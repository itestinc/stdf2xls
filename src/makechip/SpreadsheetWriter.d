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

static Format legendTitleFmt;           // ss.title.bg_color ss.legend.title.text_color
static Format failFmt;                  // ss.fail.bg_color ss.legend.fail.text_color
static Format unreliableFmt;            // ss.unreliable.bg_color ss.legend.unreliable.text_color
static Format timeoutFmt;               // ss.timeout.bg_color ss.legend.timeout.text_color
static Format alarmFmt;                 // ss.alarm.bg_color ss.legend.alarm.text_color
static Format abortFmt;                 // ss.abort.bg_color ss.legend.abort.text_color
static Format invalidFmt;               // ss.invalid.bg_color ss.legend.invalid.text_color
static Format passFmt;                  // ss.legend.pass.bg_color ss.legend.pass.text_color
static Format pageTitleFmt;             // ss.step.label.bg_color ss.step.label.text_color
static Format headerNameFmt;            // ss.header.name.bg_color ss.header.name.text_color
static Format headerValueFmt;           // ss.header.value.bg_color ss.header.value.text_color

static Format testidHdrFmt;             // ss.testid.header.bg_color ss.testid.header.text_color
static Format testidNameHdrFmt;         // same as ss.testid.header.bg_color ss.testid.header.text_color
static Format deviceidHdrFmt;           // ss.deviceid.header.bg_color ss.deviceid.header.text_color
static Format unitstempHdrFmt;          // ss.unitstemp.header.bg_color ss.unitstemp.header.text_color
static Format unitsHdrFmt;              // ss.units.header.bg_color ss.units.header.text_color
static Format tempHdrFmt;               // ss.temp.header.bg_color ss.temp.header.text_color

static Format testNumberHdrFmt;         // ss.test.header.bg_color ss.test.header.text_color
static Format testNameHdrFmt;           // ss.test.header.bg_color ss.test.header.text_color
static Format testLimitHdrFmt;          // ss.test.header.bg_color ss.test.header.text_color
static Format rsltHdrFmt;               // ss.result.header.bg_color ss.result.header.text_color
static Format dylimFmt;                 // ss.dynamic_limit.bg_color ss.dynamic_limit.text_color
static Format floatFmt;                 // ss.legend.pass.bg_color ss.legend.pass.text_color
static Format intFmt;                   // ss.legend.pass.bg_color ss.legend.pass.text_color
static Format floatFailFmt;             // ss.fail.bg_color ss.legend.fail.text_color
static Format intFailFmt;               // ss.fail.bg_color ss.legend.fail.text_color

immutable size_t defaultRowHeight = 20;
immutable size_t defaultColWidth = 70;

