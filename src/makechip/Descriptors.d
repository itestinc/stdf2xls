module makechip.Descriptors;
import std.conv;

enum Data_t
{
    C1,
    B1,
    U1,
    U2,
    U4,
    I1,
    I2,
    I4,
    R4,
    R8,
    CN,
    BN,
    DN,
    N1,
    VN
}

struct FieldType
{
    const string name;
    const string description;
    const Data_t type;
    const bool optional;
    const bool inSuper;
    const string defaultValueString;
    const string declString;
    const string arrayCountFieldName;
    const string ctorString1;
    const string ctorString2;
    const string getBytesString;
    const string reclenString;
    const string toStringString;

    private const this(string name, string description, Data_t type, bool optional, bool inSuper)
    {
        this(name, description, type, optional, inSuper, "", ""); 
    }

    private const this(string name, string description, Data_t type, bool optional, bool inSuper, string defaultValueString, string arrayCountFieldName)
    {
        this.name = name;
        this.description = description;
        this.type = type;
        this.optional = optional;
        this.defaultValueString = defaultValueString;
        this.arrayCountFieldName = arrayCountFieldName;
        auto acnt = arrayCountFieldName;
        auto dflt = defaultValueString;
        auto array = arrayCountFieldName.length > 0;
        ctorString1 = name ~ " = " ~ optional ? (array ? "OptionalArray!" ~ to!string(type) ~ "(reclen, " ~ acnt ~ ".getValue(), s);" :
                                                         "OptionalField!" ~ to!string(type) ~ "(reclen, s, " ~ dflt ~ ");") :
                                                (array ? "FieldArray!" ~ to!string(type) ~ "(s, " ~ acnt ~ ".getValue());" :
                                                         to!string(type) ~ "(s);");
        ctorString2 = "this." ~ name ~ " = " ~ name ~ ";";
        getBytesString = "bs ~= " ~ name ~ ".getBytes();";
        reclenString = "l += " ~ name ~ ".size;";
        toStringString = "app.put(\"\\n    " ~ name ~ " = \"); app.put(" ~ name ~ ".toString());";
    }

    string toString() const pure
    {
        return description;
    }
}

enum ATR_t : const(FieldType)
{
    MOD_TIM = const FieldType("MOD_TIM", "Date and time of STDF file modification", Data_t.U4, false, false),
    CMD_LINE = const FieldType("CMD_LINE", "Command line of program", Data_t.CN, false, false)
}

enum BPS_t : const(FieldType)
{
    SEQ_NAME = const FieldType("SEQ_NAME", "Program section (or sequencer) name", Data_t.CN, true, false)
}

enum DTR_t : const(FieldType)
{
    TEXT_DAT = const FieldType("TEXT_DAT", "ASCII text string", Data_t.CN, false, false)
}

enum FAR_t : const(FieldType)
{
    CPU_TYPE = const FieldType("CPU_TYPE", "CPU type that wrote this file", Data_t.U1, false, false),
    STDF_VER = const FieldType("STDF_VER", "STDF version number", Data_t.U1, false, false)
}

