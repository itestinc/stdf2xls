module makechip.Histogram;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import makechip.Config;
import std.stdio;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import makechip.logo;
import makechip.Util;
import makechip.SpreadsheetWriter;
import makechip.Spreadsheet;

import libxlsxd.chart;
//import libxlsd.charaxis;
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
			TestRecord[] tests = dr.tests;
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
            writeln("fname = ", fname);
        }
        else {
            // ...
        }

        string sheet1 = "Sheet1";
        Workbook wb = newWorkbook(fname);
        Worksheet ws = wb.addWorksheet(sheet1);


        const TestID[] ids = getTestIDs(hdr);
        ubyte[] sites = getSites(hdr);

        const string step = hdr.step;
        writeln(step);

        uint row = 0;
        ushort col = 0;
        uint prevNumber = -1;
        uint num_of_tests = 0;

        foreach(id; ids) {

            const Record_t type = id.type;
            const string pin = id.pin;
            //const uint testNumber = id.testNumber;
            const string testName = id.testName;
            const uint dup = id.dup;

            if(type == Record_t.PTR) {
                const uint testNumber = id.testNumber;

                foreach(site; sites) {
<<<<<<< HEAD
                    //writeln("site = ", site);
                    double[] results = getResults(hdr, id, site);
                    writeln("id = ", id);
                    writeln("results = ", results);

                    foreach(result; results) {
=======
                    //double[] results = getResults(hdr, id, site);

                    //foreach(result; results) {
                    //    writeln(result);
                    //}
>>>>>>> 4fe31b0c04b0e59524c23487bb017c3ea8200666

                    }
                    if(testNumber == prevNumber) {
                        ws.write(row, col, results[0]);
                        row +=1;
                    }
                    else {
                        row = 1;
                        col +=1;
                        ws.write(0, col, testName);
                        ws.write(row, col, results[0]);
                        num_of_tests++;
                    }
                    prevNumber = testNumber;
                }
                
            }

        }
        writeln("num of tests = ", num_of_tests);
        /** 
            - add cpk
        */

        /*
        // dummy data
        string[] pins = ["pin1", "pin2", "pin3", "pin4", "pin5", "pin6", "pin7", "pin8"];
        int[] b = [7, 3, 4, 2, 1, 9, 3, 7];
        int[] c = [9, 8, 9, 7, 3, 4, 6, 2];
        int[] e = [1, 1, 1, 1, 1, 1, 1, 1];
        string[] d = ["site 1", "site 2", "upper"];

        ws.write(0, 1, d[0]);
        ws.write(0, 2, d[1]);

        foreach(i, val; pins) {
            ws.write(cast(uint)(i+1), cast(ushort)0, val);
        }
        foreach(i, val; b) {
            ws.write(cast(uint)(i+1), cast(ushort)1, val);
        }
        foreach(i, val; c) {
            ws.write(cast(uint)(i+1), cast(ushort)2, val);
        }
        foreach(i, val; e) {
            ws.write(cast(uint)(i+1), cast(ushort)3, val);
        }


        string categories = "=Sheet1!$A$2:$A$9"; // pin names

        // write data to spreadsheet
            // shared categories (temp)
        const uint categories_firstRow = 0;
        const uint categories_lastRow = 11;
        const ushort categories_firstCol = 0;
        const ushort categories_lastCol = 0;

        // create chart
        Chart ch = wb.addChart(LXW_CHART_BAR);
        Chart ch2 = wb.addChart(LXW_CHART_LINE);
        ch.titleSetName("testname");

        // series & values 1
        string values1 = "=Sheet1!$B$2:B$9";
        Chartseries series1 = ch.addChartseries(categories, values1);
        const uint values1_firstRow = 1;
        const uint values1_lastRow = 8;
        const ushort values1_firstCol = 1;
        const ushort values1_lastCol = values1_firstCol;
        series1.setValues(sheet1, values1_firstRow, values1_firstCol, values1_lastRow, values1_lastCol);
        series1.setName("Series One");
        series1.setCategories(sheet1, categories_firstRow, categories_firstCol, categories_lastRow, categories_lastCol);

        // series & values 2
        string values2 = "=Sheet1!$C$2:C$9";
        Chartseries series2 = ch.addChartseries(categories, values2);
        const uint values2_firstRow = 1;
        const uint values2_lastRow = 8;
        const ushort values2_firstCol = 2;
        const ushort values2_lastCol = values2_firstCol;
        series2.setValues(sheet1, values2_firstRow, values2_firstCol, values2_lastRow, values2_lastCol);
        series2.setName("Series Two");
        series2.setCategories(sheet1, categories_firstRow, categories_firstCol, categories_lastRow, categories_lastCol);

        // line plot
        Chartseries lineseries = ch2.addChartseries(categories, values1);
        lineseries.setValues(sheet1, values1_firstRow, values1_firstCol, values1_lastRow, values1_lastCol);
        lineseries.setName("Line Series");
        lineseries.setCategories(sheet1, categories_firstRow, categories_firstCol, categories_lastRow, categories_lastCol);

        // insert chart
        ws.insertChart(5, 5, ch);
        ws.insertChart(22, 5, ch2);
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
    Chartseries series2 = ch.addChartseries("=Sheet1!$A$1:$A$9", "=Sheet1!$C$1:C$9");
    series2.setValues("Sheet1", 1, 2, 8, 2);
    series2.setName("=Sheet1!$C$1"); // orange
    series2.setCategories("Sheet1", 1, 0, 8, 0);  // same: a, b, c.. 

    ws.insertChart(10, 2, ch);

    wb.close();
}
