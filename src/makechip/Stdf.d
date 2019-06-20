module makechip.Stdf;
import std.stdio;
import std.range;
import std.array;
import std.traits;
import makechip.util.InputSource;
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
        return description;
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
    ATR = new const RecordType(null, "Audit Trail Record",                0, 20),
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
    GenericData_t type;

    this(GenericData_t type, ByteReader s)
    {
        if      (type == GenericData_t.U1) { U1 x = U1(s); h.a = x; }
        else if (type == GenericData_t.U2) { U2 x = U2(s); h.b = x; }
        else if (type == GenericData_t.U4) { U4 x = U4(s); h.c = x; }
        else if (type == GenericData_t.I1) { I1 x = I1(s); h.d = x; }
        else if (type == GenericData_t.I2) { I2 x = I2(s); h.e = x; }
        else if (type == GenericData_t.I4) { I4 x = I4(s); h.f = x; }
        else if (type == GenericData_t.R4) { R4 x = R4(s); h.g = x; }
        else if (type == GenericData_t.R8) { R8 x = R8(s); h.h = x; }
        else if (type == GenericData_t.CN) { CN x = CN(s); h.i = x; }
        else if (type == GenericData_t.BN) { BN x = BN(s); h.j = x; }
        else if (type == GenericData_t.DN) { DN x = DN(s); h.k = x; }
        else if (type == GenericData_t.N1) { N1 x = N1(s); h.l = x; }
    }

    this(ubyte v)   { U1 x = U1(v); h.a = x; type = GenericData_t.U1; } 
    this(ushort v)  { U2 x = U2(v); h.b = x; type = GenericData_t.U2; }
    this(uint v)    { U4 x = U4(v); h.c = x; type = GenericData_t.U4; }
    this(byte v)    { I1 x = I1(v); h.d = x; type = GenericData_t.I1; }
    this(short v)   { I2 x = I2(v); h.e = x; type = GenericData_t.I2; }
    this(int v)     { I4 x = I4(v); h.f = x; type = GenericData_t.I4; }
    this(float v)   { R4 x = R4(v); h.g = x; type = GenericData_t.R4; }
    this(double v)  { R8 x = R8(v); h.h = x; type = GenericData_t.R8; }
    this(string v)  { CN x = CN(v); h.i = x; type = GenericData_t.CN; }
    this(ubyte[] v) { BN x = BN(v); h.j = x; type = GenericData_t.BN; }
    this(size_t nbits, ubyte[] v) { DN x = DN(nbits, v); h.k = x; type = GenericData_t.DN; }
    this(ubyte b) { N1 x = N1(b); h.l = x; type = GenericData_t.N1; }

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

    /*
    ubyte[] getBytes(Cpu_t cpu)
    {
        ubyte[] bs;
        switch (type) with (GenericData_t)
        {
        case U1: bs = getU1Bytes(h.a); break;
        case U2: bs = getU2Bytes(h.b); break;
        case U4: bs = getU4Bytes(h.c); break;
        case I1: bs = getI1Bytes(h.d); break;
        case I2: bs = getI2Bytes(h.e); break;
        case I4: bs = getI4Bytes(h.f); break;
        case R4: bs = getR4Bytes(h.g); break;
        case R8: bs = getR8Bytes(h.h); break;
        case CN: bs = getCNBytes(h.i); break;
        case BN: bs = getBNBytes(h.j); break;
        case DN: bs = getDNBytes(numBits, h.j); break;
        default: bs ~= h.a;
        }
        return bs;
    }
    */

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
        case CN: return cast(ushort) h.i.size;
        case BN: return cast(ushort) h.j.size;
        case DN: return cast(ushort) h.k.size;
        default: 
        }
        return 1;
    }
}
import std.typecons;
// Field type holders
struct CN
{
    ubyte[] myVal;

    this(ByteReader s)
    {
        size_t len = s.front;
        myVal = s.getBytes(len+1).dup;
    }

    this(string v)
    {
        assert(v.length < 256);
        myVal = new ubyte[1 + v.length];
        myVal[0] = cast(ubyte) v.length;
        for (int i=0; i<v.length; i++) myVal[i+1] = v[i];
    }

    public string getValue() { return cast(immutable(char)[]) myVal; }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return myVal.length; }
    public string toString()
    {
        string s = cast(immutable(char)[]) myVal[1..$];
        return s;
    }

}

struct C1
{
    ubyte[] myVal;

    public this(ByteReader s) { myVal = s.getBytes(1).dup; }
    public this(char c) { myVal = new ubyte[1]; myVal[0] = cast(ubyte) c; }
    public char getValue() { return cast(char) myVal[0]; }
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
    ubyte[] myVal;

    this(ByteReader s) { myVal = s.getBytes(1).dup; } 
    this(ubyte b) { myVal = new ubyte[1]; myVal[0] = b; }
    public ubyte getValue() { return myVal[0]; }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    import std.digest;
    public string toString() { return toHexString(myVal); }
}
        
struct U2  
{
    ubyte[] myVal;

    this(ByteReader s) { myVal = s.getBytes(2).dup; }
    this(ushort b) 
    {
        myVal = new ubyte[2];
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
    }
    public ushort getValue() { return cast(ushort) (myVal[0] + (myVal[1] << 8)); }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 2; }
    public string toString() { return to!string(getValue()); }
}

struct U4
{   
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(4).dup; }
    this(uint b)
    {
        myVal = new ubyte[4];
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
        myVal[2] = cast(ubyte) ((b & 0xFF0000) >> 16);
        myVal[3] = cast(ubyte) ((b & 0xFF000000) >> 24);
    }

    public uint getValue() { return cast(uint) (myVal[0] + (myVal[1] << 8) + (myVal[2] << 16) + (myVal[3] << 24)); }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 4; }
    public string toString() { return to!string(getValue()); }
}

struct I1
{
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(1).dup; }
    this(byte b) { myVal = new ubyte[1]; myVal[0] = cast(ubyte) b; }
    public byte getValue() { return cast(byte) myVal[0]; }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    public string toString() { return to!string(cast(byte) myVal[0]); }
}

struct I2
{
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(2).dup; }
    this(short b)
    {
        myVal = new ubyte[2];
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
    }
    public short getValue() { return cast(short) (myVal[0] + (myVal[1] << 8)); }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 2; }
    public string toString() { return to!string(getValue()); }
}

struct I4
{
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(4).dup; }
    this(int b)
    {
        myVal = new ubyte[4];
        myVal[0] = cast(ubyte) (b & 0xFF);
        myVal[1] = cast(ubyte) ((b & 0xFF00) >> 8);
        myVal[2] = cast(ubyte) ((b & 0xFF0000) >> 16);
        myVal[3] = cast(ubyte) ((b & 0xFF000000) >> 24);
    }
    public int getValue() { return cast(int) (myVal[0] + (myVal[1] << 8) + (myVal[2] << 16) + (myVal[3] << 24)); }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 4; }
    public string toString() { return to!string(getValue()); }
}

struct R4
{
    import std.bitmanip;
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(4).dup; }
    this(float v)
    {
        FloatRep f;
        f.value = v;
        uint x = 0;
        x |= f.sign ? 0x80000000 : 0;
        uint exp = (f.exponent << 23) & 0x7F800000;
        x |= exp;
        x |= f.fraction & 0x007FFFFF;
        myVal = new ubyte[4];
        myVal[0] = cast(ubyte) (x & 0xFF);
        myVal[1] = cast(ubyte) ((x & 0xFF00) >> 8);
        myVal[2] = cast(ubyte) ((x & 0xFF0000) >> 16);
        myVal[3] = cast(ubyte) ((x & 0xFF000000) >> 24);
    }
    public float getValue()
    {
        uint x = cast(uint) (myVal[0] + (myVal[1] << 8) + (myVal[2] << 16) + (myVal[3] << 24));
        FloatRep f;
        f.sign = (x & 0x80000000) == 0x80000000;
        f.exponent = cast(ubyte) ((x & 0x7F800000) >> 23);
        f.fraction = x & 0x007FFFFF;
        return f.value;
    }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 4; }
    public string toString() { return to!string(getValue()); }
}

struct R8
{
    import std.bitmanip;
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(8).dup; }
    this(double d)
    {
        DoubleRep f;
        f.value = d;
        ulong x = 0L;
        x |= f.sign ? 0x8000000000000000L : 0L;
        ulong exp = (cast(ulong) f.exponent << 52) & 0x7FF0000000000000L;
        x |= exp;
        x |= f.fraction & 0xFFFFFFFFFFFFFL;
        myVal = new ubyte[8];
        myVal[0] = cast(ubyte) (x & 0xFFL);
        myVal[1] = cast(ubyte) ((x & 0xFF00L) >> 8);
        myVal[2] = cast(ubyte) ((x & 0xFF0000L) >> 16);
        myVal[3] = cast(ubyte) ((x & 0xFF000000L) >> 24);
        myVal[4] = cast(ubyte) ((x & 0xFF00000000L) >> 32);
        myVal[5] = cast(ubyte) ((x & 0xFF0000000000L) >> 40);
        myVal[6] = cast(ubyte) ((x & 0xFF000000000000L) >> 48);
        myVal[7] = cast(ubyte) ((x & 0xFF00000000000000L) >> 56);
    }
    public double getValue()
    {
        ulong x = (cast(ulong) myVal[0] + (cast(ulong) myVal[1] << 8) + (cast(ulong) myVal[2] << 16) + (cast(ulong) myVal[3] << 24) +
                  (cast(ulong) myVal[4] << 32) + (cast(ulong) myVal[5] << 40) + (cast(ulong) myVal[6] << 48) + (cast(ulong) myVal[7] << 56));
        DoubleRep f;
        f.sign = (x & 0x8000000000000000L) == 0x8000000000000000L;
        f.exponent = cast(ushort) ((x & 0x7FF0000000000000L) >> 52);
        f.fraction = x & 0xFFFFFFFFFFFFFL;
        return f.value;
    }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 8; }
    public string toString() { return to!string(getValue()); }
}

struct BN 
{
    ubyte[] myVal;
    this(ByteReader s)
    {
        size_t l = s.front();
        myVal = s.getBytes(l+1).dup;
    }
    this(ubyte[] b)
    {
        myVal = new ubyte[1 + b.length];
        myVal[0] = cast(ubyte) b.length;
        for (int i=0; i<b.length; i++) myVal[i+i] = b[i];
    }
    public ubyte[] getValue() { return myVal[1..$]; }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return myVal.length; }
    public string toString() { return to!string(myVal); }
}

struct DN 
{
    ubyte[] myVal;
    ushort numBits;
    this(ByteReader s)
    {
        ubyte b0 = s.getByte();
        ubyte b1 = s.getByte();
        numBits = cast(ushort) (b0 + (b1 << 8));
        size_t l = (numBits % 8 == 0) ? numBits/8 : numBits/8 + 1;
        myVal = new ubyte[2 + l];
        myVal[0] = b0;
        myVal[1] = b1;
        for (int i=0; i<l; i++) myVal[i+2] = s.getByte();
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
    public ubyte[] getValue() { return myVal[2..$]; }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return myVal.length; }
    public string toString()
    {
        return to!string(numBits) ~ ", " ~ to!string(myVal[2..$]);
    }
}

struct N1 
{
    ubyte[] myVal;
    this(ByteReader s) { myVal = s.getBytes(1); }
    this(ubyte val)
    {
        myVal = new ubyte[1];
        myVal[0] = val;
    }
    this(ubyte val1, ubyte val2)
    {
        myVal = new ubyte[1];
        myVal[0] = val1;
        myVal[0] |= (val2 << 4) & 0xF0;
    }
    public ubyte getValue()
    {
        return myVal[0];
    }
    public ubyte[] getBytes() { return myVal.dup; }
    public @property size_t size() { return 1; }
    public string toString() { return to!string(getValue()); }
}

