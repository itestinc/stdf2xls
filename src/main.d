import makechip.util.Util;
import makechip.Stdf;
import makechip.Cpu_t;
import std.conv;
import std.stdio;
import std.traits;

void main(string[] args)
{

    auto rdr = new StdfReader(args[1], 10000000L);
    rdr.read();
    auto recs = rdr.getRecords();
    //writeln("num recs = ", recs.length);
    foreach(r; recs) 
    {
        //writeln(r.toString());
    }

}
