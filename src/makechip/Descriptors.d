module makechip.Descriptors;

enum Data_t
{
    C1,
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
    alias istr = immutable(string);
    alias ibool = immutable(bool);

    private const this(istr name, istr description, Data_t type, ibool optional, ibool inSuper)
    {
        this(name, description, type, optional, inSuper, "", ""); 
    }

    private const this(istr name, istr description, Data_t type, ibool optional, ibool, inSuper, istr defaultValueString, istr arrayCountFieldName)
    {
        this.name = name;
        this.description = description;
        this.type = type;
        this.optional = optional;
        this.defaultValueString;
        this.arrayCountFieldName = arrayCountFieldName;
        auto acnt = arrayCountFieldName;
        auto dflt = defaultValueString;
        auto array = arryaCountFieldName.length > 0;
        ctorString1 = name ~ " = " ~ optional ? (array ? "OptionalArray!" ~ to!string(type) ~ "(reclen, " ~ acnt ~ ".getValue(), s);" :
                                                         "OptionalField!" ~ to!string(type) ~ "(reclen, s, " ~ dflt ~ ");") :
                                                (array ? "FieldArray!" ~ to!string(type) ~ "(s, " ~ acnt ~ ".getValue());" :
                                                         to!string(type) ~ "(s);");
        ctorString2 = "this." ~ name ~ " = " ~ name ~ ";";
        getByteString = "bs ~= " ~ name ~ ".getBytes();";
        reclenString = "l += " ~ name ~ ".size;";
        toStringString = "app.put(\"\\n    " ~ name ~ " = \"); app.put(" ~ name ~ ".toString());";
    }

    override string toString() const pure
    {
        return description;
    }
}

enum ATR_t : const(FieldType)
{
    MOD_TIM = FieldType("MOD_TIM", "Date and time of STDF file modification", Data_t.U4, false, false),
    CMD_LINE = FieldType("CMD_LINE", "Command line of program", Data_t.CN, false, false);
}

enum BPS_t : const(FieldType)
{
    SEQ_NAME = FieldType("SEQ_NAME", "Program section (or sequencer) name", Data_t.CN, true, false);
}

enum DTR_t : const(FieldType)
{
    TEXT_DAT = FieldType("TEXT_DAT", "ASCII text string", Data_t.CN, false, false);
}

enum FAR_t : const(FieldType)
{
    CPU_TYPE = FieldType("CPU_TYPE", "CPU type that wrote this file", Data_t.U1, false, false),
    STDF_VER = FieldType("STDF_VER", "STDF version number", Data_t.U1, false, false);
}

