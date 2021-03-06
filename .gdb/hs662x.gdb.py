######################################################################
# @file hs662x.py
# @brief 
# @date Sun, Jan 14, 2018 10:46:34 PM
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
from __future__ import print_function

import gdb
import os
import time

######################################################################
# VARIABLES
######################################################################
flash_id = 0
flash_size = 1024*512
flash_sector_size = 1024*4
device_name = 'UNKNOWN'
device_version = 'XX'
debug_file = ''
script_dir = os.path.dirname(__file__)

flash_vendor_table = {
    0x85: 'PUYA',            # Puya
    0xE0: 'BOYA_0',          # Boya
    0x68: 'BOYA_1',          # Boya
    0xEB: 'TONGXIN',          # TongXin
    0x52: 'ALLIANCE',        # Alliance Semiconductor
    0x01: 'AMD',             # AMD
    0x37: 'AMIC',            # AMIC
    0x1F: 'ATMEL',           # Atmel (now used by Adesto)
    0xAD: 'BRIGHT',          # Bright Microelectronics
    0x31: 'CATALYST',        # Catalyst
    0x8C: 'ESMT',            # Elite Semiconductor Memory Technology (ESMT) / EFST Elite Flash Storage
    0x1C: 'EON',             # EON, missing 0x7F prefix
    0x4A: 'EXCEL',           # ESI, missing 0x7F prefix
    0xF8: 'FIDELIX',         # Fidelix
    0x04: 'FUJITSU',         # Fujitsu
    0xC8: 'GIGADEVICE',      # GigaDevice
    0x50: 'GIGADEVICE_XD',   # GigaDevice
    0x51: 'GIGADEVICE_MD',   # GigaDevice
    0xAD: 'HYUNDAI',         # Hyundai
    0x1F: 'IMT',             # Integrated Memory Technologies
    0x89: 'INTEL',           # Intel
    0xD5: 'ISSI',            # ISSI Integrated Silicon Solutions, see also PMC
    0xC2: 'MACRONIX',        # Macronix (MX)
    0xD5: 'NANTRONICS',      # Nantronics, missing prefix
    0x9D: 'PMC',             # PMC, missing 0x7F prefix
    0x62: 'SANYO',           # Sanyo
    0xB0: 'SHARP',           # Sharp
    0x01: 'SPANSION',        # Spansion, same ID as AMD
    0xBF: 'SST',             # SST
    0x20: 'ST',              # ST / SGS/Thomson / Numonyx (later acquired by Micron)
    0x40: 'SYNCMOS_MVC',     # SyncMOS (SM) and Mosel Vitelic Corporation (MVC)
    0x97: 'TI',              # Texas Instruments
    0xEF: 'WINBOND_NEX',     # Winbond (ex Nexcom) serial flashes
    0xDA: 'WINBOND',         # Winbond
    0x0B: 'XTX',             # http://www.xtxtech.com/
}

FLASH_PART_APP           = 2
FLASH_PART_CFG           = 4
FLASH_PART_PATCH         = 5

FLASH_APP_BASE_ADDR      = 3 * flash_sector_size
FLASH_CFG_BASE_ADDR_N    = 4 * flash_sector_size
FLASH_PATCH_BASE_ADDR_DN = 4 * flash_sector_size

APP_MAX_SIZE             = 128 * flash_sector_size
CFG_MAX_SIZE             = 3 * flash_sector_size
PATCH_MAX_SIZE           = 2 * flash_sector_size

ONCE_OP_SIZE            = 32*1024

######################################################################
# FUNCTIONS
######################################################################

