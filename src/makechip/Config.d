module makechip.Config;
import libxlsxd.format;
import makechip.Util;
import std.conv;
import std.stdio;

class Config
{
    private LinkedMap!(string, string) cfgMap;
    static immutable string ss_logo_x_scale                     = "ss.logo.x_scale";
    static immutable string ss_logo_y_scale                     = "ss.logo.y_scale";
    static immutable string ss_logo_file_path                   = "ss.logo.file_path";
    static immutable string ss_logo_text                        = "ss.logo.text";
    static immutable string ss_logo_bg_color                    = "ss.logo.bg_color";
    static immutable string ss_logo_text_color                  = "ss.logo.text_color";
    static immutable string ss_logo_font_name                   = "ss.logo.font_name";
    static immutable string ss_logo_font_size                   = "ss.logo.font_size";
    static immutable string ss_logo_font_style                  = "ss.logo.font_style";
    static immutable string ss_title_bg_color                   = "ss.title.bg_color";
    static immutable string ss_title_text_color                 = "ss.title.text_color";
    static immutable string ss_title_font_name                  = "ss.title.font_name";
    static immutable string ss_title_font_size                  = "ss.title.font_size";
    static immutable string ss_title_font_style                 = "ss.title.font_style";
    static immutable string ss_header_name_bg_color             = "ss.header.name.bg_color";
    static immutable string ss_header_name_text_color           = "ss.header.name.text_color";
    static immutable string ss_header_name_font_name            = "ss.header.name.font_name";
    static immutable string ss_header_name_font_size            = "ss.header.name.font_size";
    static immutable string ss_header_name_font_style           = "ss.header.name.font_style";
    static immutable string ss_header_value_bg_color            = "ss.header.value.bg_color";
    static immutable string ss_header_value_text_color          = "ss.header.value.text_color";
    static immutable string ss_header_value_font_name           = "ss.header.value.font_name";
    static immutable string ss_header_value_font_size           = "ss.header.value.font_size";
    static immutable string ss_header_value_font_style          = "ss.header.value.font_style";
    static immutable string ss_test_name_header_bg_color        = "ss.test_name.header.bg_color";
    static immutable string ss_test_name_header_text_color      = "ss.test_name.header.text_color";
    static immutable string ss_test_name_header_font_name       = "ss.test_name.header.font_name";
    static immutable string ss_test_name_header_font_size       = "ss.test_name.header.font_size";
    static immutable string ss_test_name_header_font_style      = "ss.test_name.header.font_style";
    static immutable string ss_test_name_value_bg_color         = "ss.test_name.value.bg_color";
    static immutable string ss_test_name_value_text_color       = "ss.test_name.value.text_color";
    static immutable string ss_test_name_value_font_name        = "ss.test_name.value.font_name";
    static immutable string ss_test_name_value_font_size        = "ss.test_name.value.font_size";
    static immutable string ss_test_name_value_font_style       = "ss.test_name.value.font_style";
    static immutable string ss_test_number_header_bg_color      = "ss.test_number.header.bg_color";
    static immutable string ss_test_number_header_text_color    = "ss.test_number.header.text_color";
    static immutable string ss_test_number_header_font_name     = "ss.test_number.header.font_name";
    static immutable string ss_test_number_header_font_size     = "ss.test_number.header.font_size";
    static immutable string ss_test_number_header_font_style    = "ss.test_number.header.font_style";
    static immutable string ss_test_number_value_bg_color       = "ss.test_number.value.bg_color";
    static immutable string ss_test_number_value_text_color     = "ss.test_number.value.text_color";
    static immutable string ss_test_number_value_font_name      = "ss.test_number.value.font_name";
    static immutable string ss_test_number_value_font_size      = "ss.test_number.value.font_size";
    static immutable string ss_test_number_value_font_style     = "ss.test_number.value.font_style";
    static immutable string ss_duplicate_header_bg_color        = "ss.duplicate.header.bg_color";
    static immutable string ss_duplicate_header_text_color      = "ss.duplicate.header.text_color";
    static immutable string ss_duplicate_header_font_name       = "ss.duplicate.header.font_name";
    static immutable string ss_duplicate_header_font_size       = "ss.duplicate.header.font_size";
    static immutable string ss_duplicate_header_font_style      = "ss.duplicate.header.font_style";
    static immutable string ss_duplicate_value_bg_color         = "ss.duplicate.value.bg_color";
    static immutable string ss_duplicate_value_text_color       = "ss.duplicate.value.text_color";
    static immutable string ss_duplicate_value_font_name        = "ss.duplicate.value.font_name";
    static immutable string ss_duplicate_value_font_size        = "ss.duplicate.value.font_size";
    static immutable string ss_duplicate_value_font_style       = "ss.duplicate.value.font_style";
    static immutable string ss_lo_limit_header_bg_color         = "ss.lo_limit.header.bg_color";
    static immutable string ss_lo_limit_header_text_color       = "ss.lo_limit.header.text_color";
    static immutable string ss_lo_limit_header_font_name        = "ss.lo_limit.header.font_name";
    static immutable string ss_lo_limit_header_font_size        = "ss.lo_limit.header.font_size";
    static immutable string ss_lo_limit_header_font_style       = "ss.lo_limit.header.font_style";
    static immutable string ss_lo_limit_value_bg_color          = "ss.lo_limit.value.bg_color";
    static immutable string ss_lo_limit_value_text_color        = "ss.lo_limit.value.text_color";
    static immutable string ss_lo_limit_value_font_name         = "ss.lo_limit.value.font_name";
    static immutable string ss_lo_limit_value_font_size         = "ss.lo_limit.value.font_size";
    static immutable string ss_lo_limit_value_font_style        = "ss.lo_limit.value.font_style";
    static immutable string ss_hi_limit_header_bg_color         = "ss.hi_limit.header.bg_color";
    static immutable string ss_hi_limit_header_text_color       = "ss.hi_limit.header.text_color";
    static immutable string ss_hi_limit_header_font_name        = "ss.hi_limit.header.font_name";
    static immutable string ss_hi_limit_header_font_size        = "ss.hi_limit.header.font_size";
    static immutable string ss_hi_limit_header_font_style       = "ss.hi_limit.header.font_style";
    static immutable string ss_hi_limit_value_bg_color          = "ss.hi_limit.value.bg_color";
    static immutable string ss_hi_limit_value_text_color        = "ss.hi_limit.value.text_color";
    static immutable string ss_hi_limit_value_font_name         = "ss.hi_limit.value.font_name";
    static immutable string ss_hi_limit_value_font_size         = "ss.hi_limit.value.font_size";
    static immutable string ss_hi_limit_value_font_style        = "ss.hi_limit.value.font_style";
    static immutable string ss_dyn_lo_limit_header_bg_color     = "ss.dyn_lo_limit.header.bg_color";
    static immutable string ss_dyn_lo_limit_header_text_color   = "ss.dyn_lo_limit.header.text_color";
    static immutable string ss_dyn_lo_limit_header_font_name    = "ss.dyn_lo_limit.header.font_name";
    static immutable string ss_dyn_lo_limit_header_font_size    = "ss.dyn_lo_limit.header.font_size";
    static immutable string ss_dyn_lo_limit_header_font_style   = "ss.dyn_lo_limit.header.font_style";
    static immutable string ss_dyn_lo_limit_value_bg_color      = "ss.dyn_lo_limit.value.bg_color";
    static immutable string ss_dyn_lo_limit_value_text_color    = "ss.dyn_lo_limit.value.text_color";
    static immutable string ss_dyn_lo_limit_value_font_name     = "ss.dyn_lo_limit.value.font_name";
    static immutable string ss_dyn_lo_limit_value_font_size     = "ss.dyn_lo_limit.value.font_size";
    static immutable string ss_dyn_lo_limit_value_font_style    = "ss.dyn_lo_limit.value.font_style";
    static immutable string ss_dyn_hi_limit_header_bg_color     = "ss.dyn_hi_limit.header.bg_color";
    static immutable string ss_dyn_hi_limit_header_text_color   = "ss.dyn_hi_limit.header.text_color";
    static immutable string ss_dyn_hi_limit_header_font_name    = "ss.dyn_hi_limit.header.font_name";
    static immutable string ss_dyn_hi_limit_header_font_size    = "ss.dyn_hi_limit.header.font_size";
    static immutable string ss_dyn_hi_limit_header_font_style   = "ss.dyn_hi_limit.header.font_style";
    static immutable string ss_dyn_hi_limit_value_bg_color      = "ss.dyn_hi_limit.value.bg_color";
    static immutable string ss_dyn_hi_limit_value_text_color    = "ss.dyn_hi_limit.value.text_color";
    static immutable string ss_dyn_hi_limit_value_font_name     = "ss.dyn_hi_limit.value.font_name";
    static immutable string ss_dyn_hi_limit_value_font_size     = "ss.dyn_hi_limit.value.font_size";
    static immutable string ss_dyn_hi_limit_value_font_style    = "ss.dyn_hi_limit.value.font_style";
    static immutable string ss_pin_header_bg_color              = "ss.pin.header.bg_color";
    static immutable string ss_pin_header_text_color            = "ss.pin.header.text_color";
    static immutable string ss_pin_header_font_name             = "ss.pin.header.font_name";
    static immutable string ss_pin_header_font_size             = "ss.pin.header.font_size";
    static immutable string ss_pin_header_font_style            = "ss.pin.header.font_style";
    static immutable string ss_pin_value_bg_color               = "ss.pin.value.bg_color";
    static immutable string ss_pin_value_text_color             = "ss.pin.value.text_color";
    static immutable string ss_pin_value_font_name              = "ss.pin.value.font_name";
    static immutable string ss_pin_value_font_size              = "ss.pin.value.font_size";
    static immutable string ss_pin_value_font_style             = "ss.pin.value.font_style";
    static immutable string ss_units_header_bg_color            = "ss.units.header.bg_color";
    static immutable string ss_units_header_text_color          = "ss.units.header.text_color";
    static immutable string ss_units_header_font_name           = "ss.units.header.font_name";
    static immutable string ss_units_header_font_size           = "ss.units.header.font_size";
    static immutable string ss_units_header_font_style          = "ss.units.header.font_style";
    static immutable string ss_units_value_bg_color             = "ss.units.value.bg_color";
    static immutable string ss_units_value_text_color           = "ss.units.value.text_color";
    static immutable string ss_units_value_font_name            = "ss.units.value.font_name";
    static immutable string ss_units_value_font_size            = "ss.units.value.font_size";
    static immutable string ss_units_value_font_style           = "ss.units.value.font_style";
    static immutable string ss_sn_xy_header_bg_color            = "ss.sn_xy.header.bg_color";
    static immutable string ss_sn_xy_header_text_color          = "ss.sn_xy.header.text_color";
    static immutable string ss_sn_xy_header_font_name           = "ss.sn_xy.header.font_name";
    static immutable string ss_sn_xy_header_font_size           = "ss.sn_xy.header.font_size";
    static immutable string ss_sn_xy_header_font_style          = "ss.sn_xy.header.font_style";
    static immutable string ss_sn_xy_value_bg_color             = "ss.sn_xy.value.bg_color";
    static immutable string ss_sn_xy_value_text_color           = "ss.sn_xy.value.text_color";
    static immutable string ss_sn_xy_value_font_name            = "ss.sn_xy.value.font_name";
    static immutable string ss_sn_xy_value_font_size            = "ss.sn_xy.value.font_size";
    static immutable string ss_sn_xy_value_font_style           = "ss.sn_xy.value.font_style";
    static immutable string ss_temp_header_bg_color             = "ss.temp.header.bg_color";
    static immutable string ss_temp_header_text_color           = "ss.temp.header.text_color";
    static immutable string ss_temp_header_font_name            = "ss.temp.header.font_name";
    static immutable string ss_temp_header_font_size            = "ss.temp.header.font_size";
    static immutable string ss_temp_header_font_style           = "ss.temp.header.font_style";
    static immutable string ss_temp_value_bg_color              = "ss.temp.value.bg_color";
    static immutable string ss_temp_value_text_color            = "ss.temp.value.text_color";
    static immutable string ss_temp_value_font_name             = "ss.temp.value.font_name";
    static immutable string ss_temp_value_font_size             = "ss.temp.value.font_size";
    static immutable string ss_temp_value_font_style            = "ss.temp.value.font_style";
    static immutable string ss_time_header_bg_color             = "ss.time.header.bg_color";
    static immutable string ss_time_header_text_color           = "ss.time.header.text_color";
    static immutable string ss_time_header_font_name            = "ss.time.header.font_name";
    static immutable string ss_time_header_font_size            = "ss.time.header.font_size";
    static immutable string ss_time_header_font_style           = "ss.time.header.font_style";
    static immutable string ss_time_value_bg_color              = "ss.time.value.bg_color";
    static immutable string ss_time_value_text_color            = "ss.time.value.text_color";
    static immutable string ss_time_value_font_name             = "ss.time.value.font_name";
    static immutable string ss_time_value_font_size             = "ss.time.value.font_size";
    static immutable string ss_time_value_font_style            = "ss.time.value.font_style";
    static immutable string ss_hw_bin_header_bg_color           = "ss.hw_bin.header.bg_color";
    static immutable string ss_hw_bin_header_text_color         = "ss.hw_bin.header.text_color";
    static immutable string ss_hw_bin_header_font_name          = "ss.hw_bin.header.font_name";
    static immutable string ss_hw_bin_header_font_size          = "ss.hw_bin.header.font_size";
    static immutable string ss_hw_bin_header_font_style         = "ss.hw_bin.header.font_style";
    static immutable string ss_hw_bin_value_bg_color            = "ss.hw_bin.value.bg_color";
    static immutable string ss_hw_bin_value_text_color          = "ss.hw_bin.value.text_color";
    static immutable string ss_hw_bin_value_font_name           = "ss.hw_bin.value.font_name";
    static immutable string ss_hw_bin_value_font_size           = "ss.hw_bin.value.font_size";
    static immutable string ss_hw_bin_value_font_style          = "ss.hw_bin.value.font_style";
    static immutable string ss_sw_bin_header_bg_color           = "ss.sw_bin.header.bg_color";
    static immutable string ss_sw_bin_header_text_color         = "ss.sw_bin.header.text_color";
    static immutable string ss_sw_bin_header_font_name          = "ss.sw_bin.header.font_name";
    static immutable string ss_sw_bin_header_font_size          = "ss.sw_bin.header.font_size";
    static immutable string ss_sw_bin_header_font_style         = "ss.sw_bin.header.font_style";
    static immutable string ss_sw_bin_value_bg_color            = "ss.sw_bin.value.bg_color";
    static immutable string ss_sw_bin_value_text_color          = "ss.sw_bin.value.text_color";
    static immutable string ss_sw_bin_value_font_name           = "ss.sw_bin.value.font_name";
    static immutable string ss_sw_bin_value_font_size           = "ss.sw_bin.value.font_size";
    static immutable string ss_sw_bin_value_font_style          = "ss.sw_bin.value.font_style";
    static immutable string ss_site_header_bg_color             = "ss.site.header.bg_color";
    static immutable string ss_site_header_text_color           = "ss.site.header.text_color";
    static immutable string ss_site_header_font_name            = "ss.site.header.font_name";
    static immutable string ss_site_header_font_size            = "ss.site.header.font_size";
    static immutable string ss_site_header_font_style           = "ss.site.header.font_style";
    static immutable string ss_site_value_bg_color              = "ss.site.value.bg_color";
    static immutable string ss_site_value_text_color            = "ss.site.value.text_color";
    static immutable string ss_site_value_font_name             = "ss.site.value.font_name";
    static immutable string ss_site_value_font_size             = "ss.site.value.font_size";
    static immutable string ss_site_value_font_style            = "ss.site.value.font_style";
    static immutable string ss_result_header_bg_color           = "ss.result.header.bg_color";
    static immutable string ss_result_header_text_color         = "ss.result.header.text_color";
    static immutable string ss_result_header_font_name          = "ss.result.header.font_name";
    static immutable string ss_result_header_font_size          = "ss.result.header.font_size";
    static immutable string ss_result_header_font_style         = "ss.result.header.font_style";
    static immutable string ss_result_pass_value_bg_color       = "ss.result.pass.value.bg_color";
    static immutable string ss_result_pass_value_text_color     = "ss.result.pass.value.text_color";
    static immutable string ss_result_pass_value_font_name      = "ss.result.pass.value.font_name";
    static immutable string ss_result_pass_value_font_size      = "ss.result.pass.value.font_size";
    static immutable string ss_result_pass_value_font_style     = "ss.result.pass.value.font_style";
    static immutable string ss_result_fail_value_bg_color       = "ss.result.fail.value.bg_color";
    static immutable string ss_result_fail_value_text_color     = "ss.result.fail.value.text_color";
    static immutable string ss_result_fail_value_font_name      = "ss.result.fail.value.font_name";
    static immutable string ss_result_fail_value_font_size      = "ss.result.fail.value.font_size";
    static immutable string ss_result_fail_value_font_style     = "ss.result.fail.value.font_style";
    static immutable string ss_pass_data_float_value_bg_color   = "ss.pass.data.float.value.bg_color";
    static immutable string ss_pass_data_float_value_text_color = "ss.pass.data.float.value.text_color";
    static immutable string ss_pass_data_float_value_font_name  = "ss.pass.data.float.value.font_name";
    static immutable string ss_pass_data_float_value_font_size  = "ss.pass.data.float.value.font_size";
    static immutable string ss_pass_data_float_value_font_style = "ss.pass.data.float.value.font_style";
    static immutable string ss_pass_data_int_value_bg_color     = "ss.pass.data.int.value.bg_color";
    static immutable string ss_pass_data_int_value_text_color   = "ss.pass.data.int.value.text_color";
    static immutable string ss_pass_data_int_value_font_name    = "ss.pass.data.int.value.font_name";
    static immutable string ss_pass_data_int_value_font_size    = "ss.pass.data.int.value.font_size";
    static immutable string ss_pass_data_int_value_font_style   = "ss.pass.data.int.value.font_style";
    static immutable string ss_pass_data_hex_value_bg_color     = "ss.pass.data.hex.value.bg_color";
    static immutable string ss_pass_data_hex_value_text_color   = "ss.pass.data.hex.value.text_color";
    static immutable string ss_pass_data_hex_value_font_name    = "ss.pass.data.hex.value.font_name";
    static immutable string ss_pass_data_hex_value_font_size    = "ss.pass.data.hex.value.font_size";
    static immutable string ss_pass_data_hex_value_font_style   = "ss.pass.data.hex.value.font_style";
    static immutable string ss_pass_data_string_value_bg_color   = "ss.pass.data.string.value.bg_color";
    static immutable string ss_pass_data_string_value_text_color = "ss.pass.data.string.value.text_color";
    static immutable string ss_pass_data_string_value_font_name  = "ss.pass.data.string.value.font_name";
    static immutable string ss_pass_data_string_value_font_size  = "ss.pass.data.string.value.font_size";
    static immutable string ss_pass_data_string_value_font_style = "ss.pass.data.string.value.font_style";
    static immutable string ss_fail_data_value_bg_color         = "ss.fail.data.value.bg_color";
    static immutable string ss_fail_data_value_text_color       = "ss.fail.data.value.text_color";
    static immutable string ss_fail_data_value_font_name        = "ss.fail.data.value.font_name";
    static immutable string ss_fail_data_value_font_size        = "ss.fail.data.value.font_size";
    static immutable string ss_fail_data_value_font_style       = "ss.fail.data.value.font_style";
    static immutable string wafer_fail_bg_color                 = "wafer.fail.bg_color";
    static immutable string wafer_empty_bg_color                = "wafer.empty.bg_color";
    static immutable string wafer_pass_bg_color                 = "wafer.pass.bg_color";
    static immutable string wafer_pass_text_color               = "wafer.pass.text_color";
    static immutable string wafer_header_bg_color               = "wafer.header.bg_color";
    static immutable string wafer_header_text_color             = "wafer.header.text_color";
    static immutable string wafer_label_bg_color                = "wafer.label.bg_color";
    static immutable string wafer_label_text_color              = "wafer.label.text_color";

