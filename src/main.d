import makechip.util.Util;
import makechip.Stdf;
import makechip.Cpu_t;
import std.conv;
import std.stdio;
import std.traits;
import std.getopt;
import std.typecons;


int main(string[] args)
{
    bool textDump;
    bool byteDump;
    string outputDir = "/";
    auto rslt = getopt(args,
        std.getopt.config.caseSensitive,
        std.getopt.config.passThrough,
        "dumptext|d", "dump the STDF in text form", &textDump,
        "dumpBytes|b", "dump the STDF in ascii byte form", &byteDump,
        "outputDir|o", "write out the STDF to this directory", &outputDir);

    if (rslt.helpWanted)
    {
        defaultGetoptPrinter("Options:", rslt.options);
        return -1;
    }
    import std.path;
    import std.digest;
    bool save = outputDir != "/";
    for (int i=1; i<args.length; i++)
    {
        auto rdr = new StdfReader(textDump ? Yes.textDump : No.textDump, byteDump ? Yes.byteDump : No.byteDump, args[i]);
        rdr.read();
        if (save)
        {
            StdfRecord[] rs = rdr.getRecords();
            string outname = outputDir ~ baseName(args[i]);
            File f = File(outname, "w");
            foreach (r; rs)
            {
                auto type = r.recordType;
                ubyte[] bs = r.getBytes();
                f.rawWrite(bs);
            }
            f.close();
            File f1 = File(args[i], "r");
            File f2 = File(outname, "r");
            ubyte[] bs1;
            ubyte[] bs2;
            bs1.length = f1.size();
            bs2.length = f2.size();
            f1.rawRead(bs1);
            f2.rawRead(bs2);
            bool pass = true;
            size_t mismatches = 0L;
            for (size_t j=0; j<f1.size() && j<f2.size(); j++)
            {
                if (bs1[j] != bs2[j])
                {
                    writeln("diff at index ", j, ": ", toHexString([bs1[j]]), " vs ", toHexString([bs2[j]]));
                    pass = false;
                    mismatches++;
                }
                if (mismatches > 20) break;
            }
            if (pass)
            {
                writeln("Saved file matches input file");
            }
        }
    }
    return 0;
}