def chip():
    global device_name
    global device_version
    device_name = 'UNKNOWN'
    device_version = 'XX'

    # 0x40000004:
    # HS6621:   0x10a16621
    # HS6621C:  0xc0a16621
    # HS6621CB: 0xc0b16621
    # HS6621D:  0xd0a16621
    # HS6621P:  0x70a16621
    #
    # 0x08000034/0x00100034:
    # HS6621 A3:  0x66210300
    # HS6621C A2: 0x6621c200
    # HS6621C B1: 0x6621cb10
    # OM6621D A1: 0x6621d100
    chip_id = int(gdb.parse_and_eval('*0x40000004').cast(gdb.lookup_type('int')))
    chip_major_id = chip_id & 0xFFFF
    chip_sub_id = (chip_id >> 28) & 0xF
    chip_sub_b_id = (chip_id >> 20) & 0xF

    if chip_major_id == 0x6620:
        device_name = 'HS6620'
        device_version = 'A{}'.format((int(gdb.parse_and_eval('*0x08000034').cast(gdb.lookup_type('int')))>>8) & 0xFF)

    elif chip_major_id == 0x6621:
        if chip_sub_id == 0x1:
            device_name = 'HS6621'
            device_version = 'A{}'.format((int(gdb.parse_and_eval('*0x08000034').cast(gdb.lookup_type('int')))>>8) & 0xFF)
        else:
            if chip_sub_id == 0x7:
                device_name = 'HS6621P'
            else:
                device_name = 'HS6621{:X}'.format(chip_sub_id)
            if chip_sub_b_id == 0xB:
                device_version = 'B{}'.format((int(gdb.parse_and_eval('*0x00100034').cast(gdb.lookup_type('int')))>>4) & 0x0F)
            else:
                device_version = 'A{}'.format((int(gdb.parse_and_eval('*0x00100034').cast(gdb.lookup_type('int')))>>8) & 0x0F)

    else:
        raise gdb.GdbError("Can't detect supported chip!")

    return {'name':device_name, 'version':device_version}


def flash_finish():
    gdb.execute('file {}'.format(debug_file), to_string=True)


def flash_prepare_and_show():
    # global
    global flash_size
    global flash_id
    global debug_file

    # save user debug file
    debug_file = gdb.current_progspace().filename
    if debug_file == None:
        debug_file = ''

    # chip info
    chip_info = chip()

    # FLM
    if chip_info['name']=='HS6620' or chip_info['name']=='HS6621':
        flash_flm = 'HS662X.GDB.FLM'
    else:
        flash_flm = 'HS6621C.GDB.FLM'

    # Show device name
    print('Device: {} {}'.format(device_name, device_version))

    # Init
    gdb.execute('mon reset 1', to_string=True)
    gdb.execute('mon halt', to_string=True)
    gdb.execute('file {}/{}'.format(script_dir, flash_flm), to_string=True)
    gdb.execute('restore {}/{}'.format(script_dir, flash_flm), to_string=True)
    gdb.execute('set $sp=&m_stack_mem[1024]')
    gdb.execute('set $res=Init(0, 6000000, 3)')

    # Ext
    flash_id_ext = int(gdb.parse_and_eval('sf_readId(1)'))
    if flash_id_ext==0x0 or flash_id_ext==0xFFFFFF:
        flash_size_ext = 0
        flash_vendor_ext = 'None'
    else:
        flash_vendor_id_ext = (flash_id_ext >> 16) & 0xff
        flash_size_id_ext   = (flash_id_ext >> 0 ) & 0xff
        flash_size_ext = 1 << flash_size_id_ext
        if flash_vendor_id_ext in flash_vendor_table:
            flash_vendor_ext = flash_vendor_table[flash_vendor_id_ext]
        else:
            flash_vendor_ext = 'Unknown'
    # Inside
    flash_id = int(gdb.parse_and_eval('sf_readId(0)'))
    if flash_id==0x0 or flash_id==0xFFFFFF:
        flash_size = 0
        flash_vendor = 'None'
    else:
        flash_vendor_id = (flash_id >> 16) & 0xff
        flash_size_id   = (flash_id >> 0 ) & 0xff
        flash_size = 1 << flash_size_id
        if flash_vendor_id in flash_vendor_table:
            flash_vendor = flash_vendor_table[flash_vendor_id]
        else:
            flash_vendor = 'Unknown'
    print('Flash: {} {}KB (0x{:06X})'.format(flash_vendor, int(flash_size/1024), flash_id))
    print('FlashExt: {} {}KB (0x{:06X})'.format(flash_vendor_ext, int(flash_size_ext/1024), flash_id_ext))

    if flash_size==0 and flash_size_ext==0:
        flash_finish()
        raise gdb.GdbError('No valid Flash!')


def mem32_read(addr):
    value = int(gdb.parse_and_eval('*{}'.format(addr)).cast(gdb.lookup_type('unsigned long')))
    return value


