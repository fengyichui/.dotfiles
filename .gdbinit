# INSTALL INSTRUCTIONS: save as ~/.gdbinit
#
# __________________gdb options_________________

# set to 0 if you have problems with the colorized prompt - reported by Plouj with Ubuntu gdb 7.2
set $COLOREDPROMPT = 1
# use colorized output or not
set $USECOLOR = 1

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

# __________________end gdb options_________________
#

# __________________color functions_________________
#
# color codes
set $BLACK = 0
set $RED = 1
set $GREEN = 2
set $YELLOW = 3
set $BLUE = 4
set $MAGENTA = 5
set $CYAN = 6
set $WHITE = 7

# CHANGME: If you want to modify the "theme" change the colors here
#          or just create a ~/.gdbinit.local and set these variables there
set $COLOR_REGNAME = $GREEN
set $COLOR_REGVAL = $WHITE
set $COLOR_REGVAL_MODIFIED  = $RED
set $COLOR_SEPARATOR = $BLUE
set $COLOR_CPUFLAGS = $RED

# this is ugly but there's no else if available :-(
define color
 if $USECOLOR == 1
    # BLACK
    if $arg0 == 0
        echo \033[30m
    else
        # RED
        if $arg0 == 1
            echo \033[31m
        else
            # GREEN
            if $arg0 == 2
                echo \033[32m
            else
                # YELLOW
                if $arg0 == 3
                    echo \033[33m
                else
                    # BLUE
                    if $arg0 == 4
                        echo \033[34m
                    else
                        # MAGENTA
                        if $arg0 == 5
                            echo \033[35m
                        else
                            # CYAN
                            if $arg0 == 6
                                echo \033[36m
                            else
                                # WHITE
                                if $arg0 == 7
                                    echo \033[37m
                                end
                            end
                        end
                    end
                end
            end
        end
     end
 end
end

define color_reset
    if $USECOLOR == 1
       echo \033[0m
    end
end

define color_bold
    if $USECOLOR == 1
       echo \033[1m
    end
end

define color_underline
    if $USECOLOR == 1
       echo \033[4m
    end
end

# this way anyone can have their custom prompt - argp's idea :-)
# can also be used to redefine anything else in particular the colors aka theming
# just remap the color variables defined above
source ~/.gdbinit.local
source ~/.gdbinit.local.py

# can't use the color functions because we are using the set command
if $COLOREDPROMPT == 1
    set prompt \001\033[1;33m\002(gdb) \001\033[0m\002
#    set extended-prompt \[\e[1;33m\](gdb) \[\e[0m\]
end

# __________hex/ascii dump an address_________
define ascii_char
    if $argc != 1
        help ascii_char
    else
        # thanks elaine :)
        set $_c = *(unsigned char *)($arg0)
        if ($_c < 0x20 || $_c > 0x7E)
            printf "."
        else
            printf "%c", $_c
        end
    end
end
document ascii_char
Syntax: ascii_char ADDR
| Print ASCII value of byte at address ADDR.
| Print "." if the value is unprintable.
end


define hex_quad
    if $argc != 1
        help hex_quad
    else
        printf "%02X %02X %02X %02X %02X %02X %02X %02X", \
               *(unsigned char*)($arg0), *(unsigned char*)($arg0 + 1),     \
               *(unsigned char*)($arg0 + 2), *(unsigned char*)($arg0 + 3), \
               *(unsigned char*)($arg0 + 4), *(unsigned char*)($arg0 + 5), \
               *(unsigned char*)($arg0 + 6), *(unsigned char*)($arg0 + 7)
    end
end
document hex_quad
Syntax: hex_quad ADDR
| Print eight hexadecimal bytes starting at address ADDR.
end


define hexdump
    if $argc == 1
        hexdump_aux $arg0
    else
        if $argc == 2
            set $_count = 0
            while ($_count < $arg1)
                set $_i = ($_count * 0x10)
                hexdump_aux $arg0+$_i
                set $_count++
            end
        else
            help hexdump
        end
    end
end
document hexdump
Syntax: hexdump ADDR <NR_LINES>
| Display a 16-byte hex/ASCII dump of memory starting at address ADDR.
| Optional parameter is the number of lines to display if you want more than one. 
end


define hexdump_aux
    if $argc != 1
        help hexdump_aux
    else
        color_bold
        printf "0x%08X : ", $arg0
        color_reset
        hex_quad $arg0
        color_bold
        printf " - "
        color_reset
        hex_quad $arg0+8
        printf " "
        color_bold
        ascii_char $arg0+0x0
        ascii_char $arg0+0x1
        ascii_char $arg0+0x2
        ascii_char $arg0+0x3
        ascii_char $arg0+0x4
        ascii_char $arg0+0x5
        ascii_char $arg0+0x6
        ascii_char $arg0+0x7
        ascii_char $arg0+0x8
        ascii_char $arg0+0x9
        ascii_char $arg0+0xA
        ascii_char $arg0+0xB
        ascii_char $arg0+0xC
        ascii_char $arg0+0xD
        ascii_char $arg0+0xE
        ascii_char $arg0+0xF
        color_reset
        printf "\n"
    end
end
document hexdump_aux
Syntax: hexdump_aux ADDR
| Display a 16-byte hex/ASCII dump of memory at address ADDR.
end


# _______________data window__________________
define ddump
    if $argc != 1
        help ddump
    else
        color $COLOR_SEPARATOR
        printf "[0x%08X]", $data_addr

        color $COLOR_SEPARATOR
        printf "-------------------------------"
        color_bold
        color $COLOR_SEPARATOR
        printf "[data]\n"
        color_reset
        set $_count = 0
        while ($_count < $arg0)
            set $_i = ($_count * 0x10)
            hexdump $data_addr+$_i
            set $_count++
        end
    end
end
document ddump
Syntax: ddump NUM
| Display NUM lines of hexdump for address in $data_addr global variable.
end

define dump_hexfile
    dump ihex memory $arg0 $arg1 $arg2
end
document dump_hexfile
Syntax: dump_hexfile FILENAME START_ADDR STOP_ADDR
| Write a range of memory to a file in Intel ihex (hexdump) format.
| The range is specified by START_ADDR and STOP_ADDR addresses.
end


define dump_binfile
    dump memory $arg0 $arg1 $arg2
end
document dump_binfile
Syntax: dump_binfile FILENAME START_ADDR STOP_ADDR
| Write a range of memory to a binary file.
| The range is specified by START_ADDR and STOP_ADDR addresses.
end


define search
    set $start = (char *) $arg0
    set $end = (char *) $arg1
    set $pattern = (short) $arg2
    set $p = $start
    while $p < $end
        if (*(short *) $p) == $pattern
            printf "pattern 0x%hx found at 0x%x\n", $pattern, $p
        end
        set $p++
    end
end
document search
Syntax: search <START> <END> <PATTERN>
| Search for the given pattern beetween $start and $end address.
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
        set $end = $dst + $arg2
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


define memcpy_str
    if $argc != 3
        help memcpy_str
    else
        set $dst = (unsigned char *) $arg0
        set $src = $arg1
        set $end = $dst + $arg2
        set $index = 0
        while $dst < $end
            set *(unsigned char *) $dst = $src[$index]
            set $dst++
            set $index++
        end
    end
end
document memcpy_str
Syntax: memcpy_str <ADDR> <"string"> <LENGTH>
| Like memcpy, but copy the "string" to memery
end


define strcpy
    if $argc != 2
        help strcpy
    else
        set $dst = (char *) $arg0
        set $src = $arg1
        set $index = 0
        while $src[$index] != 0
            set *(char *) $dst = $src[$index]
            set $dst++
            set $index++
        end
        set *(char *) $dst = 0
    end
end
document strcpy
Syntax: strcpy <ADDR> <"string">
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
Syntax: strcat <ADDR> <"string">
| Like strcat
end


define bitset
    set $ok = 1
    if $argc == 3
        set $addr = $arg0
        set $start = $arg1
        set $length = 1
        set $value = $arg2
    else
        if $argc == 4
            set $addr = $arg0
            set $start = $arg1
            set $length = $arg2
            set $value = $arg3
        else
            help bitset
            set $ok = 0
        end
    end

    if $ok
        set $bits_value = *$addr
        set $mask = (1<<$length) - 1
        set $value = $value & $mask
        set $mask = $mask << $start
        set $value_shift = $value << $start
        set *$addr = ($bits_value & (~$mask)) | ($value_shift)

        output/x $addr
        echo [
        output $start
        echo :
        set $end = $start + $length - 1
        output $end
        echo ] = '
        output/x $value
        echo (
        output $value
        echo )'\n
    end
end
document bitset
Syntax: bitset <ADDR> <START_BIT> [<BIT_LENGTH>] <VALUE>
| bit set for register operation
| if no <BIT_LENGTH> field, BIT_LENGTH=1
end


define bitget
    set $ok = 1
    if $argc == 2
        set $addr = $arg0
        set $start = $arg1
        set $length = 1
    else
        if $argc == 3
            set $addr = $arg0
            set $start = $arg1
            set $length = $arg2
        else
            help bitget
            set $ok = 0
        end
    end

    if $ok
        set $bits_value = *$addr
        set $mask = ((1<<$length) - 1) << $start
        set $value = ($bits_value & $mask) >> $start
        output/x $addr
        echo [
        output $start
        echo :
        set $end = $start + $length - 1
        output $end
        echo ] = '
        output/x $value
        echo (
        output $value
        echo )'\n
    end

end
document bitget
Syntax: bitget <ADDR> <START_BIT> [<BIT_LENGTH>]
| bit get for register operation
| if no <BIT_LENGTH> field, BIT_LENGTH=1
end

