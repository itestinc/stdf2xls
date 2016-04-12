import std.stdio;

alias J = const C;

interface I(K, V) //if (is(V == const))
{
    static int getI();
}

class F(K, V) if (is(V : I!(K, V)))
{
    this()
    {
    }

}

class C : I!(uint, J)
{
    static F!(uint, J) map;

    static this()
    {
        map = new F!(uint, J)();
    }

    static int getI() { return 1; }
}

void main(string[] args)
{

}
