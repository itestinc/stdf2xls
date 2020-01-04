/*
 * ==========================================================================
 * Copyright (C) 2014 makechip.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * A copy of the GNU General Public License can be found in the file
 * LICENSE.txt provided with the source distribution of this program
 * This license can also be found on the GNU website at
 * http://www.gnu.org/licenses/gpl.html.
 * 
 * If you did not receive a copy of the GNU General Public License along
 * with this program, contact the lead developer, or write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */
module makechip.Util;

@safe
abstract class EnumValue(C) if (is(C : const(C)))
{
    const uint ordinal;

    protected const this(C prev)
    {   
        if (prev is null) ordinal = 0;
        else ordinal = prev.ordinal + 1;
    }   

    alias ordinal this;
    override string toString() const;
}

import std.stdio;
import std.conv;
    
final class Stack(T)
{   
    private T[] data;
    private size_t _length=0;
    
    @property size_t capacity() { return data.length;     }
    @property size_t length()   { return _length;         }
    @property ref T peek()      { return data[_length-1]; }
    @property bool empty()      { return _length == 0;    }
    
    this(size_t initialCapacity=1024) { data.length = initialCapacity; }
    
    private this(Stack!T s)
    {
        data = s.data.dup;
        _length = s._length; 
    }
    
    ref T opIndex(size_t i)
    {
        debug if (i >= _length) throw new Exception("Invalid index");
        return data[i];
    }
    
    private void expand()
    {
        size_t numMore = data.length;
        if (numMore == 0) numMore = 1;
        data.length += numMore;
    }   
        
    void clear()
    {   
        _length = 0; 
        data.destroy();
    }   
        
    void push(ref T item) 
    {   
        if (_length == data.length) expand();
        data[_length] = item;
        _length++;
        debug(collections)
        {
            writeln("STACK CONTENTS: (bottom to top)");
            for (int i=0; i<_length; i++) writeln(to!string(data[i]));
        }
    }
        
    T pop()
    {       
        _length--;
        T p = data[_length];
        return(p);
    }

}

final class ValueStack(T)
{   
    private T[] data;
    private size_t _length=0;
    
    @property size_t capacity() { return data.length;     }
    @property size_t length()   { return _length;         }
    @property T peek()      { return data[_length-1]; }
    @property bool empty()      { return _length == 0;    }
    
    this(size_t initialCapacity=1024) { data.length = initialCapacity; }
    
    private this(ValueStack!T s)
    {
        data = s.data.dup;
        _length = s._length; 
    }
    
    T opIndex(size_t i)
    {
        debug if (i >= _length) throw new Exception("Invalid index");
        return data[i];
    }
    
    private void expand()
    {
        size_t numMore = data.length;
        if (numMore == 0) numMore = 1;
        data.length += numMore;
    }   
        
    void clear()
    {   
        _length = 0; 
        data.destroy();
    }   
        
    void push(T item) 
    {   
        if (_length == data.length) expand();
        data[_length] = item;
        _length++;
        debug(collections)
        {
            writeln("STACK CONTENTS: (bottom to top)");
            for (int i=0; i<_length; i++) writeln(to!string(data[i]));
        }
    }
        
    T pop()
    {       
        _length--;
        T p = data[_length];
        return(p);
    }

}

class Queue(T)
{
    size_t length;
    private size_t head, tail;
    private T[] A = [T.init];

    @property bool empty() const pure nothrow { return length == 0; }

    void push(T item) pure nothrow
    {
        if (length >= A.length)
        {
            auto old = A;
            A = new T[A.length * 2];
            A[0 .. (old.length - head)] = old[head .. $];
            if (head) A[(old.length - head) .. old.length] = old[0 .. head];
            head = 0;
            tail = length;
        }
        A[tail] = item;
        tail = (tail + 1) & (A.length - 1);
        length++;
    }

    T pop() pure
    {
        import std.traits: hasIndirections;

        if (length == 0) throw new Exception("Token queue is empty.");
        auto saved = A[head];
        static if (hasIndirections!T) A[head] = T.init; // Help for the GC.
        head = (head + 1) & (A.length - 1);
        length--;
        return saved;
    }

    T[] getAll() { return A.dup; }
}

class LinkedMap(K, V)
{
    K[] keylist;
    V[K] map;

    void put(K key, V value)
    {
        if (key !in map)
        {
            keylist ~= key;
        }
        map[key] = value;
    }

    V get(K key, V missingValue)
    {
        if (key in map)
        {
            return map[key];
        }
        return missingValue;
    }

    @property size_t size()
    {
        return map.length;
    }

    void remove(K key)
    {
        if (key in map)
        {
            map.remove(key);
            K[] tmp;
            foreach (k; keylist)
            {
                if (k == key) continue;
                tmp ~= k;
            }
            keylist = tmp;
        }
    }

    V opIndex(K key) inout
    {
        return map[key];
    }

    V opIndexAssign(V value, K key)
    {
        if (key !in map)
        {
            keylist ~= key;
        }
        map[key] = value;
        return value;
    }

    auto opBinaryRight(string op="in")(K key)
    {
        return key in map;
    }

    @property auto keys()
    {
        K[] ks = keylist.dup;
        return ks;
    }

    @property auto values()
    {
        return map.values;
    }

