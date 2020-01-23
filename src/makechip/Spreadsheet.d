module makechip.Spreadsheet;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import makechip.Config;
import std.stdio;
import libxlsxd.workbook;
import makechip.SpreadsheetWriter;
import makechip.Util;

public void genSpreadsheet(CmdOptions options, StdfDB stdfdb, Config config)
{
    Workbook dummyWb = newWorkbook("");
    import std.array;
    import std.algorithm.sorting;
    import std.algorithm;
    string sfile = options.sfile;
    const bool separateFileForDevice = canFind(sfile, "${device}");
    const bool separateFileForLot = canFind(sfile, "${lot}");
    MultiMap!(Workbook, string, string) wbMap = new MultiMap!(Workbook, string, string)();
    foreach (key; stdfdb.deviceMap.keys)
    {
        Workbook wb;
        import std.string;
        if (separateFileForDevice && separateFileForLot)
        {
            string lot = key.lot_id;
            string dev = key.devName;
            string fname = tr(sfile, "${lot}", lot).tr("${device}", dev);
            wb = wbMap.get(dummyWb, dev, lot);
            if (wb.filename == "")
            {
                wb = newWorkbook(fname);
                initFormats(wb, options, config);
                wbMap.put(wb, dev, lot);
            }
        }
        else if (separateFileForDevice)
        {
            string lot = "";
            string dev = key.devName;
            string fname = tr(sfile, "${device}", dev);
            wb = wbMap.get(dummyWb, dev, lot);
            if (wb.filename == "")
            {
                wb = newWorkbook(fname);
                initFormats(wb, options, config);
                wbMap.put(wb, dev, lot);
            }
        }
        else if (separateFileForLot)
        {
            string lot = key.lot_id;
            string dev = "";
            string fname = tr(sfile, "${lot}", lot);
            wb = wbMap.get(dummyWb, dev, lot);
            if (wb.filename == "")
            {
                wb = newWorkbook(fname);
                initFormats(wb, options, config);
                wbMap.put(wb, dev, lot);
            }
        }
        else
        {
            wb = wbMap.get(dummyWb, "", "");
            if (wb.filename == "")
            {
                wb = newWorkbook(sfile);
                initFormats(wb, options, config);
                wbMap.put(wb, "", "");
            }
        }
        LinkedMap!(const TestID, uint) rowOrColMap = new LinkedMap!(const TestID, uint);
        DeviceResult[] dr = stdfdb.deviceMap[key];
        bool removeDups = false;
        switch (options.sortType) with (Sort_t)
        {
            case SN_UP_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_UP_TIME_UP:
                multiSort!("a.devId.setNumeric(false) < b.devId.setNumeric(false)", "a.tstamp < b.tstamp")(dr);
                break;
            case SN_DOWN_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_DOWN_TIME_UP:
                multiSort!("a.devId.setNumeric(false) > b.devId.setNumeric(false)", "a.tstamp < b.tstamp")(dr);
                break;
            case SN_UP_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_UP_TIME_DOWN:
                multiSort!("a.devId.setNumeric(false) < b.devId.setNumeric(false)", "a.tstamp > b.tstamp")(dr);
                break;
            case SN_DOWN_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_DOWN_TIME_DOWN:
                multiSort!("a.devId.setNumeric(false) > b.devId.setNumeric(false)", "a.tstamp > b.tstamp")(dr);
                break;
            case SNN_UP_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_UP_TIME_UP:
                multiSort!("a.devId.setNumeric(true) < b.devId.setNumeric(true)", "a.tstamp < b.tstamp")(dr);
                break;
            case SNN_DOWN_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_DOWN_TIME_UP:
                multiSort!("a.devId.setNumeric(true) > b.devId.setNumeric(true)", "a.tstamp < b.tstamp")(dr);
                break;
            case SNN_UP_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_UP_TIME_DOWN:
                multiSort!("a.devId.setNumeric(true) < b.devId.setNumeric(true)", "a.tstamp > b.tstamp")(dr);
                break;
            case SNN_DOWN_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_DOWN_TIME_DOWN:
                multiSort!("a.devId.setNumeric(true) > b.devId.setNumeric(true)", "a.tstamp > b.tstamp")(dr);
                break;
            case TIME_UP_SN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SN_UP:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(false) < b.devId.setNumeric(false)")(dr);
                break;
            case TIME_UP_SN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SN_DOWN:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(false) > b.devId.setNumeric(false)")(dr);
                break;
            case TIME_DOWN_SN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SN_UP:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(false) < b.devId.setNumeric(false)")(dr);
                break;
            case TIME_DOWN_SN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SN_DOWN:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(false) > b.devId.setNumeric(false)")(dr);
                break;
            case TIME_UP_SNN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SNN_UP:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(true) < b.devId.setNumeric(true)")(dr);
                break;
            case TIME_UP_SNN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SNN_DOWN:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(true) > b.devId.setNumeric(true)")(dr);
                break;
            case TIME_DOWN_SNN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SNN_UP:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(true) < b.devId.setNumeric(true)")(dr);
                break;
            case TIME_DOWN_SNN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SNN_DOWN:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(true) > b.devId.setNumeric(true)")(dr);
                break;
            default: throw new Exception("Unsupported sort type");
        }
        DeviceResult[] devices;
        if (removeDups)
        {
            DeviceResult prevDevice = dr[0];
            int i;
            for (i=1; i<dr.length; i++)
            {
                if (dr[i].devId == prevDevice.devId) continue;
                devices ~= prevDevice;
                prevDevice = dr[i];
            }
            if (devices[$-1].devId != prevDevice.devId) devices ~= prevDevice;
        }
        TestRecord[][] normList = new TestRecord[][devices.length];
        size_t maxLen = 0;
        size_t maxLoc = 0;
        size_t i = 0;
        foreach (d; devices)
        {
            if (d.tests.length > maxLen)
            {
                    maxLen = d.tests.length;
                    maxLoc = i;
            }
            i++;
        }
        // First expand the test list so they are essentially equal length (assuming they are passing devices)
        TestRecord[][] newTests = new TestRecord[][devices.length];
        for (size_t j=0; j<devices[maxLoc].tests.length; j++)
        {
            scan(j, devices[maxLoc].tests[j].id, devices[maxLoc].tests[j].type, devices, newTests);
        }
        // 1. First scan all newTests for tests that are not in newTests[maxLoc] and mark them with uflag.
        for (size_t k=0; k<newTests.length; k++)
        {
            if (k == maxLoc) continue;
            for (size_t l=0; l<newTests[k].length; l++)
            {
                if (newTests[k][l] is null) continue;
                bool found;
                for (size_t m=0; m<newTests[maxLoc].length; m++)
                {
                    if (newTests[maxLoc][m].id == newTests[k][l].id && newTests[maxLoc][m].type == newTests[k][l].type)
                    {
                        found = true;
                        break;
                    }
                }
                if (!found) newTests[k][l].uflag = true;
            }
        } 
        // Now create a dummy composite list that has all unique tests and no nulls:
        TestRecord[] compTests;
        for (size_t m=0; m<newTests[maxLoc].length; m++)
        {
            compTests ~= newTests[maxLoc][m];
            for (size_t n=0; n<newTests.length; n++)
            {
                for (size_t o=m; o<newTests[n].length; o++)
                {
                    if (newTests[n][o] !is null && newTests[n][o].uflag) 
                    {
                        bool found = false;
                        for (size_t p=0; p<compTests.length; p++)
                        {
                            if (newTests[n][o].id == compTests[p].id && newTests[n][o].type == compTests[p].type)
                            {
                                newTests[n][o].uflag = false;
                                found = true;
                            }
                        }
                        if (!found)
                        {
                            compTests ~= newTests[n][o];
                            newTests[n][o].uflag = false;
                        }
                    }
                    if (newTests[n][o] !is null) break;
                }
            }
        }
        // If there are dynamicLimits, then insert test headers for the upper and lower limits where appropriate
        TestRecord[] newCompTests;
        if (!options.noDynamicLimits)
        {
            foreach(test; compTests)
            {
                if (test.dynamicLoLimit)
                {
                    auto type = TestType.DYNAMIC_LOLIMIT;
                    auto nid = TestID.getTestID(test.id.type, "LO LIMIT", test.id.testNumber, test.id.testName ~ " LO LIMIT", test.id.dup);
                    TestRecord r = new TestRecord(nid, type);
                    newCompTests ~= r;
                }
                compTests ~= test;
                if (test.dynamicHiLimit)
                {
                    auto type = TestType.DYNAMIC_HILIMIT;
                    auto nid = TestID.getTestID(test.id.type, "HI LIMIT", test.id.testNumber, test.id.testName ~ " HI LIMIT", test.id.dup);
                    TestRecord r = new TestRecord(nid, type);
                    newCompTests ~= r;
                }
            }
        }
        else
        {
            newCompTests = compTests;
        }
        // now build a row map that maps test ID to spreadsheet row:
        uint rc = 0;
        foreach(test; newCompTests)
        {
            rowOrColMap[test.id] = rc;
            rc++;
        }
        for (size_t n=0; n<devices.length; n++) devices[n].tests = newTests[n];
        writeSheet(options, wb, rowOrColMap, key, devices, config);
    } 
}

private void scan(size_t tnum, const TestID id, const TestType type, DeviceResult[] devices, TestRecord[][] newTests)
{
    bool diff = false;
    TestID nextId;
    TestType nextType;
    for (size_t i=0; i<devices.length; i++)
    {
        if (devices[i].tests[tnum].id != id || devices[i].tests[tnum].type != type)
        {
            diff = true;
            newTests[i] ~= null;
            nextId = cast(TestID) devices[i].tests[tnum].id;
            nextType = devices[i].tests[tnum].type;
        }
        else 
        {
            newTests[i] ~= devices[i].tests[tnum];
        }
    }
    if (diff) scan(tnum, nextId, nextType, devices, newTests);
}
