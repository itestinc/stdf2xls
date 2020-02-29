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
// import libxlsd.chartsheet;

/**
*/
public void genHistogram(CmdOptions options, StdfDB stdfdb, Config config)
{

/* parametric tests to plot:
Series -> site, steps
Categories -> steps/temperatures
Values -> parametric test results

combine multiple pins into one histogram

pass testID (comprised of test number, name, duplicate number) to Eric's spreadsheet. Receive back range of values in terms of cell numberings.
testID = single instance class, immutable. Located in 'StdfDB.d'

mark limit on the histogram
*/


    foreach(hdr; stdfdb.deviceMap.keys) {

        foreach(i, dr; stdfdb.deviceMap[hdr]) {
			// TestRecord[] tests = dr.tests;
		}

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

        string sheet1 = "Sheet1";
        string sheet2 = "Sheet2";
        Workbook wb = newWorkbook(fname);
        Worksheet ws1 = wb.addWorksheet(sheet1);
        Worksheet ws2 = wb.addWorksheet(sheet2);


        const TestID[] ids = getTestIDs(hdr);
        ubyte[] sites = getSites(hdr);

        // useful headers
        const string step = hdr.step;
        const string temp = hdr.temperature;
        const string devName = hdr.devName;

        uint row = 0;
        ushort col = 0;
        uint prevNumber = -1;
        string prevName = "";
        uint num_of_tests = 0;
        uint value_count = 0;

        uint ch_row = 0;
        ushort ch_col = 0;
        double prevVal = 0;
        double min_val = 0;
        double max_val = 0;

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
                            Chart ch = wb.addChart(LXW_CHART_BAR);
                            ch.titleSetName(prevName);
                            Chartseries series = ch.addChartseries(null, null);
                            series.setName("Step "~step~" ("~temp~"C)");
                            series.setValues(sheet2, 1, cast(ushort)(col), value_count, cast(ushort)(col));
                            //series.setCategories();
                            //series.setLabels();
                            //series.setLabelsPosition(LXW_CHART_LABEL_POSITION_OUTSIDE_END);
                            Chartaxis x_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_X);
                            Chartaxis y_axis = ch.axisGet(LXW_CHART_AXIS_TYPE_Y);
                            y_axis.setName("x-axis");
                            x_axis.setName("y-axis");
                            //x_axis.setName("mean: "~to!string(histdata.mean)~", cpk: "~to!string(histdata.cpk)~", stdDev: "~to!string(histdata.stdDev));
                            ws1.insertChart(ch_row, ch_col, ch);
                            ch_row = cast(uint)(ch_row + 16);
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
        /** 
            - add cpk
            - format axis scale min/max values to min/max values of dataset
            - format axis scale reverse direction when negative
            - add high/low limit indicators on histogram
            - data series name? include step#, temperature

            - write each data value per test name [series]
            - keep track of start+end cells for each dataset

            - generate chart after writing all data values:
            - for each column, plot first to last row; test name; cpk; high/low limits
        */

        wb.close();
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