struct OptionalField(T) 
    if (is(T == DN) || is(T == U1) || is(T == U2) || 
        is(T == U4) || is(T == I1) || is(T == I2) ||
        is(T == I4) || is(T == R4) || is(T == CN))
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


    private bool empty;
    T myVal;
    public const ACT_TYPE defaultValue;

    this(ref size_t reclen, ByteReader s, ACT_TYPE defaultValue)
    {
        empty = true;
        this.defaultValue = defaultValue;
        static if (is (T : CN))
        {
            size_t l = s.front();
            if (reclen > l)
            {
                myVal = CN(s);
                reclen -= l + 1;
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
                    myVal = DN(s);
                    reclen -= l + 2;
                    empty = false;
                }
            }
            else
            {
                if (reclen >= myVal.size)
                {
                    myVal = T(s);
                    reclen -= myVal.size;
                    empty = false;
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

    public ACT_TYPE getValue()
    {
        if (empty) return cast(ACT_TYPE) defaultValue;
        return myVal.getValue();
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
struct OptionalArray(T) if (is(T == U2) || is(T == N1) || is(T == R4))
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
        }
    }
    private bool empty;
    private T[] val;

    public ACT_TYPE value(int index)
    {
        return val[index].getValue();
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
                    val[i] = T(s);
                }
                empty = false;
                reclen -= (cnt+1)/2;
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
                    if (reclen > len) val[i] = T(s);
                    reclen -= len + 1;
                    empty = false;
                }
            }
            else
            {
                static if (is (T == U2) || is (T == R4))
                {
                    size_t siz = 0;
                    static if (is(T == U2)) { siz = 2; } else { siz = 4; }
                    if (reclen >= siz * cnt)
                    {
                        val.length = cnt;
                        for (int i=0; i<cnt; i++) 
                        {
                            val[i] = T(s);
                            reclen -= val[i].size;
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

unittest
{
    import std.file;
    foreach(string name; dirEntries("stdf", SpanMode.depth))
    {
        writeln("file = ", name);
        StdfReader stdf = new StdfReader(name);
        stdf.read();
    }

}

class StdfReader
{
    private ByteReader src;
    public const string filename;
    private StdfRecord[] records = new StdfRecord[100000];
    
    this(string filename)
    {
        this.filename = filename;
        auto f = new File(filename, "rb");
        src = new BinarySource(filename);
    }

    StdfRecord[] getRecords() { return(records); }

    void read()
    {
        records.length = 100000;
        while (src.remaining() > 1)
        {
            ubyte b0 = src.getByte();
            ubyte b1 = src.getByte();
            size_t reclen = ((cast(size_t) b0) + (((cast(size_t) b1) << 8L) & 0xFF00L)) & 0xFFFFL;
            if (reclen < 2) break;
            ubyte rtype = src.getByte();
            ubyte stype = src.getByte();
            Record_t type = RecordType.getRecordType(rtype, stype);
            writeln("type = ", type, " reclen = ", reclen);
            if (type is null)
            {
                writeln("Corrupt file: ", filename, " invalid record type:");
                writeln("type = ", rtype, " subtype = ", stype);
                throw new Exception(filename);
            }
            StdfRecord r;
            switch (type.ordinal) with (Record_t)
            {
                case ATR.ordinal: r = new AuditTrailRecord(src); break;
                case BPS.ordinal: r = new BeginProgramSelectionRecord(src); break;
                case DTR.ordinal: r = new DatalogTextRecord(src); break;
                case EPS.ordinal: r = new EndProgramSelectionRecord(); break;
                case FAR.ordinal: r = new FileAttributesRecord(src); break;
                case FTR.ordinal: r = new FunctionalTestRecord(reclen, src); break;
                case GDR.ordinal: r = new GenericDataRecord(reclen, src); break;
                case HBR.ordinal: r = new HardwareBinRecord(src); break;
                case MIR.ordinal: r = new MasterInformationRecord(reclen, src); break;
                case MPR.ordinal: r = new MultipleResultParametricRecord(reclen, src); break;
                case MRR.ordinal: r = new MasterResultsRecord(src); break;
                case PCR.ordinal: r = new PartCountRecord(src); break;
                case PGR.ordinal: r = new PinGroupRecord(src); break;
                case PIR.ordinal: r = new PartInformationRecord(src); break;
                case PLR.ordinal: r = new PinListRecord(src); break;
                case PMR.ordinal: r = new PinMapRecord(src); break;
                case PRR.ordinal: r = new PartResultsRecord(src); break;
                case PTR.ordinal: r = new ParametricTestRecord(reclen, src); break;
                case RDR.ordinal: r = new RetestDataRecord(reclen, src); break;
                case SBR.ordinal: r = new SoftwareBinRecord(src); break;
                case SDR.ordinal: r = new SiteDescriptionRecord(src); break;
                case TSR.ordinal: r = new TestSynopsisRecord(reclen, src); break;
                case WCR.ordinal: r = new WaferConfigurationRecord(src); break;
                case WIR.ordinal: r = new WaferInformationRecord(src); break;
                case WRR.ordinal: r = new WaferResultsRecord(src); break;
                default: throw new Exception("Unknown record type: " ~ type.stringof);
            }
            writeln(r.toString());
            stdout.flush();
            records ~= r;
        }
    }
} // end class StdfReader

class StdfRecord
{
    const Record_t recordType;

    this(const Record_t recordType)
    {
        this.recordType = recordType;
    }

    abstract override string toString();

    //abstract ubyte[] getBytes();
    protected abstract size_t getReclen();

    bool isTestRecord()
    {
        Record_t t = recordType;
        return t == Record_t.FTR || t == Record_t.PTR || t == Record_t.MPR || t == Record_t.DTX;
    }

    /*
    ubyte[] getHeaderBytes()
    {
        ubyte[] b = new ubyte[4 + reclen];
        auto bs = getU2Bytes(reclen);
        b[0] = bs[0];
        b[1] = bs[1];
        b[2] = recordType.recordType;
        b[3] = recordType.recordSubType;
        b.length = 4;
        return b;
    }
    */
}

//        date = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
class AuditTrailRecord : StdfRecord
{
    U4 date;
    CN cmdLine;

    this(ByteReader s)
    {
        super(Record_t.ATR);
        date = U4(s);
        cmdLine = CN(s); 
    }

    this(uint date, string cmdLine)
    {
        super(Record_t.ATR);
        this.date = U4(date);
        this.cmdLine = CN(cmdLine);
    }

    override protected size_t getReclen()
    {
        return cast(ushort) (4 + cmdLine.size);
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        Duration d = date - DateTime(1970, 1, 1, 0, 0, 0); 
        uint dt = cast(uint) d.total!"seconds";
        auto b1 = getU4Bytes(dt);
        foreach(c; b1) bs ~= c;
        auto b2 = getCNBytes(cmdLine);
        foreach(c; b2) bs ~= c;
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n    date = ");
        app.put(date.toString());
        app.put("\n    cmdLine = ");
        app.put(cmdLine.toString());
        app.put("\n");
        return app.data;
    }
}

class BeginProgramSelectionRecord : StdfRecord
{
    CN seqName;

    this(ByteReader s)
    {
        super(Record_t.BPS);
        seqName = CN(s);
    }

    this(string seqName)
    {
        super(Record_t.BPS);
        this.seqName = CN(seqName);
    }

    override protected size_t getReclen()
    {
        return cast(ushort) (seqName.size);
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        auto b1 = getCNBytes(seqName);
        foreach(c; b1) bs ~= c;
        return bs;
    }
    */

    override string toString()
    {
        return recordType.description ~ ":\n    seqName = " ~ seqName.toString() ~ "\n";
    }
}

class DatalogTextRecord : StdfRecord
{
    CN text;

    this(ByteReader s)
    {
        super(Record_t.DTR);
        text = CN(s);
    }

    this(string text)
    {
        super(Record_t.DTR);
        this.text = CN(text);
    }

    override protected size_t getReclen()
    {
        return text.size;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        auto b = getCNBytes(text);
        foreach(c; b) bs ~= c;
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n    text = ");
        app.put(text.toString());
        app.put("\n");
        return app.data;
    }
}

class EndProgramSelectionRecord : StdfRecord
{

    this()
    {
        super(Record_t.EPS);
    }

    override protected size_t getReclen()
    {
        return 0;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        return bs;
    }
    */

    override string toString()
    {
        return recordType.description;
    }
}

class FileAttributesRecord : StdfRecord
{
    private U1 cpu_type;
    private U1 stdfVersion;

    this(ByteReader s)
    {
        super(Record_t.FAR);
        cpu_type = U1(s);
        if (cpu_type.getValue() != 2) assert(false, "INVALID CPU TYPE: " ~ cpu_type.toString());
        stdfVersion = U1(s);
    }

    this(uint stdfVersion)
    {
        super(Record_t.FAR);
        cpu_type = U1(2);
        this.stdfVersion = U1(cast(ubyte) stdfVersion);
    }

    override protected size_t getReclen()
    {
        return 2;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= type;
        bs ~= stdfVersion;
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n    cpu = PC");
        app.put("    stdfVersion = ");
        app.put(stdfVersion.toString());
        app.put("\n");
        return app.data;
    }
}

abstract class TestRecord : StdfRecord
{
    U4 test_num;
    U1 head_num;
    U1 site_num;
    U1 test_flg;

    this(Record_t type, ByteReader s)
    {
        super(type);
        test_num = U4(s);
        head_num = U1(s);
        site_num = U1(s);
        test_flg = U1(s);
    }

    this(Record_t type, uint test_num, ubyte head_num, ubyte site_num, ubyte test_flg)
    {
        super(type);
        this.test_num = U4(test_num);
        this.head_num = U1(head_num);
        this.site_num = U1(site_num);
        this.test_flg = U1(test_flg);
    }
 
    protected string getString()
    {
        auto app = appender!string();
        app.put("    test_num = "); 
        app.put(test_num.toString());
        app.put("\n    head_num = ");
        app.put(head_num.toString());
        app.put("\n    site_num = ");
        app.put(site_num.toString());
        app.put("\n    test_flg = ");
        app.put(test_flg.toString());
        return app.data;
    }

    override abstract protected size_t getReclen();
    //override abstract ubyte[] getBytes();
    override abstract string toString();

}

class FunctionalTestRecord : TestRecord
{
    OptionalField!(U1) opt_flag;
    OptionalField!(U4) cycl_cnt;
    OptionalField!(U4) rel_vadr;
    OptionalField!(U4) rept_cnt;
    OptionalField!(U4) num_fail;
    OptionalField!(I4) xfail_ad;
    OptionalField!(I4) yfail_ad;
    OptionalField!(I2) vect_off;
    OptionalField!(U2) rtn_icnt;
    OptionalField!(U2) pgm_icnt;
    OptionalArray!(U2) rtn_indx;
    OptionalArray!(N1) rtn_stat;
    OptionalArray!(U2) pgm_indx;
    OptionalArray!(N1) pgm_stat;
    OptionalField!(DN) fail_pin;
    OptionalField!(CN) vect_nam;
    OptionalField!(CN) time_set;
    OptionalField!(CN) op_code;
    OptionalField!(CN) test_txt;
    OptionalField!(CN) alarm_id;
    OptionalField!(CN) prog_txt;
    OptionalField!(CN) rslt_txt;
    OptionalField!(U1) patg_num;
    OptionalField!(DN) spin_map;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.FTR, s);
        reclen -= 7;
        opt_flag = OptionalField!(U1)(reclen, s, 0xFF);
        cycl_cnt = OptionalField!(U4)(reclen, s, 0);
        rel_vadr = OptionalField!(U4)(reclen, s, 0);
        rept_cnt = OptionalField!(U4)(reclen, s, 0);
        num_fail = OptionalField!(U4)(reclen, s, 0);
        xfail_ad = OptionalField!(I4)(reclen, s, 0);
        yfail_ad = OptionalField!(I4)(reclen, s, 0);
        vect_off = OptionalField!(I2)(reclen, s, 0);
        rtn_icnt = OptionalField!(U2)(reclen, s, 0);
        pgm_icnt = OptionalField!(U2)(reclen, s, 0);
        rtn_indx = OptionalArray!(U2)(reclen, rtn_icnt.getValue(), s);
        rtn_stat = OptionalArray!(N1)(reclen, rtn_icnt.getValue(), s);
        pgm_indx = OptionalArray!(U2)(reclen, pgm_icnt.getValue(), s);
        pgm_stat = OptionalArray!(N1)(reclen, pgm_icnt.getValue(), s);
        fail_pin = OptionalField!(DN)(reclen, s, new ubyte[0]);
        vect_nam = OptionalField!(CN)(reclen, s, "");
        time_set = OptionalField!(CN)(reclen, s, "");
        op_code  = OptionalField!(CN)(reclen, s, "");
        test_txt = OptionalField!(CN)(reclen, s, "");
        alarm_id = OptionalField!(CN)(reclen, s, "");
        prog_txt = OptionalField!(CN)(reclen, s, "");
        rslt_txt = OptionalField!(CN)(reclen, s, "");
        patg_num = OptionalField!(U1)(reclen, s, 0);
        spin_map = OptionalField!(DN)(reclen, s, new ubyte[0]);
    }

    this(uint test_num,
         ubyte head_num,
         ubyte site_num,
         ubyte test_flg,
         OptionalField!(U1) opt_flag,
         OptionalField!(U4) cycl_cnt,
         OptionalField!(U4) rel_vadr,
         OptionalField!(U4) rept_cnt,
         OptionalField!(U4) num_fail,
         OptionalField!(I4) xfail_ad,
         OptionalField!(I4) yfail_ad,
         OptionalField!(I2) vect_off,
         OptionalField!(U2) rtn_icnt,
         OptionalField!(U2) pgm_icnt,
         OptionalArray!(U2) rtn_indx,
         OptionalArray!(N1) rtn_stat,
         OptionalArray!(U2) pgm_indx,
         OptionalArray!(N1) pgm_stat,
         OptionalField!(DN) fail_pin,
         OptionalField!(CN) vect_nam,
         OptionalField!(CN) time_set,
         OptionalField!(CN) op_code,
         OptionalField!(CN) test_txt,
         OptionalField!(CN) alarm_id,
         OptionalField!(CN) prog_txt,
         OptionalField!(CN) rslt_txt,
         OptionalField!(U1) patg_num,
         OptionalField!(DN) spin_map)
    {
        super(Record_t.FTR, test_num, head_num, site_num, test_flg);
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
        this.fail_pin = fail_pin;
        this.vect_nam = vect_nam;
        this.time_set = time_set;
        this.op_code = op_code;
        this.test_txt = test_txt;
        this.alarm_id = alarm_id;
        this.prog_txt = prog_txt;
        this.rslt_txt = rslt_txt;
        this.patg_num = patg_num;
        this.spin_map = spin_map;
    }

    override protected size_t getReclen()
    {
        size_t l = 7;
        l += opt_flag.size;
        l += cycl_cnt.size;
        l += rel_vadr.size;
        l += rept_cnt.size;
        l += num_fail.size;
        l += xfail_ad.size;
        l += yfail_ad.size;
        l += vect_off.size;
        l += rtn_icnt.size;
        l += pgm_icnt.size;
        l += rtn_indx.size;
        l += rtn_stat.size;
        l += pgm_indx.size;
        l += pgm_stat.size;
        l += fail_pin.size;
        l += vect_nam.size;
        l += time_set.size;
        l +=  op_code.size;
        l += test_txt.size;
        l += alarm_id.size;
        l += prog_txt.size;
        l += rslt_txt.size;
        l += patg_num.size;
        l += spin_map.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU4Bytes(test_num);
        bs ~= getU1Bytes(head_num);
        bs ~= getU1Bytes(site_num);
        bs ~= getU1Bytes(test_flg);
        if (opt_flag.valid) bs ~= getU1Bytes(opt_flag);
        if (cycl_cnt.valid) bs ~= getU4Bytes(cycl_cnt);
        if (rel_vadr.valid) bs ~= getU4Bytes(rel_vadr);
        if (rept_cnt.valid) bs ~= getU4Bytes(rept_cnt);
        if (num_fail.valid) bs ~= getU4Bytes(num_fail);
        if (xfail_ad.valid) bs ~= getI4Bytes(xfail_ad);
        if (yfail_ad.valid) bs ~= getI4Bytes(yfail_ad);
        if (vect_off.valid) bs ~= getI2Bytes(vect_off);
        if (rtn_icnt.valid) bs ~= getU2Bytes(rtn_icnt);
        if (pgm_icnt.valid) bs ~= getU2Bytes(pgm_icnt);
        if (rtn_indx !is null) foreach(u; rtn_indx) bs ~= getU2Bytes(u);
        if (rtn_stat !is null) foreach(b; rtn_stat) bs ~= getU1Bytes(b);
        if (pgm_indx !is null) foreach(u; pgm_indx) bs ~= getU2Bytes(u);
        if (pgm_stat !is null) foreach(b; pgm_stat) bs ~= getU1Bytes(b);
        if (fail_pin !is null) bs ~= getDNBytes(fail_pin_bits, fail_pin);
        if (vect_nam !is null) bs ~= getCNBytes(vect_nam);
        if (time_set !is null) bs ~= getCNBytes(time_set);
        if (op_code !is null) bs ~= getCNBytes(op_code);
        if (test_txt !is null) bs ~= getCNBytes(test_txt);
        if (alarm_id !is null) bs ~= getCNBytes(alarm_id);
        if (prog_txt !is null) bs ~= getCNBytes(prog_txt);
        if (rslt_txt !is null) bs ~= getCNBytes(rslt_txt);
        if (patg_num.valid) bs ~= getU1Bytes(patg_num);
        if (spin_map !is null) bs ~= getDNBytes(spin_map_bits, spin_map);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put(recordType.description);
        app.put(":\n");
        app.put(getString());        
        if (!opt_flag.empty) { app.put("    opt_flag = "); app.put(to!string(opt_flag)); }
        if (!cycl_cnt.empty) { app.put("\n    cycl_cnt = "); app.put(to!string(cycl_cnt)); }
        if (!rel_vadr.empty) { app.put("\n    rel_vadr = "); app.put(to!string(rel_vadr)); }
        if (!rept_cnt.empty) { app.put("\n    rept_cnt = "); app.put(to!string(rept_cnt)); }
        if (!num_fail.empty) { app.put("\n    num_fail = "); app.put(to!string(num_fail)); }
        if (!xfail_ad.empty) { app.put("\n    xfail_ad = "); app.put(to!string(xfail_ad)); }
        if (!yfail_ad.empty) { app.put("\n    yfail_ad = "); app.put(to!string(yfail_ad)); }
        if (!vect_off.empty) { app.put("\n    vect_off = "); app.put(to!string(vect_off)); }
        if (!rtn_icnt.empty) { app.put("\n    rtn_icnt = "); app.put(to!string(rtn_icnt)); }
        if (!pgm_icnt.empty) { app.put("\n    pgm_icnt = "); app.put(to!string(pgm_icnt)); }
        if (!rtn_indx.empty) { app.put("\n    rtn_indx = "); app.put(to!string(rtn_indx)); }
        if (!rtn_stat.empty) { app.put("\n    rtn_stat = "); app.put(to!string(rtn_stat)); }
        if (!pgm_indx.empty) { app.put("\n    pgm_indx = "); app.put(to!string(pgm_indx)); }
        if (!pgm_stat.empty) { app.put("\n    pgm_stat = "); app.put(to!string(pgm_stat)); }
        if (!fail_pin.empty) { app.put("\n    fail_pin = "); app.put(to!string(fail_pin)); }
        if (!vect_nam.empty) { app.put("\n    vect_nam = "); app.put(to!string(vect_nam)); }
        if (!time_set.empty) { app.put("\n    time_set = "); app.put(to!string(time_set)); }
        if (!op_code.empty)  { app.put("\n    op_code = "); app.put(to!string(op_code)); }
        if (!test_txt.empty) { app.put("\n    test_txt = "); app.put(to!string(test_txt)); }
        if (!alarm_id.empty) { app.put("\n    alarm_id = "); app.put(to!string(alarm_id)); }
        if (!prog_txt.empty) { app.put("\n    prog_txt = "); app.put(to!string(prog_txt)); }
        if (!rslt_txt.empty) { app.put("\n    rslt_txt = "); app.put(to!string(rslt_txt)); }
        if (!patg_num.empty) { app.put("\n    patg_num = "); app.put(to!string(patg_num)); }
        if (!spin_map.empty) { app.put("\n    spin_map = "); app.put(to!string(spin_map)); }
        return app.data;
    }
}

class GenericDataRecord : StdfRecord
{
    private GenericData[] data;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.GDR);
        ubyte b0 = s.getByte();
        ubyte b1 = s.getByte();
        ushort fld_cnt = cast(ushort) (b0 + ((b1 << 8) & 0xFF00));
        for (ushort i=0; i<fld_cnt; i++)
        {
            GenericData_t type = getDataType(s.getByte());
            if (type == GenericData_t.B0)
            {
                i--;
                continue;
            }
            auto d = GenericData(type, s);
            data ~= d;
        }
    }

    this(GenericData[] data)
    {
        super(Record_t.GDR);
        foreach(d; data) this.data ~= d;
    }

    override protected size_t getReclen()
    {
        ushort l = 2;
        foreach(d; data)
        {
            l += d.size;
            if (l % 2) l++;
        }
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU2Bytes(cast(ushort) data.length);
        foreach(d; data)
        {
            auto b = d.getBytes(cpu);
            bs ~= b;
            if (b.length % 2) bs ~= 0;
        }
        return bs;
    }
    */

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
    U1 head_num;
    U1 site_num;
    U2 hbin_num;
    U4 hbin_cnt;
    OptionalField!C1 hbin_pf;
    OptionalField!CN hbin_nam;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.HBR);
        head_num = U1(s);
        site_num = U1(s);
        hbin_num = U2(s);
        hbin_cnt = U4(s);
        reclen -= 8;
        hbin_pf = OptionalField!C1(reclen, s, ' ');
        hbin_nam = OptionalField!CN(reclen, s, "");
    }

    this(ubyte head_num, ubyte site_num, ushort hbin_num, uint hbin_cnt, OptionalField!C1 hbin_pf, OptionalField!CN hbin_nam)
    {
        super(Record_t.HBR);
        this.head_num = U1!(head_num);
        this.site_num = U1!(site_num);
        this.hbin_num = U2!(hbin_num);
        this.hbin_cnt = U4!(hbin_cnt);
        this.hbin_pf = hbin_pf;
        this.hbin_nam = hbin_nam;
    }

    override protected size_t getReclen()
    {
        return cast(ushort) (9 + hbin_nam.size);
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU1Bytes(head_num);
        bs ~= getU1Bytes(site_num);
        bs ~= getU2Bytes(hbin_num);
        bs ~= getU4Bytes(hbin_cnt);
        bs ~= cast(ubyte) hbin_pf;
        bs ~= getCNBytes(hbin_nam);
        return bs;
    }
    */

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
    U4 setup_t;
    U4 start_t;
    U1 stat_num;
    C1 mode_cod;
    C1 rtst_cod;
    C1 prot_cod;
    U2 burn_tim;
    C1 cmod_cod;
    CN lot_id;
    CN part_typ;
    CN node_nam;
    CN tstr_typ;
    CN job_nam;
    OptionalField!CN job_rev;
    OptionalField!CN sblot_id;
    OptionalField!CN oper_nam;
    OptionalField!CN exec_typ;
    OptionalField!CN exec_ver;
    OptionalField!CN test_cod;
    OptionalField!CN tst_temp;
    OptionalField!CN user_txt;
    OptionalField!CN aux_file;
    OptionalField!CN pkg_typ;
    OptionalField!CN famly_id;
    OptionalField!CN date_cod;
    OptionalField!CN facil_id;
    OptionalField!CN floor_id;
    OptionalField!CN proc_id;
    OptionalField!CN oper_frq;
    OptionalField!CN spec_nam;
    OptionalField!CN spec_ver;
    OptionalField!CN flow_id;
    OptionalField!CN setup_id;
    OptionalField!CN dsgn_rev;
    OptionalField!CN eng_id;
    OptionalField!CN rom_cod;
    OptionalField!CN serl_num;
    OptionalField!CN supr_nam;

    //    start_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
    this(size_t reclen, ByteReader s)
    {
        super(Record_t.MIR);
        setup_t = U4(s);
        start_t = U4(s);
        stat_num = U1(s);
        mode_cod = C1(s);
        rtst_cod = C1(s);
        prot_cod = C1(s);
        burn_tim = U2(s);
        cmod_cod = C1(s);
        reclen -= 15;
        lot_id = CN(s);
        reclen -= lot_id.size;
        part_typ = CN(s);
        reclen -= part_typ.size;
        node_nam = CN(s);
        reclen -= node_nam.size;
        tstr_typ = CN(s);
        reclen -= tstr_typ.size;
        job_nam = CN(s);
        reclen -= job_nam.size;
        job_rev = OptionalField!CN(reclen, s, "");
        sblot_id = OptionalField!CN(reclen, s, "");
        oper_nam = OptionalField!CN(reclen, s, "");
        exec_typ = OptionalField!CN(reclen, s, "");
        exec_ver = OptionalField!CN(reclen, s, "");
        test_cod = OptionalField!CN(reclen, s, "");
        tst_temp = OptionalField!CN(reclen, s, "");
        user_txt = OptionalField!CN(reclen, s, "");
        aux_file = OptionalField!CN(reclen, s, "");
        pkg_typ = OptionalField!CN(reclen, s, "");
        famly_id = OptionalField!CN(reclen, s, "");
        date_cod = OptionalField!CN(reclen, s, "");
        facil_id = OptionalField!CN(reclen, s, "");
        floor_id = OptionalField!CN(reclen, s, "");
        proc_id = OptionalField!CN(reclen, s, "");
        oper_frq = OptionalField!CN(reclen, s, "");
        spec_nam = OptionalField!CN(reclen, s, "");
        spec_ver = OptionalField!CN(reclen, s, "");
        flow_id = OptionalField!CN(reclen, s, "");
        setup_id = OptionalField!CN(reclen, s, "");
        dsgn_rev = OptionalField!CN(reclen, s, "");
        eng_id = OptionalField!CN(reclen, s, "");
        rom_cod = OptionalField!CN(reclen, s, "");
        serl_num = OptionalField!CN(reclen, s, "");
        supr_nam = OptionalField!CN(reclen, s, "");
    }

    this(U4 setup_t,
         U4 start_t,
         U1 stat_num,
         C1 mode_cod,
         C1 rtst_cod,
         C1 prot_cod,
         U2 burn_tim,
         C1 cmod_cod,
         CN lot_id,
         CN part_typ,
         CN node_nam,
         CN tstr_typ,
         CN job_nam,
         OptionalField!CN job_rev,
         OptionalField!CN sblot_id,
         OptionalField!CN oper_nam,
         OptionalField!CN exec_typ,
         OptionalField!CN exec_ver,
         OptionalField!CN test_cod,
         OptionalField!CN tst_temp,
         OptionalField!CN user_txt,
         OptionalField!CN aux_file,
         OptionalField!CN pkg_typ,
         OptionalField!CN famly_id,
         OptionalField!CN date_cod,
         OptionalField!CN facil_id,
         OptionalField!CN floor_id,
         OptionalField!CN proc_id,
         OptionalField!CN oper_frq,
         OptionalField!CN spec_nam,
         OptionalField!CN spec_ver,
         OptionalField!CN flow_id,
         OptionalField!CN setup_id,
         OptionalField!CN dsgn_rev,
         OptionalField!CN eng_id,
         OptionalField!CN rom_cod,
         OptionalField!CN serl_num,
         OptionalField!CN supr_nam)
    {
        super(Record_t.MIR);
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
    }


    override protected size_t getReclen()
    {
        size_t l = 15;
        l += 1 + lot_id.size;
        l += 1 + part_typ.size;
        l += 1 + node_nam.size;
        l += 1 + tstr_typ.size;
        l += 1 + job_nam.size;
        l += 1 + job_rev.size;
        l += 1 + sblot_id.size;
        l += 1 + oper_nam.size;
        l += 1 + exec_typ.size;
        l += 1 + exec_ver.size;
        l += 1 + test_cod.size;
        l += 1 + tst_temp.size;
        l += 1 + user_txt.size;
        l += 1 + aux_file.size;
        l += 1 + pkg_typ.size;
        l += 1 + famly_id.size;
        l += 1 + date_cod.size;
        l += 1 + facil_id.size;
        l += 1 + floor_id.size;
        l += 1 + proc_id.size;
        l += 1 + oper_frq.size;
        l += 1 + spec_nam.size;
        l += 1 + spec_ver.size;
        l += 1 + flow_id.size;
        l += 1 + setup_id.size;
        l += 1 + dsgn_rev.size;
        l += 1 + eng_id.size;
        l += 1 + rom_cod.size;
        l += 1 + serl_num.size;
        l += 1 + supr_nam.size;
        return 0;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        Duration d = setup_t - DateTime(1970, 1, 1, 0, 0, 0); 
        uint dt = cast(uint) d.total!"seconds";
        bs ~= getU4Bytes(dt);
        d = start_t - DateTime(1970, 1, 1, 0, 0, 0); 
        dt = cast(uint) d.total!"seconds";
        bs ~= getU4Bytes(dt);
        bs ~= stat_num;
        bs ~= cast(ubyte) mode_cod;
        bs ~= cast(ubyte) rtst_cod;
        bs ~= cast(ubyte) prot_cod;
        bs ~= getU2Bytes(burn_tim);
        bs ~= cast(ubyte) cmod_cod;
        bs ~= getCNBytes(lot_id);
        bs ~= getCNBytes(part_typ);
        bs ~= getCNBytes(node_nam);
        bs ~= getCNBytes(tstr_typ);
        bs ~= getCNBytes(job_nam);
        bs ~= getCNBytes(job_rev);
        bs ~= getCNBytes(sblot_id);
        bs ~= getCNBytes(oper_nam);
        bs ~= getCNBytes(exec_typ);
        bs ~= getCNBytes(exec_ver);
        bs ~= getCNBytes(test_cod);
        bs ~= getCNBytes(tst_temp);
        bs ~= getCNBytes(user_txt);
        bs ~= getCNBytes(aux_file);
        bs ~= getCNBytes(pkg_typ);
        bs ~= getCNBytes(famly_id);
        bs ~= getCNBytes(date_cod);
        bs ~= getCNBytes(facil_id);
        bs ~= getCNBytes(floor_id);
        bs ~= getCNBytes(proc_id);
        bs ~= getCNBytes(oper_frq);
        bs ~= getCNBytes(spec_nam);
        bs ~= getCNBytes(spec_ver);
        bs ~= getCNBytes(flow_id);
        bs ~= getCNBytes(setup_id);
        bs ~= getCNBytes(dsgn_rev);
        bs ~= getCNBytes(eng_id);
        bs ~= getCNBytes(rom_cod);
        bs ~= getCNBytes(serl_num);
        bs ~= getCNBytes(supr_nam);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("MasterInformationRecord:");
        app.put("\n    setup_t = ");  app.put(to!string(setup_t));
        app.put("\n    start_t = ");  app.put(to!string(start_t));
        app.put("\n    stat_num = "); app.put(to!string(stat_num));
        app.put("\n    mode_cod = "); app.put(to!string(mode_cod));
        app.put("\n    rtst_cod = "); app.put(to!string(rtst_cod));
        app.put("\n    prot_cod = "); app.put(to!string(prot_cod));
        app.put("\n    burn_tim = "); app.put(to!string(burn_tim));
        app.put("\n    cmod_cod = "); app.put(to!string(cmod_cod));
        app.put("\n    lot_id = ");   app.put(lot_id.toString());
        app.put("\n    part_typ = "); app.put(part_typ.toString());
        app.put("\n    node_nam = "); app.put(node_nam.toString());
        app.put("\n    tstr_typ = "); app.put(tstr_typ.toString());
        app.put("\n    job_nam = ");  app.put(job_nam.toString());
        app.put("\n    job_rev = ");  app.put(job_rev.toString());
        app.put("\n    sblot_id = "); app.put(sblot_id.toString());
        app.put("\n    oper_nam = "); app.put(oper_nam.toString());
        app.put("\n    exec_typ = "); app.put(exec_typ.toString());
        app.put("\n    exec_ver = "); app.put(exec_ver.toString());
        app.put("\n    test_cod = "); app.put(test_cod.toString());
        app.put("\n    tst_temp = "); app.put(tst_temp.toString());
        app.put("\n    user_txt = "); app.put(user_txt.toString());
        app.put("\n    aux_file = "); app.put(aux_file.toString());
        app.put("\n    pkg_typ = ");  app.put(pkg_typ.toString());
        app.put("\n    famly_id = "); app.put(famly_id.toString());
        app.put("\n    date_cod = "); app.put(date_cod.toString());
        app.put("\n    facil_id = "); app.put(facil_id.toString());
        app.put("\n    floor_id = "); app.put(floor_id.toString());
        app.put("\n    proc_id = ");  app.put(proc_id.toString());
        app.put("\n    oper_frq = "); app.put(oper_frq.toString());
        app.put("\n    spec_nam = "); app.put(spec_nam.toString());
        app.put("\n    spec_ver = "); app.put(spec_ver.toString());
        app.put("\n    flow_id = ");  app.put(flow_id.toString());
        app.put("\n    setup_id = "); app.put(setup_id.toString());
        app.put("\n    dsgn_rev = "); app.put(dsgn_rev.toString());
        app.put("\n    eng_id = ");   app.put(eng_id.toString());
        app.put("\n    rom_cod = ");  app.put(rom_cod.toString());
        app.put("\n    serl_num = "); app.put(serl_num.toString());
        app.put("\n    supr_nam = "); app.put(supr_nam.toString());
        app.put("\n");
        return app.data;
    }
}

