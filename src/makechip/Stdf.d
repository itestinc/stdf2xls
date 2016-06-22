module makechip.Stdf;
import std.stdio;
import std.range;
import std.array;
import std.traits;
import makechip.util.InputStream;
import makechip.util.Util;
import std.algorithm;
import std.conv;
import makechip.Cpu_t;
import core.time;
import std.datetime;
import std.array;

final class RecordType : EnumValue!(const RecordType)
{
    const string description;
    const ubyte recordType;
    const ubyte recordSubType;

    private const this(const(RecordType) prev, const string description, uint type, uint subType)
    {
        super(prev);
        this.description = description;
        recordType = cast(ubyte) type;
        recordSubType = cast(ubyte) subType;
    }

    override string toString() const
    {
        return to!string(this);
    }

    static Record_t getRecordType(ubyte type, ubyte subType)
    {
        foreach(m; EnumMembers!(Record_t))
        {
            if (m.recordType == type && m.recordSubType == subType) return m;
        }
        return null;
    }
}

enum Record_t : const(RecordType)
{
    ATR = new const RecordType(null, "Audit Trail Record",                0,  20),
    BPS = new const RecordType(ATR, "Begin Program Selection Record",    20, 10),
    DTR = new const RecordType(BPS, "Datalog Text Record",               50, 30),
    DTX = new const RecordType(DTR, "Datalog Test Record",               50, 31),
    EPS = new const RecordType(DTX, "End Program Selection Record",      20, 20),
    FAR = new const RecordType(EPS, "File Attributes Record",            0,  10),
    FTR = new const RecordType(FAR, "Functional Test Record",            15, 20),
    GDR = new const RecordType(FTR, "Generic Data Record",               50, 10),
    HBR = new const RecordType(GDR, "Hardware Bin Record",               1,  40),
    MIR = new const RecordType(HBR, "Master Information Record",         1,  10),
    MPR = new const RecordType(MIR, "Multiple-Result Parametric Record", 15, 15),
    MRR = new const RecordType(MPR, "Master Results Record",             1,  20),
    PCR = new const RecordType(MRR, "Part Count Record",                 1,  30),
    PGR = new const RecordType(PCR, "Pin Group Record",                  1,  62),
    PIR = new const RecordType(PGR, "Part Information Record",           5,  10),
    PLR = new const RecordType(PIR, "Pin List Record",                   1,  63),
    PMR = new const RecordType(PLR, "Pin Map Record",                    1,  60),
    PRR = new const RecordType(PMR, "Part Results Record",               5,  20),
    PTR = new const RecordType(PRR, "Parametric Test Record",            15, 10),
    RDR = new const RecordType(PTR, "Retest Data Record",                1,  70),
    SBR = new const RecordType(RDR, "Software Bin Record",               1,  50),
    SDR = new const RecordType(SBR, "Site Description Record",           1,  80),
    TSR = new const RecordType(SDR, "Test Synopsis Record",              10, 30),
    WCR = new const RecordType(TSR, "Wafer Configuration Record",        2,  30),
    WIR = new const RecordType(WCR, "Wafer Information Record",          2,  10),
    WRR = new const RecordType(WIR, "Wafer Results Record",              2,  20)

}

enum GenericData_t : ubyte
{
    B0 = cast(ubyte) 0,
    U1 = cast(ubyte) 1,
    U2 = cast(ubyte) 2,
    U4 = cast(ubyte) 3,
    I1 = cast(ubyte) 4,
    I2 = cast(ubyte) 5,
    I4 = cast(ubyte) 6,
    R4 = cast(ubyte) 7,
    R8 = cast(ubyte) 8,
    CN = cast(ubyte) 10,
    BN = cast(ubyte) 11,
    DN = cast(ubyte) 12,
    N1 = cast(ubyte) 13
}

GenericData_t getDataType(ubyte a)
{
    switch (a)
    {
    case 1:  return GenericData_t.U1;
    case 2:  return GenericData_t.U2;
    case 3:  return GenericData_t.U4;
    case 4:  return GenericData_t.I1;
    case 5:  return GenericData_t.I2;
    case 6:  return GenericData_t.I4;
    case 7:  return GenericData_t.R4;
    case 8:  return GenericData_t.R8;
    case 10: return GenericData_t.CN;
    case 11: return GenericData_t.BN;
    case 12: return GenericData_t.DN;
    case 13: return GenericData_t.N1;
    default:
    }
    return GenericData_t.B0;
}

union GenericDataHolder
{
    ubyte a;
    ushort b;
    uint c;
    byte d;
    short e;
    int f;
    float g;
    double h;
    string i;
    ubyte[] j;
}

struct GenericData
{
    const GenericDataHolder h;
    const ushort numBits;
    const GenericData_t type;

    this(Cpu_t cpu, GenericData_t type, InputStreamRange s)
    {
        if (type == GenericData_t.U1) h.a = cpu.getU1(s);
        else if (type == GenericData_t.U2) h.b = cpu.getU2(s);
        else if (type == GenericData_t.U4) h.c = cpu.getU4(s);
        else if (type == GenericData_t.I1) h.d = cpu.getI1(s);
        else if (type == GenericData_t.I2) h.e = cpu.getI2(s);
        else if (type == GenericData_t.I4) h.f = cpu.getI4(s);
        else if (type == GenericData_t.R4) h.g = cpu.getR4(s);
        else if (type == GenericData_t.R8) h.h = cpu.getR8(s);
        else if (type == GenericData_t.CN) h.i = cpu.getCN(s);
        else if (type == GenericData_t.BN) h.j = cpu.getBN(s);
        else if (type == GenericData_t.DN)
        {
            numBits = cpu.getU2(s);
            h.j = cpu.getDN(numBits, s);
        }
        else h.j = cpu.getN1(s);
    }

    this(ubyte v)   { h.a = v; type = GenericData_t.U1; } 
    this(ushort v)  { h.b = v; type = GenericData_t.U2; }
    this(uint v)    { h.c = v; type = GenericData_t.U4; }
    this(byte v)    { h.d = v; type = GenericData_t.I1; }
    this(short v)   { h.e = v; type = GenericData_t.I2; }
    this(int v)     { h.f = v; type = GenericData_t.I4; }
    this(float v)   { h.g = v; type = GenericData_t.R4; }
    this(double v)  { h.h = v; type = GenericData_t.R8; }
    this(string v)  { h.i = v; type = GenericData_t.CN; }
    this(ubyte[] v) { h.j = v; type = GenericData_t.BN; }
    this(ushort numBits, ubyte[] v) { this.numBits = numBits; h.j = v; type = GenericData_t.DN; }
    this(ubyte b0, ubyte b1) { h.j = [ b0, b1 ]; type = GenericData_t.N1; }

    string toString()
    {
        switch (type) with (GenericData_t)
        {
        case U1: return to!string(h.a);
        case U2: return to!string(h.b);
        case U4: return to!string(h.c);
        case I1: return to!string(h.d);
        case I2: return to!string(h.e);
        case I4: return to!string(h.f);
        case R4: return to!string(h.g);
        case R8: return to!string(h.h);
        case CN: return to!string(h.i);
        case BN: return to!string(h.j);
        case DN:
            string s = to!string(numBits) ~ " : " ~ to!string(h.j);
            return s;
        default: // N1
            return to!string(h.a);
        }
    }

    ubyte[] getBytes(Cpu_t cpu)
    {
        ubyte[] bs;
        switch (type) with (GenericData_t)
        {
        case U1: bs = cpu.getU1Bytes(h.a); break;
        case U2: bs = cpu.getU2Bytes(h.b); break;
        case U4: bs = cpu.getU4Bytes(h.c); break;
        case I1: bs = cpu.getI1Bytes(h.d); break;
        case I2: bs = cpu.getI2Bytes(h.e); break;
        case I4: bs = cpu.getI4Bytes(h.f); break;
        case R4: bs = cpu.getR4Bytes(h.g); break;
        case R8: bs = cpu.getR8Bytes(h.h); break;
        case CN: bs = cpu.getCNBytes(h.i); break;
        case BN: bs = cpu.getBNBytes(h.j); break;
        case DN: bs = cpu.getDNBytes(numBits, h.j); break;
        default: bs ~= h.a;
        }
        return bs;
    }

    ushort size() @property
    {
        switch (type) with (GenericData_t)
        {
        case U1: return 1;
        case U2: return 2;
        case U4: return 4;
        case I1: return 1;
        case I2: return 2;
        case I4: return 4;
        case R4: return 4;
        case R8: return 8;
        case CN: return cast(ushort) (1 + h.i.length); 
        case BN: return cast(ushort) (1 + h.j.length);
        case DN: return cast(ushort) (2 + h.j.length);
        default: 
        }
        return 1;
    }
}


class StdfReader
{
    private InputStreamRange src;
    public const string filename;
    private Cpu_t cpu = Cpu_t.PC;
    private StdfRecord[] records = new StdfRecord[100000];
    
    this(string filename, size_t bufferSize)
    {
        this.filename = filename;
        auto f = new File(filename, "rb");
        if (f.size() > bufferSize) src = new FileBinaryInputStream(filename, bufferSize);
        else src = new FastFileBinaryInputStream(filename, bufferSize);
    }

    StdfRecord[] getRecords() { return(records); }

    void read()
    {
        records.length = 0;
        while (!src.empty)
        {
            ushort reclen = cpu.getU2(src);
            ubyte rtype = cpu.getU1(src);
            ubyte stype = cpu.getU1(src);
            Record_t type = RecordType.getRecordType(rtype, stype);
            if (type is null)
            {
                writeln("Corrupt file: ", filename, " invalid record type:");
                writeln("type = ", rtype, " subtype = ", stype);
                throw new Exception(filename);
            }
            StdfRecord r;
            switch (type.ordinal) with (Record_t)
            {
                case ATR.ordinal: r = new AuditTrailRecord(cpu, reclen, src); break;
                case BPS.ordinal: r = new BeginProgramSelectionRecord(cpu, reclen, src); break;
                case DTR.ordinal: r = new DatalogTextRecord(cpu, reclen, src); break;
                case EPS.ordinal: r = new EndProgramSelectionRecord(cpu, reclen, src); break;
                case FAR.ordinal: r = new FileAttributesRecord(cpu, reclen, src); break;
                case FTR.ordinal: r = new FunctionalTestRecord(cpu, reclen, src); break;
                case GDR.ordinal: r = new GenericDataRecord(cpu, reclen, src); break;
                case HBR.ordinal: r = new HardwareBinRecord(cpu, reclen, src); break;
                case MIR.ordinal: r = new MasterInformationRecord(cpu, reclen, src); break;
                case MPR.ordinal: r = new MultipleResultParametricRecord(cpu, reclen, src); break;
                case MRR.ordinal: r = new MasterResultsRecord(cpu, reclen, src); break;
                case PCR.ordinal: r = new PartCountRecord(cpu, reclen, src); break;
                case PGR.ordinal: r = new PinGroupRecord(cpu, reclen, src); break;
                case PIR.ordinal: r = new PartInformationRecord(cpu, reclen, src); break;
                case PLR.ordinal: r = new PinListRecord(cpu, reclen, src); break;
                case PMR.ordinal: r = new PinMapRecord(cpu, reclen, src); break;
                case PRR.ordinal: r = new PartResultsRecord(cpu, reclen, src); break;
                case PTR.ordinal: r = new ParametricTestRecord(cpu, reclen, src); break;
                case RDR.ordinal: r = new RetestDataRecord(cpu, reclen, src); break;
                case SBR.ordinal: r = new SoftwareBinRecord(cpu, reclen, src); break;
                case SDR.ordinal: r = new SiteDescriptionRecord(cpu, reclen, src); break;
                case TSR.ordinal: r = new TestSynopsisRecord(cpu, reclen, src); break;
                case WCR.ordinal: r = new WaferConfigurationRecord(cpu, reclen, src); break;
                case WIR.ordinal: r = new WaferInformationRecord(cpu, reclen, src); break;
                case WRR.ordinal: r = new WaferResultsRecord(cpu, reclen, src); break;
                default: throw new Exception("Unknown record type: " ~ type.stringof);
            }
            records ~= r;
        }
    }
} // end class StdfReader

class StdfRecord
{
    const Cpu_t cpu;
    const Record_t recordType;
    protected ushort reclen;

    this(const Cpu_t cpu, const Record_t recordType, ushort reclen)
    {
        this.cpu = cpu;
        this.recordType = recordType;
        this.reclen = reclen;
    }

