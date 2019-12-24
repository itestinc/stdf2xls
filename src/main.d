import makechip.CmdOptions;
import makechip.Stdf;
import makechip.Descriptors;
import makechip.Cpu_t;
import makechip.Stdf2xls;
import std.conv;
import std.stdio;
import std.traits;
import std.getopt;
import std.typecons;
import makechip.StdfFile;

int main(string[] args)
{
    CmdOptions options = new CmdOptions(args);
    import std.path;
    import std.digest;
    import std.file;
    StdfFile[][HeaderInfo] stdfs = processStdf(options);
    // print, write, and modify here - options.textDump, options.byteDump, options.verifyWrittenStdf, option.outputDir
    foreach (hdr; stdfs.keys)
    {
        StdfFile[] files = stdfs[hdr];
        foreach (file; files)
        {
            foreach (m; options.modifiers)
            {
                foreach (rec; file.records)
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
                foreach (rec; file.records)
                {
                    writeln("reclen = ", rec.getReclen());
                    writeln("type = ", rec.recordType); 
                    if (options.textDump) writeln(rec.toString());
                    if (options.byteDump)
                    {
                        ubyte[] bs = rec.getBytes();
                        writeln("[");
                        size_t cnt = 0;
                        foreach (b; bs)
                        {
                            if (b < 0xF) std.stdio.write("0", toHexString([b]), " ");
                            else std.stdio.write(toHexString([b]), " ");
                            if (cnt == 40)
                            {
                                writeln("");
                                cnt = 0;
                            }
                            cnt++;
                        }
                        writeln("]");
                    }
                }
                stdout.flush();
            }
            if (options.outputDir != "")
            {
                import std.path;
                string outname = options.outputDir ~ dirSeparator ~ file.filename;
                File f = File(outname, "w");
                foreach (r; file.records)
                {
                    auto type = r.recordType;
                    ubyte[] bs = r.getBytes();
                    f.rawWrite(bs);
                }
                f.close();
                if (options.verifyWrittenStdf)
                {
                    File f1 = File(file.filename, "r");
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
    }
    // prepare to process test data
    loadDb(options);
    if (options.summarize) summarize();
    if (options.genSpreadsheet) genSpreadsheet(options);
    if (options.genWafermap) genWafermap(options);
    if (options.genHistogram) genHistogram(options);
    return 0;
}


import std.regex;
void modify(StdfRecord rec, Modifier m)
{
    auto re = regex(m.regexp);
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
