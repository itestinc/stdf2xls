module makechip.SpreadsheetWriter;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import makechip.StdfFile;
import makechip.StdfDB;
import makechip.Config;
import makechip.CmdOptions;
import std.stdio;

static Format logoFmt; 
static Format titleFmt;
static Format hdrNameFmt;
static Format hdrValueFmt;
static Format testNameHdrFmt;
static Format testNameValueFmt;
static Format testNumberHdrFmt;
static Format testNumberValueFmt;
static Format dupHdrFmt;
static Format dupValueFmt;
static Format loLimitHdrFmt;
static Format loLimitValueFmt;
static Format hiLimitHdrFmt;
static Format hiLimitValueFmt;
static Format dynLoLimitHdrFmt;
static Format dynLoLimitValueFmt;
static Format dynHiLimitHdrFmt;
static Format dynHiLimitValueFmt;
static Format pinHdrFmt;
static Format pinValueFmt;
static Format unitsHdrFmt;
static Format unitsValueFmt;
static Format snxyHdrFmt;
static Format snxyValueFmt;
static Format tempHdrFmt;
static Format tempValueFmt;
static Format timeHdrFmt;
static Format timeValueFmt;
static Format hwbinHdrFmt;
static Format hwbinValueFmt;
static Format swbinHdrFmt;
static Format swbinValueFmt;
static Format siteHdrFmt;
static Format siteValueFmt;
static Format rsltHdrFmt;
static Format rsltPassValueFmt;
static Format rsltFailValueFmt;
static Format passDataFloatFmt;
static Format passDataIntFmt;
static Format passDataHexFmt;
static Format passDataStringFmt;
static Format failDataFmt;

immutable size_t defaultRowHeight = 20;
immutable size_t defaultColWidth = 70;

private Format setFormat(Workbook wb, string fmtName, Config config)
{
    size_t i;
    for (i=fmtName.length-1; i>0; i--) { if (fmtName[i] == '.') break; }
    string name = fmtName[0..i];
    Format f = wb.addFormat();
    config.setBGColor(f, name ~ ".bg_color");
    config.setFontColor(f, name ~ ".text_color");
    string font = config.getValue(name ~ ".font_name");
    f.setFontName(font == "" ? "Arial" : font);
    string fsize = config.getValue(name ~ ".font_size");
    double size = (fsize == "") ? 8.0 : to!double(fsize);
    f.setFontSize(size);
    string style = config.getValue(name ~ ".font_style");
    if (style == "") style = "normal";
    switch (style)
    {
    case "bold":                    
        f.setBold(); 
        break;
    case "italic":                  
        f.setItalic(); 
        break;
    case "underline":               
        f.setUnderline(lxw_format_underlines.LXW_UNDERLINE_SINGLE); 
        break;
    case "bold_italic":             
        f.setBold(); 
        f.setItalic(); 
        break;
    case "bold_underline":          
        f.setBold(); 
        f.setUnderline(lxw_format_underlines.LXW_UNDERLINE_SINGLE); 
        break;
    case "italic_underline":        
        f.setItalic(); 
        f.setUnderline(lxw_format_underlines.LXW_UNDERLINE_SINGLE); 
        break;
    case "bold_italic_underline":   
        f.setBold(); 
        f.setItalic(); 
        f.setUnderline(lxw_format_underlines.LXW_UNDERLINE_SINGLE); 
        break;
    case "normal":
        break;
    default: throw new Exception("ERROR: unknown font style: " ~ style);
    }
    return f;
}

