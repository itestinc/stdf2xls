module itestinc.DefaultValueDatabase;
import std.stdio;
import itestinc.Stdf;
import itestinc.Descriptors;
import itestinc.Util;
alias TestNumber_t = uint;
alias DupNumber_t = uint;
alias Site_t = ubyte;
alias Head_t = ubyte;
alias TestName_t = string;

public class DefaultValueDatabase
{
    private enum none = new U2[0];

    MultiMap!(string,   TestNumber_t, DupNumber_t) defaultTestNames;
    MultiMap!(ubyte,    TestNumber_t, TestName_t, DupNumber_t) defaultOptFlags;
    MultiMap!(byte,     TestNumber_t, TestName_t, DupNumber_t) defaultResScals;
    MultiMap!(byte,     TestNumber_t, TestName_t, DupNumber_t) defaultLlmScals;
    MultiMap!(byte,     TestNumber_t, TestName_t, DupNumber_t) defaultHlmScals;
    MultiMap!(float,    TestNumber_t, TestName_t, DupNumber_t) defaultLoLimits;
    MultiMap!(float,    TestNumber_t, TestName_t, DupNumber_t) defaultHiLimits;
    MultiMap!(string,   TestNumber_t, TestName_t, DupNumber_t) defaultUnits;
    MultiMap!(U2[],     TestNumber_t, TestName_t, DupNumber_t) defaultPinIndicies;

    MultiMap!(ubyte,    TestNumber_t, DupNumber_t) NdefaultOptFlags;
    MultiMap!(byte,     TestNumber_t, DupNumber_t) NdefaultResScals;
    MultiMap!(byte,     TestNumber_t, DupNumber_t) NdefaultLlmScals;
    MultiMap!(byte,     TestNumber_t, DupNumber_t) NdefaultHlmScals;
    MultiMap!(float,    TestNumber_t, DupNumber_t) NdefaultLoLimits;
    MultiMap!(float,    TestNumber_t, DupNumber_t) NdefaultHiLimits;
    MultiMap!(string,   TestNumber_t, DupNumber_t) NdefaultUnits;
    MultiMap!(U2[],     TestNumber_t, DupNumber_t) NdefaultPinIndicies;

    this()
    {
        defaultTestNames   = new MultiMap!(string,   TestNumber_t, DupNumber_t)();
        defaultOptFlags    = new MultiMap!(ubyte,    TestNumber_t, TestName_t, DupNumber_t)();
        defaultResScals    = new MultiMap!(byte,     TestNumber_t, TestName_t, DupNumber_t)();
        defaultLlmScals    = new MultiMap!(byte,     TestNumber_t, TestName_t, DupNumber_t)();
        defaultHlmScals    = new MultiMap!(byte,     TestNumber_t, TestName_t, DupNumber_t)();
        defaultLoLimits    = new MultiMap!(float,    TestNumber_t, TestName_t, DupNumber_t)();
        defaultHiLimits    = new MultiMap!(float,    TestNumber_t, TestName_t, DupNumber_t)();
        defaultUnits       = new MultiMap!(string,   TestNumber_t, TestName_t, DupNumber_t)();
        defaultPinIndicies = new MultiMap!(U2[],     TestNumber_t, TestName_t, DupNumber_t)();
        NdefaultOptFlags    = new MultiMap!(ubyte,    TestNumber_t, DupNumber_t)();
        NdefaultResScals    = new MultiMap!(byte,     TestNumber_t, DupNumber_t)();
        NdefaultLlmScals    = new MultiMap!(byte,     TestNumber_t, DupNumber_t)();
        NdefaultHlmScals    = new MultiMap!(byte,     TestNumber_t, DupNumber_t)();
        NdefaultLoLimits    = new MultiMap!(float,    TestNumber_t, DupNumber_t)();
        NdefaultHiLimits    = new MultiMap!(float,    TestNumber_t, DupNumber_t)();
        NdefaultUnits       = new MultiMap!(string,   TestNumber_t, DupNumber_t)();
        NdefaultPinIndicies = new MultiMap!(U2[],     TestNumber_t, DupNumber_t)();
    }

    public string getDefaultTestName(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultTestNames.get("", testNumber, dupNumber);
    }

    public ubyte getDefaultOptFlag(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultOptFlags.get(0, testNumber, testName, dupNumber);
        if (v == 0) v = NdefaultOptFlags.get(0, testNumber, dupNumber);
        return v;
    }

    public byte getDefaultResScal(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultResScals.get(byte.min, testNumber, testName, dupNumber);
        if (v == byte.min) v = NdefaultResScals.get(byte.min, testNumber, dupNumber);
        return v;
    }

    public byte getDefaultLlmScal(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultLlmScals.get(byte.min, testNumber, testName, dupNumber);
        if (v == byte.min) v = NdefaultLlmScals.get(byte.min, testNumber, dupNumber);
        return v;
    }