    @property auto byKey()
    {
        return keylist;
    }

    @property auto byValue()
    {
        return map.byValue;
    }

}

unittest
{
    LinkedMap!(string, int) map = new LinkedMap!(string, int)();

    map.put("A", 1);
    map.put("B", 2);
    map.put("C", 3);
    map["D"] = 4;
    map["E"] = 5;
    assert("A" in map);
    assert(map["D"] == 4);
    int[] q = [ 1, 2, 3, 4, 5 ];
    foreach(i, s; map.byKey)
    {
        assert(map[s] == q[i]);
    }
    writeln("LinkedMap Test #1 passes");
    map.remove("C");
    int[] qr = [ 1, 2, 4, 5 ];
    foreach(i, s; map.byKey)
    {
        assert(map[s] == qr[i]);
    }
    writeln("LinkedMap Test #2 passes");
}
import std.algorithm;
class MultiMap(V, K...) if (K.length > 1)
{
    private MultiMap!(V, K[1..$])[K[0]] map;

    public void put(V v, K k)
    {   
        if (k[0] in map)
        {   
            auto m = map[k[0]];
            m.put(v, k[1..$]);
        }   
        else
        {   
            auto m = new MultiMap!(V, K[1..$])();
            map[k[0]] = m;
            m.put(v, k[1..$]);
        }   
    }   

    public V get(V defaultValue, K k)
    {   
        if (k[0] in map)
        {   
            auto m = map[k[0]];
            return m.get(defaultValue, k[1..$]);
        }   
        return defaultValue;
    }   

    @property @trusted
    public size_t size()
    {   
        return map.values.fold!((a,b) => a + b.size)(0L);
    }   

    public void remove(K k)
    {   
        if (k[0] in map)
        {   
            auto m = map[k[0]];
            m.remove(k[1..$]);
        }   
    }   

}

class MultiMap(V, K...) if (K.length == 1)
{
    private V[K[0]] map;

    public void put(V v, K k)
    {   
        map[k[0]] = v;
    }   

    public V get(V defaultValue, K k)
    {   
        return map.get(k[0], defaultValue);
    }   

    public size_t size()
    {   
        return map.length;
    }   

    public void remove(K k)
    {   
        map.remove(k[0]);
    }
}

unittest
{
    MultiMap!(string, uint, double, char) map = new MultiMap!(string, uint, double, char)();

    map.put("AA", 3, 2.0, 'a');
    map.put("BB", 2, 3.0, 'b');
    map.put("EE", 2, 3.0, 'x');
    map.put("CC", 1, 4.0, 'c');
    map.put("DD", 0, 5.0, 'd');

    assert(map.get("XX", 3, 2.0, 'a') == "AA");
    assert(map.get("XX", 2, 3.0, 'b') == "BB");
    assert(map.get("XX", 1, 4.0, 'c') == "CC");
    assert(map.get("XX", 0, 5.0, 'd') == "DD");
    assert(map.get("XX", 0, 4.0, 'd') == "XX");
    auto s = map.get("XX", 2, 3.0, 'b');
    assert(s == "BB");

    assert(map.size() == 5L);
    map.remove(2, 3.0, 'x');
    assert(map.size() == 4L);
    map.remove(3, 2.0, 'a');
    map.remove(2, 3.0, 'b');
    assert(map.size() == 2L);
    map.remove(3, 3.0, 's');
    assert(map.size() == 2L);
    map.remove(1, 4.0, 'c');
    map.remove(0, 5.0, 'd');
    assert(map.size() == 0L);
    map.remove(0, 5.0, 'd');
    assert(map.size() == 0L);
    writeln("MultiMap Test #1 passes");
    MultiMap!(string, uint) map2 = new MultiMap!(string, uint)();

    map2.put("AA", 3);
    map2.put("BB", 2);
    map2.put("CC", 1);
    map2.put("DD", 0);

    assert(map2.get("XX", 3) == "AA");
    assert(map2.get("XX", 2) == "BB");
    assert(map2.get("XX", 1) == "CC");
    assert(map2.get("XX", 0) == "DD");
    assert(map2.get("XX", 9) == "XX");
    s = map2.get("XX", 1);
    assert(s == "CC");
    assert(map2.size() == 4);
    writeln("MultiMap Test #1 passes");
}

struct StringAppender
{
    char[] buf;
    size_t len;
    size_t capacity;

    this(size_t capacity)
    {
        this.capacity = capacity;
        buf = new char[capacity];
        len = 0L;
    }

    void put(string s)
    {
        if ((len + s.length) >= capacity)
        {
            ensureCapacity(s.length >= capacity ? s.length : capacity);
        }
        for (size_t i=0; i<s.length; i++)
        {
            buf[len++] = s[i];
        }
    }

    import core.memory;
    private void ensureCapacity(size_t newAmt)
    {
        writeln("INFO: StringBuffer increasing capacity for ", buf);
        capacity += newAmt;
        char[] newBuf = new char[capacity];
        for (int i=0; i<len; i++) newBuf[i] = buf[i];
        buf = newBuf;
    }

    alias opOpAssign(string op : "~") = put;

    @property string data()
    {
        buf = buf.ptr[0 .. len];
        buf.length = len;
        return cast(string) buf;
    }

}

