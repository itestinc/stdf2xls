module libxlsxd.format;

import libxlsxd.xlsxwrap;

Format newFormat() {
	return Format(lxw_format_new());
}

void freeFormat(Format format) {
	lxw_format_free(format.handle);
}

struct Format {
	import std.string : toStringz;
	lxw_format* handle;

	this(lxw_format* handle) pure @nogc nothrow {
		this.handle = handle;
	}

	int getXfIndex() @nogc nothrow {
		return lxw_format_get_xf_index(this.handle);
	}

	lxw_font* getFontKey() @nogc nothrow {
		return lxw_format_get_font_key(this.handle);
	}

	lxw_border* getBorderKey() @nogc nothrow {
		return lxw_format_get_border_key(this.handle);
	}

	lxw_fill* getFillKey() @nogc nothrow {
		return lxw_format_get_fill_key(this.handle);
	}

//	static lxw_color_t checkColor(lxw_color_t color) @nogc nothrow {
//		return lxw_format_check_color(color);
//	}
   
    string getFontName() nothrow {
        import std.conv;
        return to!string(format_get_font_name(this.handle));
    }

    double getFontSize() nothrow {
        return format_get_font_size(this.handle);
    }

    bool getBold() nothrow {
        return format_get_bold(this.handle) != 0;
    }

    bool getItalic() nothrow {
        return format_get_italic(this.handle) != 0;
    }

    bool getUnderline() nothrow {
        return format_get_underline(this.handle) != 0;
    }

	void setFontName(string fontname) nothrow {
		format_set_font_name(this.handle, toStringz(fontname));
	}

	void setFontSize(double size) @nogc nothrow {
		format_set_font_size(this.handle, size);
	}

	void setFontColor(lxw_color_t color) @nogc nothrow {
		format_set_font_color(this.handle, color);
	}

	void setBold() @nogc nothrow {
		format_set_bold(this.handle);
	}

	void setItalic() @nogc nothrow {
		format_set_italic(this.handle);
	}

	void setUnderline(ubyte style) @nogc nothrow {
		format_set_underline(this.handle, style);
	}

	void setFontStrikeout() @nogc nothrow {
		format_set_font_strikeout(this.handle);
	}

	void setFontScript(ubyte style) @nogc nothrow {
		format_set_font_script(this.handle, style);
	}

	void setNumFormat(string numFormat) nothrow {
		format_set_num_format(this.handle, toStringz(numFormat));
	}

	void setNumFormatIndex(ubyte index) @nogc nothrow {
		format_set_num_format_index(this.handle, index);
	}

	void setUnlocked() @nogc nothrow {
		format_set_unlocked(this.handle);
	}

	void setHidden() @nogc nothrow {
		format_set_hidden(this.handle);
	}

	void setAlign(ubyte align_) @nogc nothrow {
		format_set_align(this.handle, align_);
	}

	void setTextWrap() @nogc nothrow {
		format_set_text_wrap(this.handle);
	}

	void setRotation(short angle) @nogc nothrow {
		format_set_rotation(this.handle, angle);
	}

	void setIndent(ubyte level) @nogc nothrow {
		format_set_indent(this.handle, level);
	}

	void setShrink() @nogc nothrow {
		format_set_shrink(this.handle);
	}

	void setPattern(ubyte pattern) @nogc nothrow {
		format_set_pattern(this.handle, pattern);
	}

	void setBgColor(lxw_color_t color) @nogc nothrow {
		format_set_bg_color(this.handle, color);
	}

	void setFgColor(lxw_color_t color) @nogc nothrow {
		format_set_fg_color(this.handle, color);
	}

	void setBorder(ubyte border) @nogc nothrow {
		format_set_border(this.handle, border);
	}

	void setBottom(ubyte bottom) @nogc nothrow {
		format_set_bottom(this.handle, bottom);
	}

	void setTop(ubyte top) @nogc nothrow {
		format_set_top(this.handle, top);
	}

	void setLeft(ubyte left) @nogc nothrow {
		format_set_left(this.handle, left);
	}

	void setRight(ubyte right) @nogc nothrow {
		format_set_right(this.handle, right);
	}

	void setBorderColor(lxw_color_t color) @nogc nothrow {
		format_set_border_color(this.handle, color);
	}

	void setBottomColor(lxw_color_t color) @nogc nothrow {
		format_set_bottom_color(this.handle, color);
	}

	void setTopColor(lxw_color_t color) @nogc nothrow {
		format_set_top_color(this.handle, color);
	}

	void setLeftColor(lxw_color_t color) @nogc nothrow {
		format_set_left_color(this.handle, color);
	}

	void setRightColor(lxw_color_t color) @nogc nothrow {
		format_set_right_color(this.handle, color);
	}

	void setDiagType(ubyte type) @nogc nothrow {
		format_set_diag_type(this.handle, type);
	}

	void setDiagColor(lxw_color_t color) @nogc nothrow {
		format_set_diag_color(this.handle, color);
	}

	void setDiagBorder(ubyte border) @nogc nothrow {
		format_set_diag_border(this.handle, border);
	}

	void setFontOutline() @nogc nothrow {
		format_set_font_outline(this.handle);
	}

	void setFontShadow() @nogc nothrow {
		format_set_font_shadow(this.handle);
	}

	void setFontFamily(ubyte family) @nogc nothrow {
		format_set_font_family(this.handle, family);
	}

	void setFontCharset(ubyte charset) @nogc nothrow {
		format_set_font_charset(this.handle, charset);
	}

	void setFontScheme(string schema) nothrow {
		format_set_font_scheme(this.handle, toStringz(schema));
	}

	void setFontCondense() @nogc nothrow {
		format_set_font_condense(this.handle);
	}

	void setFontExtend() @nogc nothrow {
		format_set_font_extend(this.handle);
	}

	void setReadingOrder(ubyte order) @nogc nothrow {
		format_set_reading_order(this.handle, order);
	}

	void setTheme(ubyte theme) @nogc nothrow {
		format_set_theme(this.handle, theme);
	}
}