enum FTR_t : const(FieldType)
{
    TEST_NUM = FieldType("TEST_NUM", "Test number", Data_t.U4, false, true),
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, true),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, true),
    TEST_FLG = FieldType("TEST_FLG", "Test flags", Data_t.B1, false, true),
    OPT_FLAG = FieldType("OPT_FLAG", "Optional data flag", Data_t.B1, true, false, "0xC0", ""),
    CYCL_CNT = FieldType("CYCL_CNT", "Cycle count of vector", Data_t.U4, true, false, "0", ""),
    REL_VADR = FieldType("REL_VADR", "Relative vector address", Data_t.U4, true, false, "0", ""),
    REPT_CNT = FieldType("REPT_CNT", "Repeat count of vector", Data_t.U4, true, false, "0", ""),
    NUM_FAIL = FieldType("NUM_FAIL", "Number of pins with 1 or more failures", Data_t.U4, true, false, "0", ""),
    XFAIL_AD = FieldType("XFAIL_AD", "X logical device failure address", Data_t.I4, true, false, "0", ""),
    YFAIL_AD = FieldType("YFAIL_AD", "Y logical device failure address", Data_t.I4, true, false, "0", ""),
    VECT_OFF = FieldType("VECT_OFF", "Offset from vector of interest", Data_t.I2, true, false, "0", ""),
    RTN_ICNT = FieldType("RTN_ICNT", "Count (j) of return data PMR indexes", Data_t.U2, true, false, "0", ""),
    PGM_ICNT = FieldType("PGM_ICNT", "Count (k) of programmed state indexes", Data_t.U2, true, false, "0", ""),
    RTN_INDX = FieldType("RTN_INDX", "Array of return data PMR indexes", Data_t.U2, true, false, "0", "RTN_ICNT"),
    RTN_STAT = FieldType("RTN_STAT", "Array of returned states", Data_t.N1, true, false, "0", "RTN_ICNT"),
    PGM_INDX = FieldType("PGM_INDX", "Array of programmed state indexes", Data_t.U2, true, false, "0", "PGM_ICNT"),
    PGM_STAT = FieldType("PGM_STAT", "Array of programmed states", Data_t.N1, true, false, "0", "PGM_ICNT"),
    FAIL_PIN = FieldType("FAIL_PIN", "Failing pin bitfield", Data_t.DN, true, false, "", ""),
    VECT_NAM = FieldType("VECT_NAM", "Vector module pattern name", Data_t.CN, true, false, "\"\"", ""),
    TIME_SET = FieldType("TIME_SET", "Time set name", Data_t.CN, true, false, "\"\"", ""),
    OP_CODE = FieldType("OP_CODE", "Vector Op Code", Data_t.CN, true, false, "\"\"", ""),
    TEST_TXT = FieldType("TEST_TXT", "Descriptive text or label", Data_t.CN, true, false, "\"\"", ""),
    ALARM_ID = FieldType("ALARM_ID", "Name of alarm", Data_t.CN, true, false, "\"\"", ""),
    PROG_TXT = FieldType("PROG_TXT", "Additional programmed information", Data_t.CN, true, false, "\"\"", ""),
    RSLT_TXT = FieldType("RSLT_TXT", "Additional result information", Data_t.CN, true, false, "\"\"", ""),
    PATG_NUM = FieldType("PATG_NUM", "Pattern generator number", Data_t.U1, true, false, "255", ""),
    SPIN_MAP = FieldType("SPIN_MAP", "Bitmap of enabled comparators", Data_t.DN, true, false, "");
}

enum GDR_t : const(FieldType)
{
    FLD_CNT("FLD_CNT", "Count of data fields in record", Data_t.U2, false, false),
    GEN_DATA("GEN_DATA", "Data type code and data for one field", Data_t.VN, false, false, "", "FLD_CNT")
}

enum HBR_t : const(FieldType)
{
    HEAD_NUM = FieldType("HEAD_NUM", "Test head number", Data_t.U1, false, false),
    SITE_NUM = FieldType("SITE_NUM", "Test site number", Data_t.U1, false, false),
    HBIN_NUM = FieldType("HBIN_NUM", "Hardware bin number", Data_t.U2, false, false),
    HBIN_CNT = FieldType("HBIN_CNT", "Number of parts in bin", Data_t.U4, false, false),
    HBIN_PF = FieldType("HBIN_PF", "Pass/fail indication", Data_t.C1, true, false, "' '", ""),
    HBIN_NAM = FieldType("HBIN_NAM", "Name of hardware bin", Data_t.CN, true, false, "\"\"", "");
}