def mem32_write(addr, value):
    gdb.execute('set *{}={}'.format(addr, value))


def loop_do_show_progress(prompt, size, callback, once_op_size=ONCE_OP_SIZE, param=()):
    # HS6621D only 24K SRAM
    if device_name == 'HS6621D':
        once_op_size = 8*1024
    # progress
    before_time = time.time()
    addr = 0
    while addr < size:
        print("{} {:d}%\r".format(prompt, int(100*addr/size)), end='')
        sys.stdout.flush()
        left = size - addr
        length = left if left<once_op_size else once_op_size
        callback(addr, length, param)
        addr += length
    print("{} 100% ({:.1f}s)".format(prompt, time.time()-before_time))


def flash_download_part(part_type, file_path, is_verify=True):

    # Prepare
    flash_prepare_and_show()

    # Get file size
    file_size = os.path.getsize(file_path)

    # Get flash base address
    if part_type == FLASH_PART_APP:
        if file_size > APP_MAX_SIZE:
            raise gdb.GdbError('Too larger APP file')
        flash_base_addr = FLASH_APP_BASE_ADDR
        erase_size = file_size
    elif part_type == FLASH_PART_CFG:
        if file_size > CFG_MAX_SIZE:
            raise gdb.GdbError('Too larger CFG file')
        flash_base_addr = flash_size - FLASH_CFG_BASE_ADDR_N
        erase_size = CFG_MAX_SIZE
    elif part_type == FLASH_PART_PATCH:
        file_size_align = (file_size + flash_sector_size - 1) / flash_sector_size * flash_sector_size
        if file_size_align > PATCH_MAX_SIZE:
            raise gdb.GdbError('Too larger PATCH file')
        flash_base_addr = flash_size - FLASH_PATCH_BASE_ADDR_DN - file_size_align
        erase_size = file_size_align
    else:
        raise gdb.GdbError('invalid part')

    # show burn info
    print('{}: {:.1f}kB (0x{:08X} in flash)'.format(file_path, file_size/1024.0, flash_base_addr))

    # get buffer
    buf = int(gdb.parse_and_eval('FlashDevice.sectors').cast(gdb.lookup_type('int')))

    # Erase
    print("  Erase...\r", end='')
    gdb.execute('set $res=Init(0, 6000000, 1)')
    gdb.execute('set $res=ImageInfoReset({})'.format(flash_base_addr))
    def flash_erase_handler(addr, length, param):
        num = (length+flash_sector_size-1) / flash_sector_size
        gdb.execute('set $res=EraseSectorEx({},{})'.format(addr, num))
    loop_do_show_progress("  Erase...", erase_size, flash_erase_handler, param=())
    gdb.execute('set $res=UnInit(1)')

    # Program
    print("  Program...\r", end='')
    gdb.execute('set $res=Init(0, 6000000, {})'.format(int(part_type)))
    gdb.execute('set $res=ImageInfoReset({})'.format(flash_base_addr))
    def flash_program_handler(addr, length, param=(file_path,buf)):
        gdb.execute('restore {} binary {} {} {}'.format(file_path, buf-addr, addr, addr+length), to_string=True)
        gdb.execute('set $res=ProgramPage({}, {}, {})'.format(addr, length, buf))
    loop_do_show_progress("  Program...", file_size, flash_program_handler, param=(file_path,buf))
    gdb.execute('set $res=UnInit({})'.format(int(part_type)))

    # Verify
    if is_verify:
        print("  Verify...\r", end='')
        gdb.execute('set $res=Init(0, 6000000, 3)')
        gdb.execute('set $res=ImageInfoReset({})'.format(flash_base_addr))
        def flash_verify_handler(addr, length, param=(file_path,buf)):
            gdb.execute('restore {} binary {} {} {}'.format(file_path, buf-addr, addr, addr+length), to_string=True)
            gdb.execute('set $res=Verify({}, {}, {})'.format(addr, length, buf))
            res = int(gdb.parse_and_eval('$res').cast(gdb.lookup_type('int')))
            if res != addr + length:
                raise gdb.GdbError('  Verify FAIL: 0x{:08X}!=0x{:08X}'.format(res, addr+length))
        loop_do_show_progress("  Verify...", file_size, flash_verify_handler, param=(file_path,buf))
        gdb.execute('set $res=UnInit(3)')

    # Finish
    print("Finish")
    flash_finish()