void initFormats(Workbook wb, CmdOptions options, Config config)
{
    if (options.verbosityLevel > 9) writeln("initFormats()");
    import libxlsxd.xlsxwrap;
    logoFmt            = setFormat(wb, Config.ss_logo_bg_color, config); 

    hdrNameFmt         = setFormat(wb, Config.ss_header_name_bg_color, config);
    hdrNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    hdrNameFmt.setBorderColor(0x1000000);

    titleFmt = setFormat(wb, Config.ss_header_value_bg_color, config);

    hdrValueFmt        = setFormat(wb, Config.ss_header_value_bg_color, config);
    hdrValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    hdrValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hdrValueFmt.setBorderColor(0x1000000);

    testNameHdrFmt     = setFormat(wb, Config.ss_test_name_header_bg_color, config);
    if (!options.rotate) testNameHdrFmt.setTextWrap();
    testNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNameHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testNameHdrFmt.setBorderColor(0x1000000);
    testNameHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) testNameHdrFmt.setRotation(90);

    testNameValueFmt   = setFormat(wb, Config.ss_test_name_value_bg_color, config);
    if (!options.rotate) testNameValueFmt.setTextWrap();
    testNameValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNameValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testNameValueFmt.setBorderColor(0x1000000);
    testNameValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) testNameValueFmt.setRotation(90);

    testNumberHdrFmt   = setFormat(wb, Config.ss_test_number_header_bg_color, config);
    testNumberHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNumberHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) testNumberHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    testNumberHdrFmt.setBorderColor(0x1000000);
    testNumberHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    testNumberValueFmt = setFormat(wb, Config.ss_test_number_value_bg_color, config);
    testNumberValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNumberValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) testNumberValueFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    testNumberValueFmt.setBorderColor(0x1000000);
    testNumberValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    dupHdrFmt          = setFormat(wb, Config.ss_duplicate_header_bg_color, config);
    dupHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dupHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) dupHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    dupHdrFmt.setBorderColor(0x1000000);
    dupHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    dupValueFmt        = setFormat(wb, Config.ss_duplicate_value_bg_color, config);
    dupValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dupValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) dupValueFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    dupValueFmt.setBorderColor(0x1000000);
    dupValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    loLimitHdrFmt      = setFormat(wb, Config.ss_lo_limit_header_bg_color, config);
    loLimitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    loLimitHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    loLimitHdrFmt.setBorderColor(0x1000000);
    loLimitHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    loLimitHdrFmt.setNumFormat("0.000");

    loLimitValueFmt    = setFormat(wb, Config.ss_lo_limit_value_bg_color, config);
    loLimitValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    loLimitValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    loLimitValueFmt.setBorderColor(0x1000000);
    loLimitValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    loLimitValueFmt.setNumFormat("0.000");

    hiLimitHdrFmt      = setFormat(wb, Config.ss_hi_limit_header_bg_color, config);
    hiLimitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hiLimitHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitHdrFmt.setBorderColor(0x1000000);
    hiLimitHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitHdrFmt.setNumFormat("0.000");

    hiLimitValueFmt    = setFormat(wb, Config.ss_hi_limit_value_bg_color, config);
    hiLimitValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hiLimitValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitValueFmt.setBorderColor(0x1000000);
    hiLimitValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitValueFmt.setNumFormat("0.000");

    pinHdrFmt          = setFormat(wb, Config.ss_pin_header_bg_color, config);
    pinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    pinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) pinHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    pinHdrFmt.setBorderColor(0x1000000);
    pinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) pinHdrFmt.setRotation(90);

    pinValueFmt        = setFormat(wb, Config.ss_pin_value_bg_color, config);
    pinValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    pinValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) pinValueFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    pinValueFmt.setBorderColor(0x1000000);
    pinValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) pinValueFmt.setRotation(90);

    unitsHdrFmt        = setFormat(wb, Config.ss_units_header_bg_color, config);
    if (options.rotate) unitsHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else unitsHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    unitsHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    unitsHdrFmt.setBorderColor(0x1000000);
    unitsHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    unitsValueFmt      = setFormat(wb, Config.ss_units_value_bg_color, config);
    unitsValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    unitsValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) unitsValueFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    unitsValueFmt.setBorderColor(0x1000000);
    unitsValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    snxyHdrFmt         = setFormat(wb, Config.ss_sn_xy_header_bg_color, config);
    snxyHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    snxyHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    snxyHdrFmt.setBorderColor(0x1000000);
    snxyHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    snxyValueFmt       = setFormat(wb, Config.ss_sn_xy_value_bg_color, config);
    snxyValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    snxyValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    snxyValueFmt.setBorderColor(0x1000000);
    snxyValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    tempHdrFmt         = setFormat(wb, Config.ss_temp_header_bg_color, config);
    tempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    tempHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    tempHdrFmt.setBorderColor(0x1000000);
    tempHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    tempValueFmt       = setFormat(wb, Config.ss_temp_value_bg_color, config);
    tempValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    tempValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    tempValueFmt.setBorderColor(0x1000000);
    tempValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    timeHdrFmt         = setFormat(wb, Config.ss_time_header_bg_color, config);
    timeHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    timeHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    timeHdrFmt.setBorderColor(0x1000000);
    timeHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    timeValueFmt       = setFormat(wb, Config.ss_time_value_bg_color, config);

    hwbinHdrFmt        = setFormat(wb, Config.ss_hw_bin_header_bg_color, config);
    hwbinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hwbinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hwbinHdrFmt.setBorderColor(0x1000000);
    hwbinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    hwbinValueFmt      = setFormat(wb, Config.ss_hw_bin_value_bg_color, config);

    swbinHdrFmt        = setFormat(wb, Config.ss_sw_bin_header_bg_color, config);
    swbinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    swbinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    swbinHdrFmt.setBorderColor(0x1000000);
    swbinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    swbinValueFmt      = setFormat(wb, Config.ss_sw_bin_value_bg_color, config);

    siteHdrFmt         = setFormat(wb, Config.ss_site_header_bg_color, config);
    siteHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    siteHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    siteHdrFmt.setBorderColor(0x1000000);
    siteHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    siteValueFmt       = setFormat(wb, Config.ss_site_value_bg_color, config);

    rsltHdrFmt         = setFormat(wb, Config.ss_result_header_bg_color, config);
    if (!options.rotate) rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    else 
    {
        rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
        rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_TOP);
    }
    rsltHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rsltHdrFmt.setBorderColor(0x1000000);
    rsltHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rsltPassValueFmt   = setFormat(wb, Config.ss_result_pass_value_bg_color, config);

    rsltFailValueFmt   = setFormat(wb, Config.ss_result_fail_value_bg_color, config);
    if (!options.rotate) rsltFailValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    else 
    {
        rsltFailValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
        rsltFailValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_TOP);
    }
    rsltFailValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rsltFailValueFmt.setBorderColor(0x1000000);
    rsltFailValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    passDataFloatFmt   = setFormat(wb, Config.ss_pass_data_float_value_bg_color, config);
    passDataFloatFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    passDataFloatFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    passDataFloatFmt.setBorderColor(0x1000000);
    passDataFloatFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    passDataFloatFmt.setNumFormat("0.000");

    passDataIntFmt     = setFormat(wb, Config.ss_pass_data_int_value_bg_color, config);
    passDataIntFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    passDataIntFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    passDataIntFmt.setBorderColor(0x1000000);
    passDataIntFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    passDataIntFmt.setNumFormat("General");

    passDataHexFmt     = setFormat(wb, Config.ss_pass_data_hex_value_bg_color, config);
    passDataHexFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    passDataHexFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    passDataHexFmt.setBorderColor(0x1000000);
    passDataHexFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    passDataStringFmt  = setFormat(wb, Config.ss_pass_data_string_value_bg_color, config);
    passDataStringFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    passDataStringFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    passDataStringFmt.setBorderColor(0x1000000);
    passDataStringFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    failDataFmt        = setFormat(wb, Config.ss_fail_data_value_bg_color, config);
    failDataFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    failDataFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    failDataFmt.setBorderColor(0x1000000);
    failDataFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    failDataFmt.setNumFormat("0.000");

    dynLoLimitHdrFmt = setFormat(wb, Config.ss_dyn_lo_limit_header_bg_color, config);
    dynLoLimitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dynLoLimitHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    dynLoLimitHdrFmt.setBorderColor(0x1000000);
    dynLoLimitHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    dynLoLimitValueFmt = setFormat(wb, Config.ss_dyn_lo_limit_value_bg_color, config);
    dynLoLimitValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dynLoLimitValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    dynLoLimitValueFmt.setBorderColor(0x1000000);
    dynLoLimitValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    dynHiLimitHdrFmt = setFormat(wb, Config.ss_dyn_hi_limit_header_bg_color, config);
    dynHiLimitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dynHiLimitHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    dynHiLimitHdrFmt.setBorderColor(0x1000000);
    dynHiLimitHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    dynHiLimitValueFmt = setFormat(wb, Config.ss_dyn_hi_limit_value_bg_color, config);
    dynHiLimitValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dynHiLimitValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    dynHiLimitValueFmt.setBorderColor(0x1000000);
    dynHiLimitValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

}