public void initFormats(Workbook wb, CmdOptions options, Config config)
{
    if (options.verbosityLevel > 9) writeln("initFormats()");
    import libxlsxd.xlsxwrap;
    legendTitleFmt = wb.addFormat();
    legendTitleFmt.setFontName("Arial");
    legendTitleFmt.setFontSize(8.0);
    config.setBGColor(legendTitleFmt, Config.ss_legend_title_bg_color);
    config.setFontColor(legendTitleFmt, Config.ss_legend_title_text_color);
    legendTitleFmt.setBold(); 
    legendTitleFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    legendTitleFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    legendTitleFmt.setBorderColor(0x1000000);
    legendTitleFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    failFmt = wb.addFormat();
    failFmt.setFontName("Arial");
    failFmt.setFontSize(8.0);
    config.setBGColor(failFmt, Config.ss_fail_bg_color);
    config.setFontColor(failFmt, Config.ss_fail_text_color);
    failFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    failFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    failFmt.setBorderColor(0x1000000);
    failFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    unreliableFmt = wb.addFormat();
    unreliableFmt.setFontName("Arial");
    unreliableFmt.setFontSize(8.0);
    config.setBGColor(unreliableFmt, Config.ss_unreliable_bg_color);
    config.setFontColor(unreliableFmt, Config.ss_unreliable_text_color);
    unreliableFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    unreliableFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    unreliableFmt.setBorderColor(0x1000000);
    unreliableFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    timeoutFmt = wb.addFormat();
    timeoutFmt.setFontName("Arial");
    timeoutFmt.setFontSize(8.0);
    config.setBGColor(timeoutFmt, Config.ss_timeout_bg_color);
    config.setFontColor(timeoutFmt, Config.ss_timeout_text_color);
    timeoutFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    timeoutFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    timeoutFmt.setBorderColor(0x1000000);
    timeoutFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    alarmFmt = wb.addFormat();
    alarmFmt.setFontName("Arial");
    alarmFmt.setFontSize(8.0);
    config.setBGColor(alarmFmt, Config.ss_alarm_bg_color);
    config.setFontColor(alarmFmt, Config.ss_alarm_text_color);
    alarmFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    alarmFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    alarmFmt.setBorderColor(0x1000000);
    alarmFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    abortFmt = wb.addFormat();
    abortFmt.setFontName("Arial");
    abortFmt.setFontSize(8.0);
    config.setBGColor(abortFmt, Config.ss_abort_bg_color);
    config.setFontColor(abortFmt, Config.ss_abort_text_color);
    abortFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    abortFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    abortFmt.setBorderColor(0x1000000);
    abortFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    invalidFmt = wb.addFormat();
    invalidFmt.setFontName("Arial");
    invalidFmt.setFontSize(8.0);
    config.setBGColor(invalidFmt, Config.ss_invalid_bg_color);
    config.setFontColor(invalidFmt, Config.ss_invalid_text_color);
    invalidFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    invalidFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    invalidFmt.setBorderColor(0x1000000);
    invalidFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    passFmt = wb.addFormat();
    passFmt.setFontName("Arial");
    passFmt.setFontSize(8.0);
    config.setBGColor(passFmt, Config.ss_pass_bg_color);
    config.setFontColor(passFmt, Config.ss_pass_text_color);
    passFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    passFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    passFmt.setBorderColor(0x1000000);
    passFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    pageTitleFmt = wb.addFormat();
    pageTitleFmt.setFontName("Arial");
    pageTitleFmt.setFontSize(18.0);
    config.setBGColor(pageTitleFmt, Config.ss_page_title_bg_color);
    config.setFontColor(pageTitleFmt, Config.ss_page_title_text_color);
    pageTitleFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    pageTitleFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    pageTitleFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    pageTitleFmt.setBorderColor(0x1000000);
    pageTitleFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    headerNameFmt = wb.addFormat();
    headerNameFmt.setFontName("Arial");
    headerNameFmt.setFontSize(8.0);
    config.setBGColor(headerNameFmt, Config.ss_header_name_bg_color);
    config.setFontColor(headerNameFmt, Config.ss_header_name_text_color);
    headerNameFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    headerNameFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerNameFmt.setBorderColor(0x1000000);
    headerNameFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    headerValueFmt = wb.addFormat();
    headerValueFmt.setFontName("Arial");
    headerValueFmt.setFontSize(8.0);
    config.setBGColor(headerValueFmt, Config.ss_header_value_bg_color);
    config.setFontColor(headerValueFmt, Config.ss_header_value_text_color);
    headerValueFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    headerValueFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerValueFmt.setBorderColor(0x1000000);
    headerValueFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    testidHdrFmt = wb.addFormat();
    testidHdrFmt.setFontName("Arial");
    testidHdrFmt.setFontSize(8.0);
    config.setBGColor(testidHdrFmt, Config.ss_testid_header_bg_color);
    config.setFontColor(testidHdrFmt, Config.ss_testid_header_text_color);
    testidHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testidHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testidHdrFmt.setBorderColor(0x1000000);
    testidHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    testidNameHdrFmt = wb.addFormat();
    testidNameHdrFmt.setFontName("Arial");
    testidNameHdrFmt.setFontSize(8.0);
    config.setBGColor(testidNameHdrFmt, Config.ss_testid_header_bg_color);
    config.setFontColor(testidNameHdrFmt, Config.ss_testid_header_text_color);
    testidNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testidNameHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testidNameHdrFmt.setBorderColor(0x1000000);
    testidNameHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) testidNameHdrFmt.setRotation(90);

    deviceidHdrFmt = wb.addFormat();
    deviceidHdrFmt.setFontName("Arial");
    deviceidHdrFmt.setFontSize(8.0);
    config.setBGColor(deviceidHdrFmt, Config.ss_deviceid_header_bg_color);
    config.setFontColor(deviceidHdrFmt, Config.ss_deviceid_header_text_color);
    deviceidHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    deviceidHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    deviceidHdrFmt.setBorderColor(0x1000000);
    deviceidHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    unitstempHdrFmt = wb.addFormat();
    unitstempHdrFmt.setFontName("Arial");
    unitstempHdrFmt.setFontSize(8.0);
    config.setBGColor(unitstempHdrFmt, Config.ss_unitstemp_header_bg_color);
    config.setFontColor(unitstempHdrFmt, Config.ss_unitstemp_header_text_color);
    unitstempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    unitstempHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    unitstempHdrFmt.setBorderColor(0x1000000);
    unitstempHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    unitstempHdrFmt.setDiagType(2);
    unitstempHdrFmt.setDiagBorder(1);
    unitstempHdrFmt.setDiagColor(0x1000000);

    testNameHdrFmt = wb.addFormat();
    testNameHdrFmt.setFontName("Arial");
    testNameHdrFmt.setFontSize(8.0);
    config.setBGColor(testNameHdrFmt, Config.ss_test_header_bg_color);
    config.setFontColor(testNameHdrFmt, Config.ss_test_header_text_color);
    testNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNameHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testNameHdrFmt.setBorderColor(0x1000000);
    testNameHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) testNameHdrFmt.setRotation(90);

    unitsHdrFmt = wb.addFormat();
    unitsHdrFmt.setFontName("Arial");
    unitsHdrFmt.setFontSize(8.0);
    config.setBGColor(unitsHdrFmt, Config.ss_units_header_bg_color);
    config.setFontColor(unitsHdrFmt, Config.ss_units_header_text_color);
    if (options.rotate) unitsHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else unitsHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    unitsHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    unitsHdrFmt.setBorderColor(0x1000000);
    unitsHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    tempHdrFmt = wb.addFormat();
    tempHdrFmt.setFontName("Arial");
    tempHdrFmt.setFontSize(8.0);
    config.setBGColor(tempHdrFmt, Config.ss_temp_header_bg_color);
    config.setFontColor(tempHdrFmt, Config.ss_temp_header_text_color);
    tempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    if (options.rotate) tempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    tempHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    tempHdrFmt.setBorderColor(0x1000000);
    tempHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    testNumberHdrFmt = wb.addFormat();
    testNumberHdrFmt.setFontName("Arial");
    testNumberHdrFmt.setFontSize(8.0);
    config.setBGColor(testNumberHdrFmt, Config.ss_test_header_bg_color);
    config.setFontColor(testNumberHdrFmt, Config.ss_test_header_text_color);
    testNumberHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testNumberHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testNumberHdrFmt.setBorderColor(0x1000000);
    testNumberHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    testLimitHdrFmt = wb.addFormat();
    testLimitHdrFmt.setFontName("Arial");
    testLimitHdrFmt.setFontSize(8.0);
    config.setBGColor(testLimitHdrFmt, Config.ss_test_header_bg_color);
    config.setFontColor(testLimitHdrFmt, Config.ss_test_header_text_color);
    testLimitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testLimitHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testLimitHdrFmt.setBorderColor(0x1000000);
    testLimitHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rsltHdrFmt = wb.addFormat();
    rsltHdrFmt.setFontName("Arial");
    rsltHdrFmt.setFontSize(8.0);
    config.setBGColor(rsltHdrFmt, Config.ss_result_header_bg_color);
    config.setFontColor(rsltHdrFmt, Config.ss_result_header_text_color);
    rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    rsltHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rsltHdrFmt.setBorderColor(0x1000000);
    rsltHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    dylimFmt = wb.addFormat();
    dylimFmt.setFontName("Arial");
    dylimFmt.setFontSize(8.0);
    config.setBGColor(dylimFmt, Config.ss_dynamic_limit_bg_color);
    config.setFontColor(dylimFmt, Config.ss_dynamic_limit_text_color);
    dylimFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    dylimFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    dylimFmt.setBorderColor(0x1000000);
    dylimFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    floatFmt = wb.addFormat();
    floatFmt.setFontName("Arial");
    floatFmt.setFontSize(8.0);
    config.setBGColor(floatFmt, Config.ss_pass_bg_color);
    config.setFontColor(floatFmt, Config.ss_pass_text_color);
    floatFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    floatFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    floatFmt.setBorderColor(0x1000000);
    floatFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    floatFmt.setNumFormat("0.000");

    intFmt = wb.addFormat();
    intFmt.setFontName("Arial");
    intFmt.setFontSize(8.0);
    config.setBGColor(intFmt, Config.ss_pass_bg_color);
    config.setFontColor(intFmt, Config.ss_pass_text_color);
    intFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    intFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    intFmt.setBorderColor(0x1000000);
    intFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    intFmt.setNumFormat("General");

    floatFailFmt = wb.addFormat();
    floatFailFmt.setFontName("Arial");
    floatFailFmt.setFontSize(8.0);
    config.setBGColor(floatFailFmt, Config.ss_fail_bg_color);
    config.setFontColor(floatFailFmt, Config.ss_fail_text_color);
    floatFailFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    floatFailFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    floatFailFmt.setBorderColor(0x1000000);
    floatFailFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    floatFailFmt.setNumFormat("0.000");

    intFailFmt = wb.addFormat();
    intFailFmt.setFontName("Arial");
    intFailFmt.setFontSize(8.0);
    config.setBGColor(intFailFmt, Config.ss_fail_bg_color);
    config.setFontColor(intFailFmt, Config.ss_fail_text_color);
    intFailFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    intFailFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    intFailFmt.setBorderColor(0x1000000);
    intFailFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    intFailFmt.setNumFormat("General");

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
        Worksheet w = wb.addWorksheet(title);
        ws ~= w;
        setLogo(options, config, w);
        setLegend(options, config, w, Yes.rotated);
        setPageHeader(options, config, w, title, numDevices > maxCols - 4 ? maxCols - 4 : numDevices, Yes.rotated);
        setDeviceHeader(options, config, w, hdr, Yes.rotated);
        setTableHeaders(options, config, w, Yes.wafersort, Yes.rotated);
        setTestNameHeaders(options, config, w, Yes.rotated, rowOrColMap);
        setData(options, config, w, i, Yes.wafersort, rowOrColMap, devices);
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
        Worksheet w = wb.addWorksheet(title);
        ws ~= w;
        setLogo(options, config, w);
        setLegend(options, config, w, No.rotated);
        setPageHeader(options, config, w, title, numTests > maxCols - 4 ? maxCols - 4 : numTests, No.rotated);
        setDeviceHeader(options, config, w, hdr, No.rotated);
        setTableHeaders(options, config, w, No.wafersort, No.rotated);
        setTestNameHeaders(options, config, w, No.rotated, rowOrColMap);
        setData(options, config, w, i, maxCols, No.wafersort, rowOrColMap, devices);
    }
    return ws;
}

