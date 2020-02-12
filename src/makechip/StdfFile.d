/**
    Initial sequence = FAR ATR* MIR RDR? SDR*

    STDF Records and locations within a file:
    FAR - first record of file - ocurrences 1
    ATR - right after FAR - occurences 0 to n
    MIR - after FAR and ATRs - occurences 1
    MRR - last record of stream - occurences 1
    PCR - after initial sequence, and before MRR - occurences 1 or 1 per head or site
    HBR - after initial sequence and before MRR - occurences 1 per hardware bin per site
    SBR - after initial sequence and before MRR - occurences 1 per software bin per site
    PMR - after initial sequence and before first PGR, PLR, FTR, or MPR - occurences 1 or more
    PGR - after PMRs and before first PLR - occurences 0 or more
    PLR - after PGRs - occurences 0 or more
    RDR - after MIR - occurences 0 or 1
    SDR - after MIR and RDR - occurences 1 per site
    WIR - after initial sequence and before MRR - occurences 1 per wafer tested
    WRR - after the WIR - occurences 1 per wafer tested
    WCR - after initial sequence and before MRR - occurences 1 per file (0 if not wafersort)
    PIR - after initial sequence and before the corresponding PRR (sent before testing the device) - occurences 1 per device
    PRR - after corresponding PIR and before MRR - occurences 1 per device
    TSR - after initial sequence and before MRR - occurences one per test executed, or one per all tests
    PTR - after corresponding PIR and before corresponding PRR - occurences 1 per parametric test
    MPR - after corresponding PIR and before corresponding PRR - occurences 1 per multiple-result parametric test
    FTR - after corresponding PIR and before corresponding PRR - occurences 1 per functional test
    BPS - after PIR and before PRR - occurences 0 or more
    EPS - after corresponding BPS and before PRR - occurences 0 or more
    GDR - after initial sequence and before MRR - occurences 0 or more
    DTR - after initial sequence and before MRR - occurences 0 or more

  An STDF file may contain one or more devices.  The lot identifier
  may be printed once at the beginning of testing, or once per device.

  STEP        = DTR.TEXT_DAT = ">>> STEP #: <step>"                OR DTR.TEXT_DAT = "STEP #: <step>"
  temperature = DTR.TEXT_DAT = ">>> TEMPERATURE : <temp>"          OR DTR.TEXT_DAT = "TEMPERATURE: <temp>"           OR MIR.TST_TEMP
  lot_id      = DTR.TEXT_DAT = ">>> LOT # : <lot_id>"              OR DTR.TEXT_DAT = "LOT # : <lot_id>"              OR MIR.LOT_ID
  sublot_id   = DTR.TEXT_DAT = ">>> SUBLOT # : <sublot_id>"        OR MIR.SBLOT_ID
  Wafer       = DTR.TEXT_DAT = ">>> WAFER # : <wafer_id>"          OR WIR.wafer_id 
  Device      = DTR.TEXT_DAT = ">>> DEVICE_NUMBER : <device_name>" OR DTR.TEXT_DAT = "DEVICE_NUMBER : <device_name>" OR MIR.PART_TYP
  --------------------------------------------------------------------

  The device serial ID is identified as follows:
  DTR.TEXT_DAT = "TEXT_DATA : S/N : <serial_id>"
  PRR.part_id field or PRR.x_coord and PRR.y_coord
  All devices will also get a time stamp equal to MIR.start_t + (site_num*head_num) * PRR.test_t / (num_sites*num_heads);
  where site numbers are 1-based

  --------------------------------------------------------------------
  Each test will get a test id
  TestIDs consist of a test name, test number, duplicate number, and optionally a pin.
  For a test to be considered a duplicate, it must have the following:
  1. Same test name and test number,
  2. Same record type MPR, PTR, or FTR
  3. same pin
  3. Each test is numbered in sequential order for testflow analysis
  --------------------------------------------------------------------
  The following following is done at the file level:
  1. build pin maps
  2. Extract header information
  3. fill in missing data to test records
  4. build test IDs, and number test ordering
  5. compute timestamp for each device
  6. Scale units and values
  7. sort records by timestamp

 */
module makechip.StdfFile;
import makechip.Stdf;
import makechip.Descriptors;
import makechip.CmdOptions;
import std.algorithm.iteration;
import std.conv;
import std.string;
import std.typecons;
import makechip.DefaultValueDatabase;
import std.stdio;

class HeaderInfo
{
    private const bool ignoreMiscItems;
    const string step;
    const string temperature;
    const string lot_id;
    const string sublot_id;
    const string wafer_id;
    const string devName;
    private string[const string] headerItems;

    this(bool ignoreMiscItems, string step, string temperature, string lot_id, string sublot_id, string wafer_id, string devName)
    {
        this.ignoreMiscItems = ignoreMiscItems;
        this.step = step;
        this.temperature = temperature;
        this.lot_id = lot_id;
        this.sublot_id = sublot_id;
        this.wafer_id = wafer_id;
        this.devName = devName;
    }

    public bool isWafersort() @safe pure nothrow { return wafer_id != ""; }

    public string[const string] getHeaderItems() @safe pure
    { 
        string[const string] hi;
        foreach (key; headerItems)
        {
            string value = headerItems.get(key, "");
            hi[key] = value;
        }
        return hi;
    } 

