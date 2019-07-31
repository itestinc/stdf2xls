/**
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
import makechip.util.Collections;
import std.conv;
import std.typecons;
import makechip.CmdOptions;
import makechip.DefaultValueDatabase;

struct HeaderInfo
{
    string step;
    string temperature;
    string lot_id;
    string sublot_id;
    string wafer_id;
    string devName;
    string[string] headerItems;
}

struct Point
{
    int x;
    int y;
}

union SN
{
    string sn;
    Point xy;
}

private immutable string SERIAL_MARKER = "S/N";

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

union DTRValue
{
    float f;
    long l;
    ulong u;
    string s;
}

enum TestType
{
    FUNCTIONAL,
    PARAMETRIC,
    FLOAT,
    HEX_INT,
    DEC_INT,
    STRING
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
    const DTRValue result;
    string units;
    byte resScal;
    byte llmScal;
    byte hlmScal;
    const uint seqNum;

    /**
      CTOR for Functional Test
     */
    this(TestID id, ubyte site, ubyte head, ubyte testFlags, uint seqNum)
    {
        this.type = TestType.FUNCTIONAL;
        this.id = id;
        this.site = site;
        this.head = head;
        this.testFlags = testFlags;
        this.seqNum = seqNum;
        this.optFlags = 0;
        this.parmFlags = 0;
        this.result.f = float.nan;
    }

    /**
      CTOR for Parametric Test
     */
    this(TestID id, 
            ubyte site,
            ubyte head,
            ubyte testFlags,
            ubyte optFlags,
            ubyte parmFlags,
            float loLimit,
            float hiLimit,
            float result,
            string units,
            byte resScal,
            byte llmScal,
            byte hlmScal,
            uint seqNum)
    {
        this.type = TestType.PARAMETRIC;
        this.id = id;
        this.site = site; 
        this.head = head; 
        this.testFlags = testFlags;
        this.optFlags = optFlags;
        this.parmFlags = parmFlags;
        this.loLimit = loLimit;
        this.hiLimit = hiLimit;
        this.result.f = result;
        this.units = units;
        this.resScal = resScal;
        this.llmScal = llmScal;
        this.hlmScal = hlmScal;
        this.seqNum = seqNum;
    }

    /**
      CTOR for TEXT_DATA of type float
     */
    this(TestID id, ubyte site, ubyte head, float rslt, uint seqNum)
    {
        this.id = id;
        this.type = TestType.FLOAT;
        this.head = head;
        this.site = site;
        result.f = rslt;
        this.seqNum = seqNum;
        this.testFlags = 0;
        this.optFlags = 0;
        this.parmFlags = 0;
    }

    /**
      CTOR for TEXT_DATA of type hex int
     */
    this(TestID id, ubyte site, ubyte head, ulong rslt, uint seqNum)
    {
        this.id = id;
        this.type = TestType.HEX_INT;
        this.head = head;
        this.site = site;
        result.u = rslt;
        this.seqNum = seqNum;
        this.testFlags = 0;
        this.optFlags = 0;
        this.parmFlags = 0;
    }

    /**
      CTOR for TEXT_DATA of type dec int
     */
    this(TestID id, ubyte site, ubyte head, long  rslt, uint seqNum)
    {
        this.id = id;
        this.type = TestType.DEC_INT;
        this.head = head;
        this.site = site;
        result.l = rslt;
        this.seqNum = seqNum;
        this.testFlags = 0;
        this.optFlags = 0;
        this.parmFlags = 0;
    }

    /**
      CTOR for TEXT_DATA of type string
     */
    this(TestID id, ubyte site, ubyte head, string rslt, uint seqNum)
    {
        this.id = id;
        this.type = TestType.STRING;
        this.head = head;
        this.site = site;
        result.s = rslt;
        this.seqNum = seqNum;
        this.testFlags = 0;
        this.optFlags = 0;
        this.parmFlags = 0;
    }

    public bool pass()
    {
        assert(type == TestType.PARAMETRIC || type == TestType.FUNCTIONAL);
        return !failed();
    }

    public bool failed()            { return (testFlags & 0x80) == 0x80; }
    public bool alarm()             { return (testFlags & 0x01) == 0x01; }
    public bool unreliable()        { return (testFlags & 0x04) == 0x04; }
    public bool timeout()           { return (testFlags & 0x08) == 0x08; }
    public bool notExecuted()       { return (testFlags & 0x10) == 0x10; }
    public bool abort()             { return (testFlags & 0x20) == 0x20; }
    public bool passFailInvalid()   { return (testFlags & 0x40) == 0x40; }
    public bool resScalInvalid()    { return (optFlags  & 0x01) == 0x01; }
    public bool useDefaultLoLimit() { return (optFlags  & 0x10) == 0x10; }
    public bool useDefaultHiLimit() { return (optFlags  & 0x20) == 0x20; }
    public bool noLoLimit()         { return (optFlags  & 0x40) == 0x40; }
    public bool noHiLimit()         { return (optFlags  & 0x80) == 0x80; }
    public bool scaleError()        { return (parmFlags & 0x01) == 0x01; }
    public bool driftError()        { return (parmFlags & 0x02) == 0x02; }
    public bool oscillation()       { return (parmFlags & 0x04) == 0x04; }
    public bool useGEQwithLoLomit() { return (parmFlags & 0x40) == 0x40; }
    public bool useLEQwithHiLimit() { return (parmFlags & 0x80) == 0x80; }
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

