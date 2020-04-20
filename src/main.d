import itestinc.CmdOptions;
import itestinc.Stdf;
import itestinc.Descriptors;
import itestinc.Cpu_t;
import itestinc.Stdf2xls;
import itestinc.Config;
import std.conv;
import std.stdio;
import std.traits;
import std.getopt;
import std.typecons;
import itestinc.StdfFile;

immutable string _version_ = "5.0.0";

int main(string[] args)
{
    if ((args.length == 2) && (args[1] == "-h")) args[1] = "--help";
    writeln("stdf2xls version ", _version_);
    CmdOptions options = new CmdOptions(args);
    import std.path;
    import std.digest;
    import std.file;
    Config config = new Config();
    config.load();
    if (options.generateRC) config.write();
    processStdf(options);
    // prepare to process test data
    if (options.summarize || options.genSpreadsheet || options.genWafermap || options.genHistogram) loadDb(options);
    if (options.summarize) summarize();
    if (options.genSpreadsheet || options.genHistogram) genSpreadsheet(options, config);
    if (options.genWafermap) genWafermap(options, config);
    if (options.genHistogram) genHistogram(options, config);
    return 0;
}


