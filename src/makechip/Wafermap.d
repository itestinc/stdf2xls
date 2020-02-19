module makechip.Wafermap;
import makechip.StdfDB;
import makechip.CmdOptions;
import makechip.Config;
import makechip.logo;
import makechip.WafermapFormat;
import libxlsxd.workbook;
import std.stdio;

/**
	Read from the STDF database to generate a wafer map in excel.
	- option to dump wafer map in ascii ASE format
*/
public void genWafermap(CmdOptions options, StdfDB stdfdb, Config config)
{
	foreach(hdr; stdfdb.deviceMap.keys) {

		ushort[] hwbin;		// hwbin.length=0
		short[] x_coord;
		short[] y_coord;

		// Retrieve wafer data from STDF database.
		foreach(i, dr; stdfdb.deviceMap[hdr]) {
			hwbin.length +=1;
			x_coord.length +=1;
			y_coord.length +=1;
			hwbin[i] = cast(ushort)dr.hwbin;
			x_coord[i] = cast(short)dr.devId.id.xy.x;
			y_coord[i] = cast(short)dr.devId.id.xy.y;
		}

		// Sort to get min and max coordinates.
		short[] x_sorted = x_coord.dup;
		short[] y_sorted = y_coord.dup;
		import std.algorithm.sorting : sort;
		x_sorted.sort();
		y_sorted.sort();
		const short x_min = x_sorted[0];
		const short y_min = y_sorted[0];
		const short x_max = cast(short)(x_sorted[$-1] - x_sorted[0]);
		const short y_max = cast(short)(y_sorted[$-1] - y_sorted[0]);

		// Shift coordinates to start indexing from (0,0).
		short[] x_shifted = new short[x_coord.length];
		short[] y_shifted = new short[y_coord.length];
		x_shifted[] = x_coord[] - x_min;
		y_shifted[] = y_coord[] - y_min;

		// Create 2D array map of bins.
		ushort col = cast(ushort)(x_max + 1);
		ushort row = cast(ushort)(y_max + 1);
		ushort goodbins = 0;
		ushort badbins = 0;
		ushort[][] matrix_uint = new ushort[][](row,col);	// mat[][]=0

		foreach(i, bin; hwbin) {
			matrix_uint[y_shifted[i]][x_shifted[i]] = bin;

			switch(bin) {
				case 1: goodbins++; break;
				default: badbins++; break;
			}
		}

		// Rotate wafer according to option.
		ushort[][] matrix;
		string notch;							// save to string since compiler can't read 'options.notch' at compile time in order to 'ws.write'
		switch(options.notch) with (Notch)
		{
			case right:   // 0
				matrix = matrix_uint.dup;
				notch = "Right";
				break;
			case bottom:   // +90
				ushort[][] matrix_rot90 = new ushort[][](col,row);
				rotate90(matrix_uint, matrix_rot90);
				matrix = matrix_rot90.dup;
				if(row != col) {
					row ^= col;
					col ^= row;
					row ^= col;
				}
				notch = "Bottom";
				break;
			case left:   // +180
				ushort[][] matrix_rot180 = new ushort[][](row,col);
				rotate180(matrix_uint, matrix_rot180);
				matrix = matrix_rot180.dup;
				notch = "Left";
				break;
			case top:   // +270
				ushort[][] matrix_rot270 = new ushort[][](col,row);
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

		// Generate file name
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

		// Write headers to excel
		initWaferFormats(wb, options, config);
		ws.write( 8, 0, "wafer_id:", headerNameFmt);
		ws.write( 9, 0, "lot_id:", headerNameFmt);
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
		ws.write( 8, 1, hdr.wafer_id, headerValueFmt);
		ws.write( 9, 1, hdr.lot_id, headerValueFmt);
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
		ws.mergeRange( 8, 1,  8, 3, null);
		ws.mergeRange( 9, 1,  9, 3, null);
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

		// Set widths so that each bin cell is a square.
		const double colWidth = 2.29;
		const double rowWidth = 19.0;

		// Start drawing wafermap at defined offset cell position.
		const ushort offset_row = 1;
		const ushort offset_col = 5;

		ushort bin1 = 0;
		ushort bin2 = 0;
		ushort bin3 = 0;
		ushort bin4 = 0;
		ushort bin5 = 0;
		ushort bin6 = 0;
		ushort bin7 = 0;
		ushort bin8 = 0;
		ushort bin9 = 0;
		ushort bin10 = 0;
		ushort bin11 = 0;
		ushort bin12 = 0;
		ushort bin13 = 0;
		ushort bin14 = 0;
		ushort bin15 = 0;
		ushort bin16 = 0;

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
					case  0: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), "", waferEmptyFmt); break;    //+1 to write bins after row & col numbering
					case  1: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin01Fmt); bin1++; break;
					case  2: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin02Fmt); bin2++; break;
					case  3: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin03Fmt); bin3++; break;
					case  4: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin04Fmt); bin4++; break;
					case  5: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin05Fmt); bin5++; break;
					case  6: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin06Fmt); bin6++; break;
					case  7: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin07Fmt); bin7++; break;
					case  8: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin08Fmt); bin8++; break;
					case  9: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin09Fmt); bin9++; break;
					case 10: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin10Fmt); bin10++; break;
					case 11: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin11Fmt); bin11++; break;
					case 12: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin12Fmt); bin12++; break;
					case 13: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin13Fmt); bin13++; break;
					case 14: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin14Fmt); bin14++; break;
					case 15: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferBin15Fmt); bin15++; break;
					default: ws.write(cast(uint)(i + offset_row +1), cast(ushort)(j + offset_col+1), val, waferFailFmt); bin16++; break;
						// throw new Exception("Unknown bin numbering - shouldn't happen");
				}
				// TO DO:
				// add die color legend
				// !!: header location with respect to logo WILL change with different wafer sizes, due to changing row/col size
			}
		}
		// Set cell widths for row/col numbering cells.
		ws.setColumn(offset_col, cast(ushort) (col + offset_col + 1) , colWidth);
		ws.setRow(cast(uint)(offset_row), rowWidth);
		ws.setRow(cast(uint)(row + offset_row + 1), rowWidth);		// why setting column is (first, last) ; setting row is just (one row) ??

		ws.write(20, 0, "bin 1:", headerNameFmt);
		ws.write(21, 0, "bin 2:", headerNameFmt);
		ws.write(22, 0, "bin 3:", headerNameFmt);
		ws.write(23, 0, "bin 4:", headerNameFmt);
		ws.write(24, 0, "bin 5:", headerNameFmt);
		ws.write(25, 0, "bin 6:", headerNameFmt);
		ws.write(26, 0, "bin 7:", headerNameFmt);
		ws.write(27, 0, "bin 8:", headerNameFmt);
		ws.write(28, 0, "bin 9:", headerNameFmt);
		ws.write(29, 0, "bin 10:", headerNameFmt);
		ws.write(30, 0, "bin 11:", headerNameFmt);
		ws.write(31, 0, "bin 12:", headerNameFmt);
		ws.write(32, 0, "bin 13:", headerNameFmt);
		ws.write(33, 0, "bin 14:", headerNameFmt);
		ws.write(34, 0, "bin 15:", headerNameFmt);
		ws.write(35, 0, "other bins:", headerNameFmt);

		ws.write(20, 1, bin1, headerValueFmt);
		ws.write(21, 1, bin2, headerValueFmt);
		ws.write(22, 1, bin3, headerValueFmt);
		ws.write(23, 1, bin4, headerValueFmt);
		ws.write(24, 1, bin5, headerValueFmt);
		ws.write(25, 1, bin6, headerValueFmt);
		ws.write(26, 1, bin7, headerValueFmt);
		ws.write(27, 1, bin8, headerValueFmt);
		ws.write(28, 1, bin9, headerValueFmt);
		ws.write(29, 1, bin10, headerValueFmt);
		ws.write(30, 1, bin11, headerValueFmt);
		ws.write(31, 1, bin12, headerValueFmt);
		ws.write(32, 1, bin13, headerValueFmt);
		ws.write(33, 1, bin14, headerValueFmt);
		ws.write(34, 1, bin15, headerValueFmt);
		ws.write(35, 1, bin16, headerValueFmt);

		ws.write(20, 3, "", waferBin01Fmt);
		ws.write(21, 3, "", waferBin02Fmt);
		ws.write(22, 3, "", waferBin03Fmt);
		ws.write(23, 3, "", waferBin04Fmt);
		ws.write(24, 3, "", waferBin05Fmt);
		ws.write(25, 3, "", waferBin06Fmt);
		ws.write(26, 3, "", waferBin07Fmt);
		ws.write(27, 3, "", waferBin08Fmt);
		ws.write(28, 3, "", waferBin09Fmt);
		ws.write(29, 3, "", waferBin10Fmt);
		ws.write(30, 3, "", waferBin11Fmt);
		ws.write(31, 3, "", waferBin12Fmt);
		ws.write(32, 3, "", waferBin13Fmt);
		ws.write(33, 3, "", waferBin14Fmt);
		ws.write(34, 3, "", waferBin15Fmt);
		ws.write(35, 3, "", waferBin16Fmt);

		ws.mergeRange(20, 1, 20, 2, null);
		ws.mergeRange(21, 1, 21, 2, null);
		ws.mergeRange(22, 1, 22, 2, null);
		ws.mergeRange(23, 1, 23, 2, null);
		ws.mergeRange(24, 1, 24, 2, null);
		ws.mergeRange(25, 1, 25, 2, null);
		ws.mergeRange(26, 1, 26, 2, null);
		ws.mergeRange(27, 1, 27, 2, null);
		ws.mergeRange(28, 1, 28, 2, null);
		ws.mergeRange(29, 1, 29, 2, null);
		ws.mergeRange(30, 1, 30, 2, null);
		ws.mergeRange(31, 1, 31, 2, null);
		ws.mergeRange(32, 1, 32, 2, null);
		ws.mergeRange(33, 1, 33, 2, null);
		ws.mergeRange(34, 1, 34, 2, null);
		ws.mergeRange(35, 1, 35, 2, null);

		wb.close();

		// ASE
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

			foreach(i, row_arr; matrix) {
				foreach(j, val; row_arr) {
					switch(val) {
						case 0: write("."); break;
						case 1: write("1"); break;
						default: write("X"); break;
					}
				}
				write("\n");
			}
		}


	}
}

