import makechip.Stdf;
import std.typecons;
/**
    An STDF file may contain one or more devices.  The lot identifier
    is obtained in the following order:

    Legacy header DTR:  "STEP #: <step>"
    Header field  DTR   ">>> STEP #: <step>"
    MIR lot_id field
    Legacy header DTR:  "DEVICE_NUMBER: <device>"
    Header field DTR:   "<<< DEVICE_NUMBER: <device>
    and WIR.wafer_id if available
    --------------------------------------------------------------------

    The device serial ID is identified as follows:
    TEXT_DATA : S/N : <serial_id>  (DTR)
    PIR.part_id field or PRR.x_coord and PRR.y_cooir
    All devices will also get a time stamp equal to MIR.start_t + site_num * PRR.test_t / num_sites
    where site numbers are 1-based

    --------------------------------------------------------------------
    Each test will get a test id

*/
struct StdfFile
{

    this(string filename, Flag!"textDump" textDump, Flag!"byteDump" byteDump)
    {
        StdfReader stdf = new StdfReader(No.textDump, No.byteDump, name);
        stdf.read();
        StdfRecord[] rs = stdf.getRecords();
    }
