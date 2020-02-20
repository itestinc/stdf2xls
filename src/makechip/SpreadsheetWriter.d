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
import makechip.StdfDB:Point;

private MultiMap!(Point, string, string, size_t) sizeMap;

static this()
{
    sizeMap.put(Point(3, 5), "Arial", "normal", 4);
    sizeMap.put(Point(3, 5), "Arial", "bold", 4);
    sizeMap.put(Point(3, 5), "Arial", "bold_underline", 4);
    sizeMap.put(Point(3, 5), "Arial", "italic", 4);
    sizeMap.put(Point(3, 5), "Arial", "italic_underline", 4);
    sizeMap.put(Point(3, 5), "Arial", "bold_italic", 4);
    sizeMap.put(Point(3, 5), "Arial", "bold_italic_underline", 4);
    sizeMap.put(Point(3, 7), "Arial", "normal", 5);
    sizeMap.put(Point(3, 7), "Arial", "bold", 5);
    sizeMap.put(Point(3, 7), "Arial", "bold_underline", 5);
    sizeMap.put(Point(3, 7), "Arial", "italic", 5);
    sizeMap.put(Point(3, 7), "Arial", "italic_underline", 5);
    sizeMap.put(Point(3, 7), "Arial", "bold_italic", 5);
    sizeMap.put(Point(3, 7), "Arial", "bold_italic_underline", 5);
    sizeMap.put(Point(4, 8), "Arial", "normal", 6);
    sizeMap.put(Point(4, 8), "Arial", "bold", 6);
    sizeMap.put(Point(4, 8), "Arial", "bold_underline", 6);
    sizeMap.put(Point(4, 8), "Arial", "italic", 6);
    sizeMap.put(Point(4, 8), "Arial", "italic_underline", 6);
    sizeMap.put(Point(4, 8), "Arial", "bold_italic", 6);
    sizeMap.put(Point(4, 8), "Arial", "bold_italic_underline", 6);
    sizeMap.put(Point(5, 10), "Arial", "normal", 7);
    sizeMap.put(Point(5, 10), "Arial", "bold", 7);
    sizeMap.put(Point(5, 10), "Arial", "bold_underline", 7);
    sizeMap.put(Point(5, 10), "Arial", "italic", 7);
    sizeMap.put(Point(5, 10), "Arial", "italic_underline", 7);
    sizeMap.put(Point(5, 10), "Arial", "bold_italic", 7);
    sizeMap.put(Point(5, 10), "Arial", "bold_italic_underline", 7);
    sizeMap.put(Point(5, 10), "Arial", "normal", 8);
    sizeMap.put(Point(5, 10), "Arial", "bold", 8);
    sizeMap.put(Point(5, 10), "Arial", "bold_underline", 8);
    sizeMap.put(Point(5, 10), "Arial", "italic", 8);
    sizeMap.put(Point(5, 10), "Arial", "italic_underline", 8);
    sizeMap.put(Point(5, 10), "Arial", "bold_italic", 8);
    sizeMap.put(Point(5, 10), "Arial", "bold_italic_underline", 8);
    sizeMap.put(Point(6, 12), "Arial", "normal", 9);
    sizeMap.put(Point(6, 12), "Arial", "bold", 9);
    sizeMap.put(Point(6, 12), "Arial", "bold_underline", 9);
    sizeMap.put(Point(6, 12), "Arial", "italic", 9);
    sizeMap.put(Point(6, 12), "Arial", "italic_underline", 9);
    sizeMap.put(Point(6, 12), "Arial", "bold_italic", 9);
    sizeMap.put(Point(6, 12), "Arial", "bold_italic_underline", 9);
    sizeMap.put(Point(7, 13), "Arial", "normal", 10);
    sizeMap.put(Point(7, 13), "Arial", "bold", 10);
    sizeMap.put(Point(7, 13), "Arial", "bold_underline", 10);
    sizeMap.put(Point(7, 13), "Arial", "italic", 10);
    sizeMap.put(Point(7, 13), "Arial", "italic_underline", 10);
    sizeMap.put(Point(7, 13), "Arial", "bold_italic", 10);
    sizeMap.put(Point(7, 13), "Arial", "bold_italic_underline", 10);
    sizeMap.put(Point(7, 14), "Arial", "normal", 11);
    sizeMap.put(Point(7, 14), "Arial", "bold", 11);
    sizeMap.put(Point(7, 14), "Arial", "bold_underline", 11);
    sizeMap.put(Point(7, 14), "Arial", "italic", 11);
    sizeMap.put(Point(7, 14), "Arial", "italic_underline", 11);
    sizeMap.put(Point(7, 14), "Arial", "bold_italic", 11);
    sizeMap.put(Point(7, 14), "Arial", "bold_italic_underline", 11);
    sizeMap.put(Point(8, 15), "Arial", "normal", 12);
    sizeMap.put(Point(8, 15), "Arial", "bold", 12);
    sizeMap.put(Point(8, 15), "Arial", "bold_underline", 12);
    sizeMap.put(Point(8, 15), "Arial", "italic", 12);
    sizeMap.put(Point(8, 15), "Arial", "italic_underline", 12);
    sizeMap.put(Point(8, 15), "Arial", "bold_italic", 12);
    sizeMap.put(Point(8, 15), "Arial", "bold_italic_underline", 12);
    sizeMap.put(Point(9, 17), "Arial", "normal", 13);
    sizeMap.put(Point(9, 17), "Arial", "bold", 13);
    sizeMap.put(Point(9, 17), "Arial", "bold_underline", 13);
    sizeMap.put(Point(9, 17), "Arial", "italic", 13);
    sizeMap.put(Point(9, 17), "Arial", "italic_underline", 13);
    sizeMap.put(Point(9, 17), "Arial", "bold_italic", 13);
    sizeMap.put(Point(9, 17), "Arial", "bold_italic_underline", 13);
    sizeMap.put(Point(9, 18), "Arial", "normal", 14);
    sizeMap.put(Point(9, 18), "Arial", "bold", 14);
    sizeMap.put(Point(9, 18), "Arial", "bold_underline", 14);
    sizeMap.put(Point(9, 18), "Arial", "italic", 14);
    sizeMap.put(Point(9, 18), "Arial", "italic_underline", 14);
    sizeMap.put(Point(9, 18), "Arial", "bold_italic", 14);
    sizeMap.put(Point(9, 18), "Arial", "bold_italic_underline", 14);
    sizeMap.put(Point(10, 19), "Arial", "normal", 15);
    sizeMap.put(Point(10, 19), "Arial", "bold", 15);
    sizeMap.put(Point(10, 19), "Arial", "bold_underline", 15);
    sizeMap.put(Point(10, 19), "Arial", "italic", 15);
    sizeMap.put(Point(10, 19), "Arial", "italic_underline", 15);
    sizeMap.put(Point(10, 19), "Arial", "bold_italic", 15);
    sizeMap.put(Point(10, 19), "Arial", "bold_italic_underline", 15);
    sizeMap.put(Point(11, 20), "Arial", "normal", 16);
    sizeMap.put(Point(11, 20), "Arial", "bold", 16);
    sizeMap.put(Point(11, 20), "Arial", "bold_underline", 16);
    sizeMap.put(Point(11, 20), "Arial", "italic", 16);
    sizeMap.put(Point(11, 20), "Arial", "italic_underline", 16);
    sizeMap.put(Point(11, 20), "Arial", "bold_italic", 16);
    sizeMap.put(Point(11, 20), "Arial", "bold_italic_underline", 16);
    sizeMap.put(Point(11, 21), "Arial", "normal", 17);
    sizeMap.put(Point(11, 21), "Arial", "bold", 17);
    sizeMap.put(Point(11, 21), "Arial", "bold_underline", 17);
    sizeMap.put(Point(11, 21), "Arial", "italic", 17);
    sizeMap.put(Point(11, 21), "Arial", "italic_underline", 17);
    sizeMap.put(Point(11, 21), "Arial", "bold_italic", 17);
    sizeMap.put(Point(11, 21), "Arial", "bold_italic_underline", 17);
    sizeMap.put(Point(12, 23), "Arial", "normal", 18);
    sizeMap.put(Point(12, 23), "Arial", "bold", 18);
    sizeMap.put(Point(12, 23), "Arial", "bold_underline", 18);
    sizeMap.put(Point(12, 23), "Arial", "italic", 18);
    sizeMap.put(Point(12, 23), "Arial", "italic_underline", 18);
    sizeMap.put(Point(12, 23), "Arial", "bold_italic", 18);
    sizeMap.put(Point(12, 23), "Arial", "bold_italic_underline", 18);
    sizeMap.put(Point(13, 23), "Arial", "normal", 19);
    sizeMap.put(Point(13, 23), "Arial", "bold", 19);
    sizeMap.put(Point(13, 23), "Arial", "bold_underline", 19);
    sizeMap.put(Point(13, 23), "Arial", "italic", 19);
    sizeMap.put(Point(13, 23), "Arial", "italic_underline", 19);
    sizeMap.put(Point(13, 23), "Arial", "bold_italic", 19);
    sizeMap.put(Point(13, 23), "Arial", "bold_italic_underline", 19);
    sizeMap.put(Point(13, 25), "Arial", "normal", 20);
    sizeMap.put(Point(13, 25), "Arial", "bold", 20);
    sizeMap.put(Point(13, 25), "Arial", "bold_underline", 20);
    sizeMap.put(Point(13, 25), "Arial", "italic", 20);
    sizeMap.put(Point(13, 25), "Arial", "italic_underline", 20);
    sizeMap.put(Point(13, 25), "Arial", "bold_italic", 20);
    sizeMap.put(Point(13, 25), "Arial", "bold_italic_underline", 20);
    sizeMap.put(Point(14, 26), "Arial", "normal", 21);
    sizeMap.put(Point(14, 26), "Arial", "bold", 21);
    sizeMap.put(Point(14, 26), "Arial", "bold_underline", 21);
    sizeMap.put(Point(14, 26), "Arial", "italic", 21);
    sizeMap.put(Point(14, 26), "Arial", "italic_underline", 21);
    sizeMap.put(Point(14, 26), "Arial", "bold_italic", 21);
    sizeMap.put(Point(14, 26), "Arial", "bold_italic_underline", 21);
    sizeMap.put(Point(15, 27), "Arial", "normal", 22);
    sizeMap.put(Point(15, 27), "Arial", "bold", 22);
    sizeMap.put(Point(15, 27), "Arial", "bold_underline", 22);
    sizeMap.put(Point(15, 27), "Arial", "italic", 22);
    sizeMap.put(Point(15, 27), "Arial", "italic_underline", 22);
    sizeMap.put(Point(15, 27), "Arial", "bold_italic", 22);
    sizeMap.put(Point(15, 27), "Arial", "bold_italic_underline", 22);
    sizeMap.put(Point(15, 28), "Arial", "normal", 23);
    sizeMap.put(Point(15, 28), "Arial", "bold", 23);
    sizeMap.put(Point(15, 28), "Arial", "bold_underline", 23);
    sizeMap.put(Point(15, 28), "Arial", "italic", 23);
    sizeMap.put(Point(15, 28), "Arial", "italic_underline", 23);
    sizeMap.put(Point(15, 28), "Arial", "bold_italic", 23);
    sizeMap.put(Point(15, 28), "Arial", "bold_italic_underline", 23);
    sizeMap.put(Point(16, 30), "Arial", "normal", 24);
    sizeMap.put(Point(16, 30), "Arial", "bold", 24);
    sizeMap.put(Point(16, 30), "Arial", "bold_underline", 24);
    sizeMap.put(Point(16, 30), "Arial", "italic", 24);
    sizeMap.put(Point(16, 30), "Arial", "italic_underline", 24);
    sizeMap.put(Point(16, 30), "Arial", "bold_italic", 24);
    sizeMap.put(Point(16, 30), "Arial", "bold_italic_underline", 24);
    sizeMap.put(Point(17, 31), "Arial", "normal", 25);
    sizeMap.put(Point(17, 31), "Arial", "bold", 25);
    sizeMap.put(Point(17, 31), "Arial", "bold_underline", 25);
    sizeMap.put(Point(17, 31), "Arial", "italic", 25);
    sizeMap.put(Point(17, 31), "Arial", "italic_underline", 25);
    sizeMap.put(Point(17, 31), "Arial", "bold_italic", 25);
    sizeMap.put(Point(17, 31), "Arial", "bold_italic_underline", 25);
    sizeMap.put(Point(17, 32), "Arial", "normal", 26);
    sizeMap.put(Point(17, 32), "Arial", "bold", 26);
    sizeMap.put(Point(17, 32), "Arial", "bold_underline", 26);
    sizeMap.put(Point(17, 32), "Arial", "italic", 26);
    sizeMap.put(Point(17, 32), "Arial", "italic_underline", 26);
    sizeMap.put(Point(17, 32), "Arial", "bold_italic", 26);
    sizeMap.put(Point(17, 32), "Arial", "bold_italic_underline", 26);
    sizeMap.put(Point(18, 33), "Arial", "normal", 27);
    sizeMap.put(Point(18, 33), "Arial", "bold", 27);
    sizeMap.put(Point(18, 33), "Arial", "bold_underline", 27);
    sizeMap.put(Point(18, 33), "Arial", "italic", 27);
    sizeMap.put(Point(18, 33), "Arial", "italic_underline", 27);
    sizeMap.put(Point(18, 33), "Arial", "bold_italic", 27);
    sizeMap.put(Point(18, 33), "Arial", "bold_italic_underline", 27);
    sizeMap.put(Point(19, 35), "Arial", "normal", 28);
    sizeMap.put(Point(19, 35), "Arial", "bold", 28);
    sizeMap.put(Point(19, 35), "Arial", "bold_underline", 28);
    sizeMap.put(Point(19, 35), "Arial", "italic", 28);
    sizeMap.put(Point(19, 35), "Arial", "italic_underline", 28);
    sizeMap.put(Point(19, 35), "Arial", "bold_italic", 28);
    sizeMap.put(Point(19, 35), "Arial", "bold_italic_underline", 28);
    sizeMap.put(Point(19, 36), "Arial", "normal", 29);
    sizeMap.put(Point(19, 36), "Arial", "bold", 29);
    sizeMap.put(Point(19, 36), "Arial", "bold_underline", 29);
    sizeMap.put(Point(19, 36), "Arial", "italic", 29);
    sizeMap.put(Point(19, 36), "Arial", "italic_underline", 29);
    sizeMap.put(Point(19, 36), "Arial", "bold_italic", 29);
    sizeMap.put(Point(19, 36), "Arial", "bold_italic_underline", 29);
    sizeMap.put(Point(20, 37), "Arial", "normal", 30);
    sizeMap.put(Point(20, 37), "Arial", "bold", 30);
    sizeMap.put(Point(20, 37), "Arial", "bold_underline", 30);
    sizeMap.put(Point(20, 37), "Arial", "italic", 30);
    sizeMap.put(Point(20, 37), "Arial", "italic_underline", 30);
    sizeMap.put(Point(20, 37), "Arial", "bold_italic", 30);
    sizeMap.put(Point(20, 37), "Arial", "bold_italic_underline", 30);
    sizeMap.put(Point(21, 38), "Arial", "normal", 31);
    sizeMap.put(Point(21, 38), "Arial", "bold", 31);
    sizeMap.put(Point(21, 38), "Arial", "bold_underline", 31);
    sizeMap.put(Point(21, 38), "Arial", "italic", 31);
    sizeMap.put(Point(21, 38), "Arial", "italic_underline", 31);
    sizeMap.put(Point(21, 38), "Arial", "bold_italic", 31);
    sizeMap.put(Point(21, 38), "Arial", "bold_italic_underline", 31);
    sizeMap.put(Point(2, 6), "Liberation Mono", "normal", 4);
    sizeMap.put(Point(2, 6), "Liberation Mono", "bold", 4);
    sizeMap.put(Point(2, 6), "Liberation Mono", "bold_underline", 4);
    sizeMap.put(Point(2, 6), "Liberation Mono", "italic", 4);
    sizeMap.put(Point(2, 6), "Liberation Mono", "italic_underline", 4);
    sizeMap.put(Point(2, 6), "Liberation Mono", "bold_italic", 4);
    sizeMap.put(Point(2, 6), "Liberation Mono", "bold_italic_underline", 4);
    sizeMap.put(Point(3, 7), "Liberation Mono", "normal", 5);
    sizeMap.put(Point(3, 7), "Liberation Mono", "bold", 5);
    sizeMap.put(Point(3, 7), "Liberation Mono", "bold_underline", 5);
    sizeMap.put(Point(3, 7), "Liberation Mono", "italic", 5);
    sizeMap.put(Point(3, 7), "Liberation Mono", "italic_underline", 5);
    sizeMap.put(Point(3, 7), "Liberation Mono", "bold_italic", 5);
    sizeMap.put(Point(3, 7), "Liberation Mono", "bold_italic_underline", 5);
    sizeMap.put(Point(4, 7), "Liberation Mono", "normal", 6);
    sizeMap.put(Point(4, 7), "Liberation Mono", "bold", 6);
    sizeMap.put(Point(4, 7), "Liberation Mono", "bold_underline", 6);
    sizeMap.put(Point(4, 7), "Liberation Mono", "italic", 6);
    sizeMap.put(Point(4, 7), "Liberation Mono", "italic_underline", 6);
    sizeMap.put(Point(4, 7), "Liberation Mono", "bold_italic", 6);
    sizeMap.put(Point(4, 7), "Liberation Mono", "bold_italic_underline", 6);
    sizeMap.put(Point(4, 9), "Liberation Mono", "normal", 7);
    sizeMap.put(Point(4, 9), "Liberation Mono", "bold", 7);
    sizeMap.put(Point(4, 9), "Liberation Mono", "bold_underline", 7);
    sizeMap.put(Point(4, 9), "Liberation Mono", "italic", 7);
    sizeMap.put(Point(4, 9), "Liberation Mono", "italic_underline", 7);
    sizeMap.put(Point(4, 9), "Liberation Mono", "bold_italic", 7);
    sizeMap.put(Point(4, 9), "Liberation Mono", "bold_italic_underline", 7);
    sizeMap.put(Point(5, 10), "Liberation Mono", "normal", 8);
    sizeMap.put(Point(5, 10), "Liberation Mono", "bold", 8);
    sizeMap.put(Point(5, 10), "Liberation Mono", "bold_underline", 8);
    sizeMap.put(Point(5, 10), "Liberation Mono", "italic", 8);
    sizeMap.put(Point(5, 10), "Liberation Mono", "italic_underline", 8);
    sizeMap.put(Point(5, 10), "Liberation Mono", "bold_italic", 8);
    sizeMap.put(Point(5, 10), "Liberation Mono", "bold_italic_underline", 8);
    sizeMap.put(Point(5, 11), "Liberation Mono", "normal", 9);
    sizeMap.put(Point(5, 11), "Liberation Mono", "bold", 9);
    sizeMap.put(Point(5, 11), "Liberation Mono", "bold_underline", 9);
    sizeMap.put(Point(5, 11), "Liberation Mono", "italic", 9);
    sizeMap.put(Point(5, 11), "Liberation Mono", "italic_underline", 9);
    sizeMap.put(Point(5, 11), "Liberation Mono", "bold_italic", 9);
    sizeMap.put(Point(5, 11), "Liberation Mono", "bold_italic_underline", 9);
    sizeMap.put(Point(6, 12), "Liberation Mono", "normal", 10);
    sizeMap.put(Point(6, 12), "Liberation Mono", "bold", 10);
    sizeMap.put(Point(6, 12), "Liberation Mono", "bold_underline", 10);
    sizeMap.put(Point(6, 12), "Liberation Mono", "italic", 10);
    sizeMap.put(Point(6, 12), "Liberation Mono", "italic_underline", 10);
    sizeMap.put(Point(6, 12), "Liberation Mono", "bold_italic", 10);
    sizeMap.put(Point(6, 12), "Liberation Mono", "bold_italic_underline", 10);
    sizeMap.put(Point(7, 14), "Liberation Mono", "normal", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold_underline", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "italic", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "italic_underline", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold_italic", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold_italic_underline", 11);
    sizeMap.put(Point(7, 14), "Liberation Mono", "normal", 12);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold", 12);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold_underline", 12);
    sizeMap.put(Point(7, 14), "Liberation Mono", "italic", 12);
    sizeMap.put(Point(7, 14), "Liberation Mono", "italic_underline", 12);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold_italic", 12);
    sizeMap.put(Point(7, 14), "Liberation Mono", "bold_italic_underline", 12);
    sizeMap.put(Point(8, 15), "Liberation Mono", "normal", 13);
    sizeMap.put(Point(8, 15), "Liberation Mono", "bold", 13);
    sizeMap.put(Point(8, 15), "Liberation Mono", "bold_underline", 13);
    sizeMap.put(Point(8, 15), "Liberation Mono", "italic", 13);
    sizeMap.put(Point(8, 15), "Liberation Mono", "italic_underline", 13);
    sizeMap.put(Point(8, 15), "Liberation Mono", "bold_italic", 13);
    sizeMap.put(Point(8, 15), "Liberation Mono", "bold_italic_underline", 13);
    sizeMap.put(Point(8, 17), "Liberation Mono", "normal", 14);
    sizeMap.put(Point(8, 17), "Liberation Mono", "bold", 14);
    sizeMap.put(Point(8, 17), "Liberation Mono", "bold_underline", 14);
    sizeMap.put(Point(8, 17), "Liberation Mono", "italic", 14);
    sizeMap.put(Point(8, 17), "Liberation Mono", "italic_underline", 14);
    sizeMap.put(Point(8, 17), "Liberation Mono", "bold_italic", 14);
    sizeMap.put(Point(8, 17), "Liberation Mono", "bold_italic_underline", 14);
    sizeMap.put(Point(9, 18), "Liberation Mono", "normal", 15);
    sizeMap.put(Point(9, 18), "Liberation Mono", "bold", 15);
    sizeMap.put(Point(9, 18), "Liberation Mono", "bold_underline", 15);
    sizeMap.put(Point(9, 18), "Liberation Mono", "italic", 15);
    sizeMap.put(Point(9, 18), "Liberation Mono", "italic_underline", 15);
    sizeMap.put(Point(9, 18), "Liberation Mono", "bold_italic", 15);
    sizeMap.put(Point(9, 18), "Liberation Mono", "bold_italic_underline", 15);
    sizeMap.put(Point(10, 19), "Liberation Mono", "normal", 16);
    sizeMap.put(Point(10, 19), "Liberation Mono", "bold", 16);
    sizeMap.put(Point(10, 19), "Liberation Mono", "bold_underline", 16);
    sizeMap.put(Point(10, 19), "Liberation Mono", "italic", 16);
    sizeMap.put(Point(10, 19), "Liberation Mono", "italic_underline", 16);
    sizeMap.put(Point(10, 19), "Liberation Mono", "bold_italic", 16);
    sizeMap.put(Point(10, 19), "Liberation Mono", "bold_italic_underline", 16);
    sizeMap.put(Point(10, 21), "Liberation Mono", "normal", 17);
    sizeMap.put(Point(10, 21), "Liberation Mono", "bold", 17);
    sizeMap.put(Point(10, 21), "Liberation Mono", "bold_underline", 17);
    sizeMap.put(Point(10, 21), "Liberation Mono", "italic", 17);
    sizeMap.put(Point(10, 21), "Liberation Mono", "italic_underline", 17);
    sizeMap.put(Point(10, 21), "Liberation Mono", "bold_italic", 17);
    sizeMap.put(Point(10, 21), "Liberation Mono", "bold_italic_underline", 17);
    sizeMap.put(Point(11, 21), "Liberation Mono", "normal", 18);
    sizeMap.put(Point(11, 21), "Liberation Mono", "bold", 18);
    sizeMap.put(Point(11, 21), "Liberation Mono", "bold_underline", 18);
    sizeMap.put(Point(11, 21), "Liberation Mono", "italic", 18);
    sizeMap.put(Point(11, 21), "Liberation Mono", "italic_underline", 18);
    sizeMap.put(Point(11, 21), "Liberation Mono", "bold_italic", 18);
    sizeMap.put(Point(11, 21), "Liberation Mono", "bold_italic_underline", 18);
    sizeMap.put(Point(11, 22), "Liberation Mono", "normal", 19);
    sizeMap.put(Point(11, 22), "Liberation Mono", "bold", 19);
    sizeMap.put(Point(11, 22), "Liberation Mono", "bold_underline", 19);
    sizeMap.put(Point(11, 22), "Liberation Mono", "italic", 19);
    sizeMap.put(Point(11, 22), "Liberation Mono", "italic_underline", 19);
    sizeMap.put(Point(11, 22), "Liberation Mono", "bold_italic", 19);
    sizeMap.put(Point(11, 22), "Liberation Mono", "bold_italic_underline", 19);
    sizeMap.put(Point(12, 23), "Liberation Mono", "normal", 20);
    sizeMap.put(Point(12, 23), "Liberation Mono", "bold", 20);
    sizeMap.put(Point(12, 23), "Liberation Mono", "bold_underline", 20);
    sizeMap.put(Point(12, 23), "Liberation Mono", "italic", 20);
    sizeMap.put(Point(12, 23), "Liberation Mono", "italic_underline", 20);
    sizeMap.put(Point(12, 23), "Liberation Mono", "bold_italic", 20);
    sizeMap.put(Point(12, 23), "Liberation Mono", "bold_italic_underline", 20);
    sizeMap.put(Point(13, 25), "Liberation Mono", "normal", 21);
    sizeMap.put(Point(13, 25), "Liberation Mono", "bold", 21);
    sizeMap.put(Point(13, 25), "Liberation Mono", "bold_underline", 21);
    sizeMap.put(Point(13, 25), "Liberation Mono", "italic", 21);
    sizeMap.put(Point(13, 25), "Liberation Mono", "italic_underline", 21);
    sizeMap.put(Point(13, 25), "Liberation Mono", "bold_italic", 21);
    sizeMap.put(Point(13, 25), "Liberation Mono", "bold_italic_underline", 21);
    sizeMap.put(Point(13, 26), "Liberation Mono", "normal", 22);
    sizeMap.put(Point(13, 26), "Liberation Mono", "bold", 22);
    sizeMap.put(Point(13, 26), "Liberation Mono", "bold_underline", 22);
    sizeMap.put(Point(13, 26), "Liberation Mono", "italic", 22);
    sizeMap.put(Point(13, 26), "Liberation Mono", "italic_underline", 22);
    sizeMap.put(Point(13, 26), "Liberation Mono", "bold_italic", 22);
    sizeMap.put(Point(13, 26), "Liberation Mono", "bold_italic_underline", 22);
    sizeMap.put(Point(14, 27), "Liberation Mono", "normal", 23);
    sizeMap.put(Point(14, 27), "Liberation Mono", "bold", 23);
    sizeMap.put(Point(14, 27), "Liberation Mono", "bold_underline", 23);
    sizeMap.put(Point(14, 27), "Liberation Mono", "italic", 23);
    sizeMap.put(Point(14, 27), "Liberation Mono", "italic_underline", 23);
    sizeMap.put(Point(14, 27), "Liberation Mono", "bold_italic", 23);
    sizeMap.put(Point(14, 27), "Liberation Mono", "bold_italic_underline", 23);
    sizeMap.put(Point(14, 28), "Liberation Mono", "normal", 24);
    sizeMap.put(Point(14, 28), "Liberation Mono", "bold", 24);
    sizeMap.put(Point(14, 28), "Liberation Mono", "bold_underline", 24);
    sizeMap.put(Point(14, 28), "Liberation Mono", "italic", 24);
    sizeMap.put(Point(14, 28), "Liberation Mono", "italic_underline", 24);
    sizeMap.put(Point(14, 28), "Liberation Mono", "bold_italic", 24);
    sizeMap.put(Point(14, 28), "Liberation Mono", "bold_italic_underline", 24);
    sizeMap.put(Point(15, 29), "Liberation Mono", "normal", 25);
    sizeMap.put(Point(15, 29), "Liberation Mono", "bold", 25);
    sizeMap.put(Point(15, 29), "Liberation Mono", "bold_underline", 25);
    sizeMap.put(Point(15, 29), "Liberation Mono", "italic", 25);
    sizeMap.put(Point(15, 29), "Liberation Mono", "italic_underline", 25);
    sizeMap.put(Point(15, 29), "Liberation Mono", "bold_italic", 25);
    sizeMap.put(Point(15, 29), "Liberation Mono", "bold_italic_underline", 25);
    sizeMap.put(Point(16, 30), "Liberation Mono", "normal", 26);
    sizeMap.put(Point(16, 30), "Liberation Mono", "bold", 26);
    sizeMap.put(Point(16, 30), "Liberation Mono", "bold_underline", 26);
    sizeMap.put(Point(16, 30), "Liberation Mono", "italic", 26);
    sizeMap.put(Point(16, 30), "Liberation Mono", "italic_underline", 26);
    sizeMap.put(Point(16, 30), "Liberation Mono", "bold_italic", 26);
    sizeMap.put(Point(16, 30), "Liberation Mono", "bold_italic_underline", 26);
    sizeMap.put(Point(16, 32), "Liberation Mono", "normal", 27);
    sizeMap.put(Point(16, 32), "Liberation Mono", "bold", 27);
    sizeMap.put(Point(16, 32), "Liberation Mono", "bold_underline", 27);
    sizeMap.put(Point(16, 32), "Liberation Mono", "italic", 27);
    sizeMap.put(Point(16, 32), "Liberation Mono", "italic_underline", 27);
    sizeMap.put(Point(16, 32), "Liberation Mono", "bold_italic", 27);
    sizeMap.put(Point(16, 32), "Liberation Mono", "bold_italic_underline", 27);
    sizeMap.put(Point(17, 33), "Liberation Mono", "normal", 28);
    sizeMap.put(Point(17, 33), "Liberation Mono", "bold", 28);
    sizeMap.put(Point(17, 33), "Liberation Mono", "bold_underline", 28);
    sizeMap.put(Point(17, 33), "Liberation Mono", "italic", 28);
    sizeMap.put(Point(17, 33), "Liberation Mono", "italic_underline", 28);
    sizeMap.put(Point(17, 33), "Liberation Mono", "bold_italic", 28);
    sizeMap.put(Point(17, 33), "Liberation Mono", "bold_italic_underline", 28);
    sizeMap.put(Point(17, 34), "Liberation Mono", "normal", 29);
    sizeMap.put(Point(17, 34), "Liberation Mono", "bold", 29);
    sizeMap.put(Point(17, 34), "Liberation Mono", "bold_underline", 29);
    sizeMap.put(Point(17, 34), "Liberation Mono", "italic", 29);
    sizeMap.put(Point(17, 34), "Liberation Mono", "italic_underline", 29);
    sizeMap.put(Point(17, 34), "Liberation Mono", "bold_italic", 29);
    sizeMap.put(Point(17, 34), "Liberation Mono", "bold_italic_underline", 29);
    sizeMap.put(Point(18, 34), "Liberation Mono", "normal", 30);
    sizeMap.put(Point(18, 34), "Liberation Mono", "bold", 30);
    sizeMap.put(Point(18, 34), "Liberation Mono", "bold_underline", 30);
    sizeMap.put(Point(18, 34), "Liberation Mono", "italic", 30);
    sizeMap.put(Point(18, 34), "Liberation Mono", "italic_underline", 30);
    sizeMap.put(Point(18, 34), "Liberation Mono", "bold_italic", 30);
    sizeMap.put(Point(18, 34), "Liberation Mono", "bold_italic_underline", 30);
    sizeMap.put(Point(19, 36), "Liberation Mono", "normal", 31);
    sizeMap.put(Point(19, 36), "Liberation Mono", "bold", 31);
    sizeMap.put(Point(19, 36), "Liberation Mono", "bold_underline", 31);
    sizeMap.put(Point(19, 36), "Liberation Mono", "italic", 31);
    sizeMap.put(Point(19, 36), "Liberation Mono", "italic_underline", 31);
    sizeMap.put(Point(19, 36), "Liberation Mono", "bold_italic", 31);
    sizeMap.put(Point(19, 36), "Liberation Mono", "bold_italic_underline", 31);
    sizeMap.put(Point(2, 6), "Courier", "normal", 4);
    sizeMap.put(Point(2, 6), "Courier", "bold", 4);
    sizeMap.put(Point(2, 6), "Courier", "bold_underline", 4);
    sizeMap.put(Point(2, 6), "Courier", "italic", 4);
    sizeMap.put(Point(2, 6), "Courier", "italic_underline", 4);
    sizeMap.put(Point(2, 6), "Courier", "bold_italic", 4);
    sizeMap.put(Point(2, 6), "Courier", "bold_italic_underline", 4);
    sizeMap.put(Point(3, 6), "Courier", "normal", 5);
    sizeMap.put(Point(3, 6), "Courier", "bold", 5);
    sizeMap.put(Point(3, 6), "Courier", "bold_underline", 5);
    sizeMap.put(Point(3, 6), "Courier", "italic", 5);
    sizeMap.put(Point(3, 6), "Courier", "italic_underline", 5);
    sizeMap.put(Point(3, 6), "Courier", "bold_italic", 5);
    sizeMap.put(Point(3, 6), "Courier", "bold_italic_underline", 5);
    sizeMap.put(Point(4, 8), "Courier", "normal", 6);
    sizeMap.put(Point(4, 8), "Courier", "bold", 6);
    sizeMap.put(Point(4, 8), "Courier", "bold_underline", 6);
    sizeMap.put(Point(4, 8), "Courier", "italic", 6);
    sizeMap.put(Point(4, 8), "Courier", "italic_underline", 6);
    sizeMap.put(Point(4, 8), "Courier", "bold_italic", 6);
    sizeMap.put(Point(4, 8), "Courier", "bold_italic_underline", 6);
    sizeMap.put(Point(4, 10), "Courier", "normal", 7);
    sizeMap.put(Point(4, 10), "Courier", "bold", 7);
    sizeMap.put(Point(4, 10), "Courier", "bold_underline", 7);
    sizeMap.put(Point(4, 10), "Courier", "italic", 7);
    sizeMap.put(Point(4, 10), "Courier", "italic_underline", 7);
    sizeMap.put(Point(4, 10), "Courier", "bold_italic", 7);
    sizeMap.put(Point(4, 10), "Courier", "bold_italic_underline", 7);
    sizeMap.put(Point(5, 10), "Courier", "normal", 8);
    sizeMap.put(Point(5, 10), "Courier", "bold", 8);
    sizeMap.put(Point(5, 10), "Courier", "bold_underline", 8);
    sizeMap.put(Point(5, 10), "Courier", "italic", 8);
    sizeMap.put(Point(5, 10), "Courier", "italic_underline", 8);
    sizeMap.put(Point(5, 10), "Courier", "bold_italic", 8);
    sizeMap.put(Point(5, 10), "Courier", "bold_italic_underline", 8);
    sizeMap.put(Point(5, 12), "Courier", "normal", 9);
    sizeMap.put(Point(5, 12), "Courier", "bold", 9);
    sizeMap.put(Point(5, 12), "Courier", "bold_underline", 9);
    sizeMap.put(Point(5, 12), "Courier", "italic", 9);
    sizeMap.put(Point(5, 12), "Courier", "italic_underline", 9);
    sizeMap.put(Point(5, 12), "Courier", "bold_italic", 9);
    sizeMap.put(Point(5, 12), "Courier", "bold_italic_underline", 9);
    sizeMap.put(Point(6, 12), "Courier", "normal", 10);
    sizeMap.put(Point(6, 12), "Courier", "bold", 10);
    sizeMap.put(Point(6, 12), "Courier", "bold_underline", 10);
    sizeMap.put(Point(6, 12), "Courier", "italic", 10);
    sizeMap.put(Point(6, 12), "Courier", "italic_underline", 10);
    sizeMap.put(Point(6, 12), "Courier", "bold_italic", 10);
    sizeMap.put(Point(6, 12), "Courier", "bold_italic_underline", 10);
    sizeMap.put(Point(7, 14), "Courier", "normal", 11);
    sizeMap.put(Point(7, 14), "Courier", "bold", 11);
    sizeMap.put(Point(7, 14), "Courier", "bold_underline", 11);
    sizeMap.put(Point(7, 14), "Courier", "italic", 11);
    sizeMap.put(Point(7, 14), "Courier", "italic_underline", 11);
    sizeMap.put(Point(7, 14), "Courier", "bold_italic", 11);
    sizeMap.put(Point(7, 14), "Courier", "bold_italic_underline", 11);
    sizeMap.put(Point(7, 16), "Courier", "normal", 12);
    sizeMap.put(Point(7, 16), "Courier", "bold", 12);
    sizeMap.put(Point(7, 16), "Courier", "bold_underline", 12);
    sizeMap.put(Point(7, 16), "Courier", "italic", 12);
    sizeMap.put(Point(7, 16), "Courier", "italic_underline", 12);
    sizeMap.put(Point(7, 16), "Courier", "bold_italic", 12);
    sizeMap.put(Point(7, 16), "Courier", "bold_italic_underline", 12);
    sizeMap.put(Point(8, 16), "Courier", "normal", 13);
    sizeMap.put(Point(8, 16), "Courier", "bold", 13);
    sizeMap.put(Point(8, 16), "Courier", "bold_underline", 13);
    sizeMap.put(Point(8, 16), "Courier", "italic", 13);
    sizeMap.put(Point(8, 16), "Courier", "italic_underline", 13);
    sizeMap.put(Point(8, 16), "Courier", "bold_italic", 13);
    sizeMap.put(Point(8, 16), "Courier", "bold_italic_underline", 13);
    sizeMap.put(Point(8, 18), "Courier", "normal", 14);
    sizeMap.put(Point(8, 18), "Courier", "bold", 14);
    sizeMap.put(Point(8, 18), "Courier", "bold_underline", 14);
    sizeMap.put(Point(8, 18), "Courier", "italic", 14);
    sizeMap.put(Point(8, 18), "Courier", "italic_underline", 14);
    sizeMap.put(Point(8, 18), "Courier", "bold_italic", 14);
    sizeMap.put(Point(8, 18), "Courier", "bold_italic_underline", 14);
    sizeMap.put(Point(9, 18), "Courier", "normal", 15);
    sizeMap.put(Point(9, 18), "Courier", "bold", 15);
    sizeMap.put(Point(9, 18), "Courier", "bold_underline", 15);
    sizeMap.put(Point(9, 18), "Courier", "italic", 15);
    sizeMap.put(Point(9, 18), "Courier", "italic_underline", 15);
    sizeMap.put(Point(9, 18), "Courier", "bold_italic", 15);
    sizeMap.put(Point(9, 18), "Courier", "bold_italic_underline", 15);
    sizeMap.put(Point(10, 20), "Courier", "normal", 16);
    sizeMap.put(Point(10, 20), "Courier", "bold", 16);
    sizeMap.put(Point(10, 20), "Courier", "bold_underline", 16);
    sizeMap.put(Point(10, 20), "Courier", "italic", 16);
    sizeMap.put(Point(10, 20), "Courier", "italic_underline", 16);
    sizeMap.put(Point(10, 20), "Courier", "bold_italic", 16);
    sizeMap.put(Point(10, 20), "Courier", "bold_italic_underline", 16);
    sizeMap.put(Point(10, 22), "Courier", "normal", 17);
    sizeMap.put(Point(10, 22), "Courier", "bold", 17);
    sizeMap.put(Point(10, 22), "Courier", "bold_underline", 17);
    sizeMap.put(Point(10, 22), "Courier", "italic", 17);
    sizeMap.put(Point(10, 22), "Courier", "italic_underline", 17);
    sizeMap.put(Point(10, 22), "Courier", "bold_italic", 17);
    sizeMap.put(Point(10, 22), "Courier", "bold_italic_underline", 17);
    sizeMap.put(Point(11, 22), "Courier", "normal", 18);
    sizeMap.put(Point(11, 22), "Courier", "bold", 18);
    sizeMap.put(Point(11, 22), "Courier", "bold_underline", 18);
    sizeMap.put(Point(11, 22), "Courier", "italic", 18);
    sizeMap.put(Point(11, 22), "Courier", "italic_underline", 18);
    sizeMap.put(Point(11, 22), "Courier", "bold_italic", 18);
    sizeMap.put(Point(11, 22), "Courier", "bold_italic_underline", 18);
    sizeMap.put(Point(11, 24), "Courier", "normal", 19);
    sizeMap.put(Point(11, 24), "Courier", "bold", 19);
    sizeMap.put(Point(11, 24), "Courier", "bold_underline", 19);
    sizeMap.put(Point(11, 24), "Courier", "italic", 19);
    sizeMap.put(Point(11, 24), "Courier", "italic_underline", 19);
    sizeMap.put(Point(11, 24), "Courier", "bold_italic", 19);
    sizeMap.put(Point(11, 24), "Courier", "bold_italic_underline", 19);
    sizeMap.put(Point(12, 25), "Courier", "normal", 20);
    sizeMap.put(Point(12, 25), "Courier", "bold", 20);
    sizeMap.put(Point(12, 25), "Courier", "bold_underline", 20);
    sizeMap.put(Point(12, 25), "Courier", "italic", 20);
    sizeMap.put(Point(12, 25), "Courier", "italic_underline", 20);
    sizeMap.put(Point(12, 25), "Courier", "bold_italic", 20);
    sizeMap.put(Point(12, 25), "Courier", "bold_italic_underline", 20);
    sizeMap.put(Point(13, 26), "Courier", "normal", 21);
    sizeMap.put(Point(13, 26), "Courier", "bold", 21);
    sizeMap.put(Point(13, 26), "Courier", "bold_underline", 21);
    sizeMap.put(Point(13, 26), "Courier", "italic", 21);
    sizeMap.put(Point(13, 26), "Courier", "italic_underline", 21);
    sizeMap.put(Point(13, 26), "Courier", "bold_italic", 21);
    sizeMap.put(Point(13, 26), "Courier", "bold_italic_underline", 21);
    sizeMap.put(Point(13, 28), "Courier", "normal", 22);
    sizeMap.put(Point(13, 28), "Courier", "bold", 22);
    sizeMap.put(Point(13, 28), "Courier", "bold_underline", 22);
    sizeMap.put(Point(13, 28), "Courier", "italic", 22);
    sizeMap.put(Point(13, 28), "Courier", "italic_underline", 22);
    sizeMap.put(Point(13, 28), "Courier", "bold_italic", 22);
    sizeMap.put(Point(13, 28), "Courier", "bold_italic_underline", 22);
    sizeMap.put(Point(14, 28), "Courier", "normal", 23);
    sizeMap.put(Point(14, 28), "Courier", "bold", 23);
    sizeMap.put(Point(14, 28), "Courier", "bold_underline", 23);
    sizeMap.put(Point(14, 28), "Courier", "italic", 23);
    sizeMap.put(Point(14, 28), "Courier", "italic_underline", 23);
    sizeMap.put(Point(14, 28), "Courier", "bold_italic", 23);
    sizeMap.put(Point(14, 28), "Courier", "bold_italic_underline", 23);
    sizeMap.put(Point(14, 30), "Courier", "normal", 24);
    sizeMap.put(Point(14, 30), "Courier", "bold", 24);
    sizeMap.put(Point(14, 30), "Courier", "bold_underline", 24);
    sizeMap.put(Point(14, 30), "Courier", "italic", 24);
    sizeMap.put(Point(14, 30), "Courier", "italic_underline", 24);
    sizeMap.put(Point(14, 30), "Courier", "bold_italic", 24);
    sizeMap.put(Point(14, 30), "Courier", "bold_italic_underline", 24);
    sizeMap.put(Point(15, 31), "Courier", "normal", 25);
    sizeMap.put(Point(15, 31), "Courier", "bold", 25);
    sizeMap.put(Point(15, 31), "Courier", "bold_underline", 25);
    sizeMap.put(Point(15, 31), "Courier", "italic", 25);
    sizeMap.put(Point(15, 31), "Courier", "italic_underline", 25);
    sizeMap.put(Point(15, 31), "Courier", "bold_italic", 25);
    sizeMap.put(Point(15, 31), "Courier", "bold_italic_underline", 25);
    sizeMap.put(Point(16, 32), "Courier", "normal", 26);
    sizeMap.put(Point(16, 32), "Courier", "bold", 26);
    sizeMap.put(Point(16, 32), "Courier", "bold_underline", 26);
    sizeMap.put(Point(16, 32), "Courier", "italic", 26);
    sizeMap.put(Point(16, 32), "Courier", "italic_underline", 26);
    sizeMap.put(Point(16, 32), "Courier", "bold_italic", 26);
    sizeMap.put(Point(16, 32), "Courier", "bold_italic_underline", 26);
    sizeMap.put(Point(16, 34), "Courier", "normal", 27);
    sizeMap.put(Point(16, 34), "Courier", "bold", 27);
    sizeMap.put(Point(16, 34), "Courier", "bold_underline", 27);
    sizeMap.put(Point(16, 34), "Courier", "italic", 27);
    sizeMap.put(Point(16, 34), "Courier", "italic_underline", 27);
    sizeMap.put(Point(16, 34), "Courier", "bold_italic", 27);
    sizeMap.put(Point(16, 34), "Courier", "bold_italic_underline", 27);
    sizeMap.put(Point(17, 34), "Courier", "normal", 28);
    sizeMap.put(Point(17, 34), "Courier", "bold", 28);
    sizeMap.put(Point(17, 34), "Courier", "bold_underline", 28);
    sizeMap.put(Point(17, 34), "Courier", "italic", 28);
    sizeMap.put(Point(17, 34), "Courier", "italic_underline", 28);
    sizeMap.put(Point(17, 34), "Courier", "bold_italic", 28);
    sizeMap.put(Point(17, 34), "Courier", "bold_italic_underline", 28);
    sizeMap.put(Point(17, 36), "Courier", "normal", 29);
    sizeMap.put(Point(17, 36), "Courier", "bold", 29);
    sizeMap.put(Point(17, 36), "Courier", "bold_underline", 29);
    sizeMap.put(Point(17, 36), "Courier", "italic", 29);
    sizeMap.put(Point(17, 36), "Courier", "italic_underline", 29);
    sizeMap.put(Point(17, 36), "Courier", "bold_italic", 29);
    sizeMap.put(Point(17, 36), "Courier", "bold_italic_underline", 29);
    sizeMap.put(Point(18, 37), "Courier", "normal", 30);
    sizeMap.put(Point(18, 37), "Courier", "bold", 30);
    sizeMap.put(Point(18, 37), "Courier", "bold_underline", 30);
    sizeMap.put(Point(18, 37), "Courier", "italic", 30);
    sizeMap.put(Point(18, 37), "Courier", "italic_underline", 30);
    sizeMap.put(Point(18, 37), "Courier", "bold_italic", 30);
    sizeMap.put(Point(18, 37), "Courier", "bold_italic_underline", 30);
    sizeMap.put(Point(19, 38), "Courier", "normal", 31);
    sizeMap.put(Point(19, 38), "Courier", "bold", 31);
    sizeMap.put(Point(19, 38), "Courier", "bold_underline", 31);
    sizeMap.put(Point(19, 38), "Courier", "italic", 31);
    sizeMap.put(Point(19, 38), "Courier", "italic_underline", 31);
    sizeMap.put(Point(19, 38), "Courier", "bold_italic", 31);
    sizeMap.put(Point(19, 38), "Courier", "bold_italic_underline", 31);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "normal", 4);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "bold", 4);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "bold_underline", 4);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "italic", 4);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "italic_underline", 4);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "bold_italic", 4);
    sizeMap.put(Point(3, 5), "Comic Sans MS", "bold_italic_underline", 4);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "normal", 5);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "bold", 5);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "bold_underline", 5);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "italic", 5);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "italic_underline", 5);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "bold_italic", 5);
    sizeMap.put(Point(3, 7), "Comic Sans MS", "bold_italic_underline", 5);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "normal", 6);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "bold", 6);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "bold_underline", 6);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "italic", 6);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "italic_underline", 6);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "bold_italic", 6);
    sizeMap.put(Point(4, 8), "Comic Sans MS", "bold_italic_underline", 6);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "normal", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold_underline", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "italic", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "italic_underline", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold_italic", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold_italic_underline", 7);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "normal", 8);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold", 8);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold_underline", 8);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "italic", 8);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "italic_underline", 8);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold_italic", 8);
    sizeMap.put(Point(5, 10), "Comic Sans MS", "bold_italic_underline", 8);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "normal", 9);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "bold", 9);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "bold_underline", 9);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "italic", 9);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "italic_underline", 9);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "bold_italic", 9);
    sizeMap.put(Point(6, 12), "Comic Sans MS", "bold_italic_underline", 9);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "normal", 10);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "bold", 10);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "bold_underline", 10);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "italic", 10);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "italic_underline", 10);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "bold_italic", 10);
    sizeMap.put(Point(7, 13), "Comic Sans MS", "bold_italic_underline", 10);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "normal", 11);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "bold", 11);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "bold_underline", 11);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "italic", 11);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "italic_underline", 11);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "bold_italic", 11);
    sizeMap.put(Point(7, 14), "Comic Sans MS", "bold_italic_underline", 11);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "normal", 12);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "bold", 12);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "bold_underline", 12);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "italic", 12);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "italic_underline", 12);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "bold_italic", 12);
    sizeMap.put(Point(8, 15), "Comic Sans MS", "bold_italic_underline", 12);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "normal", 13);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "bold", 13);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "bold_underline", 13);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "italic", 13);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "italic_underline", 13);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "bold_italic", 13);
    sizeMap.put(Point(9, 17), "Comic Sans MS", "bold_italic_underline", 13);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "normal", 14);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "bold", 14);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "bold_underline", 14);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "italic", 14);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "italic_underline", 14);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "bold_italic", 14);
    sizeMap.put(Point(9, 18), "Comic Sans MS", "bold_italic_underline", 14);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "normal", 15);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "bold", 15);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "bold_underline", 15);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "italic", 15);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "italic_underline", 15);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "bold_italic", 15);
    sizeMap.put(Point(10, 19), "Comic Sans MS", "bold_italic_underline", 15);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "normal", 16);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "bold", 16);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "bold_underline", 16);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "italic", 16);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "italic_underline", 16);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "bold_italic", 16);
    sizeMap.put(Point(11, 20), "Comic Sans MS", "bold_italic_underline", 16);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "normal", 17);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "bold", 17);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "bold_underline", 17);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "italic", 17);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "italic_underline", 17);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "bold_italic", 17);
    sizeMap.put(Point(11, 21), "Comic Sans MS", "bold_italic_underline", 17);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "normal", 18);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "bold", 18);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "bold_underline", 18);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "italic", 18);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "italic_underline", 18);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "bold_italic", 18);
    sizeMap.put(Point(12, 23), "Comic Sans MS", "bold_italic_underline", 18);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "normal", 19);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "bold", 19);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "bold_underline", 19);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "italic", 19);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "italic_underline", 19);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "bold_italic", 19);
    sizeMap.put(Point(13, 23), "Comic Sans MS", "bold_italic_underline", 19);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "normal", 20);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "bold", 20);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "bold_underline", 20);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "italic", 20);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "italic_underline", 20);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "bold_italic", 20);
    sizeMap.put(Point(13, 25), "Comic Sans MS", "bold_italic_underline", 20);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "normal", 21);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "bold", 21);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "bold_underline", 21);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "italic", 21);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "italic_underline", 21);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "bold_italic", 21);
    sizeMap.put(Point(14, 26), "Comic Sans MS", "bold_italic_underline", 21);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "normal", 22);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "bold", 22);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "bold_underline", 22);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "italic", 22);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "italic_underline", 22);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "bold_italic", 22);
    sizeMap.put(Point(15, 27), "Comic Sans MS", "bold_italic_underline", 22);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "normal", 23);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "bold", 23);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "bold_underline", 23);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "italic", 23);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "italic_underline", 23);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "bold_italic", 23);
    sizeMap.put(Point(15, 28), "Comic Sans MS", "bold_italic_underline", 23);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "normal", 24);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "bold", 24);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "bold_underline", 24);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "italic", 24);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "italic_underline", 24);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "bold_italic", 24);
    sizeMap.put(Point(16, 30), "Comic Sans MS", "bold_italic_underline", 24);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "normal", 25);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "bold", 25);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "bold_underline", 25);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "italic", 25);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "italic_underline", 25);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "bold_italic", 25);
    sizeMap.put(Point(17, 31), "Comic Sans MS", "bold_italic_underline", 25);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "normal", 26);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "bold", 26);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "bold_underline", 26);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "italic", 26);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "italic_underline", 26);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "bold_italic", 26);
    sizeMap.put(Point(17, 32), "Comic Sans MS", "bold_italic_underline", 26);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "normal", 27);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "bold", 27);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "bold_underline", 27);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "italic", 27);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "italic_underline", 27);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "bold_italic", 27);
    sizeMap.put(Point(18, 33), "Comic Sans MS", "bold_italic_underline", 27);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "normal", 28);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "bold", 28);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "bold_underline", 28);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "italic", 28);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "italic_underline", 28);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "bold_italic", 28);
    sizeMap.put(Point(19, 35), "Comic Sans MS", "bold_italic_underline", 28);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "normal", 29);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "bold", 29);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "bold_underline", 29);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "italic", 29);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "italic_underline", 29);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "bold_italic", 29);
    sizeMap.put(Point(19, 36), "Comic Sans MS", "bold_italic_underline", 29);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "normal", 30);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "bold", 30);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "bold_underline", 30);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "italic", 30);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "italic_underline", 30);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "bold_italic", 30);
    sizeMap.put(Point(20, 37), "Comic Sans MS", "bold_italic_underline", 30);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "normal", 31);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "bold", 31);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "bold_underline", 31);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "italic", 31);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "italic_underline", 31);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "bold_italic", 31);
    sizeMap.put(Point(21, 38), "Comic Sans MS", "bold_italic_underline", 31);
    sizeMap.put(Point(3, 5), "Arial Black", "normal", 4);
    sizeMap.put(Point(3, 5), "Arial Black", "bold", 4);
    sizeMap.put(Point(3, 5), "Arial Black", "bold_underline", 4);
    sizeMap.put(Point(3, 5), "Arial Black", "italic", 4);
    sizeMap.put(Point(3, 5), "Arial Black", "italic_underline", 4);
    sizeMap.put(Point(3, 5), "Arial Black", "bold_italic", 4);
    sizeMap.put(Point(3, 5), "Arial Black", "bold_italic_underline", 4);
    sizeMap.put(Point(3, 7), "Arial Black", "normal", 5);
    sizeMap.put(Point(3, 7), "Arial Black", "bold", 5);
    sizeMap.put(Point(3, 7), "Arial Black", "bold_underline", 5);
    sizeMap.put(Point(3, 7), "Arial Black", "italic", 5);
    sizeMap.put(Point(3, 7), "Arial Black", "italic_underline", 5);
    sizeMap.put(Point(3, 7), "Arial Black", "bold_italic", 5);
    sizeMap.put(Point(3, 7), "Arial Black", "bold_italic_underline", 5);
    sizeMap.put(Point(4, 8), "Arial Black", "normal", 6);
    sizeMap.put(Point(4, 8), "Arial Black", "bold", 6);
    sizeMap.put(Point(4, 8), "Arial Black", "bold_underline", 6);
    sizeMap.put(Point(4, 8), "Arial Black", "italic", 6);
    sizeMap.put(Point(4, 8), "Arial Black", "italic_underline", 6);
    sizeMap.put(Point(4, 8), "Arial Black", "bold_italic", 6);
    sizeMap.put(Point(4, 8), "Arial Black", "bold_italic_underline", 6);
    sizeMap.put(Point(5, 10), "Arial Black", "normal", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "bold", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "bold_underline", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "italic", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "italic_underline", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "bold_italic", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "bold_italic_underline", 7);
    sizeMap.put(Point(5, 10), "Arial Black", "normal", 8);
    sizeMap.put(Point(5, 10), "Arial Black", "bold", 8);
    sizeMap.put(Point(5, 10), "Arial Black", "bold_underline", 8);
    sizeMap.put(Point(5, 10), "Arial Black", "italic", 8);
    sizeMap.put(Point(5, 10), "Arial Black", "italic_underline", 8);
    sizeMap.put(Point(5, 10), "Arial Black", "bold_italic", 8);
    sizeMap.put(Point(5, 10), "Arial Black", "bold_italic_underline", 8);
    sizeMap.put(Point(6, 12), "Arial Black", "normal", 9);
    sizeMap.put(Point(6, 12), "Arial Black", "bold", 9);
    sizeMap.put(Point(6, 12), "Arial Black", "bold_underline", 9);
    sizeMap.put(Point(6, 12), "Arial Black", "italic", 9);
    sizeMap.put(Point(6, 12), "Arial Black", "italic_underline", 9);
    sizeMap.put(Point(6, 12), "Arial Black", "bold_italic", 9);
    sizeMap.put(Point(6, 12), "Arial Black", "bold_italic_underline", 9);
    sizeMap.put(Point(7, 13), "Arial Black", "normal", 10);
    sizeMap.put(Point(7, 13), "Arial Black", "bold", 10);
    sizeMap.put(Point(7, 13), "Arial Black", "bold_underline", 10);
    sizeMap.put(Point(7, 13), "Arial Black", "italic", 10);
    sizeMap.put(Point(7, 13), "Arial Black", "italic_underline", 10);
    sizeMap.put(Point(7, 13), "Arial Black", "bold_italic", 10);
    sizeMap.put(Point(7, 13), "Arial Black", "bold_italic_underline", 10);
    sizeMap.put(Point(7, 14), "Arial Black", "normal", 11);
    sizeMap.put(Point(7, 14), "Arial Black", "bold", 11);
    sizeMap.put(Point(7, 14), "Arial Black", "bold_underline", 11);
    sizeMap.put(Point(7, 14), "Arial Black", "italic", 11);
    sizeMap.put(Point(7, 14), "Arial Black", "italic_underline", 11);
    sizeMap.put(Point(7, 14), "Arial Black", "bold_italic", 11);
    sizeMap.put(Point(7, 14), "Arial Black", "bold_italic_underline", 11);
    sizeMap.put(Point(8, 15), "Arial Black", "normal", 12);
    sizeMap.put(Point(8, 15), "Arial Black", "bold", 12);
    sizeMap.put(Point(8, 15), "Arial Black", "bold_underline", 12);
    sizeMap.put(Point(8, 15), "Arial Black", "italic", 12);
    sizeMap.put(Point(8, 15), "Arial Black", "italic_underline", 12);
    sizeMap.put(Point(8, 15), "Arial Black", "bold_italic", 12);
    sizeMap.put(Point(8, 15), "Arial Black", "bold_italic_underline", 12);
    sizeMap.put(Point(9, 17), "Arial Black", "normal", 13);
    sizeMap.put(Point(9, 17), "Arial Black", "bold", 13);
    sizeMap.put(Point(9, 17), "Arial Black", "bold_underline", 13);
    sizeMap.put(Point(9, 17), "Arial Black", "italic", 13);
    sizeMap.put(Point(9, 17), "Arial Black", "italic_underline", 13);
    sizeMap.put(Point(9, 17), "Arial Black", "bold_italic", 13);
    sizeMap.put(Point(9, 17), "Arial Black", "bold_italic_underline", 13);
    sizeMap.put(Point(9, 18), "Arial Black", "normal", 14);
    sizeMap.put(Point(9, 18), "Arial Black", "bold", 14);
    sizeMap.put(Point(9, 18), "Arial Black", "bold_underline", 14);
    sizeMap.put(Point(9, 18), "Arial Black", "italic", 14);
    sizeMap.put(Point(9, 18), "Arial Black", "italic_underline", 14);
    sizeMap.put(Point(9, 18), "Arial Black", "bold_italic", 14);
    sizeMap.put(Point(9, 18), "Arial Black", "bold_italic_underline", 14);
    sizeMap.put(Point(10, 19), "Arial Black", "normal", 15);
    sizeMap.put(Point(10, 19), "Arial Black", "bold", 15);
    sizeMap.put(Point(10, 19), "Arial Black", "bold_underline", 15);
    sizeMap.put(Point(10, 19), "Arial Black", "italic", 15);
    sizeMap.put(Point(10, 19), "Arial Black", "italic_underline", 15);
    sizeMap.put(Point(10, 19), "Arial Black", "bold_italic", 15);
    sizeMap.put(Point(10, 19), "Arial Black", "bold_italic_underline", 15);
    sizeMap.put(Point(11, 20), "Arial Black", "normal", 16);
    sizeMap.put(Point(11, 20), "Arial Black", "bold", 16);
    sizeMap.put(Point(11, 20), "Arial Black", "bold_underline", 16);
    sizeMap.put(Point(11, 20), "Arial Black", "italic", 16);
    sizeMap.put(Point(11, 20), "Arial Black", "italic_underline", 16);
    sizeMap.put(Point(11, 20), "Arial Black", "bold_italic", 16);
    sizeMap.put(Point(11, 20), "Arial Black", "bold_italic_underline", 16);
    sizeMap.put(Point(11, 21), "Arial Black", "normal", 17);
    sizeMap.put(Point(11, 21), "Arial Black", "bold", 17);
    sizeMap.put(Point(11, 21), "Arial Black", "bold_underline", 17);
    sizeMap.put(Point(11, 21), "Arial Black", "italic", 17);
    sizeMap.put(Point(11, 21), "Arial Black", "italic_underline", 17);
    sizeMap.put(Point(11, 21), "Arial Black", "bold_italic", 17);
    sizeMap.put(Point(11, 21), "Arial Black", "bold_italic_underline", 17);
    sizeMap.put(Point(12, 23), "Arial Black", "normal", 18);
    sizeMap.put(Point(12, 23), "Arial Black", "bold", 18);
    sizeMap.put(Point(12, 23), "Arial Black", "bold_underline", 18);
    sizeMap.put(Point(12, 23), "Arial Black", "italic", 18);
    sizeMap.put(Point(12, 23), "Arial Black", "italic_underline", 18);
    sizeMap.put(Point(12, 23), "Arial Black", "bold_italic", 18);
    sizeMap.put(Point(12, 23), "Arial Black", "bold_italic_underline", 18);
    sizeMap.put(Point(13, 23), "Arial Black", "normal", 19);
    sizeMap.put(Point(13, 23), "Arial Black", "bold", 19);
    sizeMap.put(Point(13, 23), "Arial Black", "bold_underline", 19);
    sizeMap.put(Point(13, 23), "Arial Black", "italic", 19);
    sizeMap.put(Point(13, 23), "Arial Black", "italic_underline", 19);
    sizeMap.put(Point(13, 23), "Arial Black", "bold_italic", 19);
    sizeMap.put(Point(13, 23), "Arial Black", "bold_italic_underline", 19);
    sizeMap.put(Point(13, 25), "Arial Black", "normal", 20);
    sizeMap.put(Point(13, 25), "Arial Black", "bold", 20);
    sizeMap.put(Point(13, 25), "Arial Black", "bold_underline", 20);
    sizeMap.put(Point(13, 25), "Arial Black", "italic", 20);
    sizeMap.put(Point(13, 25), "Arial Black", "italic_underline", 20);
    sizeMap.put(Point(13, 25), "Arial Black", "bold_italic", 20);
    sizeMap.put(Point(13, 25), "Arial Black", "bold_italic_underline", 20);
    sizeMap.put(Point(14, 26), "Arial Black", "normal", 21);
    sizeMap.put(Point(14, 26), "Arial Black", "bold", 21);
    sizeMap.put(Point(14, 26), "Arial Black", "bold_underline", 21);
    sizeMap.put(Point(14, 26), "Arial Black", "italic", 21);
    sizeMap.put(Point(14, 26), "Arial Black", "italic_underline", 21);
    sizeMap.put(Point(14, 26), "Arial Black", "bold_italic", 21);
    sizeMap.put(Point(14, 26), "Arial Black", "bold_italic_underline", 21);
    sizeMap.put(Point(15, 27), "Arial Black", "normal", 22);
    sizeMap.put(Point(15, 27), "Arial Black", "bold", 22);
    sizeMap.put(Point(15, 27), "Arial Black", "bold_underline", 22);
    sizeMap.put(Point(15, 27), "Arial Black", "italic", 22);
    sizeMap.put(Point(15, 27), "Arial Black", "italic_underline", 22);
    sizeMap.put(Point(15, 27), "Arial Black", "bold_italic", 22);
    sizeMap.put(Point(15, 27), "Arial Black", "bold_italic_underline", 22);
    sizeMap.put(Point(15, 28), "Arial Black", "normal", 23);
    sizeMap.put(Point(15, 28), "Arial Black", "bold", 23);
    sizeMap.put(Point(15, 28), "Arial Black", "bold_underline", 23);
    sizeMap.put(Point(15, 28), "Arial Black", "italic", 23);
    sizeMap.put(Point(15, 28), "Arial Black", "italic_underline", 23);
    sizeMap.put(Point(15, 28), "Arial Black", "bold_italic", 23);
    sizeMap.put(Point(15, 28), "Arial Black", "bold_italic_underline", 23);
    sizeMap.put(Point(16, 30), "Arial Black", "normal", 24);
    sizeMap.put(Point(16, 30), "Arial Black", "bold", 24);
    sizeMap.put(Point(16, 30), "Arial Black", "bold_underline", 24);
    sizeMap.put(Point(16, 30), "Arial Black", "italic", 24);
    sizeMap.put(Point(16, 30), "Arial Black", "italic_underline", 24);
    sizeMap.put(Point(16, 30), "Arial Black", "bold_italic", 24);
    sizeMap.put(Point(16, 30), "Arial Black", "bold_italic_underline", 24);
    sizeMap.put(Point(17, 31), "Arial Black", "normal", 25);
    sizeMap.put(Point(17, 31), "Arial Black", "bold", 25);
    sizeMap.put(Point(17, 31), "Arial Black", "bold_underline", 25);
    sizeMap.put(Point(17, 31), "Arial Black", "italic", 25);
    sizeMap.put(Point(17, 31), "Arial Black", "italic_underline", 25);
    sizeMap.put(Point(17, 31), "Arial Black", "bold_italic", 25);
    sizeMap.put(Point(17, 31), "Arial Black", "bold_italic_underline", 25);
    sizeMap.put(Point(17, 32), "Arial Black", "normal", 26);
    sizeMap.put(Point(17, 32), "Arial Black", "bold", 26);
    sizeMap.put(Point(17, 32), "Arial Black", "bold_underline", 26);
    sizeMap.put(Point(17, 32), "Arial Black", "italic", 26);
    sizeMap.put(Point(17, 32), "Arial Black", "italic_underline", 26);
    sizeMap.put(Point(17, 32), "Arial Black", "bold_italic", 26);
    sizeMap.put(Point(17, 32), "Arial Black", "bold_italic_underline", 26);
    sizeMap.put(Point(18, 33), "Arial Black", "normal", 27);
    sizeMap.put(Point(18, 33), "Arial Black", "bold", 27);
    sizeMap.put(Point(18, 33), "Arial Black", "bold_underline", 27);
    sizeMap.put(Point(18, 33), "Arial Black", "italic", 27);
    sizeMap.put(Point(18, 33), "Arial Black", "italic_underline", 27);
    sizeMap.put(Point(18, 33), "Arial Black", "bold_italic", 27);
    sizeMap.put(Point(18, 33), "Arial Black", "bold_italic_underline", 27);
    sizeMap.put(Point(19, 35), "Arial Black", "normal", 28);
    sizeMap.put(Point(19, 35), "Arial Black", "bold", 28);
    sizeMap.put(Point(19, 35), "Arial Black", "bold_underline", 28);
    sizeMap.put(Point(19, 35), "Arial Black", "italic", 28);
    sizeMap.put(Point(19, 35), "Arial Black", "italic_underline", 28);
    sizeMap.put(Point(19, 35), "Arial Black", "bold_italic", 28);
    sizeMap.put(Point(19, 35), "Arial Black", "bold_italic_underline", 28);
    sizeMap.put(Point(19, 36), "Arial Black", "normal", 29);
    sizeMap.put(Point(19, 36), "Arial Black", "bold", 29);
    sizeMap.put(Point(19, 36), "Arial Black", "bold_underline", 29);
    sizeMap.put(Point(19, 36), "Arial Black", "italic", 29);
    sizeMap.put(Point(19, 36), "Arial Black", "italic_underline", 29);
    sizeMap.put(Point(19, 36), "Arial Black", "bold_italic", 29);
    sizeMap.put(Point(19, 36), "Arial Black", "bold_italic_underline", 29);
    sizeMap.put(Point(20, 37), "Arial Black", "normal", 30);
    sizeMap.put(Point(20, 37), "Arial Black", "bold", 30);
    sizeMap.put(Point(20, 37), "Arial Black", "bold_underline", 30);
    sizeMap.put(Point(20, 37), "Arial Black", "italic", 30);
    sizeMap.put(Point(20, 37), "Arial Black", "italic_underline", 30);
    sizeMap.put(Point(20, 37), "Arial Black", "bold_italic", 30);
    sizeMap.put(Point(20, 37), "Arial Black", "bold_italic_underline", 30);
    sizeMap.put(Point(21, 38), "Arial Black", "normal", 31);
    sizeMap.put(Point(21, 38), "Arial Black", "bold", 31);
    sizeMap.put(Point(21, 38), "Arial Black", "bold_underline", 31);
    sizeMap.put(Point(21, 38), "Arial Black", "italic", 31);
    sizeMap.put(Point(21, 38), "Arial Black", "italic_underline", 31);
    sizeMap.put(Point(21, 38), "Arial Black", "bold_italic", 31);
    sizeMap.put(Point(21, 38), "Arial Black", "bold_italic_underline", 31);
    sizeMap.put(Point(3, 5), "Calibri", "normal", 4);
    sizeMap.put(Point(3, 5), "Calibri", "bold", 4);
    sizeMap.put(Point(3, 5), "Calibri", "bold_underline", 4);
    sizeMap.put(Point(3, 5), "Calibri", "italic", 4);
    sizeMap.put(Point(3, 5), "Calibri", "italic_underline", 4);
    sizeMap.put(Point(3, 5), "Calibri", "bold_italic", 4);
    sizeMap.put(Point(3, 5), "Calibri", "bold_italic_underline", 4);
    sizeMap.put(Point(3, 7), "Calibri", "normal", 5);
    sizeMap.put(Point(3, 7), "Calibri", "bold", 5);
    sizeMap.put(Point(3, 7), "Calibri", "bold_underline", 5);
    sizeMap.put(Point(3, 7), "Calibri", "italic", 5);
    sizeMap.put(Point(3, 7), "Calibri", "italic_underline", 5);
    sizeMap.put(Point(3, 7), "Calibri", "bold_italic", 5);
    sizeMap.put(Point(3, 7), "Calibri", "bold_italic_underline", 5);
    sizeMap.put(Point(4, 8), "Calibri", "normal", 6);
    sizeMap.put(Point(4, 8), "Calibri", "bold", 6);
    sizeMap.put(Point(4, 8), "Calibri", "bold_underline", 6);
    sizeMap.put(Point(4, 8), "Calibri", "italic", 6);
    sizeMap.put(Point(4, 8), "Calibri", "italic_underline", 6);
    sizeMap.put(Point(4, 8), "Calibri", "bold_italic", 6);
    sizeMap.put(Point(4, 8), "Calibri", "bold_italic_underline", 6);
    sizeMap.put(Point(5, 10), "Calibri", "normal", 7);
    sizeMap.put(Point(5, 10), "Calibri", "bold", 7);
    sizeMap.put(Point(5, 10), "Calibri", "bold_underline", 7);
    sizeMap.put(Point(5, 10), "Calibri", "italic", 7);
    sizeMap.put(Point(5, 10), "Calibri", "italic_underline", 7);
    sizeMap.put(Point(5, 10), "Calibri", "bold_italic", 7);
    sizeMap.put(Point(5, 10), "Calibri", "bold_italic_underline", 7);
    sizeMap.put(Point(5, 10), "Calibri", "normal", 8);
    sizeMap.put(Point(5, 10), "Calibri", "bold", 8);
    sizeMap.put(Point(5, 10), "Calibri", "bold_underline", 8);
    sizeMap.put(Point(5, 10), "Calibri", "italic", 8);
    sizeMap.put(Point(5, 10), "Calibri", "italic_underline", 8);
    sizeMap.put(Point(5, 10), "Calibri", "bold_italic", 8);
    sizeMap.put(Point(5, 10), "Calibri", "bold_italic_underline", 8);
    sizeMap.put(Point(6, 12), "Calibri", "normal", 9);
    sizeMap.put(Point(6, 12), "Calibri", "bold", 9);
    sizeMap.put(Point(6, 12), "Calibri", "bold_underline", 9);
    sizeMap.put(Point(6, 12), "Calibri", "italic", 9);
    sizeMap.put(Point(6, 12), "Calibri", "italic_underline", 9);
    sizeMap.put(Point(6, 12), "Calibri", "bold_italic", 9);
    sizeMap.put(Point(6, 12), "Calibri", "bold_italic_underline", 9);
    sizeMap.put(Point(7, 13), "Calibri", "normal", 10);
    sizeMap.put(Point(7, 13), "Calibri", "bold", 10);
    sizeMap.put(Point(7, 13), "Calibri", "bold_underline", 10);
    sizeMap.put(Point(7, 13), "Calibri", "italic", 10);
    sizeMap.put(Point(7, 13), "Calibri", "italic_underline", 10);
    sizeMap.put(Point(7, 13), "Calibri", "bold_italic", 10);
    sizeMap.put(Point(7, 13), "Calibri", "bold_italic_underline", 10);
    sizeMap.put(Point(7, 14), "Calibri", "normal", 11);
    sizeMap.put(Point(7, 14), "Calibri", "bold", 11);
    sizeMap.put(Point(7, 14), "Calibri", "bold_underline", 11);
    sizeMap.put(Point(7, 14), "Calibri", "italic", 11);
    sizeMap.put(Point(7, 14), "Calibri", "italic_underline", 11);
    sizeMap.put(Point(7, 14), "Calibri", "bold_italic", 11);
    sizeMap.put(Point(7, 14), "Calibri", "bold_italic_underline", 11);
    sizeMap.put(Point(8, 15), "Calibri", "normal", 12);
    sizeMap.put(Point(8, 15), "Calibri", "bold", 12);
    sizeMap.put(Point(8, 15), "Calibri", "bold_underline", 12);
    sizeMap.put(Point(8, 15), "Calibri", "italic", 12);
    sizeMap.put(Point(8, 15), "Calibri", "italic_underline", 12);
    sizeMap.put(Point(8, 15), "Calibri", "bold_italic", 12);
    sizeMap.put(Point(8, 15), "Calibri", "bold_italic_underline", 12);
    sizeMap.put(Point(9, 17), "Calibri", "normal", 13);
    sizeMap.put(Point(9, 17), "Calibri", "bold", 13);
    sizeMap.put(Point(9, 17), "Calibri", "bold_underline", 13);
    sizeMap.put(Point(9, 17), "Calibri", "italic", 13);
    sizeMap.put(Point(9, 17), "Calibri", "italic_underline", 13);
    sizeMap.put(Point(9, 17), "Calibri", "bold_italic", 13);
    sizeMap.put(Point(9, 17), "Calibri", "bold_italic_underline", 13);
    sizeMap.put(Point(9, 18), "Calibri", "normal", 14);
    sizeMap.put(Point(9, 18), "Calibri", "bold", 14);
    sizeMap.put(Point(9, 18), "Calibri", "bold_underline", 14);
    sizeMap.put(Point(9, 18), "Calibri", "italic", 14);
    sizeMap.put(Point(9, 18), "Calibri", "italic_underline", 14);
    sizeMap.put(Point(9, 18), "Calibri", "bold_italic", 14);
    sizeMap.put(Point(9, 18), "Calibri", "bold_italic_underline", 14);
    sizeMap.put(Point(10, 19), "Calibri", "normal", 15);
    sizeMap.put(Point(10, 19), "Calibri", "bold", 15);
    sizeMap.put(Point(10, 19), "Calibri", "bold_underline", 15);
    sizeMap.put(Point(10, 19), "Calibri", "italic", 15);
    sizeMap.put(Point(10, 19), "Calibri", "italic_underline", 15);
    sizeMap.put(Point(10, 19), "Calibri", "bold_italic", 15);
    sizeMap.put(Point(10, 19), "Calibri", "bold_italic_underline", 15);
    sizeMap.put(Point(11, 20), "Calibri", "normal", 16);
    sizeMap.put(Point(11, 20), "Calibri", "bold", 16);
    sizeMap.put(Point(11, 20), "Calibri", "bold_underline", 16);
    sizeMap.put(Point(11, 20), "Calibri", "italic", 16);
    sizeMap.put(Point(11, 20), "Calibri", "italic_underline", 16);
    sizeMap.put(Point(11, 20), "Calibri", "bold_italic", 16);
    sizeMap.put(Point(11, 20), "Calibri", "bold_italic_underline", 16);
    sizeMap.put(Point(11, 21), "Calibri", "normal", 17);
    sizeMap.put(Point(11, 21), "Calibri", "bold", 17);
    sizeMap.put(Point(11, 21), "Calibri", "bold_underline", 17);
    sizeMap.put(Point(11, 21), "Calibri", "italic", 17);
    sizeMap.put(Point(11, 21), "Calibri", "italic_underline", 17);
    sizeMap.put(Point(11, 21), "Calibri", "bold_italic", 17);
    sizeMap.put(Point(11, 21), "Calibri", "bold_italic_underline", 17);
    sizeMap.put(Point(12, 23), "Calibri", "normal", 18);
    sizeMap.put(Point(12, 23), "Calibri", "bold", 18);
    sizeMap.put(Point(12, 23), "Calibri", "bold_underline", 18);
    sizeMap.put(Point(12, 23), "Calibri", "italic", 18);
    sizeMap.put(Point(12, 23), "Calibri", "italic_underline", 18);
    sizeMap.put(Point(12, 23), "Calibri", "bold_italic", 18);
    sizeMap.put(Point(12, 23), "Calibri", "bold_italic_underline", 18);
    sizeMap.put(Point(13, 23), "Calibri", "normal", 19);
    sizeMap.put(Point(13, 23), "Calibri", "bold", 19);
    sizeMap.put(Point(13, 23), "Calibri", "bold_underline", 19);
    sizeMap.put(Point(13, 23), "Calibri", "italic", 19);
    sizeMap.put(Point(13, 23), "Calibri", "italic_underline", 19);
    sizeMap.put(Point(13, 23), "Calibri", "bold_italic", 19);
    sizeMap.put(Point(13, 23), "Calibri", "bold_italic_underline", 19);
    sizeMap.put(Point(13, 25), "Calibri", "normal", 20);
    sizeMap.put(Point(13, 25), "Calibri", "bold", 20);
    sizeMap.put(Point(13, 25), "Calibri", "bold_underline", 20);
    sizeMap.put(Point(13, 25), "Calibri", "italic", 20);
    sizeMap.put(Point(13, 25), "Calibri", "italic_underline", 20);
    sizeMap.put(Point(13, 25), "Calibri", "bold_italic", 20);
    sizeMap.put(Point(13, 25), "Calibri", "bold_italic_underline", 20);
    sizeMap.put(Point(14, 26), "Calibri", "normal", 21);
    sizeMap.put(Point(14, 26), "Calibri", "bold", 21);
    sizeMap.put(Point(14, 26), "Calibri", "bold_underline", 21);
    sizeMap.put(Point(14, 26), "Calibri", "italic", 21);
    sizeMap.put(Point(14, 26), "Calibri", "italic_underline", 21);
    sizeMap.put(Point(14, 26), "Calibri", "bold_italic", 21);
    sizeMap.put(Point(14, 26), "Calibri", "bold_italic_underline", 21);
    sizeMap.put(Point(15, 27), "Calibri", "normal", 22);
    sizeMap.put(Point(15, 27), "Calibri", "bold", 22);
    sizeMap.put(Point(15, 27), "Calibri", "bold_underline", 22);
    sizeMap.put(Point(15, 27), "Calibri", "italic", 22);
    sizeMap.put(Point(15, 27), "Calibri", "italic_underline", 22);
    sizeMap.put(Point(15, 27), "Calibri", "bold_italic", 22);
    sizeMap.put(Point(15, 27), "Calibri", "bold_italic_underline", 22);
    sizeMap.put(Point(15, 28), "Calibri", "normal", 23);
    sizeMap.put(Point(15, 28), "Calibri", "bold", 23);
    sizeMap.put(Point(15, 28), "Calibri", "bold_underline", 23);
    sizeMap.put(Point(15, 28), "Calibri", "italic", 23);
    sizeMap.put(Point(15, 28), "Calibri", "italic_underline", 23);
    sizeMap.put(Point(15, 28), "Calibri", "bold_italic", 23);
    sizeMap.put(Point(15, 28), "Calibri", "bold_italic_underline", 23);
    sizeMap.put(Point(16, 30), "Calibri", "normal", 24);
    sizeMap.put(Point(16, 30), "Calibri", "bold", 24);
    sizeMap.put(Point(16, 30), "Calibri", "bold_underline", 24);
    sizeMap.put(Point(16, 30), "Calibri", "italic", 24);
    sizeMap.put(Point(16, 30), "Calibri", "italic_underline", 24);
    sizeMap.put(Point(16, 30), "Calibri", "bold_italic", 24);
    sizeMap.put(Point(16, 30), "Calibri", "bold_italic_underline", 24);
    sizeMap.put(Point(17, 31), "Calibri", "normal", 25);
    sizeMap.put(Point(17, 31), "Calibri", "bold", 25);
    sizeMap.put(Point(17, 31), "Calibri", "bold_underline", 25);
    sizeMap.put(Point(17, 31), "Calibri", "italic", 25);
    sizeMap.put(Point(17, 31), "Calibri", "italic_underline", 25);
    sizeMap.put(Point(17, 31), "Calibri", "bold_italic", 25);
    sizeMap.put(Point(17, 31), "Calibri", "bold_italic_underline", 25);
    sizeMap.put(Point(17, 32), "Calibri", "normal", 26);
    sizeMap.put(Point(17, 32), "Calibri", "bold", 26);
    sizeMap.put(Point(17, 32), "Calibri", "bold_underline", 26);
    sizeMap.put(Point(17, 32), "Calibri", "italic", 26);
    sizeMap.put(Point(17, 32), "Calibri", "italic_underline", 26);
    sizeMap.put(Point(17, 32), "Calibri", "bold_italic", 26);
    sizeMap.put(Point(17, 32), "Calibri", "bold_italic_underline", 26);
    sizeMap.put(Point(18, 33), "Calibri", "normal", 27);
    sizeMap.put(Point(18, 33), "Calibri", "bold", 27);
    sizeMap.put(Point(18, 33), "Calibri", "bold_underline", 27);
    sizeMap.put(Point(18, 33), "Calibri", "italic", 27);
    sizeMap.put(Point(18, 33), "Calibri", "italic_underline", 27);
    sizeMap.put(Point(18, 33), "Calibri", "bold_italic", 27);
    sizeMap.put(Point(18, 33), "Calibri", "bold_italic_underline", 27);
    sizeMap.put(Point(19, 35), "Calibri", "normal", 28);
    sizeMap.put(Point(19, 35), "Calibri", "bold", 28);
    sizeMap.put(Point(19, 35), "Calibri", "bold_underline", 28);
    sizeMap.put(Point(19, 35), "Calibri", "italic", 28);
    sizeMap.put(Point(19, 35), "Calibri", "italic_underline", 28);
    sizeMap.put(Point(19, 35), "Calibri", "bold_italic", 28);
    sizeMap.put(Point(19, 35), "Calibri", "bold_italic_underline", 28);
    sizeMap.put(Point(19, 36), "Calibri", "normal", 29);
    sizeMap.put(Point(19, 36), "Calibri", "bold", 29);
    sizeMap.put(Point(19, 36), "Calibri", "bold_underline", 29);
    sizeMap.put(Point(19, 36), "Calibri", "italic", 29);
    sizeMap.put(Point(19, 36), "Calibri", "italic_underline", 29);
    sizeMap.put(Point(19, 36), "Calibri", "bold_italic", 29);
    sizeMap.put(Point(19, 36), "Calibri", "bold_italic_underline", 29);
    sizeMap.put(Point(20, 37), "Calibri", "normal", 30);
    sizeMap.put(Point(20, 37), "Calibri", "bold", 30);
    sizeMap.put(Point(20, 37), "Calibri", "bold_underline", 30);
    sizeMap.put(Point(20, 37), "Calibri", "italic", 30);
    sizeMap.put(Point(20, 37), "Calibri", "italic_underline", 30);
    sizeMap.put(Point(20, 37), "Calibri", "bold_italic", 30);
    sizeMap.put(Point(20, 37), "Calibri", "bold_italic_underline", 30);
    sizeMap.put(Point(21, 38), "Calibri", "normal", 31);
    sizeMap.put(Point(21, 38), "Calibri", "bold", 31);
    sizeMap.put(Point(21, 38), "Calibri", "bold_underline", 31);
    sizeMap.put(Point(21, 38), "Calibri", "italic", 31);
    sizeMap.put(Point(21, 38), "Calibri", "italic_underline", 31);
    sizeMap.put(Point(21, 38), "Calibri", "bold_italic", 31);
    sizeMap.put(Point(21, 38), "Calibri", "bold_italic_underline", 31);
}

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
        size_t col = i * maxCols;
        string title = getTitle(options, hdr, i);
        if (title.length > 31) title = title[0..31];
        Worksheet w = wb.addWorksheet(title);
        writeln("w = ", w);
        ws ~= w;
        setLogo(options, config, ws[i]);
        setTitle(ws[i], hdr, Yes.rotated);
        setDeviceHeader(options, config, ws[i], hdr, Yes.rotated);
        setTableHeaders(options, config, ws[i], hdr.isWafersort() ? Yes.wafersort : No.wafersort, Yes.rotated);
        setTestNameHeaders(options, config, ws[i], Yes.rotated, rowOrColMap, col, maxCols);
        setData(options, config, ws[i], i, hdr.isWafersort() ? Yes.wafersort : No.wafersort, rowOrColMap, devices, hdr.temperature, col, maxCols);
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
        setLogo(options, config, ws[i]);
        setTitle(ws[i], hdr, No.rotated);
        setDeviceHeader(options, config, ws[i], hdr, No.rotated);
        setTableHeaders(options, config, ws[i], hdr.isWafersort() ? Yes.wafersort : No.wafersort, No.rotated);
        setTestNameHeaders(options, config, ws[i], No.rotated, rowOrColMap, col, maxCols);
        setData(options, config, ws[i], i, maxCols, hdr.isWafersort() ? Yes.wafersort : No.wafersort, rowOrColMap, devices, hdr.temperature, col, i<(numSheets-1) ? ws[i+1] : dummy);
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
                w.mergeRange(r, c, r, cast(ushort) (c+1), "", hdrNameFmt);
                w.mergeRange(r, cast(ushort) (c+2), r, cast(ushort) (c+3), "", hdrValueFmt);
            }
        }
        int r = 0;
        if (hdr.step != "")
        {
            w.mergeRange(r, 7, r, 8, "STEP #:", hdrNameFmt);
            w.mergeRange(r, 9, r, 10, hdr.step, hdrValueFmt);
            r++;
        }
        if (hdr.temperature != "")
        {
            w.mergeRange(r, 7, r, 8, "Temperature:", hdrNameFmt);
            w.mergeRange(r, 9, r, 10, hdr.temperature, hdrValueFmt);
            r++;
        }
        if (hdr.lot_id != "")
        {
            w.mergeRange(r, 7, r, 8, "Lot #:", hdrNameFmt);
            w.mergeRange(r, 9, r, 10, hdr.lot_id, hdrValueFmt);
            r++;
        }
        if (hdr.sublot_id != "")
        {
            w.mergeRange(r, 7, r, 8, "SubLot #:", hdrNameFmt);
            w.mergeRange(r, 9, r, 10, hdr.sublot_id, hdrValueFmt);
            r++;
        }
        if (hdr.wafer_id != "")
        {
            w.mergeRange(r, 7, r, 8, "Wafer #:", hdrNameFmt);
            w.mergeRange(r, 9, r, 10, hdr.wafer_id, hdrValueFmt);
            r++;
        }
        if (hdr.devName != "")
        {
            w.mergeRange(r, 7, r, 8, "Device:", hdrNameFmt);
            w.mergeRange(r, 9, r, 10, hdr.devName, hdrValueFmt);
            r++;
        }
        auto map = hdr.getHeaderItems();
        ushort c = 7;
        foreach (key; map.keys)
        {
            w.mergeRange(r, c, r, cast(ushort) (c+1), key, hdrNameFmt);
            w.mergeRange(r, cast(ushort) (c+2), r, cast(ushort) (c+3), map[key], hdrValueFmt);
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
        foreach (key; map.keys)
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
        w.mergeRange(7, 11, 7, 15, "Pin", pinHdrFmt);
        // device id header
        if (wafersort) w.writeString(0, 15, "X, Y", snxyHdrFmt); else w.writeString(0, 15, "S/N", snxyHdrFmt);
        w.writeString(1, 15, "Temp", tempHdrFmt);
        w.writeString(2, 15, "Time", timeHdrFmt);
        w.writeString(3, 15, "HW Bin", hwbinHdrFmt);
        w.writeString(4, 15, "SW Bin", swbinHdrFmt);
        w.writeString(5, 15, "Site", siteHdrFmt);
        w.writeString(6, 15, "Result", rsltHdrFmt);
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
            w.mergeRange(row, 0, row, 5, id.testName, testNameValueFmt);
            w.writeNumber(row, 6, id.testNumber, testNumberValueFmt);
            w.writeNumber(row, 7, id.dup, dupValueFmt);
            // Limits must be added when the test data is added
            w.mergeRange(row, 11, row, 15, id.pin, pinValueFmt);
        }
    }
    else
    {
        for (size_t i=col; i<tests.length(); i++)
        {
            auto id = ids[i];       
            ushort lcol = cast(ushort) ((i-col) + 8);
            w.mergeRange(0, lcol, 11, lcol, id.testName, testNameValueFmt);
            w.writeNumber(12, lcol, id.testNumber, testNumberValueFmt);
            w.writeNumber(13, lcol, id.dup, dupValueFmt);
            // Limits must be added when the test data is added
            w.mergeRange(17, lcol, 24, lcol, id.pin, pinValueFmt);
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
        if (device.goodDevice) w.mergeRange(6, cast(ushort) rowOrCol, 7, cast(ushort) rowOrCol, "PASS", rsltPassValueFmt);
        else w.mergeRange(6, cast(ushort) rowOrCol, 7, cast(ushort) rowOrCol, "FAIL", rsltFailValueFmt);
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
                    if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT ||
                        tr.type == TestType.DYNAMIC_LOLIMIT || tr.type == TestType.DYNAMIC_HILIMIT || tr.type == TestType.STRING)
                    {
                        w.writeString(14, lcol, "", loLimitValueFmt);
                        w.writeString(15, lcol, "", hiLimitValueFmt);
                        w.writeString(16, lcol, tr.units, unitsValueFmt);
                    }
                    else
                    {
                        w.writeNumber(14, lcol, tr.loLimit, loLimitValueFmt);
                        w.writeNumber(15, lcol, tr.hiLimit, hiLimitValueFmt);
                        w.writeString(16, lcol, tr.units, unitsValueFmt);
                    }
                    cmap[cast(ushort) (lcol+col)] = true;
                }
                switch (tr.type) with(TestType)
                {
                    case FUNCTIONAL:
                        if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, lcol, "FAIL", failDataFmt);
                        else w.writeString(row, lcol, "PASS", passDataStringFmt);
                        break;
                    case PARAMETRIC: goto case;
                    case FLOAT:
                         if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, lcol, tr.result.f, failDataFmt);
                         else w.writeNumber(row, lcol, tr.result.f, passDataFloatFmt);
                         break;
                    case HEX_INT:
                         string value = to!string(tr.result.u);
                         if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                         else w.writeFormula(row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                         break;
                    case DEC_INT:
                         if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, lcol, tr.result.l, failDataFmt);
                         else w.writeNumber(row, lcol, tr.result.l, passDataIntFmt);
                         break;
                    case DYNAMIC_LOLIMIT:
                         w.writeNumber(row, lcol, tr.result.f, dynLoLimitValueFmt);
                         break;
                    case DYNAMIC_HILIMIT:
                         w.writeNumber(row, lcol, tr.result.f, dynHiLimitValueFmt);
                         break;
                    default: // STRING
                         if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, lcol, tr.result.s, failDataFmt);
                         else w.writeString(row, lcol, tr.result.s, passDataStringFmt);
                         break;
                }
            }
            if (cast(ushort) (lcol+col) !in cmap)
            {
                if (tr.type == TestType.FLOAT || tr.type == TestType.HEX_INT || tr.type == TestType.DEC_INT ||
                    tr.type == TestType.DYNAMIC_LOLIMIT || tr.type == TestType.DYNAMIC_HILIMIT || tr.type == TestType.STRING)
                {
                    w.writeString(14, lcol, "", loLimitValueFmt);
                    w.writeString(15, lcol, "", hiLimitValueFmt);
                    w.writeString(16, lcol, tr.units, unitsValueFmt);
                }
                else
                {
                    w.writeNumber(14, lcol, tr.loLimit, loLimitValueFmt);
                    w.writeNumber(15, lcol, tr.hiLimit, hiLimitValueFmt);
                    w.writeString(16, lcol, tr.units, unitsValueFmt);
                }
                cmap[cast(ushort) (lcol+col)] = true;
            }
            switch (tr.type) with(TestType)
            {
            case FUNCTIONAL:
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, lcol, "FAIL", failDataFmt);
                else w.writeString(row, lcol, "PASS", passDataStringFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, lcol, tr.result.f, failDataFmt);
                else w.writeNumber(row, lcol, tr.result.f, passDataFloatFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                else w.writeFormula(row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, lcol, tr.result.l, failDataFmt);
                else w.writeNumber(row, lcol, tr.result.l, passDataIntFmt);
                break;
            case DYNAMIC_LOLIMIT:
                w.writeNumber(row, lcol, tr.result.f, dynLoLimitValueFmt);
                break;
            case DYNAMIC_HILIMIT:
                w.writeNumber(row, lcol, tr.result.f, dynHiLimitValueFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, lcol, tr.result.s, failDataFmt);
                else w.writeString(row, lcol, tr.result.s, passDataStringFmt);
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
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, lcol, "FAIL", failDataFmt);
                else w.writeString(row, lcol, "PASS", passDataStringFmt);
                break;
            case PARAMETRIC: goto case;
            case FLOAT:
                writeln("tr.id = ", tr.id, " result = ", tr.result.f, " lcol = ", lcol, " row = ", row);
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, lcol, tr.result.f, failDataFmt);
                else w.writeNumber(row, lcol, tr.result.f, passDataFloatFmt);
                break;
            case HEX_INT:
                string value = to!string(tr.result.u);
                if ((tr.testFlags & 0x80) == 0x80) w.writeFormula(row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", failDataFmt);
                else w.writeFormula(row, lcol, "=DEC2HEX(" ~ value ~ "; 8)", passDataHexFmt);
                break;
            case DEC_INT:
                if ((tr.testFlags & 0x80) == 0x80) w.writeNumber(row, lcol, tr.result.l, failDataFmt);
                else w.writeNumber(row, lcol, tr.result.l, passDataIntFmt);
                break;
            case DYNAMIC_LOLIMIT:
                w.writeNumber(row, lcol, tr.result.f, dynLoLimitValueFmt);
                break;
            case DYNAMIC_HILIMIT:
                w.writeNumber(row, lcol, tr.result.f, dynHiLimitValueFmt);
                break;
            default: // STRING
                if ((tr.testFlags & 0x80) == 0x80) w.writeString(row, lcol, tr.result.s, failDataFmt);
                else w.writeString(row, lcol, tr.result.s, passDataStringFmt);
                break;
            }
        }
        lcol++;
    }
    w.freezePanes(8, 16);
}




