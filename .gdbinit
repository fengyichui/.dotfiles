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


define dump_fault_armcm
    set $ok = 1
    set $_ispr = $xpsr & 0x1FF
    if $_ispr == 0
        printf "No Any Faults!\n"
        set $ok = 0
    else
        if $_ispr == 3
            printf "Hardware Fault IRQ Pending\n"
        else
            if $_ispr == 4
                printf "Memory Manage Fault IRQ Pending\n"
            else
                if $_ispr == 5
                    printf "Bus Fault IRQ Pending\n"
                else
                    if $_ispr == 6
                        printf "Usage Fault IRQ Pending\n"
                    else
                        if $_ipsr > 15
                            printf "General IRQ Pending: %d\n", $_ipsr
                            set $ok = 0
                        else
                            printf "Unkown Fault IRQ Pending: %d\n", $_ipsr
                        end
                    end
                end
            end
        end
    end
    printf "\n"

    if $ok
        set $mem_fault_status   = *(unsigned char  *)0xE000ED28
        set $bus_fault_status   = *(unsigned char  *)0xE000ED29
        set $usage_fault_status = *(unsigned short *)0xE000ED2A
        set $hard_fault_status  = *(unsigned int   *)0xE000ED2C
        set $debug_fault_status = *(unsigned int   *)0xE000ED30
        set $aux_fault_status   = *(unsigned int   *)0xE000ED3C

        # Hardware fault
        if $hard_fault_status
            printf "Hardware fault status:\n"
            if $hard_fault_status & (1<<1)
                printf "- Indicates hard fault is caused by failed vector fetch\n"
                printf "  Vector fetch failed. It could be caused by\n"
                printf "  1. Bus fault at vector fetch.\n"
                printf "  2. Incorrect vector table offset setup.\n"
            end
            if $hard_fault_status & (1<<30)
                printf "- Indicates hard fault is taken because of bus fault, memory management fault, or usage fault\n"
                printf "  1. Trying to run SVC/BKPT within SVC/monitor or another handler with same or\n"
                printf "     higher priority.\n"
                printf "  2. A fault occurred if the corresponding handler is disabled or cannot be started\n"
                printf "     because another exception with the same or higher priority is running, or because\n"
                printf "     exception mask is set.\n"
            end
            if $hard_fault_status & (1<<30)
                printf "- Indicates hard fault is triggered by debug event\n"
                printf "  Fault is caused by debug event:\n"
                printf "  1. Breakpoint/watchpoint events.\n"
                printf "  2. If the hard fault handler is executing, it might be caused by execution of BKPT\n"
                printf "     without enable monitor handler (MON_EN = 0) and halt debug is not enabled\n"
                printf "     (C_DEBUGEN = 0). By default, some C compilers might include semihosting\n"
                printf "     code that use BKPT.\n"
            end
            printf "\n"
        end

        # Memory fault
        if $mem_fault_status
            printf "Memory fault status:\n"
            if $mem_fault_status & (1<<0)
                printf "- Instruction access violation\n"
                printf "  1. Violation to memory access protection, which is defined by MPU setup. For\n"
                printf "     example, user application trying to access privileged-only region. Stacked PC\n"
                printf "     might be able to locate the code that has caused the problem.\n"
                printf "  2. Branch to nonexecutable regions.\n"
                printf "  3. Invalid exception return code.\n"
                printf "  4. Invalid entry in exception vector table. For example, loading of an executable\n"
                printf "     image for traditional ARM core into the memory, or exception happened before\n"
                printf "     vector table was set.\n"
                printf "  5. Stacked PC corrupted during exception handling.\n"
            end
            if $mem_fault_status & (1<<1)
                printf "- Data access violation\n"
                printf "  Violation to memory access protection, which is defined by MPU setup. For\n"
                printf "  example, user application trying to access privileged-only region.\n"
            end
            if $mem_fault_status & (1<<3)
                printf "- Unstacking error\n"
                printf "  Error occurred during unstacking (ending of exception). If there was no error\n"
                printf "  stacking but error occurred during unstacking, it might be because of the\n"
                printf "  following reasons:\n"
                printf "  1. Stack pointer was corrupted during exception.\n"
                printf "  2. MPU configuration was changed by exception handler.\n"
            end
            if $mem_fault_status & (1<<4)
                printf "- Stacking error\n"
                printf "  Error occurred during stacking (starting of exception).\n"
                printf "  1. Stack pointer is corrupted.\n"
                printf "  2. Stack size is too large, reaching a region not defined by the MPU or disallowed\n"
                printf "     in the MPU configuration.\n"
            end
            if $mem_fault_status & (1<<7)
                # Indicates MMAR is valid
                set $mem_fault_addr = *(unsigned int *)0xE000ED34
                printf "- Address that caused memory manage fault: 0x%08X\n", $mem_fault_addr
            end
            printf "\n"
        end

        # Bus fault
        if $bus_fault_status
            printf "Bus fault status:\n"
            if $bus_fault_status & (1<<0)
                printf "- Instruction access violation\n"
                printf "  1. Branch to invalid memory regions; for example, caused by incorrect function\n"
                printf "     pointers in program code.\n"
                printf "  2. I nvalid exception return code; for example, a stacked EXC_RETURN code is\n"
                printf "     corrupted, and as a result, an exception return incorrectly treated as a branch.\n"
                printf "  3. Invalid entry in exception vector table. For example, loading of an executable\n"
                printf "     image for traditional ARM core into the memory, or exception, happens before\n"
                printf "     the vector table is set.\n"
                printf "  4. Stacked PC corrupted during function calls.\n"
                printf "  5. Access to NVIC or SCB in user mode (nonprivileged).\n"
            end
            if $bus_fault_status & (1<<1)
                printf "- Precise data access violation\n"
                printf "  Bus error during data access. The fault address may be indicated by BFAR. A bus\n"
                printf "  error could be caused by the device not being initialized, access of privileged-only\n"
                printf "  device in user mode, or the transfer size is incorrect for the specific device.\n"
            end
            if $bus_fault_status & (1<<2)
                printf "- Imprecise data access violation\n"
                printf "  Bus error during data access. Bus error could be caused by the device not being\n"
                printf "  initialized, access of privileged-only device in user mode, or the transfer size is\n"
                printf "  incorrect for the specific device.\n"
            end
            if $bus_fault_status & (1<<3)
                printf "- Unstacking error\n"
                printf "  Error occurred during unstacking (ending of exception). If there was no error\n"
                printf "  stacking but error occurred during unstacking, it might be that the stack pointer\n"
                printf "  was corrupted during exception.\n"
            end
            if $bus_fault_status & (1<<4)
                printf "- Stacking error\n"
                printf "  Error occurred during stacking (starting of exception).\n"
                printf "  1. Stack pointer is corrupted.\n"
                printf "  2. Stack size became too large, reaching an undefined memory region.\n"
                printf "  3. PSP is used but not initialized.\n"
            end
            if $bus_fault_status & (1<<7)
                # Indicates BFAR is valid
                set $bus_fault_addr = *(unsigned int *)0xE000ED38
                printf "- Address that caused bus fault: 0x%08X\n", $bus_fault_addr
            end
            printf "\n"
        end

        # Usage fault
        if $usage_fault_status
            printf "Usage fault status:\n"
            if $usage_fault_status & (1<<0)
                printf "- Attempts to execute an undefined instruction\n"
                printf "  1. Use of instructions not supported in Cortex-M3.\n"
                printf "  2. Bad/corrupted memory contents.\n"
                printf "  3. Loading of ARM object code during link stage. Checks compile steps.\n"
                printf "  4. Instruction align problem. For example, if GNU Tool chain is used, omitting\n"
                printf "     of .align after .ascii might cause next instruction to be unaligned (start in odd\n"
                printf "     memory address instead of halfword addresses).\n"
            end
            if $usage_fault_status & (1<<1)
                printf "- Attempts to switch to invalid state (e.g., ARM)\n"
                printf "  1. Loading branch target address to PC with LSB equals 0. Stacked PC should\n"
                printf "     show the branch target.\n"
                printf "  2. LSB of vector address in vector table is 0. Stacked PC should show the starting\n"
                printf "     of exception handler.\n"
                printf "  3. Stacked PSR corrupted during exception handling, so after the exception the\n"
                printf "     core tries to return to the interrupted code in ARM state.\n"
            end
            if $usage_fault_status & (1<<2)
                printf "- Attempts to do exception with bad value in EXC_RETURN number\n"
                printf "  1. Invalid value in EXC_RETURN number during exception return. For example,\n"
                printf "     a. Return to thread with EXC_RETURN = 0xFFFFFFF1\n"
                printf "     b. Return to handler with EXC_RETURN = 0xFFFFFFF9\n"
                printf "     To investigate the problem, the current LR value provides the value of LR at\n"
                printf "     the failing exception return.\n"
                printf "  2. Invalid exception active status. For example,\n"
                printf "     a. Exception return with exception active bit for the current exception already\n"
                printf "        cleared. Possibly caused by use of VECTCLRACTIVE, or clearing of exception\n"
                printf "        active status in NVIC SHCSR.\n"
                printf "     b. Exception return to thread with one or more exception active bits still active.\n"
                printf "  3. Stack corruption causing the stacked IPSR to be incorrect.\n"
                printf "     For INVPC fault, the stacked PC shows the point where the faulting exception\n"
                printf "     interrupted the main/preempted program. To investigate the cause of the\n"
                printf "     problem, it is best to use exception trace feature in the DWT.\n"
                printf "  4. ICI/IT bit invalid for current instruction. This can happen when a multiple-load/\n"
                printf "     store instruction gets interrupted and, during the interrupt handler, the stacked\n"
                printf "     PC is modified. When the interrupt return takes place, the nonzero ICI bit is\n"
                printf "     applied to an instruction that does not use ICI bits. The same problem can also\n"
                printf "     happen because of corruption of stacked PSR.\n"
            end
            if $usage_fault_status & (1<<3)
                printf "- Attempts to execute a coprocessor instruction\n"
                printf "  Attempt to execute a coprocessor instruction. The code causing the fault can be\n"
                printf "  located using stacked PC.\n"
            end
            if $usage_fault_status & (1<<8)
                printf "- Indicates unaligned access takes place (can only be set if UNALIGN_TRP is set)\n"
                printf "  Unaligned access attempted with UNALIGN_TRP is set. The code causing the fault\n"
                printf "  can be located using stacked PC.\n"
            end
            if $usage_fault_status & (1<<9)
                printf "- Indicates divide by zero takes place (can only be set if DIV_0_TRP is set)\n"
                printf "  Divide by 0 takes place and DIV_0_TRP is set. The code causing the fault can be\n"
                printf "  located using stacked PC.\n"
            end
            printf "\n"
        end

        # Debug Fault
        if $debug_fault_status
            printf "Debug fault status:\n"
            if $debug_fault_status & (1<<0)
                printf "- Halt requested in NVIC\n"
            end
            if $debug_fault_status & (1<<1)
                printf "- BKPT instruction executed\n"
                printf "  1. Breakpoint instruction is executed.\n"
                printf "  2. FPB unit generated a breakpoint event.\n"
                printf "  In some cases, BKPT instructions are inserted by C startup code as part of the\n"
                printf "  semihosting debugging setup. This should be removed for a real application code.\n"
                printf "  Please refer to your compiler document for details.\n"
            end
            if $debug_fault_status & (1<<2)
                printf "- DWT match occurred\n"
            end
            if $debug_fault_status & (1<<3)
                printf "- Vector fetch occurred\n"
            end
            if $debug_fault_status & (1<<4)
                printf "- EDBGRQ signal asserted\n"
            end
            printf "\n"
        end

        # Auxiliary Fault
        if $aux_fault_status
            printf "Auxiliary Fault Status: 0x%08X\n", $aux_fault_status
            printf "\n"
        end
    end