/**
	O(n^2)
*/
private void transpose(ushort[][] a, ushort[][] a_trans) {
	const ushort row = cast(ushort)a.length;
	const ushort col = cast(ushort)a[0].length;

	for(ushort i = 0; i < row; i++) {
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
public void rotate90(ushort[][] a, ushort[][] a_rot90) {
	const ushort row = cast(ushort)a.length;
	const ushort col = cast(ushort)a[0].length;

	ushort[][] a_rev = new ushort[][](row,col);
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
public void rotate270(ushort[][] a, ushort[][] a_rot90) {
	const ushort row = cast(ushort)a.length;
	const ushort col = cast(ushort)a[0].length;
	ushort[][] a_trans = new ushort[][](col,row);
	transpose(a, a_trans);
	
	const ushort new_row = cast(ushort)a_trans.length;
	foreach(r, rows; a_trans) {
		a_rot90[new_row - r - 1][] = rows;
	}
}

/**
	rotate 180 clockwise:
	1. rotate 90 twice
*/
public void rotate180(ushort[][] a, ushort[][] a_rot180) {
	const ushort row = cast(ushort)a.length;
	const ushort col = cast(ushort)a[0].length;
	ushort[][] temp = new ushort[][](col,row);
	rotate90(a, temp);
	rotate90(temp, a_rot180);
}


unittest {
	/*
	Excel 2007-2019
	max rows = 2^20	= 1,048,576	-> uint @ 2^32
	max cols = 2^14	= 16,384	-> ushort @ 2^16
	*/
}