    abstract override string toString();

    abstract ubyte[] getBytes();
    protected abstract ushort getReclen();

    bool isTestRecord()
    {
        Record_t t = recordType;
        return t == Record_t.FTR || t == Record_t.PTR || t == Record_t.MPR || t == Record_t.DTX;
    }

    ubyte[] getHeaderBytes()
    {
        ubyte[] b = new ubyte[4 + reclen];
        auto bs = cpu.getU2Bytes(reclen);
        b[0] = bs[0];
        b[1] = bs[1];
        b[2] = recordType.recordType;
        b[3] = recordType.recordSubType;
        b.length = 4;
        return b;
    }

}

class AuditTrailRecord : StdfRecord
{
    const DateTime date;
    const string cmdLine;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.ATR, reclen);
        uint d = cpu.getU4(s);
        date = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
        cmdLine = cpu.getCN(s); 
    }

    this(Cpu_t cpu, DateTime date, string cmdLine)
    {
        super(cpu, Record_t.ATR, 0);
        this.date = date;
        this.cmdLine = cmdLine;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        return cast(ushort) (4 + cmdLine.length + 1);
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        Duration d = date - DateTime(1970, 1, 1, 0, 0, 0); 
        uint dt = cast(uint) d.total!"seconds";
        auto b1 = cpu.getU4Bytes(dt);
        foreach(c; b1) bs ~= c;
        auto b2 = cpu.getCNBytes(cmdLine);
        foreach(c; b2) bs ~= c;
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n    date = ");
        app.put(date.toString());
        app.put("\n    cmdLine = ");
        app.put(cmdLine);
        app.put("\n");
        return app.data;
    }
}

class BeginProgramSelectionRecord : StdfRecord
{
    const string seqName;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.BPS, reclen);
        seqName = cpu.getCN(s);
    }

    this(Cpu_t cpu, string seqName)
    {
        super(cpu, Record_t.BPS, 0);
        this.seqName = seqName;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        return cast(ushort) (1 + seqName.length);
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        auto b1 = cpu.getCNBytes(seqName);
        foreach(c; b1) bs ~= c;
        return bs;
    }

    override string toString()
    {
        return recordType.description ~ ":\n    seqName = " ~ seqName ~ "\n";
    }
}

class DatalogTextRecord : StdfRecord
{
    const string text;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.DTR, reclen);
        text = cpu.getCN(s);
    }

    this(Cpu_t cpu, string text)
    {
        super(cpu, Record_t.DTR, 0);
        this.text = text;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        return cast(ushort) (1 + text.length);
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        auto b = cpu.getCNBytes(text);
        foreach(c; b) bs ~= c;
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n    text = ");
        app.put(text);
        app.put("\n");
        return app.data;
    }
}

class EndProgramSelectionRecord : StdfRecord
{

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.EPS, reclen);
    }

    this(Cpu_t cpu)
    {
        super(cpu, Record_t.EPS, cast(ushort) 0);
    }

    override protected ushort getReclen()
    {
        return 0;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        return bs;
    }

    override string toString()
    {
        return recordType.description;
    }
}

class FileAttributesRecord : StdfRecord
{
    private ubyte stdfVersion;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(Cpu_t.getCpuType(cpu.getU1(s)), Record_t.FAR, reclen);
        stdfVersion = cpu.getU1(s);
    }

    this(Cpu_t cpu, uint stdfVersion)
    {
        super(cpu, Record_t.FAR, cast(ushort) 2);
        this.stdfVersion = cast(ubyte) stdfVersion;
    }

    override protected ushort getReclen()
    {
        return cast(ushort) 2;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.type;
        bs ~= stdfVersion;
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n    cpu = ");
        app.put(cpu.toString());
        app.put("    stdfVersion = ");
        app.put(to!string(stdfVersion));
        app.put("\n");
        return app.data;
    }
}

abstract class TestRecord : StdfRecord
{
    const uint test_num;
    const ubyte head_num;
    const ubyte site_num;
    const ubyte test_flg;

    this(Cpu_t cpu, 
         ushort reclen, 
         Record_t type, 
         const uint test_num, 
         const ubyte head_num, 
         const ubyte site_num, 
         const ubyte test_flg)
    {
        super(cpu, type, reclen);
        this.test_num = test_num;
        this.head_num = head_num;
        this.site_num = site_num;
        this.test_flg = test_flg;
    }
 
    protected string getString()
    {
        auto app = appender!string();
        app.put("    test_num = "); 
        app.put(to!string(test_num));
        app.put("\n    head_num = ");
        app.put(to!string(head_num));
        app.put("\n    site_num = ");
        app.put(to!string(site_num));
        app.put("\n    test_flg = ");
        app.put(to!string(test_flg));
        return app.data;
    }

    override abstract protected ushort getReclen();
    override abstract ubyte[] getBytes();
    override abstract string toString();

}

class FunctionalTestRecord : TestRecord
{
    const (optional!ubyte) opt_flag;
    const optional!uint cycl_cnt;
    const optional!uint rel_vadr;
    const optional!uint rept_cnt;
    const optional!uint num_fail;
    const optional!int xfail_ad;
    const optional!int yfail_ad;
    const optional!short vect_off;
    const optional!ushort rtn_icnt;
    const optional!ushort pgm_icnt;
    const ushort[] rtn_indx;
    const ubyte[] rtn_stat;
    const ushort[] pgm_indx;
    const ubyte[] pgm_stat;
    const ubyte[] fail_pin;
    const string vect_nam;
    const string time_set;
    const string op_code;
    const string test_txt;
    const string alarm_id;
    const string prog_txt;
    const string rslt_txt;
    optional!ubyte patg_num;
    const ubyte[] spin_map;
    private ushort fail_pin_bits;
    private ushort spin_map_bits;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, reclen, Record_t.FTR, cpu.getU4(s), cpu.getU1(s), cpu.getU1(s), cpu.getU1(s));
        int l = cast(int) reclen;
        l -= 7;
        if (l >= 1) opt_flag = cpu.getU1(s); l--;
        if (l >= 4) cycl_cnt = cpu.getU4(s); l -= 4;
        if (l >= 4) rel_vadr = cpu.getU4(s); l -= 4;
        if (l >= 4) rept_cnt = cpu.getU4(s); l -= 4;
        if (l >= 4) num_fail = cpu.getU4(s); l -= 4;
        if (l >= 4) xfail_ad = cpu.getI4(s); l -= 4;
        if (l >= 4) yfail_ad = cpu.getI4(s); l -= 4;
        if (l >= 2) vect_off = cpu.getI2(s); l -= 2;
        if (l >= 2) rtn_icnt = cpu.getU2(s); l -= 2;
        if (l >= 2) pgm_icnt = cpu.getU2(s); l -= 2;
        if (l > 0)
        {
            auto indx = new ushort[rtn_icnt];
            for (int i=0; i<rtn_icnt; i++) 
            {
                indx[i] = cpu.getU2(s);
                l -= 2;
            }
            rtn_indx = indx;
        }
        if (l > 0)
        {
            auto stat = new ubyte[rtn_icnt];
            for (int i=0; i<rtn_icnt; i++) 
            {
                stat[i] = cpu.getU1(s);
                l--;
            }
            rtn_stat = stat;
        }
        if (l > 0)
        {
            auto indx = new ushort[pgm_icnt];
            for (int i=0; i<pgm_icnt; i++)
            {
                indx[i] = cpu.getU2(s);
                l -= 2;
            }
            pgm_indx = indx;
        }
        if (l > 0)
        {
            auto stat = new ubyte[pgm_icnt];
            for (int i=0; i<pgm_icnt; i++)
            {
                stat[i] = cpu.getU1(s);
                l--;
            }
            pgm_stat = stat;
        }
        if (l >= 2)
        {
            fail_pin_bits = cpu.getU2(s);
            if (fail_pin_bits > 0) fail_pin = cpu.getDN(fail_pin_bits, s);
            l -= (fail_pin.length + 2);
        }
        if (l > 0) { vect_nam = cpu.getCN(s); l -= (1 + vect_nam.length); }
        if (l > 0) { time_set = cpu.getCN(s); l -= (1 + time_set.length); }
        if (l > 0) { op_code = cpu.getCN(s); l -= (1 + op_code.length); }
        if (l > 0) { test_txt = cpu.getCN(s); l -= (1 + test_txt.length); }
        if (l > 0) { alarm_id = cpu.getCN(s); l -= (1 + alarm_id.length); }
        if (l > 0) { prog_txt = cpu.getCN(s); l -= (1 + prog_txt.length); }
        if (l > 0) { rslt_txt = cpu.getCN(s); l -= (1 + rslt_txt.length); }
        if (l >= 1) { patg_num = cpu.getU1(s); l--; }
        if (l > 0)
        {
            spin_map_bits = cpu.getU2(s);
            l -= 2;
            if (spin_map_bits > 0)
            { 
                spin_map = cpu.getDN(spin_map_bits, s);
            }
        }
    }

    this(Cpu_t cpu,
         const uint test_num,
         const ubyte head_num,
         const ubyte site_num,
         const ubyte test_flg,
         const optional!ubyte opt_flag,
         const optional!uint cycl_cnt,
         const optional!uint rel_vadr,
         const optional!uint rept_cnt,
         const optional!uint num_fail,
         const optional!int xfail_ad,
         const optional!int yfail_ad,
         const optional!short vect_off,
         const optional!ushort rtn_icnt,
         const optional!ushort pgm_icnt,
         const ushort[] rtn_indx,
         const ubyte[] rtn_stat,
         const ushort[] pgm_indx,
         const ubyte[] pgm_stat,
         const uint fail_pin_bits,
         const ubyte[] fail_pin,
         const string vect_nam,
         const string time_set,
         const string op_code,
         const string test_txt,
         const string alarm_id,
         const string prog_txt,
         const string rslt_txt,
         optional!ubyte patg_num,
         const uint spin_map_bits,
         const ubyte[] spin_map)
    {
        super(cpu, 0, Record_t.FTR, test_num, head_num, site_num, test_flg);
        this.opt_flag = opt_flag;
        this.cycl_cnt = cycl_cnt;
        this.rel_vadr = rel_vadr;
        this.rept_cnt = rept_cnt;
        this.num_fail = num_fail;
        this.xfail_ad = xfail_ad;
        this.yfail_ad = yfail_ad;
        this.vect_off = vect_off;
        this.rtn_icnt = rtn_icnt;
        this.pgm_icnt = pgm_icnt;
        this.rtn_indx = rtn_indx;
        this.rtn_stat = rtn_stat;
        this.pgm_indx = pgm_indx;
        this.pgm_stat = pgm_stat;
        this.fail_pin_bits = cast(ushort) fail_pin_bits;
        this.fail_pin = fail_pin;
        this.vect_nam = vect_nam;
        this.time_set = time_set;
        this.op_code = op_code;
        this.test_txt = test_txt;
        this.alarm_id = alarm_id;
        this.prog_txt = prog_txt;
        this.rslt_txt = rslt_txt;
        this.patg_num = patg_num;
        this.spin_map_bits = cast(ushort) spin_map_bits;
        this.spin_map = spin_map;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        uint l = 7;
        if (opt_flag.valid) l += 1; else return cast(ushort) l;
        if (cycl_cnt.valid) l += 4; else return cast(ushort) l;
        if (rel_vadr.valid) l += 4; else return cast(ushort) l;
        if (rept_cnt.valid) l += 4; else return cast(ushort) l;
        if (num_fail.valid) l += 4; else return cast(ushort) l;
        if (xfail_ad.valid) l += 4; else return cast(ushort) l;
        if (yfail_ad.valid) l += 4; else return cast(ushort) l;
        if (vect_off.valid) l += 2; else return cast(ushort) l;
        if (rtn_icnt.valid) l += 2; else return cast(ushort) l;
        if (pgm_icnt.valid) l += 2; else return cast(ushort) l;
        if (rtn_indx !is null) l += rtn_indx.length * 2; else return cast(ushort) l;
        if (rtn_stat !is null) l += rtn_stat.length; else return cast(ushort) l;
        if (pgm_indx !is null) l += pgm_indx.length * 2; else return cast(ushort) l;
        if (pgm_stat !is null) l += pgm_stat.length; else return cast(ushort) l;
        if (fail_pin !is null) l += (2 + fail_pin.length); else return cast(ushort) l;
        if (vect_nam !is null) l += (1 + vect_nam.length); else return cast(ushort) l;
        if (time_set !is null) l += (1 + time_set.length); else return cast(ushort) l;
        if (op_code !is null) l +=  (1 + op_code.length); else return cast(ushort) l;
        if (test_txt !is null) l += (1 + test_txt.length); else return cast(ushort) l;
        if (alarm_id !is null) l += (1 + alarm_id.length); else return cast(ushort) l;
        if (prog_txt !is null) l += (1 + prog_txt.length); else return cast(ushort) l;
        if (rslt_txt !is null) l += (1 + rslt_txt.length); else return cast(ushort) l;
        if (patg_num.valid) l += 1; else return cast(ushort) l;
        if (spin_map !is null) l += (2 + spin_map.length);
        return cast(ushort) l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU4Bytes(test_num);
        bs ~= cpu.getU1Bytes(head_num);
        bs ~= cpu.getU1Bytes(site_num);
        bs ~= cpu.getU1Bytes(test_flg);
        if (opt_flag.valid) bs ~= cpu.getU1Bytes(opt_flag);
        if (cycl_cnt.valid) bs ~= cpu.getU4Bytes(cycl_cnt);
        if (rel_vadr.valid) bs ~= cpu.getU4Bytes(rel_vadr);
        if (rept_cnt.valid) bs ~= cpu.getU4Bytes(rept_cnt);
        if (num_fail.valid) bs ~= cpu.getU4Bytes(num_fail);
        if (xfail_ad.valid) bs ~= cpu.getI4Bytes(xfail_ad);
        if (yfail_ad.valid) bs ~= cpu.getI4Bytes(yfail_ad);
        if (vect_off.valid) bs ~= cpu.getI2Bytes(vect_off);
        if (rtn_icnt.valid) bs ~= cpu.getU2Bytes(rtn_icnt);
        if (pgm_icnt.valid) bs ~= cpu.getU2Bytes(pgm_icnt);
        if (rtn_indx !is null) foreach(u; rtn_indx) bs ~= cpu.getU2Bytes(u);
        if (rtn_stat !is null) foreach(b; rtn_stat) bs ~= cpu.getU1Bytes(b);
        if (pgm_indx !is null) foreach(u; pgm_indx) bs ~= cpu.getU2Bytes(u);
        if (pgm_stat !is null) foreach(b; pgm_stat) bs ~= cpu.getU1Bytes(b);
        if (fail_pin !is null) bs ~= cpu.getDNBytes(fail_pin_bits, fail_pin);
        if (vect_nam !is null) bs ~= cpu.getCNBytes(vect_nam);
        if (time_set !is null) bs ~= cpu.getCNBytes(time_set);
        if (op_code !is null) bs ~= cpu.getCNBytes(op_code);
        if (test_txt !is null) bs ~= cpu.getCNBytes(test_txt);
        if (alarm_id !is null) bs ~= cpu.getCNBytes(alarm_id);
        if (prog_txt !is null) bs ~= cpu.getCNBytes(prog_txt);
        if (rslt_txt !is null) bs ~= cpu.getCNBytes(rslt_txt);
        if (patg_num.valid) bs ~= cpu.getU1Bytes(patg_num);
        if (spin_map !is null) bs ~= cpu.getDNBytes(spin_map_bits, spin_map);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n");
        app.put(getString());        
        if (opt_flag.valid) { app.put("    opt_flag = "); app.put(to!string(opt_flag)); }
        if (cycl_cnt.valid) { app.put("\n    cycl_cnt = "); app.put(to!string(cycl_cnt)); }
        if (rel_vadr.valid) { app.put("\n    rel_vadr = "); app.put(to!string(rel_vadr)); }
        if (rept_cnt.valid) { app.put("\n    rept_cnt = "); app.put(to!string(rept_cnt)); }
        if (num_fail.valid) { app.put("\n    num_fail = "); app.put(to!string(num_fail)); }
        if (xfail_ad.valid) { app.put("\n    xfail_ad = "); app.put(to!string(xfail_ad)); }
        if (yfail_ad.valid) { app.put("\n    yfail_ad = "); app.put(to!string(yfail_ad)); }
        if (vect_off.valid) { app.put("\n    vect_off = "); app.put(to!string(vect_off)); }
        if (rtn_icnt.valid) { app.put("\n    rtn_icnt = "); app.put(to!string(rtn_icnt)); }
        if (pgm_icnt.valid) { app.put("\n    pgm_icnt = "); app.put(to!string(pgm_icnt)); }
        if (rtn_indx !is null) { app.put("\n    rtn_indx = "); app.put(to!string(rtn_indx)); }
        if (rtn_stat !is null) { app.put("\n    rtn_stat = "); app.put(to!string(rtn_stat)); }
        if (pgm_indx !is null) { app.put("\n    pgm_indx = "); app.put(to!string(pgm_indx)); }
        if (pgm_stat !is null) { app.put("\n    pgm_stat = "); app.put(to!string(pgm_stat)); }
        if (fail_pin !is null) { app.put("\n    fail_pin = "); app.put(to!string(fail_pin)); }
        if (vect_nam !is null) { app.put("\n    vect_nam = "); app.put(vect_nam); }
        if (time_set !is null) { app.put("\n    time_set = "); app.put(time_set); }
        if (op_code !is null) { app.put("\n    op_code = "); app.put(op_code); }
        if (test_txt !is null) { app.put("\n    test_txt = "); app.put(test_txt); }
        if (alarm_id !is null) { app.put("\n    alarm_id = "); app.put(alarm_id); }
        if (prog_txt !is null) { app.put("\n    prog_txt = "); app.put(prog_txt); }
        if (rslt_txt !is null) { app.put("\n    rslt_txt = "); app.put(rslt_txt); }
        if (patg_num.valid) { app.put("\n    patg_num = "); app.put(to!string(patg_num)); }
        if (spin_map !is null) { app.put("\n    spin_map = "); app.put(to!string(spin_map)); }
        return app.data;
    }
}

