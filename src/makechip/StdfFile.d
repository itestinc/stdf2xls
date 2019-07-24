/**
    An STDF file may contain one or more devices.  The lot identifier
    is obtained in the following order:

    STEP        = DTR.TEXT_DAT = ">>> STEP #: <step>"                OR DTR.TEXT_DAT = "STEP #: <step>"
    temperature = DTR.TEXT_DAT = ">>> TEMPERATURE : <temp>"          OR DTR.TEXT_DAT = "TEMPERATURE: <temp>"           OR MIR.TST_TEMP
    lot_id      = DTR.TEXT_DAT = ">>> LOT # : <lot_id>"              OR DTR.TEXT_DAT = "LOT # : <lot_id>"              OR MIR.LOT_ID
    sublot_id   = DTR.TEXT_DAT = ">>> SUBLOT # : <sublot_id>"        OR MIR.SBLOT_ID
    Wafer       = DTR.TEXT_DAT = ">>> WAFER # : <wafer_id>"          OR WIR.wafer_id 
    Device      = DTR.TEXT_DAT = ">>> DEVICE_NUMBER : <device_name>" OR DTR.TEXT_DAT = "DEVICE_NUMBER : <device_name>" OR MIR.PART_TYP
    --------------------------------------------------------------------

    The device serial ID is identified as follows:
    DTR.TEXT_DAT = "TEXT_DATA : S/N : <serial_id>"
    PRR.part_id field or PRR.x_coord and PRR.y_cooir
    All devices will also get a time stamp equal to MIR.start_t + site_num * PRR.test_t / num_sites
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

    this(TestID id, ubyte site, ubyte head, ubyte testFlags)
    {
        this.type = TestType.FUNCTIONAL;
        this.id = id;
        this.site = site;
        this.head = head;
        this.testFlags = testFlags;
    }

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
         byte hlmScal)
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
    }

    this(TestID id,
         ubyte site,
         ubyte head,
         float rslt)
    {
        this.type = TestType.FLOAT;
        this.head = head;
        this.site = site;
        results.f = rslt;
    }

    this(TestID id,
         ubyte site,
         ubyte head,
         ulong rslt)
    {
        this.type = TestType.HEX_INT;
        this.head = head;
        this.site = site;
        result.u = rslt;
    }

    this(TestID id,
         ubyte site,
         ubyte head,
         long  rslt)
    {
        this.type = TestType.DEC_INT;
        this.head = head;
        this.site = site;
        result.l = rslt;
    }

    this(TestID id,
         ubyte site,
         ubyte headm
         string rslt)
    {
        this.type = TestType.STRING;
        this.head = head;
        this.site = site;
        result.s = rslt;
    }

    public bool pass()
    {
        assert(type == TestType.PARAMETRIC || type == TestType.FUNCTIONAL);
        if (type == TestType.Functional) return !failed();
        

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
    long tstamp;
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
        // 3. Extract header information:
        hdr = getHeaderInfo(mir, rs);
        // 4. Store default values and create test records
        // first find min and max site and head numbers:
        ubyte minSite = 255;
        ubyte maxSite = 0;
        ubyte minHead = 255;
        ubyte maxHead = 0;
        foreach (rec; rs)
        {
            if (rec.recordType == Record_t.PRR)
            {
                Record!PRR prr = cast(Record!PRR) rec;
                if (prr.SITE_NUM < minSite) minSite = prr.SITE_NUM;
                if (prr.SITE_NUM > maxSite) maxSite = prr.SITE_NUM;
                if (prr.HEAD_NUM < minHead) minHead = prr.HEAD_NUM;
                if (prr.HEAD_NUM > maxHead) maxHead = prr.HEAD_NUM;
            }
        }
        import std.stdio;
        if (!options.quiet) writeln("INFO: missing values detected");
        auto dupNums = new MultiMap!(DupNumber_t, Record_t, TestNumber_t, Site_t, Head_t)();
        DeviceResult[][] dr = new DeviceResult[1 + maxSite - minSite][1 + maxHead - minHead];
        foreach (rec; rs)
        {
            switch (rec.recordType.ordinal)
            {
            case Record_t.FTR.ordinal:
                auto ftr = cast(Record!FTR) rec;
                uint dup = dupNums.get(uint.max, r.recordType, ftr.TEST_NUM, ftr.SITE_NUM, ftr.HEAD_NUM);
                if (dup == uint.max) dup = 1; else dup++;
                dupNums.put(dup, r.recordType, ftr.TEST_NUM, ftr.SITE_NUM, ftr.HEAD_NUM);
                dvd.setFTRDefaults(ftr, dup);
                string testName = ftr.TEST_TXT.isEmpty() ? dvd.getDefaultTestName(Record_t.FTR, ftr.TEST_NUM, dup);
                string pin = "";
                if (options.extractPin)
                {
                    auto p = testName.indexOf(options.pinDelim);
                    if (p >= 0)
                    {
                        pin = testName[p+1..$].dup;
                        testName = testName[0, p];
                    }
                }
                TestID id = TestID.getTestID(Record_t.FTR, pin, ftr.TEST_NUM, testName, dup);
                TestRecord tr = new TestRecord(id, ftr.SITE_NUM, ftr.HEAD_NUM, ftr.TEST_FLG);
                dr[ftr.SITE_NUM - minSite][ftr.HEAD_NUM - minHead].tests ~= tr;
                break;

            case Record_t.PTR.ordinal:
                auto ptr = cast(Record!PTR) r;
                uint dup = dupNums.get(uint.max, r.recordType, ptr.TEST_NUM, ptr.SITE_NUM, ptr.HEAD_NUM);
                if (dup == uint.max) dup = 1; else dup++;
                dupNums.put(dup, r.recordType, ptr.TEST_NUM, ptr.SITE_NUM, ptr.HEAD_NUM);
                dvd.setPTRDefaults(ptr, dup);
                string testName = ptr.TEST_TXT.isEmpty() ? dvd.getDefaultTestName(Record_t.PTR, ptr.TEST_NUM, dup);
                string pin = "";
                if (options.extractPin)
                {
                    auto p = testName.indexOf(options.pinDelim);
                    if (p >= 0)
                    {
                        pin = testName[p+1..$].dup;
                        testName = testName[0, p];
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
                ParametricTestRecord tr = new ParametricTestRecord(id, ptr.SITE_NUM, ptr.HEAD_NUM, ptr.TST_FLAG, optFlags,
                                                                   parmFlags, loLimit, hiLimit, result, units, resScal, llmScal, hlmScal);
                dr[ptr.SITE_NUM - minSite][ptr.HEAD_NUM - minHead].tests ~= tr;
                break;

            case Record_t.MPR.ordinal:
                auto mpr = cast(Record!MPR) r;
                uint dup = dupNums.get(uint.max, r.recordType, mpr.TEST_NUM, mpr.SITE_NUM, mpr.HEAD_NUM);
                if (dup == uint.max) dup = 1; else dup++;
                dupNums.put(dup, r.recordType, mpr.TEST_NUM, mpr.SITE_NUM, mpr.HEAD_NUM);
                dvd.setMPRDefaults(mpr, dup);
                string testName = mpr.TEST_TXT.isEmpty() ? dvd.getDefaultTestName(Record_t.MPR, ptr.TEST_NUM, dup);
                ubyte optFlags = mpr.OPT_FLAG.isEmpty() ? dvd.getDefaultOptFlag(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.OPT_FLAG;
                ubyte parmFlags = mpr.PARM_FLG;
                float loLimit = mpr.LO_LIMIT.isEmpty() ? dvd.getDefaultLoLimit(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.LO_LIMIT;
                float hiLimit = mpr.HI_LIMIT.isEmpty() ? dvd.getDefaultHiLimit(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.HI_LIMIT;
                float result = mpr.RESULT;
                string units = mpr.UNITS.isEmpty() ? dvd.getDefaultUnits(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.UNITS;
                byte resScal = mpr.RES_SCAL.isEmpty() ? dvd.getDefaultResScal(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.RES_SCAL;
                byte llmScal = mpr.LLM_SCAL.isEmpty() ? dvd.getDefaultLlmScal(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.LLM_SCAL;
                byte hlmScal = mpr.HLM_SCAL.isEmpty() ? dvd.getDefaultHlmScal(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.HLM_SCAL;
                U2[] indicies = mpr.RTN_INDX.isEmpty() ? dvd.getDefaultPinIndicies(Record_t.MPR, mpr.TEST_NUM, dup) : mpr.RTN_INDX.getValue();
                foreach(i, rslt; mpr.RTN_RSLT.getValue())
                {
                    ushort pinIndex = indicies[i];
                    string pin = pinData.get(mpr.HEAD_NUM, mpr.SITE_NUM, pinIndex);
                    TestID id = TestID.getTestID(Record_t.MPR, pin, mpr.TEST_NUM, testName, dup);
                    ParametricTestRecord tr = new ParametricTestRecord(id, mpr.SITE_NUM, mpr.HEAD_NUM, mpr.TST_FLAG, optFlags, parmFlags, 
                                                                       loLimit, hiLimit, result, units, resScal, llmScal, hlmScal);
                    dr[mpr.SITE_NUM - minSite][mpr.HEAD_NUM - minHead].tests ~= tr;
                }
                break;
            /**
                Note TEXT_DATA records have the following format:
                TEXT_DATA : <test_name> : <value> [<units>] : <test_number> [: <site_number> [: <format> [: <head_number>]]]
            */
            case Record_t.DTR.ordinal:
                auto dtr = cast(Record!DTR) rec;
                string text = dtr.TEXT_DAT.getValue().trim();
                if (text[0..9] == "TEXT_DATA")
                {
                    auto toks = text.split(":");
                    if (toks.length < 5)
                    {
                        if (!options.quiet)
                        {
                            writeln("Warning: invalid TEXT_DATA formst: ", text);
                        }
                    }
                }
                break;
            case Record_t.PRR.ordinal:
                dupNums = new MultiMap!(uint, Record_t, TestNumber_t, Site_t, Head_t)();
            }


        }
        // 5. build test IDs, and number test ordering
        // 6. compute timestamp for each device
         
    }

}

