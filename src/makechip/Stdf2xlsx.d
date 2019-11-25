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
//                            device  step
private MultiMap!(StdfFile[], string, string) files;
private string[string] devices;
private string[string] steps;

static this()
{
    files = new MultiMap!(StdfFile[], string, string);
}

public void processStdf(Options options)
{
    import std.parallelism;
    if (options.noMultithreading)
    {
        foreach(file; options.stdfFiles)
        {
            processFile(file, options);
        }
    }
    else
    {
        foreach(file; parallel(options.stdfFiles))
        {
            processFile(file, options);
        }
    }
    //import std.algorithm.sorting;
    //sort!((a, b) => cmp(a, b) < 0)(numbers);
}

private void processFile(string file, Options options)
{
    auto sfile = StdfFile(file, options);
    import std.stdio;
    foreach(d; sfile.devices)
    {
        foreach(t; d.tests)
        {
            if ((t.testFlags & 8) == 8)
            {
                stderr.writeln("site = ", d.site, "name = ", t.id);
            }
        }
    }
    StdfFile[] x;
    devices[sfile.hdr.devName] = sfile.hdr.devName;
    steps[sfile.hdr.step] = sfile.hdr.step;
    StdfFile[] data = files.get(x, sfile.hdr.devName, sfile.hdr.step);
    if (data.length == 0)
    {
        data ~= sfile;
        files.put(data, sfile.hdr.devName, sfile.hdr.step);
    }
    else
    {
        data ~= sfile;
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
*/


