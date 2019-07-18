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
    VN,
    TestID
}

struct FieldType
{
    string name;
    string description;
    Data_t type;
    bool optional;
    string defaultValueString;
    string arrayCountFieldName;

    string toString() const pure
    {
        return description;
    }
}

enum ATR : const(FieldType)
{
    MOD_TIM = FieldType("MOD_TIM", "Date and time of STDF file modification", Data_t.U4, false, "", ""),
    CMD_LINE = FieldType("CMD_LINE", "Command line of program", Data_t.CN, false, "", "")
}

enum BPS : const(FieldType)
{
    SEQ_NAME = FieldType("SEQ_NAME", "Program section (or sequencer) name", Data_t.CN, true, "\"\"", "")
}

enum DTR : const(FieldType)
{
    TEXT_DAT = FieldType("TEXT_DAT", "ASCII text string", Data_t.CN, false, "", "")
}

enum DTX : const(FieldType)
{
    TEXT_DAT = FieldType("TEXT_DAT", "ASCII text string", Data_t.CN, false, "", "")
}

enum EPS : const(FieldType)
{
    DUMMY = FieldType("DUMMY", "", Data_t.U1, false, "", "")
}

enum FAR : const(FieldType)
{
    CPU_TYPE = FieldType("CPU_TYPE", "CPU type that wrote this file", Data_t.U1, false, "", ""),
    STDF_VER = FieldType("STDF_VER", "STDF version number", Data_t.U1, false, "", "")
}

enum FTR : const(FieldType)
{
    TEST_NUM = FieldType("TEST_NUM", "Test number", Data_t.U4, false, "", ""),
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    TEST_FLG = FieldType("TEST_FLG", "Test flags", Data_t.B1, false, "", ""),
    OPT_FLAG = FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, "0xC0", ""),
    CYCL_CNT = FieldType("CYCL_CNT", "Cycle count of vector", Data_t.U4, true, "0", ""),
    REL_VADR = FieldType("REL_VADR", "Relative vector address", Data_t.U4, true, "0", ""),
    REPT_CNT = FieldType("REPT_CNT", "Repeat count of vector", Data_t.U4, true, "0", ""),
    NUM_FAIL = FieldType("NUM_FAIL", "Number of pins with 1 or more failures", Data_t.U4, true, "0", ""),
    XFAIL_AD = FieldType("XFAIL_AD", "X logical device failure address", Data_t.I4, true, "0", ""),
    YFAIL_AD = FieldType("YFAIL_AD", "Y logical device failure address", Data_t.I4, true, "0", ""),
    VECT_OFF = FieldType("VECT_OFF", "Offset from vector of interest", Data_t.I2, true, "0", ""),
    RTN_ICNT = FieldType("RTN_ICNT", "Count (j) of return data PMR indexes", Data_t.U2, true, "0", ""),
    PGM_ICNT = FieldType("PGM_ICNT", "Count (k) of programmed state indexes", Data_t.U2, true, "0", ""),
    RTN_INDX = FieldType("RTN_INDX", "Array of return data PMR indexes", Data_t.U2, true, "0", "RTN_ICNT"),
    RTN_STAT = FieldType("RTN_STAT", "Array of returned states", Data_t.N1, true, "0", "RTN_ICNT"),
    PGM_INDX = FieldType("PGM_INDX", "Array of programmed state indexes", Data_t.U2, true, "0", "PGM_ICNT"),
    PGM_STAT = FieldType("PGM_STAT", "Array of programmed states", Data_t.N1, true, "0", "PGM_ICNT"),
    FAIL_PIN = FieldType("FAIL_PIN", "Failing pin bitfield", Data_t.DN, true, "new ubyte[0]", ""),
    VECT_NAM = FieldType("VECT_NAM", "Vector module pattern name", Data_t.CN, true, "\"\"", ""),
    TIME_SET = FieldType("TIME_SET", "Time set name", Data_t.CN, true, "\"\"", ""),
    OP_CODE = FieldType("OP_CODE", "Vector Op Code", Data_t.CN, true, "\"\"", ""),
    TEST_TXT = FieldType("TEST_TXT", "Descriptive text or label", Data_t.CN, true, "\"\"", ""),
    ALARM_ID = FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, "\"\"", ""),
    PROG_TXT = FieldType("PROG_TXT", "Additional programmed information", Data_t.CN, true, "\"\"", ""),
    RSLT_TXT = FieldType("RSLT_TXT", "Additional result information", Data_t.CN, true, "\"\"", ""),
    PATG_NUM = FieldType("PATG_NUM", "Pattern generator number", Data_t.U1, true, "255", ""),
    SPIN_MAP = FieldType("SPIN_MAP", "Bitmap of enabled comparators", Data_t.DN, true, "new ubyte[0]", ""),
}

