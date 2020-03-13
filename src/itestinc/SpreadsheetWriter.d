module itestinc.SpreadsheetWriter;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import itestinc.StdfFile;
import itestinc.StdfDB;
import itestinc.Config;
import itestinc.CmdOptions;
import std.stdio;
import itestinc.StdfDB:Point;
import itestinc.fonts;

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
double lcol;
double lrow;
static uint x_dpi;
static uint y_dpi;

static size_t[string] sindex;

static this()
{
    sindex["normal"] = 0;
    sindex["bold"] = 1;
    sindex["italic"] = 2;
    sindex["bold_italic"] = 3;
    sindex["underline"] = 0;
    sindex["bold_underline"] = 1;
    sindex["italic_underline"] = 2;
    sindex["bold_italic_underline"] = 3;
}

private double getColumnWidth(string s, uint dpi, string fontName, string fontStyle, size_t fontSize, bool textIsRotated)
{
    if (textIsRotated) return 5.0;
    double[][][] cw = fmapw[fontName];

    size_t style = sindex[fontStyle];
    double w = 0.0;
    for (size_t i=0; i<s.length; i++) w += cast(double) (cast(int) (cw[fontSize][style][s[i]] + 0.5));
    return (w / 6.00) * (96.0 / dpi);
}

private double getRowHeight(string s, uint dpi, string fontName, string fontStyle, size_t fontSize, bool textIsRotated)
{
    ubyte[][] ch = fmaph[fontName];
    size_t style = sindex[fontStyle];
    double h = ch[fontSize][style];
    if (textIsRotated)
    {
        double w = getColumnWidth(s, dpi, fontName, fontStyle, fontSize, false);
        h = 15.0 * w / 8.43;
    }
    if (h < 15.0) h = 14.0;
    return (h * 96.0) / dpi;
}

double[uint] maxRowHeights;
double[ushort] maxColWidths;

private string getStyle(Format fmt)
{
    string style = "";
    if (fmt.getBold() && fmt.getItalic() && fmt.getUnderline()) style = "bold_italic_underline";
    else if (fmt.getItalic() && fmt.getUnderline()) style = "italic_underline";
    else if (fmt.getBold() && fmt.getUnderline()) style = "bold_underline";
    else if (fmt.getBold() && fmt.getItalic()) style = "bold_italic";
    else if (fmt.getUnderline()) style = "underline";
    else if (fmt.getItalic()) style = "italic";
    else if (fmt.getBold()) style = "bold";
    else style = "normal";
    return style;
}

private void updateCellSize(string s, uint row, ushort col, Format fmt)
{
    string style = getStyle(fmt);
    double cw = getColumnWidth(s, x_dpi, fmt.getFontName(), style, cast(size_t) fmt.getFontSize(), fmt.getRotation() >= 45.0);
    if (col !in maxColWidths) maxColWidths[col] = cw;
    else
    {
        double cm = maxColWidths[col];
        if (cw > cm) maxColWidths[col] = cw;
    }
    double rh = getRowHeight(s, y_dpi, fmt.getFontName(), style, cast(size_t) fmt.getFontSize(), fmt.getRotation() >= 45.0);
    if (row !in maxRowHeights) maxRowHeights[row] = rh;
    else
    {
        double rm = maxRowHeights[row];
        if (rh > rm) maxRowHeights[row] = rh;
    }
}

private void mergeRange(Worksheet w, uint row0, ushort col0, uint row1, ushort col1, string value, Format fmt)
{
    string style = getStyle(fmt);
    double cw = getColumnWidth(value, x_dpi, fmt.getFontName(), style, cast(size_t) fmt.getFontSize(), fmt.getRotation() >= 45.0);
    double rh = getRowHeight(value, y_dpi, fmt.getFontName(), style, cast(size_t) fmt.getFontSize(), fmt.getRotation() >= 45.0);
    uint cols = 1 + (col1 - col0);
    uint rows = 1 + (row1 - row0);
    cw /= cols;
    rh /= rows;
    for (ushort col=col0; col<=col1; col++)
    {
        if (col !in maxColWidths) maxColWidths[col] = cw;
        else
        {
            double cm = maxColWidths[col];
            if (cw > cm) maxColWidths[col] = cw;
        }
    }
    for (uint row=row0; row<=row1; row++)
    {
        if (row !in maxRowHeights) maxRowHeights[row] = rh;
        else
        {
            double rm = maxRowHeights[row];
            if (rh > rm) maxRowHeights[row] = rh;
        }
    }
    w.mergeRange(row0, col0, row1, col1, value, fmt);
}