class GenericDataRecord : StdfRecord
{
    private GenericData[] data;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.GDR, reclen);
        ushort fld_cnt = cpu.getU2(s);
        for (ushort i=0; i<fld_cnt; i++)
        {
            GenericData_t type = getDataType(cpu.getU1(s));
            if (type == GenericData_t.B0)
            {
                i--;
                continue;
            }
            auto d = GenericData(cpu, type, s);
            data ~= d;
        }
    }

    this(Cpu_t cpu, GenericData[] data)
    {
        super(cpu, Record_t.GDR, 0);
        foreach(d; data) this.data ~= d;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 2;
        foreach(d; data)
        {
            l += d.size;
            if (l % 2) l++;
        }
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU2Bytes(cast(ushort) data.length);
        foreach(d; data)
        {
            auto b = d.getBytes(cpu);
            bs ~= b;
            if (b.length % 2) bs ~= 0;
        }
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("GenericDataRecord:");
        foreach(d; data) 
        {
            app.put("\n    ");
            app.put(d.toString());
        }
        app.put("\n");
        return app.data;
    }
}

class HardwareBinRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_num;
    const ushort hbin_num;
    const uint hbin_cnt;
    const char hbin_pf;
    const string hbin_nam;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.HBR, reclen);
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
        hbin_num = cpu.getU2(s);
        hbin_cnt = cpu.getU4(s);
        hbin_pf = cast(char) cpu.getU1(s);
        hbin_nam = cpu.getCN(s);
    }

    override protected ushort getReclen()
    {
        return cast(ushort) (10 + hbin_nam.length);
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU1Bytes(head_num);
        bs ~= cpu.getU1Bytes(site_num);
        bs ~= cpu.getU2Bytes(hbin_num);
        bs ~= cpu.getU4Bytes(hbin_cnt);
        bs ~= cast(ubyte) hbin_pf;
        bs ~= cpu.getCNBytes(hbin_nam);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("HardwareBinRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    hbin_num = "); app.put(to!string(hbin_num));
        app.put("\n    hbin_cnt = "); app.put(to!string(hbin_cnt));
        app.put("\n    hbin_pf = "); app.put(to!string(hbin_pf));
        app.put("\n    hbin_nam = "); app.put(to!string(hbin_nam));
        app.put("\n");
        return app.data;
    }
}