enum GDR : const(FieldType)
{
    FLD_CNT = FieldType("FLD_CNT", "Count of data fields in record", Data_t.U2, false, "", ""),
    GEN_DATA = FieldType("GEN_DATA", "Data type code and data for one field", Data_t.VN, false, "", "FLD_CNT")
}

enum HBR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    HBIN_NUM = FieldType("HBIN_NUM", "Hardware bin number", Data_t.U2, false, "", ""),
    HBIN_CNT = FieldType("HBIN_CNT", "Number of parts in bin", Data_t.U4, false, "", ""),
    HBIN_PF = FieldType("HBIN_PF", "Pass/fail indication", Data_t.C1, true, "' '", ""),
    HBIN_NAM = FieldType("HBIN_NAM", "Name of hardware bin", Data_t.CN, true, "\"\"", "")
}

enum MIR : const(FieldType)
{
    SETUP_T = FieldType("SETUP_T", "Date and time of job setup", Data_t.U4, false, "", ""),
    START_T = FieldType("START_T", "Data and time first part tested", Data_t.U4, false, "", ""),
    STAT_NUM = FieldType("STAT_NUM", "Test station number", Data_t.U1, false, "", ""),
    MODE_COD = FieldType("MODE_COD", "Test mode code (e.g. prod, dev)", Data_t.C1, false, "", ""),
    RTST_COD = FieldType("RTST_COD", "Lot retest code", Data_t.C1, false, "", ""),
    PROT_COD = FieldType("PROT_COD", "Data protection code", Data_t.C1, false, "", ""),
    BURN_TIM = FieldType("BURN_TIM", "Burn-in time (in minutes)", Data_t.U2, false, "", ""),
    CMOD_COD = FieldType("CMOD_COD", "Command mode code", Data_t.C1, false, "", ""),
    LOT_ID = FieldType("LOT_ID", "Lot ID (customer specified)", Data_t.CN, false, "", ""),
    PART_TYP = FieldType("PART_TYP", "Part type (or product ID)", Data_t.CN, false, "", ""),
    NODE_NAM = FieldType("NODE_NAM", "Name of node that generated data", Data_t.CN, false, "", ""),
    TSTR_TYP = FieldType("TSTR_TYP", "Tester type", Data_t.CN, false, "", ""),
    JOB_NAM = FieldType("JOB_NAM", "Job name (test program name)", Data_t.CN, false, "", ""),
    JOB_REV = FieldType("JOB_REV", "Job (test program) revision number", Data_t.CN, true, "\"\"", ""),
    SBLOT_ID = FieldType("SBLOT_ID", "Sublot ID", Data_t.CN, true, "\"\"", ""),
    OPER_NAM = FieldType("OPER_NAM", "Operator name or ID (at setup time)", Data_t.CN, true, "\"\"", ""),
    EXEC_TYP = FieldType("EXEC_TYP", "Tester executive software type", Data_t.CN, true, "\"\"", ""),
    EXEC_VER = FieldType("EXEC_VER", "Tester exec software version number", Data_t.CN, true, "\"\"", ""),
    TEST_COD = FieldType("TEST_COD", "Test phase or step code", Data_t.CN, true, "\"\"", ""),
    TST_TEMP = FieldType("TST_TEMP", "Temperature", Data_t.CN, true, "\"\"", ""),
    USER_TXT = FieldType("USER_TXT", "Generic user text", Data_t.CN, true, "\"\"", ""),
    AUX_FILE = FieldType("AUX_FILE", "Name of auxilliary data file", Data_t.CN, true, "\"\"", ""),
    PKG_TYP = FieldType("PKG_TYP", "Package type", Data_t.CN, true, "\"\"", ""),
    FAMLY_ID = FieldType("FAMLY_ID", "Product family ID", Data_t.CN, true, "\"\"", ""),
    DATE_COD = FieldType("DATE_COD", "Date code", Data_t.CN, true, "\"\"", ""),
    FACIL_ID = FieldType("FACIL_ID", "Test facility ID", Data_t.CN, true, "\"\"", ""),
    FLOOR_ID = FieldType("FLOOR_ID", "Test Floor ID", Data_t.CN, true, "\"\"", ""),
    PROC_ID = FieldType("PROC_ID", "Fabrication process ID", Data_t.CN, true, "\"\"", ""),
    OPER_FRQ = FieldType("OPER_FRQ", "Operation frequency or step", Data_t.CN, true, "\"\"", ""),
    SPEC_NAM = FieldType("SPEC_NAM", "Test specification name", Data_t.CN, true, "\"\"", ""),
    SPEC_VER = FieldType("SPEC_VER", "Test specification version number", Data_t.CN, true, "\"\"", ""),
    FLOW_ID = FieldType("FLOW_ID", "Test flow ID", Data_t.CN, true, "\"\"", ""),
    SETUP_ID = FieldType("SETUP_ID", "Test setup ID", Data_t.CN, true, "\"\"", ""),
    DSGN_REV = FieldType("DSGN_REV", "Device design revision", Data_t.CN, true, "\"\"", ""),
    ENG_ID = FieldType("ENG_ID", "Engineering lot ID", Data_t.CN, true, "\"\"", ""),
    ROM_COD = FieldType("ROM_COD", "ROM code ID", Data_t.CN, true, "\"\"", ""),
    SERL_NUM = FieldType("SERL_NUM", "Tester serial number", Data_t.CN, true, "\"\"", ""),
    SUPR_NAM = FieldType("SUPR_NAM", "Supervisor name or ID", Data_t.CN, true, "\"\"", "")
}

