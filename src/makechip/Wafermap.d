module makechip.Wafermap;
import makechip.StdfDB;
import makechip.StdfFile;
import makechip.Stdf;
import makechip.CmdOptions;
import makechip.Config;
import makechip.Stdf2xls;
import std.stdio;

import libxlsxd.workbook;
import libxlsxd.worksheet;
import libxlsxd.format;
import libxlsxd.xlsxwrap;
import makechip.logo;
import makechip.Util;
import makechip.SpreadsheetWriter;

/**
	Read from the STDF database to generate a wafer map in excel.
*/
public void genWafermap(CmdOptions options, StdfDB stdfdb, Config config)
{
	foreach(hdr; stdfdb.deviceMap.keys) {

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

		char[][] matrix = new char[][](row, col);		// inital val is 0xFF
		writeln("row = ", row);
		writeln("col = ", col);

		// do this only for ASY format, otherwise affects speed
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
					matrix[y_shifted[i]][x_shifted[i]] = '?'; badbins++; break;
					// throw new Exception("Unsupported HW bin number");
				case 1:
					matrix[y_shifted[i]][x_shifted[i]] = '1'; goodbins++; break;
				case 2:
					matrix[y_shifted[i]][x_shifted[i]] = 'X'; badbins++; break;
			}
		}

		// rotate 90
		char[][] mat_rot = new char[][](col, row);
		rotate90(matrix, mat_rot, row, col);

		if(options.asciiDump) {
			// useful header values
			writeln("hdr.wafer_id = ", hdr.wafer_id);
			writeln("hdr.lot_id = ", hdr.lot_id);
			writeln("hdr.sublot_id = ", hdr.sublot_id);
			writeln("hdr.devName = ", hdr.devName);
			writeln("hdr.temperature = ", hdr.temperature);
			writeln("hdr.step = ", hdr.step);
			// print map
			writeln("good bins = ", goodbins);
			writeln("bad bins = ", badbins);
			writeln("total bins = ", goodbins+badbins);
			foreach(n; matrix) {
				writeln(n);
			}
			// print rotated map
			writeln("rotated:");
			foreach(n; mat_rot) {
				writeln(n);
			}
		}

	// EXCEL
		import std.algorithm: canFind;
		string wfile = options.wfile;	// "<device>_<lot>_<wafer>"
		const bool separateFileForDevice = canFind(wfile, "<device>");
		const bool separateFileForLot = canFind(wfile, "<lot>");
		const bool separateFileForWafer = canFind(wfile, "<wafer>");
		
		import std.array : replace;
		string fname = replace(wfile, "<device>", hdr.devName).replace("<lot>", hdr.lot_id).replace("<wafer>", hdr.wafer_id);
		writeln("fname = ", fname);

		/*
		if(separateFileForDevice && separateFileForLot && separateFileForWafer) {
			import std.array : replace;
			fname = replace(wfile, "<device>", hdr.devName).replace("<lot>", hdr.lot_id).replace("<wafer>", hdr.wafer_id);
			writeln("fname = ", fname);
		}
		else {
			// ...
		}*/

		Workbook wb = newWorkbook(fname);
		auto ws = wb.addWorksheet("Page 1");

		lxw_image_options img_options;
		const double ss_width = 449 * 0.350;
		const double ss_height = 245 * 0.324;
		img_options.x_scale = (4.0 * 70.0) / ss_width;
		img_options.y_scale = (7.0 * 20.0) / ss_height;
		ws.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &img_options);
		//ws.insertImageOpt(cast(uint) 0, cast(ushort) 0, "itest_logo.png", &img_options);

		const short offset_row = 8;
		const short offset_col = 4;
		import std.conv : to;
		// ws.write(10, 10, "hello");
		initFormats(wb, options, config);		// need this to load formats
		ws.setColumn(offset_col, cast(ushort) (row + offset_col) , 1.0);		// -> 0.26" ; new_col = row

		foreach(i, row_arr; mat_rot) {

			ws.setRow(cast(uint)(i + offset_row), 10.0);		// -> 0.28"

			ws.write(cast(uint)(i + offset_row), cast(ushort)(offset_col), to!string(i), waferRowNumberFmt);	// write row numbers
			ws.write(cast(uint)(i + offset_row), cast(ushort)(row + offset_col + 1), to!string(i), waferRowNumberFmt);	// write row numbers ; new_col = row

			foreach(j, val; row_arr) {

				ws.write(cast(uint)(offset_row), cast(ushort)(j + offset_col), to!string(j), waferColNumberFmt); // write column numbers
				ws.write(cast(uint)(col + offset_row + 1), cast(ushort)(j + offset_col), to!string(j), waferColNumberFmt); // write column numbers ; new_row = col

				switch(val) {
					case 0xFF:
					case '.':
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!string(val), waferEmptyFmt);	//+1 for row,col numbering
						break;
					case '1':
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!string(val), waferPassFmt);
						break;
					case 'X':
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!string(val), waferFailFmt);
						break;
					case '?':
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!string(val), waferFailFmt);
						break;
					default:
						throw new Exception("Unknown bin numbering - shouldn't happen");
				}
				// set column width to 2
				// don't write '.'s.. maybe color gray

				// add color
				// center the text
				// combine with prev for loop to optimize time
			}
		}

		wb.close();

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

/**
	O(n^2)
*/
void transpose(char[][] a, char[][] b, uint row, uint col) {
	for(uint i = 0; i < row; i++) {
		for(uint j = 0; j < col; j++) {
			b[j][i] = a[i][j];
		}
	}
}

/**
	rotate 90 clockwise:
	1. transpose
	2. reverse each row
*/
void rotate90(char[][] a, char[][] b, uint row, uint col) {
	transpose(a, b, row, col);
	const uint new_row = col;
	const uint new_col = row;
	char[][] tmp = new char[][](new_row,new_col);

	foreach(x, rows; b) {
		tmp[new_row-x-1][] = rows;
	}
	b[] = tmp[];
}

/*

Excel 2007-2019
max rows = 2^20	= 1,048,576	-> uint @ 2^32
max cols = 2^14	= 16,384	-> ushort @ 2^16


Define new format in:
SpreadsheetWriter.d 	- new format name, format options
Config.d				- format option color names
*/