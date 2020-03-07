module itestinc.Stdf;
import std.stdio;
import std.range;
import std.array;
import std.traits;
import itestinc.BinarySource;
import itestinc.Descriptors;
import itestinc.CmdOptions;
import itestinc.Util;
import std.algorithm;
import std.conv;
import itestinc.Cpu_t;
import core.time;
import std.datetime;
import std.array;

struct  RecordType
{
    const size_t bufSize;
    const ubyte ordinal;
    const ubyte recordType;
    const ubyte recordSubType;
    const string description;

    private const this(size_t bufSize, uint ordinal, uint type, uint subType, string description)
    {
        this.bufSize = bufSize;
        this.ordinal = cast(ubyte) ordinal;
        this.recordType = cast(ubyte) type;
        this.recordSubType = cast(ubyte) subType;
        this.description = description;
    }

    string toString() const pure
    {
        return description;
    }

    static Record_t getRecordType(ubyte type, ubyte subType)
    {
        foreach(m; EnumMembers!(Record_t))
        {
            if (m.recordType == type && m.recordSubType == subType) return m;
        }
        throw new Exception("Unknown record type");
    }

    static Record_t getRecordType(string name)
    {
        if (name == "ATR") return Record_t.ATR;
        if (name == "BPS") return Record_t.BPS;
        if (name == "DTR") return Record_t.DTR;
        if (name == "EPS") return Record_t.EPS;
        if (name == "FAR") return Record_t.FAR;
        if (name == "FTR") return Record_t.FTR;
        if (name == "GDR") return Record_t.GDR;
        if (name == "HBR") return Record_t.HBR;
        if (name == "MIR") return Record_t.MIR;
        if (name == "MPR") return Record_t.MPR;
        if (name == "MRR") return Record_t.MRR;
        if (name == "PCR") return Record_t.PCR;
        if (name == "PGR") return Record_t.PGR;
        if (name == "PIR") return Record_t.PIR;
        if (name == "PLR") return Record_t.PLR;
        if (name == "PMR") return Record_t.PMR;
        if (name == "PRR") return Record_t.PRR;
        if (name == "PTR") return Record_t.PTR;
        if (name == "RDR") return Record_t.RDR;
        if (name == "SBR") return Record_t.SBR;
        if (name == "SDR") return Record_t.SDR;
        if (name == "TSR") return Record_t.TSR;
        if (name == "WCR") return Record_t.WCR;
        if (name == "WIR") return Record_t.WIR;
        if (name == "WRR") return Record_t.WRR;
        throw new Exception("Unknown record type");
    }

    bool opEquals(const RecordType rt) const pure
    {
        return ordinal == rt.ordinal;
    }

    bool opEquals(ref const RecordType rt) const pure
    {
        return ordinal == rt.ordinal;
    }
}

enum Record_t : const(RecordType)
{
    ATR = const RecordType(256L,  0,   0, 20, "Audit Trail Record"),
    BPS = const RecordType(32L,   1,  20, 10, "Begin Program Selection Record"),
    DTR = const RecordType(128L,  2,  50, 30, "Datalog Text Record"),
    EPS = const RecordType(32L,   4,  20, 20, "End Program Selection Record"),
    FAR = const RecordType(64L,   5,   0, 10, "File Attributes Record"),
    FTR = const RecordType(1200L, 6,  15, 20, "Functional Test Record"),
    GDR = const RecordType(1024L, 7,  50, 10, "Generic Data Record"),
    HBR = const RecordType(1024L, 8,   1, 40, "Hardware Bin Record"),
    MIR = const RecordType(1024L, 9,   1, 10, "Master Information Record"),
    MPR = const RecordType(2300L, 10, 15, 15, "Multiple-Result Parametric Record"),
    MRR = const RecordType(128L,  11,  1, 20, "Master Results Record"),
    PCR = const RecordType(256L,  12,  1, 30, "Part Count Record"),
    PGR = const RecordType(128L,  13,  1, 62, "Pin Group Record"),
    PIR = const RecordType(64L,   14,  5, 10, "Part Information Record"),
    PLR = const RecordType(1024L, 15,  1, 63, "Pin List Record"),
    PMR = const RecordType(256L,  16,  1, 60, "Pin Map Record"),
    PRR = const RecordType(256L,  17,  5, 20, "Part Results Record"),
    PTR = const RecordType(1300L, 18, 15, 10, "Parametric Test Record"),
    RDR = const RecordType(64L,   19,  1, 70, "Retest Data Record"),
    SBR = const RecordType(256L,  20,  1, 50, "Software Bin Record"),
    SDR = const RecordType(1024L, 21,  1, 80, "Site Description Record"),
    TSR = const RecordType(1024L, 22, 10, 30, "Test Synopsis Record"),
    WCR = const RecordType(256L,  23,  2, 30, "Wafer Configuration Record"),
    WIR = const RecordType(256L,  24,  2, 10, "Wafer Information Record"),
    WRR = const RecordType(1024L, 25,  2, 20, "Wafer Results Record")
}

enum GenericDataType : ubyte
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

GenericDataType getDataType(ubyte a)
{
    switch (a)
    {
    case 1:  return GenericDataType.U1;
    case 2:  return GenericDataType.U2;
    case 3:  return GenericDataType.U4;
    case 4:  return GenericDataType.I1;
    case 5:  return GenericDataType.I2;
    case 6:  return GenericDataType.I4;
    case 7:  return GenericDataType.R4;
    case 8:  return GenericDataType.R8;
    case 10: return GenericDataType.CN;
    case 11: return GenericDataType.BN;
    case 12: return GenericDataType.DN;
    case 13: return GenericDataType.N1;
    default:
    }
    return GenericDataType.B0;
}