    public byte getDefaultHlmScal(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultHlmScals.get(byte.min, testNumber, testName, dupNumber);
        if (v == byte.min) v = NdefaultHlmScals.get(byte.min, testNumber, dupNumber);
        return v;
    }

    public float getDefaultLoLimit(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultLoLimits.get(float.max, testNumber, testName, dupNumber);
        if (v == float.max) v = NdefaultLoLimits.get(float.max, testNumber, dupNumber);
        return v;
    }

    public float getDefaultHiLimit(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultHiLimits.get(float.max, testNumber, testName, dupNumber);
        if (v == float.max) v = NdefaultHiLimits.get(float.max, testNumber, dupNumber);
        return v;
    }

    public string getDefaultUnits(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        auto v = defaultUnits.get("", testNumber, testName, dupNumber);
        if (v == "") v = NdefaultUnits.get("", testNumber, dupNumber);
        return v;
    }

    public U2[] getDefaultPinIndicies(Record_t type, uint testNumber, string testName, uint dupNumber)
    {
        import std.conv;
        auto v = defaultPinIndicies.get(none, testNumber, testName, dupNumber);
        if (v == none) v = NdefaultPinIndicies.get(none, testNumber, dupNumber);
        return v;
    }

    public void setFTRDefaults(Record!FTR ftr, uint dup)
    {
        string s = defaultTestNames.get("", ftr.TEST_NUM, dup);
        if (s == "" && !ftr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(ftr.TEST_TXT, ftr.TEST_NUM, dup);
        }
    }

