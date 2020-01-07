module makechip.SpreadsheetWriter;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import makechip.StdfFile;
import makechip.StdfDB;
import makechip.Config;
import makechip.CmdOptions;

static Format legendTitleFmt;           // ss.title.bg_color ss.legend.title.text_color
static Format failFmt;                  // ss.fail.bg_color ss.legend.fail.text_color
static Format unreliableFmt;            // ss.unreliable.bg_color ss.legend.unreliable.text_color
static Format timeoutFmt;               // ss.timeout.bg_color ss.legend.timeout.text_color
static Format alarmFmt;                 // ss.alarm.bg_color ss.legend.alarm.text_color
static Format abortFmt;                 // ss.abort.bg_color ss.legend.abort.text_color
static Format invalidFmt;               // ss.invalid.bg_color ss.legend.invalid.text_color
static Format passFmt;                  // ss.legend.pass.bg_color ss.legend.pass.text_color
static Format pageTitleFmt;             // ss.step.label.bg_color ss.step.label.text_color
static Format headerBoldFmt;            // ss.header.name.bg_color ss.header.name.text_color
static Format headerNormalFmt;          // ss.header.value.bg_color ss.header.value.text_color
static Format rowColTestHdrFmt;         // ss.table.header.bg_color ss.table.header.text_color
static Format rowColTestNameHdrFmt;     // ss.table.header.bg_color ss.table.header.text_color
static Format rowColBinHdrFmt;          // ss.table.header.bg_color ss.table.header.text_color
static Format rowColTempHdrFmt;         // ss.table.header.bg_color ss.table.header.text_color
static Format rowColUnitHdrFmt;         // ss.table.header.bg_color ss.table.header.text_color
static Format rowColUnitsTempHdrFmt;    // ss.table.header.bg_color ss.table.header.text_color
static Format rsltHdrFmt;               // ss.result.header.bg_color ss.result.header.text_color
static Format rsltTestNameHdrFmt;       // ss.result.header.bg_color ss.result.header.text_color
static Format testHdrFmt;               // ss.test.header.bg_color ss.test.header.text_color

public void initFormats(Workbook wb, CmdOptions options, Config config)
{
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

    headerBoldFmt = wb.addFormat();
    headerBoldFmt.setFontName("Arial");
    headerBoldFmt.setFontSize(8.0);
    config.setBGColor(headerBoldFmt, Config.ss_header_name_bg_color);
    config.setFontColor(headerBoldFmt, Config.ss_header_name_text_color);
    headerBoldFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    headerBoldFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerBoldFmt.setBorderColor(0x1000000);
    headerBoldFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    headerNormalFmt = wb.addFormat();
    headerNormalFmt.setFontName("Arial");
    headerNormalFmt.setFontSize(8.0);
    config.setBGColor(headerNormalFmt, Config.ss_header_value_bg_color);
    config.setFontColor(headerNormalFmt, Config.ss_header_value_text_color);
    headerNormalFmt.setAlign(lxw_format_alignments.LXW_ALIGN_LEFT);
    headerNormalFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    headerNormalFmt.setBorderColor(0x1000000);
    headerNormalFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    testHdrFmt = wb.addFormat();
    testHdrFmt.setFontName("Arial");
    testHdrFmt.setFontSize(8.0);
    config.setBGColor(testHdrFmt, Config.ss_test_header_bg_color);
    config.setFontColor(testHdrFmt, Config.ss_test_header_text_color);
    testHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    testHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    testHdrFmt.setBorderColor(0x1000000);
    testHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rowColUnitsTempHdrFmt = wb.addFormat();
    rowColUnitsTempHdrFmt.setFontName("Arial");
    rowColUnitsTempHdrFmt.setFontSize(8.0);
    config.setBGColor(rowColUnitsTempHdrFmt, Config.ss_table_header_bg_color);
    config.setFontColor(rowColUnitsTempHdrFmt, Config.ss_table_header_text_color);
    rowColUnitsTempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    rowColUnitsTempHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rowColUnitsTempHdrFmt.setBorderColor(0x1000000);
    rowColUnitsTempHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    rowColUnitsTempHdrFmt.setDiagType(2);
    rowColUnitsTempHdrFmt.setDiagBorder(1);
    rowColUnitsTempHdrFmt.setDiagColor(0x1000000);

    rowColTestHdrFmt = wb.addFormat();
    rowColTestHdrFmt.setFontName("Arial");
    rowColTestHdrFmt.setFontSize(8.0);
    config.setBGColor(rowColTestHdrFmt, Config.ss_table_header_bg_color);
    config.setFontColor(rowColTestHdrFmt, Config.ss_table_header_text_color);
    if (options.rotate) rowColTestHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else rowColTestHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    rowColTestHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rowColTestHdrFmt.setBorderColor(0x1000000);
    rowColTestHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rowColTestNameHdrFmt = wb.addFormat();
    rowColTestNameHdrFmt.setFontName("Arial");
    rowColTestNameHdrFmt.setFontSize(8.0);
    config.setBGColor(rowColTestNameHdrFmt, Config.ss_table_header_bg_color);
    config.setFontColor(rowColTestNameHdrFmt, Config.ss_table_header_text_color);
    rowColTestNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    rowColTestNameHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rowColTestNameHdrFmt.setBorderColor(0x1000000);
    rowColTestNameHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) rowColTestNameHdrFmt.setRotation(90);

    rowColBinHdrFmt = wb.addFormat();
    rowColBinHdrFmt.setFontName("Arial");
    rowColBinHdrFmt.setFontSize(8.0);
    config.setBGColor(rowColBinHdrFmt, Config.ss_table_header_bg_color);
    config.setFontColor(rowColBinHdrFmt, Config.ss_table_header_text_color);
    if (options.rotate) rowColBinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    else rowColBinHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_RIGHT);
    rowColBinHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rowColBinHdrFmt.setBorderColor(0x1000000);
    rowColBinHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rowColTempHdrFmt = wb.addFormat();
    rowColTempHdrFmt.setFontName("Arial");
    rowColTempHdrFmt.setFontSize(8.0);
    config.setBGColor(rowColTempHdrFmt, Config.ss_table_header_bg_color);
    config.setFontColor(rowColTempHdrFmt, Config.ss_table_header_text_color);
    rowColTempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    if (options.rotate) rowColTempHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    rowColTempHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rowColTempHdrFmt.setBorderColor(0x1000000);
    rowColTempHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rowColUnitHdrFmt = wb.addFormat();
    rowColUnitHdrFmt.setFontName("Arial");
    rowColUnitHdrFmt.setFontSize(8.0);
    config.setBGColor(rowColUnitHdrFmt, Config.ss_table_header_bg_color);
    config.setFontColor(rowColUnitHdrFmt, Config.ss_table_header_text_color);
    rowColUnitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    if (!options.rotate) rowColUnitHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_VERTICAL_CENTER);
    rowColUnitHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rowColUnitHdrFmt.setBorderColor(0x1000000);
    rowColUnitHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rsltHdrFmt = wb.addFormat();
    rsltHdrFmt.setFontName("Arial");
    rsltHdrFmt.setFontSize(8.0);
    config.setBGColor(rsltHdrFmt, Config.ss_result_header_bg_color);
    config.setFontColor(rsltHdrFmt, Config.ss_result_header_text_color);
    rsltHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    rsltHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rsltHdrFmt.setBorderColor(0x1000000);
    rsltHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);

    rsltTestNameHdrFmt = wb.addFormat();
    rsltTestNameHdrFmt.setFontName("Arial");
    rsltTestNameHdrFmt.setFontSize(8.0);
    config.setBGColor(rsltTestNameHdrFmt, Config.ss_result_header_bg_color);
    config.setFontColor(rsltTestNameHdrFmt, Config.ss_result_header_text_color);
    rsltTestNameHdrFmt.setAlign(lxw_format_alignments.LXW_ALIGN_CENTER);
    rsltTestNameHdrFmt.setRight(lxw_format_borders.LXW_BORDER_THIN);
    rsltTestNameHdrFmt.setBorderColor(0x1000000);
    rsltTestNameHdrFmt.setBottom(lxw_format_borders.LXW_BORDER_THIN);
    if (!options.rotate) rsltTestNameHdrFmt.setRotation(90);

}