enum FTR_t : const(FieldType)
{
    TEST_NUM = const FieldType("TEST_NUM", "Test number", Data_t.U4, false, true),
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, true),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, true),
    TEST_FLG = const FieldType("TEST_FLG", "Test flags", Data_t.B1, false, true),
    OPT_FLAG = const FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, false, "0xC0", ""),
    CYCL_CNT = const FieldType("CYCL_CNT", "Cycle count of vector", Data_t.U4, true, false, "0", ""),
    REL_VADR = const FieldType("REL_VADR", "Relative vector address", Data_t.U4, true, false, "0", ""),
    REPT_CNT = const FieldType("REPT_CNT", "Repeat count of vector", Data_t.U4, true, false, "0", ""),
    NUM_FAIL = const FieldType("NUM_FAIL", "Number of pins with 1 or more failures", Data_t.U4, true, false, "0", ""),
    XFAIL_AD = const FieldType("XFAIL_AD", "X logical device failure address", Data_t.I4, true, false, "0", ""),
    YFAIL_AD = const FieldType("YFAIL_AD", "Y logical device failure address", Data_t.I4, true, false, "0", ""),
    VECT_OFF = const FieldType("VECT_OFF", "Offset from vector of interest", Data_t.I2, true, false, "0", ""),
    RTN_ICNT = const FieldType("RTN_ICNT", "Count (j) of return data PMR indexes", Data_t.U2, true, false, "0", ""),
    PGM_ICNT = const FieldType("PGM_ICNT", "Count (k) of programmed state indexes", Data_t.U2, true, false, "0", ""),
    RTN_INDX = const FieldType("RTN_INDX", "Array of return data PMR indexes", Data_t.U2, true, false, "0", "RTN_ICNT"),
    RTN_STAT = const FieldType("RTN_STAT", "Array of returned states", Data_t.N1, true, false, "0", "RTN_ICNT"),
    PGM_INDX = const FieldType("PGM_INDX", "Array of programmed state indexes", Data_t.U2, true, false, "0", "PGM_ICNT"),
    PGM_STAT = const FieldType("PGM_STAT", "Array of programmed states", Data_t.N1, true, false, "0", "PGM_ICNT"),
    FAIL_PIN = const FieldType("FAIL_PIN", "Failing pin bitfield", Data_t.DN, true, false, "", ""),
    VECT_NAM = const FieldType("VECT_NAM", "Vector module pattern name", Data_t.CN, true, false, "\"\"", ""),
    TIME_SET = const FieldType("TIME_SET", "Time set name", Data_t.CN, true, false, "\"\"", ""),
    OP_CODE = const FieldType("OP_CODE", "Vector Op Code", Data_t.CN, true, false, "\"\"", ""),
    TEST_TXT = const FieldType("TEST_TXT", "Descriptive text or label", Data_t.CN, true, false, "\"\"", ""),
    ALARM_ID = const FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, false, "\"\"", ""),
    PROG_TXT = const FieldType("PROG_TXT", "Additional programmed information", Data_t.CN, true, false, "\"\"", ""),
    RSLT_TXT = const FieldType("RSLT_TXT", "Additional result information", Data_t.CN, true, false, "\"\"", ""),
    PATG_NUM = const FieldType("PATG_NUM", "Pattern generator number", Data_t.U1, true, false, "255", ""),
    SPIN_MAP = const FieldType("SPIN_MAP", "Bitmap of enabled comparators", Data_t.DN, true, false, "", "")
}

enum GDR_t : const(FieldType)
{
    FLD_CNT = const FieldType("FLD_CNT", "Count of data fields in record", Data_t.U2, false, false),
    GEN_DATA = const FieldType("GEN_DATA", "Data type code and data for one field", Data_t.VN, false, false, "", "FLD_CNT")
}

enum HBR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false),
    HBIN_NUM = const FieldType("HBIN_NUM", "Hardware bin number", Data_t.U2, false, false),
    HBIN_CNT = const FieldType("HBIN_CNT", "Number of parts in bin", Data_t.U4, false, false),
    HBIN_PF = const FieldType("HBIN_PF", "Pass/fail indication", Data_t.C1, true, false, "' '", ""),
    HBIN_NAM = const FieldType("HBIN_NAM", "Name of hardware bin", Data_t.CN, true, false, "\"\"", "")
}

