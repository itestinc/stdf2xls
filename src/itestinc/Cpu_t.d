module itestinc.Cpu_t;
import itestinc.Util;
import std.conv;
import std.range;
import std.bitmanip;
import itestinc.BinarySource;

enum Cpu_t : const(CPU)
{
    VAX = new const CPU(null, 0),
    SUN = new const CPU(VAX, 1),
    PC  = new const CPU(SUN, 2)
}

class CPU : EnumValue!(const CPU)
{
    const ubyte type;

    private const this(const(CPU) prev, uint type)
    {
        super(prev);
        this.type = cast(ubyte) type;
    }

    override string toString() const
    {
        return to!string(type);
    }

    static Cpu_t getCpuType(ubyte type)
    {
        if (type == cast(ubyte) 0) return Cpu_t.VAX;
        if (type == cast(ubyte) 1) return Cpu_t.SUN;
        if (type == cast(ubyte) 2) return Cpu_t.PC;
        return null;
    }

    ubyte getU1(ubyte _0) const
    {
        return _0;
    }

    ubyte getU1(ByteReader s) const
    {
        return s.nextByte();
    }

    ubyte[] getU1Bytes(ubyte b) const
    {
        ubyte[] bs = new ubyte[1];
        bs[0] |= b;
        return bs;
    }

    ushort getU2(ubyte _0, ubyte _1) const
    {
        if (this == Cpu_t.SUN) return cast(ushort) (_1 + (_0 << 8));
        return cast(ushort) (_0 + (_1 << 8));
    }

    ushort getU2(ByteReader s) const
    {
        ubyte b0 = s.nextByte();
        ubyte b1 = s.nextByte();
        return getU2(b0, b1);
    }

    ubyte[] getU2Bytes(ushort v) const
    {
        ubyte[] b = new ubyte[2];
        if (this == Cpu_t.SUN)
        {
            b[0] = cast(ubyte) ((v & 0xFF00) >> 8);
            b[1] = cast(ubyte) (v & 0xFF);
        }
        else
        {
            b[1] = cast(ubyte) ((v & 0xFF00) >> 8);
            b[0] = cast(ubyte) (v & 0xFF);
        }
        return b;
    }

    uint getU4(ubyte _0, ubyte _1, ubyte _2, ubyte _3) const
    {
        if (this == Cpu_t.SUN)
        {
            return _3 + (_2 << 8) + (_1 << 16) + (_0 << 24);
        }
        return _0 + (_1 << 8) + (_2 << 16) + (_3 << 24);
    }

    uint getU4(ByteReader s) const
    {
        ubyte b0 = s.nextByte();
        ubyte b1 = s.nextByte();
        ubyte b2 = s.nextByte();
        ubyte b3 = s.nextByte();
        return getU4(b0, b1, b2, b3);
    }

    ubyte[] getU4Bytes(uint v) const
    {
        ubyte[] b = new ubyte[4];
        if (this == Cpu_t.SUN)
        {
            b[0] = cast(ubyte) (v >> 24);
            b[1] = cast(ubyte) ((v & 0x00FF0000) >> 16);
            b[2] = cast(ubyte) ((v & 0x0000FF00) >> 8);
            b[3] = cast(ubyte) (v & 0x000000FF);
        }
        else
        {
            b[3] = cast(ubyte) (v >> 24);
            b[2] = cast(ubyte) ((v & 0x00FF0000) >> 16);
            b[1] = cast(ubyte) ((v & 0x0000FF00) >> 8);
            b[0] = cast(ubyte) (v & 0x000000FF);
        }
        return b;
    }

    byte getI1(ubyte _0) const
    {
        return cast(byte) _0;
    }

    byte getI1(ByteReader s) const
    {
        return cast(byte) s.nextByte();
    }

    ubyte[] getI1Bytes(byte v) const
    {
        ubyte[] b = new ubyte[1];
        b[0] = cast(ubyte) v;
        return b;
    }

    short getI2(ubyte _0, ubyte _1) const
    {
        if (this == Cpu_t.SUN)
        {
            return cast(short) (_1 + (_0 << 8));
        }
        return cast(short) (_0 + (_1 << 8));
    }

    short getI2(ByteReader s) const
    {
        ubyte b0 = s.nextByte();
        ubyte b1 = s.nextByte();
        return getI2(b0, b1);
    }

