import std.stdio;
import printed.canvas;
import std.file;

void main()
{
    auto pdfDoc = new PDFDocument();

    IRenderingContext2D r = cast(IRenderingContext2D) pdfDoc;

    r.fillStyle = brush("#eee");
    r.fillRect(0, 0, r.pageWidth, r.pageHeight);

    r.strokeStyle = brush("#ff0000");
    r.lineWidth(1);
    r.beginPath(100, 150);
    r.lineTo(100, 250);
    r.stroke();

    r.fillStyle = brush("black");
    r.fontFace("Helvetica");
    r.fontWeight(FontWeight.bold);
    r.fontSize(14);
    //r.translate(100, 100);
    r.fillText("HELLO WORLD", 100, 100);
    std.file.write("output.pdf", pdfDoc.bytes);
}