class MasterInformationRecord : StdfRecord
{
    const DateTime setup_t;
    const DateTime start_t;
    const ubyte stat_num;
    const char mode_cod;
    const char rtst_cod;
    const char prot_cod;
    const ushort burn_tim;
    const char cmod_cod;
    const string lot_id;
    const string part_typ;
    const string node_nam;
    const string tstr_typ;
    const string job_nam;
    const string job_rev;
    const string sblot_id;
    const string oper_nam;
    const string exec_typ;
    const string exec_ver;
    const string test_cod;
    const string tst_temp;
    const string user_txt;
    const string aux_file;
    const string pkg_typ;
    const string famly_id;
    const string date_cod;
    const string facil_id;
    const string floor_id;
    const string proc_id;
    const string oper_frq;
    const string spec_nam;
    const string spec_ver;
    const string flow_id;
    const string setup_id;
    const string dsgn_rev;
    const string eng_id;
    const string rom_cod;
    const string serl_num;
    const string supr_nam;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.MIR, reclen);
        uint d = cpu.getU4(s);
        setup_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
        d = cpu.getU4(s);
        start_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
        stat_num = cpu.getU1(s);
        mode_cod = cast(char) cpu.getU1(s);
        rtst_cod = cast(char) cpu.getU1(s);
        prot_cod = cast(char) cpu.getU1(s);
        burn_tim = cpu.getU2(s);
        cmod_cod = cast(char) cpu.getU1(s);
        lot_id = cpu.getCN(s);
        part_typ = cpu.getCN(s);
        node_nam = cpu.getCN(s);
        tstr_typ = cpu.getCN(s);
        job_nam = cpu.getCN(s);
        job_rev = cpu.getCN(s);
        sblot_id = cpu.getCN(s);
        oper_nam = cpu.getCN(s);
        exec_typ = cpu.getCN(s);
        exec_ver = cpu.getCN(s);
        test_cod = cpu.getCN(s);
        tst_temp = cpu.getCN(s);
        user_txt = cpu.getCN(s);
        aux_file = cpu.getCN(s);
        pkg_typ = cpu.getCN(s);
        famly_id = cpu.getCN(s);
        date_cod = cpu.getCN(s);
        facil_id = cpu.getCN(s);
        floor_id = cpu.getCN(s);
        proc_id = cpu.getCN(s);
        oper_frq = cpu.getCN(s);
        spec_nam = cpu.getCN(s);
        spec_ver = cpu.getCN(s);
        flow_id = cpu.getCN(s);
        setup_id = cpu.getCN(s);
        dsgn_rev = cpu.getCN(s);
        eng_id = cpu.getCN(s);
        rom_cod = cpu.getCN(s);
        serl_num = cpu.getCN(s);
        supr_nam = cpu.getCN(s);
    }

    this(Cpu_t cpu,
         const DateTime setup_t,
         const DateTime start_t,
         const ubyte stat_num,
         const char mode_cod,
         const char rtst_cod,
         const char prot_cod,
         const ushort burn_tim,
         const char cmod_cod,
         const string lot_id,
         const string part_typ,
         const string node_nam,
         const string tstr_typ,
         const string job_nam,
         const string job_rev,
         const string sblot_id,
         const string oper_nam,
         const string exec_typ,
         const string exec_ver,
         const string test_cod,
         const string tst_temp,
         const string user_txt,
         const string aux_file,
         const string pkg_typ,
         const string famly_id,
         const string date_cod,
         const string facil_id,
         const string floor_id,
         const string proc_id,
         const string oper_frq,
         const string spec_nam,
         const string spec_ver,
         const string flow_id,
         const string setup_id,
         const string dsgn_rev,
         const string eng_id,
         const string rom_cod,
         const string serl_num,
         const string supr_nam)
    {
        super(cpu, Record_t.MIR, 0);
        this.setup_t = setup_t;
        this.start_t = start_t;
        this.stat_num = stat_num;
        this.mode_cod = mode_cod;
        this.rtst_cod = rtst_cod;
        this.prot_cod = prot_cod;
        this.burn_tim = burn_tim;
        this.cmod_cod = cmod_cod;
        this.lot_id = lot_id;
        this.part_typ = part_typ;
        this.node_nam = node_nam;
        this.tstr_typ = tstr_typ;
        this.job_nam = job_nam;
        this.job_rev = job_rev;
        this.sblot_id = sblot_id;
        this.oper_nam = oper_nam;
        this.exec_typ = exec_typ;
        this.exec_ver = exec_ver;
        this.test_cod = test_cod;
        this.tst_temp = tst_temp;
        this.user_txt = user_txt;
        this.aux_file = aux_file;
        this.pkg_typ = pkg_typ;
        this.famly_id = famly_id;
        this.date_cod = date_cod;
        this.facil_id = facil_id;
        this.floor_id = floor_id;
        this.proc_id = proc_id;
        this.oper_frq = oper_frq;
        this.spec_nam = spec_nam;
        this.spec_ver = spec_ver;
        this.flow_id = flow_id;
        this.setup_id = setup_id;
        this.dsgn_rev = dsgn_rev;
        this.eng_id = eng_id;
        this.rom_cod = rom_cod;
        this.serl_num = serl_num;
        this.supr_nam = supr_nam;
        reclen = getReclen();
    }


    override protected ushort getReclen()
    {
        ushort l = 15;
        l += cast(ushort) (1 + lot_id.length);
        l += cast(ushort) (1 + part_typ.length);
        l += cast(ushort) (1 + node_nam.length);
        l += cast(ushort) (1 + tstr_typ.length);
        l += cast(ushort) (1 + job_nam.length);
        l += cast(ushort) (1 + job_rev.length);
        l += cast(ushort) (1 + sblot_id.length);
        l += cast(ushort) (1 + oper_nam.length);
        l += cast(ushort) (1 + exec_typ.length);
        l += cast(ushort) (1 + exec_ver.length);
        l += cast(ushort) (1 + test_cod.length);
        l += cast(ushort) (1 + tst_temp.length);
        l += cast(ushort) (1 + user_txt.length);
        l += cast(ushort) (1 + aux_file.length);
        l += cast(ushort) (1 + pkg_typ.length);
        l += cast(ushort) (1 + famly_id.length);
        l += cast(ushort) (1 + date_cod.length);
        l += cast(ushort) (1 + facil_id.length);
        l += cast(ushort) (1 + floor_id.length);
        l += cast(ushort) (1 + proc_id.length);
        l += cast(ushort) (1 + oper_frq.length);
        l += cast(ushort) (1 + spec_nam.length);
        l += cast(ushort) (1 + spec_ver.length);
        l += cast(ushort) (1 + flow_id.length);
        l += cast(ushort) (1 + setup_id.length);
        l += cast(ushort) (1 + dsgn_rev.length);
        l += cast(ushort) (1 + eng_id.length);
        l += cast(ushort) (1 + rom_cod.length);
        l += cast(ushort) (1 + serl_num.length);
        l += cast(ushort) (1 + supr_nam.length);
        return 0;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        Duration d = setup_t - DateTime(1970, 1, 1, 0, 0, 0); 
        uint dt = cast(uint) d.total!"seconds";
        bs ~= cpu.getU4Bytes(dt);
        d = start_t - DateTime(1970, 1, 1, 0, 0, 0); 
        dt = cast(uint) d.total!"seconds";
        bs ~= cpu.getU4Bytes(dt);
        bs ~= stat_num;
        bs ~= cast(ubyte) mode_cod;
        bs ~= cast(ubyte) rtst_cod;
        bs ~= cast(ubyte) prot_cod;
        bs ~= cpu.getU2Bytes(burn_tim);
        bs ~= cast(ubyte) cmod_cod;
        bs ~= cpu.getCNBytes(lot_id);
        bs ~= cpu.getCNBytes(part_typ);
        bs ~= cpu.getCNBytes(node_nam);
        bs ~= cpu.getCNBytes(tstr_typ);
        bs ~= cpu.getCNBytes(job_nam);
        bs ~= cpu.getCNBytes(job_rev);
        bs ~= cpu.getCNBytes(sblot_id);
        bs ~= cpu.getCNBytes(oper_nam);
        bs ~= cpu.getCNBytes(exec_typ);
        bs ~= cpu.getCNBytes(exec_ver);
        bs ~= cpu.getCNBytes(test_cod);
        bs ~= cpu.getCNBytes(tst_temp);
        bs ~= cpu.getCNBytes(user_txt);
        bs ~= cpu.getCNBytes(aux_file);
        bs ~= cpu.getCNBytes(pkg_typ);
        bs ~= cpu.getCNBytes(famly_id);
        bs ~= cpu.getCNBytes(date_cod);
        bs ~= cpu.getCNBytes(facil_id);
        bs ~= cpu.getCNBytes(floor_id);
        bs ~= cpu.getCNBytes(proc_id);
        bs ~= cpu.getCNBytes(oper_frq);
        bs ~= cpu.getCNBytes(spec_nam);
        bs ~= cpu.getCNBytes(spec_ver);
        bs ~= cpu.getCNBytes(flow_id);
        bs ~= cpu.getCNBytes(setup_id);
        bs ~= cpu.getCNBytes(dsgn_rev);
        bs ~= cpu.getCNBytes(eng_id);
        bs ~= cpu.getCNBytes(rom_cod);
        bs ~= cpu.getCNBytes(serl_num);
        bs ~= cpu.getCNBytes(supr_nam);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("MasterInformationRecord:");
        app.put("\n    setup_t = ");  app.put(setup_t.toString());
        app.put("\n    start_t = ");  app.put(start_t.toString());
        app.put("\n    stat_num = "); app.put(to!string(stat_num));
        app.put("\n    mode_cod = "); app.put(to!string(mode_cod));
        app.put("\n    rtst_cod = "); app.put(to!string(rtst_cod));
        app.put("\n    prot_cod = "); app.put(to!string(prot_cod));
        app.put("\n    burn_tim = "); app.put(to!string(burn_tim));
        app.put("\n    cmod_cod = "); app.put(to!string(cmod_cod));
        app.put("\n    lot_id = ");   app.put(lot_id);
        app.put("\n    part_typ = "); app.put(part_typ);
        app.put("\n    node_nam = "); app.put(node_nam);
        app.put("\n    tstr_typ = "); app.put(tstr_typ);
        app.put("\n    job_nam = ");  app.put(job_nam);
        app.put("\n    job_rev = ");  app.put(job_rev);
        app.put("\n    sblot_id = "); app.put(sblot_id);
        app.put("\n    oper_nam = "); app.put(oper_nam);
        app.put("\n    exec_typ = "); app.put(exec_typ);
        app.put("\n    exec_ver = "); app.put(exec_ver);
        app.put("\n    test_cod = "); app.put(test_cod);
        app.put("\n    tst_temp = "); app.put(tst_temp);
        app.put("\n    user_txt = "); app.put(user_txt);
        app.put("\n    aux_file = "); app.put(aux_file);
        app.put("\n    pkg_typ = ");  app.put(pkg_typ);
        app.put("\n    famly_id = "); app.put(famly_id);
        app.put("\n    date_cod = "); app.put(date_cod);
        app.put("\n    facil_id = "); app.put(facil_id);
        app.put("\n    floor_id = "); app.put(floor_id);
        app.put("\n    proc_id = ");  app.put(proc_id);
        app.put("\n    oper_frq = "); app.put(oper_frq);
        app.put("\n    spec_nam = "); app.put(spec_nam);
        app.put("\n    spec_ver = "); app.put(spec_ver);
        app.put("\n    flow_id = ");  app.put(flow_id);
        app.put("\n    setup_id = "); app.put(setup_id);
        app.put("\n    dsgn_rev = "); app.put(dsgn_rev);
        app.put("\n    eng_id = ");   app.put(eng_id);
        app.put("\n    rom_cod = ");  app.put(rom_cod);
        app.put("\n    serl_num = "); app.put(serl_num);
        app.put("\n    supr_nam = "); app.put(supr_nam);
        app.put("\n");
        return app.data;
    }
}

class ParametricRecord : TestRecord
{
    const ubyte parm_flg;
    
    this(Cpu_t cpu, 
         ushort reclen, 
         Record_t type, 
         const uint test_num, 
         const ubyte head_num, 
         const ubyte site_num, 
         const ubyte test_flg,
         const ubyte parm_flg)
    {
        super(cpu, reclen, type, test_num, head_num, site_num, test_flg);
        this.parm_flg = parm_flg;
    }
 
    override protected string getString()
    {
        auto app = appender!string();
        app.put(super.getString());
        app.put("\n    patm_flg = ");
        app.put(to!string(parm_flg));
        return app.data;
    }

    override abstract protected ushort getReclen();
    override abstract ubyte[] getBytes();
    override abstract string toString();
}


