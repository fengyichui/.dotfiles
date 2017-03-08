######################################################################
# @file makeiar.py
# @brief 
# @date 2016/11/10 9:20:29
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
import sys
import os
import subprocess
import glob

######################################################################
# MAIN
######################################################################

iarparams = {'clean':'-clean', 'make':'-make'}

def isewp(ewp):
    if os.path.isdir(ewp) and len(glob.glob(os.path.abspath(ewp) + '/*.ewp'))>0:
        return True
    elif os.path.isfile(ewp):
        return True
    else:
        return False

# make
# make config
# make flag
# make ewp
# make flag config
# make ewp config
# make ewp flag
# make ewp flag config
flag = 'make'
config = 'Debug'
ewp = '.'
paramnum = len(sys.argv)-1
if paramnum==0: # make
    pass
elif paramnum==1:
    if sys.argv[1] in iarparams: # make flag
        flag = sys.argv[1]
    elif isewp(sys.argv[1]): # make ewp
        ewp = sys.argv[1]
    else:
        config = sys.argv[1] # make config
elif paramnum==2:
    if sys.argv[1] in iarparams: # make flag config
        flag = sys.argv[1]
        config = sys.argv[2]
    elif sys.argv[2] in iarparams: # make ewp flag
        ewp = sys.argv[1]
        flag = sys.argv[2]
    else: # make ewp config
        ewp = sys.argv[1]
        config = sys.argv[2]
else: # make ewp flag config
    ewp = sys.argv[1]
    if sys.argv[2] in iarparams:
        flag = sys.argv[2]
    config = sys.argv[3]

if not os.path.exists(ewp):
    print("[Error] Not exist this path: " + ewp)
    sys.exit(-1)

ewp = os.path.abspath(ewp)
if os.path.isdir(ewp):
    ewps = glob.glob(ewp + '/*.ewp')
    if len(ewps)==0:
        print("[Error] Not exist ewp project: " + ewp)
        sys.exit(-2)
    else:
        ewp = ewps[0]

print('{}: {} ({})'.format(flag, ewp, config))
sys.stdout.flush()

iar_process = subprocess.Popen('iarbuild "' + ewp + '" ' + iarparams[flag] + ' ' + config)
iar_process.wait()

# @} #

