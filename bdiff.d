import std.stdio;
import std.file;

int main(string[] args)
{
    import std.digest;
    if (args.length != 3)
    {
        writeln("Usage: ./bdiff <file1> <file2>");
        return -1;
    }
    File f1 = File(args[1], "r");
    File f2 = File(args[2], "r");
//    if (f1.size() != f2.size())
//    {
//        writeln("Files must be of the same size");
//        writeln(args[1], " and ", args[2]);
//        return -1;
//    }
    ubyte[] bs1;
    ubyte[] bs2;
    bs1.length = f1.size();
    bs2.length = f2.size();
    f1.rawRead(bs1);
    f2.rawRead(bs2);
    bool pass = true;
    for (size_t i=0; i<f1.size(); i++)
    {
        if (bs1[i] != bs2[i])
        {
            writeln("diff at index ", i, ": ", toHexString([bs1[i]]), " vs ", toHexString([bs2[i]]));
            pass = false;
        }
    }
    if (!pass) return 1;
    return 0;
}
