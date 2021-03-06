module itestinc.Spreadsheet;
import itestinc.StdfDB;
import itestinc.StdfFile;
import itestinc.Stdf;
import itestinc.CmdOptions;
import itestinc.Config;
import std.stdio;
import libxlsxd.workbook;
import libxlsxd.worksheet; // deleteme
import itestinc.SpreadsheetWriter;
import itestinc.Util;

LinkedMap!(const TestID, uint)[HeaderInfo] rowOrColMapTable;
ubyte[][HeaderInfo] sitesMap;
StdfDB db;
DeviceResult[][HeaderInfo] deviceResults;
alias DeviceID = string;
MultiMap!(RsltData, HeaderInfo, DeviceID, const(TestID), ubyte) rsltMap;
bool[const(TestID)] dynMap;

struct HistoData
{
    const(TestID) id;
    double stdDev;
    double mean;
    double cpk;
    double[] values;
    double lolimit;
    double hilimit;

    string toString() const
    {
        import std.array;
        import std.conv;
        string s = "id = " ~ id.toString() ~ " mean = " ~ to!string(mean) ~ " stdDev = " ~ to!string(stdDev) ~ " Cpk = " ~ to!string(cpk) ~ "\n    " ~ to!string(values);
        return s;
    }
}

struct RsltData
{
    float rslt;
    float lolimit;
    float hilimit;
}

/*
private string fixSpecialChars(string filename)
{
    import std.string;
    auto p = filename.indexOf('/');
    string name = filename;
    if (p >= 0)
    {
        
    }
    return name;
}
*/