enum PMRNameType
{
    AUTO,
    CHANNEL,
    PHYSICAL,
    LOGICAL
}

class StdfPinData
{
    MultiMap!(string, ubyte, ubyte, ushort) map;

    public this()
    {
        map = new MultiMap!(string, ubyte, ubyte, ushort)();
    }

    void set(ubyte head, ubyte site, ushort index, string pinName)
    {
        map.put(pinName, head, site, index);
    }

    public string get(ubyte head, ubyte site, ushort index)
    {
        return map.get("", head, site, index);
    }
}

struct StdfFile
{
    StdfPinData pinData;
    HeaderInfo hdr;
    DefaultValueDatabase dvd;
    DeviceResult[] devices;

    /**
      Options needed:
      bool textDump - dumps STDF text format while reading the STDF
      bool byteDump - dumps byte array for each reacord while reading the STDF
      PMRNameType - use channel name, physical name, logical name, or auto detect for PMR pin indicies
     */
    this(string filename, Options options, PMRNameType pmrNameType)
    {
        uint seq = 0;
        StdfReader stdf = new StdfReader(options, filename);
        stdf.read();
        StdfRecord[] rs = stdf.getRecords();
        dvd = new DefaultValueDatabase();
        // 1. Get the MIR
        import std.algorithm.iteration;
        auto r = rs.filter!(a => a.recordType == Record_t.MIR);
        Record!MIR mir = cast(Record!MIR) r.front;
        if (pmrNameType == PMRNameType.AUTO)
        {
            if (mir.TSTR_TYP == "fusion_cx" || 
                    mir.TSTR_TYP == "CTX" || 
                    mir.EXEC_VER == "Smartest : s/w rev. 8")
            {
                pmrNameType = PMRNameType.PHYSICAL;
            }
            else
            {
                pmrNameType = PMRNameType.CHANNEL;
            }
        }
        // 2. build the pin maps for MPRs
        pinData = buildPinMap(pmrNameType, rs);
        // 3. Store default values and create test records
        // first find min and max site and head numbers:
        ubyte minSite = 255;
        ubyte maxSite = 0;
        ubyte minHead = 255;
        ubyte maxHead = 0;
        ubyte[ubyte] heads;
        ubyte[ubyte] sites;
        bool wafersort = false;
        foreach (rec; rs)
        {
            if (rec.recordType == Record_t.PRR)
            {
                Record!PRR prr = cast(Record!PRR) rec;
                heads[prr.HEAD_NUM.getValue()] = prr.HEAD_NUM;
                sites[prr.SITE_NUM.getValue()] = prr.SITE_NUM;
                if (prr.SITE_NUM < minSite) minSite = prr.SITE_NUM;
                if (prr.SITE_NUM > maxSite) maxSite = prr.SITE_NUM;
                if (prr.HEAD_NUM < minHead) minHead = prr.HEAD_NUM;
                if (prr.HEAD_NUM > maxHead) maxHead = prr.HEAD_NUM;
            }
            if (rec.recordType == Record_t.WCR || rec.recordType == Record_t.WIR)
            {
                wafersort = true;
            }
        }
        import std.stdio;
        if (!options.quiet) writeln("INFO: missing values detected");
        auto dupNums = new MultiMap!(DupNumber_t, Record_t, TestNumber_t, Site_t, Head_t)();
        DeviceResult[][] dr;
        dr.length = maxSite;
        for (int i=0; i<dr.length; i++) dr[i].length = maxHead;
        size_t numSites = sites.length;
        size_t numHeads = heads.length;
        ulong time = mir.START_T;
        string serial_number = "";
        PartID pid;
        import std.string;
        foreach (rec; rs)
        {
            switch (rec.recordType.ordinal)
            {
                case Record_t.FTR.ordinal:
                    auto ftr = cast(Record!FTR) rec;
                    uint dup = dupNums.get(uint.max, ftr.recordType, ftr.TEST_NUM, ftr.SITE_NUM, ftr.HEAD_NUM);
                    if (dup == uint.max) dup = 1; else dup++;
                    dupNums.put(dup, ftr.recordType, ftr.TEST_NUM, ftr.SITE_NUM, ftr.HEAD_NUM);
                    dvd.setFTRDefaults(ftr, dup);
                    string testName = ftr.TEST_TXT.isEmpty() ? dvd.getDefaultTestName(Record_t.FTR, ftr.TEST_NUM, dup) : ftr.TEST_TXT;
                    string pin = "";
                    if (options.extractPin)
                    {
                        for (int i=0; i<options.delims.length; i++)
                        {
                            auto p = testName.indexOf(options.delims[i]);
                            if (p >= 0)
                            {
                                pin = testName[p+1..$].dup;
                                testName = testName[0..p];
                                break;
                            }
                        }
                    }
                    TestID id = TestID.getTestID(Record_t.FTR, pin, ftr.TEST_NUM, testName, dup);
                    TestRecord tr = new TestRecord(id, ftr.SITE_NUM, ftr.HEAD_NUM, ftr.TEST_FLG, seq);
                    dr[ftr.SITE_NUM - minSite][ftr.HEAD_NUM - minHead].tests ~= tr;
                    seq++;
                    break;

                case Record_t.PTR.ordinal:
                    auto ptr = cast(Record!PTR) rec;
                    uint dup = dupNums.get(uint.max, ptr.recordType, ptr.TEST_NUM, ptr.SITE_NUM, ptr.HEAD_NUM);
                    if (dup == uint.max) dup = 1; else dup++;
                    dupNums.put(dup, ptr.recordType, ptr.TEST_NUM, ptr.SITE_NUM, ptr.HEAD_NUM);
                    dvd.setPTRDefaults(ptr, dup);
                    string testName = ptr.TEST_TXT.isEmpty() ? dvd.getDefaultTestName(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.TEST_TXT;
                    string pin = "";
                    if (options.extractPin)
                    {
                        for (int i=0; i<options.delims.length; i++)
                        {
                            auto p = testName.indexOf(options.delims[i]);
                            if (p >= 0)
                            {
                                pin = testName[p+1..$].dup;
                                testName = testName[0..p];
                            }
                        }
                    }
                    TestID id = TestID.getTestID(Record_t.PTR, pin, ptr.TEST_NUM, testName, dup);
                    ubyte optFlags = ptr.OPT_FLAG.isEmpty() ? dvd.getDefaultOptFlag(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.OPT_FLAG;
                    ubyte parmFlags = ptr.PARM_FLG;
                    float loLimit = ptr.LO_LIMIT.isEmpty() ? dvd.getDefaultLoLimit(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.LO_LIMIT;
                    float hiLimit = ptr.HI_LIMIT.isEmpty() ? dvd.getDefaultHiLimit(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.HI_LIMIT;
                    float result = ptr.RESULT;
                    string units = ptr.UNITS.isEmpty() ? dvd.getDefaultUnits(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.UNITS;
                    byte resScal = ptr.RES_SCAL.isEmpty() ? dvd.getDefaultResScal(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.RES_SCAL;
                    byte llmScal = ptr.LLM_SCAL.isEmpty() ? dvd.getDefaultLlmScal(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.LLM_SCAL;
                    byte hlmScal = ptr.HLM_SCAL.isEmpty() ? dvd.getDefaultHlmScal(Record_t.PTR, ptr.TEST_NUM, dup) : ptr.HLM_SCAL;
                    // scale result, limits, and units:
                    TestRecord tr = new TestRecord(id, ptr.SITE_NUM, ptr.HEAD_NUM, ptr.TEST_FLG, optFlags,
                            parmFlags, loLimit, hiLimit, result, units, resScal, llmScal, hlmScal, seq);
                    dr[ptr.SITE_NUM - minSite][ptr.HEAD_NUM - minHead].tests ~= tr;
                    seq++;
                    break;

                case Record_t.MPR.ordinal:
                    auto mpr = cast(Record!MPR) rec;
                    uint dup = dupNums.get(uint.max, rec.recordType, mpr.TEST_NUM, mpr.SITE_NUM, mpr.HEAD_NUM);
                    if (dup == uint.max) dup = 1; else dup++;
                    dupNums.put(dup, rec.recordType, mpr.TEST_NUM, mpr.SITE_NUM, mpr.HEAD_NUM);
                    dvd.setMPRDefaults(mpr, dup);
                    string testName = mpr.TEST_TXT.isEmpty() ? dvd.getDefaultTestName(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.TEST_TXT;
                    if (options.extractPin)
                    {
                        for (int i=0; i<options.delims.length; i++)
                        {
                            auto p = testName.indexOf(options.delims[i]);
                            if (p >= 0)
                            {
                                testName = testName[0..p];
                            }
                        }
                    }
                    ubyte optFlags = mpr.OPT_FLAG.isEmpty() ? dvd.getDefaultOptFlag(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.OPT_FLAG;
                    ubyte parmFlags = mpr.PARM_FLG;
                    float loLimit = mpr.LO_LIMIT.isEmpty() ? dvd.getDefaultLoLimit(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.LO_LIMIT;
                    float hiLimit = mpr.HI_LIMIT.isEmpty() ? dvd.getDefaultHiLimit(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.HI_LIMIT;
                    string units = mpr.UNITS.isEmpty() ? dvd.getDefaultUnits(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.UNITS;
                    byte resScal = mpr.RES_SCAL.isEmpty() ? dvd.getDefaultResScal(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.RES_SCAL;
                    byte llmScal = mpr.LLM_SCAL.isEmpty() ? dvd.getDefaultLlmScal(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.LLM_SCAL;
                    byte hlmScal = mpr.HLM_SCAL.isEmpty() ? dvd.getDefaultHlmScal(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.HLM_SCAL;
                    U2[] indicies = mpr.RTN_INDX.isEmpty() ? dvd.getDefaultPinIndicies(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.RTN_INDX.getValue();
                    foreach(i, rslt; mpr.RTN_RSLT.getValue())
                    {
                        ushort pinIndex = indicies[i];
                        float result = mpr.RTN_INDX.getValue()[i];
                        string pin = pinData.get(mpr.HEAD_NUM, mpr.SITE_NUM, pinIndex);
                        TestID id = TestID.getTestID(Record_t.MPR, pin, mpr.TEST_NUM, testName, dup);
                        TestRecord tr = new TestRecord(id, mpr.SITE_NUM, mpr.HEAD_NUM, mpr.TEST_FLG, optFlags, parmFlags, 
                                loLimit, hiLimit, result, units, resScal, llmScal, hlmScal, seq);
                        dr[mpr.SITE_NUM - minSite][mpr.HEAD_NUM - minHead].tests ~= tr;
                        seq++;
                    }
                    break;
                    /**
                      Note TEXT_DATA records have the following format:
                      TEXT_DATA : <test_name> : <value> [<units>] : <test_number> [: <site_number> [: <format> [: <head_number>]]]
                     */
                case Record_t.DTR.ordinal:
                    auto dtr = cast(Record!DTR) rec;
                    string text = strip(dtr.TEXT_DAT.getValue());
                    if (text[0..9] == "TEXT_DATA")
                    {
                        auto toks = text.split(":");
                        if (toks.length < 4 && toks[1] != SERIAL_MARKER)
                        {
                            if (!options.quiet)
                            {
                                writeln("Warning: invalid TEXT_DATA format: ", text);
                            }
                        }
                        else if (toks[1] == SERIAL_MARKER)
                        {
                            serial_number = strip(toks[2]);
                            pid = PartID(strip(toks[2]));
                        }
                        else
                        {
                            string testName = strip(toks[1]);
                            string pin = "";
                            if (options.extractPin)
                            {
                                for (int i=0; i<options.delims.length; i++)
                                {
                                    auto p = testName.indexOf(options.delims[i]);
                                    if (p >= 0)
                                    {
                                        pin = testName[p+1..$].dup;
                                        testName = testName[0..p];
                                        break;
                                    }
                                }
                            }
                            //FLOAT,
                            //HEX_INT,
                            //DEC_INT,
                            //STRING
                            string valueUnitsOpt = strip(toks[2]);
                            string testNumber = strip(toks[3]);
                            string site = "1";
                            string format = "";
                            string head = "1";
                            string value = "";
                            string units = "";
                            if (toks.length > 4) site = strip(toks[4]);
                            if (toks.length > 5) format = strip(toks[5]);
                            if (toks.length > 6) head = strip(toks[6]);
                            long index = valueUnitsOpt.indexOf(' ');
                            if (index <= 0) index = valueUnitsOpt.indexOf('\t');
                            if (index > 0)
                            {
                                value = valueUnitsOpt[0..index];
                                units = strip(valueUnitsOpt[index..$]);
                            }
                            else
                            {
                                value = valueUnitsOpt;
                            }
                            uint dup = dupNums.get(uint.max, rec.recordType, to!uint(testNumber), to!ubyte(site), to!ubyte(head));
                            if (dup == uint.max) dup = 1; else dup++;
                            dupNums.put(dup, rec.recordType, to!uint(testNumber), to!ubyte(site), to!ubyte(head));
                            TestID id = TestID.getTestID(Record_t.DTR, pin, to!uint(testNumber), testName, dup);
                            TestRecord tr = null;
                            if (format == "float")
                            {
                                tr = new TestRecord(id, to!ubyte(site), to!ubyte(head), to!(float)(value), seq);
                            }
                            else if (format == "hex_int")
                            {
                                tr = new TestRecord(id, to!ubyte(site), to!ubyte(head), to!(ulong)(value), seq);
                            }
                            else if (format == "dec_int")
                            {
                                tr = new TestRecord(id, to!ubyte(site), to!ubyte(head), to!(long)(value), seq);
                            }
                            else // format is string
                            {
                                tr = new TestRecord(id, to!ubyte(site), to!ubyte(head), value, seq);
                            }
                            seq++;
                            dr[to!(ubyte)(site) - minSite][to!(ubyte)(head) - minHead].tests ~= tr;
                        }
                    }
                    else // could be header info
                    {
                        if (text.startsWith("STEP #"))
                        {
                            auto i = text.indexOf(':');
                            auto ss = text[i+1..$];
                            hdr.step = strip(ss);
                        }
                        else if (text.startsWith("TEMPERATURE"))
                        {
                            auto i = text.indexOf(':');
                            auto ss = text[i+1..$];
                            hdr.temperature = strip(ss);
                        }
                        else if (text.startsWith("LOT #"))
                        {
                            auto i = text.indexOf(':');
                            auto ss = text[i+1..$];
                            hdr.lot_id = strip(ss);
                        }
                        else if (text.startsWith("DEVICE_NUMBER"))
                        {
                            auto i = text.indexOf(':');
                            auto ss = text[i+1..$];
                            hdr.devName = strip(ss);
                        }
                        else if (text.startsWith(">>>"))
                        {
                            string s1 = text[3..$];
                            string s2 = strip(s1);
                            auto i = s2.indexOf(':');
                            string name = strip(s2[0..i]);
                            string val = strip(s2[i+1..$]);
                            if (name == "STEP #") hdr.step = val;
                            else if (name == "TEMPERATURE") hdr.temperature = val;
                            else if (name == "LOT") hdr.lot_id = val;
                            else if (name == "SUBLOT") hdr.sublot_id = val;
                            else if (name == "WAFER") hdr.wafer_id = val;
                            else if (name == "DEVICE_NUMBER") hdr.devName = val;
                            else
                            {
                                hdr.headerItems[name] = val;
                            }
                        }
                        else
                        {
                            if (!options.quiet)
                            {
                                writeln("Warning: unknown text field: ", text);
                            }
                        }
                    }
                    break;
                case Record_t.PRR.ordinal:
                    dupNums = new MultiMap!(uint, Record_t, TestNumber_t, Site_t, Head_t)();
                    Record!(PRR) prr = cast(Record!(PRR)) rec;
                    if (serial_number == "")
                    {
                        if (wafersort)
                        {
                            pid = PartID(prr.X_COORD, prr.Y_COORD);
                        }
                        else
                        {
                            pid = PartID(prr.PART_ID);
                        }
                    }
                    serial_number = "";
                    uint head = prr.HEAD_NUM;
                    uint site = prr.SITE_NUM;
                    if (minSite == 0) site++;
                    if (minHead == 0) head++;
                    if (hdr.temperature == "") hdr.temperature = mir.TST_TEMP;
                    if (hdr.lot_id == "") hdr.lot_id = mir.LOT_ID;
                    if (hdr.sublot_id == "") hdr.sublot_id = mir.SBLOT_ID;
                    if (hdr.devName == "") hdr.devName = mir.PART_TYP;
                    time += ((site * head) * prr.TEST_T) / (numSites * numHeads);
                    dr[site - minSite][head - minHead].devId = pid;
                    dr[site - minSite][head - minHead].site = site;
                    dr[site - minSite][head - minHead].head = head;
                    dr[site - minSite][head - minHead].tstamp = time;
                    dr[site - minSite][head - minHead].hdr = hdr;
                    dr[site - minSite][head - minHead].hdr.headerItems = hdr.headerItems.dup;
                    devices ~= dr[site - minSite][head - minHead];
                    seq = 0;
                    break;
                default:
            }
        }
    }
}

private StdfPinData buildPinMap(PMRNameType nameType, StdfRecord[] rs)
{
    import std.algorithm.iteration;
    StdfPinData pmap = new StdfPinData();
    auto pmrs = rs.filter!(a => a.recordType == Record_t.PMR);
    switch (nameType) with (PMRNameType)
    {
        case CHANNEL:
            foreach (r; pmrs)
            {
                Record!PMR pmr = cast(Record!PMR) r;
                pmap.set(pmr.HEAD_NUM, pmr.SITE_NUM, pmr.PMR_INDX, pmr.CHAN_NAM);
            }
            break;
        case PHYSICAL:
            foreach (r; pmrs)
            {
                Record!PMR pmr = cast(Record!PMR) r;
                pmap.set(pmr.HEAD_NUM, pmr.SITE_NUM, pmr.PMR_INDX, pmr.PHY_NAM);
            }
            break;
        case LOGICAL:
            foreach (r; pmrs)
            {
                Record!PMR pmr = cast(Record!PMR) r;
                pmap.set(pmr.HEAD_NUM, pmr.SITE_NUM, pmr.PMR_INDX, pmr.LOG_NAM);
            }
            break;
        default:
            import std.stdio;
            writeln("Program bug PMR name type not set");
    }

    return pmap;
}

class TestID
{
    private static MultiMap!(TestID, const Record_t, const string, const uint, const string, const uint) map;
    public const Record_t type;
    public const string pin;
    public const uint testNumber;
    public const string testName;
    public const uint dup;

    private this(const Record_t type, const string pin, const uint testNumber, const string testName, const uint dup)
    {
        this.type = type;
        this.pin = pin;
        this.testNumber = testNumber;
        this.testName = testName;
        this.dup = dup;
    }

    public static TestID getTestID(const Record_t type, const string pin, const uint testNumber, const string testName, const uint dup)
    {
        TestID tid = map.get(null, type, pin, testNumber, testName, dup);
        if (tid is null)
        {
            tid = new TestID(type, pin, testNumber, testName, dup);
            map.put(tid, type, pin, testNumber, testName, dup);
        }
        return tid;
    }

    override public string toString()
    {
        if (type == Record_t.FTR || pin == "")
        {
            return "[" ~ to!string(type) ~ ", " ~ to!string(testNumber) ~ ", " ~ testName ~ ", " ~ to!string(dup) ~ "]";
        }
        return "[" ~ to!string(type) ~ ", " ~ pin ~ ", " ~ to!string(testNumber) ~ ", " ~ testName ~ ", " ~ to!string(dup) ~ "]";
    }

    public static TestID get(const Record_t type, const string pin, const uint testNumber, const string testName, const uint dup)
    {
        return map.get(null, type, pin, testNumber, testName, dup);
    }

    override public bool opEquals(Object rhs)
    {
        if (rhs is this) return true;
        return false;
    }
}

private void normalizeValues(TestRecord tr)
{
    int scale = findScale(tr);
    float ll = scaleValue(tr.loLimit, scale);
    float hl = scaleValue(tr.hiLimit, scale);
    string units = scaleUnits(tr.units, scale);
    float value = getScaledResult(tr, scale);
    tr.loLimit = ll;
    tr.hiLimit = hl;
    tr.units = units;
    tr.result = value;
}

private float getScaledResult(TestRecord tr, int scale)
{
    if (tr.result == float.nan) return(tr.result);
    if (tr.units == "") return tr.result;
    return scaleValue(tr.result, scale);
}

private int findScale(TestRecord tr)
{
    import std.math;
    float val = 0.0f;
    if (tr.hiLimit == float.nan && tr.loLimit == float.nan) return(0);
    if (tr.loLimit == float.nan) val = fabs(hiLimit);
    else if (tr.hiLimit == float.nan) val = fabs(loLimit);
    else val = (fabs(tr.hiLimit) > fabs(tr.loLimit)) ? fabs(tr.hiLimit) : fabs(tr.loLimit);
    int scale = 0;
    if (val <= 1.0E-6f) scale = 9;
    else if (val <= 0.001f) scale = 6;
    else if (val <= 1.0f) scale = 3;
    else if (val <= 1000.0f) scale = 0;
    else if (val <= 1000000.0f) scale = -3;
    else if (val <= 1E9f) scale = -6;
    else scale = -9;
    return(scale);
}

private float scaleValue(float value, int scale)
{
    if (value == float.nan) return(value);
    switch (scale)
    {
        case -12: value /= 1E12f; break;
        case -9:  value /= 1E9f; break;
        case -6:  value /= 1E6f; break;
        case -3:  value /= 1E3f; break;
        case  3:  value *= 1E3f; break;
        case  6:  value *= 1E6f; break;
        case  9:  value *= 1E9f; break;
        case 12:  value *= 1E12f; break;
        default:
    }
    return(value);
}

private string scaleUnits(string units, int scale)
{
    if (units == "") return("");
    String u = units;
    switch (scale)
    {
        case -12: u = "T" + units; break;
        case -9:  u = "G" + units; break;
        case -6:  u = "M" + units; break;
        case -3:  u = "K" + units; break;
        case  0:  u = units;       break;
        case  3:  u = "m" + units; break;
        case  6:  u = "u" + units; break;
        case  9:  u = "n" + units; break;
        case 12:  u = "p" + units; break;
        case 15:  u = "f" + units; break;
        default:
    }
    if (u.length() >= 3)
    {
        // Potential bug here. Tester may use uppercase letter when it should
        // be using a lower case letter.  Consequently we may not be able
        // to differentiate between milli and Mega
        String p = u.substring(0, 2);
        boolean fix = false;
        if      (p.equals("mT")) { p = "G"; fix = true; }
        else if (p.equalsIgnoreCase("uT")) { p = "M"; fix = true; }
        else if (p.equalsIgnoreCase("nT")) { p = "K"; fix = true; }
        else if (p.equalsIgnoreCase("pT")) { p = "";  fix = true; }
        else if (p.equalsIgnoreCase("fT")) { p = "m"; fix = true; }
        else if (p.equalsIgnoreCase("KG")) { p = "T"; fix = true; }
        else if (p.equals("mG")) { p = "M"; fix = true; }
        else if (p.equalsIgnoreCase("uG")) { p = "K"; fix = true; }
        else if (p.equalsIgnoreCase("nG")) { p = "";  fix = true; }
        else if (p.equalsIgnoreCase("pG")) { p = "m"; fix = true; }
        else if (p.equalsIgnoreCase("fG")) { p = "u"; fix = true; }
        else if (p.equals("MM")) { p = "T"; fix = true; }
        else if (p.equals("KM") || p.equals("kM")) { p = "G"; fix = true; }
        else if (p.equals("mM")) { p = "K"; fix = true; }
        else if (p.equals("uM") || p.equals("UM")) { p = "";  fix = true; }
        else if (p.equals("nM") || p.equals("NM")) { p = "m"; fix = true; }
        else if (p.equals("pM") || p.equals("PM")) { p = "u"; fix = true; }
        else if (p.equals("fM") || p.equals("FM")) { p = "n"; fix = true; }
        else if (p.equalsIgnoreCase("GK")) { p = "T"; fix = true; }
        else if (p.equals("MK") || p.equals("Mk")) { p = "G"; fix = true; }
        else if (p.equalsIgnoreCase("KK")) { p = "M"; fix = true; }
        else if (p.equals("mK") || p.equals("mk")) { p = "";  fix = true; }
        else if (p.equalsIgnoreCase("uK")) { p = "m"; fix = true; }
        else if (p.equalsIgnoreCase("nK")) { p = "u"; fix = true; }
        else if (p.equalsIgnoreCase("pK")) { p = "n"; fix = true; }
        else if (p.equalsIgnoreCase("fK")) { p = "p"; fix = true; }
        else if (p.equals("Tm")) { p = "G"; fix = true; }
        else if (p.equals("Gm")) { p = "M"; fix = true; }
        else if (p.equals("Mm")) { p = "K"; fix = true; }
        else if (p.equals("Km") || p.equals("km")) { p = "";  fix = true; }
        else if (p.equals("mm")) { p = "u"; fix = true; }
        else if (p.equals("um") || p.equals("Um")) { p = "n"; fix = true; }
        else if (p.equals("nm") || p.equals("Nm")) { p = "p"; fix = true; }
        else if (p.equals("pm") || p.equals("Pm")) { p = "f"; fix = true; }
        else if (p.equalsIgnoreCase("Tu")) { p = "M"; fix = true; }
        else if (p.equalsIgnoreCase("Gu")) { p = "K"; fix = true; }
        else if (p.equals("Mu") || p.equals("MU")) { p = "";  fix = true; }
        else if (p.equalsIgnoreCase("Ku")) { p = "m"; fix = true; }
        else if (p.equals("mu") || p.equals("mU")) { p = "n"; fix = true; }
        else if (p.equalsIgnoreCase("uu")) { p = "p"; fix = true; }
        else if (p.equalsIgnoreCase("nu")) { p = "f"; fix = true; }
        else if (p.equalsIgnoreCase("Tn")) { p = "K"; fix = true; }
        else if (p.equalsIgnoreCase("Gn")) { p = "";  fix = true; }
        else if (p.equals("Mn") || p.equals("MN")) { p = "m"; fix = true; }
        else if (p.equalsIgnoreCase("Kn")) { p = "u"; fix = true; }
        else if (p.equals("mn") || p.equals("mN")) { p = "p"; fix = true; }
        else if (p.equalsIgnoreCase("un")) { p = "f"; fix = true; }
        else if (p.equalsIgnoreCase("Tp")) { p = "";  fix = true; }
        else if (p.equalsIgnoreCase("Gp")) { p = "m"; fix = true; }
        else if (p.equals("Mp") || p.equals("MP")) { p = "u"; fix = true; }
        else if (p.equalsIgnoreCase("Kp")) { p = "n"; fix = true; }
        else if (p.equals("mp") || p.equals("mP")) { p = "f"; fix = true; }
        else if (p.equalsIgnoreCase("Tf")) { p = "m"; fix = true; }
        else if (p.equalsIgnoreCase("Gf")) { p = "u"; fix = true; }
        else if (p.equals("Mf") || p.equals("MF")) { p = "n"; fix = true; }
        else if (p.equalsIgnoreCase("Kf")) { p = "p"; fix = true; }
        if (fix)
        {
            String newUnits = units.substring(1);
            u = p + newUnits;
        }
    }
    return(u);
}


