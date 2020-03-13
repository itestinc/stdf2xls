module itestinc.Histogram;
import itestinc.HistogramFormat;

import itestinc.logo;
import itestinc.Util;
import itestinc.Spreadsheet;
import itestinc.StdfDB;
import itestinc.Stdf;
import itestinc.StdfFile;
import itestinc.CmdOptions;
import itestinc.Config;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.xlsxwrap;
import libxlsxd.chart;
import libxlsxd.chartaxis;
import libxlsxd.chartseries;
import libxlsxd.chartsheet;

import std.stdio;
import std.math : pow, ceil, round, isNaN;
import std.conv : to;
import std.array : replace;
import std.algorithm.iteration : uniq, mean;
import std.algorithm.sorting : sort;
import std.algorithm.searching : count, canFind;    // maxElement, minElement;
import std.string : chop;

/**
*/
public void genHistogram(CmdOptions options, StdfDB stdfdb, Config config)
{
    const double bin_width_divider = 40;    // larger = more bins
    const double aggressive_multiplier = 0.15;  // smaller = more aggressive
    const double cutoff_compensator = options.cutoff*aggressive_multiplier*6;   // increases the number of inner bins after cutting off the outlier bins; larger = more bins
    //const double cutoff_compensator = 20;

    foreach(hdr; stdfdb.deviceMap.keys) {

        string hfile = options.hfile;
        const bool separateFileForDevice = canFind(hfile, "%device%");

        uint MPR_count = 0;
        uint histo_count = 0;

        string devName = replace(hdr.devName, " ", "_");    // spaces are evil
        devName = replace(hdr.devName, "/", "_");

        string fname = replace(hfile, "%device%", devName);
        if (options.verbosityLevel > 9) writeln(fname);

        if(separateFileForDevice) {
            fname = replace(hfile, "%device%", devName);
        }
        else {
            // ... 
        }

        // create sheets and track row/col indices
        string sheet1 = "Histograms";
        string sheet2 = "Occurrences";
        string sheet3 = "Bin Values";
        //string sheet5 = "MPR";
        Workbook wb = newWorkbook(fname);
        Worksheet ws1 = wb.addWorksheet(sheet1);
        Worksheet ws2 = wb.addWorksheet(sheet2);
        Worksheet ws3 = wb.addWorksheet(sheet3);
        //Worksheet ws5 = wb.addWorksheet(sheet5);

        initHistoFormats(wb, options, config);

        uint sh1_row = 8;
        const ushort sh1_col = 0;
        uint sh2_row = 0;
        ushort sh2_col = 0;
        uint sh3_row = 0;
        ushort sh3_col = 0;
        //uint sh5_row = 0;
        //ushort sh5_col = 0;

        // draw logo
        import libxlsxd.xlsxwrap : lxw_image_options, lxw_object_position;
		lxw_image_options img_options;
		const double ss_width = 449 * 0.350;
		const double ss_height = 245 * 0.324;
		img_options.x_scale = (4.0 * 70.0) / ss_width;
		img_options.y_scale = (7.0 * 20.0) / ss_height;
		ws1.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws1.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &img_options);

        // write useful headers
        const uint header_row = 0;
        const ushort header_col = 4;

        ws1.mergeRange(cast(uint)(header_row+0), header_col, cast(uint)(header_row+0), cast(ushort)(header_col+1), "Wafer ID:", headerNameFmt);
		ws1.mergeRange(cast(uint)(header_row+1), header_col, cast(uint)(header_row+1), cast(ushort)(header_col+1), "Lot ID:", headerNameFmt);
		ws1.mergeRange(cast(uint)(header_row+2), header_col, cast(uint)(header_row+2), cast(ushort)(header_col+1), "Sublot ID:", headerNameFmt);
		ws1.mergeRange(cast(uint)(header_row+3), header_col, cast(uint)(header_row+3), cast(ushort)(header_col+1), "Device Name:", headerNameFmt);
		ws1.mergeRange(cast(uint)(header_row+4), header_col, cast(uint)(header_row+4), cast(ushort)(header_col+1), "Temperature:", headerNameFmt);
		ws1.mergeRange(cast(uint)(header_row+5), header_col, cast(uint)(header_row+5), cast(ushort)(header_col+1), "Step:", headerNameFmt);
        ws1.mergeRange(cast(uint)(header_row+6), header_col, cast(uint)(header_row+6), cast(ushort)(header_col+1), "Sites:", headerNameFmt);
        ws1.mergeRange(cast(uint)(header_row+7), header_col, cast(uint)(header_row+7), cast(ushort)(header_col+1), "Histogram Options:", headerNameFmt);

        ws1.mergeRange(cast(uint)(header_row+0), cast(ushort)(header_col+2), cast(uint)(header_row+0), cast(ushort)(header_col+4), hdr.wafer_id, headerValueFmt);
		ws1.mergeRange(cast(uint)(header_row+1), cast(ushort)(header_col+2), cast(uint)(header_row+1), cast(ushort)(header_col+4), hdr.lot_id, headerValueFmt);
		ws1.mergeRange(cast(uint)(header_row+2), cast(ushort)(header_col+2), cast(uint)(header_row+2), cast(ushort)(header_col+4), hdr.sublot_id, headerValueFmt);
		ws1.mergeRange(cast(uint)(header_row+3), cast(ushort)(header_col+2), cast(uint)(header_row+3), cast(ushort)(header_col+4), hdr.devName, headerValueFmt);
		ws1.mergeRange(cast(uint)(header_row+4), cast(ushort)(header_col+2), cast(uint)(header_row+4), cast(ushort)(header_col+4), hdr.temperature, headerValueFmt);
		ws1.mergeRange(cast(uint)(header_row+5), cast(ushort)(header_col+2), cast(uint)(header_row+5), cast(ushort)(header_col+4), hdr.step, headerValueFmt);
        ws1.mergeRange(cast(uint)(header_row+6), cast(ushort)(header_col+2), cast(uint)(header_row+6), cast(ushort)(header_col+4), to!string(getSites(hdr)), headerValueFmt);
        ws1.mergeRange(cast(uint)(header_row+7), cast(ushort)(header_col+2), cast(uint)(header_row+7), cast(ushort)(header_col+4), "\"--binCount "~to!string(options.binCount)~" --cutoff "~to!string(options.cutoff)~"\"", headerValueFmt);

        ws1.write(8, 10, "Right-click on the sheet scroll arrows (bottom left) for easy navigation.");
        ws1.write(sh1_row, sh1_col, "Test #", listNameFmt);
        ws1.write(sh1_row, cast(ushort)(sh1_col + 1), "Duplicate #", listNameFmt);
        ws1.write(sh1_row, cast(ushort)(sh1_col + 2), "Sheet #", listNameFmt);
        ws1.mergeRange( sh1_row, cast(ushort)(sh1_col + 3),  sh1_row, cast(ushort)(sh1_col + 8), "Test Name", listNameFmt);
        sh1_row++;

        /*
        foreach(i, dev_records; stdfdb.deviceMap[hdr]) {
            foreach(test_records; dev_records.tests) {
               // writeln(tr.id.testName, " ", tr.id.testNumber, " | lolimit = ", tr.loLimit, " | hilimit = ", tr.hiLimit);
                writeln(test_records.id.type);
            }
        }
        */

        const TestID[] ids = getTestIDs(hdr);
        foreach(id; ids) {
            if(id.type == Record_t.PTR || id.type == Record_t.MPR) {

                // case 1. packaged device with same test on different pins
                if( id.sameMPRTest(id) ) {
                    //writeln("MPR: ", id.testName, " | ", id.testNumber, " | ", id.dup);
                    MPR_count++;
                    if( hdr.isWafersort() ) {
                        writeln("Is Wafer Sort");
                    }
                    else {
                        writeln("NOT Wafer");
                    }
                }
                else {
                    //writeln(id.type);
                    //writeln(id.pin);
                }

                // store all of a test's values from all sites into one array
                HistoData histodata_allsites = getResults(hdr, id);
                if(histodata_allsites.values.length == 0) { continue; }     // some tests have no values

                //const double all_mean = histodata_allsites.mean;
                //if(isNaN(all_mean)) { throw new Exception("all_mean is NaN."); }

                //const double all_stdDev = histodata_allsites.stdDev;
                //if(isNaN(all_stdDev)) { throw new Exception("all_stdDev is NaN."); }

                double[] histvalues_allsites;

                foreach(i, value; histodata_allsites.values) {
                    histvalues_allsites.length +=1;
                    histvalues_allsites[i] = value;
                }
                histvalues_allsites.sort();     // need this to get min, max values
                
                // quantize the values into bins
                double bin_width = (3.5*histodata_allsites.stdDev)/pow(histvalues_allsites.length, 1/3);    // Scott's normal reference formula (bin width is too wide for our usage)
                bin_width = bin_width / bin_width_divider;                                                  // so, adjust the bin width with custom divider

                // cut off outliers based on mean vs. standard deviation of each site
                double min_value_new;
                double max_value_new;
                double min_value_eachsite;
                double max_value_eachsite;
                ubyte[] sites = getSites(hdr);
                foreach(i, site; sites) {
                    const HistoData histodata = getResults(hdr, id, site);

                    if(options.cutoff <= 0) {
                            min_value_new = histvalues_allsites[0];
                            max_value_new = histvalues_allsites[$-1];
                    }
                    else {
                        if(histodata.stdDev > 10*bin_width) {               // standard deviation is much narrower compared to bin width, so the cut off has to be more aggressive.
                            min_value_eachsite = histodata.mean - (aggressive_multiplier)*options.cutoff*histodata.stdDev;
                            max_value_eachsite = histodata.mean + (aggressive_multiplier)*options.cutoff*histodata.stdDev;
                            bin_width = bin_width / cutoff_compensator;     // compensate outer bin cut offs with more bins; should scale well with outlier cutoff multiplier
                        }
                        else {
                            min_value_eachsite = histodata.mean - options.cutoff*histodata.stdDev;
                            max_value_eachsite = histodata.mean + options.cutoff*histodata.stdDev;
                        }

                        if(i > 0) {
                            min_value_new = (min_value_new < min_value_eachsite) ? min_value_new : min_value_eachsite;
                            max_value_new = (max_value_new > max_value_eachsite) ? max_value_new : max_value_eachsite;
                         }
                        else {  // initialize values at the first index
                            min_value_new = min_value_eachsite;
                            max_value_new = max_value_eachsite;
                        }
                    }
                }

                //if(isNaN(min_value_new)) { throw new Exception("min_value_new is NaN."); }
                //if(isNaN(max_value_new)) { throw new Exception("max_value_new is NaN."); }

                // calculate number of bins based on bin width and ranges
                double[] quantized_values;
                double custom_bin_width;
                
                if(options.binCount < 1) {
                    uint auto_number_of_bins =cast(uint)ceil( (max_value_new - min_value_new)/bin_width );  // general formula

                    if(auto_number_of_bins == 0) { auto_number_of_bins = 1; }   //All values in histodata are the same, so assign just 1 bin.
                    quantized_values = new double[](auto_number_of_bins);
                }
                else {
                    custom_bin_width = cast(double)( (max_value_new - min_value_new)/options.binCount );
                    quantized_values = new double[](options.binCount);
                }

                // calculate the bin ranges using bin width, using the minimum value as base. Round to 3 decimals for better readability.
                foreach(i, value; quantized_values) {
                    if(options.binCount < 1) { quantized_values[i] = (bin_width*(i+1) + min_value_new); }     // quantized_values is automatically sorted with this
                    else { quantized_values[i] = (custom_bin_width*(i+1) + min_value_new); }
                }

                // write a list of tests that has histograms
                ws1.write(sh1_row, sh1_col, id.testNumber, headerValueFmt);
                ws1.write(sh1_row, cast(ushort)(sh1_col + 1), id.dup, headerValueFmt);
                ws1.write(sh1_row, cast(ushort)(sh1_col + 2), histo_count, headerValueFmt);
                ws1.mergeRange( sh1_row, cast(ushort)(sh1_col + 3),  sh1_row, cast(ushort)(sh1_col + 8), id.testName, headerValueFmt);
                sh1_row++;

                // write testname headers to raw data sheets for debug.
                sh2_row = 0; ws2.write(sh2_row, sh2_col, id.testName); sh2_row++;
                sh3_row = 0; ws3.write(sh3_row, sh3_col, id.testName); sh3_row++;

                // write histogram categories (bins) for each site
                double[] quantized_values_unique;
                uint qvui = 0;
                bool first_index = true;
                foreach(value; uniq(quantized_values)) {
                    quantized_values_unique.length++;
                    quantized_values_unique[qvui] = value;

                    if(first_index) {
                        ws3.write(sh3_row, sh3_col, "["~to!string(min_value_new)~", "~to!string(value)~")");
                        first_index = false;
                    }
                    else {
                        const double prev_value = quantized_values_unique[qvui-1];
                        ws3.write(sh3_row, sh3_col, "["~to!string(prev_value)~", "~to!string(value)~")");
                    }
                    qvui++;
                    sh3_row++;
                }
                ulong number_of_bins = quantized_values_unique.length;

                // set up histogram chart for each PTR
                Chart ch = wb.addChart(LXW_CHART_COLUMN);
                ch.titleSetName(id.testName~"\n"~"(Low limit: "~to!string(0)~", High limit: "~to!string(0)~")");
                ch.titleSetNameFont(&TitleFont);

                // replace any invalid characters for sheet name
                string sheetName = replace(id.testName, " ", "_");
                sheetName = replace(sheetName, ":", "-");
                sheetName = replace(sheetName, "[", "(");
                sheetName = replace(sheetName, "]", ")");
                sheetName = replace(sheetName, "*", "_");
                sheetName = replace(sheetName, "?", "_");
                sheetName = replace(sheetName, "\\", "_");
                sheetName = replace(sheetName, "/", "_");

                // max excel sheet name length is 31 characters
                sheetName = to!string(histo_count)~"-"~sheetName;
                while(sheetName.length > 30) {
                    sheetName = chop(sheetName);
                }
                Chartsheet sh = wb.addChartsheet(sheetName);
                histo_count++;
                Chartseries[] series;

                // count the data frequency (number of occurrences) for each site
                foreach(s, site; sites) {
                    HistoData histodata = getResults(hdr, id, site);

                    uint[] bin_count = new uint[](number_of_bins);
                    foreach(i, val; histodata.values) {
                        foreach(j, qval; quantized_values_unique) {
                            if(val < qval) {
                                bin_count[j]++;
                                break;
                            }
                            else {
                                if(j == number_of_bins-1 ) { bin_count[j]++; }      // last value goes into last bin
                                continue;
                            }
                        }
                    }
                    
                    // write data frequency
                    foreach(value; bin_count) {
                        ws2.write(sh2_row, sh2_col, value);
                        sh2_row++;
                    }

                    // assign data cells to histogram
                    series.length++;
                    series[s] = ch.addChartseries(null, null);
                    series[s].setName("site "~to!string(site)~" (std="~to!string(histodata.stdDev)~", cpk = "~to!string(histodata.cpk)~", mean = "~to!string(histodata.mean)~")");
                    series[s].setValues(sheet2, cast(uint)(sh2_row - number_of_bins), sh2_col, cast(uint)(sh2_row-1), sh2_col);
                    //series[s].setLabels();
                    //series[s].setLabelsFont(&LabelsFont);
                    //series[s].setLabelsPosition(LXW_CHART_LABEL_POSITION_OUTSIDE_END);
                    series[s].setCategories(sheet3, cast(uint)1, sh3_col, cast(uint)(number_of_bins), sh3_col);
                    sh3_col++;
                    sh3_row = 0;
                }
                sh2_col++;
                sh2_row = 0;

                // set histogram formats and insert into excel
                Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                x_axis.setName("Bins (min: "~to!string( histvalues_allsites[0] )~", max: "~to!string( histvalues_allsites[$-1] )~")");
                y_axis.setName("Number of Occurrences");
                x_axis.setNameFont(&AxisNameFont);
                y_axis.setNameFont(&AxisNameFont);
                x_axis.setNumFont(&AxisXNumberFont);
                y_axis.setNumFont(&AxisYNumberFont);
                x_axis.majorGridlinesSetVisible(true);
                x_axis.majorGridlinesSetLine(&GridLineX);
                y_axis.majorGridlinesSetVisible(true);
                y_axis.majorGridlinesSetLine(&GridLineY);
                ch.legendSetPosition(LXW_CHART_LEGEND_TOP);  
                ch.legendSetFont(&LegendFont);
                sh.setChart(ch);
            }
        }
        writeln("MPR Count = ", MPR_count);
        ws2.hide();
        ws3.hide();
        //ws5.hide();
        ws1.select();
        wb.close();
    }
}