private void writeString(Worksheet w, uint row, ushort col, string value, Format fmt)
{
    updateCellSize(value, row, col, fmt);
    w.writeString(row, col, value, fmt);
}

private void writeNumber(Worksheet w, uint row, ushort col, double value, Format fmt)
{
    updateCellSize("-000.000", row, col, fmt);
    w.writeNumber(row, col, value, fmt);
}

private void writeFormula(Worksheet w, uint row, ushort col, string value, Format fmt)
{
    updateCellSize("AAAAAAAA", row, col, fmt);
    w.writeFormula(row, col, value, fmt);
}


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
    logoFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    logoFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);

    hdrNameFmt         = setFormat(wb, Config.ss_header_name_bg_color, config);
    hdrNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    hdrNameFmt.setBorderColor(0x1000000);
    hdrNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    hdrNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    hdrNameFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hdrNameFmt.setBorderColor(0x1000000);
    hdrNameFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    hdrValueFmt        = setFormat(wb, Config.ss_header_value_bg_color, config);
    hdrValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    hdrValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hdrValueFmt.setBorderColor(0x1000000);
    hdrValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hdrValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    hdrValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hdrValueFmt.setBorderColor(0x1000000);
    hdrValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    titleFmt = setFormat(wb, Config.ss_title_bg_color, config);
    titleFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    titleFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    titleFmt.setBorderColor(0x1000000);
    titleFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    titleFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);

    testNameHdrFmt     = setFormat(wb, Config.ss_test_name_header_bg_color, config);
    if (!options.rotate) testNameHdrFmt.setTextWrap();
    testNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    testNameHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testNameHdrFmt.setBorderColor(0x1000000);
    testNameHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) testNameHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) testNameHdrFmt.setRotation(90);

    testNameValueFmt   = setFormat(wb, Config.ss_test_name_value_bg_color, config);
    if (!options.rotate) testNameValueFmt.setTextWrap();
    if (options.rotate) testNameValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    else testNameValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
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
    if (options.rotate) testNumberHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);

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
    if (options.rotate) dupHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);

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
    if (options.rotate) loLimitHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
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
    if (options.rotate) hiLimitHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitHdrFmt.setNumFormat("0.000");

    hiLimitValueFmt    = setFormat(wb, Config.ss_hi_limit_value_bg_color, config);
    hiLimitValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hiLimitValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitValueFmt.setBorderColor(0x1000000);
    hiLimitValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    hiLimitValueFmt.setNumFormat("0.000");

    pinHdrFmt          = setFormat(wb, Config.ss_pin_header_bg_color, config);
    pinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    pinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    pinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    pinHdrFmt.setBorderColor(0x1000000);
    if (options.rotate) pinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) pinHdrFmt.setRotation(90);

    pinValueFmt        = setFormat(wb, Config.ss_pin_value_bg_color, config);
    pinValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    pinValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) pinValueFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);
    pinValueFmt.setBorderColor(0x1000000);
    pinValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) pinValueFmt.setRotation(90);

    unitsHdrFmt        = setFormat(wb, Config.ss_units_header_bg_color, config);
    unitsHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    unitsHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    unitsHdrFmt.setBorderColor(0x1000000);
    unitsHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (options.rotate) unitsHdrFmt.setTop(lxw_format_borders.LXW_BORDER_THIN);

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
    timeValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    timeValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    timeValueFmt.setBorderColor(0x1000000);
    timeValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    hwbinHdrFmt        = setFormat(wb, Config.ss_hw_bin_header_bg_color, config);
    hwbinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hwbinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hwbinHdrFmt.setBorderColor(0x1000000);
    hwbinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    hwbinValueFmt      = setFormat(wb, Config.ss_hw_bin_value_bg_color, config);
    hwbinValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    hwbinValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    hwbinValueFmt.setBorderColor(0x1000000);
    hwbinValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    swbinHdrFmt        = setFormat(wb, Config.ss_sw_bin_header_bg_color, config);
    swbinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    swbinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    swbinHdrFmt.setBorderColor(0x1000000);
    swbinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    swbinValueFmt      = setFormat(wb, Config.ss_sw_bin_value_bg_color, config);
    swbinValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    swbinValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    swbinValueFmt.setBorderColor(0x1000000);
    swbinValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    siteHdrFmt         = setFormat(wb, Config.ss_site_header_bg_color, config);
    siteHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    siteHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    siteHdrFmt.setBorderColor(0x1000000);
    siteHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    siteValueFmt       = setFormat(wb, Config.ss_site_value_bg_color, config);
    siteValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    siteValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    siteValueFmt.setBorderColor(0x1000000);
    siteValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rsltHdrFmt         = setFormat(wb, Config.ss_result_header_bg_color, config);
    if (!options.rotate) rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else 
    {
        rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
        rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    }
    rsltHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rsltHdrFmt.setBorderColor(0x1000000);
    if (!options.rotate) rsltHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rsltPassValueFmt   = setFormat(wb, Config.ss_result_pass_value_bg_color, config);
    if (!options.rotate) rsltPassValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else 
    {
        rsltPassValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
        rsltPassValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    }
    rsltPassValueFmt.setBorderColor(0x1000000);
    rsltPassValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    rsltPassValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);

    rsltFailValueFmt   = setFormat(wb, Config.ss_result_fail_value_bg_color, config);
    if (!options.rotate) rsltFailValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else 
    {
        rsltFailValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
        rsltFailValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
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
    dynLoLimitValueFmt.setNumFormat("0.000");

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
    dynHiLimitValueFmt.setNumFormat("0.000");

}