    public void setPTRDefaults(Record!PTR ptr, uint dup)
    {
        string tname = defaultTestNames.get("", ptr.TEST_NUM, dup);
        if (tname == "" && !ptr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(ptr.TEST_TXT, ptr.TEST_NUM, dup);
        }
        if (!ptr.TEST_TXT.isEmpty()) tname = ptr.TEST_TXT;

        if (!ptr.OPT_FLAG.isEmpty() && defaultOptFlags.get(0, ptr.TEST_NUM, tname, dup) == 0)
        {
            defaultOptFlags.put(ptr.OPT_FLAG, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.OPT_FLAG.isEmpty() && NdefaultOptFlags.get(0, ptr.TEST_NUM, dup) == 0)
        {
            NdefaultOptFlags.put(ptr.OPT_FLAG, ptr.TEST_NUM, dup);
        }

        if (!ptr.RES_SCAL.isEmpty() && defaultResScals.get(byte.min, ptr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultResScals.put(ptr.RES_SCAL, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.RES_SCAL.isEmpty() && NdefaultResScals.get(byte.min, ptr.TEST_NUM, dup) == byte.min)
        {
            NdefaultResScals.put(ptr.RES_SCAL, ptr.TEST_NUM, dup);
        }

        if (!ptr.LLM_SCAL.isEmpty() && defaultLlmScals.get(byte.min, ptr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultLlmScals.put(ptr.LLM_SCAL, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.LLM_SCAL.isEmpty() && NdefaultLlmScals.get(byte.min, ptr.TEST_NUM, dup) == byte.min)
        {
            NdefaultLlmScals.put(ptr.LLM_SCAL, ptr.TEST_NUM, dup);
        }

        if (!ptr.HLM_SCAL.isEmpty() && defaultHlmScals.get(byte.min, ptr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultHlmScals.put(ptr.HLM_SCAL, ptr.TEST_NUM, tname, dup);
        }
        if (!ptr.HLM_SCAL.isEmpty() && NdefaultHlmScals.get(byte.min, ptr.TEST_NUM, dup) == byte.min)
        {
            NdefaultHlmScals.put(ptr.HLM_SCAL, ptr.TEST_NUM, dup);
        }

        if ((!ptr.LO_LIMIT.isEmpty()) && (defaultLoLimits.get(float.max, ptr.TEST_NUM, tname, dup) == float.max))
        {
            defaultLoLimits.put(ptr.LO_LIMIT, ptr.TEST_NUM, tname, dup);
        }
        if ((!ptr.LO_LIMIT.isEmpty()) && (NdefaultLoLimits.get(float.max, ptr.TEST_NUM, dup) == float.max))
        {
            NdefaultLoLimits.put(ptr.LO_LIMIT, ptr.TEST_NUM, dup);
        }

        if ((!ptr.HI_LIMIT.isEmpty()) && (defaultHiLimits.get(float.max, ptr.TEST_NUM, tname, dup) == float.max))
        {
            defaultHiLimits.put(ptr.HI_LIMIT, ptr.TEST_NUM, tname, dup);
        }
        if ((!ptr.HI_LIMIT.isEmpty()) && (NdefaultHiLimits.get(float.max, ptr.TEST_NUM, dup) == float.max))
        {
            NdefaultHiLimits.put(ptr.HI_LIMIT, ptr.TEST_NUM, dup);
        }

        if ((!ptr.UNITS.isEmpty()) && (defaultUnits.get("", ptr.TEST_NUM, tname, dup) == ""))
        {
            defaultUnits.put(ptr.UNITS, ptr.TEST_NUM, tname, dup);
        }
        if ((!ptr.UNITS.isEmpty()) && (NdefaultUnits.get("", ptr.TEST_NUM, dup) == ""))
        {
            NdefaultUnits.put(ptr.UNITS, ptr.TEST_NUM, dup);
        }
    }

    public void setMPRDefaults(Record!MPR mpr, uint dup)
    {
        string tname = defaultTestNames.get("", mpr.TEST_NUM, dup);
        if (tname == "" && !mpr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(mpr.TEST_TXT.getValue(), mpr.TEST_NUM.getValue(), dup);
        }
        if (!mpr.TEST_TXT.isEmpty()) tname = mpr.TEST_TXT;

        if (!mpr.OPT_FLAG.isEmpty() && defaultOptFlags.get(0, mpr.TEST_NUM, tname, dup) == 0)
        {
            defaultOptFlags.put(mpr.OPT_FLAG, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.OPT_FLAG.isEmpty() && NdefaultOptFlags.get(0, mpr.TEST_NUM, dup) == 0)
        {
            NdefaultOptFlags.put(mpr.OPT_FLAG, mpr.TEST_NUM, dup);
        }

        if (!mpr.RES_SCAL.isEmpty() && defaultResScals.get(byte.min, mpr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultResScals.put(mpr.RES_SCAL, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.RES_SCAL.isEmpty() && NdefaultResScals.get(byte.min, mpr.TEST_NUM, dup) == byte.min)
        {
            NdefaultResScals.put(mpr.RES_SCAL, mpr.TEST_NUM, dup);
        }

        if (!mpr.LLM_SCAL.isEmpty() && defaultLlmScals.get(byte.min, mpr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultLlmScals.put(mpr.LLM_SCAL, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.LLM_SCAL.isEmpty() && NdefaultLlmScals.get(byte.min, mpr.TEST_NUM, dup) == byte.min)
        {
            NdefaultLlmScals.put(mpr.LLM_SCAL, mpr.TEST_NUM, dup);
        }

        if (!mpr.HLM_SCAL.isEmpty() && defaultHlmScals.get(byte.min, mpr.TEST_NUM, tname, dup) == byte.min)
        {
            defaultHlmScals.put(mpr.HLM_SCAL, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.HLM_SCAL.isEmpty() && NdefaultHlmScals.get(byte.min, mpr.TEST_NUM, dup) == byte.min)
        {
            NdefaultHlmScals.put(mpr.HLM_SCAL, mpr.TEST_NUM, dup);
        }

        if (!mpr.LO_LIMIT.isEmpty() && defaultLoLimits.get(float.max, mpr.TEST_NUM, tname, dup) == float.max)
        {
            defaultLoLimits.put(mpr.LO_LIMIT, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.LO_LIMIT.isEmpty() && NdefaultLoLimits.get(float.max, mpr.TEST_NUM, dup) == float.max)
        {
            NdefaultLoLimits.put(mpr.LO_LIMIT, mpr.TEST_NUM, dup);
        }

        if (!mpr.HI_LIMIT.isEmpty() && defaultHiLimits.get(float.max, mpr.TEST_NUM, tname, dup) == float.max)
        {
            defaultHiLimits.put(mpr.HI_LIMIT, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.HI_LIMIT.isEmpty() && NdefaultHiLimits.get(float.max, mpr.TEST_NUM, dup) == float.max)
        {
            NdefaultHiLimits.put(mpr.HI_LIMIT, mpr.TEST_NUM, dup);
        }

        if (!mpr.UNITS.isEmpty() && defaultUnits.get("", mpr.TEST_NUM, tname, dup) == "")
        {
            defaultUnits.put(mpr.UNITS, mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.UNITS.isEmpty() && NdefaultUnits.get("", mpr.TEST_NUM, dup) == "")
        {
            NdefaultUnits.put(mpr.UNITS, mpr.TEST_NUM, dup);
        }

        if (!mpr.RTN_INDX.isEmpty() && mpr.RTN_INDX.length != 0 && defaultPinIndicies.get(none, mpr.TEST_NUM, tname, dup) == none)
        {
            defaultPinIndicies.put(mpr.RTN_INDX.getValue(), mpr.TEST_NUM, tname, dup);
        }
        if (!mpr.RTN_INDX.isEmpty() && mpr.RTN_INDX.length != 0 && NdefaultPinIndicies.get(none, mpr.TEST_NUM, dup) == none)
        {
            NdefaultPinIndicies.put(mpr.RTN_INDX.getValue(), mpr.TEST_NUM, dup);
        }
    }
}