class MultipleResultParametricRecord : ParametricRecord
{
    const ushort rtn_icnt;
    const ushort rslt_cnt;
    const ubyte[] rtn_stat;
    const float[] rtn_rslt;
    const string test_txt;
    const string alarm_id;
    const optional!ubyte opt_flag;
    const optional!byte res_scal;
    const optional!byte llm_scal;
    const optional!byte hlm_scal;
    const optional!float lo_limit;
    const optional!float hi_limit;
    const optional!float start_in;
    const optional!float incr_in;
    const ushort[] rtn_indx;
    const string units;
    const string units_in;
    const string c_resfmt;
    const string c_llmfmt;
    const string c_hlmfmt;
    const optional!float lo_spec;
    const optional!float hi_spec;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, reclen, Record_t.MPR, cpu.getU4(s), cpu.getU1(s), cpu.getU1(s), cpu.getU1(s), cpu.getU1(s));
        int l = cast(int) reclen;
        l -= 8;
        rtn_icnt = cpu.getU2(s); l -= 2;
        rslt_cnt = cpu.getU2(s); l -= 2;
        auto stat = new ubyte[rtn_icnt];
        for (int i=0; i<rtn_icnt; i++) stat[i] = cpu.getU1(s);
        rtn_stat = stat;
        l -= (2 * rtn_icnt);
        auto rslt = new float[rslt_cnt];
        for (int i=0; i<rslt_cnt; i++) rslt[i] = cpu.getR4(s);
        rtn_rslt = rslt;
        l -= (2 * rslt_cnt);
        test_txt = cpu.getCN(s);
        l -= (1 + test_txt.length);
        alarm_id = cpu.getCN(s);
        l -= (1 + alarm_id.length);
        if (l >= 1) { opt_flag = cpu.getU1(s); l--; }
        if (l >= 1) { res_scal = cpu.getI1(s); l--; }
        if (l >= 1) { llm_scal = cpu.getI1(s); l--; }
        if (l >= 1) { hlm_scal = cpu.getI1(s); l--; }
        if (l >= 4) { lo_limit = cpu.getR4(s); l -= 4; }
        if (l >= 4) { hi_limit = cpu.getR4(s); l -= 4; }
        if (l >= 4) { start_in = cpu.getR4(s); l -= 4; }
        if (l >= 4) { incr_in  = cpu.getR4(s); l -= 4; }
        if (l >= 2 * rtn_icnt) 
        {
            auto indx = new ushort[rtn_icnt];
            for (int i=0; i<rtn_icnt; i++) indx[i] = cpu.getU2(s);
            rtn_indx = indx;
            l -= (2 * rtn_indx.length);
        }
        if (l > 0) { units = cpu.getCN(s); l -= (1 + units.length); }
        if (l > 0) { units_in = cpu.getCN(s); l -= (1 + units_in.length); }
        if (l > 0) { c_resfmt = cpu.getCN(s); l -= (1 + c_resfmt.length); }
        if (l > 0) { c_llmfmt = cpu.getCN(s); l -= (1 + c_llmfmt.length); }
        if (l > 0) { c_hlmfmt = cpu.getCN(s); l -= (1 + c_hlmfmt.length); }
        if (l >= 4) { lo_spec = cpu.getR4(s); l -= 4; }
        if (l > 0) { hi_spec = cpu.getR4(s); l -= 4; }
    }
 
    this(Cpu_t cpu,
         const uint test_num,
         const ubyte head_num,
         const ubyte site_num,
         const ubyte test_flg,
         const ubyte parm_flg,
         const ushort rtn_icnt,
         const ushort rslt_cnt,
         const ubyte[] rtn_stat,
         const float[] rtn_rslt,
         const string test_txt,
         const string alarm_id,
         const optional!ubyte opt_flag,
         const optional!byte res_scal,
         const optional!byte llm_scal,
         const optional!byte hlm_scal,
         const optional!float lo_limit,
         const optional!float hi_limit,
         const optional!float start_in,
         const optional!float incr_in,
         const ushort[] rtn_indx,
         const string units,
         const string units_in,
         const string c_resfmt,
         const string c_llmfmt,
         const string c_hlmfmt,
         const optional!float lo_spec,
         const optional!float hi_spec)
    {
        super(cpu, 0, Record_t.MPR, test_num, head_num, site_num, test_flg, parm_flg);
        this.rtn_icnt = rtn_icnt;
        this.rslt_cnt = rslt_cnt;
        auto stat = new ubyte[rtn_stat.length];
        foreach(i, d; rtn_stat) stat[i] = d;
        this.rtn_stat = stat;
        auto rslt = new float[rtn_rslt.length];
        foreach(i, d; rtn_rslt) rslt[i] = d;
        this.rtn_rslt = rslt;
        this.test_txt = test_txt;
        this.alarm_id = alarm_id;
        this.opt_flag = opt_flag;
        this.res_scal = res_scal;
        this.llm_scal = llm_scal;
        this.hlm_scal = hlm_scal;
        this.lo_limit = lo_limit;
        this.hi_limit = hi_limit;
        this.start_in = start_in;
        this.incr_in = incr_in;
        auto indx = new ushort[rtn_indx.length];
        foreach(i, d; rtn_indx) indx[i] = d;
        this.rtn_indx = indx;
        this.units = units;
        this.units_in = units_in;
        this.c_resfmt = c_resfmt;
        this.c_llmfmt = c_llmfmt;
        this.c_hlmfmt = c_hlmfmt;
        this.lo_spec = lo_spec;
        this.hi_spec = hi_spec;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 12;
        l += rtn_stat.length;
        l += (4 * rtn_rslt.length);
        l += (1 + test_txt.length);
        l += (1 + alarm_id.length);
        if (opt_flag.valid) l++;
        if (res_scal.valid) l++;
        if (llm_scal.valid) l++;
        if (hlm_scal.valid) l++;
        if (lo_limit.valid) l += 4;
        if (hi_limit.valid) l += 4;
        if (start_in.valid) l += 4;
        if (incr_in.valid)  l += 4;
        if (rtn_indx !is null) l += (2 * rtn_indx.length);
        if (units !is null) l += (1 + units.length);
        if (units_in !is null) l += (1 + units_in.length);
        if (c_resfmt !is null) l += (1 + c_resfmt.length);
        if (c_llmfmt !is null) l += (1 + c_llmfmt.length);
        if (c_hlmfmt !is null) l += (1 + c_hlmfmt.length);
        if (lo_spec.valid) l += 4;
        if (hi_spec.valid) l += 4;
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU4Bytes(test_num);
        bs ~= cpu.getU1Bytes(head_num);
        bs ~= cpu.getU1Bytes(site_num);
        bs ~= cpu.getU1Bytes(test_flg);
        bs ~= cpu.getU1Bytes(parm_flg);
        bs ~= cpu.getU2Bytes(rtn_icnt);
        bs ~= cpu.getU2Bytes(rslt_cnt);
        foreach(d; rtn_stat) bs ~= cpu.getU1Bytes(d);
        foreach(d; rtn_rslt) bs ~= cpu.getR4Bytes(d);
        bs ~= cpu.getCNBytes(test_txt);
        bs ~= cpu.getCNBytes(alarm_id);
        if (opt_flag.valid) bs ~= opt_flag;
        if (res_scal.valid) bs ~= cpu.getI1Bytes(res_scal);
        if (llm_scal.valid) bs ~= cpu.getI1Bytes(llm_scal);
        if (hlm_scal.valid) bs ~= cpu.getI1Bytes(hlm_scal);
        if (lo_limit.valid) bs ~= cpu.getR4Bytes(lo_limit);
        if (hi_limit.valid) bs ~= cpu.getR4Bytes(hi_limit);
        if (start_in.valid) bs ~= cpu.getR4Bytes(start_in);
        if (incr_in.valid)  bs ~= cpu.getR4Bytes(incr_in);
        foreach(d; rtn_indx) bs ~= cpu.getU2Bytes(d);
        if (units !is null) bs ~= cpu.getCNBytes(units);
        if (units_in !is null) bs ~= cpu.getCNBytes(units_in);
        if (c_resfmt !is null) bs ~= cpu.getCNBytes(c_resfmt);
        if (c_llmfmt !is null) bs ~= cpu.getCNBytes(c_llmfmt);
        if (c_hlmfmt !is null) bs ~= cpu.getCNBytes(c_hlmfmt);
        if (lo_spec.valid) bs ~= cpu.getR4Bytes(lo_spec);
        if (hi_spec.valid) bs ~= cpu.getR4Bytes(hi_spec);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("MultipleResultParametricRecord:\n");
        app.put(getString());
        app.put("    parm_flg = "); app.put(to!string(parm_flg));
        app.put("\n    rtn_icnt = "); app.put(to!string(rtn_icnt));
        app.put("\n    rslt_cnt = "); app.put(to!string(rslt_cnt));
        app.put("\n    rtn_stat = "); app.put(to!string(rtn_stat));
        app.put("\n    rtn_rslt = "); app.put(to!string(rtn_rslt));
        app.put("\n    test_txt = "); app.put(test_txt);
        app.put("\n    alarm_id = "); app.put(alarm_id);

        if (opt_flag.valid) { app.put("\n    opt_flag = "); app.put(to!string(opt_flag)); }
        if (res_scal.valid) { app.put("\n    res_scal = "); app.put(to!string(res_scal)); }
        if (llm_scal.valid) { app.put("\n    llm_scal = "); app.put(to!string(llm_scal)); }
        if (hlm_scal.valid) { app.put("\n    hlm_scal = "); app.put(to!string(hlm_scal)); }
        if (lo_limit.valid) { app.put("\n    lo_limit = "); app.put(to!string(lo_limit)); }
        if (hi_limit.valid) { app.put("\n    hi_limit = "); app.put(to!string(hi_limit)); }
        if (start_in.valid) { app.put("\n    start_in = "); app.put(to!string(start_in)); }
        if (incr_in.valid) { app.put("\n    incr_in = "); app.put(to!string(incr_in)); }
        if (rtn_indx !is null) { app.put("\n    rtn_indx = "); app.put(to!string(rtn_indx)); }
        if (units !is null) { app.put("\n    units = "); app.put(units); }
        if (units_in !is null) { app.put("\n    units_in = "); app.put(units_in); }
        if (c_resfmt !is null) { app.put("\n    c_resfmt = "); app.put(c_resfmt); }
        if (c_llmfmt !is null) { app.put("\n    c_llmfmt = "); app.put(c_llmfmt); }
        if (c_hlmfmt !is null) { app.put("\n    c_hlmfmt = "); app.put(c_hlmfmt); }
        if (lo_spec.valid) { app.put("\n    lo_spec = "); app.put(to!string(lo_spec)); }
        if (hi_spec.valid) { app.put("\n    hi_spec = "); app.put(to!string(hi_spec)); }
        app.put("\n");
        return app.data;
    }
}

class MasterResultsRecord : StdfRecord
{
    const DateTime finish_t;
    const char disp_cod;
    const string usr_desc;
    const string exc_desc;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.MRR, reclen);
        uint d = cpu.getU4(s);
        finish_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
        disp_cod = cast(char) cpu.getU1(s);
        usr_desc = cpu.getCN(s);
        exc_desc = cpu.getCN(s);
    }

    this(Cpu_t cpu, 
         const DateTime finish_t, 
         const char disp_cod, 
         const string usr_desc, 
         const string exc_desc)
    {
        super(cpu, Record_t.MRR, 0);
        this.finish_t = finish_t;
        this.disp_cod = disp_cod;
        this.usr_desc = usr_desc;
        this.exc_desc = exc_desc;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 5;
        l += (1 + usr_desc.length);
        l += (1 + exc_desc.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        auto d = finish_t - DateTime(1970, 1, 1, 0, 0, 0); 
        auto dt = cast(uint) d.total!"seconds";
        bs ~= cpu.getU4Bytes(dt);
        bs ~= cast(ubyte) disp_cod;
        bs ~= cpu.getCNBytes(usr_desc);
        bs ~= cpu.getCNBytes(exc_desc);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("MasterResultsRecord:");
        app.put("\n    finish_t = "); app.put(finish_t.toString());
        app.put("\n    disp_cod = "); app.put(to!string(disp_cod));
        app.put("\n    usr_desc = "); app.put(usr_desc);
        app.put("\n    exc_desc = "); app.put(exc_desc);
        app.put("\n");
        return app.data;
    }
}

class PartCountRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_num;
    const uint part_cnt;
    const uint rtst_cnt;
    const uint abrt_cnt;
    const uint good_cnt;
    const uint func_cnt;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.PCR, reclen);
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
        part_cnt = cpu.getU4(s);
        rtst_cnt = cpu.getU4(s);
        abrt_cnt = cpu.getU4(s);
        good_cnt = cpu.getU4(s);
        func_cnt = cpu.getU4(s);
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_num,
         const uint part_cnt,
         const uint rtst_cnt,
         const uint abrt_cnt,
         const uint good_cnt,
         const uint func_cnt)
    {
        super(cpu, Record_t.PCR, 0);
        this.head_num = head_num;
        this.site_num = site_num;
        this.part_cnt = part_cnt;
        this.rtst_cnt = rtst_cnt;
        this.abrt_cnt = abrt_cnt;
        this.good_cnt = good_cnt;
        this.func_cnt = func_cnt;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        return 22;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        bs ~= cpu.getU4Bytes(part_cnt);
        bs ~= cpu.getU4Bytes(rtst_cnt);
        bs ~= cpu.getU4Bytes(abrt_cnt);
        bs ~= cpu.getU4Bytes(good_cnt);
        bs ~= cpu.getU4Bytes(func_cnt);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("PartCountRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    part_cnt = "); app.put(to!string(part_cnt));
        app.put("\n    rtst_cnt = "); app.put(to!string(rtst_cnt));
        app.put("\n    abrt_cnt = "); app.put(to!string(abrt_cnt));
        app.put("\n    good_cnt = "); app.put(to!string(good_cnt));
        app.put("\n    func_cnt = "); app.put(to!string(func_cnt));
        app.put("\n");
        return app.data;
    }
}

class PinGroupRecord : StdfRecord
{
    const ushort grp_indx;
    const string grp_nam;
    const ushort indx_cnt;
    const ushort[] pmr_indx;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.PGR, reclen);
        grp_indx = cpu.getU2(s);
        grp_nam = cpu.getCN(s);
        indx_cnt = cpu.getU2(s);
        auto indx = new ushort[indx_cnt];
        for (int i=0; i<indx_cnt; i++) indx[i] = cpu.getU2(s);
        pmr_indx = indx;
    }

    this(Cpu_t cpu,
         const ushort grp_indx,
         const string grp_nam,
         const ushort indx_cnt,
         const ushort[] pmr_indx)
    {
         super(cpu, Record_t.PGR, 0);
         this.grp_indx = grp_indx;
         this.grp_nam = grp_nam;
         this.indx_cnt = indx_cnt;
         auto indx = new ushort[indx_cnt];
         foreach(i, d; pmr_indx) indx[i] = d;
         this.pmr_indx = indx;
         reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 4;
        l += (1 + grp_nam.length);
        l += (2 * indx_cnt);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU2Bytes(grp_indx);
        bs ~= cpu.getCNBytes(grp_nam);
        bs ~= cpu.getU2Bytes(indx_cnt);
        foreach(d; pmr_indx) bs ~= cpu.getU2Bytes(d);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("PinGroupRecord:");
        app.put("\n    grp_indx = "); app.put(to!string(grp_indx));
        app.put("\n    grp_nam = ");  app.put(grp_nam);
        app.put("\n    indx_cnt = "); app.put(to!string(indx_cnt));
        app.put("\n    pmr_indx = "); app.put(to!string(pmr_indx));
        app.put("\n");
        return app.data;
    }
}

class PartInformationRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_num;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.PIR, reclen);
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
    }

    this(Cpu_t cpu, const ubyte head_num, const ubyte site_num)
    {
        super(cpu, Record_t.PIR, 0);
        this.head_num = head_num;
        this.site_num = site_num;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        return 2;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("PartInformationRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n");
        return app.data;
    }
}