enum MIR_t : const(FieldType)
{
    SETUP_T = const FieldType("SETUP_T", "Date and time of job setup", Data_t.U4, false, false),
    START_T = const FieldType("START_T", "Data and time first part tested", Data_t.U4, false, false),
    STAT_NUM = const FieldType("STAT_NUM", "Test station number", Data_t.U1, false, false),
    MODE_COD = const FieldType("MODE_COD", "Test mode code (e.g. prod, dev)", Data_t.C1, false, false),
    RTST_COD = const FieldType("RTST_COD", "Lot retest code", Data_t.C1, false, false),
    PROT_COD = const FieldType("PROT_COD", "Data protection code", Data_t.C1, false, false),
    BURN_TIM = const FieldType("BURN_TIM", "Burn-in time (in minutes)", Data_t.U2, false, false),
    CMOD_COD = const FieldType("CMOD_COD", "Command mode code", Data_t.C1, false, false),
    LOT_ID = const FieldType("LOT_ID", "Lot ID (customer specified)", Data_t.CN, false, false),
    PART_TYP = const FieldType("PART_TYP", "Part type (or product ID)", Data_t.CN, false, false),
    NODE_NAM = const FieldType("NODE_NAM", "Name of node that generated data", Data_t.CN, false, false),
    TSTR_TYP = const FieldType("TSTR_TYP", "Tester type", Data_t.CN, false, false),
    JOB_NAM = const FieldType("JOB_NAM", "Job name (test program name)", Data_t.CN, false, false),
    JOB_REV = const FieldType("JOB_REV", "Job (test program) revision number", Data_t.CN, true, false, "\"\"", ""),
    SBLOT_ID = const FieldType("SBLOT_ID", "Sublot ID", Data_t.CN, true, false, "\"\"", ""),
    OPER_NAM = const FieldType("OPER_NAM", "Operator name or ID (at setup time)", Data_t.CN, true, false, "\"\"", ""),
    EXEC_TYP = const FieldType("EXEC_TYP", "Tester executive software type", Data_t.CN, true, false, "\"\"", ""),
    EXEC_VER = const FieldType("EXEC_VER", "Tester exec software version number", Data_t.CN, true, false, "\"\"", ""),
    TEST_COD = const FieldType("TEST_COD", "Test phase or step code", Data_t.CN, true, false, "\"\"", ""),
    TST_TEMP = const FieldType("TST_TEMP", "Temperature", Data_t.CN, true, false, "\"\"", ""),
    USER_TXT = const FieldType("USER_TXT", "Generic user text", Data_t.CN, true, false, "\"\"", ""),
    AUX_FILE = const FieldType("AUX_FILE", "Name of auxilliary data file", Data_t.CN, true, false, "\"\"", ""),
    PKG_TYP = const FieldType("PKG_TYP", "Package type", Data_t.CN, true, false, "\"\"", ""),
    FAMLY_ID = const FieldType("FAMLY_ID", "Product family ID", Data_t.CN, true, false, "\"\"", ""),
    DATE_COD = const FieldType("DATE_COD", "Date code", Data_t.CN, true, false, "\"\"", ""),
    FACIL_ID = const FieldType("FACIL_ID", "Test facility ID", Data_t.CN, true, false, "\"\"", ""),
    FLOOR_ID = const FieldType("FLOOR_ID", "Test Floor ID", Data_t.CN, true, false, "\"\"", ""),
    PROC_ID = const FieldType("PROC_ID", "Fabrication process ID", Data_t.CN, true, false, "\"\"", ""),
    OPER_FRQ = const FieldType("OPER_FRQ", "Operation frequency or step", Data_t.CN, true, false, "\"\"", ""),
    SPEC_NAM = const FieldType("SPEC_NAM", "Test specification name", Data_t.CN, true, false, "\"\"", ""),
    SPEC_VER = const FieldType("SPEC_VER", "Test specification version number", Data_t.CN, true, false, "\"\"", ""),
    FLOW_ID = const FieldType("FLOW_ID", "Test flow ID", Data_t.CN, true, false, "\"\"", ""),
    SETUP_ID = const FieldType("SETUP_ID", "Test setup ID", Data_t.CN, true, false, "\"\"", ""),
    DSGN_REV = const FieldType("DSGN_REV", "Device design revision", Data_t.CN, true, false, "\"\"", ""),
    ENG_ID = const FieldType("ENG_ID", "Engineering lot ID", Data_t.CN, true, false, "\"\"", ""),
    ROM_COD = const FieldType("ROM_COD", "ROM code ID", Data_t.CN, true, false, "\"\"", ""),
    SERL_NUM = const FieldType("SERL_NUM", "Tester serial number", Data_t.CN, true, false, "\"\"", ""),
    SUPR_NAM = const FieldType("SUPR_NAM", "Supervisor name or ID", Data_t.CN, true, false, "\"\"", "")
}