public enum MPR : const(FieldType)
{
    TEST_NUM = FieldType("TEST_NUM", "Test number", Data_t.U4, false, "", ""),
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    TEST_FLG = FieldType("TEST_FLG", "Test flags", Data_t.B1, false, "", ""),
    PARM_FLG = FieldType("PARM_FLG", "Parametric flags (drift, etc.)", Data_t.B1, false, "", ""),
    RTN_ICNT = FieldType("RTN_ICNT", "Count (j) of PMR indexes", Data_t.U2, true, "0", ""),
    RSLT_CNT = FieldType("RSLT_CNT", "Count (k) of returned results", Data_t.U2, true, "0", ""),
    RTN_STAT = FieldType("RTN_STAT", "Array of returned states", Data_t.N1, true, "", "RTN_ICNT"),
    RTN_RSLT = FieldType("RTN_RSLT", "Array of returned results", Data_t.R4, true, "", "RSLT_CNT"),
    TEST_TXT = FieldType("TEST_TXT", "Test description text or label", Data_t.CN, true, "\"\"", ""),
    ALARM_ID = FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, "\"\"", ""),
    OPT_FLAG = FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, "0", ""),
    RES_SCAL = FieldType("RES_SCAL", "Test results scaling exponent", Data_t.I1, true, "0", ""),
    LLM_SCAL = FieldType("LLM_SCAL", "Low limit scaling exponent", Data_t.I1, true, "0", ""),
    HLM_SCAL = FieldType("HLM_SCAL", "High limit scaling exponent", Data_t.I1, true, "0", ""),
    LO_LIMIT = FieldType("LO_LIMIT", "Low test limit value", Data_t.R4, true, "0.0", ""),
    HI_LIMIT = FieldType("HI_LIMIT", "High test limit value", Data_t.R4, true, "0.0", ""),
    START_IN = FieldType("START_IN", "Starting input value (condition)", Data_t.R4, true, "0.0", ""),
    INCR_IN = FieldType("INCR_IN", "Increment of input condition", Data_t.R4, true, "0.0", ""),
    RTN_INDX = FieldType("RTN_INDX", "Array of PMR indexes", Data_t.U2, true, "", "RTN_ICNT"),
    UNITS = FieldType("UNITS", "Test units", Data_t.CN, true, "\"\"", ""),
    UNITS_IN = FieldType("UNITS_IN", "Input condition units", Data_t.CN, true, "\"\"", ""),
    C_RESFMT = FieldType("C_RESFMT", "ANSI C result format string", Data_t.CN, true, "\"\"", ""),
    C_LLMFMT = FieldType("C_LLMFMT", "ANSI C low limit format string", Data_t.CN, true, "\"\"", ""),
    C_HLMFMT = FieldType("C_HLMFMT", "ANSI C high limit format string", Data_t.CN, true, "\"\"", ""),
    LO_SPEC = FieldType("LO_SPEC", "Low specification limit value", Data_t.R4, true, "0.0", ""),
    HI_SPEC = FieldType("HI_SPEC", "High specification limit value", Data_t.R4, true, "0.0", ""),
}

