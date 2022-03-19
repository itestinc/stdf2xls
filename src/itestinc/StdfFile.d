/**
    Initial sequence = FAR ATR* MIR RDR? SDR*

    STDF Records and locations within a file:
    FAR - first record of file - ocurrences 1
    ATR - right after FAR - occurences 0 to n
    MIR - after FAR and ATRs - occurences 1
    MRR - last record of stream - occurences 1
    PCR - after initial sequence, and before MRR - occurences 1 or 1 per head or site
    HBR - after initial sequence and before MRR - occurences 1 per hardware bin per site
    SBR - after initial sequence and before MRR - occurences 1 per software bin per site
    PMR - after initial sequence and before first PGR, PLR, FTR, or MPR - occurences 1 or more
    PGR - after PMRs and before first PLR - occurences 0 or more
    PLR - after PGRs - occurences 0 or more
    RDR - after MIR - occurences 0 or 1
    SDR - after MIR and RDR - occurences 1 per site
    WIR - after initial sequence and before MRR - occurences 1 per wafer tested
    WRR - after the WIR - occurences 1 per wafer tested
    WCR - after initial sequence and before MRR - occurences 1 per file (0 if not wafersort)
    PIR - after initial sequence and before the corresponding PRR (sent before testing the device) - occurences 1 per device
    PRR - after corresponding PIR and before MRR - occurences 1 per device
    TSR - after initial sequence and before MRR - occurences one per test executed, or one per all tests
    PTR - after corresponding PIR and before corresponding PRR - occurences 1 per parametric test
    MPR - after corresponding PIR and before corresponding PRR - occurences 1 per multiple-result parametric test
    FTR - after corresponding PIR and before corresponding PRR - occurences 1 per functional test
    BPS - after PIR and before PRR - occurences 0 or more
    EPS - after corresponding BPS and before PRR - occurences 0 or more
    GDR - after initial sequence and before MRR - occurences 0 or more
    DTR - after initial sequence and before MRR - occurences 0 or more

  An STDF file may contain one or more devices.  The lot identifier
  may be printed once at the beginning of testing, or once per device.

  STEP        = DTR.TEXT_DAT = ">>> STEP #: <step>"                OR DTR.TEXT_DAT = "STEP #: <step>"
  temperature = DTR.TEXT_DAT = ">>> TEMPERATURE : <temp>"          OR DTR.TEXT_DAT = "TEMPERATURE: <temp>"           OR MIR.TST_TEMP
  lot_id      = DTR.TEXT_DAT = ">>> LOT # : <lot_id>"              OR DTR.TEXT_DAT = "LOT # : <lot_id>"              OR MIR.LOT_ID
  sublot_id   = DTR.TEXT_DAT = ">>> SUBLOT # : <sublot_id>"        OR MIR.SBLOT_ID
  Wafer       = DTR.TEXT_DAT = ">>> WAFER # : <wafer_id>"          OR WIR.wafer_id 
  Device      = DTR.TEXT_DAT = ">>> DEVICE_NUMBER : <device_name>" OR DTR.TEXT_DAT = "DEVICE_NUMBER : <device_name>" OR MIR.PART_TYP
  --------------------------------------------------------------------

  The device serial ID is identified as follows:
  DTR.TEXT_DAT = "TEXT_DATA : S/N : <serial_id>"
  PRR.part_id field or PRR.x_coord and PRR.y_coord
  All devices will also get a time stamp equal to MIR.start_t + (site_num*head_num) * PRR.test_t / (num_sites*num_heads);
  where site numbers are 1-based

  --------------------------------------------------------------------
  Each test will get a test id
  TestIDs consist of a test name, test number, duplicate number, and optionally a pin.
  For a test to be considered a duplicate, it must have the following:
  1. Same test name and test number,
  2. Same record type MPR, PTR, or FTR
  3. same pin
  3. Each test is numbered in sequential order for testflow analysis
  --------------------------------------------------------------------
  The following following is done at the file level:
  1. build pin maps
  2. Extract header information
  3. fill in missing data to test records
  4. build test IDs, and number test ordering
  5. compute timestamp for each device
  6. Scale units and values
  7. sort records by timestamp

 */