    ubyte[] getI2Bytes(short v) const
    {
        ubyte[] b = new ubyte[2];
        if (this == Cpu_t.SUN)
        {
            b[0] = cast(ubyte) ((v & 0xFF00) >> 8);
            b[1] = cast(ubyte) (v & 0x00FF);
        }
        else
        {
            b[1] = cast(ubyte) ((v & 0xFF00) >> 8);
            b[0] = cast(ubyte) (v & 0x00FF);
        }
        return b;
    }

    int getI4(ubyte _0, ubyte _1, ubyte _2, ubyte _3) const
    {
        if (this == Cpu_t.SUN)
        {
            return _3 + (_2 << 8) + (_1 << 16) + (_0 << 24);
        }
        return _0 + (_1 << 8) + (_2 << 16) + (_3 << 24);
    }

    int getI4(ByteReader s) const
    {
        ubyte b0 = s.nextByte();
        ubyte b1 = s.nextByte();
        ubyte b2 = s.nextByte();
        ubyte b3 = s.nextByte();
        return getI4(b0, b1, b2, b3);
    }

    ubyte[] getI4Bytes(int v) const
    {
        ubyte[] b = new ubyte[4];
        if (this == Cpu_t.SUN)
        {
            b[0] = cast(ubyte) ((v & 0xFF000000) >> 24);
            b[1] = cast(ubyte) ((v & 0x00FF0000) >> 16);
            b[2] = cast(ubyte) ((v & 0x0000FF00) >> 8);
            b[3] = cast(ubyte) (v & 0x000000FF);
        }
        else
        {
            b[3] = cast(ubyte) ((v & 0xFF000000) >> 24);
            b[2] = cast(ubyte) ((v & 0x00FF0000) >> 16);
            b[1] = cast(ubyte) ((v & 0x0000FF00) >> 8);
            b[0] = cast(ubyte) (v & 0x000000FF);
        }
        return b;
    }

    long getLong(ubyte _0, ubyte _1, ubyte _2, ubyte _3, ubyte _4, ubyte _5, ubyte _6, ubyte _7) const
    {
        if (this == Cpu_t.SUN)
        {
            return cast(long) _7 + (cast(long) _6 << 8) + (cast(long) _5 << 16) + (cast(long) _4 << 24) + (cast(long) _3 << 32) + (cast(long) _2 << 40) + (cast(long) _1 << 48) + (cast(long) _0 <<56);
        }
        return cast(long) _0 + (cast(long) _1 << 8) + (cast(long) _2 << 16) + (cast(long) _3 << 24) + (cast(long) _4 << 32) + (cast(long) _5 << 40) + (cast(long) _6 << 48) + (cast(long) _7 <<56);
    }

    float getR4(ubyte _0, ubyte _1, ubyte _2, ubyte _3) const
    {
        int x = getI4(_0, _1, _2, _3); 
        FloatRep f;
        f.sign = (x & 0x80000000) == 0x80000000;
        f.exponent = cast(ubyte) ((x & 0x7F800000) >> 23);
        f.fraction = x & 0x007FFFFF;
        return f.value;
    }

    float getR4(ByteReader s) const
    {
        byte b0 = s.nextByte();
        byte b1 = s.nextByte();
        byte b2 = s.nextByte();
        byte b3 = s.nextByte();
        return getR4(b0, b1, b2, b3);
    }

    ubyte[] getR4Bytes(float v) const
    {
        FloatRep f;
        f.value = v;
        int x = 0;
        if (f.sign) x |= 0x8000;
        int exp = (f.exponent << 23) & 0x7F800000;
        x |= exp;
        x |= f.fraction;
        return getU4Bytes(x);
    }

    double getR8(ubyte _0, ubyte _1, ubyte _2, ubyte _3, ubyte _4, ubyte _5, ubyte _6, ubyte _7) const
    {
        long l = getLong(_0, _1, _2, _3, _4, _5, _6, _7);
        DoubleRep d;
        d.sign = (l & 0x8000000000000000L) == 0x8000000000000000L;
        d.exponent = cast(ushort) ((l & 0x7FF0000000000000L) >> 52);
        d.fraction = l & 0xFFFFFFFFFFFFFL;
        return d.value;
    }
        