enum MRR : const(FieldType)
{
    FINISH_T = FieldType("FINISH_T", "Date and time last part tested", Data_t.U4, false, "", ""),
    DISP_COD = FieldType("DISP_COD", "Lot disposition code", Data_t.C1, true, "' '", ""),
    USR_DESC = FieldType("USR_DESC", "Lot description supplied by user", Data_t.CN, true, "\"\"", ""),
    EXC_DESC = FieldType("EXC_DESC", "Lot description supplied by exec", Data_t.CN, true, "\"\"", "")
}

enum PCR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    PART_CNT = FieldType("PART_CNT", "Number of parts tested", Data_t.U4, false, "", ""),
    RTST_CNT = FieldType("RTST_CNT", "Number of parts retested", Data_t.U4, true, "4294967295", ""),
    ABRT_CNT = FieldType("ABRT_CNT", "Number of aborts during testing", Data_t.U4, true, "4294967295", ""),
    GOOD_CNT = FieldType("GOOD_CNT", "Number of good (passed) parts tested", Data_t.U4, true, "4294967295", ""),
    FUNC_CNT = FieldType("FUNC_CNT", "Number of functional parts tested", Data_t.U4, true, "4294967295", "")
}

enum PGR : const(FieldType)
{
    GRP_INDX = FieldType("GRP_INDX", "Unique index associated with pin group", Data_t.U2, false, "", ""),
    GRP_NAM = FieldType("GRP_NAM", "Name of pin group", Data_t.CN, false, "", ""),
    INDX_CNT = FieldType("INDX_CNT", "Count(k) of PMR indexes", Data_t.U2, false, "", ""),
    PMR_INDX = FieldType("PMR_INDX", "Array of indexes for  pins in the group", Data_t.U2, true, "", "INDX_CNT")
}

enum PIR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", "")
}

enum PLR : const(FieldType)
{
    GRP_CNT = FieldType("GRP_CNT", "Count (k) og pins or pin groups", Data_t.U2, false, "", ""),
    GRP_INDX = FieldType("GRP_INDX", "Array of pin or pin group indexes", Data_t.U2, false, "", "GRP_CNT"),
    GRP_MODE = FieldType("GRP_MODE", "Operating mode of pin group", Data_t.U2, true, "", "GRP_CNT"),
    GRP_RADX = FieldType("GRP_RADX", "Display radix of pin group", Data_t.U1, true, "", "GRP_CNT"),
    PGM_CHAR = FieldType("PGM_CHAR", "Program state encoding characters", Data_t.CN, true, "", "GRP_CNT"),
    RTN_CHAR = FieldType("RTN_CHAR", "Return state encoding characters", Data_t.CN, true, "", "GRP_CNT"),
    PGM_CHAL = FieldType("PGM_CHAL", "Program state encoding characters", Data_t.CN, true, "", "GRP_CNT"),
    RTN_CHAL = FieldType("RTN_CHAL", "Return state encoding characters", Data_t.CN, true, "", "GRP_CNT")
}

