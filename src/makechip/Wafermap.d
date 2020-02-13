module makechip.Wafermap;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import makechip.Config;
import makechip.Stdf2xls;
import std.stdio;

// O(n^2)
void transpose(char[][] a, char[][] b, uint row, uint col) {
	for(uint i = 0; i < row; i++) {
		for(uint j = 0; j < col; j++) {
			b[j][i] = a[i][j];
		}
	}
}

void rotate90(char[][] a, char[][] b, uint row, uint col) {
	//transpose
	transpose(a, b, row, col);

	// reverse each row
	const int new_row = col;
	const int new_col = row;
	char[][] tmp = new char[][](new_row,new_col);

	foreach(x, rows; b) {
		tmp[new_row-x-1][] = rows;
	}
	b[] = tmp[];

}

public void genWafermap(CmdOptions options, StdfDB stdfdb, Config config)
{

	foreach(hdr; stdfdb.deviceMap.keys) {
		// useful header values
		writeln("hdr.wafer_id = ", hdr.wafer_id);
		writeln("hdr.devName = ", hdr.devName);
		writeln("hdr.temperature = ", hdr.temperature);
		writeln("hdr.step = ", hdr.step);

		uint[] hwbin;
		int[] x_coord;
		int[] y_coord;
		hwbin.length = 0;
		x_coord.length = 0;
		y_coord.length = 0;

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

			// sort for min/max elements
			int[] x_sorted = x_coord.dup;
			int[] y_sorted = y_coord.dup;

			import std.algorithm.sorting : sort;
			x_sorted.sort();
			y_sorted.sort();

			const int x_min = x_sorted[0];
			const int y_min = y_sorted[0];
			const int x_max = x_sorted[$-1] - x_sorted[0];
			const int y_max = y_sorted[$-1] - y_sorted[0];

			// shift for indexing
			int[] x_shifted = new int[x_coord.length];
			int[] y_shifted = new int[y_coord.length];
			x_shifted[] = x_coord[] - x_min;
			y_shifted[] = y_coord[] - y_min;

			// create empty map
			const uint col = x_max + 1;
			const uint row = y_max + 1;

			char[][] matrix = new char[][](row, col);
			writeln("row = ", row);
			writeln("col = ", col);

			// pre-fill map with dots
			for(uint i = 0; i < row; i++) {
				for(uint j = 0; j < col; j++) {
					matrix[i][j] = '.';
				}
			}

			uint goodbins = 0;
			uint badbins = 0;
			// fill map with hwbins
			foreach(i, bin; hwbin) {
				switch(hwbin[i]) {
					default:
						// matrix[y_shifted[i]][x_shifted[i]] = '?'; break;
						throw new Exception("Unsupported HW bin number");
					case 1:
						matrix[y_shifted[i]][x_shifted[i]] = '1'; goodbins++; break;
					case 2:
						matrix[y_shifted[i]][x_shifted[i]] = 'X'; badbins++; break;
				}
			}

			// print map
			writeln("good bins = ", goodbins);
			writeln("bad bins = ", badbins);
			writeln("total bins = ", goodbins+badbins);
			foreach(n; matrix) {
				writeln(n);
			}

			char[][] mat_rot = new char[][](col, row);
			rotate90(matrix, mat_rot, row, col);

			foreach(n; mat_rot) {
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