union GenericDataHolder
{
    U1 a;
    U2 b;
    U4 c;
    I1 d;
    I2 e;
    I4 f;
    R4 g;
    R8 h;
    CN i;
    BN j;
    DN k;
    N1 l;
}

struct GenericData
{
    GenericDataHolder h;
    private ushort numBits;
    GenericDataType type;

    this(ref size_t reclen, GenericDataType type, ByteReader s)
    {
        this.type = type;
        if      (type == GenericDataType.U1) { U1 x = U1(reclen, s); h.a = x; }
        else if (type == GenericDataType.U2) { U2 x = U2(reclen, s); h.b = x; }
        else if (type == GenericDataType.U4) { U4 x = U4(reclen, s); h.c = x; }
        else if (type == GenericDataType.I1) { I1 x = I1(reclen, s); h.d = x; }
        else if (type == GenericDataType.I2) { I2 x = I2(reclen, s); h.e = x; }
        else if (type == GenericDataType.I4) { I4 x = I4(reclen, s); h.f = x; }
        else if (type == GenericDataType.R4) { R4 x = R4(reclen, s); h.g = x; }
        else if (type == GenericDataType.R8) { R8 x = R8(reclen, s); h.h = x; }
        else if (type == GenericDataType.CN) { CN x = CN(reclen, s); h.i = x; }
        else if (type == GenericDataType.BN) { BN x = BN(reclen, s); h.j = x; }
        else if (type == GenericDataType.DN) { DN x = DN(reclen, s); h.k = x; }
        else if (type == GenericDataType.N1) { N1 x = N1(reclen, s); h.l = x; }
    }

    this(ubyte v)   { U1 x = U1(v); h.a = x; type = GenericDataType.U1; } 
    this(ushort v)  { U2 x = U2(v); h.b = x; type = GenericDataType.U2; }
    this(uint v)    { U4 x = U4(v); h.c = x; type = GenericDataType.U4; }
    this(byte v)    { I1 x = I1(v); h.d = x; type = GenericDataType.I1; }
    this(short v)   { I2 x = I2(v); h.e = x; type = GenericDataType.I2; }
    this(int v)     { I4 x = I4(v); h.f = x; type = GenericDataType.I4; }
    this(float v)   { R4 x = R4(v); h.g = x; type = GenericDataType.R4; }
    this(double v)  { R8 x = R8(v); h.h = x; type = GenericDataType.R8; }
    this(string v)  { CN x = CN(v); h.i = x; type = GenericDataType.CN; }
    this(ubyte[] v) { BN x = BN(v); h.j = x; type = GenericDataType.BN; }
    this(size_t nbits, ubyte[] v) { DN x = DN(nbits, v); h.k = x; type = GenericDataType.DN; }
    //this(ubyte b) { N1 x = N1(b); h.l = x; type = GenericDataType.N1; }

    string toString()
    {
        writeln("type = ", type);
        switch (type) with (GenericDataType)
        {
        case U1: return h.a.toString();
        case U2: return h.b.toString();
        case U4: return h.c.toString();
        case I1: return h.d.toString();
        case I2: return h.e.toString();
        case I4: return h.f.toString();
        case R4: return h.g.toString();
        case R8: return h.h.toString();
        case CN: return h.i.toString();
        case BN: return h.j.toString();
        case DN: string s = to!string(numBits) ~ " : " ~ to!string(h.k); return s;
        default: return h.l.toString();
        }
    }

    ubyte[] getBytes()
    {
        auto bs = appender!(ubyte[]);
        bs.reserve(8);
        bs ~= cast(ubyte) type;
        switch (type) with (GenericDataType)
        {
        case U1: bs ~=  h.a.getBytes(); break;
        case U2: bs ~=  h.b.getBytes(); break;
        case U4: bs ~=  h.c.getBytes(); break;
        case I1: bs ~=  h.d.getBytes(); break;
        case I2: bs ~=  h.e.getBytes(); break;
        case I4: bs ~=  h.f.getBytes(); break;
        case R4: bs ~=  h.g.getBytes(); break;
        case R8: bs ~=  h.h.getBytes(); break;
        case CN: bs ~=  h.i.getBytes(); break;
        case BN: bs ~=  h.j.getBytes(); break;
        case DN: bs ~=  h.k.getBytes(); break;
        default: bs ~=  h.l.getBytes(); break;
        }
        return bs.data;
    }

    ushort size() @property
    {
        switch (type) with (GenericDataType)
        {
        case U1: return 2;
        case U2: return 3;
        case U4: return 5;
        case I1: return 2;
        case I2: return 3;
        case I4: return 5;
        case R4: return 5;
        case R8: return 9;
        case CN: return cast(ushort) (1 + h.i.size);
        case BN: return cast(ushort) (1 + h.j.size);
        case DN: return cast(ushort) (1 + h.k.size);
        default: 
        }
        return 1;
    }
}

alias B1 = U1;
import std.typecons;
// Field type holders
struct CN
{
    private ubyte[] myVal;

    this(ref size_t reclen, ByteReader s)
    {
        size_t len = s.front;
        myVal = s.getBytes(len+1).dup;
        //string ss = cast(string) myVal[1..$];
        //writeln("CN = ", ss);
        reclen -= len + 1;
    }

