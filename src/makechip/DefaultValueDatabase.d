module makechip.DefaultValueDatabase;
import std.stdio;
import makechip.util.Collections;
import makechip.Stdf;
import makechip.Descriptors;
alias TestNumber_t = uint;
alias DupNumber_t = uint;
alias Site_t = ubyte;
alias Head_t = ubyte;

public class DefaultValueDatabase
{
    private enum none = new U2[0];

    MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t) defaultTestNames;
    MultiMap!(ubyte,    Record_t, TestNumber_t, DupNumber_t) defaultOptFlags;
    MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t) defaultResScals;
    MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t) defaultLlmScals;
    MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t) defaultHlmScals;
    MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t) defaultLoLimits;
    MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t) defaultHiLimits;
    MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t) defaultUnits;
    MultiMap!(U2[], Record_t, TestNumber_t, DupNumber_t) defaultPinIndicies;

    this()
    {
        defaultTestNames   = new MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t)();
        defaultOptFlags    = new MultiMap!(ubyte,    Record_t, TestNumber_t, DupNumber_t)();
        defaultResScals    = new MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t)();
        defaultLlmScals    = new MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t)();
        defaultHlmScals    = new MultiMap!(byte,     Record_t, TestNumber_t, DupNumber_t)();
        defaultLoLimits    = new MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t)();
        defaultHiLimits    = new MultiMap!(float,    Record_t, TestNumber_t, DupNumber_t)();
        defaultUnits       = new MultiMap!(string,   Record_t, TestNumber_t, DupNumber_t)();
        defaultPinIndicies = new MultiMap!(U2[], Record_t, TestNumber_t, DupNumber_t)();
    }

    public string getDefaultTestName(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultTestNames.get("", type, testNumber, dupNumber);
    }

    public ubyte getDefaultOptFlag(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultOptFlags.get(0, type, testNumber, dupNumber);
    }

    public byte getDefaultResScal(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultResScals.get(byte.min, type, testNumber, dupNumber);
    }

    public byte getDefaultLlmScal(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultLlmScals.get(byte.min, type, testNumber, dupNumber);
    }

    public byte getDefaultHlmScal(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultHlmScals.get(byte.min, type, testNumber, dupNumber);
    }

    public float getDefaultLoLimit(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultLoLimits.get(float.nan, type, testNumber, dupNumber);
    }

    public float getDefaultHiLimit(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultHiLimits.get(float.nan, type, testNumber, dupNumber);
    }

    public string getDefaultUnits(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultUnits.get("*&^%$##", type, testNumber, dupNumber);
    }

    public U2[] getDefaultPinIndicies(Record_t type, uint testNumber, uint dupNumber)
    {
        return defaultPinIndicies.get(none, type, testNumber, dupNumber);
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
        string s = defaultTestNames.get("", ptr.recordType, ptr.TEST_NUM, dup);
        if (s == "" && !ptr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(ptr.TEST_TXT, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.OPT_FLAG.isEmpty() && defaultOptFlags.get(0, ptr.recordType, ptr.TEST_NUM, dup) == 0)
        {
            defaultOptFlags.put(ptr.OPT_FLAG, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.RES_SCAL.isEmpty() && defaultResScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, dup) == byte.min)
        {
            defaultResScals.put(ptr.RES_SCAL, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.LLM_SCAL.isEmpty() && defaultLlmScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, dup) == byte.min)
        {
            defaultLlmScals.put(ptr.LLM_SCAL, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.HLM_SCAL.isEmpty() && defaultHlmScals.get(byte.min, ptr.recordType, ptr.TEST_NUM, dup) == byte.min)
        {
            defaultHlmScals.put(ptr.HLM_SCAL, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.LO_LIMIT.isEmpty() && defaultLoLimits.get(float.nan, ptr.recordType, ptr.TEST_NUM, dup) == float.nan)
        {
            defaultLoLimits.put(ptr.LO_LIMIT, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.HI_LIMIT.isEmpty() && defaultHiLimits.get(float.nan, ptr.recordType, ptr.TEST_NUM, dup) == float.nan)
        {
            defaultHiLimits.put(ptr.HI_LIMIT, ptr.recordType, ptr.TEST_NUM, dup);
        }
        if (!ptr.UNITS.isEmpty() && defaultUnits.get("*&^%$##", ptr.recordType, ptr.TEST_NUM, dup) == "*&^%$##")
        {
            defaultUnits.put(ptr.UNITS, ptr.recordType, ptr.TEST_NUM, dup);
        }
    }

    public void setMPRDefaults(Record!MPR mpr, uint dup)
    {
        string s = defaultTestNames.get("", mpr.recordType, mpr.TEST_NUM, dup);
        if (s == "" && !mpr.TEST_TXT.isEmpty())
        {
            defaultTestNames.put(mpr.TEST_TXT.getValue(), mpr.recordType, mpr.TEST_NUM.getValue(), dup);
        }
        if (!mpr.OPT_FLAG.isEmpty() && defaultOptFlags.get(0, mpr.recordType, mpr.TEST_NUM, dup) == 0)
        {
            defaultOptFlags.put(mpr.OPT_FLAG, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.RES_SCAL.isEmpty() && defaultResScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, dup) == byte.min)
        {
            defaultResScals.put(mpr.RES_SCAL, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.LLM_SCAL.isEmpty() && defaultLlmScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, dup) == byte.min)
        {
            defaultLlmScals.put(mpr.LLM_SCAL, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.HLM_SCAL.isEmpty() && defaultHlmScals.get(byte.min, mpr.recordType, mpr.TEST_NUM, dup) == byte.min)
        {
            defaultHlmScals.put(mpr.HLM_SCAL, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.LO_LIMIT.isEmpty() && defaultLoLimits.get(float.nan, mpr.recordType, mpr.TEST_NUM, dup) == float.nan)
        {
            defaultLoLimits.put(mpr.LO_LIMIT, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.HI_LIMIT.isEmpty() && defaultHiLimits.get(float.nan, mpr.recordType, mpr.TEST_NUM, dup) == float.nan)
        {
            defaultHiLimits.put(mpr.HI_LIMIT, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.UNITS.isEmpty() && defaultUnits.get("*&^%$##", mpr.recordType, mpr.TEST_NUM, dup) == "*&^%$##")
        {
            defaultUnits.put(mpr.UNITS, mpr.recordType, mpr.TEST_NUM, dup);
        }
        if (!mpr.RTN_INDX.isEmpty() && defaultPinIndicies.get(none, mpr.recordType, mpr.TEST_NUM, dup) == none)
        {
            defaultPinIndicies.put(mpr.RTN_INDX.getValue(), mpr.recordType, mpr.TEST_NUM, dup);
        }
    }
}