    override public string toString()
    {
        string s = "HeaderInfo:\n";
        s ~= "  devName = " ~ devName ~ "\n";
        s ~= "  step = " ~ step ~ "\n";
        s ~= "  temperature = " ~ temperature ~ "\n";
        s ~= "  lot_id = " ~ lot_id ~ "\n";
        s ~= "  sublot_id = " ~ sublot_id ~ "\n";
        s ~= "  wafer_id = " ~ wafer_id ~ "\n";
        s ~= "  ignoreMiscItems = " ~ to!string(ignoreMiscItems) ~ "\n";
        s ~= "  " ~ to!string(headerItems) ~ "\n";
        s ~= "  hashcode = " ~ to!string(toHash()) ~ "\n";
        return s;
    }

    override public bool opEquals(Object o) 
    {
        import std.stdio;
        if (o is null) return false;
        if (typeid(o) != typeid(this)) return false;
        HeaderInfo h = cast(HeaderInfo) o;
        if (ignoreMiscItems != h.ignoreMiscItems) return false;
        if (step != h.step) return false;
        if (temperature != h.temperature) return false;
        if (lot_id != h.lot_id) return false;
        if (sublot_id != h.sublot_id) return false;
        if (wafer_id != h.wafer_id) return false;
        if (devName != h.devName) return false;
        if (!ignoreMiscItems)
        {
            if (headerItems.length != h.headerItems.length) return false;
            foreach(key; headerItems.keys)
            {
                string value = headerItems[key];
                string value2 = headerItems.get(key, "");
                if (value != value2) return false;
            }
        }
        return true;
    }

    override public size_t toHash() const @safe pure nothrow
    {
        size_t hash = step.hashOf();
        hash = temperature.hashOf(hash);
        hash = lot_id.hashOf(hash);
        hash = sublot_id.hashOf(hash);
        hash = wafer_id.hashOf(hash);
        hash = devName.hashOf(hash);
        if (!ignoreMiscItems) hash = headerItems.hashOf(hash);
        hash = ignoreMiscItems ? hash ^ 0xAAAA : hash ^ 0x5555;
        return hash;
    }

}

struct StdfFile
{
    HeaderInfo hdr;
    const string filename;
    StdfRecord[] records;
    private const bool ignoreMiscHeaderItems;

    /**
      Options needed:
      noIgnoreMiscHeader;
     */
    this(string filename, CmdOptions options)
    {
        this.filename = filename;
        this.ignoreMiscHeaderItems = !options.noIgnoreMiscHeader; 
    }

    void load()
    {
        StdfReader stdf = new StdfReader(filename);
        stdf.read();
        stdf.close();
        records = stdf.getRecords();
        hdr = getHeaderInfo();
    }

    private HeaderInfo getHeaderInfo()
    {
        auto dtrs = records.filter!(r => r.recordType == Record_t.DTR).map!(a => cast(Record!DTR) a);
        Record!(MIR) mir;
        for (int i=0; i<records.length; i++)
        {
            if (records[i].recordType == Record_t.MIR)
            {
                mir = cast(Record!(MIR)) records[i];
                break;
            }
        }
        Record!(WIR) wir = null;
        for (int i=0; i<records.length; i++)
        {
            if (records[i].recordType == Record_t.WIR)
            {
                wir = cast(Record!(WIR)) records[i];
                break;
            }
        }
        string temp = mir.TST_TEMP;
        string step = "";
        string lot = mir.LOT_ID;
        string sblot = mir.SBLOT_ID;
        string device = mir.PART_TYP;
        string wafer = (wir is null) ? "" : wir.WAFER_ID;
//      writeln("WAFER = ", wafer);
        string[string] miscFields;
        foreach (dtr; dtrs)
        {
            string rec = strip(dtr.TEXT_DAT);
            auto toks = rec.split(":");
            // check for legacy headerfiels:
            if (toks.length == 2)
            {
                auto tok0 = toks[0].strip;
                auto tok1 = toks[1].strip;
                if (tok0 == "CUSTOMER") miscFields["CUSTOMER"] = tok1;
                else if (tok0 == "DEVICE NUMBER") device = tok1;
                else if (tok0 == "SOW") miscFields["SOW"] = tok1;
                else if (tok0 == "CUSTOMER PO#") miscFields["CUSTOMER PO#"] = tok1;
                else if (tok0 == "TESTER") miscFields["TESTER"] = tok1;
                else if (tok0 == "TEST PROGRAM") miscFields["TEST PROGRAM"] = tok1;
                else if (tok0 == "CONTROL SERIAL #s") miscFields["CONTROL SERIAL #s"] = tok1;
                else if (tok0 == "JOB #") miscFields["JOB #"] = tok1;
                else if (tok0 == "LOT #") lot = tok1;
                else if (tok0 == "STEP #") step = tok1;
                else if (tok0 == "TEMPERATURE") temp = tok1;
                else // check for normal header fields:
                {
                    if (rec[0..3] == ">>>") // it's a header field
                    {
                        rec = rec[3..$];
                        toks = rec.split(":");
                        tok0 = toks[0].strip;
                        tok1 = toks[1].strip;
                        if (tok0 == "STEP #") step = tok1;
                        else if (tok0 == "TEMPERATURE") temp = tok1;
                        else if (tok0 == "LOT #") lot = tok1;
                        else if (tok0 == "SUBLOT #") sblot = tok1;
                        else if (tok0 == "WAFER #") wafer = tok1;
                        else if (tok0 == "DEVICE_NUMBER" || tok0 == "DEVICE NUMBER") device = tok1;
                        else miscFields[tok0] = tok1;
                    }
                }
            }
        }
        HeaderInfo hdr = new HeaderInfo(ignoreMiscHeaderItems, step, temp, lot, sblot, wafer, device);
        foreach (key; miscFields.keys)
        {
            auto value = miscFields.get(key, "");
            hdr.headerItems[key] = value;
        }
        return hdr;
    }


}