end
document dump_fault_armcm
Dump cortex-M0/M1/M3/M4 fault information
end


define dump_reg_armcm
    printf "SCB:\n"
    printf "- CPUID Base Register: 0x%08X\n", *0xe000ed00
    printf "- Interrupt Control and State Register: 0x%08X\n", *0xe000ed04
    printf "- Vector Table Offset Register: 0x%08X\n", *0xe000ed08
    printf "- Application Interrupt and Reset Control Register: 0x%08X\n", *0xe000ed0C
    printf "- System Control Register: 0x%08X\n", *0xe000ed10
    printf "- Configuration Control Register: 0x%08X\n", *0xe000ed14
    printf "- System Handlers Priority Registers (4-15): %02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X,%02X\n", \
        *(unsigned char *)0xe000ed18, *(unsigned char *)0xe000ed19,*(unsigned char *)0xe000ed1a,*(unsigned char *)0xe000ed1b, \
        *(unsigned char *)0xe000ed1c, *(unsigned char *)0xe000ed1d,*(unsigned char *)0xe000ed1e,*(unsigned char *)0xe000ed1f, \
        *(unsigned char *)0xe000ed20, *(unsigned char *)0xe000ed21,*(unsigned char *)0xe000ed22,*(unsigned char *)0xe000ed23
    printf "- System Handler Control and State Register: 0x%08X\n", *0xe000ed24
    printf "- Configurable Fault Status Register: 0x%08X\n", *0xe000ed28
    printf "- HardFault Status Register: 0x%08X\n", *0xe000ed2C
    printf "- Debug Fault Status Register: 0x%08X\n", *0xe000ed30
    printf "- MemManage Fault Address Register: 0x%08X\n", *0xe000ed34
    printf "- BusFault Address Register: 0x%08X\n", *0xe000ed38
    printf "- Auxiliary Fault Status Register: 0x%08X\n", *0xe000ed3C
    printf "- Processor Feature Register: 0x%08X,%08X\n", *0xe000ed40, *0xe000ed44
    printf "- Debug Feature Register: 0x%08X\n", *0xe000ed48
    printf "- Auxiliary Feature Register: 0x%08X\n", *0xe000ed4C
    printf "- Memory Model Feature Register: 0x%08X,%08X,%08X,%08X\n", *0xe000ed50, *0xe000ed54, *0xe000ed58, *0xe000ed5C
    printf "- Instruction Set Attributes Register: 0x%08X,%08X,%08X,%08X,%08X\n", *0xe000ed60, *0xe000ed64, *0xe000ed68, *0xe000ed6C, *0xe000ed70
    printf "- Coprocessor Access Control Register: 0x%08X\n", *0xe000ed88
    printf "\n"

    printf "NVIC:\n"
    set $irq_en_0_31 = *0xE000E100
    set $irq_en_32_63 = *0xE000E104
    printf "- Enable for external Interrupt #0–31: 0x%08X, #32-63: %08X\n", $irq_en_0_31, $irq_en_32_63
    printf "- Pending for external Interrupt #0–31: 0x%08X, #32-63: %08X\n", *0xE000E200, *0xE000E204
    printf "- Active status for external Interrupt #0–31: 0x%08X, #32-63: %08X\n", *0xE000E300, *0xE000E304
    printf "- Priority-level external Interrupt:"
    set $i = 0
    while $i < 64
        if ($i % 4) == 0
            printf "\n  #%02d-%02d: ", $i, $i+3
        end
        if $i < 32
            set $enable = $irq_en_0_31 & (1<<$i)
        else
            set $enable = $irq_en_32_63 & (1<<($i-32))
        end
        if $enable
            printf "%02X* ", *(unsigned char *)(0xE000E400+$i)
        else
            printf "%02X  ", *(unsigned char *)(0xE000E400+$i)
        end
        set $i++
    end
    printf "\n"
end
document dump_reg_armcm
Dump cortex-M0/M1/M3/M4 register information
end

# __________________END USER COMMAND_________________
#

