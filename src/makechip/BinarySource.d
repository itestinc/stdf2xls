/*
 * ==========================================================================
 * Copyright (C) 2019 makechip.com
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
/++
    This module contains buffered ranges for binary and UTF* encoded files.
+/
module makechip.BinarySource;

import std.stdio;
import std.range;
import std.conv;
import std.file;
import core.stdc.stdlib;
import core.stdc.string;

version(unittest)
{
    private bool testmode; 
    private uint testval;
}

version(Posix)
{
    private alias FSChar = char;
}
else version(Windows)
{
    private alias FSChar = wchar;
}
else
{
    static assert(0);
}

public class BufferException : Exception
{
    public this(string msg)
    {
        super("\n" ~ msg);
    }
}

public interface ByteReader
{
    nothrow pure string getName();
    @property ubyte front();
    @property nothrow bool empty();
    void popFront();
    ubyte nextByte();
    ubyte[] getBytes(size_t howMany);
    nothrow pure size_t size();
    ubyte getByte();
    size_t remaining();
    void mark();
    void resetToMark();
    size_t getPtr();
    void close();
}

/**
    This class is for reading binary files.  It buffers all
    of the file in memory and forgoes line and column counting for extra speed.
*/
public class BinarySource : ByteReader
{
    immutable ubyte *NULL = cast(ubyte*) 0;
    public const string bufferName;
    private ubyte *ptr;
    private ubyte *eofLoc;
    private ubyte *_mark;
    private const size_t bufferSize;
    private const size_t fileSize;
    private const bool file;

    import core.sys.posix.fcntl;
    import core.sys.posix.sys.mman;
    import core.sys.posix.sys.stat;
    import core.sys.posix.sys.shm;

    private int fd;
    private ubyte *buffer;

    public nothrow pure string getName() { return bufferName; }

    public size_t getPtr()
    {
        return bufferSize - cast(size_t) (eofLoc - ptr);
    }

    /++
        Constructor for when the source is a file.

        fileName = The path to the input file.
    +/
    this(string fileName)
    {
        this.file = true;
        import std.internal.cstring;
        this.bufferName = fileName;
        version(Windows)
        {
            import std.string;
            File f1 = File(fileName, "r");
            bufferSize = fileSize = f1.size();
            f1.close();
            import core.memory;
            import core.stdc.stdio;
            auto f = fopen(toStringz(fileName), "r");
            buffer = cast(ubyte*) pureMalloc(fileSize);
            fread(buffer, 1L, fileSize, f);
            fclose(f);
        }
        else
        {
            const size_t pageSize;
            pageSize = __getpagesize();
            fd = open(bufferName.tempCString!FSChar(), O_RDONLY);
            version(unittest)
            {
                if (!testmode)
                {
                    if (fd <= 0) 
                    {
                        throw new BufferException("Unable to open " ~ bufferName);
                    }
                }
            }
            else
            {
                if (fd <= 0) 
                {
                    throw new BufferException("Unable to open " ~ bufferName);
                }
            }
            stat_t finfo;
            int status;
            status = core.sys.posix.fcntl.fstat(fd, &finfo);
            if (status != 0) 
            {
                throw new BufferException("Unable to stat file: " ~ bufferName);
            }
            fileSize = finfo.st_size;
            size_t numPages = fileSize / pageSize;
            if ((fileSize % pageSize) != 0LU) numPages++;
            this.bufferSize = numPages * pageSize;
            buffer = cast(ubyte *) mmap(null, this.bufferSize, PROT_READ, MAP_SHARED, fd, 0);
            version(unittest)
            {
                if (testmode && testval == 6) 
                {
                    import core.sys.posix.unistd;
                    munmap(cast(void*) buffer, bufferSize);
                    core.sys.posix.unistd.close(fd);
                    buffer = cast(ubyte*) MAP_FAILED;
                    fd = 0;
                }
            }
            if (buffer == MAP_FAILED) 
            {
                throw new BufferException("Unable to allocate buffer for " ~ bufferName);
            }
        }
        ptr = buffer;
        _mark = ptr;
        eofLoc = ptr + this.fileSize;
    }

    /++
        This constructor is for buffering string types.  It is not really needed since strings are
        input ranges anyways.  However this ctor is provided mainly for testing purposes.
        Also this buffer returns code units, not code points.
        stringBuffer = The string holding the buffer contents.
        bufferName = A name for this buffer.
    +/
    this(string stringBuffer, string bufferName)
    {
        this.file = false;
        this.bufferName = bufferName;
        ptr = cast(ubyte *) stringBuffer.ptr;
        this.bufferSize = stringBuffer.length;
        this.fileSize = bufferSize;
        _mark = ptr;
        eofLoc = ptr + bufferSize;
    }