public enum MPR_t : const(FieldType)
{
    TEST_NUM = const FieldType("TEST_NUM", "Test number", Data_t.U4, false, true),
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, true),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, true),
    TEST_FLG = const FieldType("TEST_FLG", "Test flags", Data_t.B1, false, true),
    PARM_FLG = const FieldType("PARM_FLG", "Parametric flags (drift, etc.)", Data_t.B1, false, true),
    RTN_ICNT = const FieldType("RTN_ICNT", "Count (j) of PMR indexes", Data_t.U2, true, false, "0", ""),
    RSLT_CNT = const FieldType("RSLT_CNT", "Count (k) of returned results", Data_t.U2, true, false, "0", ""),
    RTN_STAT = const FieldType("RTN_STAT", "Array of returned states", Data_t.N1, true, true, "", "RTN_ICNT"),
    RTN_RSLT = const FieldType("RTN_RSLT", "Array of returned results", Data_t.R4, true, true, "", "RSLT_CNT"),
    TEST_TXT = const FieldType("TEST_TXT", "Test description text or label", Data_t.CN, true, false, "\"\"", ""),
    ALARM_ID = const FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, false, "\"\"", ""),
    OPT_FLAG = const FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, false, "0", ""),
    RES_SCAL = const FieldType("RES_SCAL", "Test results scaling exponent", Data_t.I1, true, false, "0", ""),
    LLM_SCAL = const FieldType("LLM_SCAL", "Low limit scaling exponent", Data_t.I1, true, false, "0", ""),
    HLM_SCAL = const FieldType("HLM_SCAL", "High limit scaling exponent", Data_t.I1, true, false, "0", ""),
    LO_LIMIT = const FieldType("LO_LIMIT", "Low test limit value", Data_t.R4, true, false, "0.0", ""),
    HI_LIMIT = const FieldType("HI_LIMIT", "High test limit value", Data_t.R4, true, false, "0.0", ""),
    START_IN = const FieldType("START_IN", "Starting input value (condition)", Data_t.R4, true, false, "0.0", ""),
    INCR_IN = const FieldType("INCR_IN", "Increment of input condition", Data_t.R4, true, false, "0.0", ""),
    RTN_INDX = const FieldType("RTN_INDX", "Array of PMR indexes", Data_t.U2, true, true, "", "RTN_ICNT"),
    UNITS = const FieldType("UNITS", "Test units", Data_t.CN, true, false, "\"\"", ""),
    UNITS_IN = const FieldType("UNITS_IN", "Input condition units", Data_t.CN, true, false, "\"\"", ""),
    C_RESFMT = const FieldType("C_RESFMT", "ANSI C result format string", Data_t.CN, true, false, "\"\"", ""),
    C_LLMFMT = const FieldType("C_LLMFMT", "ANSI C low limit format string", Data_t.CN, true, false, "\"\"", ""),
    C_HLMFMT = const FieldType("C_HLMFMT", "ANSI C high limit format string", Data_t.CN, true, false, "\"\"", ""),
    LO_SPEC = const FieldType("LO_SPEC", "Low specification limit value", Data_t.R4, true, false, "0.0", ""),
    HI_SPEC = const FieldType("HI_SPEC", "High specification limit value", Data_t.R4, true, false, "0.0", "")
}

enum MRR_t : const(FieldType)
{
    FINISH_T = const FieldType("FINISH_T", "Date and time last part tested", Data_t.U4, false, false),
    DISP_COD = const FieldType("DISP_COD", "Lot disposition code", Data_t.C1, true, false, "' '", ""),
    USR_DESC = const FieldType("USR_DESC", "Lot description supplied by user", Data_t.CN, true, false, "\"\"", ""),
    EXC_DESC = const FieldType("EXC_DESC", "Lot description supplied by exec", Data_t.CN, true, false, "\"\"", "")
}