public void genSpreadsheet(CmdOptions options, StdfDB stdfdb, Config config)
{
    if (options.genHistogram) rsltMap = new MultiMap!(RsltData, HeaderInfo, DeviceID, const(TestID), ubyte);
    db = stdfdb;
    sitesMap = stdfdb.sitesMap;
    Workbook dummyWb = newWorkbook("");
    import std.array;
    import std.algorithm.sorting;
    import std.algorithm;
    string sfile = options.sfile;
    const bool separateFileForDevice = canFind(sfile, "%device%");
    const bool separateFileForLot = canFind(sfile, "%lot%");
    MultiMap!(Workbook, string, string) wbMap = new MultiMap!(Workbook, string, string)();
    foreach (key; stdfdb.deviceMap.keys)
    {
        Workbook wb;
        import std.string;
        if (separateFileForDevice && separateFileForLot)
        {
            string lot = replace(key.lot_id, '/', '%');
            string dev = replace(key.devName, '/', '%');
            lot = replace(lot, ' ', '_');
            dev = replace(dev, ' ', '_');
            string fname = replace(sfile, "%lot%", lot).replace("%device%", dev);
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
            string dev = replace(key.devName, '/', '%');
            dev = replace(dev, ' ', '_');
            string fname = replace(sfile, "%device%", dev);
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
            string lot = replace(key.lot_id, '/', '%');
            lot = replace(lot, ' ', '_');
            string dev = "";
            string fname = replace(sfile, "%lot%", lot);
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
                writeln("SORTING");
                multiSort!("a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) != 0", "a.tstamp < b.tstamp")(dr);
                break;
            case SN_DOWN_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_DOWN_TIME_UP:
                multiSort!("a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) == 0", "a.tstamp < b.tstamp")(dr);
                break;
            case SN_UP_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_UP_TIME_DOWN:
                multiSort!("a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) != 0", "a.tstamp > b.tstamp")(dr);
                break;
            case SN_DOWN_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SN_DOWN_TIME_DOWN:
                multiSort!("a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) == 0", "a.tstamp > b.tstamp")(dr);
                break;
            case SNN_UP_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_UP_TIME_UP:
                multiSort!("a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) < 0", "a.tstamp > b.tstamp")(dr);
                break;
            case SNN_DOWN_TIME_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_DOWN_TIME_UP:
                multiSort!("a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) > 0", "a.tstamp < b.tstamp")(dr);
                break;
            case SNN_UP_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_UP_TIME_DOWN:
                multiSort!("a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) < 0", "a.tstamp > b.tstamp")(dr);
                break;
            case SNN_DOWN_TIME_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case SNN_DOWN_TIME_DOWN:
                multiSort!("a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) > 0", "a.tstamp > b.tstamp")(dr);
                break;
            case TIME_UP_SN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SN_UP:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) != 0")(dr);
                break;
            case TIME_UP_SN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SN_DOWN:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) == 0")(dr);
                break;
            case TIME_DOWN_SN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SN_UP:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) != 0")(dr);
                break;
            case TIME_DOWN_SN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SN_DOWN:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(false).opCmp(b.devId.setNumeric(false)) == 0")(dr);
                break;
            case TIME_UP_SNN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SNN_UP:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) < 0")(dr);
                break;
            case TIME_UP_SNN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_UP_SNN_DOWN:
                multiSort!("a.tstamp < b.tstamp", "a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) > 0")(dr);
                break;
            case TIME_DOWN_SNN_UP_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SNN_UP:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) < 0")(dr);
                break;
            case TIME_DOWN_SNN_DOWN_NO_DUPS:
                removeDups = true;
                goto case;
            case TIME_DOWN_SNN_DOWN:
                multiSort!("a.tstamp > b.tstamp", "a.devId.setNumeric(true).opCmp(b.devId.setNumeric(true)) > 0")(dr);
                break;
            default: throw new Exception("Unsupported sort type");
        }
        DeviceResult[] devices;
        if (removeDups)
        {
            DeviceResult prevDevice;
            int i;
            for (i=0; i<dr.length; i++)
            {
                if (dr[i].devId == prevDevice.devId) continue;
                devices ~= prevDevice;
                prevDevice = dr[i];
            }
            if (devices[$-1].devId != prevDevice.devId) devices ~= prevDevice;
        }
        else devices = dr;
        // Now create the list of all tests in the test flow in the correct order. (Different devices may have slightly different test flows)
        string[const(TestID)] tmpmap;
        // determine the total number of unique TestIDs:
        foreach (dev; devices)
        {
            foreach (test; dev.tests)
            {
                tmpmap[test.id] = "1"; 
            }
        }
        size_t totalIds = tmpmap.length;
        TestRecord[const(TestID)][] normList;
        normList.length = totalIds;
        // Now find the number of different tests at each point in the flow:
        foreach (d, dev; devices)
        {
            foreach (t, test; dev.tests)
            {
                normList[t][test.id] = test;
            }
        }
        // Now figure out the order of the tests
        TestRecord[] testList;
        for (size_t i=0; i<normList.length; i++)
        {
            
            if (normList[i].length == 1)
            {
                foreach(k; normList[i].keys) testList ~= normList[i][k];
            }
            else
            {
                size_t[const(TestID)] depth;
                foreach(l, k; normList[i].keys)
                {
                    for (size_t j=i; j<normList.length; j++)
                    {
                        if (k in normList[j]) 
                        {
                            if (k !in depth)
                            {
                                depth[k] = j - i;
                            }
                            else
                            {
                                size_t x = depth[k];
                                x++;
                                depth[k] = x;
                            }
                        }
                    }
                }
                size_t minDepth = size_t.max;
                foreach(k; depth.keys)
                {
                    size_t s = depth[k];
                    if (s < minDepth) minDepth = s;
                }
                foreach(k; depth.keys)
                {
                    size_t s = depth[k];
                    if (s == minDepth) testList ~= normList[i][k];
                }
            }
        }
        // If there are dynamicLimits, then insert test headers for the upper and lower limits where appropriate
        TestRecord[] newCompTests;
        if (!options.noDynamicLimits)
        {
            foreach(test; testList)
            {
                if (test.dynamicLoLimit)
                {
                    auto type = TestType.DYNAMIC_LOLIMIT;
                    auto nid = TestID.getTestID(test.id.type, "LO LIMIT", test.id.testNumber, test.id.testName ~ " LO LIMIT", test.id.dup);
                    TestRecord r = new TestRecord(nid, type);
                    newCompTests ~= r;
                }
                newCompTests ~= test;
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
            newCompTests = testList;
        }
        // now build a row map that maps test ID to spreadsheet row:
        uint rc = 0;
        foreach(test; newCompTests)
        {
            rowOrColMap[test.id] = rc;
            rc++;
        }
        rowOrColMapTable[key] = rowOrColMap;
        //for (size_t n=0; n<devices.length; n++) devices[n].tests = newTests[n];
        deviceResults[key] = devices;
        foreach(dev; devices)
        {
            foreach(tr; dev.tests)
            {
                if (tr.type != TestType.PARAMETRIC && tr.type != TestType.FLOAT) continue;
                if (options.genHistogram)
                {
                    rsltMap.put(RsltData(tr.result.f, tr.loLimit, tr.hiLimit), key, dev.devId.getID(), tr.id, tr.site);
                    if (tr.id !in dynMap)
                    {
                        if (tr.dynamicLoLimit || tr.dynamicHiLimit) dynMap[tr.id] = true;
                    }
                }
            }
        }
        if (options.genSpreadsheet)
        {
            writeSheet(options, wb, rowOrColMap, key, devices, config);
        }
    } 
    foreach (xwb; wbMap.getValues()) xwb.close();
}

