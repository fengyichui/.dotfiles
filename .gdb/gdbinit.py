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
        super(self.__class__, self).__init__("loop_command", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

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

# ignore errors
class ignore_errors_command_register (gdb.Command):
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

# ignore errors and its exceptions
class ignore_exceptions_command_register (gdb.Command):
    """Execute a single command, ignoring all errors and exceptions output.
Only one-line commands are supported.
This is primarily useful in scripts."""

    def __init__ (self):
        super (self.__class__, self).__init__ ("ignore-exceptions", gdb.COMMAND_OBSCURE, gdb.COMPLETE_COMMAND)

    def invoke (self, arg, from_tty):
        try:
            gdb.execute (arg, from_tty)
        except:
            pass

# ignore all error and output
class ignore_all_command_register (gdb.Command):
    """Execute a single command, ignoring all errors and output.
Only one-line commands are supported.
This is primarily useful in scripts."""

    def __init__ (self):
        super (self.__class__, self).__init__ ("ignore-all", gdb.COMMAND_OBSCURE, gdb.COMPLETE_COMMAND)

    def invoke (self, arg, from_tty):
        try:
            gdb.execute (arg, from_tty, to_string=True)
        except:
            pass


# less command
class less_command_register(gdb.Command):

    """less command
    """

    def __init__(self):
        super(self.__class__, self).__init__("less", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

    def invoke(self, args, from_tty):
        os.popen("less","w").write(gdb.execute(args, to_string=True))


# log command
class log_command_register(gdb.Command):

    """log command
    log <gdb.log> command
    """

    def __init__(self):
        super(self.__class__, self).__init__("log", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

    def invoke(self, args, from_tty):
        argv = gdb.string_to_argv(args)
        if len(argv) == 0:
            raise gdb.GdbError('No command!')
        else:
            if re.match(r'^.+\.log$', argv[0]):
                if len(argv) == 1:
                    raise gdb.GdbError('No command!')
                logfile = argv[0]
                cmdpos = 1
            else:
                logfile = 'gdb.log'
                cmdpos = 0
            command = ''.join(str(a)+' ' for a in argv[cmdpos:])
            gdb.execute("log-begin " + logfile, from_tty)
            gdb.execute(command, from_tty)
            gdb.execute("log-end", from_tty)


# log begin command
class log_begin_register(gdb.Command):

    """log begin command
    log-begin <gdb.log>
    """

    def __init__(self):
        super(self.__class__, self).__init__("log-begin", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

    def invoke(self, args, from_tty):
        # End old log
        gdb.execute("log-end", from_tty, to_string=True)
        # Start new log
        gdb.execute("set logging file {}".format('gdb.log' if args=='' else args), from_tty)
        gdb.execute("set logging overwrite on", from_tty)
        gdb.execute("set logging on", from_tty)


# log end command
class log_end_register(gdb.Command):

    """log end command
    """

    def __init__(self):
        super(self.__class__, self).__init__("log-end", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

    def invoke(self, args, from_tty):
        gdb.execute("set logging off", from_tty)
        gdb.execute("set logging overwrite off", from_tty)


# redir command
class redir_command_register(gdb.Command):

    """Auto substitute-path command
    redir <-n> <new-path>
    -n: don't execute "list main"
    new-path: default is current directory
    """

    def __init__(self):
        super(self.__class__, self).__init__("redir", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):
        listmain = True
        # Parse option
        argv = gdb.string_to_argv(args)
        if len(argv) == 0:
            cur_dir = '.'
        else:
            if argv[0] == '-n':
                listmain = False
                cur_dir = '.' if len(argv)==1 else argv[1]
            else:
                cur_dir = argv[0]
        # list main
        if listmain:
            gdb.execute('list main', to_string=True)
        # current dir
        cur_absdir = os.path.realpath(cur_dir)
        # source dir
        src_absdir = None
        src_dir = gdb.execute('info source', to_string=True).splitlines()
        for absdir in src_dir:
            match = re.match(r'^Compilation directory is (.*)$', absdir, flags=re.I)
            if match:
                src_absdir = match.group(1)
                break
        else:
            raise gdb.GdbError("Can't find compilation directory! May be work: 'list main'")
        # substitute-path
        print("'{}' -> '{}'".format(src_absdir, cur_absdir))
        gdb.execute('set substitute-path {} {}'.format(src_absdir.replace("\\", "\\\\"), cur_absdir), from_tty)


# reload file
class reloadfile_command_register(gdb.Command):

    """Reload file
    """

    def __init__(self):
        super(self.__class__, self).__init__("reloadfile", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

    def invoke(self, args, from_tty):
        debug_file = gdb.current_progspace().filename
        if debug_file != None:
            gdb.execute("file {}".format(debug_file), from_tty)


######################################################################
# Register
######################################################################

# register
loop_command_register()
loop_memery_change_register()
restore_dump_reg_register()
restore_dump_memery_register()
ignore_errors_command_register()
ignore_exceptions_command_register()
ignore_all_command_register()
less_command_register()
log_command_register()
log_begin_register()
log_end_register()
redir_command_register()
reloadfile_command_register()

# @} #