class PinListRecord : StdfRecord
{
    const ushort grp_cnt;
    const ushort[] grp_indx;
    const ushort[] grp_mode;
    const ubyte[] grp_radx;
    const string[] pgm_char;
    const string[] rtn_char;
    const string[] pgm_chal;
    const string[] rtn_chal;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.PLR, reclen);
        grp_cnt = cpu.getU2(s);
        auto indx = new ushort[grp_cnt];
        for (int i=0; i<grp_cnt; i++) indx[i] = cpu.getU2(s);
        grp_indx = indx;
        auto mode = new ushort[grp_cnt];
        for (int i=0; i<grp_cnt; i++) mode[i] = cpu.getU2(s);
        grp_mode = mode;
        auto radx = new ubyte[grp_cnt];
        for (int i=0; i<grp_cnt; i++) radx[i] = cpu.getU1(s);
        grp_radx = radx;
        auto pchar = new string[grp_cnt];
        for (int i=0; i<grp_cnt; i++) pchar[i] = cpu.getCN(s);
        pgm_char = pchar;
        auto rchar = new string[grp_cnt];
        for (int i=0; i<grp_cnt; i++) rchar[i] = cpu.getCN(s);
        rtn_char = rchar;
        auto pchal = new string[grp_cnt];
        for (int i=0; i<grp_cnt; i++) pchal[i] = cpu.getCN(s);
        pgm_chal = pchal;
        auto rchal = new string[grp_cnt];
        for (int i=0; i<grp_cnt; i++) rchal[i] = cpu.getCN(s);
        rtn_chal = rchal;
    }

    this(Cpu_t cpu,
         const ushort grp_cnt,
         const ushort[] grp_indx,
         const ushort[] grp_mode,
         const ubyte[] grp_radx,
         const string[] pgm_char,
         const string[] rtn_char,
         const string[] pgm_chal,
         const string[] rtn_chal)
    {
        super(cpu, Record_t.PLR, 0);
        this.grp_cnt = grp_cnt;
        auto indx = new ushort[grp_cnt];
        foreach(i, d; grp_indx) indx[i] = d;
        this.grp_indx = indx;
        auto mode = new ushort[grp_cnt];
        foreach(i, d; grp_mode) mode[i] = d;
        this.grp_mode = mode;
        auto radx = new ubyte[grp_cnt];
        foreach(i, d; grp_radx) radx[i] = d;
        this.grp_radx = radx;
        auto pchar = new string[grp_cnt];
        foreach(i, d; pgm_char) pchar[i] = d;
        this.pgm_char = pchar;
        auto rchar = new string[grp_cnt];
        foreach(i, d; rtn_char) rchar[i] = d;
        this.rtn_char = rchar;
        auto pchal = new string[grp_cnt];
        foreach(i, d; pgm_chal) pchal[i] = d;
        this.pgm_chal = pchal;
        auto rchal = new string[grp_cnt];
        foreach(i, d; rtn_chal) rchal[i] = d;
        this.rtn_chal = rchal;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 2;
        l += (5 * grp_cnt);
        l += (grp_cnt * (1 + pgm_char.length));
        l += (grp_cnt * (1 + rtn_char.length));
        l += (grp_cnt * (1 + pgm_chal.length));
        l += (grp_cnt * (1 + rtn_chal.length));
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU2Bytes(grp_cnt);
        foreach(d; grp_indx) bs ~= cpu.getU2Bytes(d);
        foreach(d; grp_mode) bs ~= cpu.getU2Bytes(d);
        foreach(d; grp_radx) bs ~= d;
        foreach(s; pgm_char) bs ~= cpu.getCNBytes(s);
        foreach(s; rtn_char) bs ~= cpu.getCNBytes(s);
        foreach(s; pgm_chal) bs ~= cpu.getCNBytes(s);
        foreach(s; rtn_chal) bs ~= cpu.getCNBytes(s);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("PinListRecord:");
        app.put("\n    grp_cnt = "); app.put(to!string(grp_cnt));
        app.put("\n    grp_indx = "); app.put(to!string(grp_indx));
        app.put("\n    grp_mode = "); app.put(to!string(grp_mode));
        app.put("\n    grp_radx = "); app.put(to!string(grp_radx));
        app.put("\n    pgm_char = "); app.put(to!string(pgm_char));
        app.put("\n    rtn_char = "); app.put(to!string(rtn_char));
        app.put("\n    pgm_chal = "); app.put(to!string(pgm_chal));
        app.put("\n    rtn_chal = "); app.put(to!string(rtn_chal));
        app.put("\n");
        return app.data;
    }
}

class PinMapRecord : StdfRecord
{
    const ushort pmr_indx;
    const ushort chan_typ;
    const string chan_nam;
    const string phy_nam;
    const string log_nam;
    const ubyte head_num;
    const ubyte site_num;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.PMR, reclen);
        pmr_indx = cpu.getU2(s);
        chan_typ = cpu.getU2(s);
        chan_nam = cpu.getCN(s);
        phy_nam = cpu.getCN(s);
        log_nam = cpu.getCN(s);
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
    }

    this(Cpu_t cpu,
         const ushort pmr_indx,
         const ushort chan_typ,
         const string chan_nam,
         const string phy_nam,
         const string log_nam,
         const ubyte head_num,
         const ubyte site_num)
    {
        super(cpu, Record_t.PMR, 0);
        this.pmr_indx = pmr_indx;
        this.chan_typ = chan_typ;
        this.chan_nam = chan_nam;
        this.phy_nam = phy_nam;
        this.log_nam = log_nam;
        this.head_num = head_num;
        this.site_num = site_num;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 6;
        l += (1 + chan_nam.length);
        l += (1 + phy_nam.length);
        l += (1 + log_nam.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU2Bytes(pmr_indx);
        bs ~= cpu.getU2Bytes(chan_typ);
        bs ~= cpu.getCNBytes(chan_nam);
        bs ~= cpu.getCNBytes(phy_nam);
        bs ~= cpu.getCNBytes(log_nam);
        bs ~= head_num;
        bs ~= site_num;
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("PinMapRecord:");
        app.put("\n    pmr_indx = "); app.put(to!string(pmr_indx));
        app.put("\n    chan_typ = "); app.put(to!string(chan_typ));
        app.put("\n    chan_nam = "); app.put(chan_nam);
        app.put("\n    phy_nam = "); app.put(phy_nam);
        app.put("\n    log_nam = "); app.put(log_nam);
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n");
        return app.data;
    }
}

class PartResultsRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_num;
    const ubyte part_flg;
    const ushort num_test;
    const ushort hard_bin;
    const ushort soft_bin;
    const short x_coord;
    const short y_coord;
    const uint test_t;
    const string part_id;
    const string part_txt;
    const ubyte[] part_fix;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.PRR, reclen);
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
        part_flg = cpu.getU1(s);
        num_test = cpu.getU2(s);
        hard_bin = cpu.getU2(s);
        soft_bin = cpu.getU2(s);
        x_coord = cpu.getI2(s);
        y_coord = cpu.getI2(s);
        test_t = cpu.getU4(s);
        part_id = cpu.getCN(s);
        part_txt = cpu.getCN(s);
        part_fix = cpu.getBN(s);
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_num,
         const ubyte part_flg,
         const ushort num_test,
         const ushort hard_bin,
         const ushort soft_bin,
         const short x_coord,
         const short y_coord,
         const uint test_t,
         const string part_id,
         const string part_txt,
         const ubyte[] part_fix)
    {
        super(cpu, Record_t.PRR, 0);
        this.head_num = head_num;
        this.site_num = site_num;
        this.part_flg = part_flg;
        this.num_test = num_test;
        this.hard_bin = hard_bin;
        this.soft_bin = soft_bin;
        this.x_coord = x_coord;
        this.y_coord = y_coord;
        this.test_t = test_t;
        this.part_id = part_id;
        this.part_txt = part_txt;
        auto fix = new ubyte[part_fix.length];
        foreach(i, d; part_fix) fix[i] = d;
        this.part_fix = fix;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 17;
        l += (1 + part_id.length);
        l += (1 + part_txt.length);
        l += (1 + part_fix.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        bs ~= part_flg;
        bs ~= cpu.getU2Bytes(num_test);
        bs ~= cpu.getU2Bytes(hard_bin);
        bs ~= cpu.getU2Bytes(soft_bin);
        bs ~= cpu.getI2Bytes(x_coord);
        bs ~= cpu.getI2Bytes(y_coord);
        bs ~= cpu.getU4Bytes(test_t);
        bs ~= cpu.getCNBytes(part_id);
        bs ~= cpu.getCNBytes(part_txt);
        bs ~= cpu.getBNBytes(part_fix);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("PartResultsRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    part_flg = "); app.put(to!string(part_flg));
        app.put("\n    num_test = "); app.put(to!string(num_test));
        app.put("\n    hard_bin = "); app.put(to!string(hard_bin));
        app.put("\n    soft_bin = "); app.put(to!string(soft_bin));
        app.put("\n    x_coord = "); app.put(to!string(x_coord));
        app.put("\n    y_coord = "); app.put(to!string(y_coord));
        app.put("\n    test_t = "); app.put(to!string(test_t));
        app.put("\n    part_id = "); app.put(part_id);
        app.put("\n    part_txt = "); app.put(part_txt);
        app.put("\n    part_fix = "); app.put(to!string(part_fix));
        app.put("\n");
        return app.data;
    }
}

class ParametricTestRecord : ParametricRecord
{
    const float result;
    const string test_txt;
    const string alarm_id;
    const optional!ubyte opt_flag;
    const optional!byte res_scal;
    const optional!byte llm_scal;
    const optional!byte hlm_scal;
    const optional!float lo_limit;
    const optional!float hi_limit;
    const string units;
    const string c_resfmt;
    const string c_llmfmt;
    const string c_hlmfmt;
    const optional!float lo_spec;
    const optional!float hi_spec;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, reclen, Record_t.PTR, cpu.getU4(s), cpu.getU1(s), cpu.getU1(s), cpu.getU1(s), cpu.getU1(s));
        int l = cast(int) reclen;
        l -= 12;
        result = cpu.getU4(s);
        test_txt = cpu.getCN(s); l -= (1 + test_txt.length);
        alarm_id = cpu.getCN(s); l -= (1 + alarm_id.length);
        if (l > 0) opt_flag = cpu.getU1(s); l--;
        if (l > 0) res_scal = cpu.getI1(s); l--;
        if (l > 0) llm_scal = cpu.getI1(s); l--;
        if (l > 0) hlm_scal = cpu.getI1(s); l--;
        if (l >= 4) lo_limit = cpu.getR4(s); l -= 4;
        if (l >= 4) hi_limit = cpu.getR4(s); l -= 4;
        if (l > 0) units = cpu.getCN(s); l -= (1 + units.length);
        if (l > 0) c_resfmt = cpu.getCN(s); l -= (1 + c_resfmt.length);
        if (l > 0) c_llmfmt = cpu.getCN(s); l -= (1 + c_llmfmt.length);
        if (l > 0) c_hlmfmt = cpu.getCN(s); l -= (1 + c_hlmfmt.length);
        if (l > 3) lo_spec = cpu.getR4(s); l -= 4;
        if (l > 3) hi_spec = cpu.getR4(s);
    }

    this(Cpu_t cpu,
         const uint test_num,
         const ubyte head_num,
         const ubyte site_num,
         const ubyte test_flg,
         const ubyte parm_flg,
         const float result,
         const string test_txt,
         const string alarm_id,
         const optional!ubyte opt_flag,
         const optional!byte res_scal,
         const optional!byte llm_scal,
         const optional!byte hlm_scal,
         const optional!float lo_limit,
         const optional!float hi_limit,
         const string units,
         const string c_resfmt,
         const string c_llmfmt,
         const string c_hlmfmt,
         const optional!float lo_spec,
         const optional!float hi_spec)
     {
        super(cpu, 0, Record_t.PTR, test_num, head_num, site_num, test_flg, parm_flg);
        this.result = result;
        this.test_txt = test_txt;
        this.alarm_id = alarm_id;
        this.opt_flag = opt_flag;
        this.res_scal = res_scal;
        this.llm_scal = llm_scal;
        this.hlm_scal = hlm_scal;
        this.lo_limit = lo_limit;
        this.hi_limit = hi_limit;
        this.units = units;
        this.c_resfmt = c_resfmt;
        this.c_llmfmt = c_llmfmt;
        this.c_hlmfmt = c_hlmfmt;
        this.lo_spec = lo_spec;
        this.hi_spec = hi_spec;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 32;
        l += (1 + test_txt.length);
        l += (1 + alarm_id.length);
        if (units !is null) l += (1 + units.length);
        if (c_resfmt !is null) l += (1 + c_resfmt.length);
        if (c_llmfmt !is null) l += (1 + c_llmfmt.length);
        if (c_hlmfmt !is null) l += (1 + c_hlmfmt.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU4Bytes(test_num);
        bs ~= cpu.getU1Bytes(head_num);
        bs ~= cpu.getU1Bytes(site_num);
        bs ~= cpu.getU1Bytes(test_flg);
        bs ~= cpu.getU1Bytes(parm_flg);
        bs ~= cpu.getR4Bytes(result);
        bs ~= cpu.getCNBytes(test_txt);
        bs ~= cpu.getCNBytes(alarm_id);
        if (opt_flag.valid) bs ~= cpu.getU1Bytes(opt_flag);
        if (res_scal.valid) bs ~= cpu.getI1Bytes(res_scal);
        if (llm_scal.valid) bs ~= cpu.getI1Bytes(llm_scal);
        if (hlm_scal.valid) bs ~= cpu.getI1Bytes(hlm_scal);
        if (lo_limit.valid) bs ~= cpu.getR4Bytes(lo_limit);
        if (hi_limit.valid) bs ~= cpu.getR4Bytes(hi_limit);
        if (units !is null) bs ~= cpu.getCNBytes(units);
        if (c_resfmt !is null) bs ~= cpu.getCNBytes(c_resfmt);
        if (c_llmfmt !is null) bs ~= cpu.getCNBytes(c_llmfmt);
        if (c_hlmfmt !is null) bs ~= cpu.getCNBytes(c_hlmfmt);
        if (lo_spec.valid) bs ~= cpu.getR4Bytes(lo_spec);
        if (hi_spec.valid) bs ~= cpu.getR4Bytes(hi_spec);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("ParametricTestRecord:\n");
        app.put(getString());
        app.put("\n    result = "); app.put(to!string(result));
        app.put("\n    test_txt = "); app.put(test_txt);
        app.put("\n    alarm_id = "); app.put(alarm_id);
        if (opt_flag.valid) { app.put("\n    opt_flag = "); app.put(to!string(opt_flag)); }
        if (res_scal.valid) { app.put("\n    res_scal = "); app.put(to!string(res_scal)); }
        if (llm_scal.valid) { app.put("\n    llm_scal = "); app.put(to!string(llm_scal)); }
        if (hlm_scal.valid) { app.put("\n    hlm_scal = "); app.put(to!string(hlm_scal)); }
        if (lo_limit.valid) { app.put("\n    lo_limit = "); app.put(to!string(lo_limit)); }
        if (hi_limit.valid) { app.put("\n    hi_limit = "); app.put(to!string(hi_limit)); }
        if (units !is null) { app.put("\n    units = "); app.put(units); }
        if (c_resfmt !is null) { app.put("\n    c_resfmt = "); app.put(c_resfmt); }
        if (c_llmfmt !is null) { app.put("\n    c_llmfmt = "); app.put(c_llmfmt); }
        if (c_hlmfmt !is null) { app.put("\n    c_hlmfmt = "); app.put(c_hlmfmt); }
        if (lo_spec.valid) { app.put("\n    lo_spec = "); app.put(to!string(lo_spec)); }
        if (hi_spec.valid) { app.put("\n    hi_spec = "); app.put(to!string(hi_spec)); }
        app.put("\n");
        return app.data;
    }
}