enum PCR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false),
    PART_CNT = const FieldType("PART_CNT", "Number of parts tested", Data_t.U4, false, false),
    RTST_CNT = const FieldType("RTST_CNT", "Number of parts retested", Data_t.U4, true, false, "4294967295", ""),
    ABRT_CNT = const FieldType("ABRT_CNT", "Number of aborts during testing", Data_t.U4, true, false, "4294967295", ""),
    GOOD_CNT = const FieldType("GOOD_CNT", "Number of good (passed) parts tested", Data_t.U4, true, false, "4294967295", ""),
    FUNC_CNT = const FieldType("FUNC_CNT", "Number of functional parts tested", Data_t.U4, true, false, "4294967295", "")
}

enum PGR_t : const(FieldType)
{
    GRP_INDX = const FieldType("GRP_INDX", "Unique index associated with pin group", Data_t.U2, false, false),
    GRP_NAM = const FieldType("GRP_NAM", "Name of pin group", Data_t.CN, false, false),
    INDX_CNT = const FieldType("INDX_CNT", "Count(k) of PMR indexes", Data_t.U2, false, false),
    PMR_INDX = const FieldType("PMR_INDX", "Array of indexes for  pins in the group", Data_t.U2, true, false, "", "INDX_CNT")
}

enum PIR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false)
}

enum PLR_t : const(FieldType)
{
    GRP_CNT = const FieldType("GRP_CNT", "Count (k) og pins or pin groups", Data_t.U2, false, false),
    GRP_INDX = const FieldType("GRP_INDX", "Array of pin or pin group indexes", Data_t.U2, false, false, "", "GRP_CNT"),
    GRP_MODE = const FieldType("GRP_MODE", "Operating mode of pin group", Data_t.U2, true, false, "", "GRP_CNT"),
    GRP_RADX = const FieldType("GRP_RADX", "Display radix of pin group", Data_t.U1, true, false, "", "GRP_CNT"),
    PGM_CHAR = const FieldType("PGM_CHAR", "Program state encoding characters", Data_t.CN, true, false, "", "GRP_CNT"),
    RTN_CHAR = const FieldType("RTN_CHAR", "Return state encoding characters", Data_t.CN, true, false, "", "GRP_CNT"),
    PGM_CHAL = const FieldType("PGM_CHAL", "Program state encoding characters", Data_t.CN, true, false, "", "GRP_CNT"),
    RTN_CHAL = const FieldType("RTN_CHAL", "Return state encoding characters", Data_t.CN, true, false, "", "GRP_CNT")
}

enum PMR_t : const(FieldType)
{
    PMR_INDX = const FieldType("PMR_INDX", "Unique index associated with pin", Data_t.U2, false, false),
    CHAN_TYP = const FieldType("CHAN_TYP", "Channel type", Data_t.U2, true, false, "0", ""),
    CHAN_NAM = const FieldType("CHAN_NAM", "Channel name", Data_t.CN, true, false, "\"\"", ""),
    PHY_NAM = const FieldType("PHY_NAM", "Physical name of pin", Data_t.CN, true, false, "\"\"", ""),
    LOG_NAM = const FieldType("LOG_NAM", "Logical name of pin", Data_t.CN, true, false, "\"\"", ""),
    HEAD_NUM = const FieldType("HEAD_NUM", "Head number associated with channel", Data_t.U1, true, false, "1", ""),
    SITE_NUM = const FieldType("SITE_NUM", "Site number associated with channel", Data_t.U1, true, false, "1", "")
}

