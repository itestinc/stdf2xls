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
module makechip.Stdf2xlsx;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.Descriptors;
import makechip.util.Collections;
import std.conv;
import std.typecons;
import makechip.CmdOptions;
import makechip.DefaultValueDatabase;
import makechip.StdfFile;
import makechip.StdfDB;

private StdfFile[][HeaderInfo] stdfFiles;
private string[string] devices;
private string[string] steps;
private StdfDB stdfdb;

public StdfFile[][HeaderInfo] processStdf(Options options)
{
    import std.parallelism;
    if (options.noMultithreading)
    {
        foreach(file; options.stdfFiles) processFile(file, options);
    }
    else
    {
        foreach(file; parallel(options.stdfFiles)) processFile(file, options);
    }
    return stdfFiles;
}

public void loadDb(Options options)
{
    if (stdfdb is null) stdfdb = new StdfDB(options);
    // build test results lists here
    foreach (hdr; stdfFiles.keys)
    {
        StdfFile[] f = stdfFiles[hdr];
        foreach (file; f) stdfdb.load(file);
    }
    //import std.algorithm.sorting;
    //sort!((a, b) => cmp(a, b) < 0)(numbers);
}

private void processFile(string file, Options options)
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
    }
}

/*
struct HeaderInfo { string step; string temperature; string lot_id; string sublot_id; string wafer_id; string devName; string[string] headerItems; }
union SN { string sn; Point xy; }
//private immutable string SERIAL_MARKER = "S/N";
struct PartID
{
    bool ws;
    SN id;

    this(string sn)
    {
        ws = false;
        id.sn = sn;
    }

    this(int x, int y)
    {
        ws = true;
        id.xy.x = x;
        id.xy.y = y;
    }

    void set(string sn)
    {
        id.sn = sn;
        ws = false;
    }

    void set(int x, int y)
    {
        id.xy.x = x;
        id.xy.y = y;
        ws = true;
    }

    string getID()
    {
        if (ws)
        {
            return to!string(id.xy.x) ~ " : " ~ to!string(id.xy.y);
        }
        return id.sn;
    }
}
class TestRecord
{
    const TestType type;
    const TestID id;
    const ubyte site;
    const ubyte head;
    const ubyte testFlags;
    const ubyte optFlags;
    const ubyte parmFlags;
    float loLimit;
    float hiLimit;
    DTRValue result;
    string units;
    byte resScal;
    byte llmScal;
    byte hlmScal;
    const uint seqNum;
}
struct DeviceResult
{
    PartID devId;
    uint site;
    uint head;
    ulong tstamp;
    HeaderInfo hdr;
    TestRecord[] tests;

}

struct StdfFile
{
    StdfPinData pinData;
    HeaderInfo hdr;
    DefaultValueDatabase dvd;
    DeviceResult[] devices;
}

        if (options.saveStdf)
        {   
            string outname = options.outputDir ~ filename;
            File f = File(outname, "w");
            foreach (rec; rs) 
            {   
                ubyte[] bs = rec.getBytes();
                f.rawWrite(bs);
            }   
            f.close();
            if (options.verifyWrittenStdf)
            {   
                File f1 = File(filename, "r");
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



*/