unittest {

    string[] a = ["a", "b", "c", "d", "e", "f", "g", "h"];
    int[] b = [7, 3, 4, 2, 1, 9, 3, 7];
    int[] c = [9, 8, 9, 7, 3, 4, 6, 2];
    string[] d = ["apple", "orange"];

    Workbook wb = newWorkbook("histo_test.xlsx");
    Worksheet ws = wb.addWorksheet("Sheet1");
    Chartsheet sh = wb.addChartsheet("Chartsheet1");

    ws.write(0, 1, d[0]);
    ws.write(0, 2, d[1]);

    foreach(i, val; a) {
        ws.write(cast(uint)(i+1), cast(ushort)0, val);
    }
    foreach(i, val; b) {
        ws.write(cast(uint)(i+1), cast(ushort)1, val);
    }
    foreach(i, val; c) {
        ws.write(cast(uint)(i+1), cast(ushort)2, val);
    }

    Chart ch = wb.addChart(LXW_CHART_COLUMN);
    ch.titleSetName("Example Title");

    // APPLE
    Chartseries series = ch.addChartseries("=Sheet1!$A$1:$A$9", "=Sheet1!$B$1:B$9"); // categories, values
    series.setValues("Sheet1", 1, 1, 8, 1);
    series.setName("=Sheet1!$B$1"); // apple
    series.setCategories("Sheet1", 1, 0, 8, 0);  // same: a, b, c..

    // ORANGE
    //Chartseries series2 = ch.addChartseries("=Sheet1!$A$1:$A$9", "=Sheet1!$C$1:C$9");
    Chartseries series2 = ch.addChartseries("=Sheet1!$A$1:$A$9", "=Sheet1!$C$1:C$9");
    series2.setValues("Sheet1", 1, 2, 8, 2);
    series2.setName("=Sheet1!$C$1"); // orange
    series2.setCategories("Sheet1", 1, 0, 8, 0);  // same: a, b, c.. 

    //ws.insertChart(10, 2, ch);
    sh.setChart(ch);  // cannot insert chart in both worksheet and chartsheet.
    sh.activate();

    wb.close();
}