enum PRR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false),
    PART_FLG = const FieldType("PART_FLG", "Part information flag", Data_t.B1, false, false),
    NUM_TEST = const FieldType("NUM_TEST", "Number of tests executed", Data_t.U2, false, false),
    HARD_BIN = const FieldType("HARD_BIN", "Hardware bin number", Data_t.U2, false, false),
    SOFT_BIN = const FieldType("SOFT_BIN", "Software bin number", Data_t.U2, true, false, "65535", ""),
    X_COORD = const FieldType("X_COORD", "(Wafer) X coordinate", Data_t.I2, true, false, "-32768", ""),
    Y_COORD = const FieldType("Y_COORD", "(Wafer) Y coordinate", Data_t.I2, true, false, "-32768", ""),
    TEST_T = const FieldType("TEST_T", "Elapsed test time in milliseconds", Data_t.U4, true, false, "0", ""),
    PART_ID = const FieldType("PART_ID", "Part identification", Data_t.CN, true, false, "\"\"", ""),
    PART_TXT = const FieldType("PART_TXT", "Part description text", Data_t.CN, true, false, "\"\"", ""),
    PART_FIX = const FieldType("PART_FIX", "Part repair information", Data_t.BN, true, false, "new ubyte[0]", "")
}

enum PTR_t : const(FieldType)
{
    TEST_NUM = const FieldType("TEST_NUM", "Test number", Data_t.U4, false, true),
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, true),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, true),
    TEST_FLG = const FieldType("TEST_FLG", "Test flags", Data_t.B1, false, true),
    PARM_FLG = const FieldType("PARM_FLG", "Parametric flags (drift, etc.)", Data_t.B1, false, true),
    RESULT = const FieldType("RESULT", "Test result", Data_t.R4, false, false),
    TEST_TXT = const FieldType("TEST_TXT", "Test description text or label", Data_t.CN, false, false),
    ALARM_ID = const FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, false, "\"\"", ""),
    OPT_FLAG = const FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, false, "0xFF", ""),
    RES_SCAL = const FieldType("RES_SCAL", "Test results scaling exponent", Data_t.I1, true, false, "0", ""),
    LLM_SCAL = const FieldType("LLM_SCAL", "Low limit scaling exponent", Data_t.I1, true, false, "0", ""),
    HLM_SCAL = const FieldType("HLM_SCAL", "High limit scaling exponent", Data_t.I1, true, false, "0", ""),
    LO_LIMIT = const FieldType("LO_LIMIT", "Low test limit value", Data_t.R4, true, false, "0.0f", ""),
    HI_LIMIT = const FieldType("HI_LIMIT", "High test limit value", Data_t.R4, true, false, "0.0f", ""),
    UNITS = const FieldType("UNITS", "Test units", Data_t.CN, true, false, "\"\"", ""),
    C_RESFMT = const FieldType("C_RESFMT", "ANSI C result format string", Data_t.CN, true, false, "\"\"", ""),
    C_LLMFMT = const FieldType("C_LLMFMT", "ANSI C low limit format string", Data_t.CN, true, false, "\"\"", ""),
    C_HLMFMT = const FieldType("C_HLMFMT", "ANSI C high limit format string", Data_t.CN, true, false, "\"\"", ""),
    LO_SPEC = const FieldType("LO_SPEC", "Low specification limit value", Data_t.R4, true, false, "0.0f", ""),
    HI_SPEC = const FieldType("HI_SPEC", "High specification limit value", Data_t.R4, true, false, "0.0f", "")
}

enum RDR_t : const(FieldType)
{
    NUM_BINS = const FieldType("NUM_BINS", "Number (k) of bins being retested", Data_t.U2, false, false),
    RTST_BIN = const FieldType("RTST_BIN", "Array of retest bin numbers", Data_t.U2, true, false, "", "NUM_BINS")
}

enum SBR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false),
    SBIN_NUM = const FieldType("SBIN_NUM", "Software bin number", Data_t.U2, false, false),
    SBIN_CNT = const FieldType("SBIN_CNT", "Number of parts in bin", Data_t.U4, false, false),
    SBIN_PF = const FieldType("SBIN_PF", "Pass/fail indication", Data_t.C1, true, false, "' '", ""),
    SBIN_NAM = const FieldType("SBIN_NAM", "Name of software bin", Data_t.CN, true, false, "\"\"", "")
}

