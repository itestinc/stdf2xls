module makechip.Wafermap;
import makechip.StdfDB;			// deviceMap, key
import makechip.StdfFile;		// HeaderInfo, StdfFile
import makechip.Stdf;			// rec
import makechip.CmdOptions;
import makechip.Config;
import makechip.Descriptors;	// record enums to cast
import makechip.Stdf2xls;
import std.stdio;

public void genWafermap(CmdOptions options, StdfDB stdfdb, Config config)
{
	int i = 0;
	int j = 0;
	int k = 0;
	int m = 0;

	ushort[] hwbin;
	int[] x_coord;
	int[] y_coord;
	hwbin.length = 0;
	x_coord.length = 0;
	y_coord.length = 0;

	StdfFile[][HeaderInfo] stdfs = processStdf(options);
	foreach (hdr; stdfs.keys)
	{
		i++;

		// <class>HeaderInfo member variables
		writeln("hdr.wafer_id = ", hdr.wafer_id, "\n");
		writeln("hdr.devName = ", hdr.devName, "\n");
		writeln("hdr.temperature = ", hdr.temperature, "\n");
		writeln("hdr.step = ", hdr.step, "\n");

		// StdfFile[] files = stdfs[hdr];
		foreach (file; stdfs[hdr]) 			// why twice?
		{
			foreach (rec; file.records)
			{
				if (rec.recordType == rec.recordType.PRR) {

					writeln( "type = ", rec.recordType);
					writeln( "reclen = ", rec.getReclen());
					writeln( "getBytes = ", rec.getBytes());            // <ubyte[]>
					writeln( "getHeaderBytes = ", rec.getHeaderBytes()); // <Appender!(ubyte[])>

					Record!PRR prr = cast(Record!PRR) rec;
					writeln( "HARD_BIN = ", prr.HARD_BIN);
					writeln( "X_COORD = ", prr.X_COORD);
					writeln( "Y_COORD = ", prr.Y_COORD);

					hwbin.length +=1;
					x_coord.length +=1;
					y_coord.length +=1;

					hwbin[m] = prr.HARD_BIN;
					x_coord[m] = prr.X_COORD;
					y_coord[m] = prr.Y_COORD;

					m++;
				}
				k++;
			}
			j++;
			break;
		}
	}



	writeln("i = ", i);		// 1
	writeln("j = ", j);		// 2 !!
	writeln("k = ", k);		// 10270
	writeln("m = ", m);		// 2
}