######################################################################
# CLASS
######################################################################

# disable wdt
class disable_wdt_register(gdb.Command):

    """HS662x diable WDT
    """

    def __init__(self):
        super(self.__class__, self).__init__("disable_wdt", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        gdb.execute('set *0x400e0024 |= 1<<27')
        gdb.execute('set *0x400e00e8 = 0x6666')
        print("WDT is disabled")


# remap to ROM
class remap_register(gdb.Command):

    """HS662x remap
    """

    def __init__(self):
        super(self.__class__, self).__init__("remap", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        if args == "ram":
            if chip()['name'] == 'HS6620':
                gdb.execute('set *0x400e003c |= 0x20')
                gdb.execute('set *0x400e003c  = (*0x400e003c & 0xFFFFFFF0) | 6')
                print("Remapped to RAM (HS6620)")
            else:
                gdb.execute('set *0x400e003c |= 0x20')
                gdb.execute('set *0x400e003c  = (*0x400e003c & 0xFFFFFFF0) | 2')
                print("Remapped to RAM (HS6621X)")
        elif args == "otp":
            if chip()['name'] == 'HS6620':
                print("Can't remap to OTP (HS6620)")
            else:
                gdb.execute('set *0x400e003c |= 0x20')
                gdb.execute('set *0x400e003c  = (*0x400e003c & 0xFFFFFFF0) | 8')
                print("Remapped to OTP (HS6621X)")
        else:
            if chip()['name'] == 'HS6620':
                gdb.execute('set *0x400e003c |= 0x20')
                gdb.execute('set *0x400e003c  = (*0x400e003c & 0xFFFFFFF0) | 5')
                print("Remapped to ROM (HS6620)")
            else:
                gdb.execute('set *0x400e003c |= 0x20')
                gdb.execute('set *0x400e003c  = (*0x400e003c & 0xFFFFFFF0) | 1')
                print("Remapped to ROM (HS6621X)")

# reboot
class reboot_register(gdb.Command):

    """HS662x reboot
    """

    def __init__(self):
        super(self.__class__, self).__init__("reboot", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        gdb.execute('mon reset')
        gdb.execute('remap rom')
        gdb.execute('mon reset 1')
        gdb.execute('c')


# info
class device_info_register(gdb.Command):

    """HS662x info
    """

    def __init__(self):
        super(self.__class__, self).__init__("device_info", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        flash_prepare_and_show()
        flash_finish()


# upload
class flash_upload_register(gdb.Command):

    """HS662x upload from flash
    Usage: flash_upload <flash_image.bin>
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_upload", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Prepare
        flash_prepare_and_show()

        # flash image data
        flash_image = [b'']

        # Get file name
        if args == '':
            flash_file = 'FLASH_{:06X}_{}KB_{}{}.bin'.format(flash_id, int(flash_size/1024), device_name, device_version)
        else:
            flash_file = args

        # get buf
        buf = int(gdb.parse_and_eval('FlashDevice.sectors').cast(gdb.lookup_type('int')))

        # Read
        def flash_read_handler(addr, length, param=(buf, flash_image)):
            gdb.execute('set $res=flash_read({}, {}, {})'.format(buf, addr, length))
            gdb.execute('dump memory /tmp/hs662x_upload.tmp {} {}'.format(buf, buf+length))
            flash_image[0] += open('/tmp/hs662x_upload.tmp', 'rb').read()
        loop_do_show_progress("  Upload...", flash_size, flash_read_handler, param=(buf,flash_image))

        open(flash_file, 'wb').write(flash_image[0])

        # Finish
        print("Finish: {}".format(flash_file))
        flash_finish()


# download
class flash_download_image_register(gdb.Command):

    """HS662x download ALL image to flash
    Usage: flash_download_image <flash_image.bin> <flash_addr>
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_download_image", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Prepare
        flash_prepare_and_show()

        # Get file name
        file_path = 'flash_image.bin'
        flash_addr = 0
        for opt in args.split():
            try:
                flash_addr = int(opt, 0)
            except:
                file_path = opt

        # Get file size
        file_real_size = os.path.getsize(file_path)
        flash_addr_end = min(flash_addr+file_real_size, (flash_size-flash_sector_size)) # last is CPFT data
        file_size = flash_addr_end - flash_addr

        # show burn application info
        print('{}: {}kB -> 0x{:X}'.format(file_path, int(file_size/1024), flash_addr))

        # get buffer
        buf = int(gdb.parse_and_eval('FlashDevice.sectors').cast(gdb.lookup_type('int')))

        # Erase
        def flash_erase_handler(addr, length, param=(flash_addr)):
            gdb.execute('set $res=flash_erase({}, {}, 0)'.format(flash_addr+addr, length))
        loop_do_show_progress("  Erase...", file_size, flash_erase_handler, param=(flash_addr))

        # Program
        def flash_program_handler(addr, length, param=(file_path, flash_addr, buf)):
            gdb.execute('restore {} binary {} {} {}'.format(file_path, buf-addr, addr, addr+length), to_string=True)
            gdb.execute('set $res=flash_write({}, {}, {})'.format(flash_addr+addr, buf, length))
        loop_do_show_progress("  Program...", file_size, flash_program_handler, param=(file_path,flash_addr,buf))

        # Finish
        print("Finish")
        flash_finish()


# erase
class flash_erase_register(gdb.Command):

    """HS662x flash erase
    flash_erase <begin_kB> <length_kB>
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_erase", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):

        # Prepare
        flash_prepare_and_show()

        # param
        argv = gdb.string_to_argv(args)
        if len(argv) == 0:
            begin = 0
            length = flash_size - flash_sector_size # last is CPFT data
        elif len(argv) == 2:
            begin = int(argv[0]) * 1024
            length = int(argv[1]) * 1024
        else:
            raise gdb.GdbError('Invalid params, "help flash_erase" for more infomation')

        # Info
        print("Erase begin={}kB length={}kB".format(int(begin/1024), int(length/1024)))

        # Erase
        def flash_erase_handler(addr, length, param=(begin)):
            gdb.execute('set $res=flash_erase({}, {}, 0)'.format(begin+addr, length))
        loop_do_show_progress("  Erase...", length, flash_erase_handler, param=(begin))

        # Finish
        print("Finish")
        flash_finish()


# download app
class flash_download_app_noverify_register(gdb.Command):

    """HS662x download APP to flash
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_download_app_noverify", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            file_path = 'a.bin'
        else:
            file_path = args

        # Download
        flash_download_part(FLASH_PART_APP, file_path, is_verify=False)

# download app
class flash_download_app_register(gdb.Command):

    """HS662x download APP to flash
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_download_app", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            file_path = 'a.bin'
        else:
            file_path = args

        # Download
        flash_download_part(FLASH_PART_APP, file_path)

# download cfg
class flash_download_cfg_register(gdb.Command):

    """HS662x download CFG to flash
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_download_cfg", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            file_path = 'cfg.bin'
        else:
            file_path = args

        # Download
        flash_download_part(FLASH_PART_CFG, file_path)


# download patch
class flash_download_patch_register(gdb.Command):

    """HS662x download PATCH to flash
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_download_patch", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Get file name
        if args == '':
            file_path = 'patch.bin'
        else:
            file_path = args

        # Download
        flash_download_part(FLASH_PART_PATCH, file_path)


# issue reappear
class issue_reappear_register(gdb.Command):

    """HS662x issue reappear with simulator
    issue_reappear [<ROM_DIR>] <USR_DIR>
    ROM_DIR: xxx.axf xxx.bin
    USR_DIR: xxx.axf xxx.log xxx.bin
    """

    def __init__(self):
        super(self.__class__, self).__init__("issue_reappear", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # param
        argv = gdb.string_to_argv(args)
        if len(argv) == 1:
            rom_dir = None
            usr_dir = argv[0]
        elif len(argv) == 2:
            rom_dir = argv[0]
            usr_dir = argv[1]
        else:
            raise gdb.GdbError('Invalid params, "help issue_reappear" for more infomation')

        rom_axf = None
        rom_bin = None
        usr_axf = None
        usr_ram_bin = None
        usr_em_bin = None
        usr_flash_bin = None
        usr_log = None

        # Search ROM files
        if rom_dir != None:
            for file in os.listdir(rom_dir):
                if file.endswith(".axf"):
                    rom_axf = os.path.join(rom_dir, file)
                elif file.endswith(".bin"):
                    rom_bin = os.path.join(rom_dir, file)
            if rom_axf == None or rom_bin == None:
                raise gdb.GdbError('Can not found ROM axf/bin file!')

        # Search USR files
        for file in os.listdir(usr_dir):
            if file.endswith(".axf"):
                usr_axf = os.path.join(usr_dir, file)
            elif file.endswith(".bin"):
                usr_ram_bin = os.path.join(usr_dir, file)
            elif file.endswith(".ebin"):
                usr_em_bin = os.path.join(usr_dir, file)
            elif file.endswith(".fbin"):
                usr_flash_bin = os.path.join(usr_dir, file)
            elif file.endswith(".log"):
                usr_log = os.path.join(usr_dir, file)
        if usr_ram_bin == None or usr_log == None:
            raise gdb.GdbError('Can not found USR bin/log file!')

        print("rom_axf: {}".format(rom_axf))
        print("rom_bin: {}".format(rom_bin))
        print("usr_axf: {}".format(usr_axf))
        print("usr_ram_bin: {}".format(usr_ram_bin))
        print("usr_em_bin: {}".format(usr_em_bin))
        print("usr_flash_bin: {}".format(usr_flash_bin))
        print("usr_log: {}".format(usr_log))

        # Start simulate
        gdb.execute('file', to_string=True)
        gdb.execute('file {}/sim_cm3.axf'.format(script_dir), to_string=True)
        gdb.execute('target sim', to_string=True)
        gdb.execute('load', to_string=True)
        print("\nPress 'Ctrl-C' to continue")
        gdb.execute('run', to_string=True)

        # Restore USR info
        if usr_axf != None:
            gdb.execute('file {}'.format(usr_axf), to_string=True)
        gdb.execute('restore {} binary 0'.format(usr_ram_bin), to_string=True) # Remaped address
        gdb.execute('restore {} binary 0x00200000'.format(usr_ram_bin), to_string=True) # Physical address
        gdb.execute('restore {} binary 0x20000000'.format(usr_ram_bin), to_string=True) # Physical address
        if usr_em_bin != None:
            gdb.execute('restore {} binary 0x41310000'.format(usr_em_bin), to_string=True)
        if usr_flash_bin != None:
            gdb.execute('restore {} binary 0x12000000'.format(usr_flash_bin), to_string=True) # HS6621
            gdb.execute('restore {} binary 0x00400000'.format(usr_flash_bin), to_string=True) # HS6621C

        # Restore ROM info
        if rom_axf != None:
            if usr_axf == None:
                gdb.execute('file {}'.format(rom_axf), to_string=True)
            else:
                gdb.execute('add-symbol-file {}'.format(rom_axf), to_string=True)
            gdb.execute('restore {} binary 0x08000000'.format(rom_bin), to_string=True) # HS6620/HS6621
            gdb.execute('restore {} binary 0x00100000'.format(rom_bin), to_string=True) # HS6621C

        # dump memery / register
        gdb.execute('restore_dump_mem {}'.format(usr_log), to_string=True)
        gdb.execute('restore_dump_reg {}'.format(usr_log), to_string=True)

        # Debug
        print("\nDump ARM Register")
        print(  "-----------------")
        gdb.execute('dump_reg_armcm')

        print("\nDump ARM Fault")
        print(  "--------------")
        gdb.execute('dump_fault_armcm')

        print("\nStack")
        print(  "-----")
        gdb.execute('x/40wx $sp')

        print("\nDisassemble")
        print(  "-----------")
        gdb.execute('x/16i $pc-16')

        print("\nRegister String")
        print(  "--------")
        for i in range(13):
            try:
                print('r{}\t{}'.format(i, gdb.parse_and_eval('(char *)$r{}'.format(i))))
            except:
                pass

        print("\nBacktrace")
        print(  "---------")
        gdb.execute('bt')


# register
disable_wdt_register()
remap_register()
reboot_register()
device_info_register()
flash_upload_register()
flash_download_app_register()
flash_download_app_noverify_register()
flash_download_cfg_register()
flash_download_patch_register()
flash_download_image_register()
flash_erase_register()
issue_reappear_register()

# @} #