const(TestID)[] getTestIDs(HeaderInfo hdr)
{
    const(TestID)[] ts;
    LinkedMap!(const(TestID), uint) m = rowOrColMapTable[hdr];
    foreach(t; m.keys)
    {
        ts ~= t;
    }
    return ts;
}

unittest
{
    import itestinc.Stdf2xls;
    CmdOptions options = new CmdOptions(["stdf2xls", "-a", "-r", "-h", "stdf/rabbi.stdf"]);
    Config config = new Config();
    config.load();
    StdfFile[][HeaderInfo] stdfs = processStdf(options);
    StdfDB stdfdb = loadDb(options);
    genSpreadsheet(options, stdfdb, config);
    foreach (hdr; stdfdb.deviceMap.keys)
    {
        foreach(id; getTestIDs(hdr))
        {
            HistoData d = getResults(hdr, id);
            writeln(d.toString());
        }
    }
}

HistoData getResults(HeaderInfo hdr, const(TestID) testId)
{
    import std.math;
    double[] r;
    DeviceResult[] dr = deviceResults[hdr];
    ubyte[] sites = sitesMap[hdr];
    double sum = 0.0;
    uint n = 0;
    RsltData dummy = RsltData(-999999.0, -999999.0, -999999.0);
    foreach(s; sites)
    {
        foreach(d; dr)
        {
            auto rslt = rsltMap.get(dummy, hdr, d.devId.getID(), testId, s);
            if (rslt == dummy) continue;
            r ~= rslt.rslt;
            sum += rslt.rslt;
            n++;
        }
    }
    double mean = sum / n;
    sum = 0.0;
    foreach (v; r) sum += (v - mean) * (v - mean);
    double stdDev = sqrt(sum / (n - 1));
    // compute Cpk:
    double Cpk;
    double sl = 0.0;
    double sh = 0.0;
    double llmean = 0.0;
    double hlmean = 0.0;
    if (testId in dynMap) // dynamic limits
    {
        foreach(s; sites)
        {
            foreach(d; dr)
            {
                auto rslt = rsltMap.get(dummy, hdr, d.devId.getID(), testId, s);
                if (rslt == dummy) continue;
                llmean += (mean - rslt.lolimit);
                hlmean += (rslt.hilimit - mean);
            }
        }
        double llave = llmean / n;
        double hlave = hlmean / n;
        double cpk1 = llave / (3.0 * stdDev);
        double cpk2 = hlave / (3.0 * stdDev);
        Cpk = (cpk1 < cpk2) ? cpk1 : cpk2;
        return HistoData(testId, stdDev, mean, Cpk, r, llmean, hlmean);
    }
    else
    {
        double ll;
        double hl;
        foreach(s; sites)
        {
            bool exit = false;
            foreach(d; dr)
            {
                auto rslt = rsltMap.get(dummy, hdr, d.devId.getID(), testId, s);
                if (rslt == dummy) continue;
                ll = rslt.lolimit;
                hl = rslt.hilimit;
                llmean = ll;
                hlmean = hl;
                exit = true;
                break;
            }
            if (exit) break;
        }
        double cpk1 = (mean - ll) / (3.0 * stdDev);
        double cpk2 = (hl - mean) / (3.0 * stdDev);
        Cpk = (cpk1 < cpk2) ? cpk1 : cpk2;
    }
    return HistoData(testId, stdDev, mean, Cpk, r, llmean, hlmean);
}