class ParametricRecord : TestRecord
{
    U1 parm_flg;
    
    this(Record_t type, ByteReader s)
    {
        super(type, s);
        this.parm_flg = U1(s);
    }

    this(Record_t type, uint test_num, ubyte head_num, ubyte site_num, ubyte test_flg, ubyte parm_flg)
    {
        super(type, test_num, head_num, site_num, test_flg);
        this.parm_flg = U1(parm_flg);
    }
 
    override protected string getString()
    {
        auto app = appender!string();
        app.put(super.getString());
        app.put("\n    patm_flg = ");
        app.put(to!string(parm_flg));
        return app.data;
    }

    override abstract protected size_t getReclen();
    //override abstract ubyte[] getBytes();
    override abstract string toString();
}


class MultipleResultParametricRecord : ParametricRecord
{
    OptionalField!U2 rtn_icnt;
    OptionalField!U2 rslt_cnt;
    OptionalArray!N1 rtn_stat;
    OptionalArray!R4 rtn_rslt;
    OptionalField!CN test_txt;
    OptionalField!CN alarm_id;
    OptionalField!U1 opt_flag;
    OptionalField!I1 res_scal;
    OptionalField!I1 llm_scal;
    OptionalField!I1 hlm_scal;
    OptionalField!R4 lo_limit;
    OptionalField!R4 hi_limit;
    OptionalField!R4 start_in;
    OptionalField!R4 incr_in;
    OptionalArray!U2 rtn_indx;
    OptionalField!CN units;
    OptionalField!CN units_in;
    OptionalField!CN c_resfmt;
    OptionalField!CN c_llmfmt;
    OptionalField!CN c_hlmfmt;
    OptionalField!R4 lo_spec;
    OptionalField!R4 hi_spec;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.MPR, s);
        reclen -= 8;
        rtn_icnt = OptionalField!U2(reclen, s, 0);
        rslt_cnt = OptionalField!U2(reclen, s, 0);
        rtn_stat = OptionalArray!N1(reclen, rtn_icnt.getValue(), s);
        rtn_rslt = OptionalArray!R4(reclen, rslt_cnt.getValue(), s);
        test_txt = OptionalField!CN(reclen, s, "");
        alarm_id = OptionalField!CN(reclen, s, "");
        opt_flag = OptionalField!U1(reclen, s, 0);
        res_scal = OptionalField!I1(reclen, s, 0);
        llm_scal = OptionalField!I1(reclen, s, 0);
        hlm_scal = OptionalField!I1(reclen, s, 0);
        lo_limit = OptionalField!R4(reclen, s, 0.0f);
        hi_limit = OptionalField!R4(reclen, s, 0.0f);
        start_in = OptionalField!R4(reclen, s, 0.0f);
        incr_in  = OptionalField!R4(reclen, s, 0.0f);
        rtn_indx = OptionalArray!U2(reclen, rtn_icnt.getValue(), s);
        units    = OptionalField!CN(reclen, s, "");
        units_in = OptionalField!CN(reclen, s, "");
        c_resfmt = OptionalField!CN(reclen, s, "");
        c_llmfmt = OptionalField!CN(reclen, s, "");
        c_hlmfmt = OptionalField!CN(reclen, s, "");
        lo_spec  = OptionalField!R4(reclen, s, 0.0f);
        hi_spec  = OptionalField!R4(reclen, s, 0.0f);
    }
 
    this(uint test_num,
         ubyte head_num,
         ubyte site_num,
         ubyte test_flg,
         ubyte parm_flg,
         OptionalField!U2 rtn_icnt,
         OptionalField!U2 rslt_cnt,
         OptionalArray!N1 rtn_stat,
         OptionalArray!R4 rtn_rslt,
         OptionalField!CN test_txt,
         OptionalField!CN alarm_id,
         OptionalField!U1 opt_flag,
         OptionalField!I1 res_scal,
         OptionalField!I1 llm_scal,
         OptionalField!I1 hlm_scal,
         OptionalField!R4 lo_limit,
         OptionalField!R4 hi_limit,
         OptionalField!R4 start_in,
         OptionalField!R4 incr_in,
         OptionalArray!U2 rtn_indx,
         OptionalField!CN units,
         OptionalField!CN units_in,
         OptionalField!CN c_resfmt,
         OptionalField!CN c_llmfmt,
         OptionalField!CN c_hlmfmt,
         OptionalField!R4 lo_spec,
         OptionalField!R4 hi_spec)
    {
        super(Record_t.MPR, test_num, head_num, site_num, test_flg, parm_flg);
        this.rtn_icnt = rtn_icnt;
        this.rslt_cnt = rslt_cnt;
        this.rtn_stat = rtn_stat;
        this.rtn_rslt = rtn_rslt;
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
        this.rtn_indx = rtn_indx;
        this.units = units;
        this.units_in = units_in;
        this.c_resfmt = c_resfmt;
        this.c_llmfmt = c_llmfmt;
        this.c_hlmfmt = c_hlmfmt;
        this.lo_spec = lo_spec;
        this.hi_spec = hi_spec;
    }

    override protected size_t getReclen()
    {
        size_t l = 12;
        l += rtn_stat.size();
        l += rtn_rslt.size();
        l += test_txt.size();
        l += alarm_id.size();
        l += opt_flag.size();
        l += res_scal.size();
        l += llm_scal.size();
        l += hlm_scal.size();
        l += lo_limit.size();
        l += hi_limit.size();
        l += start_in.size();
        l += incr_in.size();
        l += rtn_indx.size();
        l += units.size();
        l += units_in.size();
        l += c_resfmt.size();
        l += c_llmfmt.size();
        l += c_hlmfmt.size();
        l += lo_spec.size();
        l += hi_spec.size();
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU4Bytes(test_num);
        bs ~= getU1Bytes(head_num);
        bs ~= getU1Bytes(site_num);
        bs ~= getU1Bytes(test_flg);
        bs ~= getU1Bytes(parm_flg);
        bs ~= getU2Bytes(rtn_icnt);
        bs ~= getU2Bytes(rslt_cnt);
        foreach(d; rtn_stat) bs ~= getU1Bytes(d);
        foreach(d; rtn_rslt) bs ~= getR4Bytes(d);
        bs ~= getCNBytes(test_txt);
        bs ~= getCNBytes(alarm_id);
        if (opt_flag.valid) bs ~= opt_flag;
        if (res_scal.valid) bs ~= getI1Bytes(res_scal);
        if (llm_scal.valid) bs ~= getI1Bytes(llm_scal);
        if (hlm_scal.valid) bs ~= getI1Bytes(hlm_scal);
        if (lo_limit.valid) bs ~= getR4Bytes(lo_limit);
        if (hi_limit.valid) bs ~= getR4Bytes(hi_limit);
        if (start_in.valid) bs ~= getR4Bytes(start_in);
        if (incr_in.valid)  bs ~= getR4Bytes(incr_in);
        foreach(d; rtn_indx) bs ~= getU2Bytes(d);
        if (units !is null) bs ~= getCNBytes(units);
        if (units_in !is null) bs ~= getCNBytes(units_in);
        if (c_resfmt !is null) bs ~= getCNBytes(c_resfmt);
        if (c_llmfmt !is null) bs ~= getCNBytes(c_llmfmt);
        if (c_hlmfmt !is null) bs ~= getCNBytes(c_hlmfmt);
        if (lo_spec.valid) bs ~= getR4Bytes(lo_spec);
        if (hi_spec.valid) bs ~= getR4Bytes(hi_spec);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("MultipleResultParametricRecord:\n");
        app.put(getString());
        app.put("\n    rtn_icnt = "); app.put(to!string(rtn_icnt));
        app.put("\n    rslt_cnt = "); app.put(to!string(rslt_cnt));
        app.put("\n    rtn_stat = "); app.put(to!string(rtn_stat));
        app.put("\n    rtn_rslt = "); app.put(to!string(rtn_rslt));
        app.put("\n    test_txt = "); app.put(test_txt.toString());
        app.put("\n    alarm_id = "); app.put(alarm_id.toString());

        if (!opt_flag.empty) { app.put("\n    opt_flag = "); app.put(to!string(opt_flag)); }
        if (!res_scal.empty) { app.put("\n    res_scal = "); app.put(to!string(res_scal)); }
        if (!llm_scal.empty) { app.put("\n    llm_scal = "); app.put(to!string(llm_scal)); }
        if (!hlm_scal.empty) { app.put("\n    hlm_scal = "); app.put(to!string(hlm_scal)); }
        if (!lo_limit.empty) { app.put("\n    lo_limit = "); app.put(to!string(lo_limit)); }
        if (!hi_limit.empty) { app.put("\n    hi_limit = "); app.put(to!string(hi_limit)); }
        if (!start_in.empty) { app.put("\n    start_in = "); app.put(to!string(start_in)); }
        if (!incr_in.empty) { app.put("\n    incr_in = "); app.put(to!string(incr_in)); }
        if (!rtn_indx.empty) { app.put("\n    rtn_indx = "); app.put(to!string(rtn_indx)); }
        if (!units.empty) { app.put("\n    units = "); app.put(units.toString()); }
        if (!units_in.empty) { app.put("\n    units_in = "); app.put(units_in.toString()); }
        if (!c_resfmt.empty) { app.put("\n    c_resfmt = "); app.put(c_resfmt.toString()); }
        if (!c_llmfmt.empty) { app.put("\n    c_llmfmt = "); app.put(c_llmfmt.toString()); }
        if (!c_hlmfmt.empty) { app.put("\n    c_hlmfmt = "); app.put(c_hlmfmt.toString()); }
        if (!lo_spec.empty) { app.put("\n    lo_spec = "); app.put(to!string(lo_spec.toString())); }
        if (!hi_spec.empty) { app.put("\n    hi_spec = "); app.put(to!string(hi_spec.toString())); }
        app.put("\n");
        return app.data;
    }
}