    this(string v)
    {
        assert(v.length < 256);
        myVal = new ubyte[1 + v.length];
        myVal[0] = cast(ubyte) v.length;
        for (int i=0; i<v.length; i++) myVal[i+1] = v[i];
    }
    @property public string getValue() { return toString(); }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return myVal.length; }
    public string toString()
    {
        if (myVal.length > 1)
        {
            string s = cast(immutable(char)[]) myVal[1..$];
            return s;
        }
        return "";
    }

}

struct C1
{
    private ubyte[1] myVal;

    public this(ref size_t reclen, ByteReader s) { myVal[0] = s.getByte(); reclen--; }
    public this(char c) { myVal = new ubyte[1]; myVal[0] = cast(ubyte) c; }
    @property public char getValue() { return cast(char) myVal[0]; }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    public string toString()
    { 
        string s = to!string(cast(char) myVal[0]);
        return s; 
    }
}

struct U1
{
    private ubyte[1] myVal;

    this(ref size_t reclen, ByteReader s) { myVal[0] = s.getByte(); reclen--; } 
    this(ubyte b) { myVal[0] = b; }
    @property public ubyte getValue() { return myVal[0]; }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    import std.digest;
    public string toString() { return toHexString([myVal[0]]); }
}
        
struct U2  
{
    private ubyte[2] myVal;

    this(ref size_t reclen, ByteReader s) { myVal[0] = s.getByte(); myVal[1] = s.getByte(); reclen -= 2; }
    this(ushort b) 
    {
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
    }
    @property public ushort getValue() { return cast(ushort) (myVal[0] + (myVal[1] << 8)); }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 2; }
    public string toString() { return to!string(getValue()); }
}

struct U4
{   
    private ubyte[4] myVal;
    this(ref size_t reclen, ByteReader s) 
    { 
        myVal[0] = s.getByte(); 
        myVal[1] = s.getByte();
        myVal[2] = s.getByte();
        myVal[3] = s.getByte();
        reclen -= 4;
    }

    this(uint b)
    {
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
        myVal[2] = cast(ubyte) ((b & 0xFF0000) >> 16);
        myVal[3] = cast(ubyte) ((b & 0xFF000000) >> 24);
    }

    @property public uint getValue() { return cast(uint) (myVal[0] + (myVal[1] << 8) + (myVal[2] << 16) + (myVal[3] << 24)); }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 4; }
    public string toString() { return to!string(getValue()); }
}

struct I1
{
    private ubyte[1] myVal;
    this(ref size_t reclen, ByteReader s) { myVal[0] = s.getByte(); reclen--; }
    this(byte b) { myVal[0] = cast(ubyte) b; }
    @property public byte getValue() { return cast(byte) myVal[0]; }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    public string toString() { return to!string(cast(byte) myVal[0]); }
}

struct I2
{
    private ubyte[2] myVal;
    this(ref size_t reclen, ByteReader s) { myVal[0] = s.getByte(); myVal[1] = s.getByte(); reclen -= 2; }
    this(short b)
    {
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
    }
    @property public short getValue() { return cast(short) (myVal[0] + (myVal[1] << 8)); }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 2; }
    public string toString() { return to!string(getValue()); }
}

struct I4
{
    private ubyte[4] myVal;
    this(ref size_t reclen, ByteReader s) 
    { 
        myVal[0] = s.getByte(); 
        myVal[1] = s.getByte(); 
        myVal[2] = s.getByte(); 
        myVal[3] = s.getByte(); 
        reclen -= 4;
    }

    this(int b)
    {
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
        myVal[2] = cast(ubyte) ((b & 0xFF0000) >> 16);
        myVal[3] = cast(ubyte) ((b & 0xFF000000) >> 24);
    }
    @property public int getValue() { return cast(int) (myVal[0] + (myVal[1] << 8) + (myVal[2] << 16) + (myVal[3] << 24)); }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 4; }
    public string toString() { return to!string(getValue()); }
}

struct R4
{
    import std.bitmanip;
    private ubyte[4] myVal;
    this(ref size_t reclen, ByteReader s) 
    { 
        myVal[0] = s.getByte(); 
        myVal[1] = s.getByte(); 
        myVal[2] = s.getByte(); 
        myVal[3] = s.getByte(); 
        reclen -= 4;
    }

    this(float v)
    {
        FloatRep f;
        f.value = v;
        uint x = 0;
        x |= f.sign ? 0x80000000 : 0;
        uint exp = (f.exponent << 23) & 0x7F800000;
        x |= exp;
        x |= f.fraction & 0x007FFFFF;
        myVal[0] = cast(ubyte) (x & 0xFF);
        myVal[1] = cast(ubyte) ((x & 0xFF00) >> 8);
        myVal[2] = cast(ubyte) ((x & 0xFF0000) >> 16);
        myVal[3] = cast(ubyte) ((x & 0xFF000000) >> 24);
    }
    @property public float getValue()
    {
        uint x = cast(uint) (myVal[0] + (myVal[1] << 8) + (myVal[2] << 16) + (myVal[3] << 24));
        FloatRep f;
        f.sign = (x & 0x80000000) == 0x80000000;
        f.exponent = cast(ubyte) ((x & 0x7F800000) >> 23);
        f.fraction = x & 0x007FFFFF;
        return f.value;
    }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 4; }
    public string toString() { return to!string(getValue()); }
}

