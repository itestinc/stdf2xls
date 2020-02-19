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

import libxlsxd.chart;
//import libxlsd.charaxis;
import libxlsxd.chartseries;
// import libxlsd.chartsheet;


public void genHistogram(CmdOptions options, StdfDB stdfdb, Config config)
{

/* parametric tests to plot:
Series -> site
Categories -> steps/temperatures
Values -> parametric test results
*/
    foreach(hdr; stdfdb.deviceMap.keys) {

        import std.algorithm: canFind;
        string hfile = options.hfile;	// "<device>_historgrams.pdf"
        const bool separateFileForDevice = canFind(hfile, "<device>");

        import std.array : replace;
        string fname = replace(hfile, "<device>", hdr.devName);

        if(separateFileForDevice) {
            import std.array : replace;
            fname = replace(hfile, "<device>", hdr.devName);
            writeln("fname = ", fname);
        }
        else {
            // ...
        }

        string sheet1 = "Sheet1";
        Workbook wb = newWorkbook(hfile);
        Worksheet ws = wb.addWorksheet(sheet1);

        Chart ch = wb.addChart(LXW_CHART_COLUMN);
        ch.titleSetName("Chart Title");

        // shared categories
        string categories = "=Sheet1!$A$1:$A$9";
        const uint categories_firstRow = 0;
        const uint categories_lastRow = 11;
        const ushort categories_firstCol = 0;
        const ushort categories_lastCol = categories_firstCol;

        // series & values 1
        string values1 = "=Sheet1!$B$1:B$9";
        Chartseries series1 = ch.addChartseries(categories, values1);
        const uint values1_firstRow = 0;
        const uint values1_lastRow = 11;
        const ushort values1_firstCol = 0;
        const ushort values1_lastCol = values1_firstCol;
        series1.setValues(sheet1, values1_firstRow, values1_firstCol, values1_lastRow, values1_lastCol);
        series1.setName("Series One");
        series1.setCategories(sheet1, categories_firstRow, categories_firstCol, categories_lastRow, categories_lastCol);

        // series & values 2
        string values2 = "=Sheet1!$C$1:C$9";
        Chartseries series2 = ch.addChartseries(categories, values2);
        const uint values2_firstRow = 0;
        const uint values2_lastRow = 11;
        const ushort values2_firstCol = 0;
        const ushort values2_lastCol = values1_firstCol;
        series2.setValues(sheet1, values2_firstRow, values2_firstCol, values2_lastRow, values2_lastCol);
        series2.setName("Series Two");
        series2.setCategories(sheet1, categories_firstRow, categories_firstCol, categories_lastRow, categories_lastCol);

        // insert chart
        const uint row = 5;
        const uint col = 5;
        ws.insertChart(row, col, ch);

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