    /++
        This method returns the number of code units contained in the buffer.
        (The size does not change as units are removed from the buffer).
        For UTF32 buffers this method returns the number of dwords in the buffer.
        For UTF16 buffers this method returns the number of words in the buffer.
        For all other encodings this method returns the number of bytes in the buffer.
    +/
    @property nothrow pure size_t size()
    {
        return fileSize;
    }

    /++
        This method returns the current character in the range. If the encoding
        is UTF16 or UTF32 and the encoding is not in the native endian format,
        then the bytes are swapped so that the returned character is in the
        native endian format.
    +/
    @property ubyte front()
    {
        return *ptr;
    }

    /++
        This method indicates when the range is empty.

        Returns: true if the range is empty. false otherwise.
    +/
    @property nothrow bool empty()
    {
        return ptr >= eofLoc;
    }

    /++
        This method increments the buffer pointer.
    +/
    void popFront()
    {
        ptr++;
    }

    /++
        This is a convenience method that does the following:<br>
        1. if (empty) throw an exception for unexpected EOF.<br>
        2. get the front character.<br>
        3. call popFront().<br>
        4. return the front character.
    +/
    ubyte nextByte()
    {
        if (empty) throw new BufferException("Unexpected EOF");
        ubyte a = front;
        popFront();
        return a;
    }

    /++
        Like nextByte(), but does absolutely no checking for pointer bounds.
    +/
    ubyte getByte()
    {
        auto b = *ptr;
        ptr++;
        return b;
    }

    ubyte[] getBytes(size_t howMany)
    {
        size_t index = cast(size_t) (ptr - buffer);
        auto b = buffer[index..index+howMany];
        ptr += howMany;
        return b;
    }

    /++
        Returns the number of bytes remaining in the buffer.
    +/
    size_t remaining()
    {
        return eofLoc - ptr;
    }

    void mark()
    {
        _mark = ptr;
    }

    void resetToMark()
    {
        ptr = _mark;
    }

    /++
        This method closes the file buffer.  If this is a string buffer,
        then this method does nothing.
    +/
    public void close()
    {
        if (file)
        {
            version(Windows)
            {
                import core.memory;
                free(buffer);
            }
            else
            {
                import core.sys.posix.unistd;
                if (fd != 0)
                {
                    munmap(cast(void*) buffer, bufferSize);
                    core.sys.posix.unistd.close(fd);
                }
            }
        }
    }
}

unittest
{
    auto f = File("x.x", "w");
    f.write("abc");
    f.close();

    auto bin1 = new BinarySource("x.x");
    assert(bin1.getName() == "x.x");
    assert(bin1.size() == 3L);
    assert(bin1.nextByte() == 'a');
    assert(bin1.nextByte() == 'b');
    assert(bin1.nextByte() == 'c');
    writeln("Binary reader test passes");
    
    auto bin2 = new BinarySource("abc", "bin2");
    assert(bin2.getName() == "bin2");
    assert(bin2.size() == 3L);
    assert(bin2.nextByte() == 'a');
    assert(bin2.nextByte() == 'b');
    assert(bin2.nextByte() == 'c');
    writeln("Binary string reader test passes");

    bool pass = false;
    try { new BinarySource("asd%kskwwew.2342353ewa"); } catch (BufferException) { pass = true; }
    assert(pass);
    writeln("Binary source missing file test passes");
    testmode = true;
    pass = false;
    try { new BinarySource("asd%kskwwew.2342353ewa"); } catch (BufferException) { pass = true; }
    assert(pass);
    writeln("Binary source missing file stat test passes");

    testval = 6;
    pass = false;
    try { new BinarySource("x.x"); } catch (BufferException) { pass = true; }
    testmode = false;
    testval = 0;
    assert(pass);
    writeln("Binary source fail mem alloc test passes");

    f = File("x.x", "w");
    for (int i=0; i<100; i++) f.writefln("\0\0\0\0\0");
    f.close();
    auto fs = new BinarySource("x.x");
    uint cnt = 0; 
    while (!fs.empty)
    {    
        auto c = fs.nextByte();
        if (c != cast(ubyte) '\n')
        {
            assert(c == 0);
        }
        cnt++;
    }    
    assert(cnt == 600);
    writeln("InputSource small buffer file test passes");
    std.file.remove("x.x");
}