struct R8
{
    import std.bitmanip;
    private ubyte[8] myVal;
    this(ref size_t reclen, ByteReader s) 
    { 
        myVal[0] = s.getByte(); 
        myVal[1] = s.getByte(); 
        myVal[2] = s.getByte(); 
        myVal[3] = s.getByte(); 
        myVal[4] = s.getByte(); 
        myVal[5] = s.getByte(); 
        myVal[6] = s.getByte(); 
        myVal[7] = s.getByte(); 
        reclen -= 8;
    }

    this(double d)
    {
        DoubleRep f;
        f.value = d;
        ulong x = 0L;
        x |= f.sign ? 0x8000000000000000L : 0L;
        ulong exp = (cast(ulong) f.exponent << 52) & 0x7FF0000000000000L;
        x |= exp;
        x |= f.fraction & 0xFFFFFFFFFFFFFL;
        myVal[0] = cast(ubyte) (x & 0xFFL);
        myVal[1] = cast(ubyte) ((x & 0xFF00L) >> 8);
        myVal[2] = cast(ubyte) ((x & 0xFF0000L) >> 16);
        myVal[3] = cast(ubyte) ((x & 0xFF000000L) >> 24);
        myVal[4] = cast(ubyte) ((x & 0xFF00000000L) >> 32);
        myVal[5] = cast(ubyte) ((x & 0xFF0000000000L) >> 40);
        myVal[6] = cast(ubyte) ((x & 0xFF000000000000L) >> 48);
        myVal[7] = cast(ubyte) ((x & 0xFF00000000000000L) >> 56);
    }
    @property public double getValue()
    {
        ulong x = (cast(ulong) myVal[0] + (cast(ulong) myVal[1] << 8) + (cast(ulong) myVal[2] << 16) + (cast(ulong) myVal[3] << 24) +
                  (cast(ulong) myVal[4] << 32) + (cast(ulong) myVal[5] << 40) + (cast(ulong) myVal[6] << 48) + (cast(ulong) myVal[7] << 56));
        DoubleRep f;
        f.sign = (x & 0x8000000000000000L) == 0x8000000000000000L;
        f.exponent = cast(ushort) ((x & 0x7FF0000000000000L) >> 52);
        f.fraction = x & 0xFFFFFFFFFFFFFL;
        return f.value;
    }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 8; }
    public string toString() { return to!string(getValue()); }
}

struct BN 
{
    private ubyte[] myVal;
    this(ref size_t reclen, ByteReader s)
    {
        size_t l = s.front();
        myVal = s.getBytes(l+1).dup;
        reclen -= l + 1;
    }

    this(ubyte[] b)
    {
        myVal = new ubyte[1 + b.length];
        myVal[0] = cast(ubyte) b.length;
        for (int i=0; i<b.length; i++) myVal[i+i] = b[i];
    }
    @property public ubyte[] getValue() { return myVal[1..$]; }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return myVal.length; }
    public string toString() { return to!string(myVal); }
}

struct DN 
{
    private ubyte[] myVal;
    ushort numBits;
    this(ref size_t reclen, ByteReader s)
    {
        ubyte b0 = s.getByte();
        ubyte b1 = s.getByte();
        numBits = cast(ushort) (b0 + (b1 << 8));
        size_t l = (numBits % 8 == 0) ? numBits/8 : numBits/8 + 1;
        myVal = new ubyte[2 + l];
        myVal[0] = b0;
        myVal[1] = b1;
        for (int i=0; i<l; i++) myVal[i+2] = s.getByte();
        reclen -= l + 2;
    }
    this(size_t numBits, ubyte[] bits)
    {
        this.numBits = cast(ushort) numBits;
        size_t l = (numBits % 8 == 0) ? numBits/8 : numBits/8 + 1;
        myVal = new ubyte[2 + l];
        ubyte b0 = cast(ubyte) (numBits & 0xFF);
        ubyte b1 = cast(ubyte) ((numBits & 0xFF00) >> 8);
        myVal[0] = b0;
        myVal[1] = b1;
        for (int i=0; i<l; i++) myVal[2+i] = bits[i];
    }
    @property public ubyte[] getValue() { return myVal[2..$]; }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return myVal.length; }
    public string toString()
    {
        return to!string(numBits) ~ ", " ~ to!string(myVal[2..$]);
    }
}

struct N1 
{
    private ubyte[1] myVal;
    this(ref size_t reclen, ByteReader s) { myVal[0] = s.getByte(); reclen--; }
    this(ubyte val) { myVal[0] = val; }
    this(ubyte val1, ubyte val2)
    {
        myVal[0] = val1;
        myVal[0] |= (val2 << 4) & 0xF0;
    }
    @property public ubyte getValue() { return myVal[0]; }
    alias getValue this;
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    public string toString() { return to!string(getValue()); }
}

