module itestinc.CmdOptions;
import itestinc.Stdf;
import itestinc.StdfDB;
import itestinc.Descriptors;
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

enum Sort_t
{
    SN_UP_TIME_UP_NO_DUPS,
    SN_DOWN_TIME_UP_NO_DUPS,
    SN_UP_TIME_DOWN_NO_DUPS,
    SN_DOWN_TIME_DOWN_NO_DUPS,
    SNN_UP_TIME_UP_NO_DUPS,
    SNN_DOWN_TIME_UP_NO_DUPS,
    SNN_UP_TIME_DOWN_NO_DUPS,
    SNN_DOWN_TIME_DOWN_NO_DUPS,
    TIME_UP_SN_UP_NO_DUPS,
    TIME_UP_SN_DOWN_NO_DUPS,
    TIME_DOWN_SN_UP_NO_DUPS,
    TIME_DOWN_SN_DOWN_NO_DUPS,
    TIME_UP_SNN_UP_NO_DUPS,
    TIME_UP_SNN_DOWN_NO_DUPS,
    TIME_DOWN_SNN_UP_NO_DUPS,
    TIME_DOWN_SNN_DOWN_NO_DUPS,
    SN_UP_TIME_UP,
    SN_DOWN_TIME_UP,
    SN_UP_TIME_DOWN,
    SN_DOWN_TIME_DOWN,
    SNN_UP_TIME_UP,
    SNN_DOWN_TIME_UP,
    SNN_UP_TIME_DOWN,
    SNN_DOWN_TIME_DOWN,
    TIME_UP_SN_UP,
    TIME_UP_SN_DOWN,
    TIME_DOWN_SN_UP,
    TIME_DOWN_SN_DOWN,
    TIME_UP_SNN_UP,
    TIME_UP_SNN_DOWN,
    TIME_DOWN_SNN_UP,
    TIME_DOWN_SNN_DOWN
}

enum BinCategory_t
{
    NONE,
    SITE,
    LOT,
    TEMP
}


enum WafermapFormat_t {
    ASY,
    SINF,
    SINF_SENTONS,
    MICROSOFT
}


import std.regex;
import itestinc.StdfFile;
class CmdOptions
{
    public static immutable string stdf2xlsx_version = "5.0.1";
    string[] files;     // output filenames with full path prefix
    string[] paths;     // list of paths in which to search for files with wildcard match
    ulong p = 0;
    ulong f = 0;
    bool _debug = false;
    bool textDump = false;
    bool byteDump = false;
    bool extractPin = true;
    bool verifyWrittenStdf = false;
    bool noIgnoreMiscHeader = false;
    bool summarize = false;
    bool genSpreadsheet = false;
    bool genWafermap = false;
    bool genHistogram = false;
    bool rotate = false;
    bool ignoreSerialMarker = false;
    bool generateRC = false;
    bool limit1k = false;
    bool noDynamicLimits = false;
    bool dumpAscii = false;
    bool forceWafer = false;
    WafermapFormat_t wformat = WafermapFormat_t.ASY;
    bool pattern = false;
    bool showNum = false;
    int rotateWafer = 0;
    uint binCount = 0;
    double cutoff = 2.0;
    Sort_t sortType = Sort_t.SN_UP_TIME_UP; 
    private string[] modify;
    PMRNameType channelType = PMRNameType.AUTO;
    uint verbosityLevel = 1;
    string outputDir = "";
    string sfile = "%device%_%lot%.xlsx";
    string hfile = "%device%_histograms.xlsx";
    string wfile = "%device%_%lot%_%wafer%.xlsx";
    BinCategory_t category = BinCategory_t.NONE;
    const string options;
    
    string[] stdfFiles;
    Modifier[] modifiers;
    char[] delims;

    bool success;