    public this()
    {
        cfgMap = new LinkedMap!(string, string)();
    }

    public string getLogoPath()
    {
        string path = cfgMap.get(ss_logo_file_path, "");
        return path;
    }
 
    public string getValue(string name)
    {
        return cfgMap.get(name, "");
    }

    public int getColor(string colorName)
    {
        string c = cfgMap.get(colorName, "NONE");
        if (c == "NONE") return -1;
        int x = to!int(c, 16);
        if (x == 0) x = 0x1000000;
        return x;
    }

    public double getLogoXScale()
    {
        string x = cfgMap.get("", ss_logo_x_scale);
        if (x == "") return 0.0;
        return to!double(x);
    }

    public double getLogoYScale()
    {
        string y = cfgMap.get("", ss_logo_y_scale);
        if (y == "") return 0.0;
        return to!double(y);
    }

    public void setBGColor(Format f, string colorName)
    {
        string c = cfgMap.get(colorName, "NONE");
        if (c == "NONE") return;
        int x = to!int(c, 16);
        if (x == 0) x = 0x1000000;
        f.setBgColor(x);
    }

    public void setFGColor(Format f, string colorName)
    {
        string c = cfgMap.get(colorName, "NONE");
        if (c == "NONE") return;
        int x = to!int(c, 16);
        if (x == 0) x = 0x1000000;
        f.setFgColor(x);
    }

