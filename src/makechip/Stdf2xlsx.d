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
import makechip.Util;

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

public StdfDB loadDb(CmdOptions options)
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
    if (!options.noDynamicLimits)
    {
        MultiMap!(bool, HeaderInfo, const TestID) dynLoLims = new MultiMap!(bool, HeaderInfo, const TestID)();
        MultiMap!(bool, HeaderInfo, const TestID) dynHiLims = new MultiMap!(bool, HeaderInfo, const TestID)();
        MultiMap!(float, HeaderInfo, const TestID) loLims = new MultiMap!(float, HeaderInfo, const TestID)();
        MultiMap!(float, HeaderInfo, const TestID) hiLims = new MultiMap!(float, HeaderInfo, const TestID)();
        import std.math;
        foreach (hdr; stdfdb.deviceMap.keys)
        {
            auto map = hdr.getHeaderItems();
            DeviceResult[] dr = stdfdb.deviceMap[hdr];
            foreach (ref dev; dr)
            {
                foreach (test; dev.tests)
                {
                    const TestID id = test.id;
                    if (id.type == Record_t.MPR || id.type == Record_t.PTR)
                    {
                        if (!loLims.contains(hdr, id)) 
                        {
                            loLims.put(test.loLimit, hdr, id);
                        }
                        else
                        {
                            float ll = fabs(loLims.get(-999999.0, hdr, id));
                            float ll2 = fabs(test.loLimit);
                            if (ll > (1.001 * ll2) || ll < (0.999 * ll2))
                            {
                                if (!dynLoLims.contains(hdr, id)) dynLoLims.put(true, hdr, id);
                            }
                        }
                        if (!hiLims.contains(hdr, id)) 
                        {
                            hiLims.put(test.hiLimit, hdr, id);
                        }
                        else
                        {
                            float hl = fabs(hiLims.get(-999999.0, hdr, id));
                            float hl2 = fabs(test.hiLimit);
                            if (hl > (1.001 * hl2) || hl < (0.999 * hl2))
                            {
                                if (!dynHiLims.contains(hdr, id)) dynHiLims.put(true, hdr, id);
                            }
                        }
                    }
                }
            }
        }
        // now insert lo and hi limit markers in the test record lists
        foreach (hdr; stdfdb.deviceMap.keys)
        {
            DeviceResult[] dr = stdfdb.deviceMap[hdr];
            foreach (ref dev; dr)
            {
                TestID lastid = null;
                TestRecord lastTest = null;
                bool foundFirst = false;
                foreach (test; dev.tests)
                {
                    const TestID id = test.id;
                    if (id.type == Record_t.MPR)
                    {
                        if ((lastid !is null) && id.sameMPRTest(cast(const TestID) lastid)) continue;
                        if (dynLoLims.contains(hdr, id) && !foundFirst)
                        {
                            if (options.verbosityLevel > 1) writeln("Warning: dynamic low limit found: ", id);
                            test.dynamicLoLimit = true;
                            lastid = cast(TestID) id;
                            foundFirst = true;
                        }
                        if (foundFirst)
                        {
                            if (dynHiLims.contains(hdr, id))
                            {
                                if (options.verbosityLevel > 1) writeln("Warning: dynamic high limit found: ", id);
                                if (lastTest !is null) lastTest.dynamicHiLimit = true;
                                lastid = cast(TestID) id;
                                foundFirst = false;
                            }
                        }
                        lastTest = test;
                    }
                    else if (id.type == Record_t.PTR)
                    {
                        if (dynLoLims.contains(hdr, id)) 
                        {
                            if (options.verbosityLevel > 1) writeln("Warning: dynamic low limit found: ", id);
                            test.dynamicLoLimit = true;
                        }
                        if (dynHiLims.contains(hdr, id)) 
                        {
                            if (options.verbosityLevel > 1) writeln("Warning: dynamic high limit found: ", id);
                            test.dynamicHiLimit = true;
                        }
                    }
                }
            }
        }
    }
    return stdfdb;
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