module itestinc.StdfFile;
import itestinc.Stdf;
import itestinc.Descriptors;
import itestinc.CmdOptions;
import std.algorithm.iteration;
import std.conv;
import std.string;
import std.typecons;
import itestinc.DefaultValueDatabase;
import std.stdio;

class HeaderInfo
{
    private const bool ignoreMiscItems;
    const string step;
    const string temperature;
    const string lot_id;
    const string sublot_id;
    const string wafer_id;
    const string devName;
    private string[const string] headerItems;
    private string[const string] hi;
    private static int wnum;

    this(bool ignoreMiscItems, string step, string temperature, string lot_id, string sublot_id, string wafer_id, string devName)
    {
        this.ignoreMiscItems = ignoreMiscItems;
        this.step = step;
        this.temperature = temperature;
        this.lot_id = lot_id;
        this.sublot_id = sublot_id;
        this.wafer_id = wafer_id;
        this.devName = devName;
    }

    public bool isWafersort() @safe pure nothrow { return wafer_id != ""; }

    public string[const string] getHeaderItems() pure
    { 
        hi.clear();
        foreach (key; headerItems.keys)
        {
            hi[key] = headerItems[key];
        }
        return hi;
    } 

    override public string toString()
    {
        string s = "HeaderInfo:\n";
        s ~= "  devName = " ~ devName ~ "\n";
        s ~= "  step = " ~ step ~ "\n";
        s ~= "  temperature = " ~ temperature ~ "\n";
        s ~= "  lot_id = " ~ lot_id ~ "\n";
        s ~= "  sublot_id = " ~ sublot_id ~ "\n";
        s ~= "  wafer_id = " ~ wafer_id ~ "\n";
        s ~= "  ignoreMiscItems = " ~ to!string(ignoreMiscItems) ~ "\n";
        s ~= "  " ~ to!string(headerItems) ~ "\n";
        s ~= "  hashcode = " ~ to!string(toHash()) ~ "\n";
        return s;
    }

    override public bool opEquals(Object o) 
    {
        import std.stdio;
        if (o is null) return false;
        if (typeid(o) != typeid(this)) return false;
        HeaderInfo h = cast(HeaderInfo) o;
        if (ignoreMiscItems != h.ignoreMiscItems) return false;
        if (step != h.step) return false;
        if (temperature != h.temperature) return false;
        if (lot_id != h.lot_id) return false;
        if (sublot_id != h.sublot_id) return false;
        if (wafer_id != h.wafer_id) return false;
        if (devName != h.devName) return false;
        if (!ignoreMiscItems)
        {
            if (headerItems.length != h.headerItems.length) return false;
            foreach(key; headerItems.keys)
            {
                string value = headerItems[key];
                string value2 = headerItems.get(key, "");
                if (value != value2) return false;
            }
        }
        return true;
    }

    override public size_t toHash() const @safe pure nothrow
    {
        size_t hash = step.hashOf();
        hash = temperature.hashOf(hash);
        hash = lot_id.hashOf(hash);
        hash = sublot_id.hashOf(hash);
        hash = wafer_id.hashOf(hash);
        hash = devName.hashOf(hash);
        if (!ignoreMiscItems) hash = headerItems.hashOf(hash);
        hash = ignoreMiscItems ? hash ^ 0xAAAA : hash ^ 0x5555;
        return hash;
    }

}

struct StdfData
{
    StdfRecord[][HeaderInfo] records;
    string filename;
    Record!MIR mir;
    Record!(HBR)[] hbrs;
}

struct StdfFile
{
    StdfData data;
    private const bool ignoreMiscHeaderItems;
    private const string optionString;
    private CmdOptions options;
    uint wnum = 1;

    /**
      Options needed:
      noIgnoreMiscHeader;
     */
    this(string filename, CmdOptions options)
    {
        this.options = options;
        optionString = options.options;
        data.filename = filename;
        this.ignoreMiscHeaderItems = !options.noIgnoreMiscHeader; 
    }