enum MIR_t : const(FieldType)
{
    SETUP_T(U4,   null, true, U4_t.SETUP_T, "Date and time of job setup"),
    START_T(U4,   null, true, U4_t.START_T, "Data and time first part tested"),
    STAT_NUM(U1,  null, true, U1_t.STAT_NUM, "Test station number"),
    MODE_COD(C1,  null, true, C1_t.MODE_COD, "Test mode code (e.g. prod, dev)"),
    RTST_COD(C1,  null, true, C1_t.RTST_COD, "Lot retest code"),
    PROT_COD(C1,  null, true, C1_t.PROT_COD, "Data protection code"),
    BURN_TIM(U2,  null, true, U2_t.BURN_TIM, "Burn-in time (in minutes)"),
    CMOD_COD(C1,  null, true, C1_t.CMOD_COD, "Command mode code"),
    LOT_ID(CN,    null, true, CN_t.LOT_ID, "Lot ID (customer specified)"),
    PART_TYP(CN,  null, true, CN_t.PART_TYP, "Part type (or product ID)"),
    NODE_NAM(CN,  null, true, CN_t.NODE_NAM, "Name of node that generated data"),
    TSTR_TYP(CN,  null, true, CN_t.TSTR_TYP, "Tester type"),
    JOB_NAM(CN,   null, true, CN_t.JOB_NAM, "Job name (test program name)"),
    JOB_REV(CN,   null, false, CN_t.JOB_REV, "Job (test program) revision number"),
    SBLOT_ID(CN,  null, false, CN_t.SBLOT_ID, "Sublot ID"),
    OPER_NAM(CN,  null, false, CN_t.OPER_NAM, "Operator name or ID (at setup time)"),
    EXEC_TYP(CN,  null, false, CN_t.EXEC_TYP, "Tester executive software type"),
    EXEC_VER(CN,  null, false, CN_t.EXEC_VER, "Tester exec software version number"),
    TEST_COD(CN,  null, false, CN_t.TEST_COD, "Test phase or step code"),
    TST_TEMP(CN,  null, false, CN_t.TST_TEMP, "Temperature"),
    USER_TXT(CN,  null, false, CN_t.USER_TXT, "Generic user text"),
    AUX_FILE(CN,  null, false, CN_t.AUX_FILE, "Name of auxilliary data file"),
    PKG_TYP(CN,   null, false, CN_t.PKG_TYP, "Package type"),
    FAMLY_ID(CN,  null, false, CN_t.FAMLY_ID, "Product family ID"),
    DATE_COD(CN,  null, false, CN_t.DATE_COD, "Date code"),
    FACIL_ID(CN,  null, false, CN_t.FACIL_ID, "Test facility ID"),
    FLOOR_ID(CN,  null, false, CN_t.FLOOR_ID, "Test Floor ID"),
    PROC_ID(CN,   null, false, CN_t.PROC_ID, "Fabrication process ID"),
    OPER_FRQ(CN,  null, false, CN_t.OPER_FRQ, "Operation frequency or step"),
    SPEC_NAM(CN,  null, false, CN_t.SPEC_NAM, "Test specification name"),
    SPEC_VER(CN,  null, false, CN_t.SPEC_VER, "Test specification version number"),
    FLOW_ID(CN,   null, false, CN_t.FLOW_ID, "Test flow ID"),
    SETUP_ID(CN,  null, false, CN_t.SETUP_ID, "Test setup ID"),
    DSGN_REV(CN,  null, false, CN_t.DSGN_REV, "Device design revision"),
    ENG_ID(CN,    null, false, CN_t.ENG_ID, "Engineering lot ID"),
    ROM_COD(CN,   null, false, CN_t.ROM_COD, "ROM code ID"),
    SERL_NUM(CN,  null, false, CN_t.SERL_NUM, "Tester serial number"),
    SUPR_NAM(CN,  null, false, CN_t.SUPR_NAM, "Supervisor name or ID");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private MIR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.countField = countField;
        this.required = required;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.*;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum MPR_t implements FieldDescriptor
{
    TEST_NUM(U4, null, true, U4_t.TEST_NUM, "Test number"),
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number"),
    TEST_FLG(B1, null, true, B1_t.TEST_FLG, "Test flags"),
    PARM_FLG(B1, null, true, B1_t.PARM_FLG, "Parametric flags (drift, etc.)"),
    RTN_ICNT(U2, null, true, U2_t.RTN_ICNT, "Count (j) of PMR indexes"),
    RSLT_CNT(U2, null, true, U2_t.RSLT_CNT, "Count (k) of returned results"),
    RTN_STAT(N1, RTN_ICNT, false, N1Array_t.RTN_STAT, "Array of returned states"),
    RTN_RSLT(R4, RSLT_CNT, false, R4Array_t.RTN_RSLT, "Array of returned results"),
    TEST_TXT(CN, null, false, CN_t.TEST_TXT, "Test description text or label"),
    ALARM_ID(CN, null, false, CN_t.ALARM_ID, "Name of alarm"),
    OPT_FLAG(B1, null, false, B1_t.OPT_FLAG, "Optional data flag"),
    RES_SCAL(I1, null, false, I1_t.RES_SCAL, "Test results scaling exponent"),
    LLM_SCAL(I1, null, false, I1_t.LLM_SCAL, "Lfalseow limit scaling exponent"),
    HLM_SCAL(I1, null, false, I1_t.HLM_SCAL, "High limit scaling exponent"),
    LO_LIMIT(R4, null, false, R4_t.LO_LIMIT, "Low test limit value"),
    HI_LIMIT(R4, null, false, R4_t.HI_LIMIT, "High test limit value"),
    START_IN(R4, null, false, R4_t.START_IN, "Starting input value (condition)"),
    INCR_IN(R4,  null, false, R4_t.INCR_IN, "Increment of input condition"),
    RTN_INDX(U2, RTN_ICNT, false, U2Array_t.RTN_INDX, "Array of PMR indexes"),
    UNITS(CN,    null, false, CN_t.UNITS, "Test units"),
    UNITS_IN(CN, null, false, CN_t.UNITS_IN, "Input condition units"),
    C_RESFMT(CN, null, false, CN_t.C_RESFMT, "ANSI C result format string"),
    C_LLMFMT(CN, null, false, CN_t.C_LLMFMT, "ANSI C low limit format string"),
    C_HLMFMT(CN, null, false, CN_t.C_HLMFMT, "ANSI C high limit format string"),
    LO_SPEC(R4,  null, false, R4_t.LO_SPEC, "Low specification limit value"),
    HI_SPEC(R4,  null, false, R4_t.HI_SPEC, "High specification limit value");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private MPR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.C1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.C1_t;
import com.makechip.stdf2xls4.stdf.enums.types.CN_t;
import com.makechip.stdf2xls4.stdf.enums.types.FieldType;
import com.makechip.stdf2xls4.stdf.enums.types.U4_t;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum MRR_t implements FieldDescriptor
{
    FINISH_T(U4, null, true, U4_t.FINISH_T, "Date and time last part tested"),
    DISP_COD(C1, null, false, C1_t.DISP_COD, "Lot disposition code"),
    USR_DESC(CN, null, false, CN_t.USR_DESC, "Lot description supplied by user"),
    EXC_DESC(CN, null, false, CN_t.EXC_DESC, "Lot description supplied by exec");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private MRR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.FieldType;
import com.makechip.stdf2xls4.stdf.enums.types.U1_t;
import com.makechip.stdf2xls4.stdf.enums.types.U4_t;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PCR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number"),
    PART_CNT(U4, null, true, U4_t.PART_CNT, "Number of parts tested"),
    RTST_CNT(U4, null, false, U4_t.RTST_CNT, "Number of parts retested"),
    ABRT_CNT(U4, null, false, U4_t.ABRT_CNT, "Number of aborts during testing"),
    GOOD_CNT(U4, null, false, U4_t.GOOD_CNT, "Number of good (passed) parts tested"),
    FUNC_CNT(U4, null, false, U4_t.FUNC_CNT, "Number of functional parts tested");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PCR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U2;

import com.makechip.stdf2xls4.stdf.enums.types.CN_t;
import com.makechip.stdf2xls4.stdf.enums.types.FieldType;
import com.makechip.stdf2xls4.stdf.enums.types.U2Array_t;
import com.makechip.stdf2xls4.stdf.enums.types.U2_t;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PGR_t implements FieldDescriptor
{
    GRP_INDX(U2, null, true, U2_t.GRP_INDX, "Unique index associated with pin group"),
    GRP_NAM(CN,  null, true, CN_t.GRP_NAM, "Name of pin group"),
    INDX_CNT(U2, null, true, U2_t.INDX_CNT, "Count(k) of PMR indexes"),
    PMR_INDX(U2, INDX_CNT, false, U2Array_t.PMR_INDX, "Array of indexes for  pins in the group");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PGR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;

import com.makechip.stdf2xls4.stdf.enums.types.FieldType;
import com.makechip.stdf2xls4.stdf.enums.types.U1_t;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PIR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PIR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U2;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PLR_t implements FieldDescriptor
{
    GRP_CNT(U2, null, true, U2_t.GRP_CNT, "Count (k) og pins or pin groups"),
    GRP_INDX(U2, GRP_CNT, true, U2Array_t.GRP_INDX, "Array of pin or pin group indexes"),
    GRP_MODE(U2, GRP_CNT, false, U2Array_t.GRP_MODE, "Operating mode of pin group"),
    GRP_RADX(U1, GRP_CNT, false, U1Array_t.GRP_RADX, "Display radix of pin group"),
    PGM_CHAR(CN, GRP_CNT, false, CNArray_t.PGM_CHAR, "Program state encoding characters"),
    RTN_CHAR(CN, GRP_CNT, false, CNArray_t.RTN_CHAR, "Return state encoding characters"),
    PGM_CHAL(CN, GRP_CNT, false, CNArray_t.PGM_CHAL, "Program state encoding characters"),
    RTN_CHAL(CN, GRP_CNT, false, CNArray_t.RTN_CHAL, "Return state encoding characters");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PLR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U2;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PMR_t implements FieldDescriptor
{
    PMR_INDX(U2, null, true, U2_t.PMR_INDX, "Unique index associated with pin"),
    CHAN_TYP(U2, null, false, U2_t.CHAN_TYP, "Channel type"),
    CHAN_NAM(CN, null, false, CN_t.CHAN_NAM, "Channel name"),
    PHY_NAM(CN,  null, false, CN_t.PHY_NAM, "Physical name of pin"),
    LOG_NAM(CN,  null, false, CN_t.LOG_NAM, "Logical name of pin"),
    HEAD_NUM(U1, null, false, U1_t.HEAD_NUM, "Head number associated with channel"),
    SITE_NUM(U1, null, false, U1_t.SITE_NUM, "Site number associated with channel");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PMR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.B1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.BN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.I2;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U2;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PRR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number"),
    PART_FLG(B1, null, true, B1_t.PART_FLG, "Part information flag"),
    NUM_TEST(U2, null, true, U2_t.NUM_TEST, "Number of tests executed"),
    HARD_BIN(U2, null, true, U2_t.HARD_BIN, "Hardware bin number"),
    SOFT_BIN(U2, null, false, U2_t.SOFT_BIN, "Software bin number"),
    X_COORD(I2,  null, false, I2_t.X_COORD, "(Wafer) X coordinate"),
    Y_COORD(I2,  null, false, I2_t.Y_COORD, "(Wafer) Y coordinate"),
    TEST_T(U4,   null, false, U4_t.TEST_T, "Elapsed test time in milliseconds"),
    PART_ID(CN,  null, false, CN_t.PART_ID, "Part identification"),
    PART_TXT(CN, null, false, CN_t.PART_TXT, "Part description text"),
    PART_FIX(BN, null, false, BN_t.PART_FIX, "Part repair information");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PRR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.B1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.I1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.R4;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum PTR_t implements FieldDescriptor
{
    TEST_NUM(U4, null, true, U4_t.TEST_NUM, "Test number"),
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number"),
    TEST_FLG(B1, null, true, B1_t.TEST_FLG, "Test flags"),
    PARM_FLG(B1, null, true, B1_t.PARM_FLG, "Parametric flags (drift, etc.)"),
    RESULT(R4,   null, false, R4_t.RESULT, "Test result"),
    TEST_TXT(CN, null, false, CN_t.TEST_TXT, "Test description text or label"),
    ALARM_ID(CN, null, false, CN_t.ALARM_ID, "Name of alarm"),
    OPT_FLAG(B1, null, false, B1_t.OPT_FLAG, "Optional data flag"),
    RES_SCAL(I1, null, false, I1_t.RES_SCAL, "Test results scaling exponent"),
    LLM_SCAL(I1, null, false, I1_t.LLM_SCAL, "Low limit scaling exponent"),
    HLM_SCAL(I1, null, false, I1_t.HLM_SCAL, "High limit scaling exponent"),
    LO_LIMIT(R4, null, false, R4_t.LO_LIMIT, "Low test limit value"),
    HI_LIMIT(R4, null, false, R4_t.HI_LIMIT, "High test limit value"),
    UNITS(CN,    null, false, CN_t.UNITS, "Test units"),
    C_RESFMT(CN, null, false, CN_t.C_RESFMT, "ANSI C result format string"),
    C_LLMFMT(CN, null, false, CN_t.C_LLMFMT, "ANSI C low limit format string"),
    C_HLMFMT(CN, null, false, CN_t.C_HLMFMT, "ANSI C high limit format string"),
    LO_SPEC(R4,  null, false, R4_t.LO_SPEC, "Low specification limit value"),
    HI_SPEC(R4,  null, false, R4_t.HI_SPEC, "High specification limit value");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private PTR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.U2;

import com.makechip.stdf2xls4.stdf.enums.types.FieldType;
import com.makechip.stdf2xls4.stdf.enums.types.U2Array_t;
import com.makechip.stdf2xls4.stdf.enums.types.U2_t;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum RDR_t implements FieldDescriptor
{
    NUM_BINS(U2, null, true, U2_t.NUM_BINS, "Number (k) of bins being retested"),
    RTST_BIN(U2, NUM_BINS, false, U2Array_t.RTST_BIN, "Array of retest bin numbers");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private RDR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.C1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U2;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum SBR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number"),
    SBIN_NUM(U2, null, true, U2_t.SBIN_NUM, "Software bin number"),
    SBIN_CNT(U4, null, true, U4_t.SBIN_CNT, "Number of parts in bin"),
    SBIN_PF(C1,  null, false, C1_t.SBIN_PF, "Pass/fail indication"),
    SBIN_NAM(CN, null, false, CN_t.SBIN_NAM, "Name of software bin");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private SBR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum SDR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_GRP(U1, null, true, U1_t.SITE_NUM, "Site group number"),
    SITE_CNT(U1, null, true, U1_t.SITE_CNT, "Number (k) of test sites in site group"),
    SITE_NUM(U1, SITE_CNT, true, U1Array_t.SITE_NUM, "Array of test site numbers"),
    HAND_TYP(CN, null, false, CN_t.HAND_TYP, "Handler or prober type"),
    HAND_ID(CN,  null, false, CN_t.HAND_ID, "Handler or prober ID"),
    CARD_TYP(CN, null, false, CN_t.CARD_TYP, "Probe card type"),
    CARD_ID(CN,  null, false, CN_t.CARD_ID, "Probe card ID"),
    LOAD_TYP(CN, null, false, CN_t.LOAD_TYP, "Loadboard type"),
    LOAD_ID(CN,  null, false, CN_t.LOAD_ID, "Loadboard ID"),
    DIB_TYP(CN,  null, false, CN_t.DIB_TYP, "DIB board type"),
    DIB_ID(CN,   null, false, CN_t.DIB_ID, "DIB board ID"),
    CABL_TYP(CN, null, false, CN_t.CABL_TYP, "Interface cable type"),
    CABL_ID(CN,  null, false, CN_t.CABL_ID, "Interface cable ID"),
    CONT_TYP(CN, null, false, CN_t.CONT_TYP, "Handler contactor type"),
    CONT_ID(CN,  null, false, CN_t.CONT_ID, "Handler contactor ID"),
    LASR_TYP(CN, null, false, CN_t.LASR_TYP, "Laser type"),
    LASR_ID(CN,  null, false, CN_t.LASR_ID, "Laser ID"),
    EXTR_TYP(CN, null, false, CN_t.EXTR_TYP, "Extra equipment type field"),
    EXTR_ID(CN,  null, false, CN_t.EXTR_ID, "Extra equipment ID");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private SDR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.B1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.C1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.R4;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum TSR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_NUM(U1, null, true, U1_t.SITE_NUM, "Test site number"),
    TEST_TYP(C1, null, true, C1_t.TEST_TYP, "Test type"),
    TEST_NUM(U4, null, true, U4_t.TEST_NUM, "Test number"),
    EXEC_CNT(U4, null, false, U4_t.EXEC_CNT, "Number of test executions"),
    FAIL_CNT(U4, null, false, U4_t.FAIL_CNT, "Number of test failures"),
    ALRM_CNT(U4, null, false, U4_t.ALRM_CNT, "Number of alarmed tests"),
    TEST_NAM(CN, null, false, CN_t.TEST_NAM, "Test name"),
    SEQ_NAME(CN, null, false, CN_t.SEQ_NAME, "Sequencer (program segment/flow) name"),
    TEST_LBL(CN, null, false, CN_t.TEST_LBL, "Test label or text"),
    OPT_FLAG(B1, null, false, B1_t.OPT_FLAG, "Optional data flag"),
    TEST_TIM(R4, null, false, R4_t.TEST_TIM, "Average test execution time in seconds"),
    TEST_MIN(R4, null, false, R4_t.TEST_MIN, "Lowest test result value"),
    TEST_MAX(R4, null, false, R4_t.TEST_MAX, "Highest test result value"),
    TST_SUMS(R4, null, false, R4_t.TST_SUMS, "Sum of test result values"),
    TST_SQRS(R4, null, false, R4_t.TST_SQRS, "Sum of squares of test result values");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private TSR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.C1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.I2;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.R4;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum WCR_t implements FieldDescriptor
{
    WAFR_SIZ(R4, null, false, R4_t.WAFR_SIZ, "Diameter of wafer"),
    DIE_HT(R4,   null, false, R4_t.DIE_HT, "Height of die"),
    DIE_WID(R4,  null, false, R4_t.DIE_WID, "Width of die"),
    WF_UNITS(U1, null, false, U1_t.WF_UNITS, "Units for wafer and die dimensions"),
    WF_FLAT(C1,  null, false, C1_t.WF_FLAT, "Orientation of wafer flat"),
    CENTER_X(I2, null, false, I2_t.CENTER_X, "X coordinate of center die on wafer"),
    CENTER_Y(I2, null, false, I2_t.CENTER_Y, "Y coordinate of center die on wafer"),
    POS_X(C1,    null, false, C1_t.POS_X, "Positive X direction on wafer"),
    POS_Y(C1,    null, false, C1_t.POS_Y, "Positive Y direction on wafer");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private FieldType kind;

    private WCR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.CN_t;
import com.makechip.stdf2xls4.stdf.enums.types.FieldType;
import com.makechip.stdf2xls4.stdf.enums.types.U1_t;
import com.makechip.stdf2xls4.stdf.enums.types.U4_t;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum WIR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_GRP(U1, null, true, U1_t.SITE_GRP, "Site group number"),
    START_T(U4,  null, true, U4_t.START_T, "Date and time first part tested"),
    WAFER_ID(CN, null, false, CN_t.WAFER_ID, "Wafer ID");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private WIR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.description = description;
        this.kind = kind;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

package com.makechip.stdf2xls4.stdf.enums.descriptors;

import static com.makechip.stdf2xls4.stdf.enums.Data_t.CN;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U1;
import static com.makechip.stdf2xls4.stdf.enums.Data_t.U4;

import com.makechip.stdf2xls4.stdf.enums.types.*;
import com.makechip.stdf2xls4.stdf.enums.Data_t;

public enum WRR_t implements FieldDescriptor
{
    HEAD_NUM(U1, null, true, U1_t.HEAD_NUM, "Test head number"),
    SITE_GRP(U1, null, true, U1_t.SITE_GRP, "Site group number"),
    FINISH_T(U4, null, true, U4_t.FINISH_T, "Date and time last part tested"),
    PART_CNT(U4, null, true, U4_t.PART_CNT, "Number of parts tested"),
    RTST_CNT(U4, null, false, U4_t.RTST_CNT, "Number of parts retested"),
    ABRT_CNT(U4, null, false, U4_t.ABRT_CNT, "Number of aborts during testing"),
    GOOD_CNT(U4, null, false, U4_t.GOOD_CNT, "Number of good (passed) parts tested"),
    FUNC_CNT(U4, null, false, U4_t.FUNC_CNT, "Number of functional parts tested"),
    WAFER_ID(CN, null, false, CN_t.WAFER_ID, "Wafer ID"),
    FABWF_ID(CN, null, false, CN_t.FABWF_ID, "Fab wafer ID"),
    FRAME_ID(CN, null, false, CN_t.FRAME_ID, "Wafer frame ID"),
    MASK_ID(CN,  null, false, CN_t.MASK_ID, "Wafer mask ID"),
    USR_DESC(CN, null, false, CN_t.USR_DESC, "Wafer description supplied by user"),
    EXC_DESC(CN, null, false, CN_t.EXC_DESC, "Wafer description supplied by exec");

    private final Data_t type;
    private final boolean required;
    private final String description;
    private final FieldDescriptor countField;
    private final FieldType kind;

    private WRR_t(Data_t type, FieldDescriptor countField, boolean required, FieldType kind, String description)
    {
        this.type = type;
        this.required = required;
        this.countField = countField;
        this.kind = kind;
        this.description = description;
    }

	@Override
    public Data_t getType()         { return(type); }
	@Override
    public boolean isRequired()     { return(required); }
	@Override
    public String getDescription()  { return(description); }
	@Override
    public FieldDescriptor getCountField() { return(countField); }
	@Override
	public FieldType getKind() { return(kind); }
}