public void writeSheet(CmdOptions options, Workbook wb, LinkedMap!(const TestID, uint) rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    if (options.verbosityLevel > 9) 
    {
        writeln("writeSheet()");
        writeln("rowOrColMap.length = ", rowOrColMap.length);
    }
    if (options.rotate) createSheetsRotated(options, config, wb, rowOrColMap, hdr, devices);
    else createSheets(options, config, wb, rowOrColMap, hdr, devices);
}

import makechip.Util;
import std.typecons;
private Worksheet[] createSheetsRotated(CmdOptions options, Config config, Workbook wb, LinkedMap!(const TestID, uint) rowOrColMap, HeaderInfo hdr, DeviceResult[] devices)
{
    if (options.verbosityLevel > 9) writeln("createSheetsRotated()");
    const size_t numDevices = devices.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
    const size_t numSheets = (numDevices % maxCols == 0) ? numDevices / maxCols : 1 + (numDevices / maxCols);
    Worksheet[] ws;
    for (size_t i=0; i<numSheets; i++)
    {
        string title = getTitle(options, hdr, i);
        if (title.length > 31) title = title[0..31];
        Worksheet w = wb.addWorksheet(title);
        ws ~= w;
        setLogo(options, config, w);
        setTitle(w, hdr, Yes.rotated);
        setDeviceHeader(options, config, w, hdr, Yes.rotated);
        setTableHeaders(options, config, w, Yes.wafersort, Yes.rotated);
        setTestNameHeaders(options, config, w, Yes.rotated, rowOrColMap);
        setData(options, config, w, i, Yes.wafersort, rowOrColMap, devices, hdr.temperature);
    }
    return ws;
}

