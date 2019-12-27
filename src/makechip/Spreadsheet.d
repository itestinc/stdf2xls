module makechip.Spreadsheet;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import std.stdio;

public void genSpreadsheet(CmdOptions options, StdfDB stdfdb)
{
    import std.array;
    import std.algorithm.sorting;
    foreach (key; stdfdb.deviceMap.keys)
    {
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
        if (options.flowAnalysis)
        {
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
        }
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
