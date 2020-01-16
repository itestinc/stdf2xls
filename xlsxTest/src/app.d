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
    //import logo;
    ws.setTabColor(0xFF4400);
    MemoryImage image = MemoryImage.fromImage("itest_logo.png");
    lxw_image_options options;
    writeln("width = ", image.width(), " height = ", image.height());
    double ss_width = image.width() * 0.350;
    double ss_height = image.height() * 0.324;
    options.x_scale = (4.0 * 70.0) / ss_width;
    options.y_scale = (7.0 * 20.0) / ss_height;
    ws.mergeRange(0, 0, 7, 3, null);
    options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
    ws.insertImageOpt(cast(uint) 0, cast(ushort) 0, "itest_logo.png", &options);
    //ws.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, logo.img.dup.ptr, 30811L, &options);

    
    /*
    auto fin = File("itest_logo.png", "r");
    auto buf = fin.rawRead(new ubyte[30811]);
    auto f = File("src/logo.d", "w");
    f.writeln("module logo;");
    f.writeln("");
    f.writeln("immutable(ubyte[]) img = [");
    for (size_t i=0; i<buf.length; i++)
    {
        f.writeln(buf[i], ",");
    }
    f.writeln("];");
    f.close();
    */
}