//        finish_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
class MasterResultsRecord : StdfRecord
{
    U4 finish_t;
    OptionalField!C1 disp_cod;
    OptionalField!CN usr_desc;
    OptionalField!CN exc_desc;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.MRR);
        finish_t = U4(s);
        reclen -= 4;
        disp_cod = OptionalField!C1(reclen, s, ' ');
        usr_desc = OptionalField!CN(reclen, s, "");
        exc_desc = OptionalField!CN(reclen, s, "");
    }

    this(ushort finish_t, 
         OptionalField!C1 disp_cod, 
         OptionalField!CN usr_desc, 
         OptionalField!CN exc_desc)
    {
        super(Record_t.MRR);
        this.finish_t = U4!(finish_t);
        this.disp_cod = disp_cod;
        this.usr_desc = usr_desc;
        this.exc_desc = exc_desc;
    }

    override protected size_t getReclen()
    {
        ushort l = 5;
        l += usr_desc.size;
        l += exc_desc.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        auto d = finish_t - DateTime(1970, 1, 1, 0, 0, 0); 
        auto dt = cast(uint) d.total!"seconds";
        bs ~= getU4Bytes(dt);
        bs ~= cast(ubyte) disp_cod;
        bs ~= getCNBytes(usr_desc);
        bs ~= getCNBytes(exc_desc);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("MasterResultsRecord:");
        app.put("\n    finish_t = "); app.put(to!string(finish_t));
        app.put("\n    disp_cod = "); app.put(to!string(disp_cod));
        app.put("\n    usr_desc = "); app.put(usr_desc.toString());
        app.put("\n    exc_desc = "); app.put(exc_desc.toString());
        app.put("\n");
        return app.data;
    }
}