private Worksheet[] createSheets(CmdOptions options, Config config, Workbook wb, LinkedMap!(const TestID, uint) rowOrColMap, HeaderInfo hdr, DeviceResult[] devices)
{
    if (options.verbosityLevel > 9) writeln("createSheets()");
    const size_t numTests  = rowOrColMap.length;
    const size_t maxCols   = options.limit1k ? 1000 : 16360;
    const size_t numSheets = (numTests % maxCols == 0) ? numTests / maxCols : 1 + (numTests / maxCols);
    if (options.verbosityLevel > 9) writeln("numSheets = ", numSheets, " numTests = ", numTests, " maxCols = ", maxCols);
    Worksheet[] ws;
    for (size_t i=0; i<numSheets; i++)
    {
        string title = getTitle(options, hdr, i);
        if (title.length > 31) title = title[0..31];
        Worksheet w = wb.addWorksheet(title);
        ws ~= w;
        setLogo(options, config, w);
        setTitle(w, hdr, No.rotated);
        setDeviceHeader(options, config, w, hdr, No.rotated);
        setTableHeaders(options, config, w, No.wafersort, No.rotated);
        setTestNameHeaders(options, config, w, No.rotated, rowOrColMap);
        setData(options, config, w, i, maxCols, No.wafersort, rowOrColMap, devices, hdr.temperature);
    }
    return ws;
}

private string getTitle(CmdOptions options, HeaderInfo hdr, size_t page)
{
    if (hdr.isWafersort())
    {
        return "Page " ~ to!string(page) ~ " Wafer " ~ hdr.wafer_id;
    }
    if ((hdr.step is null) || hdr.step == "")
    {
        return "Page " ~ to!string(page) ~ " Temp " ~ hdr.temperature;
    }
    return "Page " ~ to!string(page) ~ " Step " ~ hdr.step;
}

import std.conv;

private void setTitle(Worksheet w, HeaderInfo hdr, bool rotated)
{
    if (rotated)
    {
        w.mergeRange(0, 3, 2, 4, hdr.devName, titleFmt);
        if (hdr.isWafersort())
        {
            w.mergeRange(3, 3, 4, 4, "Lot: " ~ hdr.lot_id, titleFmt);
            w.mergeRange(5, 3, 6, 4, "Wafer: " ~ hdr.wafer_id, titleFmt);
        }
        else
        {
            w.mergeRange(3, 3, 4, 4, "Step: " ~ hdr.step, titleFmt);
            w.mergeRange(5, 3, 6, 4, "Temp: " ~ hdr.temperature, titleFmt);
        }
    }
    else
    {
        w.mergeRange(0, 3, 2, 6, hdr.devName, titleFmt);
        if (hdr.isWafersort())
        {
            w.mergeRange(3, 3, 4, 6, "Lot: " ~ hdr.lot_id, titleFmt);
            w.mergeRange(5, 3, 6, 6, "Wafer: " ~ hdr.wafer_id, titleFmt);
        }
        else
        {
            w.mergeRange(3, 3, 4, 6, "Step: " ~ hdr.step, titleFmt);
            w.mergeRange(5, 3, 6, 6, "Temp: " ~ hdr.temperature, titleFmt);
        }
    }
}

