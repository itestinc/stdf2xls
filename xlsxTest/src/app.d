import std.stdio;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import arsd.image;
import arsd.color;

// The sts_logo is 1200 pixels X 463 pixels.
// With X and Y scale == 1.0 the logo comes out as 420 X 148 in the spreadsheet

void main()
{
    immutable size_t fourCols = 210;
    immutable size_t sevenRows = 138;
    auto wb = newWorkbook("x.xlsx");
    auto ws = wb.addWorksheet("PAGE 1");
    MemoryImage mi = MemoryImage.fromImage("sts_logo.png");
    writeln("Width = ", mi.width(), " Height = ", mi.height());
    ws.setTabColor(0xFF4400);
    lxw_image_options options;
    options.x_scale = 1.0;
    options.y_scale = 1.0;
    ws.insertImageOpt(cast(uint) 0, cast(ushort) 0,  "sts_logo.png", &options);
}