class PartCountRecord : StdfRecord
{
    U1 head_num;
    U1 site_num;
    U4 part_cnt;
    OptionalField!U4 rtst_cnt;
    OptionalField!U4 abrt_cnt;
    OptionalField!U4 good_cnt;
    OptionalField!U4 func_cnt;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.PCR);
        head_num = U1(s);
        site_num = U1(s);
        part_cnt = U4(s);
        reclen -= 6;
        rtst_cnt = OptionalField!U4(reclen, s, 4294967295);
        abrt_cnt = OptionalField!U4(reclen, s, 4294967295);
        good_cnt = OptionalField!U4(reclen, s, 4294967295);
        func_cnt = OptionalField!U4(reclen, s, 4294967295);
    }

    this(ubyte head_num,
         ubyte site_num,
         uint part_cnt,
         OptionalField!U4 rtst_cnt,
         OptionalField!U4 abrt_cnt,
         OptionalField!U4 good_cnt,
         OptionalField!U4 func_cnt)
    {
        super(Record_t.PCR);
        this.head_num = U1!(head_num);
        this.site_num = U1!(site_num);
        this.part_cnt =U4!( part_cnt);
        this.rtst_cnt = rtst_cnt;
        this.abrt_cnt = abrt_cnt;
        this.good_cnt = good_cnt;
        this.func_cnt = func_cnt;
    }

    override protected size_t getReclen()
    {
        return 22;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        bs ~= getU4Bytes(part_cnt);
        bs ~= getU4Bytes(rtst_cnt);
        bs ~= getU4Bytes(abrt_cnt);
        bs ~= getU4Bytes(good_cnt);
        bs ~= getU4Bytes(func_cnt);
        return bs;
    }
    */

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
    U2 grp_indx;
    CN grp_nam;
    U2 indx_cnt;
    OptionalArray!U2 pmr_indx;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.PGR);
        grp_indx = U2(s);
        reclen -= 2;
        grp_nam = CN(s);
        reclen -= grp_nam.size;
        indx_cnt = U2(s);
        reclen -= 2;
        pmr_indx = OptionalArray!U2(reclen, indx_cnt.getValue(), s);
    }

    this(ushort grp_indx,
         string grp_nam,
         ushort indx_cnt,
         OptionalArray!U2 pmr_indx)
    {
         super(Record_t.PGR);
         this.grp_indx = U2(grp_indx);
         this.grp_nam = CN(grp_nam);
         this.indx_cnt = U2(indx_cnt);
         this.pmr_indx = pmr_indx;
    }

    override protected size_t getReclen()
    {
        ushort l = 4;
        l += grp_nam.size;
        l += (2 * indx_cnt.getValue());
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU2Bytes(grp_indx);
        bs ~= getCNBytes(grp_nam);
        bs ~= getU2Bytes(indx_cnt);
        foreach(d; pmr_indx) bs ~= getU2Bytes(d);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("PinGroupRecord:");
        app.put("\n    grp_indx = "); app.put(to!string(grp_indx));
        app.put("\n    grp_nam = ");  app.put(grp_nam.toString());
        app.put("\n    indx_cnt = "); app.put(to!string(indx_cnt));
        app.put("\n    pmr_indx = "); app.put(to!string(pmr_indx));
        app.put("\n");
        return app.data;
    }
}

