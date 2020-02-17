module makechip.Wafermap;
import makechip.StdfDB;
import makechip.CmdOptions;
import makechip.Config;
import makechip.logo;
import WafermapFormat;		// including module name gives error ?
import libxlsxd.workbook;
import std.stdio;

/**
	Read from the STDF database to generate a wafer map in excel.
	- option to dump wafer map in ascii ASE format
*/
public void genWafermap(CmdOptions options, StdfDB stdfdb, Config config)
{
	foreach(hdr; stdfdb.deviceMap.keys) {

		uint[] hwbin;		// default length is zero
		int[] x_coord;
		int[] y_coord;

		// Retrieve wafer data from STDF database.
		foreach(i, dr; stdfdb.deviceMap[hdr]) {
			hwbin.length +=1;
			x_coord.length +=1;
			y_coord.length +=1;
			hwbin[i] = dr.hwbin;
			x_coord[i] = dr.devId.id.xy.x;
			y_coord[i] = dr.devId.id.xy.y;
		}

		// Sort to get min and max coordinates.
		int[] x_sorted = x_coord.dup;
		int[] y_sorted = y_coord.dup;
		import std.algorithm.sorting : sort;
		x_sorted.sort();
		y_sorted.sort();
		const int x_min = x_sorted[0];
		const int y_min = y_sorted[0];
		const int x_max = x_sorted[$-1] - x_sorted[0];
		const int y_max = y_sorted[$-1] - y_sorted[0];

		// Shift coordinates to start indexing from (0,0).
		int[] x_shifted = new int[x_coord.length];
		int[] y_shifted = new int[y_coord.length];
		x_shifted[] = x_coord[] - x_min;
		y_shifted[] = y_coord[] - y_min;

		// Create 2D array map of bins.
		uint col = x_max + 1;
		uint row = y_max + 1;
		uint goodbins = 0;
		uint badbins = 0;
		uint[][] matrix_uint = new uint[][](row,col);	// pre-filled with zeros

		foreach(i, bin; hwbin) {
			matrix_uint[y_shifted[i]][x_shifted[i]] = bin;

			switch(bin) {
				case 1: goodbins++; break;
				default: badbins++; break;
			}
		}

		uint[][] matrix;
		string notch;		// save to string since compiler can't read 'options.notch' at compile time in order to 'ws.write'
		switch(options.notch) with (Notch)
		{
			case right: // 0
				matrix = matrix_uint.dup;
				notch = "Right";
				break;
			case bottom:	// +90
				uint[][] matrix_rot90 = new uint[][](col,row);
				rotate90(matrix_uint, matrix_rot90);
				matrix = matrix_rot90.dup;
				if(row != col) {
					row ^= col;
					col ^= row;
					row ^= col;
				}
				notch = "Bottom";
				break;
			case left: // +180
				uint[][] matrix_rot180 = new uint[][](row,col);
				rotate180(matrix_uint, matrix_rot180);
				matrix = matrix_rot180.dup;
				notch = "Left";
				break;
			case top: // +270
				uint[][] matrix_rot270 = new uint[][](col,row);
				rotate270(matrix_uint, matrix_rot270);
				matrix = matrix_rot270.dup;
				if(row != col) {
					row ^= col;
					col ^= row;
					row ^= col;
				}
				notch = "Top";
				break;
			default:
				throw new Exception("Invalid notch position");
		}

		import std.algorithm: canFind;
		string wfile = options.wfile;	// "<device>_<lot>_<wafer>"
		const bool separateFileForDevice = canFind(wfile, "<device>");
		const bool separateFileForLot = canFind(wfile, "<lot>");
		const bool separateFileForWafer = canFind(wfile, "<wafer>");
		
		import std.array : replace;
		string fname = replace(wfile, "<device>", hdr.devName).replace("<lot>", hdr.lot_id).replace("<wafer>", hdr.wafer_id);

		if(separateFileForDevice && separateFileForLot && separateFileForWafer) {
			import std.array : replace;
			fname = replace(wfile, "<device>", hdr.devName).replace("<lot>", hdr.lot_id).replace("<wafer>", hdr.wafer_id);
			writeln("fname = ", fname);
		}
		else {
			// ...
		}

		Workbook wb = newWorkbook(fname);
		auto ws = wb.addWorksheet("Sheet1");

		// Draw logo (7 rows, 3 cols)
		import libxlsxd.xlsxwrap : lxw_image_options, lxw_object_position;
		lxw_image_options img_options;
		const double ss_width = 449 * 0.350;
		const double ss_height = 245 * 0.324;
		img_options.x_scale = (4.0 * 70.0) / ss_width;
		img_options.y_scale = (8.0 * 20.0) / ss_height;
		ws.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &img_options);
		//ws.insertImageOpt(cast(uint) 0, cast(ushort) 0, "itest_logo.png", &img_options);

		// Write some headers..
		initWaferFormats(wb, options, config);

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
		ws.write(19, 0, "notch:", headerNameFmt);

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
		ws.write(19, 1, notch, headerValueFmt);

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
		ws.mergeRange(19, 1, 19, 3, null);

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
			writeln("notch = ", options.notch);
		}

		// Set widths so that each bin cell is a square.
		const double colWidth = 2.29;
		const double rowWidth = 15.0;

		// Start drawing wafermap at defined offset cell position.
		const ushort offset_row = 15;
		const ushort offset_col = 4;

		foreach(i, row_arr; matrix) {
			ws.setRow(cast(uint)(i + offset_row + 1), rowWidth);

			// Label row numbers on each side of the wafermap.
			ws.write(cast(uint)(i + offset_row + 1), cast(ushort)(offset_col), i, waferRowNumberFmt);
			ws.write(cast(uint)(i + offset_row + 1), cast(ushort)(col + offset_col + 1), i, waferRowNumberFmt);

			foreach(j, val; row_arr) {
				// Label column numbers on top and bottom of the wafermap.
				ws.write(cast(uint)(offset_row), cast(ushort)(j + offset_col + 1), j, waferColNumberFmt);
				ws.write(cast(uint)(row + offset_row + 1), cast(ushort)(j + offset_col + 1), j, waferColNumberFmt);

				switch(val) {
					case 0:
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), "", waferEmptyFmt);    //+1 to write bins after row & col numbering
						if(options.asciiDump) { write("."); }
						break;
					case 1:
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferPassFmt);
						if(options.asciiDump) { write("1"); }
						break;
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
					case 10:
						ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferFailFmt);
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

		// Set cell widths for row/col numbering cells.
		ws.setColumn(offset_col, cast(ushort) (col + offset_col + 1) , colWidth);
		ws.setRow(cast(uint)(offset_row), rowWidth);
		ws.setRow(cast(uint)(row + offset_row + 1), rowWidth);		// why setting column is (first, last) ; setting row is just (one row) ??

		wb.close();
	}
}

