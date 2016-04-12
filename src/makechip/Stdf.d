import std.stdio;
import std.range;
import std.array;
import makechip.util.InputStream;
import std.algorithm;

class StdfReader
{
    private InputStreamRange src;
    public const string filename;
    
    this(string filename, size_t bufferSize)
    {
        this.filename = filename;
        auto f = new File(filename, "rb");
        if (f.size() > bufferSize) src = new FileBinaryInputStream(filename, bufferSize);
        else src = new FastFileBinaryInputStream(filename, bufferSize);
    }

    void read()
    {
        while (!src.empty)
        {
            ubyte a = src.front; src.popFront();
            if (src.empty) throw new Exception("Unexpected EOF: " ~ filename);
            ubyte b = src.front; src.popFront();
            if (src.empty) throw new Exception("Unexpected EOF: " ~ filename);
            ubyte c = src.front; src.popFront();
            if (src.empty) throw new Exception("Unexpected EOF: " ~ filename);
            ubyte d = src.front; src.popFront();
            if (src.empty) throw new Exception("Unexpected EOF: " ~ filename);
            short recordType = cast(short) 0;
            short subType = cast(short) 0;
            recordType |= (c & 0xFF);
            subType |= (d & 0xFF);

        }
    }

}