class PartInformationRecord : StdfRecord
{
    U1 head_num;
    U1 site_num;

    this(ByteReader s)
    {
        super(Record_t.PIR);
        head_num = U1(s);
        site_num = U1(s);
    }

    this(ubyte head_num, ubyte site_num)
    {
        super(Record_t.PIR);
        this.head_num = U1(head_num);
        this.site_num = U1(site_num);
    }

    override protected size_t getReclen()
    {
        return 2;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        return bs;
    }
    */

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
    U2 grp_cnt;
    U2[] grp_indx;
    OptionalArray!U2 grp_mode;
    OptionalArray!U1 grp_radx;
    OptionalArray!CN pgm_char;
    OptionalArray!CN rtn_char;
    OptionalArray!CN pgm_chal;
    OptionalArray!CN rtn_chal;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.PLR);
        grp_cnt = U2(s);
        reclen -= 2;
        grp_indx = new U2[grp_cnt.getValue()];
        for (int i=0; i<grp_cnt.getValue(); i++) grp_indx[i] = U2(s);
        reclen -= 2 * grp_cnt.getValue(); 
        grp_mode = OptionalArray!U2(reclen, grp_cnt.getValue(), s);
        grp_radx = OptionalArray!U1(reclen, grp_cnt.getValue(), s);
        pgm_char = OptionalArray!CN(reclen, grp_cnt.getValue(), s);
        rtn_char = OptionalArray!CN(reclen, grp_cnt.getValue(), s);
        pgm_chal = OptionalArray!CN(reclen, grp_cnt.getValue(), s);
        rtn_chal = OptionalArray!CN(reclen, grp_cnt.getValue(), s);
    }

    this(ushort grp_cnt,
         ushort[] grp_indx,
         OptionalArray!U2 grp_mode,
         OptionalArray!U1 grp_radx,
         OptionalArray!CN pgm_char,
         OptionalArray!CN rtn_char,
         OptionalArray!CN pgm_chal,
         OptionalArray!CN rtn_chal)
    {
        super(Record_t.PLR);
        this.grp_cnt = U2(grp_cnt);
        this.grp_indx = new U2[grp_cnt];
        foreach(i, d; grp_indx) this.grp_indx[i] = U2(d);
        this.grp_mode = grp_mode;
        this.grp_radx = grp_radx;
        this.pgm_char = pgm_char;
        this.rtn_char = rtn_char;
        this.pgm_chal = pgm_chal;
        this.rtn_chal = rtn_chal;
    }

    override protected size_t getReclen()
    {
        size_t l = 2;
        l += (5 * grp_cnt.getValue());
        for (int i=0; i<grp_cnt.getValue(); i++)
        {
            l += pgm_char[i].size;
            l += rtn_char[i].size;
            l += pgm_chal[i].size;
            l += rtn_chal[i].size;
        }
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU2Bytes(grp_cnt);
        foreach(d; grp_indx) bs ~= getU2Bytes(d);
        foreach(d; grp_mode) bs ~= getU2Bytes(d);
        foreach(d; grp_radx) bs ~= d;
        foreach(s; pgm_char) bs ~= getCNBytes(s);
        foreach(s; rtn_char) bs ~= getCNBytes(s);
        foreach(s; pgm_chal) bs ~= getCNBytes(s);
        foreach(s; rtn_chal) bs ~= getCNBytes(s);
        return bs;
    }
    */

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
    U2 pmr_indx;
    OptionalField!U2 chan_typ;
    OptionalField!CN chan_nam;
    OptionalField!CN phy_nam;
    OptionalField!CN log_nam;
    OptionalField!U1 head_num;
    OptionalField!U1 site_num;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.PMR);
        pmr_indx = U2(s);
        reclen -= 2;
        chan_typ = OptionalField!U2(reclen, s, 0);
        chan_nam = OptionalField!CN(reclen, s, "");
        phy_nam = OptionalField!CN(reclen, s, "");
        log_nam = OptionalField!CN(reclen, s, "");
        head_num = OptionalField!U1(reclen, s, 1);
        site_num = OptionalField!U1(reclen, s, 1);
    }

    this(ushort pmr_indx,
         OptionalField!U2 chan_typ,
         OptionalField!CN chan_nam,
         OptionalField!CN phy_nam,
         OptionalField!CN log_nam,
         OptionalField!U1 head_num,
         OptionalField!U1 site_num)
    {
        super(Record_t.PMR);
        this.pmr_indx = U2(pmr_indx);
        this.chan_typ = chan_typ;
        this.chan_nam = chan_nam;
        this.phy_nam = phy_nam;
        this.log_nam = log_nam;
        this.head_num = head_num;
        this.site_num = site_num;
    }

    override protected size_t getReclen()
    {
        ushort l = 6;
        l += chan_nam.size;
        l += phy_nam.size;
        l += log_nam.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU2Bytes(pmr_indx);
        bs ~= getU2Bytes(chan_typ);
        bs ~= getCNBytes(chan_nam);
        bs ~= getCNBytes(phy_nam);
        bs ~= getCNBytes(log_nam);
        bs ~= head_num;
        bs ~= site_num;
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("PinMapRecord:");
        app.put("\n    pmr_indx = "); app.put(to!string(pmr_indx));
        app.put("\n    chan_typ = "); app.put(to!string(chan_typ));
        app.put("\n    chan_nam = "); app.put(chan_nam.toString());
        app.put("\n    phy_nam = "); app.put(phy_nam.toString());
        app.put("\n    log_nam = "); app.put(log_nam.toString());
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n");
        return app.data;
    }
}

class PartResultsRecord : StdfRecord
{
    U1 head_num;
    U1 site_num;
    U1 part_flg;
    U2 num_test;
    U2 hard_bin;
    U2 soft_bin;
    I2 x_coord;
    I2 y_coord;
    I4 test_t;
    CN part_id;
    CN part_txt;
    BN part_fix;

    this(ByteReader s)
    {
        super(Record_t.PRR);
        head_num = U1(s);
        site_num = U1(s);
        part_flg = U1(s);
        num_test = U2(s);
        hard_bin = U2(s);
        soft_bin = U2(s);
        x_coord = I2(s);
        y_coord = I2(s);
        test_t = I4(s);
        part_id = CN(s);
        part_txt = CN(s);
        part_fix = BN(s);
    }

    this(ubyte head_num,
         ubyte site_num,
         ubyte part_flg,
         ushort num_test,
         ushort hard_bin,
         ushort soft_bin,
         short x_coord,
         short y_coord,
         int test_t,
         string part_id,
         string part_txt,
         ubyte[] part_fix)
    {
        super(Record_t.PRR);
        this.head_num = U1(head_num);
        this.site_num = U1(site_num);
        this.part_flg = U1(part_flg);
        this.num_test = U2(num_test);
        this.hard_bin = U2(hard_bin);
        this.soft_bin = U2(soft_bin);
        this.x_coord = I2(x_coord);
        this.y_coord = I2(y_coord);
        this.test_t = I4(test_t);
        this.part_id = CN(part_id);
        this.part_txt = CN(part_txt);
        this.part_fix = BN(part_fix);
    }

    override protected size_t getReclen()
    {
        ushort l = 17;
        l += part_id.size;
        l += part_txt.size;
        l += part_fix.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        bs ~= part_flg;
        bs ~= getU2Bytes(num_test);
        bs ~= getU2Bytes(hard_bin);
        bs ~= getU2Bytes(soft_bin);
        bs ~= getI2Bytes(x_coord);
        bs ~= getI2Bytes(y_coord);
        bs ~= getU4Bytes(test_t);
        bs ~= getCNBytes(part_id);
        bs ~= getCNBytes(part_txt);
        bs ~= getBNBytes(part_fix);
        return bs;
    }
    */

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
        app.put("\n    part_id = "); app.put(part_id.toString());
        app.put("\n    part_txt = "); app.put(part_txt.toString());
        app.put("\n    part_fix = "); app.put(to!string(part_fix));
        app.put("\n");
        return app.data;
    }
}

class ParametricTestRecord : ParametricRecord
{
    R4 result;
    CN test_txt;
    CN alarm_id;
    OptionalField!U1 opt_flag;
    OptionalField!I1 res_scal;
    OptionalField!I1 llm_scal;
    OptionalField!I1 hlm_scal;
    OptionalField!R4 lo_limit;
    OptionalField!R4 hi_limit;
    OptionalField!CN units;
    OptionalField!CN c_resfmt;
    OptionalField!CN c_llmfmt;
    OptionalField!CN c_hlmfmt;
    OptionalField!R4 lo_spec;
    OptionalField!R4 hi_spec;

    this(ref size_t reclen, ByteReader s)
    {
        super(Record_t.PTR, s);
        result = R4(s);
        reclen -= 12;
        test_txt = CN(s);
        alarm_id = CN(s);
        reclen -= test_txt.size;
        reclen -= alarm_id.size;
        opt_flag = OptionalField!U1(reclen, s, 0xFF);
        res_scal = OptionalField!I1(reclen, s, 0);
        llm_scal = OptionalField!I1(reclen, s, 0);
        hlm_scal = OptionalField!I1(reclen, s, 0);
        lo_limit = OptionalField!R4(reclen, s, 0.0f);
        hi_limit = OptionalField!R4(reclen, s, 0.0f);
        units = OptionalField!CN(reclen, s, "");
        c_resfmt = OptionalField!CN(reclen, s, "");
        c_llmfmt = OptionalField!CN(reclen, s, "");
        c_hlmfmt = OptionalField!CN(reclen, s, "");
        lo_spec = OptionalField!R4(reclen, s, 0.0f);
        hi_spec = OptionalField!R4(reclen, s, 0.0f);
    }

    this(uint test_num,
         ubyte head_num,
         ubyte site_num,
         ubyte test_flg,
         ubyte parm_flg,
         float result,
         string test_txt,
         string alarm_id,
         OptionalField!U1 opt_flag,
         OptionalField!I1 res_scal,
         OptionalField!I1 llm_scal,
         OptionalField!I1 hlm_scal,
         OptionalField!R4 lo_limit,
         OptionalField!R4 hi_limit,
         OptionalField!CN units,
         OptionalField!CN c_resfmt,
         OptionalField!CN c_llmfmt,
         OptionalField!CN c_hlmfmt,
         OptionalField!R4 lo_spec,
         OptionalField!R4 hi_spec)
     {
        super(Record_t.PTR, test_num, head_num, site_num, test_flg, parm_flg);
        this.result = R4(result);
        this.test_txt = CN(test_txt);
        this.alarm_id = CN(alarm_id);
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
    }