enum SDR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_GRP = const FieldType("SITE_GRP", "Site group number", Data_t.U1, false, false),
    SITE_CNT = const FieldType("SITE_CNT", "Number (k) of test sites in site group", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Array of test site numbers", Data_t.U1, false, false, "", "SITE_CNT"),
    HAND_TYP = const FieldType("HAND_TYP", "Handler or prober type", Data_t.U1, true, false, "\"\"", ""),
    HAND_ID = const FieldType("HAND_ID", "Handler or prober ID", Data_t.CN, true, false, "\"\"", ""),
    CARD_TYP = const FieldType("CARD_TYP", "Probe card type", Data_t.CN, true, false, "\"\"", ""),
    CARD_ID = const FieldType("CARD_ID", "Probe card ID", Data_t.CN, true, false, "\"\"", ""),
    LOAD_TYP = const FieldType("LOAD_TYP", "Loadboard type", Data_t.CN, true, false, "\"\"", ""),
    LOAD_ID = const FieldType("LOAD_ID", "Loadboard ID", Data_t.CN, true, false, "\"\"", ""),
    DIB_TYP = const FieldType("DIB_TYP", "DIB board type", Data_t.CN, true, false, "\"\"", ""),
    DIB_ID = const FieldType("DIB_ID", "DIB board ID", Data_t.CN, true, false, "\"\"", ""),
    CABL_TYP = const FieldType("CABL_TYP", "Interface cable type", Data_t.CN, true, false, "\"\"", ""),
    CABL_ID = const FieldType("CABL_ID", "Interface cable ID", Data_t.CN, true, false, "\"\"", ""),
    CONT_TYP = const FieldType("CONT_TYP", "Handler contactor type", Data_t.CN, true, false, "\"\"", ""),
    CONT_ID = const FieldType("CONT_ID", "Handler contactor ID", Data_t.CN, true, false, "\"\"", ""),
    LASR_TYP = const FieldType("LASR_TYP", "Laser type", Data_t.CN, true, false, "\"\"", ""),
    LASR_ID = const FieldType("LASR_ID", "Laser ID", Data_t.CN, true, false, "\"\"", ""),
    EXTR_TYP = const FieldType("EXTR_TYP", "Extra equipment type field", Data_t.CN, true, false, "\"\"", ""),
    EXTR_ID = const FieldType("EXTR_ID", "Extra equipment ID", Data_t.CN, true, false, "\"\"", "")
}

enum TSR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = const FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false),
    TEST_TYP = const FieldType("TEST_TYP", "Test type", Data_t.C1, false, false),
    TEST_NUM = const FieldType("TEST_NUM", "Test number", Data_t.U4, false, false),
    EXEC_CNT = const FieldType("EXEC_CNT", "Number of test executions", Data_t.U4, true, false, "4294967295", ""),
    FAIL_CNT = const FieldType("FAIL_CNT", "Number of test failures", Data_t.U4, true, false, "4294967295", ""),
    ALRM_CNT = const FieldType("ALRM_CNT", "Number of alarmed tests", Data_t.U4, true, false, "4294967295", ""),
    TEST_NAM = const FieldType("TEST_NAM", "Test name", Data_t.CN, true, false, "\"\"", ""),
    SEQ_NAME = const FieldType("SEQ_NAME", "Sequencer (program segment/flow) name", Data_t.CN, true, false, "\"\"", ""),
    TEST_LBL = const FieldType("TEST_LBL", "Test label or text", Data_t.CN, true, false, "\"\"", ""),
    OPT_FLAG = const FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, false, "0", ""),
    TEST_TIM = const FieldType("TEST_TIM", "Average test execution time in seconds", Data_t.R4, true, false, "0.0f", ""),
    TEST_MIN = const FieldType("TEST_MIN", "Lowest test result value", Data_t.R4, true, false, "0.0f", ""),
    TEST_MAX = const FieldType("TEST_MAX", "Highest test result value", Data_t.R4, true, false, "0.0f", ""),
    TST_SUMS = const FieldType("TST_SUMS", "Sum of test result values", Data_t.R4, true, false, "0.0f", ""),
    TST_SQRS = const FieldType("TST_SQRS", "Sum of squares of test result values", Data_t.R4, true, false, "0.0f", "")
}