    // Since load can change the order of records, always do any printing or modifying first
    import std.digest;
    void printAndOrModify(StdfRecord[] records)
    {
        foreach (m; options.modifiers)
        {
            foreach (rec; records)
            {
                if (rec.recordType == m.recordType)
                {
                    modify(rec, m);
                }
            }
        }
        if (options.textDump || options.byteDump)
        {
            import std.digest;
            foreach (rec; records)
            {   
                writeln("reclen = ", rec.getReclen());
                writeln("type = ", rec.recordType); 
                if (options.textDump) writeln(rec.toString());
                if (options.byteDump)
                {   
                    ubyte[] bs = rec.getBytes();
                    writeln("[");
                    size_t cnt = 1;
                    foreach (b; bs) 
                    {   
                        string by = toHexString([b]);
                        if (by.length < 2) std.stdio.write("0", by, " ");
                        else std.stdio.write(by, " ");
                        if (cnt == 24) 
                        {   
                            writeln("");
                            cnt = 0;
                        }   
                        cnt++;
                    }   
                    writeln("]");
                }   
            }   
        }   
        if (options.outputDir != "") 
        {   
            import std.path;
            string fname = baseName(data.filename);
            string outname = options.outputDir ~ dirSeparator ~ fname;
            File f = File(outname, "w");
            foreach (r; records)
            {   
                auto type = r.recordType;
                ubyte[] bs = r.getBytes();
                f.rawWrite(bs);
            }   
            f.close();
            if (options.verifyWrittenStdf)
            {   
                File f1 = File(data.filename, "r");
                File f2 = File(outname, "r");
                ubyte[] bs1;
                ubyte[] bs2;
                bs1.length = f1.size();
                bs2.length = f2.size();
                f1.rawRead(bs1);
                f2.rawRead(bs2);
                bool pass = true;
                size_t mismatches = 0L; 
                for (size_t j=0; j<f1.size() && j<f2.size(); j++)
                {   
                    if (bs1[j] != bs2[j])
                    {   
                        writeln("diff at index ", j, ": ", toHexString([bs1[j]]), " vs ", toHexString([bs2[j]]));
                        pass = false;
                        mismatches++;
                    }   
                    if (mismatches > 20) break;
                }
                if (pass)
                {
                    writeln("Saved file matches input file");
                }
            }
        }
    }

    void load()
    {
        StdfReader stdf = new StdfReader(data.filename);
        stdf.read();
        stdf.close();
        StdfRecord[] records = stdf.getRecords();
        foreach (r; records)
        {
            if (r.recordType == Record_t.MIR)
            {
                data.mir = cast(Record!MIR) r;
            }
            else if (r.recordType == Record_t.HBR)
            {
                data.hbrs ~= cast(Record!HBR) r;
            }
        }
        records = stdf.getRecords();
        printAndOrModify(records);
        records = stdf.getRecords();
        HeaderInfo hdr = getHeaderInfo(records);
        bool first = true;
        StdfRecord[] rs;
        string temp = hdr.temperature;
        string step = hdr.step;
        string wafer = hdr.wafer_id;
        string[const string] miscFields = hdr.getHeaderItems();
        bool waferFound = false;
        HeaderInfo hdr2;
        records = stdf.getRecords();
        foreach (rec; records)
        {
            if (first) 
            {
                rs ~= rec;
                if (rec.recordType == Record_t.PRR)
                {
                    first = false;
                    if (step != "end") data.records[hdr] = rs.dup;
                    rs.length = 0;
                }
            }
            else
            {
                rs ~= rec;
                if (rec.recordType == Record_t.DTR)
                {
                    Record!DTR dtr = cast(Record!DTR) rec;
                    string srec = strip(dtr.TEXT_DAT);
                    auto toks = srec.split(":");
                    // check for legacy headerfiels:
                    if (toks.length == 2)
                    {
                        auto tok0 = toks[0].strip;
                        auto tok1 = toks[1].strip;
                        if (tok0 == "STEP #") step = tok1;
                        else if (tok0 == "TEMPERATURE") temp = tok1;
                        else // check for normal header fields:
                        {
                            if (srec[0..3] == ">>>") // it's a header field
                            {
                                srec = srec[3..$];
                                toks = srec.split(":");
                                tok0 = toks[0].strip;
                                tok1 = toks[1].strip;
                                if (tok0 == "STEP #") step = tok1;
                                else if (tok0 == "TEMPERATURE") temp = tok1;
                                else if (tok0 == "WAFER #") wafer = tok1;
                                else miscFields[tok0] = tok1;
                            }
                        }
                    }
                }
                else if (rec.recordType == Record_t.WIR)
                {
                    waferFound = true;
                    Record!WIR wir = cast(Record!WIR) rec;
                    wafer = (wir is null) ? "" : wir.WAFER_ID;
                }
                else if (rec.recordType == Record_t.PRR)
                {
                    waferFound = false;
                    hdr2 = new HeaderInfo(ignoreMiscHeaderItems, step, temp, hdr.lot_id, hdr.sublot_id, wafer, hdr.devName);
                    foreach (key; miscFields.keys)
                    {
                        auto value = miscFields.get(key, "");
                        hdr2.headerItems[key] = value;
                    }
                    if (step != "end")
                    {
                        if (hdr2 in data.records)
                        {
                            StdfRecord[] recs = data.records[hdr2];
                            recs ~= rs.dup;
                            data.records[hdr2] = recs;
                        }
                        else
                        {
                            data.records[hdr2] = rs.dup;
                        }
                    }
                    rs.length = 0;
                }
            }
            wnum++;
        }
        if (step != "end")
        {
            if (hdr2 is null)
            {
                StdfRecord[] recs = data.records[hdr];
                recs ~= rs.dup;
                data.records[hdr] = recs;
            }
            else
            {
                if (hdr2 in data.records)
                {
                        StdfRecord[] recs = data.records[hdr2];
                        recs ~= rs.dup;
                        data.records[hdr2] = recs;
                }
                else
                {
                        data.records[hdr2] = rs.dup;
                }
            }
        }
    }