// Note scaling relies on the image having a resolution of 11.811 pixels / mm
private void setLogo(CmdOptions options, Config config, Worksheet w)
{
    if (options.verbosityLevel > 9) writeln("setLogo()");
    import arsd.image;
    import arsd.color;
    string logoPath = config.getLogoPath();
    lxw_image_options opts;
    opts.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
    w.mergeRange(0, 0, 6, 2, null);
    if (logoPath == "") // use ITest logo
    {
        import makechip.logo;
        double ss_width = 449 * 0.350;
        double ss_height = 245 * 0.324;
        opts.x_scale = (3.0 * 70.0) / ss_width;
        opts.y_scale = (7.0 * 20.0) / ss_height;
        opts.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
        w.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, makechip.logo.img.dup.ptr, makechip.logo.img.length, &opts);
    }
    else
    {
        MemoryImage image = MemoryImage.fromImage(logoPath);
        double xscl = config.getLogoXScale();
        double yscl = config.getLogoYScale();
        if (xscl == 0.0 || yscl == 0.0)
        {
            double ss_width = image.width() * 0.350;
            double ss_height = image.height() * 0.324;
            opts.x_scale = (3.0 * defaultColWidth) / ss_width;
            opts.y_scale = (7.0 * defaultRowHeight) / ss_height;
            w.insertImageOpt(cast(uint) 0, cast(ushort) 0, logoPath, &opts);
        }
        else
        {
            opts.x_scale = xscl;
            opts.y_scale = yscl;
            w.insertImageOpt(cast(uint) 0, cast(ushort) 0, logoPath, &opts);
        }
    }
    if (options.rotate)
    {
        w.setColumn(cast(ushort) 0, cast(ushort) 11, 10.0);
    }
    else
    {
        w.setColumn(cast(ushort) 0, cast(ushort) 2, 10.0);
    }
}

