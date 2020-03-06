module itestinc.Histogram;
import itestinc.StdfDB;
import itestinc.StdfFile;
import itestinc.Stdf;
import itestinc.CmdOptions;
import itestinc.Config;
import std.stdio;
import std.math;
import std.conv;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import itestinc.logo;
import itestinc.Util;
import itestinc.SpreadsheetWriter;
import itestinc.Spreadsheet;

import libxlsxd.chart;
import libxlsxd.chartaxis;
import libxlsxd.chartseries;
import libxlsxd.chartsheet;

import itestinc.WafermapFormat;

import std.algorithm.iteration : uniq, mean;
import std.algorithm.sorting : sort;
import std.algorithm.searching : count;

/**
*/
public void genHistogram(CmdOptions options, StdfDB stdfdb, Config config)
{
    uint MPR_count = 0;

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

        string sheet1 = "Histograms";
        string sheet2 = "Occurrences";
        string sheet3 = "Bin Values";
        string sheet5 = "MPR";
        Workbook wb = newWorkbook(fname);
        Worksheet ws1 = wb.addWorksheet(sheet1);
        Worksheet ws2 = wb.addWorksheet(sheet2);
        Worksheet ws3 = wb.addWorksheet(sheet3);
        Worksheet ws5 = wb.addWorksheet(sheet5);

        // logo
        import libxlsxd.xlsxwrap : lxw_image_options, lxw_object_position;
		lxw_image_options img_options;
		const double ss_width = 449 * 0.350;
		const double ss_height = 245 * 0.324;
		img_options.x_scale = (2.5 * 70.0) / ss_width;
		img_options.y_scale = (5.0 * 20.0) / ss_height;
		ws1.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws1.insertImageBufferOpt(cast(uint) 0, cast(ushort) 1, img.dup.ptr, img.length, &img_options);

        // global chart options
		lxw_image_options ch_options;
		ch_options.x_scale = 2;
		ch_options.y_scale = 1.5;
		ch_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;

        uint ch_row = 0;
        ushort ch_col = 5;

        // useful headers
        initWaferFormats(wb, options, config);
		ws1.write( 9, 0, "lot_id:", headerNameFmt);
		ws1.write(10, 0, "sublot_id:", headerNameFmt);
		ws1.write(11, 0, "devName:", headerNameFmt);
		ws1.write(12, 0, "temperature:", headerNameFmt);
		ws1.write(13, 0, "step:", headerNameFmt);
		ws1.write( 9, 1, hdr.lot_id, headerValueFmt);
		ws1.write(10, 1, hdr.sublot_id, headerValueFmt);
		ws1.write(11, 1, hdr.devName, headerValueFmt);
		ws1.write(12, 1, hdr.temperature, headerValueFmt);
		ws1.write(13, 1, hdr.step, headerValueFmt);
		ws1.mergeRange( 9, 1,  9, 3, null);
		ws1.mergeRange(10, 1, 10, 3, null);
		ws1.mergeRange(11, 1, 11, 3, null);
		ws1.mergeRange(12, 1, 12, 3, null);
		ws1.mergeRange(13, 1, 13, 3, null);

        // NOT WAFER
        if(hdr.wafer_id == "deprecated") {
            uint row = 0;
            ushort col = 0;
            uint prevNumber = -1;
            string prevName = "";
            uint num_of_tests = 0;
            uint value_count = 0;

            double prevVal = 0;
            double min_val = 0;
            double max_val = 0;

            ubyte[] sites = getSites(hdr);
            writeln("sites = ", sites);

            const TestID[] ids = getTestIDs(hdr);
            foreach(id; ids) {

                if(id.type == Record_t.PTR) {

                    //const Record_t type = id.type;
                    //const string pin = id.pin;
                    const uint testNumber = id.testNumber;
                    const string testName = id.testName;
                    //const uint dup = id.dup;

                    foreach(site; sites) {
                        HistoData histdata = getResults(hdr, id, site);
                        writeln("id = ", id);
                        writeln("histdata = ", histdata);
                        double value = histdata.values[0];

                        if(histdata.values.length > 1) {
                            throw new Exception("longer values");
                        }

                        if(testNumber == prevNumber) {
                            ws2.write(row, col, value);
                            row +=1;
                            value_count++;

                            max_val = (prevVal > value) ? prevVal:value;
                            min_val = (prevVal < value) ? prevVal:value;
                        }
                        else {
                            // new test name, test number
                            if(col > 0) {
                                // write the PREVIOUS dataset to chart
                                Chart ch = wb.addChart(LXW_CHART_COLUMN);
                                ch.titleSetName(prevName);
                                Chartseries series = ch.addChartseries(null, null);
                                series.setName("Step "~hdr.step~" ("~hdr.temperature~"C)");
                                series.setValues(sheet2, 1, cast(ushort)(col), value_count, cast(ushort)(col));
                                Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                                Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                                x_axis.setName("x-axis");
                                y_axis.setName("y-axis");
                                ws1.insertChart(ch_row, ch_col, ch);
                                ch_row = cast(uint)(ch_row + 15);
                            }
                            // initialize new dataset
                            col +=1;
                            ws2.write(0, col, testName);
                            row = 1;
                            value_count = 1;
                            ws2.write(1, col, value);
                            num_of_tests++;

                        }
                        prevNumber = testNumber;
                        prevName = testName;
                        prevVal = value;
                    }
                }
            }
            writeln("num of tests = ", num_of_tests);
            wb.close();
        }
        // WAFER
        else {
            writeln("wafer");

            uint sh5_row = 0;
            ushort sh5_col = 0;

            uint sh3_row = 0;
            ushort sh3_col = 0;

            uint sh2_row = 0;
            ushort sh2_col = 0;

            uint sh1_row = 14;
            const ushort sh1_col = 0;
            ws1.write(sh1_row, sh1_col, "Test #", headerNameFmt2);
            ws1.write(sh1_row, cast(ushort)(sh1_col + 1), "Duplicate #", headerNameFmt2);
            ws1.write(sh1_row, cast(ushort)(sh1_col + 2), "Test Name", headerNameFmt2);
            ws1.mergeRange( sh1_row, 2,  sh1_row, 4, null);
            sh1_row++;

            const TestID[] ids = getTestIDs(hdr);
            foreach(id; ids) {
                if(id.type == Record_t.PTR ) {

                    ws1.write(sh1_row, sh1_col, id.testNumber, headerValueFmt);
                    ws1.write(sh1_row, cast(ushort)(sh1_col + 1), id.dup, headerValueFmt);
                    ws1.write(sh1_row, cast(ushort)(sh1_col + 2), id.testName, headerValueFmt);
                    ws1.mergeRange( sh1_row, 2,  sh1_row, 4, null);
                    sh1_row++;

                    sh2_row = 0;
                    sh3_row = 0;
                    ws2.write(sh2_row, sh2_col, id.testName);
                    ws3.write(sh3_row, sh3_col, id.testName);
                    sh2_row++;
                    sh3_row++;

                    // store ALL histo values from ALL sites into one array
                    double[] histvalues_allsites;
                    HistoData histodata_allsites = getResults(hdr, id);

                    if(histodata_allsites.values.length == 0) {       //when is this the case?
                        writeln("skipped; no value(s) in histodata.");
                        //histvalues_allsites.length +=1;
                        //histvalues_allsites[0] = -1;
                        continue;
                    }

                    foreach(i, value; histodata_allsites.values) {
                        histvalues_allsites.length +=1;
                        histvalues_allsites[i] = value;
                    }

                    // setup chart for each PTR
                    Chart ch = wb.addChart(LXW_CHART_COLUMN);
                    ch.titleSetName(id.testName);
                    Chartsheet sh = wb.addChartsheet(to!string(id.testNumber)~"-"~to!string(id.dup));
                    Chartseries[] series;
                    
                    // quantize the array into bins
                    double bin_width = (3.5*histodata_allsites.stdDev)/pow(histvalues_allsites.length, 1/3);
                    //bin_width = round(bin_width*10_000)/10_000;
                    import std.algorithm.searching : maxElement, minElement;
                    histvalues_allsites.sort();
                    const double min_value = histvalues_allsites[0];
                    const double max_value = histvalues_allsites[$-1];
                    uint num_of_bins =cast(uint)ceil( (max_value - min_value)/bin_width );

                    if(num_of_bins == 0) {                 //when is this the case?
                        num_of_bins = 1;
                    }

                    // here, need to cut out the outliers, and zoom into denser frequencies
                    double[] quantized_values = new double[](num_of_bins);
                    foreach(i, value; quantized_values) {
                        quantized_values[i] = ceil((bin_width*(i+1) + min_value)*1_000)/1_000;     // only works for even distribution
                        //quantized_values[i]
                        // quantized_values[i] = round(value.quantize(bin_width)*1000)/1000;
                    }

                    writeln("min = ", min_value, " | max = ", max_value, "| mean = ", mean(quantized_values));
                    //writeln("quantized_values = ", quantized_values);
                    //writeln("bin width = ", bin_width);

                    quantized_values.sort();
                    double[] quantized_values_unique;
                    uint qvui = 0;
                    bool first_index = true;
                    foreach(value; uniq(quantized_values)) {
                        quantized_values_unique.length++;
                        quantized_values_unique[qvui] = value;

                        if(first_index) {
                            ws3.write(sh3_row, sh3_col, "["~to!string(min_value)~", "~to!string(value)~")");
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

                    //writeln("Unique quantized values = ", quantized_values_unique);

                    // write data for each site
                    ubyte[] sites = getSites(hdr);
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

                        series.length++;
                        series[s] = ch.addChartseries(null, null);
                        series[s].setName("site "~to!string(site)~" (std="~to!string(histodata.stdDev)~")");
                        series[s].setValues(sheet2, cast(uint)(sh2_row - number_of_bins), sh2_col, cast(uint)(sh2_row-1), sh2_col);
                        series[s].setLabels();
                        series[s].setLabelsPosition(LXW_CHART_LABEL_POSITION_OUTSIDE_END);

                        
                    }
                    sh2_col++;
                    sh2_row = 0;

                    foreach(i, s; series) {
                        series[i].setCategories(sheet3, cast(uint)1, sh3_col, cast(uint)(number_of_bins), sh3_col);
                    }
                    sh3_col++;
                    sh3_row = 0;

                    Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                    Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                    x_axis.setName("ranges of values");
                    y_axis.setName("number of occurrences");
                    x_axis.majorGridlinesSetVisible(true);
                    ch.legendSetPosition(LXW_CHART_LEGEND_TOP);  

                    sh.setChart(ch);
                    sh.activate();
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
