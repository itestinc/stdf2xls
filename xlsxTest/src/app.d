import std.stdio;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import logo;

void main()
{
    auto wb = newWorkbook("x.xlsx");
    auto ws = wb.addWorksheet("PAGE 1");
    lxw_image_options options;
    double ss_width = 449 * 0.350;
    double ss_height = 245 * 0.324;
    options.x_scale = (4.0 * 70.0) / ss_width;
    options.y_scale = (7.0 * 20.0) / ss_height;
    ws.mergeRange(0, 0, 7, 3, null);
    options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
    ws.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &options);
    //ws.insertImageOpt(cast(uint) 0, cast(ushort) 0, "itest_logo.png", &options);
}