private void setDeviceHeader(CmdOptions options, Config config, Worksheet w, HeaderInfo hdr, Flag!"rotated" rotated)
{
    if (options.verbosityLevel > 9) writeln("setDeviceHeader()");
    if (rotated)
    {
        for (uint r=0; r<7; r++)
        {
            for (ushort c=5; c<14; c+=4)
            {
                w.mergeRange(r, c, r, cast(ushort) (c+1), "", hdrNameFmt);
                w.mergeRange(r, cast(ushort) (c+2), r, cast(ushort) (c+3), "", hdrValueFmt);
            }
        }
        int r = 0;
        if (hdr.step != "")
        {
            w.mergeRange(r, 5, r, 6, "STEP #:", hdrNameFmt);
            w.mergeRange(r, 7, r, 8, hdr.step, hdrValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            w.mergeRange(r, 5, r, 6, "Temperature:", hdrNameFmt);
            w.mergeRange(r, 7, r, 8, hdr.temperature, hdrValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            w.mergeRange(r, 5, r, 6, "Lot #:", hdrNameFmt);
            w.mergeRange(r, 7, r, 8, hdr.lot_id, hdrValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            w.mergeRange(r, 5, r, 6, "SubLot #:", hdrNameFmt);
            w.mergeRange(r, 7, r, 8, hdr.sublot_id, hdrValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            w.mergeRange(r, 5, r, 6, "Wafer #:", hdrNameFmt);
            w.mergeRange(r, 7, r, 8, hdr.wafer_id, hdrValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            w.mergeRange(r, 5, r, 6, "Device:", hdrNameFmt);
            w.mergeRange(r, 7, r, 8, hdr.devName, hdrValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        ushort c = 5;
        foreach (key; map)
        {
            w.mergeRange(r, c, r, cast(ushort) (c+1), key, hdrNameFmt);
            w.mergeRange(r, cast(ushort) (c+2), r, cast(ushort) (c+3), map[key], hdrValueFmt);
            r++;
            if (r == 7)
            {
                r = 0;
                c += 4;
            }
            if (r == 7 && c == 8) break;
        }
    }
    else
    {
        for (uint r=7; r<24; r++)
        {
            w.mergeRange(r, 0, r, cast(ushort) 2, "", hdrNameFmt);
            w.mergeRange(r, cast(ushort) 3, r, cast(ushort) 6, "", hdrValueFmt);
        }
        int r = 7;
        if (hdr.step != "")
        {
            w.mergeRange(r, 0, r, 2, "STEP #:", hdrNameFmt);
            w.mergeRange(r, 3, r, 6, hdr.step, hdrValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            w.mergeRange(r, 0, r, 2, "Temperature:", hdrNameFmt);
            w.mergeRange(r, 3, r, 6, hdr.temperature, hdrValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            w.mergeRange(r, 0, r, 2, "Lot #:", hdrNameFmt);
            w.mergeRange(r, 3, r, 6, hdr.lot_id, hdrValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            w.mergeRange(r, 0, r, 2, "SubLot #:", hdrNameFmt);
            w.mergeRange(r, 3, r, 6, hdr.sublot_id, hdrValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            w.mergeRange(r, 0, r, 2, "Wafer #:", hdrNameFmt);
            w.mergeRange(r, 3, r, 6, hdr.wafer_id, hdrValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            w.mergeRange(r, 0, r, 2, "Device:", hdrNameFmt);
            w.mergeRange(r, 3, r, 6, hdr.devName, hdrValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        foreach (key; map)
        {
            w.mergeRange(r, 0, r, 2, key, hdrNameFmt);
            w.mergeRange(r, 3, r, 6, map[key], hdrValueFmt);
            r++;
            if (r > 23) break;
        }
    }
}

//static Format testidHdrFmt;             // ss.testid.header.bg_color ss.testid.header.text_color
//static Format deviceidHdrFmt;           // ss.deviceid.header.bg_color ss.deviceid.header.text_color
//static Format unitstempHdrFmt;          // ss.unitstemp.header.bg_color ss.unitstemp.header.text_color
//static Format unitsHdrFmt;              // ss.units.header.bg_color ss.units.header.text_color
//static Format tempHdrFmt;               // ss.temp.header.bg_color ss.temp.header.text_color
private void setTableHeaders(CmdOptions options, Config config, Worksheet w, Flag!"wafersort" wafersort, Flag!"rotated" rotated)
{
    if (options.verbosityLevel > 9) writeln("setTableHeaders()");
    if (rotated)
    {
        // test id header
        w.mergeRange(7, 0, 7, 5, "Test Name", testNameHdrFmt);
        w.writeString(7, 6, "Test Num", testNumberHdrFmt);
        w.writeString(7, 7, "Duplicate", dupHdrFmt);
        w.writeString(7, 8, "Lo Limit", loLimitHdrFmt);
        w.writeString(7, 9, "Hi Limit", hiLimitHdrFmt);
        w.writeString(7, 10, "Units", unitsHdrFmt);
        w.mergeRange(7, 11, 7, 13, "Pin", pinHdrFmt);
        // device id header
        if (wafersort) w.writeString(0, 13, "X, Y", snxyHdrFmt); else w.writeString(0, 13, "S/N", snxyHdrFmt);
        w.writeString(1, 13, "Temp", tempHdrFmt);
        w.writeString(2, 13, "HW Bin", hwbinHdrFmt);
        w.writeString(3, 13, "SW Bin", swbinHdrFmt);
        w.writeString(4, 13, "Site", siteHdrFmt);
        w.writeString(5, 13, "Time", timeHdrFmt);
        w.writeString(6, 13, "Result", rsltHdrFmt);
    }
    else
    {
        // test id header
        w.mergeRange(0, 7, 11, 7, "Test Name", testNameHdrFmt);
        w.writeString(12, 7, "Test Num", testNumberHdrFmt);
        w.writeString(13, 7, "Duplicate", dupHdrFmt);
        w.writeString(14, 7, "Lo Limit", loLimitHdrFmt);
        w.writeString(15, 7, "Hi Limit", hiLimitHdrFmt);
        w.writeString(16, 7, "Units", unitsHdrFmt);
        w.mergeRange(17, 7, 23, 7, "Pin", pinHdrFmt);
        if (wafersort) w.writeString(24, 0, "X, Y", snxyHdrFmt); else w.writeString(24, 0, "S/N", snxyHdrFmt);
        w.writeString(24, 1, "Temp", tempHdrFmt);
        w.writeString(24, 2, "Time", timeHdrFmt);
        w.writeString(24, 3, "HW Bin", hwbinHdrFmt);
        w.writeString(24, 4, "SW Bin", swbinHdrFmt);
        w.writeString(24, 5, "Site", siteHdrFmt);
        w.mergeRange(24, 6, 24, 7, "Result", rsltHdrFmt);
    }
}

private void setTestNameHeaders(CmdOptions options, Config config, Worksheet w, Flag!"rotated" rotated, LinkedMap!(const TestID, uint) tests)
{
    if (options.verbosityLevel > 9) writeln("setTestNameHeaders()");
    const TestID[] ids = tests.keys();
    if (rotated)
    {
        for (uint i=0; i<tests.length(); i++)
        {
            auto id = ids[i];       
            int row = i + 8;
            w.mergeRange(row, 0, row, 5, id.testName, testNameValueFmt);
            w.writeNumber(row, 6, id.testNumber, testNumberValueFmt);
            w.writeNumber(row, 7, id.dup, dupValueFmt);
            // Limits must be added when the test data is added
            w.mergeRange(row, 11, row, 13, id.pin, pinValueFmt);
        }
    }
    else
    {
        for (uint i=0; i<tests.length(); i++)
        {
            auto id = ids[i];       
            ushort col = cast(ushort) (i + 8);
            w.mergeRange(0, col, 11, col, id.testName, testNameValueFmt);
            w.writeNumber(12, col, id.testNumber, testNumberValueFmt);
            w.writeNumber(13, col, id.dup, dupValueFmt);
            // Limits must be added when the test data is added
            w.mergeRange(18, col, 24, col, id.pin, pinValueFmt);
        }
    }
}

private void setDeviceNameHeader(CmdOptions options, Config config, Worksheet w, Flag!"wafersort" wafersort, Flag!"rotated" rotated, uint rowOrCol, ulong tmin, string temp, DeviceResult device)
{
    if (options.verbosityLevel > 9) writeln("setDeviceNameHeaders()");
    if (rotated)
    {
        w.writeString(0, cast(ushort) rowOrCol, device.devId.getID(), snxyValueFmt);
        w.writeString(1, cast(ushort) rowOrCol, temp, tempValueFmt);
        w.writeNumber(2, cast(ushort) rowOrCol, device.tstamp - tmin, timeValueFmt);
        w.writeNumber(3, cast(ushort) rowOrCol, device.hwbin, hwbinValueFmt);
        w.writeNumber(4, cast(ushort) rowOrCol, device.swbin, swbinValueFmt);
        w.writeNumber(5, cast(ushort) rowOrCol, device.site, siteValueFmt);
        if (device.goodDevice) w.writeString(6, cast(ushort) rowOrCol, "PASS", rsltPassValueFmt);
        else w.writeString(6, cast(ushort) rowOrCol, "FAIL", rsltFailValueFmt);
    }
    else
    {
        w.writeString(rowOrCol, 0, device.devId.getID(), snxyValueFmt);
        w.writeString(rowOrCol, 1, temp, tempValueFmt);
        w.writeNumber(rowOrCol, 2, device.tstamp - tmin, timeValueFmt);
        w.writeNumber(rowOrCol, 3, device.hwbin, hwbinValueFmt);
        w.writeNumber(rowOrCol, 4, device.swbin, swbinValueFmt);
        w.writeNumber(rowOrCol, 5, device.site, siteValueFmt);
        if (device.goodDevice) w.mergeRange(rowOrCol, 6, rowOrCol, 7, "PASS", rsltPassValueFmt);
        else w.mergeRange(rowOrCol, 6, rowOrCol, 7, "FAIL", rsltFailValueFmt);
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private bool[ushort] cmap;
// This is for not-rotated spreadsheets
private void setData(CmdOptions options, Config config, Worksheet w, size_t sheetNum, const size_t maxCols, Flag!"wafersort" wafersort, LinkedMap!(const TestID, uint) rowOrColMap, DeviceResult[] devices, string temp)
{
    if (options.verbosityLevel > 9) writeln("setData(1)");
    // Find the smallest timestamp:
    ulong tmin = ulong.max;
    foreach (ref device; devices)
    {
        if (device.tstamp < tmin) tmin = device.tstamp;
    }
    // do not exceed maxCols
    uint row = 25;
    cmap.clear();
    foreach(ref device; devices)
    {
        setDeviceNameHeader(options, config, w, wafersort, No.rotated, row, tmin, temp, device);
        for (int i=0; i<device.tests.length; i++)
        {
            TestRecord tr = device.tests[i];
            uint seqNum = rowOrColMap[tr.id];
            ushort col = cast(ushort) (seqNum + 8);
            if (col !in cmap)
            {
                if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT ||
                    tr.type == TestType.DYNAMIC_LOLIMIT || tr.type == TestType.DYNAMIC_HILIMIT || tr.type == TestType.STRING)
                {
                    w.writeString(14, col, "", loLimitValueFmt);
                    w.writeString(15, col, "", hiLimitValueFmt);
                    w.writeString(16, col, tr.units, unitsValueFmt);
                }
                else
                {
                    w.writeNumber(14, col, tr.loLimit, loLimitValueFmt);
                    w.writeNumber(15, col, tr.hiLimit, hiLimitValueFmt);
                    w.writeString(16, col, tr.units, unitsValueFmt);
                }
                cmap[col] = true;
            }
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, "FAIL", failDataFmt);
                else w.writeString(row, col, "PASS", passDataStringFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.f, failDataFmt);
                else w.writeNumber(row, col, tr.result.f, passDataFloatFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                else w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.l, failDataFmt);
                else w.writeNumber(row, col, tr.result.l, passDataIntFmt);
                break;
            case DYNAMIC_LOLIMIT:
                w.writeNumber(row, col, tr.result.f, dynLoLimitValueFmt);
                break;
            case DYNAMIC_HILIMIT:
                w.writeNumber(row, col, tr.result.f, dynHiLimitValueFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, tr.result.s, failDataFmt);
                else w.writeString(row, col, tr.result.s, passDataStringFmt);
                break;
            }
        }
        row++;
    }
}

private bool[uint] lmap;

// This is for rotated spreadsheets
private void setData(CmdOptions options, Config config, Worksheet w, size_t sheetNum, Flag!"wafersort" wafersort, LinkedMap!(const TestID, uint) rowOrColMap, DeviceResult[] devices, string temp)
{
    if (options.verbosityLevel > 9) writeln("setData(2)");
    // Find the smallest timestamp:
    ulong tmin = ulong.max;
    foreach (ref device; devices)
    {
        if (device.tstamp < tmin) tmin = device.tstamp;
    }
    ushort col = 14;
    lmap.clear();
    foreach(ref device; devices)
    {
        setDeviceNameHeader(options, config, w, wafersort, Yes.rotated, col, tmin, temp, device);
        for (int i=0; i<device.tests.length; i++)
        {
            TestRecord tr = device.tests[i];
            writeln("tr.id = ", tr.id); std.stdio.stdout.flush();
            uint seqNum = rowOrColMap[tr.id];
            uint row = seqNum + 8;
            if (row !in lmap)
            {
                if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT ||
                    tr.type == TestType.DYNAMIC_LOLIMIT || tr.type == TestType.DYNAMIC_HILIMIT || tr.type == TestType.STRING)
                {
                    w.writeString(row, 8, "", loLimitValueFmt);
                    w.writeString(row, 9, "", hiLimitValueFmt);
                    w.writeString(row, 10, tr.units, unitsValueFmt);
                }
                else
                {
                    w.writeNumber(row, 8, tr.loLimit, loLimitValueFmt);
                    w.writeNumber(row, 9, tr.hiLimit, loLimitValueFmt);
                    w.writeString(row, 10, tr.units, unitsValueFmt);
                }
                lmap[row] = true;
            }
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, "FAIL", failDataFmt);
                else w.writeString(row, col, "PASS", passDataStringFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.f, failDataFmt);
                else w.writeNumber(row, col, tr.result.f, passDataFloatFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                else w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.l, failDataFmt);
                else w.writeNumber(row, col, tr.result.l, passDataIntFmt);
                break;
            case DYNAMIC_LOLIMIT:
                w.writeNumber(row, col, tr.result.f, dynLoLimitValueFmt);
                break;
            case DYNAMIC_HILIMIT:
                w.writeNumber(row, col, tr.result.f, dynHiLimitValueFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, tr.result.s, failDataFmt);
                else w.writeString(row, col, tr.result.s, passDataStringFmt);
                break;
            }
        }
        col++;
    }
    w.freezePanes(14, 13);
}




