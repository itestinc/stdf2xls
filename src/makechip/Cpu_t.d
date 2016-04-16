import makechip.util.Util;




alias C = immutable CPU;

class CPU : Enum!(C), immutable (Identity!(uint, C))
{
    private static IdentityFactory!(uint, C) map;
    const ushort type;

    static this()
    {
        map = new IdentityFactory!(uint, C)();
    }

    private immutable this(uint type)
    {
        super();
        this.type = cast(ushort) type;
    }

    static size_t getInstanceCount() { return map.getInstanceCount(); }

    static C getValue(uint type) 
    { 
        return map.getValue(type, function(uint type) { return new C(type); }); 
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