public void writeSheet(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    if (hdr.isWafersort()) 
    {
        if (options.rotate) writeWaferSheetRotate(options, wb, rowOrColMap, hdr, devices, config);
        else writeWaferSheet(options, wb, rowOrColMap, hdr, devices, config);
    }
    else
    {
        if (options.rotate) writeFTSheetRotate(options, wb, rowOrColMap, hdr, devices, config);
        else writeFTSheet(options, wb, rowOrColMap, hdr, devices, config);
    }
}

private void writeWaferSheetRotate(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    const size_t numDevices = devices.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
}

private void writeWaferSheet(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    const size_t numTests = rowOrColMap.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
    
}

private void writeFTSheetRotate(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    const size_t numDevices = devices.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;

}

private void writeFTSheet(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{
    const size_t numTests = rowOrColMap.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;

}

private worksheet[] createSheetsWafer(CmdOptions options, Config config, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices)
{
    const size_t numTests = rowOrColMap.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
    const size_t numSheets = (numTests % maxCols == 0) ? numTests / maxCols : (numTests + 1) / macCols;
    worksheet[] ws;
    for (size_t i=0; i<numSheets; i++)
    {
        worksheet w = wb.addWorkSheet(title);
        ws ~= w;
        makePageHeader(title, wafersort.yes, rotated.no, numCols, continued.no, config.logoPath);
    }
}

private worksheet[] createSheetsWaferRotated(CmdOptions options, Config config, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices)
{
    const size_t numDevices = devices.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
    const size_t numSheets = (numDevices % maxCols == 0) ? numDevices / maxCols : (numDevices + 1) / maxCols;
}

private worksheet[] createSheetsFT(CmdOptions options, Config config, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices)
{
    const size_t numTests = rowOrColMap.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
    const size_t numSheets = (numTests % maxCols == 0) ? numTests / maxCols : (numTests + 1) / macCols;

}

private worksheet[] createSheetsFTRotated(CmdOptions options, Config config, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices)
{
    const size_t numDevices = devices.length;
    const size_t maxCols = options.limit1k ? 1000 : 16360;
    const size_t numSheets = (numDevices % maxCols == 0) ? numDevices / maxCols : (numDevices + 1) / maxCols;

}

