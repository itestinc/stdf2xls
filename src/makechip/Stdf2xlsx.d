/**
  This module loads all the STDF files, groups them by device type,
  add dynamic limits if necessary, and sorts the S/N or X/Y as required.

  The following following is done at the top level:
  1. Possibly sort by timestamp and/or SN/XY
  2. Optionally remove duplicates
  3. Figure out dynamic limits
  4. Generate spreadsheets
  5. Generate histograms
  6. Generate wafermaps

 */
module makechip.Stdf2xls;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.Descriptors;
import makechip.Config;
import std.conv;
import std.typecons;
import makechip.CmdOptions;
import makechip.DefaultValueDatabase;
import makechip.StdfFile;
import makechip.StdfDB;
import std.stdio;
import makechip.Spreadsheet;
import makechip.Wafermap;
import makechip.Histogram;

private StdfFile[][HeaderInfo] stdfFiles;
private string[string] devices;
private string[string] steps;
private StdfDB stdfdb;

public StdfFile[][HeaderInfo] processStdf(CmdOptions options)
{
    foreach(file; options.stdfFiles) 
    {
        processFile(file, options);
    }
    return stdfFiles;
}

public void loadDb(CmdOptions options)
{
    if (stdfdb is null) stdfdb = new StdfDB(options);
    // build test results lists here
    foreach (hdr; stdfFiles.keys)
    {
        StdfFile[] f = stdfFiles[hdr];
        foreach (file; f) stdfdb.load(file);
        if (options.verbosityLevel > 10)
        {
            writeln("device: ", hdr.devName);
            writeln("number of devices: ", stdfdb.deviceMap[hdr].length);
            writeln("number of files with this header = ", f.length);
            write(hdr.toString());
            writeln("");
        }
    }
    if (options.verbosityLevel > 2) writeln("Number of unique headers: ", stdfdb.deviceMap.length);
}

public void genSpreadsheet(CmdOptions options, Config config)
{
    makechip.Spreadsheet.genSpreadsheet(options, stdfdb, config);
}

public void genWafermap(CmdOptions options, Config config)
{
    makechip.Wafermap.genWafermap(options, stdfdb, config);
}

public void genHistogram(CmdOptions options, Config config)
{
    makechip.Histogram.genHistogram(options, stdfdb, config);
}

public void summarize()
{
    foreach(hdr; stdfdb.deviceMap.keys)
    {
        DeviceResult[] dr = stdfdb.deviceMap[hdr];
        string dev = dr.length == 1 ? "device" : "devices";
        writeln("", dr.length, " ", dev, " for HEADER:");
        writeln(hdr.toString());
    }
}

private void processFile(string file, CmdOptions options)
{
    auto sfile = StdfFile(file, options);
    sfile.load();
    if (sfile.hdr !in stdfFiles)
    {
        StdfFile[] s;
        s ~= sfile;
        stdfFiles[sfile.hdr] = s;
    }
    else
    {
        StdfFile[] s = stdfFiles[sfile.hdr];
        s ~= sfile;
        stdfFiles[sfile.hdr] = s;
    }
}