HistoData getResults(HeaderInfo hdr, const(TestID) testId, ubyte site)
{
    import std.math;
    double[] r;
    DeviceResult[] dr = deviceResults[hdr];
    ubyte[] sites = sitesMap[hdr];
    double sum = 0.0;
    uint n = 0;
    RsltData dummy = RsltData(-999999.0, -999999.0, -999999.0);
    foreach(d; dr)
    {
        auto rslt = rsltMap.get(dummy, hdr, d.devId.getID(), testId, site);
        if (rslt == dummy) continue;
        r ~= rslt.rslt;
        sum += rslt.rslt;
        n++;
    }
    double mean = sum / n;
    sum = 0.0;
    foreach (v; r) sum += (v - mean) * (v - mean);
    double stdDev = sqrt(sum / (n - 1));
    // compute Cpk:
    double Cpk;
    double sl = 0.0;
    double sh = 0.0;
    double llmean = 0.0;
    double hlmean = 0.0;
    if (testId in dynMap) // dynamic limits
    {
        foreach(d; dr)
        {
            auto rslt = rsltMap.get(dummy, hdr, d.devId.getID(), testId, site);
            if (rslt == dummy) continue;
            llmean += (mean - rslt.lolimit);
            hlmean += (rslt.hilimit - mean);
        }
        double llave = llmean / n;
        double hlave = hlmean / n;
        double cpk1 = llave / (3.0 * stdDev);
        double cpk2 = hlave / (3.0 * stdDev);
        Cpk = (cpk1 < cpk2) ? cpk1 : cpk2;
        return HistoData(testId, stdDev, mean, Cpk, r, llmean, hlmean);
    }
    else
    {
        double ll;
        double hl;
        foreach(d; dr)
        {
            auto rslt = rsltMap.get(dummy, hdr, d.devId.getID(), testId, site);
            if (rslt == dummy) continue;
            ll = rslt.lolimit;
            hl = rslt.hilimit;
            llmean = ll;
            hlmean = hl;
            break;
        }
        double cpk1 = (mean - ll) / (3.0 * stdDev);
        double cpk2 = (hl - mean) / (3.0 * stdDev);
        Cpk = (cpk1 < cpk2) ? cpk1 : cpk2;
    }
    return HistoData(testId, stdDev, mean, Cpk, r, llmean, hlmean);
}

ubyte[] getSites(HeaderInfo hdr)
{
    return sitesMap[hdr];
}

private void scan(size_t tnum, const TestID id, const TestType type, DeviceResult[] devices, TestRecord[][] newTests)
{
    bool diff = false;
    TestID nextId;
    TestType nextType;
    for (size_t i=0; i<devices.length; i++)
    {
        if (tnum >= devices[i].tests.length) continue;
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
