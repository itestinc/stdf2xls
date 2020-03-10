module itestinc.HistogramFormat;

import itestinc.CmdOptions;
import itestinc.Config;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import libxlsxd.chart;
import libxlsxd.chartaxis;
import libxlsxd.chartseries;
import libxlsxd.chartsheet;

import std.stdio;

static Format headerNameFmt;
static Format headerValueFmt;
static Format listNameFmt;

lxw_chart_font TitleFont;
lxw_chart_font LegendFont;
lxw_chart_font AxisNameFont;
lxw_chart_font AxisXNumberFont;
lxw_chart_font AxisYNumberFont;
lxw_chart_line GridLineX;
lxw_chart_line GridLineY;
//lxw_chart_font LabelsFont;

/**
*/
public void initHistoFormats(Workbook wb, CmdOptions options, Config config) {

    /* DEFAULT\
    uint binCount = 0;     0 = auto
    double cutoff = 1.5;    0 = auto
    */

    if(options.binCount > 0) {
        writeln("Using manual bin count: ", options.binCount);
    }
    if(options.cutoff > 0) {
        writeln("Using manual cutoff: ", options.cutoff);
    }
    if(options.binCount < 1) {
        writeln("Defaulting to automatic bin count.");
    }
    if(options.cutoff <= 0) {
        writeln("Defaulting to automatic outlier cutoff.");
    }


    import libxlsxd.xlsxwrap : lxw_format_borders, lxw_format_alignments, lxw_format_underlines;

    headerNameFmt = wb.addFormat();
    headerNameFmt.setFontName("Arial");
    headerNameFmt.setFontSize(8.0);
    headerNameFmt.setBold();
    config.setBGColor(headerNameFmt, Config.histo_header_bg_color);
    config.setFontColor(headerNameFmt, Config.histo_header_text_color);
    headerNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    headerNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    headerNameFmt.setLeft(lxw_format_borders.LXW_BORDER_THIN);
    headerNameFmt.setBorderColor(0x1000000);

    listNameFmt = wb.addFormat();
    listNameFmt.setFontName("Arial");
    listNameFmt.setFontSize(8.0);
    listNameFmt.setBold();
    listNameFmt.setUnderline(lxw_format_underlines.LXW_UNDERLINE_SINGLE);
    config.setBGColor(listNameFmt, Config.histo_header_bg_color);
    config.setFontColor(listNameFmt, Config.histo_header_text_color);
    listNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    listNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    listNameFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    listNameFmt.setBorderColor(0x1000000);

    headerValueFmt = wb.addFormat();
    headerValueFmt.setFontName("Arial");
    headerValueFmt.setFontSize(8.0);
    config.setBGColor(headerValueFmt, Config.histo_header_bg_color);
    config.setFontColor(headerValueFmt, Config.histo_header_text_color);
    headerValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    headerValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    //headerValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    //headerValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    //headerValueFmt.setBorderColor(0x1000000);

    

    TitleFont.name = cast(char*)"Cambria";
    TitleFont.size = 20;

    //LabelsFont.size = 8;
    //LabelsFont.rotation = -90;

    LegendFont.size = 9;

    AxisNameFont.size = 9;
    AxisNameFont.bold = true;

    AxisXNumberFont.size = 9;
    AxisXNumberFont.rotation = -90;

    AxisYNumberFont.size = 9;

    GridLineX.color = 0xF2F2F2;
    GridLineY.color = 0xD9D9D9;
}