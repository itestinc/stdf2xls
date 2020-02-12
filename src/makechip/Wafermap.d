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

	foreach(hdr; stdfdb.deviceMap.keys) {
		// useful header values
		writeln("hdr.wafer_id = ", hdr.wafer_id);
		writeln("hdr.devName = ", hdr.devName);
		writeln("hdr.temperature = ", hdr.temperature);
		writeln("hdr.step = ", hdr.step);

		foreach(i, dr; stdfdb.deviceMap[hdr]) {

			hwbin.length +=1;
			x_coord.length +=1;
			y_coord.length +=1;

			hwbin[i] = dr.hwbin;
			x_coord[i] = dr.devId.id.xy.x;
			y_coord[i] = dr.devId.id.xy.y;
		}

		// ASY Format
		// if(options.asy) {
		if(options.asciiDump) {

			// sort to get min element
			int[] x_sorted = x_coord.dup;
			int[] y_sorted = y_coord.dup;

			import std.algorithm.sorting : sort;
			x_sorted.sort();
			y_sorted.sort();

			// shift
			const int x_min = x_sorted[0];
			const int y_min = y_sorted[0];

			const ulong size = hwbin.length;

			int[] x_shifted = new int[size];
			int[] y_shifted = new int[size];

			x_shifted[] = x_coord[] - x_min;
			y_shifted[] = y_coord[] - y_min;

			int[] x_sorted_shifted = x_sorted.dup;
			int[] y_sorted_shifted = y_sorted.dup;

			x_sorted_shifted[] = x_sorted[] - x_min;
			y_sorted_shifted[] = y_sorted[] - y_min;

			// empty map
			const int col = x_sorted_shifted[$-1] + 1;
			const int row = y_sorted_shifted[$-1] + 1;

			char[][] matrix = new char[][](row, col);
			writeln("row = ", row);
			writeln("col = ", col);

			// fill with dots
			for(int i = 0; i < row; i++) {
				for(int j = 0; j < col; j++) {
					matrix[i][j] = '.';
				}
			}

			// fill map
			foreach(i, bin; hwbin) {
				switch(hwbin[i]) {
					default:
						// matrix[y_shifted[i]][x_shifted[i]] = '?'; break;
						throw new Exception("Unsupported HW bin number");
					case 1:
						matrix[y_shifted[i]][x_shifted[i]] = '1'; break;
					case 2:
						matrix[y_shifted[i]][x_shifted[i]] = 'X'; break;
				}
			}

			// print map
			foreach(n; matrix) {
				writeln(n);
			}

		}
	}

	if(options.asciiDump) {
		// dump wafermap to ascii...
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
