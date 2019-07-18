import std.stdio;
import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;

void main()
{
    auto wb = newWorkbook("x.xlsx");
    auto ws = wb.addWorksheet("PAGE 1");
    Format fmt1 = wb.addFormat();
    fmt1.setBold();
    Format fmt2 = wb.addFormat();
    fmt2.setDiagType(2);
    fmt2.setDiagBorder(1);
    fmt2.setDiagColor(8);
    fmt2.setTextWrap();
    fmt2.setAlign(1);
    fmt2.setBgColor(0x0099AA);


    size_t w1 = ws.writeAndGetWidth(1, 1, "AAA", fmt1);
    size_t w2 = ws.writeAndGetWidth(2, 1, "AAAAA", fmt1);
    size_t w3 = ws.writeAndGetWidth(3, 1, "AAAAAAA", fmt1);
    writeln("w1 = ", w1, " w2 = ", w2, " w3 = ", w3);
    ws.setRow(2, 30);
    ws.write(2, 2, "        AA BB", fmt2);
    ws.setTabColor(0xFF4400);
}