private HeaderInfo getHeaderInfo(Record!MIR mir, StdfRecord[] rs)
{
    HeaderInfo hdr;
    hdr.temperature = mir.TST_TEMP;
    hdr.lot_id = mir.LOT_ID;
    hdr.sublot_id = mir.SBLOT_ID;
    hdr.devName = mir.PART_TYP;
    hdr.wafer_id = "";
    import std.algorithm.iteration;
    auto dtrs = rs.filter!(a => a.recordType == Record_t.DTR);
    // 3a. scan DTRs for legacy header info:
    import std.string;
    import std.algorithm.searching;
    foreach(rec; dtrs)
    {
        Record!DTR dtr = cast(Record!DTR) rec;
        string s = strip(dtr.TEXT_DAT);
        if (s.startsWith("STEP #:"))
        {
            auto i = s.indexOf(':');
            auto ss = s[i+1..$];
            hdr.step = strip(ss);
        }
        else if (s.startsWith("TEMPERATURE:"))
        {
            auto i = s.indexOf(':');
            auto ss = s[i+1..$];
            hdr.temperature = strip(ss);
        }
        else if (s.startsWith("LOT #:"))
        {
            auto i = s.indexOf(':');
            auto ss = s[i+1..$];
            hdr.lot_id = strip(ss);
        }
        else if (s.startsWith("DEVICE_NUMBER:"))
        {
            auto i = s.indexOf(':');
            auto ss = s[i+1..$];
            hdr.devName = strip(ss);
        }
    }
    foreach(rec; dtrs)
    {
        Record!DTR dtr = cast(Record!DTR) rec;
        string s = strip(dtr.TEXT_DAT);
        if (s.startsWith(">>>"))
        {
            string s1 = s[3..$];
            string s2 = strip(s1);
            auto i = s2.indexOf(':');
            string name = s2[0..i];
            string val = s2[i+1..$];
            hdr.headerItems[strip(name)] = strip(val);
        }
    }
    return hdr;
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

