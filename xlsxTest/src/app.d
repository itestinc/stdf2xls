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
    MemoryImage mi = MemoryImage.fromImage("itest_logo.png");
    writeln("Width = ", mi.width(), " Height = ", mi.height());
    ws.setTabColor(0xFF4400);
    lxw_image_options options;
    double ss_width = mi.width() * 0.35;
    double ss_height = mi.height() * 0.321;

    options.x_scale = (4.0 * 70.0) / ss_width;
    options.y_scale = (7.0 * 20.0) / ss_height;
    ws.insertImageOpt(cast(uint) 0, cast(ushort) 0,  "itest_logo.png", &options);

    for (size_t x=0; x<mi.width(); x++)
    {
        for (size_t y=0; y<mi.height(); y++)
        {
            Color c = mi.getPixel(x, y);
    
}