    double getR8(ByteReader s) const
    {
        ubyte b0 = s.nextByte();
        ubyte b1 = s.nextByte();
        ubyte b2 = s.nextByte();
        ubyte b3 = s.nextByte();
        ubyte b4 = s.nextByte();
        ubyte b5 = s.nextByte();
        ubyte b6 = s.nextByte();
        ubyte b7 = s.nextByte();
        return getR8(b0, b1, b2, b3, b4, b5, b6, b7);
    }

    ubyte[] getR8Bytes(double v) const
    {
        DoubleRep d;
        d.value = v;
        ulong x = 0L;
        if (d.sign) x |= 0x8000000000000000UL;
        ulong exp = (cast(ulong) d.exponent << 52) & 0x7FF0000000000000UL;
        x |= exp;
        x |= d.fraction;
        ubyte[] b = new ubyte[8];
        if (this == Cpu_t.SUN)
        {
            b[0] = cast(ubyte) ((x & 0xFF00000000000000UL) >> 56);
            b[1] = cast(ubyte) ((x & 0x00FF000000000000UL) >> 48);
            b[2] = cast(ubyte) ((x & 0x0000FF0000000000UL) >> 40);
            b[3] = cast(ubyte) ((x & 0x000000FF00000000UL) >> 32);
            b[4] = cast(ubyte) ((x & 0x00000000FF000000UL) >> 24);
            b[5] = cast(ubyte) ((x & 0x0000000000FF0000UL) >> 16);
            b[6] = cast(ubyte) ((x & 0x000000000000FF00UL) >>  8);
            b[7] = cast(ubyte) (x & 0x00000000000000FFUL);
        }
        else
        {
            b[7] = cast(ubyte) ((x & 0xFF00000000000000UL) >> 56);
            b[6] = cast(ubyte) ((x & 0x00FF000000000000UL) >> 48);
            b[5] = cast(ubyte) ((x & 0x0000FF0000000000UL) >> 40);
            b[4] = cast(ubyte) ((x & 0x000000FF00000000UL) >> 32);
            b[3] = cast(ubyte) ((x & 0x00000000FF000000UL) >> 24);
            b[2] = cast(ubyte) ((x & 0x0000000000FF0000UL) >> 16);
            b[1] = cast(ubyte) ((x & 0x000000000000FF00UL) >>  8);
            b[0] = cast(ubyte) (x & 0x00000000000000FFUL);
        }
        return b;
    }

    ubyte[] getDNBytes(ushort numBits, const (ubyte[]) dn) const
    {
        ubyte[] n = getU2Bytes(numBits);
        ubyte[] b = new ubyte[dn.length + 2];
        b[0] = n[0];
        b[1] = n[1];
        foreach(i, bb; dn) b[i+2] = bb;
        return b;
    }

    ubyte[] getDN(const ushort numBits,  ByteReader s) const
    {
        uint length = (numBits % 8 == 0) ? numBits / 8 : 1 + numBits / 8;
        ubyte[] b = new ubyte[length];
        for (int i=0; i<b.length; i++) b[i] = s.nextByte();
        return b;
    }
 
    string getCN(ByteReader s) const
    {
        uint l = cast(uint) s.nextByte();
        if (l == 0) return "";
        ubyte[] b = new ubyte[l];
        for (int i=0; i<b.length; i++) b[i] = s.nextByte();
        return cast(string) b;
    }

    ubyte[] getCNBytes(string s) const
    {
        ubyte[] b = new ubyte[s.length + 1];
        b[0] = 0;
        b[0] |= s.length;
        foreach(i, c; s) b[i+1] = c;
        return b;
    }

    ubyte[] getBN(ByteReader s) const
    {
        uint l = s.nextByte();
        ubyte[] b = new ubyte[l];
        for (int i=0; i<l; i++) b[i] = s.nextByte();
        return b;
    }

    ubyte[] getBNBytes(const ubyte[] bytes) const
    {
        ubyte[] b = new ubyte[bytes.length + 1];
        b[0] = 0;
        b[0] |= cast(ubyte) (bytes.length & 0x7F);
        foreach(i, c; bytes) b[i+1] = c;
        return b;
    }

    ubyte getN1(ByteReader s) const
    {
        ubyte n = s.nextByte();
        return n;
    }

    ubyte getN1Byte(ubyte b0, ubyte b1) const
    {
        ubyte b = 0;
        b = cast(ubyte) (b0 & 0x0F);
        b |= cast(ubyte) ((b1 & 0x0F) << 4);
        return b;
    }

}

