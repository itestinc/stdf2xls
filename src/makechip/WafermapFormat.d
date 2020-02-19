module makechip.WafermapFormat;
import libxlsxd.format;
import libxlsxd.workbook;
import makechip.CmdOptions;
import makechip.Config;
import std.stdio;

static Format headerNameFmt;
static Format headerValueFmt;
static Format waferPassFmt;
static Format waferFailFmt;
static Format waferEmptyFmt;
static Format waferRowNumberFmt;
static Format waferColNumberFmt;

static Format waferBin01Fmt;
static Format waferBin02Fmt;
static Format waferBin03Fmt;
static Format waferBin04Fmt;
static Format waferBin05Fmt;
static Format waferBin06Fmt;
static Format waferBin07Fmt;
static Format waferBin08Fmt;
static Format waferBin09Fmt;
static Format waferBin10Fmt;
static Format waferBin11Fmt;
static Format waferBin12Fmt;
static Format waferBin13Fmt;
static Format waferBin14Fmt;
static Format waferBin15Fmt;
static Format waferBin16Fmt;

public void initWaferFormats(Workbook wb, CmdOptions options, Config config)
{
    if (options.verbosityLevel > 9) writeln("initWaferFormats()");
    import libxlsxd.xlsxwrap : lxw_format_borders, lxw_format_alignments;

	headerNameFmt = wb.addFormat();
    headerNameFmt.setFontName("Arial");
    headerNameFmt.setFontSize(8.0);
    headerNameFmt.setBold();
    config.setBGColor(headerNameFmt, Config.wafer_header_bg_color);
    config.setFontColor(headerNameFmt, Config.wafer_header_text_color);
    headerNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);

    headerValueFmt = wb.addFormat();
    headerValueFmt.setFontName("Arial");
    headerValueFmt.setFontSize(8.0);
    config.setBGColor(headerValueFmt, Config.wafer_header_bg_color);
    config.setFontColor(headerValueFmt, Config.wafer_header_text_color);
    headerValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    headerValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerValueFmt.setBorderColor(0x1000000);

    waferPassFmt = wb.addFormat();
    waferPassFmt.setFontName("Arial");
    waferPassFmt.setFontSize(7.0);
    config.setBGColor(waferPassFmt, Config.wafer_pass_bg_color);
    config.setFontColor(waferPassFmt, Config.wafer_pass_text_color);
    waferPassFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferPassFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferPassFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferPassFmt.setBorderColor(0x1000000);
    waferPassFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    // waferPassFmt.setBold();

    waferFailFmt = wb.addFormat();
    waferFailFmt.setFontName("Arial");
    waferFailFmt.setFontSize(7.0);
    config.setBGColor(waferFailFmt, Config.wafer_fail_bg_color);
    config.setFontColor(waferFailFmt, Config.wafer_pass_text_color);
    waferFailFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferFailFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferFailFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferFailFmt.setBorderColor(0x1000000);
    waferFailFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferEmptyFmt = wb.addFormat();
    waferEmptyFmt.setFontName("Arial");
    waferEmptyFmt.setFontSize(7.0);
    config.setBGColor(waferEmptyFmt, Config.wafer_empty_bg_color);
    config.setFontColor(waferEmptyFmt, Config.wafer_pass_text_color);
    waferEmptyFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferEmptyFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferEmptyFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferEmptyFmt.setBorderColor(0x1000000);
    waferEmptyFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferRowNumberFmt = wb.addFormat();
    waferRowNumberFmt.setFontName("Arial");
    waferRowNumberFmt.setFontSize(9.0);
    config.setBGColor(waferRowNumberFmt, Config.wafer_label_bg_color);
    config.setFontColor(waferRowNumberFmt, Config.wafer_label_text_color);
    waferRowNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferRowNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferRowNumberFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    waferRowNumberFmt.setBorderColor(0x1000000);

    waferColNumberFmt = wb.addFormat();
    waferColNumberFmt.setFontName("Arial");
    waferColNumberFmt.setFontSize(9.0);
    config.setBGColor(waferColNumberFmt, Config.wafer_label_bg_color);
    config.setFontColor(waferColNumberFmt, Config.wafer_label_text_color);
    waferColNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferColNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferColNumberFmt.setRotation(90);
    waferColNumberFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferColNumberFmt.setBorderColor(0x1000000);

    waferBin01Fmt = wb.addFormat();
    waferBin01Fmt.setFontName("Arial");
    waferBin01Fmt.setFontSize(7.0);
    config.setBGColor(waferBin01Fmt, Config.wafer_bin01_bg_color);
    config.setFontColor(waferBin01Fmt, Config.wafer_pass_text_color);
    waferBin01Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin01Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin01Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin01Fmt.setBorderColor(0x1000000);
    waferBin01Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    //waferBin01Fmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    //waferBin01Fmt.setLeft(lxw_format_borders.LXW_BORDER_THIN);

    waferBin02Fmt = wb.addFormat();
    waferBin02Fmt.setFontName("Arial");
    waferBin02Fmt.setFontSize(7.0);
    config.setBGColor(waferBin02Fmt, Config.wafer_bin02_bg_color);
    config.setFontColor(waferBin02Fmt, Config.wafer_pass_text_color);
    waferBin02Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin02Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin02Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin02Fmt.setBorderColor(0x1000000);
    waferBin02Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin03Fmt = wb.addFormat();
    waferBin03Fmt.setFontName("Arial");
    waferBin03Fmt.setFontSize(7.0);
    config.setBGColor(waferBin03Fmt, Config.wafer_bin03_bg_color);
    config.setFontColor(waferBin03Fmt, Config.wafer_pass_text_color);
    waferBin03Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin03Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin03Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin03Fmt.setBorderColor(0x1000000);
    waferBin03Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin04Fmt = wb.addFormat();
    waferBin04Fmt.setFontName("Arial");
    waferBin04Fmt.setFontSize(7.0);
    config.setBGColor(waferBin04Fmt, Config.wafer_bin04_bg_color);
    config.setFontColor(waferBin04Fmt, Config.wafer_pass_text_color);
    waferBin04Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin04Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin04Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin04Fmt.setBorderColor(0x1000000);
    waferBin04Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin05Fmt = wb.addFormat();
    waferBin05Fmt.setFontName("Arial");
    waferBin05Fmt.setFontSize(7.0);
    config.setBGColor(waferBin05Fmt, Config.wafer_bin05_bg_color);
    config.setFontColor(waferBin05Fmt, Config.wafer_pass_text_color);
    waferBin05Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin05Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin05Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin05Fmt.setBorderColor(0x1000000);
    waferBin05Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin06Fmt = wb.addFormat();
    waferBin06Fmt.setFontName("Arial");
    waferBin06Fmt.setFontSize(7.0);
    config.setBGColor(waferBin06Fmt, Config.wafer_bin06_bg_color);
    config.setFontColor(waferBin06Fmt, Config.wafer_pass_text_color);
    waferBin06Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin06Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin06Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin06Fmt.setBorderColor(0x1000000);
    waferBin06Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin07Fmt = wb.addFormat();
    waferBin07Fmt.setFontName("Arial");
    waferBin07Fmt.setFontSize(7.0);
    config.setBGColor(waferBin07Fmt, Config.wafer_bin07_bg_color);
    config.setFontColor(waferBin07Fmt, Config.wafer_pass_text_color);
    waferBin07Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin07Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin07Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin07Fmt.setBorderColor(0x1000000);
    waferBin07Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin08Fmt = wb.addFormat();
    waferBin08Fmt.setFontName("Arial");
    waferBin08Fmt.setFontSize(7.0);
    config.setBGColor(waferBin08Fmt, Config.wafer_bin08_bg_color);
    config.setFontColor(waferBin08Fmt, Config.wafer_pass_text_color);
    waferBin08Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin08Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin08Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin08Fmt.setBorderColor(0x1000000);
    waferBin08Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin09Fmt = wb.addFormat();
    waferBin09Fmt.setFontName("Arial");
    waferBin09Fmt.setFontSize(7.0);
    config.setBGColor(waferBin09Fmt, Config.wafer_bin09_bg_color);
    config.setFontColor(waferBin09Fmt, Config.wafer_pass_text_color);
    waferBin09Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin09Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin09Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin09Fmt.setBorderColor(0x1000000);
    waferBin09Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin10Fmt = wb.addFormat();
    waferBin10Fmt.setFontName("Arial");
    waferBin10Fmt.setFontSize(7.0);
    config.setBGColor(waferBin10Fmt, Config.wafer_bin10_bg_color);
    config.setFontColor(waferBin10Fmt, Config.wafer_pass_text_color);
    waferBin10Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin10Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin10Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin10Fmt.setBorderColor(0x1000000);
    waferBin10Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin11Fmt = wb.addFormat();
    waferBin11Fmt.setFontName("Arial");
    waferBin11Fmt.setFontSize(7.0);
    config.setBGColor(waferBin11Fmt, Config.wafer_bin11_bg_color);
    config.setFontColor(waferBin11Fmt, Config.wafer_pass_text_color);
    waferBin11Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin11Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin11Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin11Fmt.setBorderColor(0x1000000);
    waferBin11Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin12Fmt = wb.addFormat();
    waferBin12Fmt.setFontName("Arial");
    waferBin12Fmt.setFontSize(7.0);
    config.setBGColor(waferBin12Fmt, Config.wafer_bin12_bg_color);
    config.setFontColor(waferBin12Fmt, Config.wafer_pass_text_color);
    waferBin12Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin12Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin12Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin12Fmt.setBorderColor(0x1000000);
    waferBin12Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin13Fmt = wb.addFormat();
    waferBin13Fmt.setFontName("Arial");
    waferBin13Fmt.setFontSize(7.0);
    config.setBGColor(waferBin13Fmt, Config.wafer_bin13_bg_color);
    config.setFontColor(waferBin13Fmt, Config.wafer_pass_text_color);
    waferBin13Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin13Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin13Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin13Fmt.setBorderColor(0x1000000);
    waferBin13Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin14Fmt = wb.addFormat();
    waferBin14Fmt.setFontName("Arial");
    waferBin14Fmt.setFontSize(7.0);
    config.setBGColor(waferBin14Fmt, Config.wafer_bin14_bg_color);
    config.setFontColor(waferBin14Fmt, Config.wafer_pass_text_color);
    waferBin14Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin14Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin14Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin14Fmt.setBorderColor(0x1000000);
    waferBin14Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin15Fmt = wb.addFormat();
    waferBin15Fmt.setFontName("Arial");
    waferBin15Fmt.setFontSize(7.0);
    config.setBGColor(waferBin15Fmt, Config.wafer_bin15_bg_color);
    config.setFontColor(waferBin15Fmt, Config.wafer_pass_text_color);
    waferBin15Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin15Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin15Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin15Fmt.setBorderColor(0x1000000);
    waferBin15Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferBin16Fmt = wb.addFormat();
    waferBin16Fmt.setFontName("Arial");
    waferBin16Fmt.setFontSize(7.0);
    config.setBGColor(waferBin16Fmt, Config.wafer_bin16_bg_color);
    config.setFontColor(waferBin16Fmt, Config.wafer_pass_text_color);
    waferBin16Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferBin16Fmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferBin16Fmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferBin16Fmt.setBorderColor(0x1000000);
    waferBin16Fmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
}