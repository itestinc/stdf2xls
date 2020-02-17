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

///
public void initWaferFormats(Workbook wb, CmdOptions options, Config config)
{
    if (options.verbosityLevel > 9) writeln("initWaferFormats()");
    import libxlsxd.xlsxwrap : lxw_format_borders, lxw_format_alignments;

	headerNameFmt = wb.addFormat();
    headerNameFmt.setFontName("Arial");
    headerNameFmt.setFontSize(8.0);
    headerNameFmt.setBold();
    config.setBGColor(headerNameFmt, Config.ss_header_name_bg_color);
    config.setFontColor(headerNameFmt, Config.ss_header_name_text_color);
    headerNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    //headerNameFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerNameFmt.setBorderColor(0x1000000);
    //headerNameFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    headerValueFmt = wb.addFormat();
    headerValueFmt.setFontName("Arial");
    headerValueFmt.setFontSize(8.0);
    config.setBGColor(headerValueFmt, Config.ss_header_value_bg_color);
    config.setFontColor(headerValueFmt, Config.ss_header_value_text_color);
    headerValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    headerValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerValueFmt.setBorderColor(0x1000000);
    //headerValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferPassFmt = wb.addFormat();
    waferPassFmt.setFontName("Arial");
    waferPassFmt.setFontSize(7.0);
    config.setBGColor(waferPassFmt, Config.wafer_pass_bg_color);
    config.setFontColor(waferPassFmt, Config.ss_pass_text_color);
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
    config.setFontColor(waferFailFmt, Config.ss_pass_text_color);
    waferFailFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferFailFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferFailFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferFailFmt.setBorderColor(0x1000000);
    waferFailFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferEmptyFmt = wb.addFormat();
    waferEmptyFmt.setFontName("Arial");
    waferEmptyFmt.setFontSize(7.0);
    config.setBGColor(waferEmptyFmt, Config.wafer_empty_bg_color);
    config.setFontColor(waferEmptyFmt, Config.ss_pass_text_color);
    waferEmptyFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferEmptyFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferEmptyFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferEmptyFmt.setBorderColor(0x1000000);
    waferEmptyFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    waferRowNumberFmt = wb.addFormat();
    waferRowNumberFmt.setFontName("Arial");
    waferRowNumberFmt.setFontSize(9.0);
    config.setBGColor(waferRowNumberFmt, Config.ss_testid_header_bg_color);
    config.setFontColor(waferRowNumberFmt, Config.ss_pass_text_color);
    waferRowNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferRowNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferRowNumberFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    waferRowNumberFmt.setBorderColor(0x1000000);

    waferColNumberFmt = wb.addFormat();
    waferColNumberFmt.setFontName("Arial");
    waferColNumberFmt.setFontSize(9.0);
    config.setBGColor(waferColNumberFmt, Config.ss_testid_header_bg_color);
    config.setFontColor(waferColNumberFmt, Config.ss_pass_text_color);
    waferColNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    waferColNumberFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    waferColNumberFmt.setRotation(90);
    waferColNumberFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    waferColNumberFmt.setBorderColor(0x1000000);
}