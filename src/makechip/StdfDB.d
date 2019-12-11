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
module makechip.StdfDB;
import makechip.Stdf;
import makechip.StdfFile;
import makechip.Descriptors;
import makechip.util.Collections;
import std.conv;
import std.typecons;
import makechip.CmdOptions;
import makechip.DefaultValueDatabase;

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
    DTRValue result;
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

class StdfDB
{
    private StdfPinData[HeaderInfo] pinDataMap;
    private DefaultValueDatabase[HeaderInfo] dvdMap;
    private DeviceResult[][HeaderInfo] deviceMap;
    private Options options;

    this(Options options)
    {
        this.options = options;
    }

    void load(StdfFile stdf)
    {
        uint seq = 0;
        StdfRecord[] rs = stdf.records;
        DeviceResult[] devices;
        DefaultValueDatabase dvd = null;
        bool dvdDone = false;
        if (stdf.hdr in dvdMap) dvdDone = true;
        else
        {
            dvd = new DefaultValueDatabase();
            dvdMap[stdf.hdr] = dvd;
        }
        // 1. Get the MIR
        import std.algorithm.iteration;
        auto r = rs.filter!(a => a.recordType == Record_t.MIR);
        Record!MIR mir = cast(Record!MIR) r.front;
        StdfPinData pinData;
        if (stdf.hdr !in pinDataMap)
        {
            PMRNameType pmrNameType;
            if (options.channelType == PMRNameType.AUTO)
            {
                if (mir.TSTR_TYP == "fusion_cx" || mir.TSTR_TYP == "CTX" || mir.EXEC_VER == "Smartest : s/w rev. 8")
                {
                    pmrNameType = PMRNameType.PHYSICAL;
                }
                else
                {
                    pmrNameType = PMRNameType.CHANNEL;
                }
            }
            else
            {
                pmrNameType = options.channelType;
            }
            // 2. build the pin maps for MPRs
            pinData = buildPinMap(pmrNameType, rs);
            pinDataMap[stdf.hdr] = pinData;
        }
        else pinData = pinDataMap[stdf.hdr];
        // 3. Store default values and create test records
        // first find min and max site and head numbers:
        ubyte minSite = 255;
        ubyte maxSite = 0;
        ubyte minHead = 255;
        ubyte maxHead = 0;
        ubyte[ubyte] heads;
        ubyte[ubyte] sites;
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
        }
        import std.stdio;
        import std.string;
        auto dupNums = new MultiMap!(DupNumber_t, Record_t, TestNumber_t, Site_t, Head_t)();
        DeviceResult[][] dr;
        dr.length = maxSite;
        for (int i=0; i<dr.length; i++) dr[i].length = maxHead;
        size_t numSites = sites.length;
        size_t numHeads = heads.length;
        ulong time = mir.START_T;
        string serial_number = "";
        PartID pid;
        foreach (rec; rs)
        {
            switch (rec.recordType.ordinal)
            {
                case Record_t.FTR.ordinal:
                    auto ftr = cast(Record!FTR) rec;
                    uint dup = dupNums.get(uint.max, ftr.recordType, ftr.TEST_NUM, ftr.SITE_NUM, ftr.HEAD_NUM);
                    if (dup == uint.max) dup = 1; else dup++;
                    dupNums.put(dup, ftr.recordType, ftr.TEST_NUM, ftr.SITE_NUM, ftr.HEAD_NUM);
                    if (!dvdDone) dvd.setFTRDefaults(ftr, dup);
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
                    if (!dvdDone) dvd.setPTRDefaults(ptr, dup);
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
                    normalizeValues(tr);
                    dr[ptr.SITE_NUM - minSite][ptr.HEAD_NUM - minHead].tests ~= tr;
                    seq++;
                    break;

                case Record_t.MPR.ordinal:
                    auto mpr = cast(Record!MPR) rec;
                    uint dup = dupNums.get(uint.max, rec.recordType, mpr.TEST_NUM, mpr.SITE_NUM, mpr.HEAD_NUM);
                    if (dup == uint.max) dup = 1; else dup++;
                    dupNums.put(dup, rec.recordType, mpr.TEST_NUM, mpr.SITE_NUM, mpr.HEAD_NUM);
                    if (!dvdDone) dvd.setMPRDefaults(mpr, dup);
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
                        normalizeValues(tr);
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
                            if (options.verbosityLevel > 0)
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
                    break;
                case Record_t.PRR.ordinal:
                    dupNums = new MultiMap!(uint, Record_t, TestNumber_t, Site_t, Head_t)();
                    Record!(PRR) prr = cast(Record!(PRR)) rec;
                    if (serial_number == "")
                    {
                        if (stdf.hdr.isWafersort())
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
                    time += ((site * head) * prr.TEST_T) / (numSites * numHeads);
                    dr[site - minSite][head - minHead].devId = pid;
                    dr[site - minSite][head - minHead].site = site;
                    dr[site - minSite][head - minHead].head = head;
                    dr[site - minSite][head - minHead].tstamp = time;
                    devices ~= dr[site - minSite][head - minHead];
                    seq = 0;
                    break;
                default:
            }
        }
        if (stdf.hdr !in deviceMap)
        {
            deviceMap[stdf.hdr] = devices;
        }
        else
        {
            DeviceResult[] drs = deviceMap[stdf.hdr];
            drs ~= devices;
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
    tr.result.f = value;
}

private float getScaledResult(TestRecord tr, int scale)
{
    if (tr.result.f == float.nan) return(tr.result.f);
    if (tr.units == "") return tr.result.f;
    return scaleValue(tr.result.f, scale);
}

private int findScale(TestRecord tr)
{
    import std.math;
    float val = 0.0f;
    if (tr.hiLimit == float.nan && tr.loLimit == float.nan) return(0);
    if (tr.loLimit == float.nan) val = fabs(tr.hiLimit);
    else if (tr.hiLimit == float.nan) val = fabs(tr.loLimit);
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
    string u = units;
    switch (scale)
    {
        case -12: u = "T" ~ units; break;
        case -9:  u = "G" ~ units; break;
        case -6:  u = "M" ~ units; break;
        case -3:  u = "K" ~ units; break;
        case  0:  u = units;       break;
        case  3:  u = "m" ~ units; break;
        case  6:  u = "u" ~ units; break;
        case  9:  u = "n" ~ units; break;
        case 12:  u = "p" ~ units; break;
        case 15:  u = "f" ~ units; break;
        default:
    }
    if (u.length >= 3)
    {
        // Potential bug here. Tester may use uppercase letter when it should
        // be using a lower case letter.  Consequently we may not be able
        // to differentiate between milli and Mega
        import std.string;
        string p = u[0..2];
        bool fix = false;
        if      (p == "mT") { p = "G"; fix = true; }
        else if (icmp(p, "uT") == 0) { p = "M"; fix = true; }
        else if (icmp(p, "nT") == 0) { p = "K"; fix = true; }
        else if (icmp(p, "pT") == 0) { p = "";  fix = true; }
        else if (icmp(p, "fT") == 0) { p = "m"; fix = true; }
        else if (icmp(p, "KG") == 0) { p = "T"; fix = true; }
        else if (p == "mG") { p = "M"; fix = true; }
        else if (icmp(p, "uG") == 0) { p = "K"; fix = true; }
        else if (icmp(p, "nG") == 0) { p = "";  fix = true; }
        else if (icmp(p, "pG") == 0) { p = "m"; fix = true; }
        else if (icmp(p, "fG") == 0) { p = "u"; fix = true; }
        else if (p == "MM") { p = "T"; fix = true; }
        else if (p == "KM" || p == "kM") { p = "G"; fix = true; }
        else if (p == "mM") { p = "K"; fix = true; }
        else if (p == "uM" || p == "UM") { p = "";  fix = true; }
        else if (p == "nM" || p == "NM") { p = "m"; fix = true; }
        else if (p == "pM" || p == "PM") { p = "u"; fix = true; }
        else if (p == "fM" || p == "FM") { p = "n"; fix = true; }
        else if (icmp(p, "GK") == 0) { p = "T"; fix = true; }
        else if (p == "MK" || p == "Mk") { p = "G"; fix = true; }
        else if (icmp(p, "KK") == 0) { p = "M"; fix = true; }
        else if (p == "mK" || p == "mk") { p = "";  fix = true; }
        else if (icmp(p, "uK") == 0) { p = "m"; fix = true; }
        else if (icmp(p, "nK") == 0) { p = "u"; fix = true; }
        else if (icmp(p, "pK") == 0) { p = "n"; fix = true; }
        else if (icmp(p, "fK") == 0) { p = "p"; fix = true; }
        else if (p == "Tm") { p = "G"; fix = true; }
        else if (p == "Gm") { p = "M"; fix = true; }
        else if (p == "Mm") { p = "K"; fix = true; }
        else if (p == "Km" || p == "km") { p = "";  fix = true; }
        else if (p == "mm") { p = "u"; fix = true; }
        else if (p == "um" || p == "Um") { p = "n"; fix = true; }
        else if (p == "nm" || p == "Nm") { p = "p"; fix = true; }
        else if (p == "pm" || p == "Pm") { p = "f"; fix = true; }
        else if (icmp(p, "Tu") == 0) { p = "M"; fix = true; }
        else if (icmp(p, "Gu") == 0) { p = "K"; fix = true; }
        else if (p == "Mu" || p == "MU") { p = "";  fix = true; }
        else if (icmp(p, "Ku") == 0) { p = "m"; fix = true; }
        else if (p == "mu" || p == "mU") { p = "n"; fix = true; }
        else if (icmp(p, "uu") == 0) { p = "p"; fix = true; }
        else if (icmp(p, "nu") == 0) { p = "f"; fix = true; }
        else if (icmp(p, "Tn") == 0) { p = "K"; fix = true; }
        else if (icmp(p, "Gn") == 0) { p = "";  fix = true; }
        else if (p == "Mn" || p == "MN") { p = "m"; fix = true; }
        else if (icmp(p, "Kn") == 0) { p = "u"; fix = true; }
        else if (p == "mn" || p == "mN") { p = "p"; fix = true; }
        else if (icmp(p, "un") == 0) { p = "f"; fix = true; }
        else if (icmp(p, "Tp") == 0) { p = "";  fix = true; }
        else if (icmp(p, "Gp") == 0) { p = "m"; fix = true; }
        else if (p == "Mp" || p == "MP") { p = "u"; fix = true; }
        else if (icmp(p, "Kp") == 0) { p = "n"; fix = true; }
        else if (p == "mp" || p == "mP") { p = "f"; fix = true; }
        else if (icmp(p, "Tf") == 0) { p = "m"; fix = true; }
        else if (icmp(p, "Gf") == 0) { p = "u"; fix = true; }
        else if (p == "Mf" || p == "MF") { p = "n"; fix = true; }
        else if (icmp(p, "Kf") == 0) { p = "p"; fix = true; }
        if (fix)
        {
            string newUnits = "" ~ units[1];
            u = p ~ newUnits;
        }
    }
    return(u);
}