import std.conv;
private string getTitle(CmdOptions options, HeaderInfo hdr, size_t page)
{
    if (options.verbosityLevel > 9) writeln("getTitle()");
    string title;
    if (hdr.isWafersort())
    {
        title = hdr.devName ~ " Lot " ~ hdr.lot_id ~ " Wafer " ~ hdr.wafer_id ~ " Page " ~ to!string(page);
    }
    else
    {
        string name;
        if (hdr.lot_id == "" && hdr.step == "") name = "";
        else if (hdr.lot_id == "") name = "Step " ~ hdr.step;
        else if (hdr.step == "") name = "Lot " ~ hdr.lot_id;
        else name = "Lot " ~ hdr.lot_id ~ " Step " ~ hdr.step;
        title = hdr.devName ~ (hdr.devName != "" ? " " : "") ~ name ~ " Page " ~ to!string(page);
    }
    return title;
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
}

private void setLegend(CmdOptions options, Config config, Worksheet w, Flag!"rotated" rotated)
{
    if (options.verbosityLevel > 9) writeln("setLegend()");
    if (rotated)
    {
        w.writeString(0, 3, "Legend:", legendTitleFmt);
        w.writeString(1, 3, "FAIL", failFmt);
        w.writeString(2, 3, "Unreliable", unreliableFmt);
        w.writeString(3, 3, "Timeout", timeoutFmt);
        w.writeString(4, 3, "Alarm", alarmFmt);
        w.writeString(5, 3, "Abort", abortFmt);
        w.writeString(6, 3, "Invalid", invalidFmt);
    }
    else
    {
        w.mergeRange(0, 3, 0, 5, null);
        w.mergeRange(1, 3, 1, 5, null);
        w.mergeRange(2, 3, 2, 5, null);
        w.mergeRange(3, 3, 3, 5, null);
        w.mergeRange(4, 3, 4, 5, null);
        w.mergeRange(5, 3, 5, 5, null);
        w.mergeRange(6, 3, 6, 5, null);
        w.writeString(0, 3, "Legend:", legendTitleFmt);
        w.writeString(1, 3, "FAIL", failFmt);
        w.writeString(2, 3, "Unreliable", unreliableFmt);
        w.writeString(3, 3, "Timeout", timeoutFmt);
        w.writeString(4, 3, "Alarm", alarmFmt);
        w.writeString(5, 3, "Abort", abortFmt);
        w.writeString(6, 3, "Invalid", invalidFmt);
    }
}

