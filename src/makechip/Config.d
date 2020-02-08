module makechip.Config;
import libxlsxd.format;
import std.conv;
import std.stdio;

class Config
{
    private string[string] cfgMap;
    static immutable string ss_legend_title_bg_color        = "ss.legend.title.bg_color";
    static immutable string ss_legend_title_text_color      = "ss.legend.title.text_color";
    static immutable string ss_fail_bg_color                = "ss.fail.bg_color";
    static immutable string ss_fail_text_color              = "ss.fail.text_color";
    static immutable string ss_unreliable_bg_color          = "ss.unreliable.bg_color";
    static immutable string ss_unreliable_text_color        = "ss.unreliable.text_color";
    static immutable string ss_pass_bg_color                = "ss.pass.bg_color";
    static immutable string ss_pass_text_color              = "ss.pass.text_color";
    static immutable string ss_timeout_bg_color             = "ss.timeout.bg_color";
    static immutable string ss_timeout_text_color           = "ss.timeout.text_color";
    static immutable string ss_alarm_bg_color               = "ss.alarm.bg_color";
    static immutable string ss_alarm_text_color             = "ss.alarm.text_color";
    static immutable string ss_abort_bg_color               = "ss.abort.bg_color";
    static immutable string ss_abort_text_color             = "ss.abort.text_color";
    static immutable string ss_invalid_bg_color             = "ss.invalid.bg_color";
    static immutable string ss_invalid_text_color           = "ss.invalid.text_color";
    static immutable string ss_header_name_bg_color         = "ss.header.name.bg_color";
    static immutable string ss_header_name_text_color       = "ss.header.name.text_color";
    static immutable string ss_header_value_bg_color        = "ss.header.value.bg_color";
    static immutable string ss_header_value_text_color      = "ss.header.value.text_color";
    static immutable string ss_dynamic_limit_bg_color       = "ss.dynamic_limit.bg_color";
    static immutable string ss_dynamic_limit_text_color     = "ss.dynamic_limit.text_color";


    static immutable string ss_testid_header_bg_color       = "ss.testid.header.bg_color";
    static immutable string ss_testid_header_text_color     = "ss.testid.header.text_color";
    static immutable string ss_deviceid_header_bg_color     = "ss.deviceid.header.bg_color";
    static immutable string ss_deviceid_header_text_color   = "ss.deviceid.header.text_color";
    static immutable string ss_unitstemp_header_bg_color    = "ss.unitstemp.header.bg_color";
    static immutable string ss_unitstemp_header_text_color  = "ss.unitstemp.header.text_color";
    static immutable string ss_units_header_bg_color        = "ss.units.header.bg_color";
    static immutable string ss_units_header_text_color      = "ss.units.header.text_color";
    static immutable string ss_temp_header_bg_color         = "ss.temp.header.bg_color";
    static immutable string ss_temp_header_text_color       = "ss.temp.header.text_color";

    static immutable string ss_test_header_bg_color         = "ss.test.header.bg_color";
    static immutable string ss_test_header_text_color       = "ss.test.header.text_color";
    static immutable string ss_result_header_bg_color       = "ss.result.header.bg_color";
    static immutable string ss_result_header_text_color     = "ss.result.header.text_color";
    static immutable string ss_page_title_bg_color          = "ss.page.title.bg_color";
    static immutable string ss_page_title_text_color        = "ss.page.title.text_color";
    static immutable string ss_logo_file_path               = "ss.logo.file_path";
    static immutable string ss_logo_x_scale                 = "ss.logo.x_scale";
    static immutable string ss_logo_y_scale                 = "ss.logo.y_scale";

    public this()
    {
    }

    public string getLogoPath()
    {
        string path = cfgMap.get(ss_logo_file_path, "");
        return path;
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
        writeln("colorName = ", colorName, " color = ", c);
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
        cfgMap[ss_legend_title_bg_color] = "NONE";
        cfgMap[ss_legend_title_text_color] = "000000";
        cfgMap[ss_fail_bg_color] = "FF0000";
        cfgMap[ss_fail_text_color] = "000000";
        cfgMap[ss_unreliable_bg_color] = "BBE33D";
        cfgMap[ss_unreliable_text_color] = "000000";
        cfgMap[ss_pass_bg_color] = "NONE";
        cfgMap[ss_pass_text_color] = "000000";
        cfgMap[ss_timeout_bg_color] = "FF00FF";
        cfgMap[ss_timeout_text_color] = "000000";
        cfgMap[ss_alarm_bg_color] = "FFFF00";
        cfgMap[ss_alarm_text_color] = "000000";
        cfgMap[ss_abort_bg_color] = "00FFFF";
        cfgMap[ss_abort_text_color] = "000000";
        cfgMap[ss_invalid_bg_color] = "33CCCC";
        cfgMap[ss_invalid_text_color] = "000000";
        cfgMap[ss_header_name_bg_color] = "F6F9D4";
        cfgMap[ss_header_name_text_color] = "000000";
        cfgMap[ss_header_value_bg_color] = "F6F9D4";
        cfgMap[ss_header_value_text_color] = "000000";
        cfgMap[ss_dynamic_limit_bg_color] = "FFFF00";
        cfgMap[ss_dynamic_limit_text_color] = "000000";

        cfgMap[ss_testid_header_bg_color] = "DEE6EF";
        cfgMap[ss_testid_header_text_color] = "000000";
        cfgMap[ss_deviceid_header_bg_color] = "DEE6EF";
        cfgMap[ss_deviceid_header_text_color] = "000000";
        cfgMap[ss_unitstemp_header_bg_color] = "DEE6EF";
        cfgMap[ss_unitstemp_header_text_color] = "000000";
        cfgMap[ss_units_header_bg_color] = "DEE6EF";
        cfgMap[ss_units_header_text_color] = "000000";
        cfgMap[ss_temp_header_bg_color] = "DEE6EF";
        cfgMap[ss_temp_header_text_color] = "000000";

        cfgMap[ss_test_header_bg_color] = "FFE994";
        cfgMap[ss_test_header_text_color] = "000000";
        cfgMap[ss_result_header_bg_color] = "FFFFA6";
        cfgMap[ss_result_header_text_color] = "000000";
        cfgMap[ss_page_title_bg_color] = "508ED3";
        cfgMap[ss_page_title_text_color] = "FFFFFF";
        cfgMap[ss_logo_file_path] = "";
        cfgMap[ss_logo_x_scale] = "0.0";
        cfgMap[ss_logo_y_scale] = "0.0";

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
                else 
                {
                    writeln("x[0] = ", x[0], " x[1] = ", x[1]);
                    cfgMap[x[0].idup] = x[1].idup;
                    string cc = cfgMap.get(ss_page_title_bg_color, "-");
                    writeln("cc = ", cc);
                    cc = cfgMap.get(ss_unitstemp_header_bg_color, "-");
                    writeln("dd = ", cc);
                }
            }
            f.close();
        }
        if (ss_page_title_bg_color == "ss.page.title.bg_color")
        {
            writeln("ss_page_title_bg_color = ", cfgMap[ss_page_title_bg_color]);
        }
    }

    public void write()
    {
        import std.path;
        import std.stdio;
        string rc = expandTilde("~/stdf2xlsxrc");
        auto f = File(rc, "w");
        foreach (key; cfgMap)
        {
            auto value = cfgMap[key];
            f.writeln(key, " ", value);
        }
        f.close();
    }
}

