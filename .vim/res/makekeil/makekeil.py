######################################################################
# @file makekeil.py
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
import threading
import sys
import os
import time
import psutil
import subprocess
import tempfile
import glob

######################################################################
# VARIABLES
######################################################################
keilparams = {'make':'-j0 -b', 'clean':'-j0 -c', 'debug':'-d', 'download':'-f'}

keil_process = None
tail_process = None
keil_thread = None
tail_thread = None

ppid = os.getppid()
tmpfilefd, tmpfilename = tempfile.mkstemp()
os.close(tmpfilefd)

# make
# make flag
# make uvproj
# make uvproj flag
flag = 'make'
uvproj = '.'
paramnum = len(sys.argv)-1
if paramnum==0: # make
    pass
elif paramnum==1:
    if sys.argv[1] in keilparams: # make flag
        flag = sys.argv[1]
    else: # make uvproj
        uvproj = sys.argv[1]
else: # make uvproj flag
    uvproj = sys.argv[1]
    if sys.argv[2] in keilparams:
        flag = sys.argv[2]

if not os.path.exists(uvproj):
    print("[Error] Not exist this path: " + uvproj)
    sys.exit(-1)

uvproj = os.path.abspath(uvproj)
if os.path.isdir(uvproj):
    uvprojs = glob.glob(uvproj + '/*.uvproj')
    if len(uvprojs)==0:
        print("[Error] Not exist uvproj project: " + uvproj)
        sys.exit(-2)
    else:
        uvproj = uvprojs[0]

print('{}: {}'.format(flag, uvproj))
print('Entering directory: {}'.format(os.path.dirname(uvproj)))
sys.stdout.flush()

######################################################################
# FUNCTIONS
######################################################################

def keil_handler():
    global keil_process
    keil_process = subprocess.Popen('UV4 ' + keilparams[flag] + ' "' + uvproj + '" -o "' + tmpfilename + '"')
    keil_process.wait()

def tail_handler():
    global tail_process
    tail_process = subprocess.Popen('tail -f "' + tmpfilename + '"')
    tail_process.wait()

def guard_handler():
    while 1:
        if not psutil.pid_exists(ppid):
            keil_process.kill()
            tail_process.kill()
            break

        if not keil_thread.is_alive():
            if tail_thread.is_alive():
                time.sleep(0.5)
                tail_process.kill()
            break

        if not tail_thread.is_alive():
            if keil_thread.is_alive():
                keil_process.kill()
            break

        time.sleep(0.1)


######################################################################
# MAIN
######################################################################

keil_thread  = threading.Thread(target=keil_handler)
tail_thread  = threading.Thread(target=tail_handler)
guard_thread = threading.Thread(target=guard_handler)

keil_thread.start()
tail_thread.start()

while keil_process==None or tail_process==None:
    time.sleep(0.01)

guard_thread.start()

keil_thread.join()
tail_thread.join()
guard_thread.join()

if os.path.isfile(tmpfilename):
    os.unlink(tmpfilename)

print('Leaving directory')
sys.stdout.flush()

# @} #