    override protected size_t getReclen()
    {
        size_t l = 12;
        l += test_txt.size;
        l += alarm_id.size;
        l += opt_flag.size;
        l += res_scal.size;
        l += llm_scal.size;
        l += hlm_scal.size;
        l += lo_limit.size;
        l += hi_limit.size;
        l += units.size;
        l += c_resfmt.size;
        l += c_llmfmt.size;
        l += c_hlmfmt.size;
        l += lo_spec.size;
        l += hi_spec.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU4Bytes(test_num);
        bs ~= getU1Bytes(head_num);
        bs ~= getU1Bytes(site_num);
        bs ~= getU1Bytes(test_flg);
        bs ~= getU1Bytes(parm_flg);
        bs ~= getR4Bytes(result);
        bs ~= getCNBytes(test_txt);
        bs ~= getCNBytes(alarm_id);
        if (opt_flag.valid) bs ~= getU1Bytes(opt_flag);
        if (res_scal.valid) bs ~= getI1Bytes(res_scal);
        if (llm_scal.valid) bs ~= getI1Bytes(llm_scal);
        if (hlm_scal.valid) bs ~= getI1Bytes(hlm_scal);
        if (lo_limit.valid) bs ~= getR4Bytes(lo_limit);
        if (hi_limit.valid) bs ~= getR4Bytes(hi_limit);
        if (units !is null) bs ~= getCNBytes(units);
        if (c_resfmt !is null) bs ~= getCNBytes(c_resfmt);
        if (c_llmfmt !is null) bs ~= getCNBytes(c_llmfmt);
        if (c_hlmfmt !is null) bs ~= getCNBytes(c_hlmfmt);
        if (lo_spec.valid) bs ~= getR4Bytes(lo_spec);
        if (hi_spec.valid) bs ~= getR4Bytes(hi_spec);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("ParametricTestRecord:\n");
        app.put(getString());
        app.put("\n    result = "); app.put(to!string(result));
        app.put("\n    test_txt = "); app.put(test_txt.toString());
        app.put("\n    alarm_id = "); app.put(alarm_id.toString());
        if (!opt_flag.empty) { app.put("\n    opt_flag = "); app.put((opt_flag.toString())); }
        if (!res_scal.empty) { app.put("\n    res_scal = "); app.put(to!string(res_scal)); }
        if (!llm_scal.empty) { app.put("\n    llm_scal = "); app.put(to!string(llm_scal)); }
        if (!hlm_scal.empty) { app.put("\n    hlm_scal = "); app.put(to!string(hlm_scal)); }
        if (!lo_limit.empty) { app.put("\n    lo_limit = "); app.put(to!string(lo_limit)); }
        if (!hi_limit.empty) { app.put("\n    hi_limit = "); app.put(to!string(hi_limit)); }
        if (!units.empty) { app.put("\n    units = "); app.put(units.toString()); }
        if (!c_resfmt.empty) { app.put("\n    c_resfmt = "); app.put(c_resfmt.toString()); }
        if (!c_llmfmt.empty) { app.put("\n    c_llmfmt = "); app.put(c_llmfmt.toString()); }
        if (!c_hlmfmt.empty) { app.put("\n    c_hlmfmt = "); app.put(c_hlmfmt.toString()); }
        if (!lo_spec.empty) { app.put("\n    lo_spec = "); app.put(to!string(lo_spec)); }
        if (!hi_spec.empty) { app.put("\n    hi_spec = "); app.put(to!string(hi_spec)); }
        app.put("\n");
        return app.data;
    }
}

class RetestDataRecord : StdfRecord
{
    U2 num_bins;
    OptionalArray!U2 rtst_bin;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.RDR);
        num_bins = U2(s);
        reclen -= 2;
        rtst_bin = OptionalArray!U2(reclen, num_bins.getValue(), s);
    }

    this(ushort num_bins, OptionalArray!U2 rtst_bin)
    {
        super(Record_t.RDR);
        this.num_bins = U2(num_bins);
        this.rtst_bin = rtst_bin;
    }

    override protected size_t getReclen()
    {
        ushort l = 2;
        l += rtst_bin.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU2Bytes(num_bins);
        foreach(d; rtst_bin) bs ~= getU2Bytes(d);
        return bs;
    }
    */

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
    U1 head_num;
    U1 site_num;
    U2 sbin_num;
    U4 sbin_cnt;
    OptionalField!C1 sbin_pf;
    OptionalField!CN sbin_nam;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.SBR);
        head_num = U1(s);
        site_num = U1(s);
        sbin_num = U2(s);
        sbin_cnt = U4(s);
        reclen -= 8;
        sbin_pf = OptionalField!C1(reclen, s, ' ');
        sbin_nam = OptionalField!CN(reclen, s, "");
    }

    this(ubyte head_num,
         ubyte site_num,
         ushort sbin_num,
         uint sbin_cnt,
         OptionalField!C1 sbin_pf,
         OptionalField!CN sbin_nam)
    {
        super(Record_t.SBR);
        this.head_num = U1(head_num);
        this.site_num = U1(site_num);
        this.sbin_num = U2(sbin_num);
        this.sbin_cnt = U4(sbin_cnt);
        this.sbin_pf  = sbin_pf;
        this.sbin_nam = sbin_nam;
    }
         

    override protected size_t getReclen()
    {
        ushort l = 9;
        l += sbin_nam.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getU1Bytes(head_num);
        bs ~= getU1Bytes(site_num);
        bs ~= getU2Bytes(sbin_num);
        bs ~= getU4Bytes(sbin_cnt);
        bs ~= cast(ubyte) sbin_pf;
        bs ~= getCNBytes(sbin_nam);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("SoftwareBinRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    sbin_num = "); app.put(to!string(sbin_num));
        app.put("\n    sbin_cnt = "); app.put(to!string(sbin_cnt));
        app.put("\n    sbin_pf = "); app.put(to!string(sbin_pf));
        app.put("\n    sbin_nam = "); app.put(sbin_nam.toString());
        app.put("\n");
        return app.data;
    }
}

class SiteDescriptionRecord : StdfRecord
{
    U1 head_num;
    U1 site_grp;
    U1 site_cnt;
    U1[] site_num;
    OptionalField!CN hand_typ;
    OptionalField!CN hand_id;
    OptionalField!CN card_typ;
    OptionalField!CN card_id;
    OptionalField!CN load_typ;
    OptionalField!CN load_id;
    OptionalField!CN dib_typ;
    OptionalField!CN dib_id;
    OptionalField!CN cabl_typ;
    OptionalField!CN cabl_id;
    OptionalField!CN cont_typ;
    OptionalField!CN cont_id;
    OptionalField!CN lasr_typ;
    OptionalField!CN lasr_id;
    OptionalField!CN extr_typ;
    OptionalField!CN extr_id;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.SDR);
        head_num = U1(s);
        site_grp = U1(s);
        site_cnt = U1(s);
        reclen -= 3;
        site_num = new U1[site_cnt.getValue()];
        for (int i=0; i<site_cnt.getValue(); i++) site_num[i] = U1(s);
        reclen -= site_cnt.getValue();
        hand_typ = OptionalField!CN(reclen, s, "");
        hand_id = OptionalField!CN(reclen, s, "");
        card_typ = OptionalField!CN(reclen, s, "");
        card_id = OptionalField!CN(reclen, s, "");
        load_typ = OptionalField!CN(reclen, s, "");
        load_id = OptionalField!CN(reclen, s, "");
        dib_typ = OptionalField!CN(reclen, s, "");
        dib_id = OptionalField!CN(reclen, s, "");
        cabl_typ = OptionalField!CN(reclen, s, "");
        cabl_id = OptionalField!CN(reclen, s, "");
        cont_typ = OptionalField!CN(reclen, s, "");
        cont_id = OptionalField!CN(reclen, s, "");
        lasr_typ = OptionalField!CN(reclen, s, "");
        lasr_id = OptionalField!CN(reclen, s, "");
        extr_typ = OptionalField!CN(reclen, s, "");
        extr_id = OptionalField!CN(reclen, s, "");
    }

    this(ubyte head_num,
         ubyte site_grp,
         ubyte site_cnt,
         ubyte[] site_num,
         OptionalField!CN hand_typ,
         OptionalField!CN hand_id,
         OptionalField!CN card_typ,
         OptionalField!CN card_id,
         OptionalField!CN load_typ,
         OptionalField!CN load_id,
         OptionalField!CN dib_typ,
         OptionalField!CN dib_id,
         OptionalField!CN cabl_typ,
         OptionalField!CN cabl_id,
         OptionalField!CN cont_typ,
         OptionalField!CN cont_id,
         OptionalField!CN lasr_typ,
         OptionalField!CN lasr_id,
         OptionalField!CN extr_typ,
         OptionalField!CN extr_id)
    {
        super(Record_t.SDR);
        this.head_num = U1(head_num);
        this.site_grp = U1(site_grp);
        this.site_cnt = U1(site_cnt);
        this.site_num = new U1[site_cnt];
        foreach(i, d; site_num) this.site_num[i] = U1(d);
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
   }
         

    override protected size_t getReclen()
    {
        ushort l = 3;
        l += site_cnt.getValue();
        l += hand_typ.size;
        l += hand_id.size;
        l += card_typ.size;
        l += card_id.size;
        l += load_typ.size;
        l += load_id.size;
        l += dib_typ.size;
        l += dib_id.size;
        l += cabl_typ.size;
        l += cabl_id.size;
        l += cont_typ.size;
        l += cont_id.size;
        l += lasr_typ.size;
        l += lasr_id.size;
        l += extr_typ.size;
        l += extr_id.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_grp;
        bs ~= site_cnt;
        bs ~= site_num;
        bs ~= getCNBytes(hand_typ);
        bs ~= getCNBytes(hand_id);
        bs ~= getCNBytes(card_typ);
        bs ~= getCNBytes(card_id);
        bs ~= getCNBytes(load_typ);
        bs ~= getCNBytes(load_id);
        bs ~= getCNBytes(dib_typ);
        bs ~= getCNBytes(dib_id);
        bs ~= getCNBytes(cabl_typ);
        bs ~= getCNBytes(cabl_id);
        bs ~= getCNBytes(cont_typ);
        bs ~= getCNBytes(cont_id);
        bs ~= getCNBytes(lasr_typ);
        bs ~= getCNBytes(lasr_id);
        bs ~= getCNBytes(extr_typ);
        bs ~= getCNBytes(extr_id);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("SiteDescriptionRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_grp = "); app.put(to!string(site_grp));
        app.put("\n    site_cnt = "); app.put(to!string(site_cnt));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    hand_typ = "); app.put(hand_typ.toString());
        app.put("\n    hand_id = "); app.put(hand_id.toString());
        app.put("\n    card_typ = "); app.put(card_typ.toString());
        app.put("\n    card_id = "); app.put(card_id.toString());
        app.put("\n    load_typ = "); app.put(load_typ.toString());
        app.put("\n    load_id = "); app.put(load_id.toString());
        app.put("\n    dib_typ = "); app.put(dib_typ.toString());
        app.put("\n    dib_id = "); app.put(dib_id.toString());
        app.put("\n    cabl_typ = "); app.put(cabl_typ.toString());
        app.put("\n    cabl_id = "); app.put(cabl_id.toString());
        app.put("\n    cont_typ = "); app.put(cont_typ.toString());
        app.put("\n    cont_id = "); app.put(cont_id.toString());
        app.put("\n    lasr_typ = "); app.put(lasr_typ.toString());
        app.put("\n    lasr_id = "); app.put(lasr_id.toString());
        app.put("\n    extr_typ = "); app.put(extr_typ.toString());
        app.put("\n    extr_id = "); app.put(extr_id.toString());
        app.put("\n");
        return app.data;
    }
}

