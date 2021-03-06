module itestinc.Wafermap;
import itestinc.StdfDB;
import itestinc.CmdOptions;
import itestinc.Config;
import itestinc.logo;
import itestinc.WafermapFormat;
import itestinc.Spreadsheet;

import libxlsxd.workbook;
import libxlsxd.worksheet;

import std.stdio;
import std.math : round;
import std.conv : to;
import std.algorithm: canFind;
import std.array : replace;
import std.algorithm.sorting : sort;

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
			if(dr.hwbin == 65535) { writeln("WARNING: One of your HW bins carries a value of -1. Something may have gone wrong during wafer probing."); }
			else if(dr.hwbin > 65000) { writefln("WARNING: Your datalog contains an unusually high HW bin value that may have underflowed from a negative number: %s", dr.hwbin); }
			hwbin[i] = cast(ushort)dr.hwbin;
			x_coord[i] = cast(short)dr.devId.id.xy.x;
			y_coord[i] = cast(short)dr.devId.id.xy.y;
		}

		// Sort to get min and max coordinates.
		short[] x_sorted = x_coord.dup;
		short[] y_sorted = y_coord.dup;
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
		ushort col = cast(ushort)(x_max + 1);				// Excel 2007-2019: max rows = 2^20	= 1,048,576	-> uint @ 2^32
		ushort row = cast(ushort)(y_max + 1);				// Excel 2007-2019: max cols = 2^14	= 16,384	-> ushort @ 2^16
		ushort[][] matrix_org = new ushort[][](row,col);	// initial mat[][] = 0
		foreach(i, bin; hwbin) {
			matrix_org[y_shifted[i]][x_shifted[i]] = bin;
		}

		// Rotate wafer according to option.
		ushort[][] matrix;
		switch(options.rotateWafer)
		{
			case 0:
				matrix = matrix_org.dup;
				break;
			case -270:
			case 90:
				ushort[][] matrix_rot90 = new ushort[][](col,row);
				rotate90(matrix_org, matrix_rot90);
				matrix = matrix_rot90.dup;
				if(row != col) {
					row ^= col;
					col ^= row;
					row ^= col;
				}
				break;
			case -180:
			case 180:
				ushort[][] matrix_rot180 = new ushort[][](row,col);
				rotate180(matrix_org, matrix_rot180);
				matrix = matrix_rot180.dup;
				break;
			case -90:
			case 270:
				ushort[][] matrix_rot270 = new ushort[][](col,row);
				rotate270(matrix_org, matrix_rot270);
				matrix = matrix_rot270.dup;
				if(row != col) {
					row ^= col;
					col ^= row;
					row ^= col;
				}
				break;
			default:
				throw new Exception("Invalid wafer rotation. Must be +/- 0, 90, 180, or 270.");
		}

		// Generate file name
		string wfile = options.wfile;
		const bool separateFileForDevice = canFind(wfile, "%device%");
		const bool separateFileForLot = canFind(wfile, "%lot%");
		const bool separateFileForWafer = canFind(wfile, "%wafer%");

		// handle invalid characters for filename
		string devName = replace(hdr.devName, " ", "-");
		devName = replace(devName, "/", "-");
		string waferID = replace(hdr.wafer_id, " ", "-");
		waferID = replace(waferID, "/", "-");
		string lotID = replace(hdr.lot_id, " ", "-");
		lotID = replace(lotID, "/", "-");

		string fname = replace(wfile, "%device%", devName).replace("%lot%", lotID).replace("%wafer%", waferID);
		if(separateFileForDevice && separateFileForLot && separateFileForWafer) {
			fname = replace(wfile, "%device%", devName).replace("%lot%", lotID).replace("%wafer%", waferID);
		}
		else {
			// ...
		}

		Workbook wb = newWorkbook(fname);
		Worksheet ws1 = wb.addWorksheet("HW Bins");
		Worksheet ws3 = wb.addWorksheet("Bin Filter (experimental)");

		// Draw logo (7 rows, 3 cols)
		import libxlsxd.xlsxwrap : lxw_image_options, lxw_object_position;
		lxw_image_options img_options;
		const double ss_width = 449 * 0.350;
		const double ss_height = 245 * 0.324;
		img_options.x_scale = (4.0 * 70.0) / ss_width;
		img_options.y_scale = (7.0 * 20.0) / ss_height;
		ws1.mergeRange(0, 0, 7, 3, null);
		img_options.object_position = lxw_object_position.LXW_OBJECT_MOVE_AND_SIZE;
		ws1.insertImageBufferOpt(cast(uint) 0, cast(ushort) 0, img.dup.ptr, img.length, &img_options);

		// Write headers to excel
		initWaferFormats(wb, options, config);
		ws1.mergeRange( 8, 0,  8, 1, "Wafer ID:", headerNameFmt);
		ws1.mergeRange( 9, 0,  9, 1, "Lot ID:", headerNameFmt);
		ws1.mergeRange(10, 0, 10, 1, "Sublot ID:", headerNameFmt);
		ws1.mergeRange(11, 0, 11, 1, "Device Name:", headerNameFmt);
		ws1.mergeRange(12, 0, 12, 1, "Temperature:", headerNameFmt);
		ws1.mergeRange(13, 0, 13, 1, "Step:", headerNameFmt);
		ws1.mergeRange(14, 0, 14, 1, "Rows:", headerNameFmt);
		ws1.mergeRange(15, 0, 15, 1, "Columns:", headerNameFmt);
		ws1.mergeRange(16, 0, 16, 1, "Rotation:", headerNameFmt);
		ws1.mergeRange(17, 0, 17, 1, "Good Bins:", headerNameFmt);
		ws1.mergeRange(18, 0, 18, 1, "Bad Bins:", headerNameFmt);
		ws1.mergeRange(19, 0, 19, 1, "Total Bins:", headerNameFmt);
		ws1.mergeRange( 8, 2,  8, 3, hdr.wafer_id, headerValueFmt);
		ws1.mergeRange( 9, 2,  9, 3, hdr.lot_id, headerValueFmt);
		ws1.mergeRange(10, 2, 10, 3, hdr.sublot_id, headerValueFmt);
		ws1.mergeRange(11, 2, 11, 3, hdr.devName, headerValueFmt);
		ws1.mergeRange(12, 2, 12, 3, hdr.temperature, headerValueFmt);
		ws1.mergeRange(13, 2, 13, 3, hdr.step, headerValueFmt);
		ws1.mergeRange(14, 2, 14, 3, to!string(row), headerValueFmt);
		ws1.mergeRange(15, 2, 15, 3, to!string(col), headerValueFmt);
		ws1.mergeRange(16, 2, 16, 3, to!string(options.rotateWafer)~" deg", headerValueFmt);
		
		// Set widths so that each bin cell is a square.
		const double colWidth = 2.29;
		const double rowWidth = 15;

		for(uint i = 0; i < 37; i++) {
			ws1.setRow(i, rowWidth);	// consistent header size for any wafer size
		}

		// Start drawing wafermap at defined offset cell position.
		const ushort offset_row = 2;
		const ushort offset_col = 7;

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
		ushort bin16 = 0;	// other bins

		foreach(i, row_arr; matrix) {
			ws1.setRow(cast(uint)(i + offset_row), rowWidth);
			ws3.setRow(cast(uint)(i + offset_row), rowWidth);

			// Label row numbers on each side of the wafermap.
			ws1.write(cast(uint)(i + offset_row), cast(ushort)(offset_col - 1), i, waferRowNumberFmt);
			ws1.write(cast(uint)(i + offset_row), cast(ushort)(col + offset_col), i, waferRowNumberFmt);

			ws3.write(cast(uint)(i + offset_row), cast(ushort)(offset_col - 1), i, waferRowNumberFmt);
			ws3.write(cast(uint)(i + offset_row), cast(ushort)(col + offset_col), i, waferRowNumberFmt);

			foreach(j, val; row_arr) {

				// Label column numbers on top and bottom of the wafermap.
				ws1.write(cast(uint)(offset_row - 1), cast(ushort)(j + offset_col), j, waferColNumberFmt);
				ws1.write(cast(uint)(row + offset_row), cast(ushort)(j + offset_col), j, waferColNumberFmt);

				ws3.write(cast(uint)(offset_row - 1), cast(ushort)(j + offset_col), j, waferColNumberFmt);
				ws3.write(cast(uint)(row + offset_row), cast(ushort)(j + offset_col), j, waferColNumberFmt);

				switch(val) {
					case  0: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferEmptyFmt); break;
					case  1: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin01Fmt); bin1++; break;
					case  2: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin02Fmt); bin2++; break;
					case  3: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin03Fmt); bin3++; break;
					case  4: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin04Fmt); bin4++; break;
					case  5: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin05Fmt); bin5++; break;
					case  6: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin06Fmt); bin6++; break;
					case  7: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin07Fmt); bin7++; break;
					case  8: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin08Fmt); bin8++; break;
					case  9: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin09Fmt); bin9++; break;
					case 10: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin10Fmt); bin10++; break;
					case 11: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin11Fmt); bin11++; break;
					case 12: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin12Fmt); bin12++; break;
					case 13: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin13Fmt); bin13++; break;
					case 14: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin14Fmt); bin14++; break;
					case 15: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col),  val, waferBin15Fmt); bin15++; break;
					case 65_535: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), -1, waferBin16Fmt); bin16++; break;
					default: ws1.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), val, waferBin16Fmt); bin16++;
				}

				switch(val) {
					case  0: ws3.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), "", waferEmptyFmt); break;
					default: ws3.write(cast(uint)(i + offset_row), cast(ushort)(j + offset_col), "", blankBinFmt);
				}
			}
		}
		// set row/col width for label numbers
		ws1.setColumn(cast(ushort)(offset_col - 2), cast(ushort)(col + offset_col + 1), colWidth);
		ws1.setRow(cast(uint)(offset_row - 1), rowWidth);
		ws1.setRow(cast(uint)(row + offset_row), rowWidth);

		ws3.setColumn(cast(ushort)(offset_col - 2), cast(ushort)(col + offset_col + 1), colWidth);
		ws3.setRow(cast(uint)(offset_row - 1), rowWidth);
		ws3.setRow(cast(uint)(row + offset_row), rowWidth);

		// write bin counts to headers
		uint goodbins = bin1;
		uint badbins = bin2+bin3+bin4+bin5+bin6+bin7+bin8+bin9+bin10+bin11+bin12+bin13+bin14+bin15+bin16;
		const double good_per = round(100*goodbins/(goodbins+badbins));
		const double bad_per = round(100*badbins/(goodbins+badbins));
		
		ws1.mergeRange(17, 2, 17, 3, to!string(goodbins)~" ("~to!string(good_per)~"%)", headerValueFmt);
		ws1.mergeRange(18, 2, 18, 3, to!string(badbins)~" ("~to!string(bad_per)~"%)", headerValueFmt);
		ws1.write(19, 2, (goodbins+badbins), headerValueFmt);
		ws1.mergeRange(19, 2, 19, 3, null);

		ws1.mergeRange(20, 0, 20, 1, "bin 1:", headerNameFmt);
		ws1.mergeRange(21, 0, 21, 1, "bin 2:", headerNameFmt);
		ws1.mergeRange(22, 0, 22, 1, "bin 3:", headerNameFmt);
		ws1.mergeRange(23, 0, 23, 1, "bin 4:", headerNameFmt);
		ws1.mergeRange(24, 0, 24, 1, "bin 5:", headerNameFmt);
		ws1.mergeRange(25, 0, 25, 1, "bin 6:", headerNameFmt);
		ws1.mergeRange(26, 0, 26, 1, "bin 7:", headerNameFmt);
		ws1.mergeRange(27, 0, 27, 1, "bin 8:", headerNameFmt);
		ws1.mergeRange(28, 0, 28, 1, "bin 9:", headerNameFmt);
		ws1.mergeRange(29, 0, 29, 1, "bin 10:", headerNameFmt);
		ws1.mergeRange(30, 0, 30, 1, "bin 11:", headerNameFmt);
		ws1.mergeRange(31, 0, 31, 1, "bin 12:", headerNameFmt);
		ws1.mergeRange(32, 0, 32, 1, "bin 13:", headerNameFmt);
		ws1.mergeRange(33, 0, 33, 1, "bin 14:", headerNameFmt);
		ws1.mergeRange(34, 0, 34, 1, "bin 15:", headerNameFmt);
		ws1.mergeRange(35, 0, 35, 1, "other:", headerNameFmt);

		ws1.write(20, 2, bin1, headerValueFmt);
		ws1.write(21, 2, bin2, headerValueFmt);
		ws1.write(22, 2, bin3, headerValueFmt);
		ws1.write(23, 2, bin4, headerValueFmt);
		ws1.write(24, 2, bin5, headerValueFmt);
		ws1.write(25, 2, bin6, headerValueFmt);
		ws1.write(26, 2, bin7, headerValueFmt);
		ws1.write(27, 2, bin8, headerValueFmt);
		ws1.write(28, 2, bin9, headerValueFmt);
		ws1.write(29, 2, bin10, headerValueFmt);
		ws1.write(30, 2, bin11, headerValueFmt);
		ws1.write(31, 2, bin12, headerValueFmt);
		ws1.write(32, 2, bin13, headerValueFmt);
		ws1.write(33, 2, bin14, headerValueFmt);
		ws1.write(34, 2, bin15, headerValueFmt);
		ws1.write(35, 2, bin16, headerValueFmt);

		ws1.write(20, 3, 1, waferBin01Fmt);
		ws1.write(21, 3, 2, waferBin02Fmt);
		ws1.write(22, 3, 3, waferBin03Fmt);
		ws1.write(23, 3, 4, waferBin04Fmt);
		ws1.write(24, 3, 5, waferBin05Fmt);
		ws1.write(25, 3, 6, waferBin06Fmt);
		ws1.write(26, 3, 7, waferBin07Fmt);
		ws1.write(27, 3, 8, waferBin08Fmt);
		ws1.write(28, 3, 9, waferBin09Fmt);
		ws1.write(29, 3, 10, waferBin10Fmt);
		ws1.write(30, 3, 11, waferBin11Fmt);
		ws1.write(31, 3, 12, waferBin12Fmt);
		ws1.write(32, 3, 13, waferBin13Fmt);
		ws1.write(33, 3, 14, waferBin14Fmt);
		ws1.write(34, 3, 15, waferBin15Fmt);
		ws1.write(35, 3, 16, waferBin16Fmt);

		// experimental bin filter using data validation
		ws3.mergeRange(5, 0, 5, 3, "2. Enter the desired bin number to filter:", headerNameFmt);
		ws3.write(6, 3, 1, blankBinFmt);

		import libxlsxd.xlsxwrap : lxw_data_validation, lxw_validation_types;
		lxw_data_validation validator;
		//validator.validate = lxw_validation_types.LXW_VALIDATION_TYPE_LIST;
		//string[] list = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];
		//char* val_list = cast(char*)(list);
		//validator.value_list = &val_list;

		validator.validate = lxw_validation_types.LXW_VALIDATION_TYPE_LIST_FORMULA;
		char* list = cast(char*)"=Wafermap!$D$21:$D$36";
		validator.value_formula = list;
		ws3.dataValidationCell(6, 3, &validator);
		ws3.mergeRange(offset_row, cast(ushort)(offset_col - 3), offset_row, cast(ushort)(offset_col - 1), "1. Apply this formula →", headerNameFmt);
		string formula = "=IF(Wafermap!G3:BY73=$D$7, $D$7, \"\")";
		ws3.writeArrayFormula(offset_row, offset_col, offset_row, offset_col, formula, waferBin01Fmt);
		//ws3.writeFormulaNumImpl(offset_row, offset_col, "=IF(Colored!G3:BY73=$A$2, $A$2, \"\")", -999, waferEmptyFmt);	// both works.
		//ws2.write(2, 6, "=IF(Sheet1!G10:BY80=$A$2, $A$2, \"\")", headerValueFmt);	// only works in Microsoft Excel. Not working on libreoffice/openoffice.
		//ws3.write(2, 6, "=IF(Colored!G3:BY73=$A$2, $A$2, \"\")", waferEmptyFmt);

		ws3.hide();
		wb.close();

		if(options.dumpAscii) {
			switch(options.wformat) with (WafermapFormat_t) {
			case ASY:
				writeln("wafer_id: ", hdr.wafer_id);
				writeln("lot_id: ", hdr.lot_id);
				writeln("sublot_id: ", hdr.sublot_id);
				writeln("device_name: ", hdr.devName);
				writeln("temperature: ", hdr.temperature);
				writeln("step: ", hdr.step);
				writeln("row: ", row);
				writeln("col: ", col);
				writeln("rotation: ", options.rotateWafer);
				writeln("good_bins: ", goodbins);
				writeln("bad_bins: ", badbins);
				writeln("total_bins: ", goodbins+badbins);

				foreach(i, row_arr; matrix) {
					foreach(j, val; row_arr) {
						switch(val) {
							case 0: write("."); break;
							case 1: write("1"); break;
							default: write("X");
						}
					}
					write("\n");
				}
				break;
			case SINF:
				writeln("wafer_id: ", hdr.wafer_id);
				writeln("lot_id: ", hdr.lot_id);
				writeln("sublot_id: ", hdr.sublot_id);
				writeln("device_name: ", hdr.devName);
				writeln("temperature: ", hdr.temperature);
				writeln("step: ", hdr.step);
				writeln("row: ", row);
				writeln("col: ", col);
				writeln("rotation: ", options.rotateWafer);
				writeln("good_bins: ", goodbins);
				writeln("bad_bins: ", badbins);
				writeln("total_bins: ", goodbins+badbins);

				foreach(i, row_arr; matrix) { write("RowData:");
					foreach(j, val; row_arr) {
						switch(val) {
							case  0: write("__ "); break;
							case  1: write("01 "); break;
							case  2: write("02 "); break;
							case  3: write("03 "); break;
							case  4: write("04 "); break;
							case  5: write("05 "); break;
							case  6: write("06 "); break;
							case  7: write("07 "); break;
							case  8: write("08 "); break;
							case  9: write("09 "); break;
							case 10: write("0A "); break;
							case 11: write("0B "); break;
							case 12: write("0C "); break;
							case 13: write("0D "); break;
							case 14: write("0E "); break;
							case 15: write("0F "); break;
							case 16: write("10 "); break;
							case -1: write("ER "); break;
							default: write("__ ");
						}
					}
					write("\n");
				}
				break;
			case SINF_SENTONS:
				writeln("DEVICE:", hdr.devName);
				writeln("LOT:", hdr.lot_id);
				writeln("WAFER:", hdr.wafer_id);
				writeln("FNLOC:", options.rotateWafer);
				writeln("ROWCT:", row);
				writeln("COLCT:", col);
				writeln("BCEQU:", "000");
				writeln("REFPX:");
				writeln("REFPY:");
				writeln("DUTMS:");
				writeln("XDIES:");
				writeln("YDIES:");
				foreach(i, row_arr; matrix) { write("RowData:");
					foreach(j, val; row_arr) {
						switch(val) {
							case  0: write("___ "); break;
							case  1: write("000 "); break;
							case  2: write("002 "); break;
							case  3: write("003 "); break;
							case  4: write("004 "); break;
							case  5: write("005 "); break;
							case  6: write("006 "); break;
							case  7: write("007 "); break;
							case  8: write("008 "); break;
							case  9: write("009 "); break;
							case 10: write("00A "); break;
							case 11: write("00B "); break;
							case 12: write("00C "); break;
							case 13: write("00D "); break;
							case 14: write("00E "); break;
							case 15: write("00F "); break;
							case 16: write("010 "); break;
							case -1: write("ERR "); break;
							default: write("___ ");
						}
					}
					write("\n");
				}
				break;
			case MICROSOFT:
				writeln("wafer_id: ", hdr.wafer_id);
				writeln("lot_id: ", hdr.lot_id);
				writeln("sublot_id: ", hdr.sublot_id);
				writeln("device_name: ", hdr.devName);
				writeln("temperature: ", hdr.temperature);
				writeln("step: ", hdr.step);
				writeln("row: ", row);
				writeln("col: ", col);
				writeln("rotation: ", options.rotateWafer);
				writeln("good_bins: ", goodbins);
				writeln("bad_bins: ", badbins);
				writeln("total_bins: ", goodbins+badbins);

				foreach(i, row_arr; matrix) { write("[");
					foreach(j, val; row_arr) {
						switch(val) {
							case 0: write(" "); break;
							case 1: write("p"); break;
							default: write("F");
						}
					}
					write("]");
					write("\n");
				}
				write("\n");
				foreach(i, row_arr; matrix) { write("[");
					foreach(j, val; row_arr) {
						switch(val) {
							case  0: write("  "); break;
							case  1: write("01"); break;
							case  2: write("02"); break;
							case  3: write("03"); break;
							case  4: write("04"); break;
							case  5: write("05"); break;
							case  6: write("06"); break;
							case  7: write("07"); break;
							case  8: write("08"); break;
							case  9: write("09"); break;
							case 10: write("0A"); break;
							case 11: write("0B"); break;
							case 12: write("0C"); break;
							case 13: write("0D"); break;
							case 14: write("0E"); break;
							case 15: write("0F"); break;
							case 16: write("10"); break;
							case -1: write("ER"); break;
							default: write("__");
						}
					}
					write("]");
					write("\n");
				}

				break;
			default:
				throw new Exception("Unsupported format for ASCII dump.");
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
	// underflow behavior test for hw bin #s
	ushort test1 = cast(ushort)-1;
	ushort test2 = cast(ushort)-2;
	writeln("test1 = ", test1);
	writeln("test2 = ", test2);

	assert( test1 == 65_535 );
	assert( test2 == 65_534 );
}