public void writeSheet(CmdOptions options, Workbook wb, LinkedMap!(const TestID, uint) rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    maxRowHeights[0] = 15;
    maxRowHeights[1] = 15;
    maxRowHeights[2] = 15;
    maxRowHeights[3] = 15;
    maxRowHeights[4] = 15;
    maxRowHeights[5] = 15;
    maxRowHeights[6] = 15;
    maxColWidths[0] = 8.43;
    maxColWidths[1] = 8.43;
    maxColWidths[2] = 8.43;
    x_dpi = config.getMonitorXDpi();
    y_dpi = config.getMonitorYDpi();
    if (options.verbosityLevel > 9) 
    {
        writeln("writeSheet()");
        writeln("rowOrColMap.length = ", rowOrColMap.length);
    }
    if (options.rotate) createSheetsRotated(options, config, wb, rowOrColMap, hdr, devices);
    else createSheets(options, config, wb, rowOrColMap, hdr, devices);
}

import itestinc.Util;
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
        size_t col = i * maxCols;
        string title = getTitle(options, hdr, i);
        if (title.length > 31) title = title[0..31];
        Worksheet w = wb.addWorksheet(title);
        ws ~= w;
        setTitle(ws[i], hdr, Yes.rotated);
        setDeviceHeader(options, config, ws[i], hdr, Yes.rotated);
        setTableHeaders(options, config, ws[i], hdr.isWafersort() ? Yes.wafersort : No.wafersort, Yes.rotated);
        setTestNameHeaders(options, config, ws[i], Yes.rotated, rowOrColMap, col, maxCols);
        setData(options, config, ws[i], i, hdr.isWafersort() ? Yes.wafersort : No.wafersort, rowOrColMap, devices, hdr.temperature, col, maxCols);
        lcol = 0;
        lrow = 0;
        foreach (row; maxRowHeights.keys)
        {
            if (row < 7) lrow += maxRowHeights[row];
            ws[i].setRow(row, maxRowHeights[row]);
        }
        foreach (c; maxColWidths.keys)
        {
            if (c < 3) lcol += maxColWidths[c];
            ws[i].setColumn(c, c, maxColWidths[c]);
        }
        setLogo(options, config, ws[i]);
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
    Worksheet dummy;
    Worksheet[] ws;
    for (size_t i=0; i<numSheets; i++)
    {
        string title = getTitle(options, hdr, i);
        if (title.length > 31) title = title[0..31];
        Worksheet w = wb.addWorksheet(title);
        ws ~= w;
    }
    for (size_t i=0; i<numSheets; i++)
    {
        size_t col = i * maxCols;
        setTitle(ws[i], hdr, No.rotated);
        setDeviceHeader(options, config, ws[i], hdr, No.rotated);
        setTableHeaders(options, config, ws[i], hdr.isWafersort() ? Yes.wafersort : No.wafersort, No.rotated);
        setTestNameHeaders(options, config, ws[i], No.rotated, rowOrColMap, col, maxCols);
        setData(options, config, ws[i], i, maxCols, hdr.isWafersort() ? Yes.wafersort : No.wafersort, rowOrColMap, devices, hdr.temperature, col, i<(numSheets-1) ? ws[i+1] : dummy);
        lcol = 0;
        lrow = 0;
        foreach (row; maxRowHeights.keys)
        {
            if (row < 7) lrow += maxRowHeights[row];
            ws[i].setRow(row, maxRowHeights[row]);
        }
        foreach (c; maxColWidths.keys)
        {
            if (c < 3) lcol += maxColWidths[c];
            ws[i].setColumn(c, c, maxColWidths[c]);
        }
        setLogo(options, config, ws[i]);
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
        mergeRange(w, 0, 3, 2, 6, hdr.devName, titleFmt);
        if (hdr.isWafersort())
        {
            mergeRange(w, 3, 3, 4, 6, "Lot: " ~ hdr.lot_id, titleFmt);
            mergeRange(w, 5, 3, 6, 6, "Wafer: " ~ hdr.wafer_id, titleFmt);
        }
        else
        {
            mergeRange(w, 3, 3, 4, 6, "Step: " ~ hdr.step, titleFmt);
            mergeRange(w, 5, 3, 6, 6, "Temp: " ~ hdr.temperature, titleFmt);
        }
    }
    else
    {
        mergeRange(w, 0, 3, 2, 6, hdr.devName, titleFmt);
        if (hdr.isWafersort())
        {
            mergeRange(w, 3, 3, 4, 6, "Lot: " ~ hdr.lot_id, titleFmt);
            mergeRange(w, 5, 3, 6, 6, "Wafer: " ~ hdr.wafer_id, titleFmt);
        }
        else
        {
            mergeRange(w, 3, 3, 4, 6, "Step: " ~ hdr.step, titleFmt);
            mergeRange(w, 5, 3, 6, 6, "Temp: " ~ hdr.temperature, titleFmt);
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
    double logo_area_x_pixels = lcol * 10.746;
    double logo_area_y_pixels = lrow * 1.292;
    opts.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
    string text = config.getLogoText();
    if (text != "")
    {
        w.mergeRange(0, 0, 6, 2, text, logoFmt);
        return;
    }
    w.mergeRange(0, 0, 6, 2, null);
    if (logoPath == "") // use ITest logo
    {
        import itestinc.logo;
        double ss_width = 449 * 0.360 * 25.29 / lcol;
        double ss_height = 245 * 0.324 * 105.0 / lrow;
        opts.x_scale = (3.0 * 70.0) / ss_width;
        opts.y_scale = (7.0 * 20.0) / ss_height;
        opts.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
        w.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, itestinc.logo.img.dup.ptr, itestinc.logo.img.length, &opts);
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
//    if (options.rotate)
//    {
//        w.setColumn(cast(ushort) 0, cast(ushort) 11, 10.0);
//    }
//    else
//    {
//        w.setColumn(cast(ushort) 0, cast(ushort) 2, 10.0);
//    }
}

private void setDeviceHeader(CmdOptions options, Config config, Worksheet w, HeaderInfo hdr, Flag!"rotated" rotated)
{
    if (options.verbosityLevel > 9) writeln("setDeviceHeader()");
    if (rotated)
    {
        for (uint r=0; r<7; r++)
        {
            for (ushort c=7; c<15; c+=4)
            {
                mergeRange(w, r, c, r, cast(ushort) (c+1), "", hdrNameFmt);
                mergeRange(w, r, cast(ushort) (c+2), r, cast(ushort) (c+3), "", hdrValueFmt);
            }
        }
        int r = 0;
        if (hdr.step != "")
        {
            mergeRange(w, r, 7, r, 8, "STEP #:", hdrNameFmt);
            mergeRange(w, r, 9, r, 10, hdr.step, hdrValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            mergeRange(w, r, 7, r, 8, "Temperature:", hdrNameFmt);
            mergeRange(w, r, 9, r, 10, hdr.temperature, hdrValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            mergeRange(w, r, 7, r, 8, "Lot #:", hdrNameFmt);
            mergeRange(w, r, 9, r, 10, hdr.lot_id, hdrValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            mergeRange(w, r, 7, r, 8, "SubLot #:", hdrNameFmt);
            mergeRange(w, r, 9, r, 10, hdr.sublot_id, hdrValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            mergeRange(w, r, 7, r, 8, "Wafer #:", hdrNameFmt);
            mergeRange(w, r, 9, r, 10, hdr.wafer_id, hdrValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            mergeRange(w, r, 7, r, 8, "Device:", hdrNameFmt);
            mergeRange(w, r, 9, r, 10, hdr.devName, hdrValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        ushort c = 7;
        foreach (key; map.keys)
        {
            mergeRange(w, r, c, r, cast(ushort) (c+1), key, hdrNameFmt);
            mergeRange(w, r, cast(ushort) (c+2), r, cast(ushort) (c+3), map[key], hdrValueFmt);
            r++;
            if (r == 7)
            {
                r = 0;
                c += 4;
            }
            if (r == 7 && c == 11) break;
        }
    }
    else
    {
        for (uint r=7; r<24; r++)
        {
            mergeRange(w, r, 0, r, cast(ushort) 2, "", hdrNameFmt);
            mergeRange(w, r, cast(ushort) 3, r, cast(ushort) 6, "", hdrValueFmt);
        }
        int r = 7;
        if (hdr.step != "")
        {
            mergeRange(w, r, 0, r, 2, "STEP #:", hdrNameFmt);
            mergeRange(w, r, 3, r, 6, hdr.step, hdrValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            mergeRange(w, r, 0, r, 2, "Temperature:", hdrNameFmt);
            mergeRange(w, r, 3, r, 6, hdr.temperature, hdrValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            mergeRange(w, r, 0, r, 2, "Lot #:", hdrNameFmt);
            mergeRange(w, r, 3, r, 6, hdr.lot_id, hdrValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            mergeRange(w, r, 0, r, 2, "SubLot #:", hdrNameFmt);
            mergeRange(w, r, 3, r, 6, hdr.sublot_id, hdrValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            mergeRange(w, r, 0, r, 2, "Wafer #:", hdrNameFmt);
            mergeRange(w, r, 3, r, 6, hdr.wafer_id, hdrValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            mergeRange(w, r, 0, r, 2, "Device:", hdrNameFmt);
            mergeRange(w, r, 3, r, 6, hdr.devName, hdrValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        foreach (key; map.keys)
        {
            mergeRange(w, r, 0, r, 2, key, hdrNameFmt);
            mergeRange(w, r, 3, r, 6, map[key], hdrValueFmt);
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
        mergeRange(w, 7, 0, 7, 5, "Test Name", testNameHdrFmt);
        writeString(w, 7, 6, "Test Num", testNumberHdrFmt);
        writeString(w, 7, 7, "Duplicate", dupHdrFmt);
        writeString(w, 7, 8, "Lo Limit", loLimitHdrFmt);
        writeString(w, 7, 9, "Hi Limit", hiLimitHdrFmt);
        writeString(w, 7, 10, "Units", unitsHdrFmt);
        mergeRange(w, 7, 11, 7, 15, "Pin", pinHdrFmt);
        // device id header
        if (wafersort) writeString(w, 0, 15, "X : Y", snxyHdrFmt); else writeString(w, 0, 15, "S/N", snxyHdrFmt);
        writeString(w, 1, 15, "Temp", tempHdrFmt);
        writeString(w, 2, 15, "Time", timeHdrFmt);
        writeString(w, 3, 15, "HW Bin", hwbinHdrFmt);
        writeString(w, 4, 15, "SW Bin", swbinHdrFmt);
        writeString(w, 5, 15, "Site", siteHdrFmt);
        writeString(w, 6, 15, "Result", rsltHdrFmt);
    }
    else
    {
        // test id header
        mergeRange(w, 0, 7, 11, 7, "Test Name", testNameHdrFmt);
        writeString(w, 12, 7, "Test Num", testNumberHdrFmt);
        writeString(w, 13, 7, "Duplicate", dupHdrFmt);
        writeString(w, 14, 7, "Lo Limit", loLimitHdrFmt);
        writeString(w, 15, 7, "Hi Limit", hiLimitHdrFmt);
        writeString(w, 16, 7, "Units", unitsHdrFmt);
        mergeRange(w, 17, 7, 23, 7, "Pin", pinHdrFmt);
        if (wafersort) writeString(w, 24, 0, "X : Y", snxyHdrFmt); else writeString(w, 24, 0, "S/N", snxyHdrFmt);
        writeString(w, 24, 1, "Temp", tempHdrFmt);
        writeString(w, 24, 2, "Time", timeHdrFmt);
        writeString(w, 24, 3, "HW Bin", hwbinHdrFmt);
        writeString(w, 24, 4, "SW Bin", swbinHdrFmt);
        writeString(w, 24, 5, "Site", siteHdrFmt);
        mergeRange(w, 24, 6, 24, 7, "Result", rsltHdrFmt);
    }
}

private void setTestNameHeaders(CmdOptions options, Config config, Worksheet w, Flag!"rotated" rotated, LinkedMap!(const TestID, uint) tests, size_t col, size_t maxCols)
{
    if (options.verbosityLevel > 9) writeln("setTestNameHeaders()");
    const TestID[] ids = tests.keys();
    if (rotated)
    {
        for (uint i=0; i<tests.length(); i++)
        {
            auto id = ids[i];       
            int row = i + 8;
            mergeRange(w, row, 0, row, 5, id.testName, testNameValueFmt);
            writeNumber(w, row, 6, id.testNumber, testNumberValueFmt);
            writeNumber(w, row, 7, id.dup, dupValueFmt);
            // Limits must be added when the test data is added
            mergeRange(w, row, 11, row, 15, id.pin, pinValueFmt);
        }
    }
    else
    {
        for (size_t i=col; i<tests.length() && i<col+maxCols; i++)
        {
            auto id = ids[i];       
            ushort lcol = cast(ushort) ((i-col) + 8);
            mergeRange(w, 0, lcol, 11, lcol, id.testName, testNameValueFmt);
            writeNumber(w, 12, lcol, id.testNumber, testNumberValueFmt);
            writeNumber(w, 13, lcol, id.dup, dupValueFmt);
            // Limits must be added when the test data is added
            mergeRange(w, 17, lcol, 24, lcol, id.pin, pinValueFmt);
        }
    }
}

private void setDeviceNameHeader(CmdOptions options, Config config, Worksheet w, Flag!"wafersort" wafersort, Flag!"rotated" rotated, uint rowOrCol, ulong tmin, string temp, DeviceResult device)
{
    if (options.verbosityLevel > 9) writeln("setDeviceNameHeaders()");
    if (rotated)
    {
        writeString(w, 0, cast(ushort) rowOrCol, device.devId.getID(), snxyValueFmt);
        writeString(w, 1, cast(ushort) rowOrCol, temp, tempValueFmt);
        writeNumber(w, 2, cast(ushort) rowOrCol, device.tstamp, timeValueFmt);
        writeNumber(w, 3, cast(ushort) rowOrCol, device.hwbin, hwbinValueFmt);
        writeNumber(w, 4, cast(ushort) rowOrCol, device.swbin, swbinValueFmt);
        writeNumber(w, 5, cast(ushort) rowOrCol, device.site, siteValueFmt);
        if (device.goodDevice) mergeRange(w, 6, cast(ushort) rowOrCol, 7, cast(ushort) rowOrCol, "PASS", rsltPassValueFmt);
        else mergeRange(w, 6, cast(ushort) rowOrCol, 7, cast(ushort) rowOrCol, "FAIL", rsltFailValueFmt);
    }
    else
    {
        writeString(w, rowOrCol, 0, device.devId.getID(), snxyValueFmt);
        writeString(w, rowOrCol, 1, temp, tempValueFmt);
        writeNumber(w, rowOrCol, 2, device.tstamp, timeValueFmt);
        writeNumber(w, rowOrCol, 3, device.hwbin, hwbinValueFmt);
        writeNumber(w, rowOrCol, 4, device.swbin, swbinValueFmt);
        writeNumber(w, rowOrCol, 5, device.site, siteValueFmt);
        if (device.goodDevice) mergeRange(w, rowOrCol, 6, rowOrCol, 7, "PASS", rsltPassValueFmt);
        else mergeRange(w, rowOrCol, 6, rowOrCol, 7, "FAIL", rsltFailValueFmt);
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
private bool[ushort] cmap;
// This is for not-rotated spreadsheets
private void setData(CmdOptions options, Config config, Worksheet w, size_t sheetNum, const size_t maxCols, Flag!"wafersort" wafersort, LinkedMap!(const TestID, uint) rowOrColMap, DeviceResult[] devices, string temp, size_t col, Worksheet nextSheet)
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
        for (size_t i=col; i<device.tests.length && i<col+maxCols; i++)
        {
            TestRecord tr = device.tests[i];
            uint seqNum = rowOrColMap[tr.id];
            ushort lcol = cast(ushort) ((seqNum + 8) - col);
            if (lcol >= maxCols)
            {
                if (cast(ushort) (lcol+col) !in cmap)
                {
                    if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT || tr.type == TestType.STRING)
                    {
                        writeString(w, 14, lcol, "", loLimitValueFmt);
                        writeString(w, 15, lcol, "", hiLimitValueFmt);
                        writeString(w, 16, lcol, tr.units, unitsValueFmt);
                    }
                    else
                    {
                        if (tr.dynamicLoLimit)
                        {
                            writeString(w, 14, cast(ushort) (lcol-1), "", dynLoLimitHdrFmt);
                            writeString(w, 15, cast(ushort) (lcol-1), "", dynLoLimitHdrFmt);
                            writeString(w, 16, cast(ushort) (lcol-1), tr.units, unitsValueFmt);
                        }                       
                        if (tr.loLimit > 1E28) writeString(w, 14, lcol, "", loLimitValueFmt); 
                        else writeNumber(w, 14, lcol, tr.loLimit, loLimitValueFmt);
                        if (tr.hiLimit > 1E28) writeString(w, 15, lcol, "", hiLimitValueFmt);
                        writeNumber(w, 15, lcol, tr.hiLimit, hiLimitValueFmt);
                        writeString(w, 16, lcol, tr.units, unitsValueFmt);
                        if (tr.dynamicHiLimit)
                        {
                            writeString(w, 14, cast(ushort) (lcol+1), "", dynHiLimitHdrFmt);
                            writeString(w, 15, cast(ushort) (lcol+1), "", dynHiLimitHdrFmt);
                            writeString(w, 16, cast(ushort) (lcol+1), tr.units, unitsValueFmt);
                        }
                    }
                    cmap[cast(ushort) (lcol+col)] = true;
                }
                switch (tr.type) with(TestType)
                {
                    case FUNCTIONAL:
                        if ((tr.testFlags & 0x80) == 0x80) writeString(w, row, lcol, "FAIL", failDataFmt);
                        else writeString(w, row, lcol, "PASS", passDataStringFmt);
                        break;
                    case PARAMETRIC: goto case;
                    case FLOAT:
                        if (tr.dynamicLoLimit) writeNumber(w, row, cast(ushort) (lcol-1), tr.loLimit, dynLoLimitValueFmt);
                        if ((tr.testFlags & 0x80) == 0x80) writeNumber(w, row, lcol, tr.result.f, failDataFmt);
                        else writeNumber(w, row, lcol, tr.result.f, passDataFloatFmt);
                        if (tr.dynamicHiLimit) writeNumber(w, row, cast(ushort) (lcol+1), tr.hiLimit, dynHiLimitValueFmt);
                        break;
                    case HEX_INT:
                        string value = to!string(tr.result.u);
                        if ((tr.testFlags & 0x80) == 0x80) writeFormula(w, row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                        else writeFormula(w, row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                        break;
                    case DEC_INT:
                        if ((tr.testFlags & 0x80) == 0x80) writeNumber(w, row, lcol, tr.result.l, failDataFmt);
                        else writeNumber(w, row, lcol, tr.result.l, passDataIntFmt);
                        break;
                    case DYNAMIC_LOLIMIT:
                        writeNumber(w, row, lcol, tr.result.f, dynLoLimitValueFmt);
                        break;
                    case DYNAMIC_HILIMIT:
                        writeNumber(w, row, lcol, tr.result.f, dynHiLimitValueFmt);
                        break;
                    default: // STRING
                        if ((tr.testFlags & 0x80) == 0x80) writeString(w, row, lcol, tr.result.s, failDataFmt);
                        else writeString(w, row, lcol, tr.result.s, passDataStringFmt);
                        break;
                }
            }
            if (cast(ushort) (lcol+col) !in cmap)
            {
                if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT || tr.type == TestType.STRING)
                {
                    writeString(w, 14, lcol, "", loLimitValueFmt);
                    writeString(w, 15, lcol, "", hiLimitValueFmt);
                    writeString(w, 16, lcol, tr.units, unitsValueFmt);
                }
                else
                {
                    if (tr.dynamicLoLimit)
                    {
                        writeString(w, 14, cast(ushort) (lcol-1), "", dynLoLimitHdrFmt);
                        writeString(w, 15, cast(ushort) (lcol-1), "", dynLoLimitHdrFmt);
                        writeString(w, 16, cast(ushort) (lcol-1), tr.units, unitsValueFmt);
                    }                       
                    if (tr.loLimit > 1E28) writeString(w, 14, lcol, "", loLimitValueFmt);
                    else writeNumber(w, 14, lcol, tr.loLimit, loLimitValueFmt);
                    if (tr.hiLimit > 1E28) writeString(w, 15, lcol, "", hiLimitValueFmt);
                    else writeNumber(w, 15, lcol, tr.hiLimit, hiLimitValueFmt);
                    writeString(w, 16, lcol, tr.units, unitsValueFmt);
                    if (tr.dynamicHiLimit)
                    {
                        writeString(w, 14, cast(ushort) (lcol+1), "", dynHiLimitHdrFmt);
                        writeString(w, 15, cast(ushort) (lcol+1), "", dynHiLimitHdrFmt);
                        writeString(w, 16, cast(ushort) (lcol+1), tr.units, unitsValueFmt);
                    }
                }
                cmap[cast(ushort) (lcol+col)] = true;
            }
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) writeString(w, row, lcol, "FAIL", failDataFmt);
                else writeString(w, row, lcol, "PASS", passDataStringFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if (tr.dynamicLoLimit) writeNumber(w, row, cast(ushort) (lcol-1), tr.loLimit, dynLoLimitValueFmt);
                if ((tr.testFlags & 0x80) == 0x80) writeNumber(w, row, lcol, tr.result.f, failDataFmt);
                else writeNumber(w, row, lcol, tr.result.f, passDataFloatFmt);
                if (tr.dynamicHiLimit) writeNumber(w, row, cast(ushort) (lcol+1), tr.hiLimit, dynHiLimitValueFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) writeFormula(w, row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                else writeFormula(w, row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) writeNumber(w, row, lcol, tr.result.l, failDataFmt);
                else writeNumber(w, row, lcol, tr.result.l, passDataIntFmt);
                break;
            case DYNAMIC_LOLIMIT:
                writeNumber(w, row, lcol, tr.result.f, dynLoLimitValueFmt);
                break;
            case DYNAMIC_HILIMIT:
                writeNumber(w, row, lcol, tr.result.f, dynHiLimitValueFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) writeString(w, row, lcol, tr.result.s, failDataFmt);
                else writeString(w, row, lcol, tr.result.s, passDataStringFmt);
                break;
            }
        }
        row++;
    }
    w.freezePanes(25, 8);
}

private bool[uint] lmap;

// This is for rotated spreadsheets
private void setData(CmdOptions options, Config config, Worksheet w, size_t sheetNum, Flag!"wafersort" wafersort, LinkedMap!(const TestID, uint) rowOrColMap, DeviceResult[] devices, string temp, size_t col, size_t maxCols)
{
    if (options.verbosityLevel > 9) writeln("setData(2)");
    // Find the smallest timestamp:
    ulong tmin = ulong.max;
    foreach (ref device; devices)
    {
        if (device.tstamp < tmin) tmin = device.tstamp;
    }
    ushort lcol = 16;
    lmap.clear();
    for (size_t j=col; j<devices.length && j<col+maxCols; j++)
    {
        setDeviceNameHeader(options, config, w, wafersort, Yes.rotated, lcol, tmin, temp, devices[j]);
        for (int i=0; i<devices[j].tests.length; i++)
        {
            TestRecord tr = devices[j].tests[i];
            uint seqNum = rowOrColMap[tr.id];
            uint row = seqNum + 8;
            if (row !in lmap)
            {
                writeString(w, row, 10, tr.units, unitsValueFmt);
                if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT || tr.type == TestType.STRING)
                {
                    writeString(w, row, 8, "", loLimitValueFmt);
                    writeString(w, row, 9, "", hiLimitValueFmt);
                }
                else
                {
                    if (tr.dynamicLoLimit)
                    {
                        writeString(w, row-1, 8, "", dynLoLimitHdrFmt);
                        writeString(w, row-1, 9, "", dynLoLimitHdrFmt);
                        writeString(w, row-1, 10, tr.units, unitsValueFmt);
                    }                       
                    if (tr.loLimit > 1E28) writeString(w, row, 8, "", loLimitValueFmt);
                    else writeNumber(w, row, 8, tr.loLimit, loLimitValueFmt);
                    if (tr.hiLimit > 1E28) writeString(w, row, 9, "", loLimitValueFmt);
                    else writeNumber(w, row, 9, tr.hiLimit, loLimitValueFmt);
                    if (tr.dynamicHiLimit)
                    {
                        writeString(w, row+1, 8, "", dynHiLimitHdrFmt);
                        writeString(w, row+1, 9, "", dynHiLimitHdrFmt);
                        writeString(w, row+1, 10, tr.units, unitsValueFmt);
                    }
                }
                lmap[row] = true;
            }
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) writeString(w, row, lcol, "FAIL", failDataFmt);
                else writeString(w, row, lcol, "PASS", passDataStringFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if (tr.dynamicLoLimit) writeNumber(w, row-1, lcol, tr.loLimit, dynLoLimitValueFmt);
                if ((tr.testFlags & 0x80) == 0x80) writeNumber(w, row, lcol, tr.result.f, failDataFmt);
                else writeNumber(w, row, lcol, tr.result.f, passDataFloatFmt);
                if (tr.dynamicHiLimit) writeNumber(w, row+1, lcol, tr.hiLimit, dynHiLimitValueFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) writeFormula(w, row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                else writeFormula(w, row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) writeNumber(w, row, lcol, tr.result.l, failDataFmt);
                else writeNumber(w, row, lcol, tr.result.l, passDataIntFmt);
                break;
            case DYNAMIC_LOLIMIT:
                writeNumber(w, row, lcol, tr.result.f, dynLoLimitValueFmt);
                break;
            case DYNAMIC_HILIMIT:
                writeNumber(w, row, lcol, tr.result.f, dynHiLimitValueFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) writeString(w, row, lcol, tr.result.s, failDataFmt);
                else writeString(w, row, lcol, tr.result.s, passDataStringFmt);
                break;
            }
        }
        lcol++;
    }
    w.freezePanes(8, 16);
}