enum PMR : const(FieldType)
{
    PMR_INDX = FieldType("PMR_INDX", "Unique index associated with pin", Data_t.U2, false, "", ""),
    CHAN_TYP = FieldType("CHAN_TYP", "Channel type", Data_t.U2, true, "0", ""),
    CHAN_NAM = FieldType("CHAN_NAM", "Channel name", Data_t.CN, true, "\"\"", ""),
    PHY_NAM = FieldType("PHY_NAM", "Physical name of pin", Data_t.CN, true, "\"\"", ""),
    LOG_NAM = FieldType("LOG_NAM", "Logical name of pin", Data_t.CN, true, "\"\"", ""),
    HEAD_NUM = FieldType("HEAD_NUM", "Head number associated with channel", Data_t.U1, true, "1", ""),
    SITE_NUM = FieldType("SITE_NUM", "Site number associated with channel", Data_t.U1, true, "1", "")
}

enum PRR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    PART_FLG = FieldType("PART_FLG", "Part information flag", Data_t.B1, false, "", ""),
    NUM_TEST = FieldType("NUM_TEST", "Number of tests executed", Data_t.U2, false, "", ""),
    HARD_BIN = FieldType("HARD_BIN", "Hardware bin number", Data_t.U2, false, "", ""),
    SOFT_BIN = FieldType("SOFT_BIN", "Software bin number", Data_t.U2, true, "65535", ""),
    X_COORD = FieldType("X_COORD", "(Wafer) X coordinate", Data_t.I2, true, "-32768", ""),
    Y_COORD = FieldType("Y_COORD", "(Wafer) Y coordinate", Data_t.I2, true, "-32768", ""),
    TEST_T = FieldType("TEST_T", "Elapsed test time in milliseconds", Data_t.U4, true, "0", ""),
    PART_ID = FieldType("PART_ID", "Part identification", Data_t.CN, true, "\"\"", ""),
    PART_TXT = FieldType("PART_TXT", "Part description text", Data_t.CN, true, "\"\"", ""),
    PART_FIX = FieldType("PART_FIX", "Part repair information", Data_t.BN, true, "new ubyte[0]", "")
}

enum PTR : const(FieldType)
{
    TEST_NUM = FieldType("TEST_NUM", "Test number", Data_t.U4, false, "", ""),
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    TEST_FLG = FieldType("TEST_FLG", "Test flags", Data_t.B1, false, "", ""),
    PARM_FLG = FieldType("PARM_FLG", "Parametric flags (drift, etc.)", Data_t.B1, false, "", ""),
    RESULT = FieldType("RESULT", "Test result", Data_t.R4, false, "", ""),
    TEST_TXT = FieldType("TEST_TXT", "Test description text or label", Data_t.CN, true, "\"\"", ""),
    ALARM_ID = FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, "\"\"", ""),
    OPT_FLAG = FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, "0xFF", ""),
    RES_SCAL = FieldType("RES_SCAL", "Test results scaling exponent", Data_t.I1, true, "0", ""),
    LLM_SCAL = FieldType("LLM_SCAL", "Low limit scaling exponent", Data_t.I1, true, "0", ""),
    HLM_SCAL = FieldType("HLM_SCAL", "High limit scaling exponent", Data_t.I1, true, "0", ""),
    LO_LIMIT = FieldType("LO_LIMIT", "Low test limit value", Data_t.R4, true, "0.0f", ""),
    HI_LIMIT = FieldType("HI_LIMIT", "High test limit value", Data_t.R4, true, "0.0f", ""),
    UNITS = FieldType("UNITS", "Test units", Data_t.CN, true, "\"\"", ""),
    C_RESFMT = FieldType("C_RESFMT", "ANSI C result format string", Data_t.CN, true, "\"\"", ""),
    C_LLMFMT = FieldType("C_LLMFMT", "ANSI C low limit format string", Data_t.CN, true, "\"\"", ""),
    C_HLMFMT = FieldType("C_HLMFMT", "ANSI C high limit format string", Data_t.CN, true, "\"\"", ""),
    LO_SPEC = FieldType("LO_SPEC", "Low specification limit value", Data_t.R4, true, "0.0f", ""),
    HI_SPEC = FieldType("HI_SPEC", "High specification limit value", Data_t.R4, true, "0.0f", ""),
}

