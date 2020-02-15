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

		// retrieve data
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

		// shift for indexing from origin
		int[] x_shifted = new int[x_coord.length];
		int[] y_shifted = new int[y_coord.length];
		x_shifted[] = x_coord[] - x_min;
		y_shifted[] = y_coord[] - y_min;

		// create empty 2D map
		const uint col = x_max + 1;
		const uint row = y_max + 1;
		uint[][] matrix_uint = new uint[][](row,col);	// pre-filled with zeros

		// fill map with hwbins
		uint goodbins = 0;
		uint badbins = 0;
		foreach(i, bin; hwbin) {
			matrix_uint[y_shifted[i]][x_shifted[i]] = bin;

			switch(bin) {
				case 1: goodbins++; break;
				default: badbins++; break;
			}
		}

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
		img_options.y_scale = (8.0 * 20.0) / ss_height;
		ws.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &img_options);
		//ws.insertImageOpt(cast(uint) 0, cast(ushort) 0, "itest_logo.png", &img_options);

		const short offset_row = 15;
		const short offset_col = 4;
		import std.conv : to;

		initFormats(wb, options, config);		// need this to load formats

		// write some headers. Note: logo takes up 7 rows, 3 cols.
		ws.write(8, 0, "wafer_id:", headerNameFmt);
		ws.write(9, 0, "lot_id:", headerNameFmt);
		ws.write(10, 0, "sublot_id:", headerNameFmt);
		ws.write(11, 0, "devName:", headerNameFmt);
		ws.write(12, 0, "temperature:", headerNameFmt);
		ws.write(13, 0, "step:", headerNameFmt);
		ws.write(14, 0, "row:", headerNameFmt);
		ws.write(15, 0, "col:", headerNameFmt);
		ws.write(16, 0, "good bins:", headerNameFmt);
		ws.write(17, 0, "bad bins:", headerNameFmt);
		ws.write(18, 0, "total bins:", headerNameFmt);

		ws.write(8, 1, hdr.wafer_id, headerValueFmt);
		ws.write(9, 1, hdr.lot_id, headerValueFmt);
		ws.write(10, 1, hdr.sublot_id, headerValueFmt);
		ws.write(11, 1, hdr.devName, headerValueFmt);
		ws.write(12, 1, hdr.temperature, headerValueFmt);
		ws.write(13, 1, hdr.step, headerValueFmt);
		ws.write(14, 1, row, headerValueFmt);
		ws.write(15, 1, col, headerValueFmt);
		ws.write(16, 1, goodbins, headerValueFmt);
		ws.write(17, 1, badbins, headerValueFmt);
		ws.write(18, 1, (goodbins+badbins), headerValueFmt);

		ws.mergeRange(8, 1, 8, 3, null);
		ws.mergeRange(9, 1, 9, 3, null);
		ws.mergeRange(10, 1, 10, 3, null);
		ws.mergeRange(11, 1, 11, 3, null);
		ws.mergeRange(12, 1, 12, 3, null);
		ws.mergeRange(13, 1, 13, 3, null);
		ws.mergeRange(14, 1, 14, 3, null);
		ws.mergeRange(15, 1, 15, 3, null);
		ws.mergeRange(16, 1, 16, 3, null);
		ws.mergeRange(17, 1, 17, 3, null);
		ws.mergeRange(18, 1, 18, 3, null);

		// dump in ASE format
		if(options.asciiDump) {
			writeln("hdr.wafer_id = ", hdr.wafer_id);
			writeln("hdr.lot_id = ", hdr.lot_id);
			writeln("hdr.sublot_id = ", hdr.sublot_id);
			writeln("hdr.devName = ", hdr.devName);
			writeln("hdr.temperature = ", hdr.temperature);
			writeln("hdr.step = ", hdr.step);
			writeln("row = ", row);
			writeln("col = ", col);
			writeln("good bins = ", goodbins);
			writeln("bad bins = ", badbins);
			writeln("total bins = ", goodbins+badbins);
		}

		const double colWidth = 2.0;
		const double rowWidth = 11.6;

		ws.setColumn(offset_col, cast(ushort) (col + offset_col + 1) , colWidth);		// -> 0.26"; +1 to include other-side col numbering
		ws.setRow(cast(uint)(offset_row), rowWidth);			// to include row numbering
		ws.setRow(cast(uint)(row + offset_row + 1), rowWidth);		// +1 to include other-side row numbering

		foreach(i, row_arr; matrix_uint) {

			ws.setRow(cast(uint)(i + offset_row + 1), rowWidth);		// -> 0.28"; set rows for all the bin squares

			ws.write(cast(uint)(i + offset_row + 1), cast(ushort)(offset_col), i, waferRowNumberFmt);	// write row numbers; +1 to not overlap the 0
			ws.write(cast(uint)(i + offset_row + 1), cast(ushort)(col + offset_col + 1), i, waferRowNumberFmt);	// write row numbers on other side

			foreach(j, val; row_arr) {

				ws.write(cast(uint)(offset_row), cast(ushort)(j + offset_col + 1), j, waferColNumberFmt); // write column numbers; +1 to not overlap the 0
				ws.write(cast(uint)(row + offset_row + 1), cast(ushort)(j + offset_col + 1), j, waferColNumberFmt); // write column numbers on other side

				switch(val) {
					case 0:
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!int(val), waferEmptyFmt);	//+1 for row,col numbering
						if(options.asciiDump) { write("."); }
						break;
					case 1:
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!int(val), waferPassFmt);
						if(options.asciiDump) { write("1"); }
						break;
					case 2:
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), to!int(val), waferFailFmt);
						if(options.asciiDump) { write("X"); }
						break;
					default:
						throw new Exception("Unknown bin numbering - shouldn't happen");
				}

				// TO DO:
				// add die color legend
				// !!: header location with respect to logo WILL change with different wafer sizes, due to changing row/col size

			}
			if(options.asciiDump) { write("\n"); }
		}

		wb.close();

	}

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
Excel 2007-2019
max rows = 2^20	= 1,048,576	-> uint @ 2^32
max cols = 2^14	= 16,384	-> ushort @ 2^16

Define new format in:
SpreadsheetWriter.d 	- new format name, format options
Config.d				- format option color names

why setting column is (first, last) ; setting row is just (one row) ??
*/