    private HeaderInfo getHeaderInfo(StdfRecord[] records)
    {
        auto dtrs = records.filter!(r => r.recordType == Record_t.DTR).map!(a => cast(Record!DTR) a);
        Record!(MIR) mir;
        for (int i=0; i<records.length; i++)
        {
            if (records[i].recordType == Record_t.MIR)
            {
                mir = cast(Record!(MIR)) records[i];
                break;
            }
        }
        Record!(WIR) wir = null;
        for (int i=0; i<records.length; i++)
        {
            if (records[i].recordType == Record_t.WIR)
            {
                wir = cast(Record!(WIR)) records[i];
                break;
            }
        }
        string temp = mir.TST_TEMP;
        string step = "";
        string lot = mir.LOT_ID;
        string sblot = mir.SBLOT_ID;
        string device = mir.PROC_ID;  
        string wafer = (wir is null) ? "" : wir.WAFER_ID;
        if (options.forceWafer)
        {
            wafer = to!string(wnum);
            wnum++;
        }
        
        string[string] miscFields;
        miscFields["stdf2xlsx options"] = optionString;
        miscFields["stdf2xlsx version"] = CmdOptions.stdf2xlsx_version;
        foreach (dtr; dtrs)
        {
            string rec = strip(dtr.TEXT_DAT);
            auto toks = rec.split(":");
            // check for legacy headerfiels:
            if (toks.length == 2)
            {
                auto tok0 = toks[0].strip;
                auto tok1 = toks[1].strip;
                if (tok0 == "CUSTOMER") miscFields["CUSTOMER"] = tok1;
                else if (tok0 == "DEVICE NUMBER") device = tok1;
                else if (tok0 == "SOW") miscFields["SOW"] = tok1;
                else if (tok0 == "CUSTOMER PO#") miscFields["CUSTOMER PO#"] = tok1;
                else if (tok0 == "TESTER") miscFields["TESTER"] = tok1;
                else if (tok0 == "TEST PROGRAM") miscFields["TEST PROGRAM"] = tok1;
                else if (tok0 == "CONTROL SERIAL #s") miscFields["CONTROL SERIAL #s"] = tok1;
                else if (tok0 == "JOB #") miscFields["JOB #"] = tok1;
                else if (tok0 == "LOT #") lot = tok1;
                else if (tok0 == "STEP #") step = tok1;
                else if (tok0 == "TEMPERATURE") temp = tok1;
                else // check for normal header fields:
                {
                    if (rec[0..3] == ">>>") // it's a header field
                    {
                        rec = rec[3..$];
                        toks = rec.split(":");
                        tok0 = toks[0].strip;
                        tok1 = toks[1].strip;
                        if (tok0 == "STEP #") step = tok1;
                        else if (tok0 == "TEMPERATURE") temp = tok1;
                        else if (tok0 == "LOT #") lot = tok1;
                        else if (tok0 == "SUBLOT #") sblot = tok1;
                        else if (tok0 == "WAFER #") wafer = tok1;
                        else if (tok0 == "DEVICE_NUMBER" || tok0 == "DEVICE NUMBER") device = tok1;
                        else miscFields[tok0] = tok1;
                    }
                }
            }
        }
        HeaderInfo hdr = new HeaderInfo(ignoreMiscHeaderItems, step, temp, lot, sblot, wafer, device);
        foreach (key; miscFields.keys)
        {
            auto value = miscFields.get(key, "");
            hdr.headerItems[key] = value;
        }
        import std.array;
        return hdr;
    }


}