class RetestDataRecord : StdfRecord
{
    const ushort num_bins;
    const ushort[] rtst_bin;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.RDR, reclen);
        num_bins = cpu.getU2(s);
        auto bin = new ushort[num_bins];
        for (int i=0; i<num_bins; i++) bin[i] = cpu.getU2(s);
        rtst_bin = bin;
    }

    this(Cpu_t cpu, const ushort num_bins, const ushort[] rtst_bin)
    {
        super(cpu, Record_t.RDR, 0);
        this.num_bins = num_bins;
        auto bin = new ushort[num_bins];
        foreach(i, d; rtst_bin) bin[i] = d;
        this.rtst_bin = rtst_bin;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 2;
        l += (num_bins * 2);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU2Bytes(num_bins);
        foreach(d; rtst_bin) bs ~= cpu.getU2Bytes(d);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("RetestDataRecord:");
        app.put("\n    num_bins = "); app.put(to!string(num_bins)); 
        app.put("\n    rtst_bin = "); app.put(to!string(rtst_bin));
        app.put("\n");
        return app.data;
    }
}

class SoftwareBinRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_num;
    const ushort sbin_num;
    const uint sbin_cnt;
    const char sbin_pf;
    const string sbin_nam;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.SBR, reclen);
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
        sbin_num = cpu.getU2(s);
        sbin_cnt = cpu.getU4(s);
        sbin_pf = cast(char) cpu.getU1(s);
        sbin_nam = cpu.getCN(s);
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_num,
         const ushort sbin_num,
         const uint sbin_cnt,
         const char sbin_pf,
         const string sbin_nam)
    {
        super(cpu, Record_t.SBR, 0);
        this.head_num = head_num;
        this.site_num = site_num;
        this.sbin_num = sbin_num;
        this.sbin_cnt = sbin_cnt;
        this.sbin_pf  = sbin_pf;
        this.sbin_nam = sbin_nam;
        reclen = getReclen();
    }
         

    override protected ushort getReclen()
    {
        ushort l = 9;
        l += (1 + sbin_nam.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getU1Bytes(head_num);
        bs ~= cpu.getU1Bytes(site_num);
        bs ~= cpu.getU2Bytes(sbin_num);
        bs ~= cpu.getU4Bytes(sbin_cnt);
        bs ~= cast(ubyte) sbin_pf;
        bs ~= cpu.getCNBytes(sbin_nam);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("SoftwareBinRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    sbin_num = "); app.put(to!string(sbin_num));
        app.put("\n    sbin_cnt = "); app.put(to!string(sbin_cnt));
        app.put("\n    sbin_pf = "); app.put(to!string(sbin_pf));
        app.put("\n    sbin_nam = "); app.put(sbin_nam);
        app.put("\n");
        return app.data;
    }
}

class SiteDescriptionRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_grp;
    const ubyte site_cnt;
    const ubyte[] site_num;
    const string hand_typ;
    const string hand_id;
    const string card_typ;
    const string card_id;
    const string load_typ;
    const string load_id;
    const string dib_typ;
    const string dib_id;
    const string cabl_typ;
    const string cabl_id;
    const string cont_typ;
    const string cont_id;
    const string lasr_typ;
    const string lasr_id;
    const string extr_typ;
    const string extr_id;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.SDR, reclen);
        head_num = cpu.getU1(s);
        site_grp = cpu.getU1(s);
        site_cnt = cpu.getU1(s);
        auto num = new ubyte[site_cnt];
        for (int i=0; i<site_cnt; i++) num[i] = cpu.getU1(s);
        site_num = num;
        hand_typ = cpu.getCN(s);
        hand_id = cpu.getCN(s);
        card_typ = cpu.getCN(s);
        card_id = cpu.getCN(s);
        load_typ = cpu.getCN(s);
        load_id = cpu.getCN(s);
        dib_typ = cpu.getCN(s);
        dib_id = cpu.getCN(s);
        cabl_typ = cpu.getCN(s);
        cabl_id = cpu.getCN(s);
        cont_typ = cpu.getCN(s);
        cont_id = cpu.getCN(s);
        lasr_typ = cpu.getCN(s);
        lasr_id = cpu.getCN(s);
        extr_typ = cpu.getCN(s);
        extr_id = cpu.getCN(s);
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_grp,
         const ubyte site_cnt,
         const ubyte[] site_num,
         const string hand_typ,
         const string hand_id,
         const string card_typ,
         const string card_id,
         const string load_typ,
         const string load_id,
         const string dib_typ,
         const string dib_id,
         const string cabl_typ,
         const string cabl_id,
         const string cont_typ,
         const string cont_id,
         const string lasr_typ,
         const string lasr_id,
         const string extr_typ,
         const string extr_id)
    {
        super(cpu, Record_t.SDR, 0);
        this.head_num = head_num;
        this.site_grp = site_grp;
        this.site_cnt = site_cnt;
        auto num = new ubyte[site_cnt];
        foreach(i, d; site_num) num[i] = d;
        this.site_num = num;
        this.hand_typ = hand_typ;
        this.hand_id = hand_id;
        this.card_typ = card_typ;
        this.card_id = card_id;
        this.load_typ = load_typ;
        this.load_id = load_id;
        this.dib_typ = dib_typ;
        this.dib_id = dib_id;
        this.cabl_typ = cabl_typ;
        this.cabl_id = cabl_id;
        this.cont_typ = cont_typ;
        this.cont_id = cont_id;
        this.lasr_typ = lasr_typ;
        this.lasr_id = lasr_id;
        this.extr_typ = extr_typ;
        this.extr_id = extr_id;
        reclen = getReclen(); 
   }
         

    override protected ushort getReclen()
    {
        ushort l = 3;
        l += site_cnt;
        l += (1 + hand_typ.length);
        l += (1 + hand_id.length);
        l += (1 + card_typ.length);
        l += (1 + card_id.length);
        l += (1 + load_typ.length);
        l += (1 + load_id.length);
        l += (1 + dib_typ.length);
        l += (1 + dib_id.length);
        l += (1 + cabl_typ.length);
        l += (1 + cabl_id.length);
        l += (1 + cont_typ.length);
        l += (1 + cont_id.length);
        l += (1 + lasr_typ.length);
        l += (1 + lasr_id.length);
        l += (1 + extr_typ.length);
        l += (1 + extr_id.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_grp;
        bs ~= site_cnt;
        bs ~= site_num;
        bs ~= cpu.getCNBytes(hand_typ);
        bs ~= cpu.getCNBytes(hand_id);
        bs ~= cpu.getCNBytes(card_typ);
        bs ~= cpu.getCNBytes(card_id);
        bs ~= cpu.getCNBytes(load_typ);
        bs ~= cpu.getCNBytes(load_id);
        bs ~= cpu.getCNBytes(dib_typ);
        bs ~= cpu.getCNBytes(dib_id);
        bs ~= cpu.getCNBytes(cabl_typ);
        bs ~= cpu.getCNBytes(cabl_id);
        bs ~= cpu.getCNBytes(cont_typ);
        bs ~= cpu.getCNBytes(cont_id);
        bs ~= cpu.getCNBytes(lasr_typ);
        bs ~= cpu.getCNBytes(lasr_id);
        bs ~= cpu.getCNBytes(extr_typ);
        bs ~= cpu.getCNBytes(extr_id);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("SiteDescriptionRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_grp = "); app.put(to!string(site_grp));
        app.put("\n    site_cnt = "); app.put(to!string(site_cnt));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    hand_typ = "); app.put(hand_typ);
        app.put("\n    hand_id = "); app.put(hand_id);
        app.put("\n    card_typ = "); app.put(card_typ);
        app.put("\n    card_id = "); app.put(card_id);
        app.put("\n    load_typ = "); app.put(load_typ);
        app.put("\n    load_id = "); app.put(load_id);
        app.put("\n    dib_typ = "); app.put(dib_typ);
        app.put("\n    dib_id = "); app.put(dib_id);
        app.put("\n    cabl_typ = "); app.put(cabl_typ);
        app.put("\n    cabl_id = "); app.put(cabl_id);
        app.put("\n    cont_typ = "); app.put(cont_typ);
        app.put("\n    cont_id = "); app.put(cont_id);
        app.put("\n    lasr_typ = "); app.put(lasr_typ);
        app.put("\n    lasr_id = "); app.put(lasr_id);
        app.put("\n    extr_typ = "); app.put(extr_typ);
        app.put("\n    extr_id = "); app.put(extr_id);
        app.put("\n");
        return app.data;
    }
}

class TestSynopsisRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_num;
    const char test_typ;
    const uint test_num;
    const uint exec_cnt;
    const uint fail_cnt;
    const uint alrm_cnt;
    const string test_nam;
    const string seq_name;
    const string test_lbl;
    const optional!ubyte opt_flag;
    const optional!float test_tim;
    const optional!float test_min;
    const optional!float test_max;
    const optional!float tst_sums;
    const optional!float tst_sqrs;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.TSR, reclen);
        int l = cast(int) reclen;
        head_num = cpu.getU1(s);
        site_num = cpu.getU1(s);
        test_typ = cast(char) cpu.getU1(s);
        test_num = cpu.getU4(s);
        exec_cnt = cpu.getU4(s);
        fail_cnt = cpu.getU4(s);
        alrm_cnt = cpu.getU4(s); l -= 19;
        test_nam = cpu.getCN(s); l -= (1 + test_nam.length);
        seq_name = cpu.getCN(s); l -= (1 + seq_name.length);
        test_lbl = cpu.getCN(s); l -= (1 + test_lbl.length);
        if (l > 0) { opt_flag = cpu.getU1(s); l--; }
        if (l > 3) { test_tim = cpu.getR4(s); l -= 4; }
        if (l > 3) { test_min = cpu.getR4(s); l -= 4; }
        if (l > 3) { test_max = cpu.getR4(s); l -= 4; }
        if (l > 3) { tst_sums = cpu.getR4(s); l -= 4; }
        if (l > 3) { tst_sqrs = cpu.getR4(s); l -= 4; }
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_num,
         const char test_typ,
         const uint test_num,
         const uint exec_cnt,
         const uint fail_cnt,
         const uint alrm_cnt,
         const string test_nam,
         const string seq_name,
         const string test_lbl,
         const optional!ubyte opt_flag,
         const optional!float test_tim,
         const optional!float test_min,
         const optional!float test_max,
         const optional!float tst_sums,
         const optional!float tst_sqrs)
    {
        super(cpu, Record_t.TSR, 0);
        this.head_num = head_num;
        this.site_num = site_num;
        this.test_typ = test_typ;
        this.test_num = test_num;
        this.exec_cnt = exec_cnt;
        this.fail_cnt = fail_cnt;
        this.alrm_cnt = alrm_cnt;
        this.test_nam = test_nam;
        this.seq_name = seq_name;
        this.test_lbl = test_lbl;
        this.opt_flag = opt_flag;
        this.test_tim = test_tim;
        this.test_min = test_min;
        this.test_max = test_max;
        this.tst_sums = tst_sums;
        this.tst_sqrs = tst_sqrs;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 15;
        l += (1 + test_nam.length);
        l += (1 + seq_name.length);
        l += (1 + test_lbl.length);
        if (opt_flag.valid) l++;
        if (test_tim.valid) l += 4;
        if (test_min.valid) l += 4;
        if (test_max.valid) l += 4;
        if (tst_sums.valid) l += 4;
        if (tst_sqrs.valid) l += 4;
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        bs ~= cast(ubyte) test_typ;
        bs ~= cpu.getU4Bytes(test_num);
        bs ~= cpu.getU4Bytes(exec_cnt);
        bs ~= cpu.getU4Bytes(fail_cnt);
        bs ~= cpu.getU4Bytes(alrm_cnt);
        bs ~= cpu.getCNBytes(test_nam);
        bs ~= cpu.getCNBytes(seq_name);
        bs ~= cpu.getCNBytes(test_lbl);
        if (opt_flag.valid) bs ~= opt_flag;
        if (test_tim.valid) bs ~= cpu.getR4Bytes(test_tim);
        if (test_min.valid) bs ~= cpu.getR4Bytes(test_min);
        if (test_max.valid) bs ~= cpu.getR4Bytes(test_max);
        if (tst_sums.valid) bs ~= cpu.getR4Bytes(tst_sums);
        if (tst_sqrs.valid) bs ~= cpu.getR4Bytes(tst_sqrs);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("TestSynopsisRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    test_typ = "); app.put(to!string(test_typ));
        app.put("\n    test_num = "); app.put(to!string(test_num));
        app.put("\n    exec_cnt = "); app.put(to!string(exec_cnt));
        app.put("\n    fail_cnt = "); app.put(to!string(fail_cnt));
        app.put("\n    alrm_cnt = "); app.put(to!string(alrm_cnt));
        app.put("\n    test_nam = "); app.put(test_nam);
        app.put("\n    seq_name = "); app.put(seq_name);
        app.put("\n    test_lbl = "); app.put(test_lbl);
        if (opt_flag.valid) { app.put("\n    opt_flag = "); app.put(to!string(opt_flag)); }
        if (test_tim.valid) { app.put("\n    test_tim = "); app.put(to!string(test_tim)); }
        if (test_min.valid) { app.put("\n    test_min = "); app.put(to!string(test_min)); }
        if (test_max.valid) { app.put("\n    test_max = "); app.put(to!string(test_max)); }
        if (tst_sums.valid) { app.put("\n    tst_sums = "); app.put(to!string(tst_sums)); }
        if (tst_sqrs.valid) { app.put("\n    tst_sqrs = "); app.put(to!string(tst_sqrs)); }
        app.put("\n");
        return app.data;
    }
}

class WaferConfigurationRecord : StdfRecord
{
    const float wafr_siz;
    const float die_ht;
    const float die_wid;
    const ubyte wf_units;
    const char wf_flat;
    const short center_x;
    const short center_y;
    const char pos_x;
    const char pos_y;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.WCR, reclen);
        wafr_siz = cpu.getR4(s);
        die_ht = cpu.getR4(s);
        die_wid = cpu.getR4(s);
        wf_units = cpu.getU1(s);
        wf_flat = cast(char) cpu.getU1(s);
        center_x = cpu.getI2(s);
        center_y = cpu.getI2(s);
        pos_x = cast(char) cpu.getU1(s);
        pos_y = cast(char) cpu.getU1(s);
    }

    this(Cpu_t cpu,
         const float wafr_siz,
         const float die_ht,
         const float die_wid,
         const ubyte wf_units,
         const char wf_flat,
         const short center_x,
         const short center_y,
         const char pos_x,
         const char pos_y)
    {
        super(cpu, Record_t.WCR, 0);
        this.wafr_siz = wafr_siz;
        this.die_ht = die_ht;
        this.die_wid = die_wid;
        this.wf_units = wf_units;
        this.wf_flat = wf_flat;
        this.center_x = center_x;
        this.center_y = center_y;
        this.pos_x = pos_x;
        this.pos_y = pos_y;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        return 20;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= cpu.getR4Bytes(wafr_siz);
        bs ~= cpu.getR4Bytes(die_ht);
        bs ~= cpu.getR4Bytes(die_wid);
        bs ~= wf_units;
        bs ~= cast(ubyte) wf_flat;
        bs ~= cpu.getI2Bytes(center_x);
        bs ~= cpu.getI2Bytes(center_y);
        bs ~= cast(ubyte) pos_x;
        bs ~= cast(ubyte) pos_y;
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("WaferConfigurationRecord:");
        app.put("\n    wafr_siz = "); app.put(to!string(wafr_siz));
        app.put("\n    die_ht = "); app.put(to!string(die_ht));
        app.put("\n    die_wid = "); app.put(to!string(die_wid));
        app.put("\n    wf_units = "); app.put(to!string(wf_units));
        app.put("\n    wf_flat = "); app.put(to!string(wf_flat));
        app.put("\n    center_x = "); app.put(to!string(center_x));
        app.put("\n    center_y = "); app.put(to!string(center_y));
        app.put("\n    pos_x = "); app.put(to!string(pos_x));
        app.put("\n    pos_y = "); app.put(to!string(pos_y));
        app.put("\n");
        return app.data;
    }
}

class WaferInformationRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_grp;
    const DateTime start_t;
    const string wafer_id;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.WIR, reclen);
        head_num = cpu.getU1(s);
        site_grp = cpu.getU1(s);
        uint d = cpu.getU4(s);
        start_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
        wafer_id = cpu.getCN(s);
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_grp,
         const DateTime start_t,
         const string wafer_id)
    {
        super(cpu, Record_t.WIR, 0);
        this.head_num = head_num;
        this.site_grp = site_grp;
        this.start_t = start_t;
        this.wafer_id = wafer_id;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 6;
        l += (1 + wafer_id.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_grp;
        auto d = start_t - DateTime(1970, 1, 1, 0, 0, 0); 
        auto dt = cast(uint) d.total!"seconds";
        bs ~= cpu.getU4Bytes(dt);
        bs ~= cpu.getCNBytes(wafer_id);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("WaferInformationRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_grp = "); app.put(to!string(site_grp));
        app.put("\n    start_t = "); app.put(start_t.toString());
        app.put("\n    wafer_id = "); app.put(wafer_id);
        app.put("\n");
        return app.data;
    }
}

class WaferResultsRecord : StdfRecord
{
    const ubyte head_num;
    const ubyte site_grp;
    const DateTime finish_t;
    const uint part_cnt;
    const uint rtst_cnt;
    const uint abrt_cnt;
    const uint good_cnt;
    const uint func_cnt;
    const string wafer_id;
    const string fabwf_id;
    const string frame_id;
    const string mask_id;
    const string usr_desc;
    const string exc_desc;

    this(Cpu_t cpu, ushort reclen, InputStreamRange s)
    {
        super(cpu, Record_t.WRR, reclen);
        head_num = cpu.getU1(s);
        site_grp = cpu.getU1(s);
        uint d = cpu.getU4(s);
        finish_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
        part_cnt = cpu.getU4(s);
        rtst_cnt = cpu.getU4(s);
        abrt_cnt = cpu.getU4(s);
        good_cnt = cpu.getU4(s);
        func_cnt = cpu.getU4(s);
        wafer_id = cpu.getCN(s);
        fabwf_id = cpu.getCN(s);
        frame_id = cpu.getCN(s);
        mask_id = cpu.getCN(s);
        usr_desc = cpu.getCN(s);
        exc_desc = cpu.getCN(s);
    }

    this(Cpu_t cpu,
         const ubyte head_num,
         const ubyte site_grp,
         const DateTime finish_t,
         const uint part_cnt,
         const uint rtst_cnt,
         const uint abrt_cnt,
         const uint good_cnt,
         const uint func_cnt,
         const string wafer_id,
         const string fabwf_id,
         const string frame_id,
         const string mask_id,
         const string usr_desc,
         const string exc_desc)
    {
        super(cpu, Record_t.WRR, 0);
        this.head_num = head_num;
        this.site_grp = site_grp;
        this.finish_t = finish_t;
        this.part_cnt = part_cnt;
        this.rtst_cnt = rtst_cnt;
        this.abrt_cnt = abrt_cnt;
        this.good_cnt = good_cnt;
        this.func_cnt = func_cnt;
        this.wafer_id = wafer_id;
        this.fabwf_id = fabwf_id;
        this.frame_id = frame_id;
        this.mask_id = mask_id;
        this.usr_desc = usr_desc;
        this.exc_desc = exc_desc;
        reclen = getReclen();
    }

    override protected ushort getReclen()
    {
        ushort l = 26;
        l += (1 + wafer_id.length);
        l += (1 + fabwf_id.length);
        l += (1 + frame_id.length);
        l += (1 + mask_id.length);
        l += (1 + usr_desc.length);
        l += (1 + exc_desc.length);
        return l;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_grp;
        auto d = finish_t - DateTime(1970, 1, 1, 0, 0, 0); 
        auto dt = cast(uint) d.total!"seconds";
        bs ~= cpu.getU4Bytes(dt);
        bs ~= cpu.getU4Bytes(part_cnt);
        bs ~= cpu.getU4Bytes(rtst_cnt);
        bs ~= cpu.getU4Bytes(abrt_cnt);
        bs ~= cpu.getU4Bytes(good_cnt);
        bs ~= cpu.getU4Bytes(func_cnt);
        bs ~= cpu.getCNBytes(wafer_id);
        bs ~= cpu.getCNBytes(fabwf_id);
        bs ~= cpu.getCNBytes(frame_id);
        bs ~= cpu.getCNBytes(mask_id);
        bs ~= cpu.getCNBytes(usr_desc);
        bs ~= cpu.getCNBytes(exc_desc);
        return bs;
    }

    override string toString()
    {
        auto app = appender!string();
        app.put("WaferResultsRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_grp = "); app.put(to!string(site_grp));
        app.put("\n    finish_t = "); app.put(finish_t.toString());
        app.put("\n    part_cnt = "); app.put(to!string(part_cnt));
        app.put("\n    rtst_cnt = "); app.put(to!string(rtst_cnt));
        app.put("\n    abrt_Cnt = "); app.put(to!string(abrt_cnt));
        app.put("\n    good_cnt = "); app.put(to!string(good_cnt));
        app.put("\n    func_cnt = "); app.put(to!string(func_cnt));
        app.put("\n    wafer_id = "); app.put(wafer_id);
        app.put("\n    fabwf_id = "); app.put(fabwf_id);
        app.put("\n    frame_id = "); app.put(frame_id);
        app.put("\n    mask_id = "); app.put(mask_id);
        app.put("\n    usr_desc = "); app.put(usr_desc);
        app.put("\n    exc_desc = "); app.put(exc_desc);
        app.put("\n");
        return app.data;
    }
}



