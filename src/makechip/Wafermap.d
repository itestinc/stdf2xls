module makechip.Wafermap;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import makechip.Config;
import makechip.Stdf2xls;
import std.stdio;

public void genWafermap(CmdOptions options, StdfDB stdfdb, Config config)
{
	uint[] hwbin;
	int[] x_coord;
	int[] y_coord;

	hwbin.length = 0;
	x_coord.length = 0;
	y_coord.length = 0;

	auto f = File("test_hwbin.txt", "w");
	auto g = File("test_partID.txt", "w");

	if(options.asciiDump) {
		// dump wafermap to ascii...
	}

	foreach(hdr; stdfdb.deviceMap.keys) {
		// useful header values
		writeln("hdr.wafer_id = ", hdr.wafer_id, "\n");
		writeln("hdr.devName = ", hdr.devName, "\n");
		writeln("hdr.temperature = ", hdr.temperature, "\n");
		writeln("hdr.step = ", hdr.step, "\n");

		foreach(i, dr; stdfdb.deviceMap[hdr]) {

			hwbin.length +=1;
			x_coord.length +=1;
			y_coord.length +=1;

			hwbin[i] = dr.hwbin;
			x_coord[i] = dr.devId.id.xy.x;
			y_coord[i] = dr.devId.id.xy.y;

			f.write(dr.hwbin, "\n");
			// g.write(dr.devId.id.sn, " (", dr.devId.id.xy.x, ", ", dr.devId.id.xy.y, ")\n");		// Std Exception
			g.write("(", dr.devId.id.xy.x, ", ", dr.devId.id.xy.y, ")\n");

		}
	}


	if(options.asciiDump) {
		// dump wafermap to ascii...
		writeln(hwbin);
		writeln(x_coord);
		writeln(y_coord);
	}

	// ASY Format
	// if(options.asy) {
	if(options.textDump) {

		import std.algorithm.sorting : topNIndex, sort;
		x_coord.sort();


		int[] index = new int[hwbin.length];
		import std.typecons : Yes;
		topNIndex(x_coord, index, Yes.sortOutput);


		int*[] ptrIndex = new int*[hwbin.length];
		topNIndex(x_coord, ptrIndex, Yes.sortOutput);
		writeln(ptrIndex);

		int[] xcoord_sorted = new int[hwbin.length];
		int[] hwbin_sorted = new int[hwbin.length];
		int[] ycoord_sorted = new int[hwbin.length];
		foreach(n, i;  index) {
			hwbin_sorted[n] = x_coord[i];
			ycoord_sorted[n] = x_coord[i];
			xcoord_sorted[n] = x_coord[i];
		}




	}

}

unittest {
	int[] arr;
	arr.length = 0;

	for(uint i=0;i<3;i++) {
		arr.length += 1;
		arr[i] = i + 10;
	}
	assert(arr[0]==10);
	assert(arr[1]==11);
	assert(arr[2]==12);

	writeln("Unit test passes");
}

/*

std.exception.ErrnoException@/usr/include/dlang/dmd/std/stdio.d(2938): Enforcement failed (Bad address)
----------------
/usr/include/dlang/dmd/std/exception.d:515 @safe void std.exception.bailOut!(std.exception.ErrnoException).bailOut(immutable(char)[], ulong, scope const(char)[]) [0x55ddde0f08d5]
/usr/include/dlang/dmd/std/exception.d:436 @safe int std.exception.enforce!(std.exception.ErrnoException).enforce!(int).enforce(int, lazy const(char)[], immutable(char)[], ulong) [0x55ddde0f50cd]
/usr/include/dlang/dmd/std/stdio.d:2938 @safe void std.stdio.File.LockingTextWriter.put!(immutable(char)[]).put(scope immutable(char)[]) [0x55ddde0f4fcb]
/usr/include/dlang/dmd/std/range/primitives.d:276 @safe void std.range.primitives.doPut!(std.stdio.File.LockingTextWriter, immutable(char)[]).doPut(ref std.stdio.File.LockingTextWriter, ref immutable(char)[]) [0x55ddde0f4f4e]
/usr/include/dlang/dmd/std/range/primitives.d:379 @safe void std.range.primitives.put!(std.stdio.File.LockingTextWriter, immutable(char)[]).put(ref std.stdio.File.LockingTextWriter, immutable(char)[]) [0x55ddde0f4f20]
/usr/include/dlang/dmd/std/stdio.d:1516 @safe void std.stdio.File.write!(immutable(char)[], immutable(char)[], int, immutable(char)[], int, immutable(char)[]).write(immutable(char)[], immutable(char)[], int, immutable(char)[], int, immutable(char)[]) [0x55ddde11307a]
src/makechip/Wafermap.d:68 void makechip.Wafermap.genWafermap(makechip.CmdOptions.CmdOptions, makechip.StdfDB.StdfDB, makechip.Config.Config) [0x55ddde22d986]
src/makechip/Stdf2xlsx.d:171 void makechip.Stdf2xls.genWafermap(makechip.CmdOptions.CmdOptions, makechip.Config.Config) [0x55ddde201c0f]
src/main.d:115 _Dmain [0x55ddde178a78]

*/