import std.regex;
private void modify(StdfRecord rec, Modifier m)
{
    auto re = regex(m.regexp);
    //writeln("regex = ", re, " repl = ", m.repl);
    switch (m.recordType.ordinal)
    {
        case Record_t.ATR.ordinal:  Record!ATR r = cast(Record!ATR) rec;
                                    r.CMD_LINE = CN(replaceAll(r.CMD_LINE.getValue, re, m.repl));
                                    break;
        case Record_t.BPS.ordinal:  Record!BPS r = cast(Record!BPS) rec;
                                    r.SEQ_NAME.setValue(replaceAll(r.SEQ_NAME.getValue, re, m.repl));
                                    break;
        case Record_t.DTR.ordinal:  Record!DTR r = cast(Record!DTR) rec;
                                    r.TEXT_DAT = CN(replaceAll(r.TEXT_DAT.getValue, re, m.repl));
                                    break;
        case Record_t.FTR.ordinal:  Record!FTR r = cast(Record!FTR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "VECT_NAM": r.VECT_NAM.setValue(replaceAll(r.VECT_NAM.getValue, re, m.repl)); break;
                                    case "TIME_SET": r.TIME_SET.setValue(replaceAll(r.TIME_SET.getValue, re, m.repl)); break;
                                    case "OP_CODE":  r.OP_CODE.setValue(replaceAll(r.OP_CODE.getValue, re, m.repl)); break;
                                    case "TEST_TXT": r.TEST_TXT.setValue(replaceAll(r.TEST_TXT.getValue, re, m.repl)); break;
                                    case "ALARM_ID": r.ALARM_ID.setValue(replaceAll(r.ALARM_ID.getValue, re, m.repl)); break;
                                    case "PROG_TXT": r.PROG_TXT.setValue(replaceAll(r.PROG_TXT.getValue, re, m.repl)); break;
                                    case "RSLT_TXT": r.RSLT_TXT.setValue(replaceAll(r.RSLT_TXT.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.HBR.ordinal:  Record!HBR r = cast(Record!HBR) rec;
                                    r.HBIN_NAM.setValue(replaceAll(r.HBIN_NAM.getValue, re, m.repl));
                                    break;
        case Record_t.MIR.ordinal:  Record!MIR r = cast(Record!MIR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "LOT_ID":   r.LOT_ID = CN(replaceAll(r.LOT_ID.getValue, re, m.repl)); break;
                                    case "PART_TYP": r.PART_TYP = CN(replaceAll(r.PART_TYP.getValue, re, m.repl)); break;
                                    case "NODE_NAM": r.NODE_NAM = CN(replaceAll(r.NODE_NAM.getValue, re, m.repl)); break;
                                    case "TSTR_TYP": r.TSTR_TYP = CN(replaceAll(r.TSTR_TYP.getValue, re, m.repl)); break;
                                    case "JOB_NAM":  r.JOB_NAM = CN(replaceAll(r.JOB_NAM.getValue, re, m.repl)); break;
                                    case "JOB_REV":  r.JOB_REV.setValue(replaceAll(r.JOB_REV.getValue, re, m.repl)); break;
                                    case "SBLOT_ID": r.SBLOT_ID.setValue(replaceAll(r.SBLOT_ID.getValue, re, m.repl)); break;
                                    case "OPER_NAM": r.OPER_NAM.setValue(replaceAll(r.OPER_NAM.getValue, re, m.repl)); break;
                                    case "EXEC_TYP": r.EXEC_TYP.setValue(replaceAll(r.EXEC_TYP.getValue, re, m.repl)); break;
                                    case "EXEC_VER": r.EXEC_VER.setValue(replaceAll(r.EXEC_VER.getValue, re, m.repl)); break;
                                    case "TEST_COD": r.TEST_COD.setValue(replaceAll(r.TEST_COD.getValue, re, m.repl)); break;
                                    case "TST_TEMP": r.TST_TEMP.setValue(replaceAll(r.TST_TEMP.getValue, re, m.repl)); break;
                                    case "USER_TXT": r.USER_TXT.setValue(replaceAll(r.USER_TXT.getValue, re, m.repl)); break;
                                    case "AUX_FILE": r.AUX_FILE.setValue(replaceAll(r.AUX_FILE.getValue, re, m.repl)); break;
                                    case "PKG_TYP":  r.PKG_TYP.setValue(replaceAll(r.PKG_TYP.getValue, re, m.repl)); break;
                                    case "FAMLY_ID": r.FAMLY_ID.setValue(replaceAll(r.FAMLY_ID.getValue, re, m.repl)); break;
                                    case "DATE_COD": r.DATE_COD.setValue(replaceAll(r.DATE_COD.getValue, re, m.repl)); break;
                                    case "FACIL_ID": r.FACIL_ID.setValue(replaceAll(r.FACIL_ID.getValue, re, m.repl)); break;
                                    case "FLOOR_ID": r.FLOOR_ID.setValue(replaceAll(r.FLOOR_ID.getValue, re, m.repl)); break;
                                    case "PROC_ID":  r.PROC_ID.setValue(replaceAll(r.PROC_ID.getValue, re, m.repl)); break;
                                    case "OPER_FRQ": r.OPER_FRQ.setValue(replaceAll(r.OPER_FRQ.getValue, re, m.repl)); break;
                                    case "SPEC_NAM": r.SPEC_NAM.setValue(replaceAll(r.SPEC_NAM.getValue, re, m.repl)); break;
                                    case "SPEC_VER": r.SPEC_VER.setValue(replaceAll(r.SPEC_VER.getValue, re, m.repl)); break;
                                    case "FLOW_ID":  r.FLOW_ID.setValue(replaceAll(r.FLOW_ID.getValue, re, m.repl)); break;
                                    case "SETUP_ID": r.SETUP_ID.setValue(replaceAll(r.SETUP_ID.getValue, re, m.repl)); break;
                                    case "DSGN_REV": r.DSGN_REV.setValue(replaceAll(r.DSGN_REV.getValue, re, m.repl)); break;
                                    case "ENG_ID":   r.ENG_ID.setValue(replaceAll(r.ENG_ID.getValue, re, m.repl)); break;
                                    case "ROM_COD":  r.ROM_COD.setValue(replaceAll(r.ROM_COD.getValue, re, m.repl)); break;
                                    case "SERL_NUM": r.SERL_NUM.setValue(replaceAll(r.SERL_NUM.getValue, re, m.repl)); break;
                                    case "SUPR_NAM": r.SUPR_NAM.setValue(replaceAll(r.SUPR_NAM.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.MPR.ordinal:  Record!MPR r = cast(Record!MPR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "TEST_TXT": r.TEST_TXT.setValue(replaceAll(r.TEST_TXT.getValue, re, m.repl)); break;
                                    case "ALARM_ID": r.ALARM_ID.setValue(replaceAll(r.ALARM_ID.getValue, re, m.repl)); break;
                                    case "UNITS":    r.UNITS.setValue(replaceAll(r.UNITS.getValue, re, m.repl)); break;
                                    case "C_RESFMT": r.C_RESFMT.setValue(replaceAll(r.C_RESFMT.getValue, re, m.repl)); break;
                                    case "C_LLMFMT": r.C_LLMFMT.setValue(replaceAll(r.C_LLMFMT.getValue, re, m.repl)); break;
                                    case "UNITS_IN": r.UNITS_IN.setValue(replaceAll(r.UNITS_IN.getValue, re, m.repl)); break;
                                    case "C_HLMFMT": r.C_HLMFMT.setValue(replaceAll(r.C_HLMFMT.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.MRR.ordinal:  Record!MRR r = cast(Record!MRR) rec;
                                    if (m.fieldName == "USR_DESC")
                                    {
                                        r.USR_DESC.setValue(replaceAll(r.USR_DESC.getValue, re, m.repl));
                                    }
                                    else
                                    {
                                        r.EXC_DESC.setValue(replaceAll(r.EXC_DESC.getValue, re, m.repl));
                                    }
                                    break;
        case Record_t.PGR.ordinal:  Record!PGR r = cast(Record!PGR) rec;
                                    r.GRP_NAM = CN(replaceAll(r.GRP_NAM.getValue, re, m.repl));
                                    break;
        case Record_t.PLR.ordinal:  Record!PLR r = cast(Record!PLR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "PGM_CHAR":
                                        for (int i=0; i<r.PGM_CHAR.length(); i++)
                                        {
                                            string s = r.PGM_CHAR.value(i);
                                            r.PGM_CHAR.setValue(i, replaceAll(s, re, m.repl));
                                        }
                                        break;
                                    case "RTN_CHAR":
                                        for (int i=0; i<r.RTN_CHAR.length(); i++)
                                        {
                                            string s = r.RTN_CHAR.value(i);
                                            r.RTN_CHAR.setValue(i, replaceAll(s, re, m.repl));
                                        }
                                        break;
                                    case "PGM_CHAL":
                                        for (int i=0; i<r.PGM_CHAL.length(); i++)
                                        {
                                            string s = r.PGM_CHAL.value(i);
                                            r.PGM_CHAL.setValue(i, replaceAll(s, re, m.repl));
                                        }
                                        break;
                                    case "RTN_CHAL":
                                        for (int i=0; i<r.RTN_CHAL.length(); i++)
                                        {
                                            string s = r.RTN_CHAL.value(i);
                                            r.RTN_CHAL.setValue(i, replaceAll(s, re, m.repl));
                                        }
                                        break;
                                    default:
                                    }
                                    break;
        case Record_t.PMR.ordinal:  Record!PMR r = cast(Record!PMR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "CHAN_NAM": r.CHAN_NAM.setValue(replaceAll(r.CHAN_NAM.getValue, re, m.repl)); break;
                                    case "PHY_NAM":  r.PHY_NAM.setValue(replaceAll(r.PHY_NAM.getValue, re, m.repl)); break;
                                    case "LOG_NAM":  r.LOG_NAM.setValue(replaceAll(r.LOG_NAM.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.PRR.ordinal:  Record!PRR r = cast(Record!PRR) rec;
                                    if (m.fieldName == "PART_ID")
                                    {
                                        r.PART_ID.setValue(replaceAll(r.PART_ID.getValue, re, m.repl));
                                    }
                                    else
                                    {
                                        r.PART_TXT.setValue(replaceAll(r.PART_TXT.getValue, re, m.repl));
                                    }
                                    break;
        case Record_t.PTR.ordinal:  Record!PTR r = cast(Record!PTR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "TEST_TXT": r.TEST_TXT.setValue(replaceAll(r.TEST_TXT.getValue, re, m.repl)); break;
                                    case "ALARM_ID": r.ALARM_ID.setValue(replaceAll(r.ALARM_ID.getValue, re, m.repl)); break;
                                    case "UNITS":    r.UNITS.setValue(replaceAll(r.UNITS.getValue, re, m.repl)); break;
                                    case "C_RESFMT": r.C_RESFMT.setValue(replaceAll(r.C_RESFMT.getValue, re, m.repl)); break;
                                    case "C_LLMFMT": r.C_LLMFMT.setValue(replaceAll(r.C_LLMFMT.getValue, re, m.repl)); break;
                                    case "C_HLMFMT": r.C_HLMFMT.setValue(replaceAll(r.C_HLMFMT.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.SBR.ordinal:  Record!SBR r = cast(Record!SBR) rec;
                                    r.SBIN_NAM.setValue(replaceAll(r.SBIN_NAM.getValue, re, m.repl));
                                    break;
        case Record_t.SDR.ordinal:  Record!SDR r = cast(Record!SDR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "HAND_TYP": r.HAND_TYP.setValue(replaceAll(r.HAND_TYP.getValue, re, m.repl)); break;
                                    case "HAND_ID":  r.HAND_ID.setValue(replaceAll(r.HAND_ID.getValue, re, m.repl)); break;
                                    case "CARD_TYP": r.CARD_TYP.setValue(replaceAll(r.CARD_TYP.getValue, re, m.repl)); break;
                                    case "CARD_ID":  r.CARD_ID.setValue(replaceAll(r.CARD_ID.getValue, re, m.repl)); break;
                                    case "LOAD_TYP": r.LOAD_TYP.setValue(replaceAll(r.LOAD_TYP.getValue, re, m.repl)); break;
                                    case "LOAD_ID":  r.LOAD_ID.setValue(replaceAll(r.LOAD_ID.getValue, re, m.repl)); break;
                                    case "DIB_TYP":  r.DIB_TYP.setValue(replaceAll(r.DIB_TYP.getValue, re, m.repl)); break;
                                    case "DIB_ID":   r.DIB_ID.setValue(replaceAll(r.DIB_ID.getValue, re, m.repl)); break;
                                    case "CABL_TYP": r.CABL_TYP.setValue(replaceAll(r.CABL_TYP.getValue, re, m.repl)); break;
                                    case "CABL_ID":  r.CABL_ID.setValue(replaceAll(r.CABL_ID.getValue, re, m.repl)); break;
                                    case "CONT_TYP": r.CONT_TYP.setValue(replaceAll(r.CONT_TYP.getValue, re, m.repl)); break;
                                    case "CONT_ID":  r.CONT_ID.setValue(replaceAll(r.CONT_ID.getValue, re, m.repl)); break;
                                    case "LASR_TYP": r.LASR_TYP.setValue(replaceAll(r.LASR_TYP.getValue, re, m.repl)); break;
                                    case "LASR_ID":  r.LASR_ID.setValue(replaceAll(r.LASR_ID.getValue, re, m.repl)); break;
                                    case "EXTR_TYP": r.EXTR_TYP.setValue(replaceAll(r.EXTR_TYP.getValue, re, m.repl)); break;
                                    case "EXTR_ID":  r.EXTR_ID.setValue(replaceAll(r.EXTR_ID.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.TSR.ordinal:  Record!TSR r = cast(Record!TSR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "TEST_NAM": r.TEST_NAM.setValue(replaceAll(r.TEST_NAM.getValue, re, m.repl)); break;
                                    case "SEQ_NAME": r.SEQ_NAME.setValue(replaceAll(r.SEQ_NAME.getValue, re, m.repl)); break;
                                    case "TEST_LBL": r.TEST_LBL.setValue(replaceAll(r.TEST_LBL.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        case Record_t.WIR.ordinal:  Record!WIR r = cast(Record!WIR) rec;
                                    r.WAFER_ID.setValue(replaceAll(r.WAFER_ID.getValue, re, m.repl));
                                    break;
        case Record_t.WRR.ordinal:  Record!WRR r = cast(Record!WRR) rec;
                                    switch (m.fieldName)
                                    {
                                    case "WAFER_ID": r.WAFER_ID.setValue(replaceAll(r.WAFER_ID.getValue, re, m.repl)); break;
                                    case "FABWF_ID": r.FABWF_ID.setValue(replaceAll(r.FABWF_ID.getValue, re, m.repl)); break;
                                    case "FRAME_ID": r.FRAME_ID.setValue(replaceAll(r.FRAME_ID.getValue, re, m.repl)); break;
                                    case "MASK_ID":  r.MASK_ID.setValue(replaceAll(r.MASK_ID.getValue, re, m.repl)); break;
                                    case "USR_DESC": r.USR_DESC.setValue(replaceAll(r.USR_DESC.getValue, re, m.repl)); break;
                                    case "EXC_DESC": r.EXC_DESC.setValue(replaceAll(r.EXC_DESC.getValue, re, m.repl)); break;
                                    default:
                                    }
                                    break;
        default: throw new Exception("This bug can't happen: " ~ m.fieldName);
    }
}