    version(Windows)
    {
            /**
             * getFiles()
             * in:
             fileWild = file name with a wildcard inside
             paths = path names in which to find files
             **/
            void getFiles(string fileWild, string[] paths)
            {
                    foreach(path; paths)
                    {
                            string[] fnames = expandToMatchingFiles(fileWild, path);
                            //if(_debug) writeln("fnames = ", fnames);

                            foreach(fn; fnames)
                            {
                                    files.length++;
                                    files[cast(uint)f] = path ~ fn;
                                    f++;
                            }

                    }
            }

            /**
             * goDeeper()
             * in:
             index = index number of directory level where there is a wildcard
             base = base path before first wildcard
             dirs = array of directory levels
             adirs = array of directories that match wildcard
             **/
            void goDeeper(ulong index, string base, string[] dirs, string[] adirs)
            {
                    import std.path : dirSeparator;

                    index += 1;
                    if(_debug)  writeln("index = ", index);

                    if(index <= dirs.length - 1)
                    {
                            string wildcard = dirs[cast(uint)index];
                            if(_debug)  writeln("wildcard = ", wildcard);
                            foreach(ad; adirs)
                            {
                                    string newbase = base ~ ad ~ dirSeparator;
                                    if(_debug)  writeln("newbase = ", newbase);
                                    string[] newadirs = expandToMatchingDirs(wildcard, newbase);
                                    if(_debug)  writeln("newadirs = ", newadirs);

                                    if(index < dirs.length - 1)
                                    {
                                            goDeeper(index, newbase, dirs, newadirs);
                                    }
                                    else
                                    {
                                            //save path
                                            foreach(newad; newadirs)
                                            {
                                                    paths.length++;
                                                    paths[cast(uint)p] = newbase ~ newad ~ dirSeparator;
                                                    p++;
                                            }
                                    }
                            }
                    }
                    else    // only 1 deep
                    {
                            foreach(ad; adirs)
                            {
                                    paths.length++;
                                    paths[cast(uint)p] = base ~ ad ~ dirSeparator;
                                    p++;
                            }
                    }

            }

            /**
             * findWildcard()
             * in: array of directory levels
             * out: index of first wildcard inside dirs array
             **/
            ulong findWildcard(string[] dirs)
            {
                    import std.algorithm;
                    auto wildcards = ["*", "[", "]", "?"];
                    foreach(i, d; dirs)
                    {
                            foreach(wc; wildcards)
                            {
                                    if(canFind(d, wc))
                                    {
                                            return i;
                                    }
                            }
                    }
                    return -1;
            }

            /**
             * expandToMatchingDirs()
             * in: wildcard, path on wildcard's level
             * out: list of directories that match
             **/
            string[] expandToMatchingDirs(string wildcard, string base)
            {
                    import std.algorithm;
                    import std.algorithm : filter, map;
                    import std.path : dirSeparator, baseName;
                    import std.file : dirEntries, SpanMode;
                    import std.array;

                    return dirEntries(base, wildcard, SpanMode.shallow)     //get matching dirs without the preceding path (built-in globMatch)
                            .filter!(a => a.isDir)
                            .map!(a => baseName(a.name))
                            .array;   // convert from map to string array
            }

            /**
             * expandToMatchingFiles()
             * in: wildcard, path on wildcard's level
             * out: list of files that match
             **/
            string[] expandToMatchingFiles(string wildcard, string base)
            {
                    import std.path : dirSeparator, baseName;
                    import std.file : dirEntries, SpanMode;
                    import std.algorithm;
                    import std.algorithm : filter, map;
                    import std.array;

                    if(_debug) writeln("wildcard = ", wildcard);
                    return dirEntries(base, wildcard, SpanMode.shallow)
                            .map!(a => baseName(a.name))
                            .array;   // convert from map to string array
            }
    }
    this(string[] args)
    {
        success = true;
        modifiers = null;
        string[] optargs = args.dup;
        auto rslt = getopt(args,
            std.getopt.config.caseSensitive,
            std.getopt.config.passThrough,
            "extract-pin|a", "Extract pin name from test name suffix (default delimiter = '@')", &extractPin,
            "dumpBytes|b", "dump the STDF in ascii byte form", &byteDump,
            "dumptext|d", "dump the STDF in text form", &textDump,
            "modify|m", "modify a string field in specified record type.\n     Example: -m 'MIR TST_TEMP \"TEMPERATURE :\" \"TEMPERATURE:\"'", &modify,
            "outputDir|o", "write out the STDF to this directory. Specifying this will cause the STDF to be written back out.", &outputDir,
            "pin-delimiter|p", "Delimiter character that separates pin name from test name (Default = '@')", &delims,
            "ignoreSerialMarker|i", "Ignore the serial marker and use STDF part ID instead", &ignoreSerialMarker,
            "digest|D", "Summarize file contents", &summarize,

            "genSpreadsheets|s", "Generate spreadsheet(s)", &genSpreadsheet,
            "so|S", "Spreadsheet output filename(s); name may contain variables for device, and/or lot\nDefault = %device%_%lot%.xlsx", &sfile,
            "rotate|r", "Transpose spreadsheet so there is one device per column instead of one device per row", &rotate,
            "sortType", "Specify device sort order: Default: by alphanumeric serial number, then by time. See the manual for valid sort types", &sortType,
            "1kcol|c", "limit to 1000 columns for libreoffice - default is 16360 columns", &limit1k,
            "noDynamicLimits|Y", "Don't check for and show dynamic limits", &noDynamicLimits,
            "forceWafer|F", "Force wafersort in case wafer ID is missing", &forceWafer,

            "genWafermaps|w", "Generate wafer map(s)", &genWafermap,
            "wo|W", "Wafermap output filename(s); name may contain variables for device, wafer, and/or lot\nDefault = %device%_%lot%_%wafer%.xlsx", &wfile,
            "dumpAscii|A", "dump the wafer map in ASCII form", &dumpAscii,
            "wformat|f", "Specify the wafermap format for the ASCII dump (default:ASY)", &wformat,
            "pattern|P", "fill wafermap bins with patterns instead of colors", &pattern,
            "rotateWafer|R", "Rotate the wafer map clockwise in degrees: +/- 0|90|180|270", &rotateWafer,
            "showNum|N", "Show the bin numbers on the wafer map, along with colors or patterns.", &showNum,

            "genHistograms|h", "Generate histogram(s)", &genHistogram,
            "ho|H", "Histogram output filename(s); name may contain variables for device, step, lot, and/or testID\nDefault = %device%_histograms.pdf", &hfile,
            "binCategory", "Specify if bins should be divided by SITE, LOT, TEMPerature or NONE. Default = NONE\nNote: if --ho contains %lot% then dividing bins by lot does not make sense", &category,
            "manualBins|B", "Manually set the number of bins across all histograms. Set to 0 (zero) for automatic.", &binCount,
            "cutOutlier|C", "Define how much of the outliers to cut off, in terms of standard deviation. Set to 0 (zero) for no cutoff.", &cutoff,

            "generateRCFile|g", "Generate a default \".stdf2xlsxrc\" file", &generateRC,
            "channel-type|t", "Channel type: AUTO, CHANNEL, PHYSICAL, or LOGICAL. Only use this if you know what you are doing.", &channelType,
            "verbose|v", "Verbosity level. Default is 1 which means print only warnings.  0 means don't print anything", &verbosityLevel,
            "verify|V", "Verify written STDF; only useful if --outputDir is specified. For testing purposes only.", &verifyWrittenStdf,
            "noIgnoreMiscHeader", "Don't ignore custom user header items when comparing headers from different STDF files", &noIgnoreMiscHeader);
        if (delims.length == 0) delims ~= '@';
        stdfFiles.length = args.length-1;
        if (args.length > 1)
        {
            string firstNonOpt = args[1];
            string opts;
            for (int i=1; i<optargs.length; i++)
            {
                if (optargs[i] == firstNonOpt) break;
                opts ~= optargs[i] ~ " ";
            }
            options = opts;
        }
        for (int i=1; i<args.length; i++) stdfFiles[i-1] = args[i];
        version(Windows)
        {
            import std.string;
            import std.range;
            import std.algorithm;
            writeln("processing wildcards");
            foreach(i, arg; stdfFiles)
            {
                writeln("arg = ", arg);
                //if (i == 0) continue;
                import std.path : baseName, dirName, absolutePath, asNormalizedPath, driveName, stripDrive, dirSeparator;
                string dirSep = dirSeparator;
                string fname = baseName(arg);
                string path = dirName(arg);
                path = absolutePath(path);
                path = to!string(asNormalizedPath(path));
                string drive = driveName(path);
                path = stripDrive(path);
                if(_debug) writeln("drive = ", drive, " path = ", path, " fname = ", fname);
                if(_debug) writeln("dirSep = ", dirSep);
                // first expand wildcards in path and build a list of paths
                string[] dirs = split(path, dirSep);
                // dirs now has all path elements; now expand their wild cards (if any)
                string[] allPaths;
                if(_debug)  writeln("dirs = ", dirs);
                if(_debug) writeln("dirs length = ", dirs.length);

                ulong index = findWildcard(dirs);
                if(_debug) writeln("index = ",  index);

                if(index == -1)     // no wildcard
                {
                    paths.length++;
                    paths[0] = drive ~ path ~ dirSeparator;
                    if(_debug) writeln("paths = ", paths);
                }
                else
                {
                    string wildcard = dirs[cast(uint)index];
                    if(_debug) writeln("wildcard = ", wildcard);
                    string base = drive;
                    for(int j = 0; j < index; j++)
                    {
                        base ~= dirs[j] ~ dirSeparator;
                    }
                    if(_debug) writeln("base = ", base);

                    string[] adirs = expandToMatchingDirs(wildcard, base);
                    if(_debug) writeln("adirs = ", adirs);

                    goDeeper(index, base, dirs, adirs);
                    if(_debug) writeln("paths = ", paths);
                }

                getFiles(fname, paths);
                if(_debug) writeln("files = ", files);

            }
            //if(_debug) writeln("files.length = ", files.length);
            foreach(f; files) writeln(f);
            stdfFiles = files;
        }
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