enum WCR_t : const(FieldType)
{
    WAFR_SIZ = const FieldType("WAFR_SIZ", "Diameter of wafer", Data_t.R4, true, false, "0.0f", ""),
    DIE_HT = const FieldType("DIE_HT", "Height of die", Data_t.R4, true, false, "0.0f", ""),
    DIE_WID = const FieldType("DIE_WID", "Width of die", Data_t.R4, true, false, "0.0f", ""),
    WF_UNITS = const FieldType("WF_UNITS", "Units for wafer and die dimensions", Data_t.U1, true, false, "0", ""),
    WF_FLAT = const FieldType("WF_FLAT", "Orientation of wafer flat", Data_t.C1, true, false, "' '", ""),
    CENTER_X = const FieldType("CENTER_X", "X coordinate of center die on wafer", Data_t.I2, true, false, "-32768", ""),
    CENTER_Y = const FieldType("CENTER_Y", "Y coordinate of center die on wafer", Data_t.I2, true, false, "-32768", ""),
    POS_X = const FieldType("POS_X", "Positive X direction on wafer", Data_t.C1, true, false, "' '", ""),
    POS_Y = const FieldType("POS_Y", "Positive Y direction on wafer", Data_t.C1, true, false, "' '", "")
}

enum WIR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_GRP = const FieldType("SITE_GRP", "Site group number", Data_t.U1, false, false),
    START_T = const FieldType("START_T", "Date and time first part tested", Data_t.U4, false, false),
    WAFER_ID = const FieldType("WAFER_ID", "Wafer ID", Data_t.CN, true, false, "\"\"", "")
}

enum WRR_t : const(FieldType)
{
    HEAD_NUM = const FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_GRP = const FieldType("SITE_GRP", "Site group number", Data_t.U1, false, false),
    FINISH_T = const FieldType("FINISH_T", "Date and time last part tested", Data_t.U4, false, false),
    PART_CNT = const FieldType("PART_CNT", "Number of parts tested", Data_t.U4, false, false),
    RTST_CNT = const FieldType("RTST_CNT", "Number of parts retested", Data_t.U4, true, false, "4294967295", ""),
    ABRT_CNT = const FieldType("ABRT_CNT", "Number of aborts during testing", Data_t.U4, true, false, "4294967295", ""),
    GOOD_CNT = const FieldType("GOOD_CNT", "Number of good (passed) parts tested", Data_t.U4, true, false, "4294967295", ""),
    FUNC_CNT = const FieldType("FUNC_CNT", "Number of functional parts tested", Data_t.U4, true, false, "4294967295", ""),
    WAFER_ID = const FieldType("WAFER_ID", "Wafer ID", Data_t.CN, true, false, "\"\"", ""),
    FABWF_ID = const FieldType("FABWF_ID", "Fab wafer ID", Data_t.CN, true, false, "\"\"", ""),
    FRAME_ID = const FieldType("FRAME_ID", "Wafer frame ID", Data_t.CN, true, false, "\"\"", ""),
    MASK_ID = const FieldType("MASK_ID", "Wafer mask ID", Data_t.CN, true, false, "\"\"", ""),
    USR_DESC = const FieldType("USR_DESC", "Wafer description supplied by user", Data_t.CN, true, false, "\"\"", ""),
    EXC_DESC = const FieldType("EXC_DESC", "Wafer description supplied by exec", Data_t.CN, true, false, "\"\"", "")
}