enum RDR : const(FieldType)
{
    NUM_BINS = FieldType("NUM_BINS", "Number (k) of bins being retested", Data_t.U2, false, "", ""),
    RTST_BIN = FieldType("RTST_BIN", "Array of retest bin numbers", Data_t.U2, true, "", "NUM_BINS")
}

enum SBR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    SBIN_NUM = FieldType("SBIN_NUM", "Software bin number", Data_t.U2, false, "", ""),
    SBIN_CNT = FieldType("SBIN_CNT", "Number of parts in bin", Data_t.U4, false, "", ""),
    SBIN_PF = FieldType("SBIN_PF", "Pass/fail indication", Data_t.C1, true, "' '", ""),
    SBIN_NAM = FieldType("SBIN_NAM", "Name of software bin", Data_t.CN, true, "\"\"", "")
}

enum SDR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_GRP = FieldType("SITE_GRP", "Site group number", Data_t.U1, false, "", ""),
    SITE_CNT = FieldType("SITE_CNT", "Number (k) of test sites in site group", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Array of test site numbers", Data_t.U1, false, "", "SITE_CNT"),
    HAND_TYP = FieldType("HAND_TYP", "Handler or prober type", Data_t.CN, true, "\"\"", ""),
    HAND_ID = FieldType("HAND_ID", "Handler or prober ID", Data_t.CN, true, "\"\"", ""),
    CARD_TYP = FieldType("CARD_TYP", "Probe card type", Data_t.CN, true, "\"\"", ""),
    CARD_ID = FieldType("CARD_ID", "Probe card ID", Data_t.CN, true, "\"\"", ""),
    LOAD_TYP = FieldType("LOAD_TYP", "Loadboard type", Data_t.CN, true, "\"\"", ""),
    LOAD_ID = FieldType("LOAD_ID", "Loadboard ID", Data_t.CN, true, "\"\"", ""),
    DIB_TYP = FieldType("DIB_TYP", "DIB board type", Data_t.CN, true, "\"\"", ""),
    DIB_ID = FieldType("DIB_ID", "DIB board ID", Data_t.CN, true, "\"\"", ""),
    CABL_TYP = FieldType("CABL_TYP", "Interface cable type", Data_t.CN, true, "\"\"", ""),
    CABL_ID = FieldType("CABL_ID", "Interface cable ID", Data_t.CN, true, "\"\"", ""),
    CONT_TYP = FieldType("CONT_TYP", "Handler contactor type", Data_t.CN, true, "\"\"", ""),
    CONT_ID = FieldType("CONT_ID", "Handler contactor ID", Data_t.CN, true, "\"\"", ""),
    LASR_TYP = FieldType("LASR_TYP", "Laser type", Data_t.CN, true, "\"\"", ""),
    LASR_ID = FieldType("LASR_ID", "Laser ID", Data_t.CN, true, "\"\"", ""),
    EXTR_TYP = FieldType("EXTR_TYP", "Extra equipment type field", Data_t.CN, true, "\"\"", ""),
    EXTR_ID = FieldType("EXTR_ID", "Extra equipment ID", Data_t.CN, true, "\"\"", "")
}