    public void setFontColor(Format f, string colorName)
    {
        string c = cfgMap.get(colorName, "NONE");
        if (c == "NONE") return;
        int x = to!int(c, 16);
        if (x == 0) x = 0x1000000;
        f.setFontColor(x);
    }

    public void load()
    {
        import std.array;
        import std.path;
        import std.file;
        import std.string;
        import std.stdio;

        cfgMap[ss_logo_x_scale]                   = "0_0";
        cfgMap[ss_logo_y_scale]                   = "0_0";
        cfgMap[ss_logo_file_path]                 = "";
        cfgMap[ss_logo_text]                      = "";
        cfgMap[ss_logo_bg_color]                  = "NONE";
        cfgMap[ss_logo_text_color]                = "000000";
        cfgMap[ss_logo_font_name]                 = "Arial";
        cfgMap[ss_logo_font_size]                 = "8";
        cfgMap[ss_logo_font_style]                = "normal";
        cfgMap[ss_title_bg_color]                 = "15B8D7";
        cfgMap[ss_title_text_color]               = "FFFFFF";
        cfgMap[ss_title_font_name]                = "Arial";
        cfgMap[ss_title_font_size]                = "16";
        cfgMap[ss_title_font_style]               = "bold";
        cfgMap[ss_header_name_bg_color]           = "F6F9D4";
        cfgMap[ss_header_name_text_color]         = "000000";
        cfgMap[ss_header_name_font_name]          = "Arial";
        cfgMap[ss_header_name_font_size]          = "8   ";
        cfgMap[ss_header_name_font_style]         = "bold";
        cfgMap[ss_header_value_bg_color]          = "F6F9D4";
        cfgMap[ss_header_value_text_color]        = "000000";
        cfgMap[ss_header_value_font_name]         = "Arial";
        cfgMap[ss_header_value_font_size]         = "8   ";
        cfgMap[ss_header_value_font_style]        = "normal";
        cfgMap[ss_test_name_header_bg_color]      = "DEE6EF";
        cfgMap[ss_test_name_header_text_color]    = "000000";
        cfgMap[ss_test_name_header_font_name]     = "Arial";
        cfgMap[ss_test_name_header_font_size]     = "8";
        cfgMap[ss_test_name_header_font_style]    = "bold";
        cfgMap[ss_test_name_value_bg_color]       = "FFE994";
        cfgMap[ss_test_name_value_text_color]     = "000000";
        cfgMap[ss_test_name_value_font_name]      = "Arial";
        cfgMap[ss_test_name_value_font_size]      = "8";
        cfgMap[ss_test_name_value_font_style]     = "normal";
        cfgMap[ss_test_number_header_bg_color]    = "DEE6EF";
        cfgMap[ss_test_number_header_text_color]  = "000000";
        cfgMap[ss_test_number_header_font_name]   = "Arial";
        cfgMap[ss_test_number_header_font_size]   = "8";
        cfgMap[ss_test_number_header_font_style]  = "bold";
        cfgMap[ss_test_number_value_bg_color]     = "FFE994";
        cfgMap[ss_test_number_value_text_color]   = "000000";
        cfgMap[ss_test_number_value_font_name]    = "Arial";
        cfgMap[ss_test_number_value_font_size]    = "8";
        cfgMap[ss_test_number_value_font_style]   = "normal";
        cfgMap[ss_duplicate_header_bg_color]      = "DEE6EF";
        cfgMap[ss_duplicate_header_text_color]    = "000000";
        cfgMap[ss_duplicate_header_font_name]     = "Arial";
        cfgMap[ss_duplicate_header_font_size]     = "8";
        cfgMap[ss_duplicate_header_font_style]    = "bold";
        cfgMap[ss_duplicate_value_bg_color]       = "FFE994";
        cfgMap[ss_duplicate_value_text_color]     = "000000";
        cfgMap[ss_duplicate_value_font_name]      = "Arial";
        cfgMap[ss_duplicate_value_font_size]      = "8";
        cfgMap[ss_duplicate_value_font_style]     = "normal";
        cfgMap[ss_lo_limit_header_bg_color]       = "DEE6EF";
        cfgMap[ss_lo_limit_header_text_color]     = "000000";
        cfgMap[ss_lo_limit_header_font_name]      = "Arial";
        cfgMap[ss_lo_limit_header_font_size]      = "8";
        cfgMap[ss_lo_limit_header_font_style]     = "bold";
        cfgMap[ss_lo_limit_value_bg_color]        = "FFE994";
        cfgMap[ss_lo_limit_value_text_color]      = "000000";
        cfgMap[ss_lo_limit_value_font_name]       = "Arial";
        cfgMap[ss_lo_limit_value_font_size]       = "8";
        cfgMap[ss_lo_limit_value_font_style]      = "normal";
        cfgMap[ss_hi_limit_header_bg_color]       = "DEE6EF";
        cfgMap[ss_hi_limit_header_text_color]     = "000000";
        cfgMap[ss_hi_limit_header_font_name]      = "Arial";
        cfgMap[ss_hi_limit_header_font_size]      = "8";
        cfgMap[ss_hi_limit_header_font_style]     = "bold";
        cfgMap[ss_hi_limit_value_bg_color]        = "FFE994";
        cfgMap[ss_hi_limit_value_text_color]      = "000000";
        cfgMap[ss_hi_limit_value_font_name]       = "Arial";
        cfgMap[ss_hi_limit_value_font_size]       = "8";
        cfgMap[ss_hi_limit_value_font_style]      = "normal";
        cfgMap[ss_dyn_lo_limit_header_bg_color]   = "DEE6EF";
        cfgMap[ss_dyn_lo_limit_header_text_color] = "000000";
        cfgMap[ss_dyn_lo_limit_header_font_name]  = "Arial";
        cfgMap[ss_dyn_lo_limit_header_font_size]  = "8";
        cfgMap[ss_dyn_lo_limit_header_font_style] = "bold";
        cfgMap[ss_dyn_lo_limit_value_bg_color]    = "FFFFB4";
        cfgMap[ss_dyn_lo_limit_value_text_color]  = "000000";
        cfgMap[ss_dyn_lo_limit_value_font_name]   = "Arial";
        cfgMap[ss_dyn_lo_limit_value_font_size]   = "8";
        cfgMap[ss_dyn_lo_limit_value_font_style]  = "normal";
        cfgMap[ss_dyn_hi_limit_header_bg_color]   = "DEE6EF";
        cfgMap[ss_dyn_hi_limit_header_text_color] = "000000";
        cfgMap[ss_dyn_hi_limit_header_font_name]  = "Arial";
        cfgMap[ss_dyn_hi_limit_header_font_size]  = "8";
        cfgMap[ss_dyn_hi_limit_header_font_style] = "bold";
        cfgMap[ss_dyn_hi_limit_value_bg_color]    = "FFFFB4";
        cfgMap[ss_dyn_hi_limit_value_text_color]  = "000000";
        cfgMap[ss_dyn_hi_limit_value_font_name]   = "Arial";
        cfgMap[ss_dyn_hi_limit_value_font_size]   = "8";
        cfgMap[ss_dyn_hi_limit_value_font_style]  = "normal";
        cfgMap[ss_pin_header_bg_color]            = "DEE6EF";
        cfgMap[ss_pin_header_text_color]          = "000000";
        cfgMap[ss_pin_header_font_name]           = "Arial";
        cfgMap[ss_pin_header_font_size]           = "8";
        cfgMap[ss_pin_header_font_style]          = "bold";
        cfgMap[ss_pin_value_bg_color]             = "FFE994";
        cfgMap[ss_pin_value_text_color]           = "000000";
        cfgMap[ss_pin_value_font_name]            = "Arial";
        cfgMap[ss_pin_value_font_size]            = "8";
        cfgMap[ss_pin_value_font_style]           = "normal";
        cfgMap[ss_units_header_bg_color]          = "DEE6EF";
        cfgMap[ss_units_header_text_color]        = "000000";
        cfgMap[ss_units_header_font_name]         = "Arial";
        cfgMap[ss_units_header_font_size]         = "8";
        cfgMap[ss_units_header_font_style]        = "bold";
        cfgMap[ss_units_value_bg_color]           = "FFE994";
        cfgMap[ss_units_value_text_color]         = "000000";
        cfgMap[ss_units_value_font_name]          = "Arial";
        cfgMap[ss_units_value_font_size]          = "8";
        cfgMap[ss_units_value_font_style]         = "normal";
        cfgMap[ss_sn_xy_header_bg_color]          = "DEE6EF";
        cfgMap[ss_sn_xy_header_text_color]        = "000000";
        cfgMap[ss_sn_xy_header_font_name]         = "Arial";
        cfgMap[ss_sn_xy_header_font_size]         = "8";
        cfgMap[ss_sn_xy_header_font_style]        = "bold";
        cfgMap[ss_sn_xy_value_bg_color]           = "FFE994";
        cfgMap[ss_sn_xy_value_text_color]         = "000000";
        cfgMap[ss_sn_xy_value_font_name]          = "Arial";
        cfgMap[ss_sn_xy_value_font_size]          = "8";
        cfgMap[ss_sn_xy_value_font_style]         = "normal";
        cfgMap[ss_temp_header_bg_color]           = "DEE6EF";
        cfgMap[ss_temp_header_text_color]         = "000000";
        cfgMap[ss_temp_header_font_name]          = "Arial";
        cfgMap[ss_temp_header_font_size]          = "8";
        cfgMap[ss_temp_header_font_style]         = "bold";
        cfgMap[ss_temp_value_bg_color]            = "FFE994";
        cfgMap[ss_temp_value_text_color]          = "000000";
        cfgMap[ss_temp_value_font_name]           = "Arial";
        cfgMap[ss_temp_value_font_size]           = "8";
        cfgMap[ss_temp_value_font_style]          = "normal";
        cfgMap[ss_time_header_bg_color]           = "DEE6EF";
        cfgMap[ss_time_header_text_color]         = "000000";
        cfgMap[ss_time_header_font_name]          = "Arial";
        cfgMap[ss_time_header_font_size]          = "8";
        cfgMap[ss_time_header_font_style]         = "bold";
        cfgMap[ss_time_value_bg_color]            = "FFE994";
        cfgMap[ss_time_value_text_color]          = "000000";
        cfgMap[ss_time_value_font_name]           = "Arial";
        cfgMap[ss_time_value_font_size]           = "8";
        cfgMap[ss_time_value_font_style]          = "normal";
        cfgMap[ss_hw_bin_header_bg_color]         = "DEE6EF";
        cfgMap[ss_hw_bin_header_text_color]       = "000000";
        cfgMap[ss_hw_bin_header_font_name]        = "Arial";
        cfgMap[ss_hw_bin_header_font_size]        = "8";
        cfgMap[ss_hw_bin_header_font_style]       = "bold";
        cfgMap[ss_hw_bin_value_bg_color]          = "FFE994";
        cfgMap[ss_hw_bin_value_text_color]        = "000000";
        cfgMap[ss_hw_bin_value_font_name]         = "Arial";
        cfgMap[ss_hw_bin_value_font_size]         = "8";
        cfgMap[ss_hw_bin_value_font_style]        = "normal";
        cfgMap[ss_sw_bin_header_bg_color]         = "DEE6EF";
        cfgMap[ss_sw_bin_header_text_color]       = "000000";
        cfgMap[ss_sw_bin_header_font_name]        = "Arial";
        cfgMap[ss_sw_bin_header_font_size]        = "8";
        cfgMap[ss_sw_bin_header_font_style]       = "bold";
        cfgMap[ss_sw_bin_value_bg_color]          = "FFE994";
        cfgMap[ss_sw_bin_value_text_color]        = "000000";
        cfgMap[ss_sw_bin_value_font_name]         = "Arial";
        cfgMap[ss_sw_bin_value_font_size]         = "8";
        cfgMap[ss_sw_bin_value_font_style]        = "normal";
        cfgMap[ss_site_header_bg_color]           = "DEE6EF";
        cfgMap[ss_site_header_text_color]         = "000000";
        cfgMap[ss_site_header_font_name]          = "Arial";
        cfgMap[ss_site_header_font_size]          = "8";
        cfgMap[ss_site_header_font_style]         = "bold";
        cfgMap[ss_site_value_bg_color]            = "FFE994";
        cfgMap[ss_site_value_text_color]          = "000000";
        cfgMap[ss_site_value_font_name]           = "Arial";
        cfgMap[ss_site_value_font_size]           = "8";
        cfgMap[ss_site_value_font_style]          = "normal";
        cfgMap[ss_result_header_bg_color]         = "DEE6EF";
        cfgMap[ss_result_header_text_color]       = "000000";
        cfgMap[ss_result_header_font_name]        = "Arial";
        cfgMap[ss_result_header_font_size]        = "8";
        cfgMap[ss_result_header_font_style]       = "bold";
        cfgMap[ss_result_pass_value_bg_color]     = "FFE994";
        cfgMap[ss_result_pass_value_text_color]   = "000000";
        cfgMap[ss_result_pass_value_font_name]    = "Arial";
        cfgMap[ss_result_pass_value_font_size]    = "8";
        cfgMap[ss_result_pass_value_font_style]   = "normal";
        cfgMap[ss_result_fail_value_bg_color]     = "FF0000";
        cfgMap[ss_result_fail_value_text_color]   = "000000";
        cfgMap[ss_result_fail_value_font_name]    = "Arial";
        cfgMap[ss_result_fail_value_font_size]    = "8";
        cfgMap[ss_result_fail_value_font_style]   = "normal";
        cfgMap[ss_pass_data_float_value_bg_color]   = "NONE";
        cfgMap[ss_pass_data_float_value_text_color] = "000000";
        cfgMap[ss_pass_data_float_value_font_name]  = "Arial";
        cfgMap[ss_pass_data_float_value_font_size]  = "8";
        cfgMap[ss_pass_data_float_value_font_style] = "normal";
        cfgMap[ss_pass_data_int_value_bg_color]     = "NONE";
        cfgMap[ss_pass_data_int_value_text_color]   = "000000";
        cfgMap[ss_pass_data_int_value_font_name]    = "Arial";
        cfgMap[ss_pass_data_int_value_font_size]    = "8";
        cfgMap[ss_pass_data_int_value_font_style]   = "normal";
        cfgMap[ss_pass_data_hex_value_bg_color]     = "NONE";
        cfgMap[ss_pass_data_hex_value_text_color]   = "000000";
        cfgMap[ss_pass_data_hex_value_font_name]    = "Arial";
        cfgMap[ss_pass_data_hex_value_font_size]    = "8";
        cfgMap[ss_pass_data_hex_value_font_style]   = "normal";
        cfgMap[ss_pass_data_string_value_bg_color]   = "NONE";
        cfgMap[ss_pass_data_string_value_text_color] = "000000";
        cfgMap[ss_pass_data_string_value_font_name]  = "Arial";
        cfgMap[ss_pass_data_string_value_font_size]  = "8";
        cfgMap[ss_pass_data_string_value_font_style] = "normal";
        cfgMap[ss_fail_data_value_bg_color]       = "FF0000";
        cfgMap[ss_fail_data_value_text_color]     = "000000";
        cfgMap[ss_fail_data_value_font_name]      = "Arial";
        cfgMap[ss_fail_data_value_font_size]      = "8";
        cfgMap[ss_fail_data_value_font_style]     = "normal";
        cfgMap[wafer_fail_bg_color]               = "BF0000";
        cfgMap[wafer_empty_bg_color]              = "666666";
        cfgMap[wafer_pass_bg_color]               = "22C600";
        cfgMap[wafer_pass_text_color]             = "000000";
        cfgMap[wafer_header_bg_color]             = "DEE6EF";
        cfgMap[wafer_header_text_color]           = "000000";
        cfgMap[wafer_label_bg_color]              = "999999";
        cfgMap[wafer_label_text_color]            = "000000";


        string rc = std.path.expandTilde("~/.stdf2xlsxrc");
        if (rc.exists)
        {
            auto f = File(rc, "r");
            foreach (line; f.byLine())
            {
                auto l = std.string.strip(line);
                if (l.length == 0) continue;
                if (l[0] == '#') continue;
                string[] x = cast(string[]) split(l);
                if (x.length == 1) cfgMap[x[0]] = "";
                else cfgMap[x[0].idup] = x[1].idup;
            }
            f.close();
        }
    }

    public void write()
    {
        import std.path;
        import std.stdio;
        string rc = expandTilde("~/stdf2xlsxrc");
        auto f = File(rc, "w");
        writeln("# font styles: normal | bold | italic | underline | bold_italic | bold_underline | italic_underline | bold_italic_underline");
        foreach (key; cfgMap.keys)
        {
            auto value = cfgMap[key];
            f.write(key);
            for (size_t i=0; i<40-key.length; i++) f.write(" ");
            f.writeln(value);
        }
        f.close();
    }
}

