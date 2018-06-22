######################################################################
# @file .gdbinit
# @brief
# @date Tue, Mar  6, 2018  4:37:46 PM
# @author liqiang
######################################################################

#
# __________________GDB OPTIONS_________________

# misc
set confirm off
set verbose off
set pagination off

# history
set history filename ~/.gdb_history
set history remove-duplicates unlimited
set history save on
set history size 4096

# print
set print pretty on
set print elements 0
#set print array on

# radix
set output-radix 0x0A
set input-radix 0x0A

# logging
set logging off
set logging file gdb.log
set logging overwrite on
set logging on

# These make gdb never pause in its output
#set height unlimited
#set width unlimited

# prompt
set prompt \001\033[1;33m\002(gdb) \001\033[0m\002
#set extended-prompt \[\e[1;33m\](gdb) \[\e[0m\]

# __________________END GDB OPTIONS_________________
#

# source python_init and local_init
source ~/.gdbinit.py
source ~/.gdbinit.local

#
# __________________USER COMMAND_________________


define ascii_char
    set $_c = *(unsigned char *)($arg0)
    if ($_c < 0x20 || $_c > 0x7E)
        printf "."
    else
        printf "%c", $_c
    end
end


define hexdump
    if $argc < 1
        help hexdump
    else
        set $daddr = $arg0
        if $argc == 1
            set $dlines = 16
        else
            set $dlines = $arg1
        end
        set $line = 0
        while ($line < $dlines)
            set $addr = $daddr + ($line * 0x10)
            printf "%08X: ", $addr
            set $i = 0
            while $i < 0x08
                printf "%02X ", *(unsigned char *)($addr+$i)
                set $i++
            end
            printf " "
            while $i < 0x10
                printf "%02X ", *(unsigned char *)($addr+$i)
                set $i++
            end
            printf " |"
            set $i = 0
            while $i < 0x10
                ascii_char $addr+$i
                set $i++
            end
            printf "|\n"
            set $line++
        end
    end
end
document hexdump
Syntax: hexdump <ADDR> [<NR_LINES>]
| Display a 16-byte hex/ASCII dump of memory starting at address ADDR.
| if no NR_LINES field, NR_LINES = 16
end


define hexdump32
    if $argc < 1
        help hexdump32
    else
        set $daddr = $arg0
        if $argc == 1
            set $dlines = 16
        else
            set $dlines = $arg1
        end
        set $line = 0
        while ($line < $dlines)
            set $addr = $daddr + ($line * 0x10)
            printf "%08X: ", $addr
            set $i = 0
            while $i < 0x10
                printf "%08X ", *(unsigned int *)($addr+$i)
                set $i += 4
            end
            printf " |"
            set $i = 0
            while $i < 0x10
                ascii_char $addr+$i
                set $i++
            end
            printf "|\n"
            set $line++
        end
    end
end
document hexdump32
Syntax: hexdump32 <ADDR> [<NR_LINES>]
| Display a 4-int(32bit) hex/ASCII dump of memory starting at address ADDR.
| if no NR_LINES field, NR_LINES = 16
end


define dump_hexfile
    if $argc != 3
        help dump_hexfile
    else
        dump ihex memory $arg0 $arg1 $arg2
    end
end
document dump_hexfile
Syntax: dump_hexfile <FILENAME> <START_ADDR> <STOP_ADDR>
| Write a range of memory to a file in Intel ihex (hexdump) format.
| The range is specified by START_ADDR and STOP_ADDR addresses.
end


define dump_binfile
    if $argc != 3
        help dump_binfile
    else
        dump memory $arg0 $arg1 $arg2
    end
end
document dump_binfile
Syntax: dump_binfile <FILENAME> <START_ADDR> <STOP_ADDR>
| Write a range of memory to a binary file.
| The range is specified by START_ADDR and STOP_ADDR addresses.
end


define restore_hexfile
    if $argc != 1
        help restore_hexfile
    else
        restore $arg0
    end
end
document restore_hexfile
Syntax: restore_hexfile <FILENAME>
| Restore the contents of FILE to target memory.
end


define restore_binfile
    if $argc != 2
        help restore_binfile
    else
        restore $arg0 binary $arg1
    end
end
document restore_binfile
Syntax: restore_binfile <FILENAME> <ADDR>
| Restore the contents of FILE to target memory.
end


define sii
    si
    x/1i $pc
end
document sii
Like si, but show the next disassembler instruction
end


define xi
    x/16i $pc-16
end
document xi
Show disassembler instructions around $pc
end


define memset
    if $argc != 3
        help memset
    else
        set $start = (unsigned char *) $arg0
        set $value = (unsigned char) $arg1
        set $end = $start + $arg2
        set $p = $start
        while $p < $end
            set *(unsigned char *) $p = $value
            set $p++
        end
    end
end
document memset
Syntax: memset <ADDR> <VALUE> <LENGTH>
| Like memset
end


define memset32
    if $argc != 3
        help memset32
    else
        set $start = (unsigned int *) $arg0
        set $value = (unsigned int) $arg1
        set $end = $start + $arg2
        set $p = $start
        while $p < $end
            set *(unsigned int *) $p = $value
            set $p++
        end
    end
end
document memset32
Syntax: memset32 <ADDR> <VALUE> <LENGTH>
| Like memset, but value is 32bit
end


define memcpy
    if $argc != 3
        help memcpy
    else
        set $dst = (unsigned char *) $arg0
        set $src = (unsigned char *) $arg1
        set $length = $arg2
        set $end = $dst + $length
        while $dst < $end
            set *(unsigned char *) $dst = *(unsigned char *) $src
            set $dst++
            set $src++
        end
    end
end
document memcpy
Syntax: memcpy <ADDR_DST> <ADDR_SRC> <LENGTH>
| Like memcpy
end


define memcpy_s
    if $argc < 2
        help memcpy_s
    else
        set $dst = (unsigned char *) $arg0
        set $src = $arg1
        if $argc > 2
            set $length = $arg2
        else
            set $i = 0
            while $src[$i] != 0
                set $i++
            end
            set $length = $i
        end
        set $end = $dst + $length
        set $i = 0
        while $dst < $end
            set *(unsigned char *) $dst = $src[$i]
            set $dst++
            set $i++
        end
    end
end
document memcpy_s
Syntax: memcpy_s <ADDR> <"STRING"> [<LENGTH>]
| Like memcpy, but copy the "string" to memery
| if no LENGTH field, LENGTH is strlen(STRING)
end


define memfind
    if $argc < 3
        help memfind
    else
        set $start = (char *) $arg0
        set $end = (char *) $arg1
        set $pattern = $arg2
        if $argc > 3
            set $length = $arg3
        else
            set $length = 0
        end
        set $p = $start
        while $p < $end
            set $loop = 1
            set $i = 0
            while $loop
                if (*(unsigned char*) $p) == $pattern[$i]
                    set $i++
                    set $finish = 0
                    if $length == 0
                        if $pattern[$i] == 0
                            set $finish = 1
                        end
                    else
                        if $i == $length
                            set $finish = 1
                        end
                    end
                    if $finish
                        set $loop = 0
                        set $found = $p - ($i - 1)
                        printf "found at 0x%08x\n", $found
                    end
                else
                    set $loop = 0
                    set $p = $p - $i
                end
                set $p++
            end
        end
    end
end
document memfind
Syntax: memfind <START> <END> <"PATTERN"> [<PATTERN_LENGTH>]
| search for the given pattern beetween $start and $end address.
| if no PATTERN_LENGTH field, PATTERN_LENGTH is strlen(PATTERN)
end


define strcpy
    if $argc != 2
        help strcpy
    else
        set $dst = (char *) $arg0
        set $src = $arg1
        set $i = 0
        while $src[$i] != 0
            set *(char *) $dst = $src[$i]
            set $dst++
            set $i++
        end
        set *(char *) $dst = 0
    end
end
document strcpy
Syntax: strcpy <ADDR> <"STRING">
| Like strcpy
end


define strcat
    if $argc != 2
        help strcat
    else
        set $dst = (char *) $arg0
        set $src = $arg1
        while *(char *)$dst != 0
            set $dst++
        end
        strcpy $dst $src
    end
end
document strcat
Syntax: strcat <ADDR> <"STRING">
| Like strcat
end


define hex_dec_show
    printf "%d", $arg0
    if $arg0 > 9
        printf "(0x%X)", $arg0
    end
end
document hex_dec_show
Syntax: hex_dec_show <VALUE>
| hex and dec show the value, if value < 10, the hex-value will be hidded.
end


define bitset
    if $argc < 3
        help bitset
    else
        set $addr = $arg0
        set $start = $arg1
        if $argc == 3
            set $length = 1
            set $value = $arg2
        else
            set $length = $arg2
            set $value = $arg3
        end

        # set
        set $bits_value = *$addr
        set $mask = (1<<$length) - 1
        set $value = $value & $mask
        set $mask = $mask << $start
        set $value_shift = $value << $start
        set *$addr = ($bits_value & (~$mask)) | ($value_shift)

        # get
        set $bits_value = *$addr
        set $result_value = ($bits_value & $mask) >> $start

        # show
        set $end = $start + $length - 1
        printf "0x%08X[%d:%d] ==> '", $addr, $start, $end
        hex_dec_show $value
        if $result_value != $value
            printf "', but read is '"
            hex_dec_show $result_value
        end
        printf "'\n"
    end
end
document bitset
Syntax: bitset <ADDR> <START_BIT> [<BIT_LENGTH>] <VALUE>
| bit set for register operation
| if no <BIT_LENGTH> field, BIT_LENGTH is 1
end


define bitset_e
    if $argc < 3
        help bitset_e
    else
        set $addr = $arg0
        set $start = $arg1
        if $argc == 3
            set $length = 1
            set $value = $arg2
        else
            set $length = $arg2 - $start + 1
            set $value = $arg3
        end

        bitset $addr $start $length $value
    end
end
document bitset_e
Syntax: bitset_e <ADDR> <START_BIT> [<END_BIT>] <VALUE>
| bit set for register operation
| if no <END_BIT> field, END_BIT is START_BIT
end


define bitget
    if $argc < 2
        help bitget
    else
        set $addr = $arg0
        set $start = $arg1
        if $argc == 2
            set $length = 1
        else
            set $length = $arg2
        end

        # get
        set $bits_value = *$addr
        set $mask = ((1<<$length) - 1) << $start
        set $value = ($bits_value & $mask) >> $start

        # show
        set $end = $start + $length - 1
        printf "0x%08X[%d:%d] = '", $addr, $start, $end
        hex_dec_show $value
        printf "'\n"
    end
end
document bitget
Syntax: bitget <ADDR> <START_BIT> [<BIT_LENGTH>]
| bit get for register operation
| if no <BIT_LENGTH> field, BIT_LENGTH is 1
end


define bitget_e
    if $argc < 2
        help bitget_e
    else
        set $addr = $arg0
        set $start = $arg1
        if $argc == 2
            set $length = 1
        else
            set $length = $arg2 - $start + 1
        end

        bitget $addr $start $length
    end
end
document bitget_e
Syntax: bitget_e <ADDR> <START_BIT> [<END_BIT>]
| bit get for register operation
| if no <END_BIT> field, END_BIT is START_BIT
end


# __________________END USER COMMAND_________________
#

