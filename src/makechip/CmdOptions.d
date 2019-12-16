module makechip.CmdOptions;
import makechip.Stdf;
import makechip.StdfDB;
import makechip.Descriptors;
import std.conv;
import std.stdio;
import std.traits;
import std.getopt;
import std.typecons;

class StringTokenizer
{
    private string s;
    private uint p;

    this(string s)
    {
        this.s = s;
        p = 0;
    }

    string nextToken()
    {
        bool inQuote = false;
        if (p == s.length + 1) return(null);
        if (p != 0) p++;
        uint start = p;
        while (p < s.length && ((s[p] != ' ' && s[p] != '\t') || inQuote))
        {
            if (s[p] == '"') inQuote = !inQuote;
            p++;
        }
        return(s[start .. p]);
    }

    bool hasMoreTokens() { return(p < s.length - 1); }
}

class Modifier
{
    const Record_t recordType;
    const string fieldName;
    const string regexp;
    const string repl;

    this(Record_t recordType, string fieldName, string regexp, string repl)
    {
        this.recordType = recordType;
        this.fieldName = fieldName;
        this.regexp = regexp;
        this.repl = repl;
    }
}

import std.regex;
import makechip.StdfFile;
class Options
{
    bool textDump = false;
    bool byteDump = false;
    bool extractPin = false;
    bool verifyWrittenStdf = false;
    bool noIgnoreMiscHeader = false;
    private string[] modify;
    PMRNameType channelType = PMRNameType.AUTO;
    int verbosityLevel = 0;
    string outputDir = "";

    string[] stdfFiles;
    Modifier[] modifiers;
    char[] delims;

    bool success;