struct OptionalField(T) 
    if (is(T == DN) || is(T == U1) || is(T == U2) || is(T == U4) || is(T == I1) || 
        is(T == I2) || is(T == I4) || is(T == R4) || is(T == CN) || is(T == C1) || is(T == BN))
{
    static if (is(T == DN)) 
    {
        alias ACT_TYPE = ubyte[];
    }
    else
    {
        static if (is(T == U1))
        {
            alias ACT_TYPE = ubyte;
        }
        else
        {
            static if (is(T == U2))
            {
                alias ACT_TYPE = ushort;
            }
            else
            {
                static if (is(T == U4))
                {
                    alias ACT_TYPE = uint;
                }
                else
                {
                    static if (is(T == I1))
                    {
                        alias ACT_TYPE = byte;
                    }
                    else
                    {
                        static if (is(T == I2))
                        {
                            alias ACT_TYPE = short;
                        }
                        else
                        {
                            static if (is(T == I4))
                            {
                                alias ACT_TYPE = int;
                            }
                            else
                            {
                                static if (is(T == R4))
                                {
                                    alias ACT_TYPE = float;
                                }
                                else
                                {
                                    static if (is(T == CN))
                                    {
                                        alias ACT_TYPE = string;
                                    }
                                    else
                                    {
                                        static if (is(T == C1))
                                        {
                                            alias ACT_TYPE = char;
                                        }
                                        else
                                        {
                                            static if (is(T == BN))
                                            {
                                                alias ACT_TYPE = ubyte[];
                                            }
                                            else
                                            {
                                                static assert(false, "ERROR: Invalid type for OptionalField: " ~ T.stringof);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    private bool empty;
    T myVal;
    public const ACT_TYPE defaultValue;

    this(ref size_t reclen, ByteReader s, ACT_TYPE defaultValue)
    {
        empty = true;
        this.defaultValue = defaultValue;
        static if (is (T : CN))
        {
            size_t l = 0;
            if (reclen > 0)
            {
                l = s.front();
            }
            if (reclen > l)
            {
                myVal = CN(reclen, s);
                empty = false;
            }
        }
        else
        {
            static if (is (T == BN))
            {
                size_t l = 0;
                if (reclen > 0)
                {
                    l = s.front();
                }
                if (reclen > l)
                {
                    myVal = BN(reclen, s);
                    empty = false;
                }
            }
            else
            {
                static if (is (T == DN))
                {
                    size_t l = 0;
                    if (reclen > 1)
                    {
                        s.mark();
                        size_t nbits = s.getByte() + (s.getByte() << 8);
                        s.resetToMark();
                        l = (nbits % 8 == 0) ? nbits / 8 : (nbits / 8) + 1;
                    }
                    if (reclen > l + 1)
                    {
                        myVal = DN(reclen, s);
                        empty = false;
                    }
                }
                else
                {
                    if (reclen >= myVal.size)
                    {
                        myVal = T(reclen, s);
                        empty = false;
                    }
                }
            }
        }
    }

    this(ACT_TYPE defaultValue)
    {
        this.defaultValue = defaultValue;
        empty = true;
    }

    static if (is(T == DN))
    {
        this(size_t numBits, ACT_TYPE val)
        {
            this.defaultValue = defaultValue;
            myVal = T(numBits, val);
            empty = false;
        }
    }
    else
    {
        this(ACT_TYPE val, ACT_TYPE defaultValue)
        {
            this.defaultValue = defaultValue;
            myVal = T(val);
            empty = false;
        }
    }

    @property public ACT_TYPE getValue()
    {
        if (empty) return cast(ACT_TYPE) defaultValue;
        return myVal.getValue();
    }
    alias getValue this;

    static if (is(T == DN))
    {
        public void setValue(size_t numBits, ACT_TYPE val)
        {
            myVal = T(numBits, val);
            empty = false;
        }
    }
    else
    {
        public void setValue(ACT_TYPE val)
        {
            myVal = T(val);
            empty = false;
        }
    }

    @property bool isEmpty()
    {
        return empty;
    }

    public string toString()
    {
        if (empty) return to!string(defaultValue);
        return myVal.toString();
    }

    @property size_t size()
    {
        if (empty) return 0;
        return myVal.size;
    }

    public ubyte[] getBytes()
    {
        if (empty) return new ubyte[0];
        return myVal.getBytes();
    }

}

// U2, N1, R4
struct OptionalArray(T) if (is(T == U2) || is(T == N1) || is(T == R4) || is(T == U1) || is (T == CN))
{
    static if (is(T == U2))
    {
        alias ACT_TYPE = ushort;
    }
    else
    {
        static if (is(T == N1))
        {
            alias ACT_TYPE = ubyte;
        }
        else
        {
            static if (is(T == R4))
            {
                alias ACT_TYPE = float;
            }
            else
            {
                static if (is(T == U1))
                {
                    alias ACT_TYPE = ubyte;
                }
                else
                {
                    static if (is(T == CN))
                    {
                        alias ACT_TYPE = string;
                    }
                    else
                    {
                        static assert(false, "Invalid type for OptionalArray: " ~ T.stringof);
                    }
                }
            }
        }
    }
    private bool empty;
    private T[] val;

    public ubyte[] getBytes()
    {
        size_t l = 0;
        for (size_t i=0; i<val.length; i++) l += val[i].size();
        auto bs = appender!(ubyte[]);
        bs.reserve(l);
        for (size_t i=0; i<val.length; i++) bs ~= val[i].getBytes();
        return bs.data;
    }

    public ACT_TYPE value(int index)
    {
        return val[index].getValue();
    }

    public T[] getValue()
    {
        return val;
    }

    public size_t length()
    {
        return val.length;
    }

    @property bool isEmpty()
    {
        return empty;
    }

    @property size_t size()
    {
        if (empty) return 0;
        if (val.length == 0) return 0;
        return val[0].size * val.length;
    }

    public void setValue(size_t index, ACT_TYPE newVal)
    {
        assert(index < val.length);
        val[index] = T(newVal);
    }

    public string toString()
    {
        return to!string(val);
    }

    this(ACT_TYPE[] vals)
    {
        if (vals.length == 0) empty = true; else empty = false;
        val = new T[vals.length];
        static if (is(T == N1))
        {
            for (int i=0; i<vals.length; i++) val[i] = T(vals[2*i], vals[2*i+1]);
        }
        else
        {
            for (int i=0; i<vals.length; i++) val[i] = T(vals[i]);
        }
    }

    this(ref size_t reclen, size_t cnt, ByteReader s)
    {
        val = new T[0];
        empty = true;
        static if (is (T == N1))
        {
            if (reclen >= (cnt+1)/2)
            {
                val.length = (cnt + 1) /2;
                for (int i=0; i<(cnt+1)/2; i++) 
                {
                    val[i] = T(reclen, s);
                }
                empty = false;
            }
        }
        else
        {
            static if (is (T == CN))
            {
                val.length = cnt;
                for (int i=0; i<cnt; i++)
                {
                    size_t len = s.front();
                    if (reclen > len) 
                    {
                        val[i] = T(reclen, s);
                        empty = false;
                    }
                }
            }
            else
            {
                static if (is(T == U2) || is(T == R4) || is(T == U1))
                {
                    size_t siz = 0;
                    static if (is(T == U2)) { siz = 2; } else { siz = 4; }
                    if (reclen >= siz * cnt)
                    {
                        val.length = cnt;
                        for (int i=0; i<cnt; i++) 
                        {
                            val[i] = T(reclen, s);
                        }
                        empty = false;
                    }
                }
                else
                {
                    assert(false, "Invalid type for OptionalArray: " ~ T.stringof);
                }
            }
        }
    }
}

// U1 and U2
struct FieldArray(T) if (is(T == U2) || is(T == U1) || is(T == U4))
{
    static if (is(T == U4))
    {
        alias ACT_TYPE = uint;
    }
    else
    {
        static if (is(T == U2))
        {
            alias ACT_TYPE = ushort;
        }
        else
        {
            static if (is(T == U1))
            {
                alias ACT_TYPE = ubyte;
            } 
            else
            {
                static assert(false, "Invalid type for FieldArray: " ~ T.stringof);
            }
        }
    }

    private T[] val;

    public ubyte[] getBytes()
    {
        size_t l = 0;
        for (size_t i=0; i<val.length; i++) l += val[i].size();
        auto bs = appender!(ubyte[]);
        bs.reserve(l);
        for (size_t i=0; i<val.length; i++) bs ~= val[i].getBytes();
        return bs.data;
    }

    public ACT_TYPE value(int index)
    {
        return val[index].getValue();
    }

    public size_t length()
    {
        return val.length;
    }

    @property size_t size()
    {
        if (val.length == 0) return 0;
        return val[0].size * val.length;
    }

    public void setValue(size_t index, ACT_TYPE newVal)
    {
        assert(index < val.length);
        val[index] = T(newVal);
    }

    public string toString()
    {
        return to!string(val);
    }

    this(ACT_TYPE[] vals)
    {
        val = new T[vals.length];
        for (int i=0; i<vals.length; i++) val[i] = T(vals[i]);
    }

    this(ref size_t reclen, size_t cnt, ByteReader s)
    {
        size_t siz = 0;
        static if (is(T == U4)) { siz = 4; }
        else
        {
            static if (is(T == U2)) { siz = 2; } else { siz = 1; }
        }
        val.length = cnt;
        for (int i=0; i<cnt; i++) val[i] = T(reclen, s);
    }
}

unittest
{
    import core.stdc.stdlib;
    import std.file;
    import std.string;
    auto rr = dirEntries("stdf", SpanMode.depth);
    string[] files;
    string tmp;
    foreach(s; rr) files ~= s;
    try
    {
        foreach(string name; files)
        {
            tmp = name;
            writeln("Reading STDF file: ", name); stdout.flush();
            StdfReader stdf = new StdfReader(name);
            stdf.read();
            stdf.close();
            writeln("Done."); stdout.flush();
            StdfRecord[] rs = stdf.getRecords();
            File f = File(name ~ ".tmp", "w");
            writeln("Writing STDF file: ", name, ".tmp"); stdout.flush();
            foreach (StdfRecord r; rs)
            {
                auto type = r.recordType;
                ubyte[] bs = r.getBytes();
                f.rawWrite(bs);
            }
            f.close();
            string cmd = "./bdiff " ~ name ~ ".tmp " ~ name;
            writeln("DIFF: ", cmd); stdout.flush();
            int rv = system(toStringz(cmd));
            if (rv != 0) writeln("FILE = ", name);
            assert(rv == 0);
            remove(name ~ ".tmp");
            writeln("write/diff test passes for ", name); stdout.flush();
        }
    }
    catch (Exception e) { writeln("Exception on file", tmp); }
}

private string getDeclString(const FieldType f) pure
{
    const bool array = f.arrayCountFieldName.length > 0;
    if (f.optional)
    {
        return array ? "OptionalArray!" ~ to!string(f.type) ~ " " ~ f.name ~ ";" : "OptionalField!" ~ to!string(f.type) ~ " " ~ f.name ~ ";";
    }
    return array ? "FieldArray!" ~ to!string(f.type) ~ " " ~ f.name ~ ";" : to!string(f.type) ~ " " ~ f.name ~ ";";
}

private string getCtor1String(const FieldType f) pure
{
    const bool array = f.arrayCountFieldName.length > 0;
    const string acnt = f.arrayCountFieldName;
    const string dflt = f.defaultValueString;
    if (f.optional)
    {
    return f.name ~ " = " ~ (array ? "OptionalArray!" ~ to!string(f.type) ~ "(reclen, " ~ acnt ~ ".getValue(), s);\n" :
                                     "OptionalField!" ~ to!string(f.type) ~ "(reclen, s, " ~ dflt ~ ");\n");
    }
    return f.name ~ " = " ~ (array ? "FieldArray!" ~ to!string(f.type) ~ "(reclen, " ~ acnt ~ ".getValue(), s);\n" :
                                                     to!string(f.type) ~ "(reclen, s);\n");
}

private string getCtor2ArgString(const FieldType f) pure
{
    const bool array = f.arrayCountFieldName.length > 0;
    if (f.optional)
    {
        return array ? "OptionalArray!" ~ to!string(f.type) ~ " " ~ f.name : "OptionalField!" ~ to!string(f.type) ~ " " ~ f.name;
    }
    return array ? "FieldArray!" ~ to!string(f.type) ~ " " ~ f.name : to!string(f.type) ~ " " ~ f.name;
}

private string getCtor2String(const FieldType f) pure
{
    return "this." ~ f.name ~ " = " ~ f.name ~ ";";
}

private string getCtor2(T)() pure
{
    string s = "this(";
    bool first = true;
    static foreach(m; EnumMembers!T)
    {
        if (first)
        {
            s ~= m.getCtor2ArgString();
            first = false;
        }
        else
        {
            s ~= ", ";
            s ~= m.getCtor2ArgString();
        }
    }
    s ~= ") { super(Record_t.";
    s ~= T.stringof;
    s ~= ");";
    static foreach(i, m; EnumMembers!T)
    {
        s ~= getCtor2String(m);
    }
    s ~= "}";
    return s;
}

private string getGetBytesString(const FieldType f) pure
{
    return "bs ~= " ~ f.name ~ ".getBytes();";
}

private string getGetReclenString(const FieldType f) pure
{
    return "l += " ~ f.name ~ ".size;";
}

private string getToStringString(const FieldType f) pure
{
    return "app.put(\"\\n    " ~ f.name ~ " = \"); app.put(" ~ f.name ~ ".toString());";
}

class StdfReader
{
    private ByteReader src;
    public const string filename;
    private StdfRecord[] records;
    
    this(const string filename)
    {
        this.filename = filename;
        auto f = new File(filename, "rb");
        src = new BinarySource(filename);
    }

    public void close()
    {
        src.close();
    }

    StdfRecord[] getRecords() { return(records); }

    void read()
    {
        import std.array;
        auto rs = appender!(StdfRecord[]);
        rs.reserve(100000);
        while (src.remaining() > 3)
        {
            ubyte b0 = src.getByte();
            ubyte b1 = src.getByte();
            size_t reclen = ((cast(size_t) b0) + (((cast(size_t) b1) << 8L) & 0xFF00L)) & 0xFFFFL;
            writeln("src.remaining() = ", src.remaining(), " reclen = ", reclen);
            if (src.remaining() < 2) 
            {
                writeln("Warining: premature end if STDF file");
                break;
            }
            ubyte rtype = src.getByte();
            ubyte stype = src.getByte();
            Record_t type = RecordType.getRecordType(rtype, stype);
            StdfRecord r;
            switch (type.ordinal)
            {
                case Record_t.ATR.ordinal: r = new Record!ATR(type, reclen, src); writeln("ATR"); break;
                case Record_t.BPS.ordinal: r = new Record!BPS(type, reclen, src); writeln("BPS"); break;
                case Record_t.DTR.ordinal: r = new Record!DTR(type, reclen, src); writeln("DTR"); break;
                case Record_t.EPS.ordinal: r = new Record!EPS(type, reclen, src); writeln("EPS"); break;
                case Record_t.FAR.ordinal: r = new Record!FAR(type, reclen, src); writeln("FAR"); break;
                case Record_t.FTR.ordinal: r = new Record!FTR(type, reclen, src); writeln("FTR"); break;
                case Record_t.GDR.ordinal: r = new Record!GDR(type, reclen, src); writeln("GDR"); break;
                case Record_t.HBR.ordinal: r = new Record!HBR(type, reclen, src); writeln("HBR"); break;
                case Record_t.MIR.ordinal: r = new Record!MIR(type, reclen, src); writeln("MIR"); break;
                case Record_t.MPR.ordinal: r = new Record!MPR(type, reclen, src); writeln("MPR"); break;
                case Record_t.MRR.ordinal: r = new Record!MRR(type, reclen, src); writeln("MRR"); break;
                case Record_t.PCR.ordinal: r = new Record!PCR(type, reclen, src); writeln("PCR"); break;
                case Record_t.PGR.ordinal: r = new Record!PGR(type, reclen, src); writeln("PGR"); break;
                case Record_t.PIR.ordinal: r = new Record!PIR(type, reclen, src); writeln("PIR"); break;
                case Record_t.PLR.ordinal: r = new Record!PLR(type, reclen, src); writeln("PLR"); break;
                case Record_t.PMR.ordinal: r = new Record!PMR(type, reclen, src); writeln("PMR"); break;
                case Record_t.PRR.ordinal: r = new Record!PRR(type, reclen, src); writeln("PRR"); break;
                case Record_t.PTR.ordinal: r = new Record!PTR(type, reclen, src); writeln("PTR"); break;
                case Record_t.RDR.ordinal: r = new Record!RDR(type, reclen, src); writeln("RDR"); break;
                case Record_t.SBR.ordinal: r = new Record!SBR(type, reclen, src); writeln("SBR"); break;
                case Record_t.SDR.ordinal: r = new Record!SDR(type, reclen, src); writeln("SDR"); break;
                case Record_t.TSR.ordinal: r = new Record!TSR(type, reclen, src); writeln("TSR"); break;
                case Record_t.WCR.ordinal: r = new Record!WCR(type, reclen, src); writeln("WCR"); break;
                case Record_t.WIR.ordinal: r = new Record!WIR(type, reclen, src); writeln("WTR"); break;
                case Record_t.WRR.ordinal: r = new Record!WRR(type, reclen, src); writeln("WRR"); break;
                default: throw new Exception("Unknown record type: " ~ type.stringof);
            }
            rs ~= r;
            if (type == Record_t.MRR) break;
        }
        records = rs.data;
    }
} // end class StdfReader
import std.array;
class StdfRecord
{
    const Record_t recordType;

    this(const Record_t recordType)
    {
        this.recordType = recordType;
    }

    abstract override string toString();

    abstract ubyte[] getBytes();
    public abstract size_t getReclen();

    bool isTestRecord()
    {
        Record_t t = recordType;
        return t == Record_t.FTR || t == Record_t.PTR || t == Record_t.MPR;
    }

    Appender!(ubyte[]) getHeaderBytes()
    {
        
        size_t l = getReclen();
        Appender!(ubyte[]) bs = appender!(ubyte[]);
        bs.reserve(l);
        bs ~= cast(ubyte) (l & 0xFF);
        bs ~= cast(ubyte) ((l & 0xFF00) >> 8);
        bs ~= recordType.recordType;
        bs ~= recordType.recordSubType;
        return bs;
    }
}

StdfRecord r;

class Record(T) : StdfRecord if (is(T == ATR) || is(T == BPS) || is(T == DTR) || 
                                 is(T == FAR) || is(T == FTR) || is(T == HBR) || 
                                 is(T == MIR) || is(T == MPR) || is(T == MRR) || 
                                 is(T == PCR) || is(T == PGR) || is(T == PIR) || 
                                 is(T == PLR) || is(T == PMR) || is(T == PRR) ||
                                 is(T == PTR) || is(T == RDR) || is(T == SBR) || 
                                 is(T == SDR) || is(T == TSR) || is(T == WCR) || 
                                 is(T == WIR) || is(T == WRR))
{
    static foreach(m; EnumMembers!T)
    {
        mixin(m.getDeclString());
    }

    this(Record_t type, size_t reclen, ByteReader s)
    {
        super(type);
        static foreach(m; EnumMembers!T)
        {
            mixin(m.getCtor1String());
        }
    }

    mixin(getCtor2!T());

    override string toString()
    {
        auto app = StringAppender(recordType.bufSize);
        app.put(recordType.description);
        static foreach(m; EnumMembers!T)
        {
            mixin(m.getToStringString());
        }
        app.put("\n");
        return app.data;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        static foreach(m; EnumMembers!T)
        {
            mixin(m.getGetBytesString());
        }
        return bs.data;
    }

    override size_t getReclen()
    {
        size_t l = 0;
        static foreach(m; EnumMembers!T)
        {
            mixin(m.getGetReclenString());
        }
        return l;
    }
}

class Record(T: EPS) : StdfRecord
{

    this(Record_t type, size_t reclen, ByteReader s)
    {
        super(type);
    }

    override string toString()
    {
        return recordType.description;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        return bs.data;
    }

    override size_t getReclen()
    {
        return 0L;
    }
}

class Record(T: GDR) : StdfRecord
{
    GenericData[] data; 

    this(Record_t type, size_t reclen, ByteReader s)
    {
        super(type);
        ubyte b0 = s.getByte();
        ubyte b1 = s.getByte();
        ushort fld_cnt = cast(ushort) (b0 + ((b1 << 8) & 0xFF00));
        for (ushort i=0; i<fld_cnt; i++)
        {
            GenericDataType t = getDataType(s.getByte());
            if (t == GenericDataType.B0)
            {
                i--;
                writeln("");
                continue;
            }
            auto d = GenericData(reclen, t, s);
            data ~= d;
        }
    }

    override string toString()
    {
        auto app = StringAppender(1024);
        app.put(recordType.description);
        app.put("\n: fields = " ~ to!string(data.length));
        foreach(d; data)
        {
            app.put("\n    ");
            app.put(d.toString());
        }
        app.put("\n");
        return app.data;
    }

    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        size_t l = data.length;
        bs ~= cast(ubyte) (l & 0xFF);
        bs ~= cast(ubyte) ((l & 0xFF00) >> 8);
        size_t cnt = 0;
        for (size_t i=0; i<data.length; i++)
        {
            /*
            if ((cnt+1) % 2 != 0)
            {
                if (data[i].type == GenericDataType.U2 || data[i].type == GenericDataType.U4 ||
                    data[i].type == GenericDataType.I2 || data[i].type == GenericDataType.I4 ||
                    data[i].type == GenericDataType.R4 || data[i].type == GenericDataType.R8 ||
                    data[i].type == GenericDataType.DN)
                {
                    bs ~= cast(ubyte) 0;
                    cnt++;
                }
            }
            */
            bs ~= data[i].getBytes();
            cnt += data[i].size;
        }
        return bs.data;
    }

    override size_t getReclen()
    {
        ushort l = 2;
        foreach(d; data)
        {
            l += d.size;
            //if (l % 2) l++;
        }
        return l;
    }
}
