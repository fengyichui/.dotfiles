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

######################################################################
# VARIABLES
######################################################################


######################################################################
# FUNCTIONS
######################################################################


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

    """loop command
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
            print("{:08X}".format(save))
            while True:
                cur = int(gdb.parse_and_eval(args))
                if cur != save:
                    print("{:08X}".format(cur))
                    save = cur
        except KeyboardInterrupt:
            pass
        except Exception as e:
            print(e)

######################################################################
# CLASS
######################################################################

# register
loop_command_register()
loop_memery_change_register()

# @} #

