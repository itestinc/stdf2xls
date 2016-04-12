import makechip.util.Util;

alias C = const CPU;

static if (is (CPU : Identity!(uint, C)))
{
    pragma(msg, "XXX");
}



class CPU : Identity!(uint, C)
{
    private static IdentityFactory1!(uint, C) map;
    const ushort type;

    static this()
    {
        map = new IdentityFactory1!(uint, C)();
    }

    private this(uint type)
    {
        this.type = cast(ushort) type;
    }

    static ulong getInstanceCount() { return map.getInstanceCount(); }

    static C getValue(uint type) 
    { 
        return map.getValue(type, function(uint type) { return new CPU(type); }); 
    }

    static C getExistingValue(uint type) { return map.getExistingValue(type, null); }


}

/*
enum Cpu_t : CPU
{
    VAX = new CPU(0),
    SUN = new CPU(1),
    PC = new CPU(2)
}
*/

