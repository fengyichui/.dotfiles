######################################################################
# @file gdbinit.py
# @brief 
# @date Tue, Mar  6, 2018  4:37:46 PM
# @author liqiang
#
# @addtogroup 
# @ingroup 
# @details 
#
# @{
######################################################################

######################################################################
# IMPORT
######################################################################
import gdb
import os
import time
import re

######################################################################
# VARIABLES
######################################################################


######################################################################
# FUNCTIONS
######################################################################

def parse_dump_data(file_path, parse_reg=False, parse_mem=False):

    cmds = []
    ignore = False

    f = open(file_path, 'r')
    for line in f.readlines():

        # comment
        match = re.match(r'^\s*#', line)
        if match:
            continue

        # if 0
        match = re.match(r'^if 0', line, flags=re.I)
        if match:
            ignore = True

        # endif
        match = re.match(r'^endif', line, flags=re.I)
        if match:
            ignore = False

        # ignore
        if ignore:
            continue

        # restore reg
        if parse_reg:
            match = re.match(r'^(\w+)\s+(0x[0-9a-f]+)\s', line, flags=re.I)
            if match:
                cmds += ["set ${}={}".format(match.group(1), match.group(2))]

        # restore memery
        if parse_mem:
            match = re.match(r'^(0x[0-9a-f]+):\s+(0x[0-9a-f]+)(?:\s+(0x[0-9a-f]+))?(?:\s+(0x[0-9a-f]+))?(?:\s+(0x[0-9a-f]+))?', line, flags=re.I)
            if match:
                address = int(match.group(1), 0)
                cmds += ["set *0x{:08x}={}".format(address, match.group(2))]
                if match.group(3):
                    cmds += ["set *0x{:08x}={}".format(address+4, match.group(3))]
                if match.group(4):
                    cmds += ["set *0x{:08x}={}".format(address+8, match.group(4))]
                if match.group(5):
                    cmds += ["set *0x{:08x}={}".format(address+12, match.group(5))]

    f.close()

    return cmds

######################################################################
# CLASS
######################################################################

# loop command
class loop_command_register(gdb.Command):

    """loop command
    """

    def __init__(self):
        super(self.__class__, self).__init__("loop_command", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            raise gdb.GdbError('Invalid params!')

        # loop
        try:
            while True:
                gdb.execute(args)
                time.sleep(0.2)
        except KeyboardInterrupt:
            pass
        except Exception as e:
            print(e)


# loop memery change
class loop_memery_change_register(gdb.Command):

    """loop memery change
    """

    def __init__(self):
        super(self.__class__, self).__init__("loop_memery_change", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            raise gdb.GdbError('Invalid params!')

        # loop
        try:
            save = int(gdb.parse_and_eval(args))
            time_base = time.time()
            print("{:0>8.3f}: {:08X} {}".format(0, save, save))
            while True:
                cur = int(gdb.parse_and_eval(args))
                if cur != save:
                    print("{:0>8.3f}: {:08X} {}".format(time.time()-time_base, cur, cur))
                    save = cur
        except KeyboardInterrupt:
            pass
        except Exception as e:
            print(e)

# restore reg
class restore_dump_reg_register(gdb.Command):

    """restore dump reg
    """

    def __init__(self):
        super(self.__class__, self).__init__("restore_dump_reg", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            raise gdb.GdbError('missing restore file!')

        cmds = parse_dump_data(args, parse_reg=True)

        for cmd in cmds:
            print(cmd)
            gdb.execute(cmd)

# restore dump memery
class restore_dump_memery_register(gdb.Command):

    """restore dump memery
    """

    def __init__(self):
        super(self.__class__, self).__init__("restore_dump_mem", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            raise gdb.GdbError('missing restore file!')

        cmds = parse_dump_data(args, parse_mem=True)

        for cmd in cmds:
            print(cmd)
            gdb.execute(cmd)

class ignore_errors_command (gdb.Command):
    """Execute a single command, ignoring all errors.
Only one-line commands are supported.
This is primarily useful in scripts."""

    def __init__ (self):
        super (self.__class__, self).__init__ ("ignore-errors", gdb.COMMAND_OBSCURE, gdb.COMPLETE_COMMAND)

    def invoke (self, arg, from_tty):
        try:
            gdb.execute (arg, from_tty)
        except Exception as e:
            print(e)


######################################################################
# CLASS
######################################################################

# register
loop_command_register()
loop_memery_change_register()
restore_dump_reg_register()
restore_dump_memery_register()
ignore_errors_command()

# @} #

