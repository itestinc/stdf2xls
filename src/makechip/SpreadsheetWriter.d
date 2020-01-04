module makechip.SpreadsheetWriter;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import makechip.StdfFile;
import makechip.StdfDB;
import makechip.Config;
import makechip.CmdOptions;

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
        else writeFTSheet(options, rowOrColMap, hdr, devices, config);
    }
}

private void writeWaferSheetRotate(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{

}

private void writeWaferSheet(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{

}

private void writeFTSheetRotate(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{

}

private void writeFTSheet(CmdOptions options, Workbook wb, uint[const TestID] rowOrColMap, HeaderInfo hdr, DeviceResult[] devices, Config config)
{

}


