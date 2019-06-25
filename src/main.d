import makechip.util.Util;
import makechip.Stdf;
import makechip.Cpu_t;
import std.conv;
import std.stdio;
import std.traits;
import std.getopt;

private struct CmdOptions
{

    @Parameter("dumptext", 'd') @Description("dump the STDF in text form") bool d1;
    @Parameter("dumpbytes", 'b') @Description("dump the STDF in ascii byte form") bool d2;
    @Parameter("output", 'o') @Description("dump to this file instead of stdout") string outputFile;
    @Parameter() string stdfFiles;
}

void main(string[] args)
{
    bool dumpText = false;
    bool dumpBytes = false;
    string outputFile = "";
    auto helpInfo = getopt(args,
        std.getopt.config.caseSensitive,
        std
        "dumptext|d", "dump the STDF in text form", &dumpText,
        "dumpBytes|b", "dump the STDF in ascii byte form", &dumpBytes,
        "output|o", "write out the STDF to this file", &outputFile,

    //writeln("d1 = '", config.d1, "'");
    //writeln("d2 = '", config.d2, "'");
    //writeln("outputFile = '", config.outputFile, "'");
    writeln("stdfFiles = ", config.stdfFiles);

/*
    auto rdr = new StdfReader(args[1]);
    rdr.read();
    auto recs = rdr.getRecords();
    //writeln("num recs = ", recs.length);
    foreach(r; recs) 
    {
        //writeln(r.toString());
    }
*/
}