enum TSR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, "", ""),
    TEST_TYP = FieldType("TEST_TYP", "Test type", Data_t.C1, false, "", ""),
    TEST_NUM = FieldType("TEST_NUM", "Test number", Data_t.U4, false, "", ""),
    EXEC_CNT = FieldType("EXEC_CNT", "Number of test executions", Data_t.U4, true, "4294967295", ""),
    FAIL_CNT = FieldType("FAIL_CNT", "Number of test failures", Data_t.U4, true, "4294967295", ""),
    ALRM_CNT = FieldType("ALRM_CNT", "Number of alarmed tests", Data_t.U4, true, "4294967295", ""),
    TEST_NAM = FieldType("TEST_NAM", "Test name", Data_t.CN, true, "\"\"", ""),
    SEQ_NAME = FieldType("SEQ_NAME", "Sequencer (program segment/flow) name", Data_t.CN, true, "\"\"", ""),
    TEST_LBL = FieldType("TEST_LBL", "Test label or text", Data_t.CN, true, "\"\"", ""),
    OPT_FLAG = FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, "0", ""),
    TEST_TIM = FieldType("TEST_TIM", "Average test execution time in seconds", Data_t.R4, true, "0.0f", ""),
    TEST_MIN = FieldType("TEST_MIN", "Lowest test result value", Data_t.R4, true, "0.0f", ""),
    TEST_MAX = FieldType("TEST_MAX", "Highest test result value", Data_t.R4, true, "0.0f", ""),
    TST_SUMS = FieldType("TST_SUMS", "Sum of test result values", Data_t.R4, true, "0.0f", ""),
    TST_SQRS = FieldType("TST_SQRS", "Sum of squares of test result values", Data_t.R4, true, "0.0f", "")
}

enum WCR : const(FieldType)
{
    WAFR_SIZ = FieldType("WAFR_SIZ", "Diameter of wafer", Data_t.R4, true, "0.0f", ""),
    DIE_HT = FieldType("DIE_HT", "Height of die", Data_t.R4, true, "0.0f", ""),
    DIE_WID = FieldType("DIE_WID", "Width of die", Data_t.R4, true, "0.0f", ""),
    WF_UNITS = FieldType("WF_UNITS", "Units for wafer and die dimensions", Data_t.U1, true, "0", ""),
    WF_FLAT = FieldType("WF_FLAT", "Orientation of wafer flat", Data_t.C1, true, "' '", ""),
    CENTER_X = FieldType("CENTER_X", "X coordinate of center die on wafer", Data_t.I2, true, "-32768", ""),
    CENTER_Y = FieldType("CENTER_Y", "Y coordinate of center die on wafer", Data_t.I2, true, "-32768", ""),
    POS_X = FieldType("POS_X", "Positive X direction on wafer", Data_t.C1, true, "' '", ""),
    POS_Y = FieldType("POS_Y", "Positive Y direction on wafer", Data_t.C1, true, "' '", "")
}

enum WIR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_GRP = FieldType("SITE_GRP", "Site group number", Data_t.U1, false, "", ""),
    START_T = FieldType("START_T", "Date and time first part tested", Data_t.U4, false, "", ""),
    WAFER_ID = FieldType("WAFER_ID", "Wafer ID", Data_t.CN, true, "\"\"", "")
}

enum WRR : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, "", ""),
    SITE_GRP = FieldType("SITE_GRP", "Site group number", Data_t.U1, false, "", ""),
    FINISH_T = FieldType("FINISH_T", "Date and time last part tested", Data_t.U4, false, "", ""),
    PART_CNT = FieldType("PART_CNT", "Number of parts tested", Data_t.U4, false, "", ""),
    RTST_CNT = FieldType("RTST_CNT", "Number of parts retested", Data_t.U4, true, "4294967295", ""),
    ABRT_CNT = FieldType("ABRT_CNT", "Number of aborts during testing", Data_t.U4, true, "4294967295", ""),
    GOOD_CNT = FieldType("GOOD_CNT", "Number of good (passed) parts tested", Data_t.U4, true, "4294967295", ""),
    FUNC_CNT = FieldType("FUNC_CNT", "Number of functional parts tested", Data_t.U4, true, "4294967295", ""),
    WAFER_ID = FieldType("WAFER_ID", "Wafer ID", Data_t.CN, true, "\"\"", ""),
    FABWF_ID = FieldType("FABWF_ID", "Fab wafer ID", Data_t.CN, true, "\"\"", ""),
    FRAME_ID = FieldType("FRAME_ID", "Wafer frame ID", Data_t.CN, true, "\"\"", ""),
    MASK_ID = FieldType("MASK_ID", "Wafer mask ID", Data_t.CN, true, "\"\"", ""),
    USR_DESC = FieldType("USR_DESC", "Wafer description supplied by user", Data_t.CN, true, "\"\"", ""),
    EXC_DESC = FieldType("EXC_DESC", "Wafer description supplied by exec", Data_t.CN, true, "\"\"", "")
}