private void setPageHeader(CmdOptions options, Config config, Worksheet w, string title, size_t dataCols, Flag!"rotated" rotated)
{
    if (options.verbosityLevel > 9) writeln("setPageHeader()");
    if (rotated)
    {
        w.mergeRange(0, cast(ushort) 6, 6, cast(ushort) (6+dataCols), title, pageTitleFmt);
    }
    else
    {
        w.mergeRange(0, cast(ushort) 4, 6, cast(ushort) (12+dataCols), title, pageTitleFmt);
    }
}

private void setDeviceHeader(CmdOptions options, Config config, Worksheet w, HeaderInfo hdr, Flag!"rotated" rotated)
{
    if (options.verbosityLevel > 9) writeln("setDeviceHeader()");
    if (rotated)
    {
        int r = 7;
        if (hdr.step != "")
        {
            w.mergeRange(r, 0, r, 1, "STEP #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.step, headerValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            w.mergeRange(r, 0, r, 1, "Temperature:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.temperature, headerValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            w.mergeRange(r, 0, r, 1, "Lot #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.lot_id, headerValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            w.mergeRange(r, 0, r, 1, "SubLot #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.sublot_id, headerValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            w.mergeRange(r, 0, r, 1, "Wafer #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.wafer_id, headerValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            w.mergeRange(r, 0, r, 1, "Device:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.devName, headerValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        ushort c = 0;
        foreach (key; map)
        {
            w.mergeRange(r, c, r, cast(ushort) (c+1), key, headerNameFmt);
            w.mergeRange(r, cast(ushort) (c+2), r, cast(ushort) (c+4), map[key], headerValueFmt);
            r++;
            if (r == 14)
            {
                r = 7;
                c += 4;
            }
            if (r == 14 && c == 8) break;
        }
    }
    else
    {
        int r = 7;
        if (hdr.step != "")
        {
            w.mergeRange(r, 0, r, 1, "STEP #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.step, headerValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            w.mergeRange(r, 0, r, 1, "Temperature:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.temperature, headerValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            w.mergeRange(r, 0, r, 1, "Lot #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.lot_id, headerValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            w.mergeRange(r, 0, r, 1, "SubLot #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.sublot_id, headerValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            w.mergeRange(r, 0, r, 1, "Wafer #:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.wafer_id, headerValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            w.mergeRange(r, 0, r, 1, "Device:", headerNameFmt);
            w.mergeRange(r, 2, r, 4, hdr.devName, headerValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        foreach (key; map)
        {
            w.mergeRange(r, 0, r, 1, key, headerNameFmt);
            w.mergeRange(r, 2, r, 4, map[key], headerValueFmt);
            r++;
            if (r > 24) break;
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
        w.writeString(15, 0, "Test Num", testidHdrFmt);
        w.mergeRange(15, 1, 15, 5, "Test Name", testidHdrFmt);
        w.writeString(15, 6, "Duplicate", testidHdrFmt);
        w.writeString(15, 7, "Lo Limit", testidHdrFmt);
        w.writeString(15, 8, "Hi Limit", testidHdrFmt);
        w.mergeRange(15, 9, 15, 11, "Pin", testidHdrFmt);
        // units/temp header
        w.mergeRange(14, 12, 15, 12, "    Temp Units", unitstempHdrFmt);
        // device id header
        if (wafersort) w.writeString(7, 12, "X, Y", deviceidHdrFmt); else w.writeString(7, 12, "S/N", deviceidHdrFmt);
        w.writeString(8, 12, "HW Bin", deviceidHdrFmt);
        w.writeString(9, 12, "SW Bin", deviceidHdrFmt);
        w.writeString(10, 12, "Site", deviceidHdrFmt);
        w.writeString(11, 12, "Time", deviceidHdrFmt);
        w.writeString(12, 12, "Result", deviceidHdrFmt);
    }
    else
    {
        // test id header
        w.mergeRange(7, 6, 18, 6, "Test Name", testidNameHdrFmt);
        w.writeString(19, 6, "Test Num", testidHdrFmt);
        w.writeString(20, 6, "Duplicate", testidHdrFmt);
        w.writeString(21, 6, "Lo Limit", testidHdrFmt);
        w.writeString(22, 6, "Hi Limit", testidHdrFmt);
        w.writeString(23, 6, "Pin", testidHdrFmt);
        // units/temp header
        w.mergeRange(24, 6, 25, 6, "    Units Temp", unitstempHdrFmt);
        // device id header
        if (wafersort) w.writeString(25, 0, "X, Y", deviceidHdrFmt); else w.writeString(25, 0, "S/N", deviceidHdrFmt);
        w.writeString(25, 1, "HW Bin", deviceidHdrFmt);
        w.writeString(25, 2, "SW Bin", deviceidHdrFmt);
        w.writeString(25, 3, "Site", deviceidHdrFmt);
        w.writeString(25, 4, "Time", deviceidHdrFmt);
        w.writeString(25, 5, "Result", deviceidHdrFmt);
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
            int row = i + 16;
            w.writeNumber(row, 0, id.testNumber, testNumberHdrFmt);
            w.mergeRange(row, 1, row, 5, id.testName, testNameHdrFmt);
            w.writeNumber(row, 6, id.dup, testNumberHdrFmt);
            // Limits must be added when the test data is added
            w.mergeRange(row, 9, row, 11, id.pin, testNameHdrFmt);
        }
    }
    else
    {
        for (uint i=0; i<tests.length(); i++)
        {
            auto id = ids[i];       
            ushort col = cast(ushort) (i + 7);
            w.mergeRange(7, col, 18, col, id.testName, testNameHdrFmt);
            w.writeNumber(19, col, id.testNumber, testNumberHdrFmt);
            w.writeNumber(20, col, id.dup, testNumberHdrFmt);
            // Limits must be added when the test data is added
            w.writeString(23, col, id.pin, testNameHdrFmt);
        }
    }
}

private void setDeviceNameHeader(CmdOptions options, Config config, Worksheet w, Flag!"wafersort" wafersort, Flag!"rotated" rotated, uint rowOrCol, ulong tmin, DeviceResult device)
{
    if (options.verbosityLevel > 9) writeln("setDeviceNameHeaders()");
    if (rotated)
    {
        w.writeString(7, cast(ushort) rowOrCol, device.devId.getID(), deviceidHdrFmt);
        w.writeNumber(8, cast(ushort) rowOrCol, device.tstamp - tmin, deviceidHdrFmt);
        w.writeNumber(9, cast(ushort) rowOrCol, device.hwbin, deviceidHdrFmt);
        w.writeNumber(10, cast(ushort) rowOrCol, device.swbin, deviceidHdrFmt);
        w.writeNumber(11, cast(ushort) rowOrCol, device.site, deviceidHdrFmt);
        if (device.goodDevice) w.writeString(12, cast(ushort) rowOrCol, "PASS", deviceidHdrFmt);
        else w.writeString(12, cast(ushort) rowOrCol, "FAIL", failFmt);
    }
    else
    {
        w.writeString(rowOrCol, 0, device.devId.getID(), deviceidHdrFmt);
        w.writeNumber(rowOrCol, 1, device.tstamp - tmin, deviceidHdrFmt);
        w.writeNumber(rowOrCol, 2, device.hwbin, deviceidHdrFmt);
        w.writeNumber(rowOrCol, 3, device.swbin, deviceidHdrFmt);
        w.writeNumber(rowOrCol, 4, device.site, deviceidHdrFmt);
        if (device.goodDevice) w.writeString(rowOrCol, 5, "PASS", deviceidHdrFmt);
        else w.writeString(rowOrCol, 5, "FAIL", failFmt);
    }
}

// This is for not-rotated spreadsheets
private void setData(CmdOptions options, Config config, Worksheet w, size_t sheetNum, const size_t maxCols, Flag!"wafersort" wafersort, LinkedMap!(const TestID, uint) rowOrColMap, DeviceResult[] devices)
{
    if (options.verbosityLevel > 9) writeln("setData(1)");
    // Find the smallest timestamp:
    ulong tmin = ulong.max;
    foreach (device; devices)
    {
        if (device.tstamp < tmin) tmin = device.tstamp;
    }
    // do not exceed maxCols
    uint row = 26;
    foreach(device; devices)
    {
        setDeviceNameHeader(options, config, w, wafersort, No.rotated, row, tmin, device);
        for (int i=0; i<device.tests.length; i++)
        {
            TestRecord tr = device.tests[i];
            uint seqNum = rowOrColMap[tr.id];
            ushort col = cast(ushort) (seqNum + 7);
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, "FAIL", failFmt);
                else w.writeString(row, col, "PASS", passFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.f, floatFailFmt);
                else w.writeNumber(row, col, tr.result.f, floatFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", intFailFmt);
                else w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", intFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.l, intFailFmt);
                else w.writeNumber(row, col, tr.result.l, intFmt);
                break;
            case DYNAMIC_LOLIMIT: goto case;
            case DYNAMIC_HILIMIT:
                w.writeNumber(row, col, tr.result.f, dylimFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, tr.result.s, failFmt);
                else w.writeString(row, col, tr.result.s, passFmt);
                break;
            }
        }
        row++;
    }
}

// This is for rotated spreadsheets
private void setData(CmdOptions options, Config config, Worksheet w, size_t sheetNum, Flag!"wafersort" wafersort, LinkedMap!(const TestID, uint) rowOrColMap, DeviceResult[] devices)
{
    if (options.verbosityLevel > 9) writeln("setData(2)");
    // Find the smallest timestamp:
    ulong tmin = ulong.max;
    foreach (device; devices)
    {
        if (device.tstamp < tmin) tmin = device.tstamp;
    }
    ushort col = 13;
    foreach(device; devices)
    {
        setDeviceNameHeader(options, config, w, wafersort, Yes.rotated, col, tmin, device);
        for (int i=0; i<device.tests.length; i++)
        {
            TestRecord tr = device.tests[i];
            uint seqNum = rowOrColMap[tr.id];
            ushort row = cast(ushort) (seqNum + 15);
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, "FAIL", failFmt);
                else w.writeString(row, col, "PASS", passFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.f, floatFailFmt);
                else w.writeNumber(row, col, tr.result.f, floatFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", intFailFmt);
                else w.writeFormula(row, col, "=DEC2HEX(" ~ value ~ "; 8)", intFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, col, tr.result.l, intFailFmt);
                else w.writeNumber(row, col, tr.result.l, intFmt);
                break;
            case DYNAMIC_LOLIMIT: goto case;
            case DYNAMIC_HILIMIT:
                w.writeNumber(row, col, tr.result.f, dylimFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, col, tr.result.s, failFmt);
                else w.writeString(row, col, tr.result.s, passFmt);
                break;
            }
        }
        col++;
    }
}