/**
	O(n^2)
*/
private void transpose(uint[][] a, uint[][] a_trans) {
	const uint row = cast(uint)a.length;
	const ushort col = cast(ushort)a[0].length;

	for(uint i = 0; i < row; i++) {
		for(ushort j = 0; j < col; j++) {
			a_trans[j][i] = a[i][j];
		}
	}
}

/**
	rotate 90 clockwise:
	1. reverse each row
	2. transpose
*/
public void rotate90(uint[][] a, uint[][] a_rot90) {
	const uint row = cast(uint)a.length;
	const ushort col = cast(ushort)a[0].length;

	uint[][] a_rev = new uint[][](row,col);
	foreach(r, rows; a) {
		a_rev[row - r - 1][] = rows;
	}

	transpose(a_rev, a_rot90);
}

/**
	rotate 270 clockwise:
	1. transpose
	2. reverse each row (which is column after transposing)
*/
public void rotate270(uint[][] a, uint[][] a_rot90) {
	const uint row = cast(uint)a.length;
	const ushort col = cast(ushort)a[0].length;
	uint[][] a_trans = new uint[][](col,row);
	transpose(a, a_trans);

	const ushort new_row = cast(ushort)a_trans.length;
	const ushort new_col = cast(ushort)a_trans[0].length;

	assert(new_row == col);
	assert(new_col == row);

	foreach(r, rows; a_trans) {
		a_rot90[new_row - r - 1][] = rows;
	}
}

/**
	rotate 180 clockwise:
	1. rotate 90 twice
*/
public void rotate180(uint[][] a, uint[][] a_rot180) {
	const uint row = cast(uint)a.length;
	const ushort col = cast(ushort)a[0].length;
	uint[][] temp = new uint[][](col,row);
	rotate90(a, temp);
	rotate90(temp, a_rot180);
}


unittest {

}

/*
Excel 2007-2019
max rows = 2^20	= 1,048,576	-> uint @ 2^32
max cols = 2^14	= 16,384	-> ushort @ 2^16
*/