class TestSynopsisRecord : StdfRecord
{
    U1 head_num;
    U1 site_num;
    C1 test_typ;
    U4 test_num;
    OptionalField!U4 exec_cnt;
    OptionalField!U4 fail_cnt;
    OptionalField!U4 alrm_cnt;
    OptionalField!CN test_nam;
    OptionalField!CN seq_name;
    OptionalField!CN test_lbl;
    OptionalField!U1 opt_flag;
    OptionalField!R4 test_tim;
    OptionalField!R4 test_min;
    OptionalField!R4 test_max;
    OptionalField!R4 tst_sums;
    OptionalField!R4 tst_sqrs;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.TSR);
        reclen -= 7;
        head_num = U1(s);
        site_num = U1(s);
        test_typ = C1(s);
        test_num = U4(s);
        exec_cnt = OptionalField!U4(reclen, s, 0);
        fail_cnt = OptionalField!U4(reclen, s, 0);
        alrm_cnt = OptionalField!U4(reclen, s, 0);
        test_nam = OptionalField!CN(reclen, s, "");
        seq_name = OptionalField!CN(reclen, s, "");
        test_lbl = OptionalField!CN(reclen, s, "");
        opt_flag = OptionalField!U1(reclen, s, 0);
        test_tim = OptionalField!R4(reclen, s, 0.0f);
        test_min = OptionalField!R4(reclen, s, 0.0f);
        test_max = OptionalField!R4(reclen, s, 0.0f);
        tst_sums = OptionalField!R4(reclen, s, 0.0f);
        tst_sqrs = OptionalField!R4(reclen, s, 0.0f);
    }

    this(ubyte head_num,
         ubyte site_num,
         char test_typ,
         uint test_num,
         OptionalField!U4 exec_cnt,
         OptionalField!U4 fail_cnt,
         OptionalField!U4 alrm_cnt,
         OptionalField!CN test_nam,
         OptionalField!CN seq_name,
         OptionalField!CN test_lbl,
         OptionalField!U1 opt_flag,
         OptionalField!R4 test_tim,
         OptionalField!R4 test_min,
         OptionalField!R4 test_max,
         OptionalField!R4 tst_sums,
         OptionalField!R4 tst_sqrs)
    {
        super(Record_t.TSR);
        this.head_num = U1(head_num);
        this.site_num = U1(site_num);
        this.test_typ = C1(test_typ);
        this.test_num = uint(test_num);
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
    }

    override protected size_t getReclen()
    {
        size_t l = 7;
        l += exec_cnt.size;
        l += fail_cnt.size;
        l += alrm_cnt.size;
        l += test_nam.size;
        l += seq_name.size;
        l += test_lbl.size;
        l += opt_flag.size;
        l += test_tim.size;
        l += test_min.size;
        l += test_max.size;
        l += tst_sums.size;
        l += tst_sqrs.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_num;
        bs ~= cast(ubyte) test_typ;
        bs ~= getU4Bytes(test_num);
        bs ~= getU4Bytes(exec_cnt);
        bs ~= getU4Bytes(fail_cnt);
        bs ~= getU4Bytes(alrm_cnt);
        bs ~= getCNBytes(test_nam);
        bs ~= getCNBytes(seq_name);
        bs ~= getCNBytes(test_lbl);
        if (opt_flag.valid) bs ~= opt_flag;
        if (test_tim.valid) bs ~= getR4Bytes(test_tim);
        if (test_min.valid) bs ~= getR4Bytes(test_min);
        if (test_max.valid) bs ~= getR4Bytes(test_max);
        if (tst_sums.valid) bs ~= getR4Bytes(tst_sums);
        if (tst_sqrs.valid) bs ~= getR4Bytes(tst_sqrs);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("TestSynopsisRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_num = "); app.put(to!string(site_num));
        app.put("\n    test_typ = "); app.put(to!string(test_typ));
        app.put("\n    test_num = "); app.put(to!string(test_num));
        if (!exec_cnt.empty) { app.put("\n    exec_cnt = "); app.put(to!string(exec_cnt)); }
        if (!fail_cnt.empty) { app.put("\n    fail_cnt = "); app.put(to!string(fail_cnt)); }
        if (!alrm_cnt.empty) { app.put("\n    alrm_cnt = "); app.put(to!string(alrm_cnt)); }
        if (!test_nam.empty) { app.put("\n    test_nam = "); app.put(test_nam.toString()); }
        if (!seq_name.empty) { app.put("\n    seq_name = "); app.put(seq_name.toString()); }
        if (!test_lbl.empty) { app.put("\n    test_lbl = "); app.put(test_lbl.toString()); }
        if (!opt_flag.empty) { app.put("\n    opt_flag = "); app.put(to!string(opt_flag)); }
        if (!test_tim.empty) { app.put("\n    test_tim = "); app.put(to!string(test_tim)); }
        if (!test_min.empty) { app.put("\n    test_min = "); app.put(to!string(test_min)); }
        if (!test_max.empty) { app.put("\n    test_max = "); app.put(to!string(test_max)); }
        if (!tst_sums.empty) { app.put("\n    tst_sums = "); app.put(to!string(tst_sums)); }
        if (!tst_sqrs.empty) { app.put("\n    tst_sqrs = "); app.put(to!string(tst_sqrs)); }
        app.put("\n");
        return app.data;
    }
}

class WaferConfigurationRecord : StdfRecord
{
    R4 wafr_siz;
    R4 die_ht;
    R4 die_wid;
    U1 wf_units;
    C1 wf_flat;
    I2 center_x;
    I2 center_y;
    C1 pos_x;
    C1 pos_y;

    this(ByteReader s)
    {
        super(Record_t.WCR);
        wafr_siz = R4(s);
        die_ht = R4(s);
        die_wid = R4(s);
        wf_units = U1(s);
        wf_flat = C1(s);
        center_x = I2(s);
        center_y = I2(s);
        pos_x = C1(s);
        pos_y = C1(s);
    }

    this(float wafr_siz,
         float die_ht,
         float die_wid,
         ubyte wf_units,
         char wf_flat,
         short center_x,
         short center_y,
         char pos_x,
         char pos_y)
    {
        super(Record_t.WCR);
        this.wafr_siz = R4(wafr_siz);
        this.die_ht = R4(die_ht);
        this.die_wid = R4(die_wid);
        this.wf_units = U1(wf_units);
        this.wf_flat = C1(wf_flat);
        this.center_x = I2(center_x);
        this.center_y = I2(center_y);
        this.pos_x = C1(pos_x);
        this.pos_y = C1(pos_y);
    }

    override protected size_t getReclen()
    {
        return 20;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= getR4Bytes(wafr_siz);
        bs ~= getR4Bytes(die_ht);
        bs ~= getR4Bytes(die_wid);
        bs ~= wf_units;
        bs ~= cast(ubyte) wf_flat;
        bs ~= getI2Bytes(center_x);
        bs ~= getI2Bytes(center_y);
        bs ~= cast(ubyte) pos_x;
        bs ~= cast(ubyte) pos_y;
        return bs;
    }
    */

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

//        start_t = DateTime(1970, 1, 1, 0, 0, 0) + dur!"seconds"(d);
class WaferInformationRecord : StdfRecord
{
    U1 head_num;
    U1 site_grp;
    U4 start_t;
    OptionalField!CN wafer_id;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.WIR);
        head_num = U1(s);
        site_grp = U1(s);
        start_t = U4(s);
        reclen -= 6;
        wafer_id = OptionalField!CN(reclen, s, "");
    }

    this(ubyte head_num,
         ubyte site_grp,
         uint start_t,
         OptionalField!CN wafer_id)
    {
        super(Record_t.WIR);
        this.head_num = U1(head_num);
        this.site_grp = U1(site_grp);
        this.start_t = U4(start_t);
        this.wafer_id = wafer_id;
    }

    override protected size_t getReclen()
    {
        ushort l = 6;
        l += wafer_id.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_grp;
        auto d = start_t - DateTime(1970, 1, 1, 0, 0, 0); 
        auto dt = cast(uint) d.total!"seconds";
        bs ~= getU4Bytes(dt);
        bs ~= getCNBytes(wafer_id);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("WaferInformationRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_grp = "); app.put(to!string(site_grp));
        app.put("\n    start_t = "); app.put(to!string(start_t));
        app.put("\n    wafer_id = "); app.put(to!string(wafer_id));
        app.put("\n");
        return app.data;
    }
}

class WaferResultsRecord : StdfRecord
{
    U1 head_num;
    U1 site_grp;
    U4 finish_t;
    U4 part_cnt;
    OptionalField!U4 rtst_cnt;
    OptionalField!U4 abrt_cnt;
    OptionalField!U4 good_cnt;
    OptionalField!U4 func_cnt;
    OptionalField!CN wafer_id;
    OptionalField!CN fabwf_id;
    OptionalField!CN frame_id;
    OptionalField!CN mask_id;
    OptionalField!CN usr_desc;
    OptionalField!CN exc_desc;

    this(size_t reclen, ByteReader s)
    {
        super(Record_t.WRR);
        head_num = U1(s);
        site_grp = U1(s);
        finish_t = U4(s);
        part_cnt = U4(s);
        reclen -= 10;
        rtst_cnt = OptionalField!U4(reclen, s, 4294967295);
        abrt_cnt = OptionalField!U4(reclen, s, 4294967295);
        good_cnt = OptionalField!U4(reclen, s, 4294967295);
        func_cnt = OptionalField!U4(reclen, s, 4294967295);
        wafer_id = OptionalField!CN(reclen, s, "");
        fabwf_id = OptionalField!CN(reclen, s, "");
        frame_id = OptionalField!CN(reclen, s, "");
        mask_id = OptionalField!CN(reclen, s, "");
        usr_desc = OptionalField!CN(reclen, s, "");
        exc_desc = OptionalField!CN(reclen, s, "");
    }

    this(ubyte head_num,
         ubyte site_grp,
         uint finish_t,
         uint part_cnt,
         OptionalField!U4 rtst_cnt,
         OptionalField!U4 abrt_cnt,
         OptionalField!U4 good_cnt,
         OptionalField!U4 func_cnt,
         OptionalField!CN wafer_id,
         OptionalField!CN fabwf_id,
         OptionalField!CN frame_id,
         OptionalField!CN mask_id,
         OptionalField!CN usr_desc,
         OptionalField!CN exc_desc)
    {
        super(Record_t.WRR);
        this.head_num = U1(head_num);
        this.site_grp = U1(site_grp);
        this.finish_t = U4(finish_t);
        this.part_cnt = U4(part_cnt);
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
    }

    override protected size_t getReclen()
    {
        size_t l = 26;
        l += wafer_id.size;
        l += fabwf_id.size;
        l += frame_id.size;
        l += mask_id.size;
        l += usr_desc.size;
        l += exc_desc.size;
        return l;
    }

    /*
    override ubyte[] getBytes()
    {
        auto bs = getHeaderBytes();
        bs ~= head_num;
        bs ~= site_grp;
        auto d = finish_t - DateTime(1970, 1, 1, 0, 0, 0); 
        auto dt = cast(uint) d.total!"seconds";
        bs ~= getU4Bytes(dt);
        bs ~= getU4Bytes(part_cnt);
        bs ~= getU4Bytes(rtst_cnt);
        bs ~= getU4Bytes(abrt_cnt);
        bs ~= getU4Bytes(good_cnt);
        bs ~= getU4Bytes(func_cnt);
        bs ~= getCNBytes(wafer_id);
        bs ~= getCNBytes(fabwf_id);
        bs ~= getCNBytes(frame_id);
        bs ~= getCNBytes(mask_id);
        bs ~= getCNBytes(usr_desc);
        bs ~= getCNBytes(exc_desc);
        return bs;
    }
    */

    override string toString()
    {
        auto app = appender!string();
        app.put("WaferResultsRecord:");
        app.put("\n    head_num = "); app.put(to!string(head_num));
        app.put("\n    site_grp = "); app.put(to!string(site_grp));
        app.put("\n    finish_t = "); app.put(to!string(finish_t));
        app.put("\n    part_cnt = "); app.put(to!string(part_cnt));
        app.put("\n    rtst_cnt = "); app.put(to!string(rtst_cnt));
        app.put("\n    abrt_Cnt = "); app.put(to!string(abrt_cnt));
        app.put("\n    good_cnt = "); app.put(to!string(good_cnt));
        app.put("\n    func_cnt = "); app.put(to!string(func_cnt));
        app.put("\n    wafer_id = "); app.put(wafer_id.toString());
        app.put("\n    fabwf_id = "); app.put(fabwf_id.toString());
        app.put("\n    frame_id = "); app.put(frame_id.toString());
        app.put("\n    mask_id = "); app.put(mask_id.toString());
        app.put("\n    usr_desc = "); app.put(usr_desc.toString());
        app.put("\n    exc_desc = "); app.put(exc_desc.toString());
        app.put("\n");
        return app.data;
    }
}



