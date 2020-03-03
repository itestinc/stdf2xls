module makechip.Histogram;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import makechip.Config;
import std.stdio;
import std.math;
import std.conv;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import makechip.logo;
import makechip.Util;
import makechip.SpreadsheetWriter;
import makechip.Spreadsheet;

import libxlsxd.chart;
import libxlsxd.chartaxis;
import libxlsxd.chartseries;
//import libxlsxd.chartsheet;

import makechip.WafermapFormat;

/**
*/
public void genHistogram(CmdOptions options, StdfDB stdfdb, Config config)
{
    foreach(hdr; stdfdb.deviceMap.keys) {

        import std.algorithm: canFind;
        string hfile = options.hfile;	// "<device>_histograms.pdf"
        const bool separateFileForDevice = canFind(hfile, "<device>");

        import std.array : replace;
        string fname = replace(hfile, "<device>", hdr.devName);
        if (options.verbosityLevel > 9) writeln(fname);

        if(separateFileForDevice) {
            import std.array : replace;
            fname = replace(hfile, "<device>", hdr.devName);
        }
        else {
            // ...
        }

        string sheet1 = "Histograms";
        string sheet2 = "Occurrences";
        string sheet3 = "Bin Values";
        string sheet4 = "Raw Values";
        Workbook wb = newWorkbook(fname);
        Worksheet ws1 = wb.addWorksheet(sheet1);
        Worksheet ws2 = wb.addWorksheet(sheet2);
        Worksheet ws3 = wb.addWorksheet(sheet3);
        Worksheet ws4 = wb.addWorksheet(sheet4);

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

        uint ch_row = 0;
        ushort ch_col = 6;

        // NOT WAFER
        if(hdr.wafer_id == "") {
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
                                //series.setCategories();
                                //series.setLabels();
                                //series.setLabelsPosition(LXW_CHART_LABEL_POSITION_OUTSIDE_END);
                                Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                                Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                                x_axis.setName("x-axis");
                                y_axis.setName("y-axis");
                                //x_axis.setName("mean: "~to!string(histdata.mean)~", cpk: "~to!string(histdata.cpk)~", stdDev: "~to!string(histdata.stdDev));
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

            uint sh4_row = 0;
            ushort sh4_col = 0;

            uint sh3_row = 0;
            ushort sh3_col = 0;

            uint sh2_row = 0;
            ushort sh2_col = 0;

            const uint underflow_bin_count = 0;
            const uint overflow_bin_count = 0;

            const TestID[] ids = getTestIDs(hdr);
            foreach(id; ids) {
                if(id.type == Record_t.PTR) {

                    // setup chart for each PTR
                    Chart ch = wb.addChart(LXW_CHART_COLUMN);
                    ch.titleSetName(id.testName);
                    Chartseries[] series;

                    double[] bin_values_allsites;
                    uint bva = 0;       // keep track of bin values for all sites
                    import std.algorithm.iteration : uniq;
                    import std.algorithm.sorting : sort;
                    sh2_row = 0;
                    sh3_row = 0;
                    ws2.write(sh2_row, sh2_col, id.testName);
                    ws3.write(sh3_row, sh3_col, id.testName);
                    sh2_row++;
                    sh3_row++;

                    // write data for each site
                    ubyte[] sites = getSites(hdr);
                    foreach(s, site; sites) {
                        HistoData histodata = getResults(hdr, id, site);

                        // SHEET 2: BIN FREQ
                        ws2.write(sh2_row, sh2_col, "site "~to!string(site));
                        sh2_row++;

                        // quantize raw values into bins, then store into bin_values array.
                        const ulong n = histodata.values.length;    // total number of data points
                        writeln(n);
                        const double bin_width = 3.5*histodata.stdDev/pow(n, 3);       // Scott's normal reference formula to determine bin width
                        double[] bin_values;
                        foreach(v, val; histodata.values) {
                            ws4.write(sh4_row, sh4_col, val);   //write raw values for debug
                            sh4_row++;

                            bin_values.length +=1;
                            bin_values[v] = val.quantize(bin_width);
                            // store bins to master array containing bins for all sites
                            bin_values_allsites.length +=1;
                            bin_values_allsites[bva] = bin_values[v]; bva++;
                        }
                        sh4_col++;
                        sh4_row = 0;

                        // calculate bin frequency
                        uint[] bin_counts;
                        uint v = 0;
                        import std.algorithm.searching : count;
                        foreach(val; uniq( sort(bin_values) )) {
                            bin_counts.length +=1;
                            bin_counts[v] = cast(uint)count(bin_values, val);
                            ws2.write(sh2_row, sh2_col, bin_counts[v]);     // write bin frequencies
                            sh2_row++;
                            v++;
                        }             

                        series.length++;
                        series[s] = ch.addChartseries(null, null);
                        series[s].setName("site "~to!string(site)~" (std="~to!string(histodata.stdDev)~")");
                        series[s].setValues(sheet2, cast(uint)2, sh2_col, cast(uint)(bin_counts.length+1), sh2_col);

                        sh2_col++;        
                        sh2_row = 1; 
                    }
                    
                    // SHEET 3: BIN VALUES UNIQUE
                    uint bva_uniq = 0;
                    foreach(val; uniq( sort(bin_values_allsites) ) ) {
                        ws3.write(sh3_row, sh3_col, val);     // write unique bin values
                        sh3_row++;
                        bva_uniq++;
                    }

                    // set chart categories as the unique bin values across all sites.
                    foreach(i, s; series) {
                        series[i].setCategories(sheet3, cast(uint)1, sh3_col, cast(uint)bva_uniq, sh3_col);
                    }
                    sh3_col++;
                    sh3_row = 0;

                    Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                    Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                    x_axis.setName("value bins");
                    y_axis.setName("number of occurrences");
                    ws1.insertChart(ch_row, ch_col, ch);
                    ch_row = cast(uint)(ch_row + 15);      
                }
            }
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
    auto ws = wb.addWorksheet("Sheet1");

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

    ws.insertChart(10, 2, ch);

    wb.close();
}
