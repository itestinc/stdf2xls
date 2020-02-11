module makechip.DefaultValueDatabase;
import std.stdio;
import makechip.Stdf;
import makechip.Descriptors;
import makechip.Util;
alias TestNumber_t = uint;
alias DupNumber_t = uint;
alias Site_t = ubyte;
alias Head_t = ubyte;
alias TestName_t = string;

public class DefaultValueDatabase
{
    private enum none = new U2[0];

    MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t) defaultTestNames;
    MultiMap!(ubyte,    Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultOptFlags;
    MultiMap!(byte,     Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultResScals;
    MultiMap!(byte,     Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultLlmScals;
    MultiMap!(byte,     Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultHlmScals;
    MultiMap!(float,    Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultLoLimits;
    MultiMap!(float,    Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultHiLimits;
    MultiMap!(string,   Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultUnits;
    MultiMap!(U2[],     Record_t, TestNumber_t, TestName_t, DupNumber_t) defaultPinIndicies;

    MultiMap!(ubyte,    Record_t, TestNumber_t, DupNumber_t) NdefaultOptFlags;
    MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t) NdefaultResScals;
    MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t) NdefaultLlmScals;
    MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t) NdefaultHlmScals;
    MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t) NdefaultLoLimits;
    MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t) NdefaultHiLimits;
    MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t) NdefaultUnits;
    MultiMap!(U2[],     Record_t, TestNumber_t, DupNumber_t) NdefaultPinIndicies;

    this()
    {
        defaultTestNames   = new MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t)();
        defaultOptFlags    = new MultiMap!(ubyte,    Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultResScals    = new MultiMap!(byte,     Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultLlmScals    = new MultiMap!(byte,     Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultHlmScals    = new MultiMap!(byte,     Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultLoLimits    = new MultiMap!(float,    Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultHiLimits    = new MultiMap!(float,    Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultUnits       = new MultiMap!(string,   Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        defaultPinIndicies = new MultiMap!(U2[],     Record_t, TestNumber_t, TestName_t, DupNumber_t)();
        NdefaultOptFlags    = new MultiMap!(ubyte,    Record_t, TestNumber_t, DupNumber_t)();
        NdefaultResScals    = new MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t)();
        NdefaultLlmScals    = new MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t)();
        NdefaultHlmScals    = new MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t)();
        NdefaultLoLimits    = new MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t)();
        NdefaultHiLimits    = new MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t)();
        NdefaultUnits       = new MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t)();
        NdefaultPinIndicies = new MultiMap!(U2[],     Record_t, TestNumber_t, DupNumber_t)();
    }

    public string getDefaultTestName(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultTestNames.get("", type, testNumber, dupNumber);
    }

    public ubyte getDefaultOptFlag(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultOptFlags.get(0, type, testNumber, testName, dupNumber);
        if (v == 0) v = NdefaultOptFlags.get(0, type, testNumber, dupNumber);
        return v;
    }

    public byte getDefaultResScal(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultResScals.get(byte.min, type, testNumber, testName, dupNumber);
        if (v == byte.min) v = NdefaultResScals.get(byte.min, type, testNumber, dupNumber);
        return v;
    }

    public byte getDefaultLlmScal(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultLlmScals.get(byte.min, type, testNumber, testName, dupNumber);
        if (v == byte.min) v = NdefaultLlmScals.get(byte.min, type, testNumber, dupNumber);
        return v;
    }

    public byte getDefaultHlmScal(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultHlmScals.get(byte.min, type, testNumber, testName, dupNumber);
        if (v == byte.min) v = NdefaultHlmScals.get(byte.min, type, testNumber, dupNumber);
        return v;
    }

    public float getDefaultLoLimit(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultLoLimits.get(float.max, type, testNumber, testName, dupNumber);
        if (v == float.max) v = NdefaultLoLimits.get(float.max, type, testNumber, dupNumber);
        return v;
    }

    public float getDefaultHiLimit(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultHiLimits.get(float.max, type, testNumber, testName, dupNumber);
        if (v == float.max) v = NdefaultHiLimits.get(float.max, type, testNumber, dupNumber);
        return v;
    }

    public string getDefaultUnits(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultUnits.get("*&^%$##", type, testNumber, testName, dupNumber);
        if (v == "*&^%$##") v = NdefaultUnits.get("*&^%$##", type, testNumber, dupNumber);
        return v;
    }

    public U2[] getDefaultPinIndicies(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        import std.conv;
        auto v = defaultPinIndicies.get(none, type, testNumber, testName, dupNumber);
        if (v == none) v = NdefaultPinIndicies.get(none, type, testNumber, dupNumber);
        return v;
    }

    public void setFTRDefaults(Record!FTR ftr, uint dup)
    {
        string s = defaultTestNames.get("", ftr.recordType, ftr.TEST_NUM, dup);
        if (s == "" && !ftr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(ftr.TEST_TXT, ftr.recordType, ftr.TEST_NUM, dup);
        }
    }

    public void setPTRDefaults(Record!PTR ptr, uint dup)
    {
        string tname = defaultTestNames.get("", ptr.recordType, ptr.TEST_NUM, dup);
        if (tname == "" && !ptr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(ptr.TEST_TXT, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.TEST_TXT.isEmpty()) tname = ptr.TEST_TXT;

        if (!ptr.OPT_FLAG.isEmpty() && defaultOptFlags.get(0, ptr.recordType, ptr.TEST_NUM, tname, dup) == 0)
        {
            defaultOptFlags.put(ptr.OPT_FLAG, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.OPT_FLAG.isEmpty() && NdefaultOptFlags.get(0, ptr.recordType, ptr.TEST_NUM, dup) == 0)
        {
            NdefaultOptFlags.put(ptr.OPT_FLAG, ptr.recordType, ptr.TEST_NUM, dup);
        }

        if (!ptr.RES_SCAL.isEmpty() && defaultResScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultResScals.put(ptr.RES_SCAL, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.RES_SCAL.isEmpty() && NdefaultResScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, dup) == byte.min)
        {
            NdefaultResScals.put(ptr.RES_SCAL, ptr.recordType, ptr.TEST_NUM, dup);
        }

        if (!ptr.LLM_SCAL.isEmpty() && defaultLlmScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultLlmScals.put(ptr.LLM_SCAL, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.LLM_SCAL.isEmpty() && NdefaultLlmScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, dup) == byte.min)
        {
            NdefaultLlmScals.put(ptr.LLM_SCAL, ptr.recordType, ptr.TEST_NUM, dup);
        }

        if (!ptr.HLM_SCAL.isEmpty() && defaultHlmScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultHlmScals.put(ptr.HLM_SCAL, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.HLM_SCAL.isEmpty() && NdefaultHlmScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, dup) == byte.min)
        {
            NdefaultHlmScals.put(ptr.HLM_SCAL, ptr.recordType, ptr.TEST_NUM, dup);
        }

        writeln("defaultLoLimit = ", defaultLoLimits.get(float.max, ptr.recordType, ptr.TEST_NUM, tname, dup));
        writeln("max = ", (defaultLoLimits.get(float.max, ptr.recordType, ptr.TEST_NUM, tname, dup) == float.max));
        writeln("LO_LIMIT.isEmpty = ", ptr.LO_LIMIT.isEmpty());
        if ((!ptr.LO_LIMIT.isEmpty()) && (defaultLoLimits.get(float.max, ptr.recordType, ptr.TEST_NUM, tname, dup) == float.max))
        {
            writeln("type = ", ptr.recordType, " tnum = ", ptr.TEST_NUM, " tname = ", tname, " dup = ", dup, "LO limit = ", ptr.LO_LIMIT);
            defaultLoLimits.put(ptr.LO_LIMIT, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.LO_LIMIT.isEmpty() && NdefaultLoLimits.get(float.max, ptr.recordType, ptr.TEST_NUM, dup) == float.max)
        {
            NdefaultLoLimits.put(ptr.LO_LIMIT, ptr.recordType, ptr.TEST_NUM, dup);
        }

        if (!ptr.HI_LIMIT.isEmpty() && defaultHiLimits.get(float.max, ptr.recordType, ptr.TEST_NUM, tname, dup) == float.max)
        {
            defaultHiLimits.put(ptr.HI_LIMIT, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.HI_LIMIT.isEmpty() && NdefaultHiLimits.get(float.max, ptr.recordType, ptr.TEST_NUM, dup) == float.max)
        {
            NdefaultHiLimits.put(ptr.HI_LIMIT, ptr.recordType, ptr.TEST_NUM, dup);
        }

        if (!ptr.UNITS.isEmpty() && defaultUnits.get("*&^%$##", ptr.recordType, ptr.TEST_NUM, tname, dup) == "*&^%$##")
        {
            defaultUnits.put(ptr.UNITS, ptr.recordType, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.UNITS.isEmpty() && NdefaultUnits.get("*&^%$##", ptr.recordType, ptr.TEST_NUM, dup) == "*&^%$##")
        {
            NdefaultUnits.put(ptr.UNITS, ptr.recordType, ptr.TEST_NUM, dup);
        }
    }

    public void setMPRDefaults(Record!MPR mpr, uint dup)
    {
        string tname = defaultTestNames.get("", mpr.recordType, mpr.TEST_NUM, dup);
        if (tname == "" && !mpr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(mpr.TEST_TXT.getValue(), mpr.recordType, mpr.TEST_NUM.getValue(), dup);
        }
        if (!mpr.TEST_TXT.isEmpty()) tname = mpr.TEST_TXT;

        if (!mpr.OPT_FLAG.isEmpty() && defaultOptFlags.get(0, mpr.recordType, mpr.TEST_NUM, tname, dup) == 0)
        {
            defaultOptFlags.put(mpr.OPT_FLAG, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.OPT_FLAG.isEmpty() && NdefaultOptFlags.get(0, mpr.recordType, mpr.TEST_NUM, dup) == 0)
        {
            NdefaultOptFlags.put(mpr.OPT_FLAG, mpr.recordType, mpr.TEST_NUM, dup);
        }

        if (!mpr.RES_SCAL.isEmpty() && defaultResScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultResScals.put(mpr.RES_SCAL, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.RES_SCAL.isEmpty() && NdefaultResScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, dup) == byte.min)
        {
            NdefaultResScals.put(mpr.RES_SCAL, mpr.recordType, mpr.TEST_NUM, dup);
        }

        if (!mpr.LLM_SCAL.isEmpty() && defaultLlmScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultLlmScals.put(mpr.LLM_SCAL, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.LLM_SCAL.isEmpty() && NdefaultLlmScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, dup) == byte.min)
        {
            NdefaultLlmScals.put(mpr.LLM_SCAL, mpr.recordType, mpr.TEST_NUM, dup);
        }

        if (!mpr.HLM_SCAL.isEmpty() && defaultHlmScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultHlmScals.put(mpr.HLM_SCAL, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.HLM_SCAL.isEmpty() && NdefaultHlmScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, dup) == byte.min)
        {
            NdefaultHlmScals.put(mpr.HLM_SCAL, mpr.recordType, mpr.TEST_NUM, dup);
        }

        if (!mpr.LO_LIMIT.isEmpty() && defaultLoLimits.get(float.max, mpr.recordType, mpr.TEST_NUM, tname, dup) == float.max)
        {
            defaultLoLimits.put(mpr.LO_LIMIT, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.LO_LIMIT.isEmpty() && NdefaultLoLimits.get(float.max, mpr.recordType, mpr.TEST_NUM, dup) == float.max)
        {
            NdefaultLoLimits.put(mpr.LO_LIMIT, mpr.recordType, mpr.TEST_NUM, dup);
        }

        if (!mpr.HI_LIMIT.isEmpty() && defaultHiLimits.get(float.max, mpr.recordType, mpr.TEST_NUM, tname, dup) == float.max)
        {
            defaultHiLimits.put(mpr.HI_LIMIT, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.HI_LIMIT.isEmpty() && NdefaultHiLimits.get(float.max, mpr.recordType, mpr.TEST_NUM, dup) == float.max)
        {
            NdefaultHiLimits.put(mpr.HI_LIMIT, mpr.recordType, mpr.TEST_NUM, dup);
        }

        if (!mpr.UNITS.isEmpty() && defaultUnits.get("*&^%$##", mpr.recordType, mpr.TEST_NUM, tname, dup) == "*&^%$##")
        {
            defaultUnits.put(mpr.UNITS, mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.UNITS.isEmpty() && NdefaultUnits.get("*&^%$##", mpr.recordType, mpr.TEST_NUM, dup) == "*&^%$##")
        {
            NdefaultUnits.put(mpr.UNITS, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.RTN_INDX.isEmpty() && mpr.RTN_INDX.length != 0 && defaultPinIndicies.get(none, mpr.recordType, mpr.TEST_NUM, tname, dup) == none)
        {
            defaultPinIndicies.put(mpr.RTN_INDX.getValue(), mpr.recordType, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.RTN_INDX.isEmpty() && mpr.RTN_INDX.length != 0 && NdefaultPinIndicies.get(none, mpr.recordType, mpr.TEST_NUM, dup) == none)
        {
            NdefaultPinIndicies.put(mpr.RTN_INDX.getValue(), mpr.recordType, mpr.TEST_NUM, dup);
        }
    }
}