    this(string[] args)
    {
        success = true;
        modifiers = null;
        auto rslt = getopt(args,
            std.getopt.config.caseSensitive,
            std.getopt.config.passThrough,
            "dumptext|d", "dump the STDF in text form", &textDump,
            "dumpBytes|b", "dump the STDF in ascii byte form", &byteDump,
            "modify|m", "modify a string field in specified record type.\n     Example: -m 'MIR TST_TEMP \"TEMPERATURE :\" \"TEMPERATURE:\"'", &modify,
            "outputDir|o", "write out the STDF to this directory. Specifying this will cause the STDF to be written back out.", &outputDir,

            "channel-type|t", "Channel type: AUTO, CHANNEL, PHYSICAL, or LOGICAL. Only use this if you know what you are doing.", &channelType,
            "extract-pin|a", "Extract pin name from test name suffix (default delimiter = '@')", &extractPin,
            "pin-delimiter|p", "Delimiter character that separates pin name from test name (Default = '@')", &delims,
            "verbose|v", "Verbosity level. Default is 0 which means print nothing", &verbosityLevel,
            "verify|V", "Verify written STDF; only useful if --outputDir is specified. For testing purposes only.", &verifyWrittenStdf,
            "noIgnoreMiscHeader", "Don't ignore custom user header items when comparing headers from different STDF files", &noIgnoreMiscHeader);
        if (delims.length == 0) delims ~= '@';
        stdfFiles.length = args.length-1;
        for (int i=1; i<args.length; i++) stdfFiles[i-1] = args[i];
        if (rslt.helpWanted)
        {
            defaultGetoptPrinter("Options:", rslt.options);
            success = false;
            return;
        }
        foreach(m; modify)
        {
            auto st = new StringTokenizer(m);
            string rec;
            string field;
            string reg;
            string repl;
            if (st.hasMoreTokens())
            {
                rec = st.nextToken();
                if (st.hasMoreTokens())
                {
                    field = st.nextToken();
                    if (st.hasMoreTokens())
                    {
                        reg = st.nextToken();
                        if (st.hasMoreTokens())
                        {
                            repl = st.nextToken();
                        }
                        else
                        {
                            writeln("Error: modifier missing repl string");
                            success = false;
                        }
                    }
                    else
                    {
                        writeln("Error: modifier missing regex string");
                        success = false;
                    }
                }
                else
                {
                    writeln("Error: modifier missing field name");
                    success = false;
                }
            }
            else
            {
                writeln("Error: missing modifier");
                success = false;
            }
            auto re = regex("\"");
            string regexp = replaceAll(reg, re, "");
            string replace = replaceAll(repl, re, "");
            try 
            { 
                Record_t type = RecordType.getRecordType(rec);
                switch (type.ordinal)
                {    
                    case Record_t.ATR.ordinal:  if (field != "CMD_LINE") 
                                                {
                                                    writeln(field, " is not a CN field of Audit Trail Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.BPS.ordinal:  if (field != "SEQ_NAME")
                                                {
                                                    writeln(field, " is not a CN field of Begin Program Section Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.DTR.ordinal:  if (field != "TEXT_DAT")
                                                {
                                                    writeln(field, " is not a CN field of Begin Program Section Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.EPS.ordinal:  writeln(field, " is not a CN field of End Program Section Record");
                                                success = false;
                                                break;
                    case Record_t.FAR.ordinal:  writeln(field, " is not a CN field of Field Attributes Record");
                                                success = false;
                                                break;
                    case Record_t.FTR.ordinal:  if (field != "VECT_NAM" && field != "TIME_SET" && field != "OP_CODE" && field != "TEST_TXT" &&
                                                    field != "ALARM_ID" && field != "PROG_TXT" && field != "RSLT_TXT")
                                                {
                                                    writeln(field, " is not a CN field of Functional Test Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.GDR.ordinal:  writeln("field modification of Generic Data Records not supported");
                                                success = false;
                                                break;
                    case Record_t.HBR.ordinal:  if (field != "HBIN_NAM")
                                                {
                                                    writeln(field, " is not a CN field of Hardware Bin Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.MIR.ordinal:  if (field != "LOT_ID" && field != "PART_TYP" && field != "NODE_NAM" &&
                                                    field != "TSTR_TYP" && field != "JOB_NAM" && field != "JOB_REV" && 
                                                    field != "SBLOT_ID" && field != "OPER_NAM" && field != "EXEC_TYP" && 
                                                    field != "EXEC_VER" && field != "TEST_COD" && field != "TST_TEMP" && 
                                                    field != "USER_TXT" && field != "AUX_FILE" && field != "PKG_TYP" &&
                                                    field != "FAMLY_ID" && field != "DATE_COD" && field != "FACIL_ID" && 
                                                    field != "FLOOR_ID" && field != "PROC_ID" && field != "OPER_FRQ" && 
                                                    field != "SPEC_NAM" && field != "SPEC_VER" && field != "FLOW_ID" && 
                                                    field != "SETUP_ID" && field != "DSGN_REV" && field != "ENG_ID" &&
                                                    field != "ROM_COD" && field != "SERL_NUM" && field != "SUPR_NAM")
                                                {
                                                    writeln(field, " is not a CN field of Master Information Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.MPR.ordinal:  if (field != "TEST_TXT" && field != "ALARM_ID" && field != "UNITS" && field != "C_RESFMT" &&
                                                    field != "C_LLMFMT" && field != "UNITS_IN" && field != "C_HLMFMT")
                                                {
                                                    writeln(field, " is not a CN field of Multiple-Result Parametric Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.MRR.ordinal:  if (field != "USR_DESC" && field != "EXC_DESC")
                                                {
                                                    writeln(field, " is not a CN field of Master Results Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.PCR.ordinal:  writeln(field, " is not a CN field of Part Count Record");
                                                success = false;
                                                break;
                    case Record_t.PGR.ordinal:  if (field != "GRP_NAM")
                                                {
                                                    writeln(field, " is not a CN field of Pin Group Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.PIR.ordinal:  writeln(field, " is not a CN field of Part Information Record");
                                                success = false;
                                                break;
                    case Record_t.PLR.ordinal:  if (field != "PGM_CHAR" && field != "RTN_CHAR" && field != "PGM_CHAL" && field != "RTN_CHAL")
                                                {
                                                    writeln(field, " is not a CN field of Pin List Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.PMR.ordinal:  if (field != "CHAN_NAM" && field != "PHY_NAM" && field != "LOG_NAM")
                                                {
                                                    writeln(field, " is not a CN field of Pin Map Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.PRR.ordinal:  if (field != "PART_ID" && field != "PART_TXT")
                                                {
                                                    writeln(field, " is not a CN field of Part Results Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.PTR.ordinal:  if (field != "TEST_TXT" && field != "ALARM_ID" && field != "UNITS" && 
                                                    field != "C_RESFMT" && field != "C_LLMFMT" && field != "C_HLMFMT")
                                                {
                                                    writeln(field, " is not a CN field of Parametric Test Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.RDR.ordinal:  writeln(field, " is not a CN field of Retest Data Record");
                                                success = false;
                                                break;
                    case Record_t.SBR.ordinal:  if (field != "SBIN_NAM")
                                                {
                                                    writeln(field, " is not a CN field of Software Bin Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.SDR.ordinal:  if (field != "HAND_TYP" && field != "HAND_ID" && field != "CARD_TYP" &&
                                                    field != "CARD_ID" && field != "LOAD_TYP" && field != "LOAD_ID" &&
                                                    field != "DIB_TYP" && field != "DIB_ID" && field != "CABL_TYP" &&
                                                    field != "CABL_ID" && field != "CONT_TYP" && field != "CONT_ID" &&
                                                    field != "LASR_TYP" && field != "LASR_ID" && field != "EXTR_TYP" && field != "EXTR_ID")
                                                {
                                                    writeln(field, " is not a CN field of Site Description Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.TSR.ordinal:  if (field != "TEST_NAM" && field != "SEQ_NAME" && field != "TEST_LBL")
                                                {
                                                    writeln(field, " is not a CN field of Test Synopsis Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.WCR.ordinal:  writeln(field, " is not a CN field of Wafer Configuration Record");
                                                success = false;
                                                break;
                    case Record_t.WIR.ordinal:  if (field != "WAFER_ID")
                                                {
                                                    writeln(field, " is not a CN field of Wafer Information Record");
                                                    success = false;
                                                }
                                                break;
                    case Record_t.WRR.ordinal:  if (field != "WAFER_ID" && field != "FABWF_ID" && field != "FRAME_ID" &&
                                                    field != "MASK_ID" && field != "USR_DESC" && field != "EXC_DESC")
                                                {
                                                    writeln(field, " is not a CN field of Wafer Results Record");
                                                    success = false;
                                                }
                                                break;
                    default: throw new Exception("This bug can't happen: " ~ type.stringof);
                }    
                modifiers ~= new Modifier(type, field, regexp, replace);
            }
            catch (Exception e)
            {
                writeln("Unknow record type: ", rec);
                success = false;
            }
        }       
    }
}
