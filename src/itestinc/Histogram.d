module itestinc.Histogram;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import itestinc.logo;
import itestinc.Util;
import itestinc.SpreadsheetWriter;
import itestinc.Spreadsheet;
import itestinc.StdfDB;
import itestinc.StdfFile;
import itestinc.Stdf;
import itestinc.CmdOptions;
import itestinc.Config;
import itestinc.WafermapFormat;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import libxlsxd.chart;
import libxlsxd.chartaxis;
import libxlsxd.chartseries;
import libxlsxd.chartsheet;
import itestinc.WafermapFormat;

import std.stdio;
import std.math;
import std.conv;
import std.algorithm.iteration : uniq, mean;
import std.algorithm.sorting : sort;
import std.algorithm.searching : count;

/**
*/

public void genHistogram(CmdOptions options, StdfDB stdfdb, Config config)
{
    // Possible cmd options
    const double outlier_cutoff = 1.5;      // is a multiplier of standard deviation; larger = less cutoff
    const double bin_width_divider = 20;    // larger = more bins

    uint MPR_count = 0;

    lxw_chart_font TitleFont;
    TitleFont.name = cast(char*)"Cambria";
    TitleFont.size = 20;

    //lxw_chart_font LabelsFont;
    //LabelsFont.size = 8;
    //LabelsFont.rotation = -90;

    lxw_chart_font LegendFont;
    LegendFont.size = 9;

    lxw_chart_font AxisNameFont;
    AxisNameFont.size = 9;
    AxisNameFont.bold = true;

    lxw_chart_font xAxisNumberFont;
    xAxisNumberFont.size = 9;
    xAxisNumberFont.rotation = -45;

    lxw_chart_font yAxisNumberFont;
    yAxisNumberFont.size = 9;

    lxw_chart_line GridLine;
    GridLine.color = 0xC8C8C8;

    foreach(hdr; stdfdb.deviceMap.keys) {

        import std.algorithm: canFind;
        string hfile = options.hfile;	// "%device%_histograms.xlsx";
        const bool separateFileForDevice = canFind(hfile, "%device%");

        import std.array : replace;
        string fname = replace(hfile, "%device%", hdr.devName);
        if (options.verbosityLevel > 9) writeln(fname);

        if(separateFileForDevice) {
            import std.array : replace;
            fname = replace(hfile, "%device%", hdr.devName);
        }
        else {
            // ...
        }

        foreach(i, dr; stdfdb.deviceMap[hdr]) {
            foreach(tr; dr.tests) {
                //writeln(tr.loLimit);
            }
        }

        // create sheets and track row/col indices
        string sheet1 = "Histograms";
        string sheet2 = "Occurrences";
        string sheet3 = "Bin Values";
        string sheet5 = "MPR";
        Workbook wb = newWorkbook(fname);
        Worksheet ws1 = wb.addWorksheet(sheet1);
        Worksheet ws2 = wb.addWorksheet(sheet2);
        Worksheet ws3 = wb.addWorksheet(sheet3);
        Worksheet ws5 = wb.addWorksheet(sheet5);

        uint sh1_row = 1;
        uint sh2_row = 0;
        uint sh3_row = 0;
        uint sh5_row = 0;

        const ushort sh1_col = 5;
        ushort sh2_col = 0;
        ushort sh3_col = 0;
        ushort sh5_col = 0;

        // draw logo
        import libxlsxd.xlsxwrap : lxw_image_options, lxw_object_position;
		lxw_image_options img_options;
		const double ss_width = 449 * 0.350;
		const double ss_height = 245 * 0.324;
		img_options.x_scale = (3.0 * 70.0) / ss_width;
		img_options.y_scale = (7.0 * 20.0) / ss_height;
		ws1.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws1.insertImageBufferOpt(cast(uint) 0, cast(ushort) 1, img.dup.ptr, img.length, &img_options);

        // write useful headers
        initWaferFormats(wb, options, config);
        ws1.write( 8, 0, "wafer_id:", headerNameFmt);
		ws1.write( 9, 0, "lot_id:", headerNameFmt);
		ws1.write(10, 0, "sublot_id:", headerNameFmt);
		ws1.write(11, 0, "device:", headerNameFmt);
		ws1.write(12, 0, "temp:", headerNameFmt);
		ws1.write(13, 0, "step:", headerNameFmt);
        ws1.write(14, 0, "sites:", headerNameFmt);

        ws1.write( 8, 1, hdr.wafer_id, headerValueFmt);
		ws1.write( 9, 1, hdr.lot_id, headerValueFmt);
		ws1.write(10, 1, hdr.sublot_id, headerValueFmt);
		ws1.write(11, 1, hdr.devName, headerValueFmt);
		ws1.write(12, 1, hdr.temperature, headerValueFmt);
		ws1.write(13, 1, hdr.step, headerValueFmt);
        ws1.write(14, 1, getSites(hdr).length, headerValueFmt);

        ws1.mergeRange( 8, 1,  8, 3, null);
		ws1.mergeRange( 9, 1,  9, 3, null);
		ws1.mergeRange(10, 1, 10, 3, null);
		ws1.mergeRange(11, 1, 11, 3, null);
		ws1.mergeRange(12, 1, 12, 3, null);
		ws1.mergeRange(13, 1, 13, 3, null);
        ws1.mergeRange(14, 1, 14, 3, null);

        ws1.write(sh1_row, sh1_col, "Test #", headerNameFmt2);
        ws1.write(sh1_row, cast(ushort)(sh1_col + 1), "Duplicate #", headerNameFmt2);
        ws1.write(sh1_row, cast(ushort)(sh1_col + 2), "Test Name", headerNameFmt2);
        ws1.mergeRange( sh1_row, cast(ushort)(sh1_col + 2),  sh1_row, cast(ushort)(sh1_col + 6), null);
        sh1_row++;

        const TestID[] ids = getTestIDs(hdr);
        foreach(id; ids) {
            if(id.type == Record_t.PTR ) {

                // write the list of histograms created
                ws1.write(sh1_row, sh1_col, id.testNumber, headerValueFmt);
                ws1.write(sh1_row, cast(ushort)(sh1_col + 1), id.dup, headerValueFmt);
                ws1.write(sh1_row, cast(ushort)(sh1_col + 2), id.testName, headerValueFmt);
                ws1.mergeRange( sh1_row, cast(ushort)(sh1_col + 2),  sh1_row, cast(ushort)(sh1_col + 6), null);
                sh1_row++;

                sh2_row = 0;
                sh3_row = 0;
                ws2.write(sh2_row, sh2_col, id.testName);
                ws3.write(sh3_row, sh3_col, id.testName);
                sh2_row++;
                sh3_row++;

                // store all histo values from all sites into one array
                double[] histvalues_allsites;
                HistoData histodata_allsites = getResults(hdr, id);

                if(histodata_allsites.values.length == 0) {         //when is this the case?
                    writeln("skipped; no value(s) in histodata.");
                    continue;
                }

                foreach(i, value; histodata_allsites.values) {
                    histvalues_allsites.length +=1;
                    histvalues_allsites[i] = value;
                }

                
                
                // quantize the array into bins
                double bin_width = (3.5*histodata_allsites.stdDev)/pow(histvalues_allsites.length, 1/3);    // Scott's normal reference formula (bin width is too wide for our case)
                bin_width = bin_width / bin_width_divider;       // adjust the bin width with custom divider
                //bin_width = round(bin_width*10_000)/10_000;
                import std.algorithm.searching : maxElement, minElement;
                histvalues_allsites.sort();
                
                

                // cut off outliers based on mean vs. standard deviation of each site
                double min_value_new;
                double max_value_new;
                double min_value_eachsite;
                double max_value_eachsite;
                ubyte[] sites = getSites(hdr);
                foreach(i, site; sites) {
                    HistoData histodata = getResults(hdr, id, site);

                    writeln(id.testName, " | ", histodata.stdDev, " vs ",  bin_width);

                    if(histodata.stdDev > 10*bin_width) {       // standard deviation is much narrower compared to bin width, so the cut off has to be more aggressive.
                        min_value_eachsite = histodata.mean - (0.2)*outlier_cutoff*histodata.stdDev;
                        max_value_eachsite = histodata.mean + (0.2)*outlier_cutoff*histodata.stdDev;
                        writeln("more cutoff");
                        bin_width = bin_width / 4;      // compensate outer bin cut offs with more bins
                    }
                    else {
                        min_value_eachsite = histodata.mean - outlier_cutoff*histodata.stdDev;
                        max_value_eachsite = histodata.mean + outlier_cutoff*histodata.stdDev;
                    }

                    if(i > 0) {
                        min_value_new = min_value_new < min_value_eachsite ? min_value_new : min_value_eachsite;
                        max_value_new = max_value_new > max_value_eachsite ? max_value_new : max_value_eachsite;
                    }
                    else {  // only the first index
                        min_value_new = min_value_eachsite;
                        max_value_new = max_value_eachsite;
                    }
                }

                // calculate number of bins based on bin width and ranges
                uint num_of_bins =cast(uint)ceil( (max_value_new - min_value_new)/bin_width );  // general formula

                if(num_of_bins == 0) {                 //when is this the case?
                    num_of_bins = 1;
                }

                // calculate the bin ranges using bin width, using the minimum value as base
                double[] quantized_values = new double[](num_of_bins);
                foreach(i, value; quantized_values) {
                    quantized_values[i] = ceil((bin_width*(i+1) + min_value_new)*1_000)/1_000;
                }

                // write histogram categories (bins) for each site
                quantized_values.sort();
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
                ch.titleSetName(id.testName);
                ch.titleSetNameFont(&TitleFont);
                Chartsheet sh = wb.addChartsheet(to!string(id.testNumber)~"-"~to!string(id.dup));
                Chartseries[] series;

                // write histogram data (number of occurrences) for each site
                
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
                                if(j == number_of_bins-1 ) {
                                    bin_count[j]++;
                                }
                                continue;
                            }
                        }
                    }
                    //writeln("bin_count (", to!string(site), ") = ", bin_count);
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

                const double min_value = histvalues_allsites[0];
                const double max_value = histvalues_allsites[$-1];

                // set histogram formats and insert into excel
                Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                x_axis.setName("ranges of values (min = "~to!string(min_value)~", max = "~to!string(max_value)~")");
                y_axis.setName("number of occurrences");
                x_axis.setNameFont(&AxisNameFont);
                y_axis.setNameFont(&AxisNameFont);
                x_axis.setNumFont(&xAxisNumberFont);
                y_axis.setNumFont(&yAxisNumberFont);
                x_axis.majorGridlinesSetVisible(true);
                x_axis.majorGridlinesSetLine(&GridLine);
                y_axis.majorGridlinesSetVisible(true);
                y_axis.majorGridlinesSetLine(&GridLine);
                ch.legendSetPosition(LXW_CHART_LEGEND_TOP);  
                ch.legendSetFont(&LegendFont);
                sh.setChart(ch);
                sh.activate();

                ws2.hide();
                ws3.hide();
                ws5.hide();
            }
            
            else if(id.type == Record_t.MPR) {

                if( id.sameMPRTest(id) ) {
                    //writeln("MPR: ", id.testName, " | ", id.testNumber, " | ", id.dup);
                    MPR_count++;
                }
                sh5_col = 0;
                ubyte[] sites = getSites(hdr);
                ws5.write(0, sh5_col, id.testName);
                foreach(s, site; sites) {
                    HistoData histodata = getResults(hdr, id, site);
                    ws5.write(1, sh5_col, site);
                    foreach(v, val; histodata.values) {
                        ws5.write(cast(uint)(v+2), sh5_col, val);
                        ws5.write(cast(uint)(v+2), cast(ushort)(sh5_col+1), id.pin);
                    }
                    sh5_col+=2;
                }
            }
        }
        writeln("MPR Count = ", MPR_count);
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
