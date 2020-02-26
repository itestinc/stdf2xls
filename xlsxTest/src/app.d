import std.stdio;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import std.conv;
import fonts;
import Util;
import logo;

private Format setFormat(Workbook wb, string fontName, string fontStyle, size_t fontSize)
{
    Format f = wb.addFormat();
    f.setFontName(fontName);
    f.setFontSize(fontSize);
    if (fontStyle == "") fontStyle = "normal";
    switch (fontStyle)
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
    default: throw new Exception("ERROR: unknown font style: " ~ fontStyle);
    }

    return f;
}

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

public double getDefaultPixelsPerChar(string s)
{
    double[][][] cw = fmapw["Arial"];
    size_t style = sindex["normal"];
    double w = 0.0;
    for (size_t i=0; i<s.length; i++)
    {
        w += cast(double) cast(int) (cw[11][style][s[i]] + 0.5);
    }
    double width = w / (cast(double) s.length);
    return width;
}

// returns the width in number of default characters
public double getColumnWidth(string s, uint dpi, string fontName, string fontStyle, size_t fontSize)
{
    //import std.math;
    //double averageCharWidth = getDefaultPixelsPerChar(s);
    double[][][] cw = fmapw[fontName];
    size_t style = sindex[fontStyle];
    double w = 0.0;
    for (size_t i=0; i<s.length; i++)
    {
        w += cast(double) (cast(int) (cw[fontSize][style][s[i]] + 0.5));
        //writeln("c = ", to!string(cast(char) s[i]), " w = ", cw[fontSize][style][s[i]]);
    }
    double width = (w / 6.00) * (96.0 / dpi);
    writeln("font = ", fontName, " w = ",  w, " width = ", width, " size = ", fontSize /*, " averageCharWidth = ", averageCharWidth */);
    return width + 0.5;
}

public double getRowHeight(uint dpi, string fontName, string fontStyle, size_t fontSize)
{
    ubyte[][] ch = fmaph[fontName];
    size_t style = sindex[fontStyle];
    double h = ch[fontSize][style];
    double height = (h * 96) / dpi;
    return height;
}


void main()
{
    auto wb = newWorkbook("x.xlsx");
    auto ws = wb.addWorksheet("PAGE 1");

    /*
    lxw_image_options options;
    double ss_width = 449 * 0.350;
    double ss_height = 245 * 0.324;
    options.x_scale = (4.0 * 70.0) / ss_width;
    options.y_scale = (7.0 * 20.0) / ss_height;
    ws.mergeRange(0, 0, 7, 3, null);
    options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
    ws.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &options);
    //ws.insertImageOpt(cast(uint) 0, cast(ushort) 0, "itest_logo.png", &options);
    */
    const string s1 = "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii";
    const string s2 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    const string s3 = "abcdefghijklmnopqrstuvwxyz0123456789";

    const string[] fonts = [ "Arial", "Courrier New", "Times New Roman" ];
    const string[] styles = [ "normal", "bold", "italic", "bold_italic", "underline", "bold_underline", "italic_underline", "bold_italic_underline" ];
    const size_t[] sizes = [ 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 ];

    ushort row = 0;
    ushort col = 0;
    /*
    Format fmt = setFormat(wb, fonts[0], styles[1], sizes[6]);
    //string str = fonts[0] ~ " " ~ styles[0] ~ " " ~ to!string(sizes[0]) ~ " " ~ s;
    double rh = getRowHeight(96, fonts[0], styles[1], sizes[6]);
    ws.setRow(row, rh);
    ws.writeString(0, 0, s1, fmt);
    double cw = getColumnWidth(s1, 96, fonts[0], styles[1], sizes[6]);
    ws.setColumn(0, 0, cw);
    ws.writeString(0, 1, s2, fmt);
    cw = getColumnWidth(s2, 96, fonts[0], styles[1], sizes[6]);
    ws.setColumn(1, 1, cw);
    ws.writeString(0, 2, s3, fmt);
    cw = getColumnWidth(s3, 96, fonts[0], styles[1], sizes[6]);
    ws.setColumn(2, 2, cw);
    */ 
    
    foreach(font; fonts)
    {
        foreach(style; styles)
        {
            foreach(size; sizes)
            {
                Format fmt = setFormat(wb, font, style, size);
                //writeln("font = ", fmt.font_name);
                string str = font ~ " " ~ style ~ " " ~ to!string(size) ~ " " ~ s1;
                double cw = getColumnWidth(str, 96, font, style, size);
                double rh = getRowHeight(96, font, style, size);
                ws.setColumn(col, col, cw);
                ws.setRow(row, rh);
                ws.writeString(row, col, str, fmt);
                row++;
                col++;
            }
        }
    }
    
    wb.close();
}

