module makechip.Config;

class Config
{
    string[string] cfgMap;
    static immutable string ss_legend_fail_bg_color         = "ss.legend.fail.bg_color";
    static immutable string ss_legend_fail_text_color       = "ss.legend.fail.text_color";
    static immutable string ss_legend_unreliable_bg_color   = "ss.legend.unreliable.bg_color";
    static immutable string ss_legend_unreliable_text_color = "ss.legend.unreliable.text_color";
    static immutable string ss_legend_pass_bg_color         = "ss.legend.pass.bg_color";
    static immutable string ss_legend_pass_text_color       = "ss.legend.pass.text_color";
    static immutable string ss_legend_timeout_bg_color      = "ss.legend.timeout.bg_color";
    static immutable string ss_legend_timeout_text_color    = "ss.legend.timeout.text_color";
    static immutable string ss_legend_alarm_bg_color        = "ss.legend.alarm.bg_color";
    static immutable string ss_legend_alarm_text_color      = "ss.legend.alarm.text_color";
    static immutable string ss_legend_abort_bg_color        = "ss.legend.abort.bg_color";
    static immutable string ss_legend_abort_text_color      = "ss.legend.abort.text_color";
    static immutable string ss_legend_invalid_bg_color      = "ss.legend.invalid.bg_color";
    static immutable string ss_legend_invalid_text_color    = "ss.legend.invalid.text_color";
    static immutable string ss_header_name_bg_color         = "ss.header.name.bg_color";
    static immutable string ss_header_name_text_color       = "ss.header.name.text_color";
    static immutable string ss_header_value_bg_color        = "ss.header.value.bg_color";
    static immutable string ss_header_value_text_color      = "ss.header.value.text_color";
    static immutable string ss_table_header_bg_color        = "ss.table.header.bg_color";
    static immutable string ss_table_header_text_color      = "ss.table.header.text_color";
    static immutable string ss_test_header_bg_color         = "ss.test.header.bg_color";
    static immutable string ss_test_header_text_color       = "ss.test.header.text_color";
    static immutable string ss_result_header_bg_color       = "ss.result.header.bg_color";
    static immutable string ss_result_header_text_color     = "ss.result.header.text_color";
    static immutable string ss_step_label_bg_color          = "ss.step.label.bg_color";
    static immutable string ss_step_label_text_color        = "ss.step.label.text_color";
    static immutable string ss_logo_file_path               = "ss.logo.file_path";

    public this()
    {
    }

    public void load()
    {
        import std.array;
        import std.path;
        import std.file;
        import std.string;
        import std.stdio;
        cfgMap[ss_legend_fail_bg_color] = "FF0000";
        cfgMap[ss_legend_fail_text_color] = "000000";
        cfgMap[ss_legend_unreliable_bg_color] = "BBE33D";
        cfgMap[ss_legend_unreliable_text_color] = "000000";
        cfgMap[ss_legend_pass_bg_color] = "NONE";
        cfgMap[ss_legend_pass_text_color] = "000000";
        cfgMap[ss_legend_timeout_bg_color] = "FF00FF";
        cfgMap[ss_legend_timeout_text_color] = "000000";
        cfgMap[ss_legend_alarm_bg_color] = "FFFF00";
        cfgMap[ss_legend_alarm_text_color] = "000000";
        cfgMap[ss_legend_abort_bg_color] = "00FFFF";
        cfgMap[ss_legend_abort_text_color] = "000000";
        cfgMap[ss_legend_invalid_bg_color] = "33CCCC";
        cfgMap[ss_legend_invalid_text_color] = "000000";
        cfgMap[ss_header_name_bg_color] = "F6F9D4";
        cfgMap[ss_header_name_text_color] = "000000";
        cfgMap[ss_header_value_bg_color] = "F6F9D4";
        cfgMap[ss_header_value_text_color] = "000000";
        cfgMap[ss_table_header_bg_color] = "DEE6EF";
        cfgMap[ss_table_header_text_color] = "000000";
        cfgMap[ss_test_header_bg_color] = "FFE994";
        cfgMap[ss_test_header_text_color] = "000000";
        cfgMap[ss_result_header_bg_color] = "FFFFA6";
        cfgMap[ss_result_header_text_color] = "000000";
        cfgMap[ss_step_label_bg_color] = "508ED3";
        cfgMap[ss_step_label_text_color] = "FFFFFF";
        cfgMap[ss_logo_file_path] = "";

        string rc = std.path.expandTilde("~/stdf2xlsxrc");
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
                else cfgMap[x[0]] = x[1];
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
        foreach (key; cfgMap)
        {
            auto value = cfgMap[key];
            f.writeln(key, " ", value);
        }
        f.close();
    }
}

