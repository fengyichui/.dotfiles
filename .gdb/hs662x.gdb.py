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
import gdb
import os

######################################################################
# VARIABLES
######################################################################
flash_size = 1024*512
flash_sector_size = 1024*4

flash_info_table = {
    0x504013: {'size': 512*1024,  'name': "XD25D40"},
    0x514013: {'size': 512*1024,  'name': "MD25D40"},
    0x514014: {'size': 1024*1024, 'name': "MD25D80"},
    0xC84015: {'size': 2048*1024, 'name': "GD25Q16B"},
    0xC84016: {'size': 4096*1024, 'name': "GD25Q32B"},
    0xEF4015: {'size': 2048*1024, 'name': "W25Q16B"},
    0xE04013: {'size': 512*1024,  'name': "BY25Q40A"},
    0xE04014: {'size': 1024*1024, 'name': "PN25F08"},
    0x5E4014: {'size': 1024*1024, 'name': "PN25F08B"},
    0x1C3113: {'size': 512*1024,  'name': "PN25F04C"},
    0x684013: {'size': 512*1024,  'name': "BY25D40"},
    0x856013: {'size': 512*1024,  'name': "P25R40H"},
    0x856014: {'size': 1024*1024, 'name': "P25R80H"},
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

######################################################################
# FUNCTIONS
######################################################################

def flash_prepare_and_show():
    # Init
    gdb.execute('mon reset 1', to_string=True)
    gdb.execute('mon halt', to_string=True)
    gdb.execute('file ~/.gdb/HS662X.GDB.FLM', to_string=True)
    gdb.execute('restore ~/.gdb/HS662X.GDB.FLM', to_string=True)
    gdb.execute('set $sp=&FlashDevice.sectors[1024]')
    gdb.execute('set $res=Init(0, 6000000, 3)')

    # Show device name
    device_info = int(gdb.parse_and_eval('*0x08000034').cast(gdb.lookup_type('int')))
    device_name = 'HS{:04X}'.format(device_info>>16)
    device_version = (device_info>>8) & 0xFF
    print('Device: {} A{}'.format(device_name, device_version))

    # Flash ID
    global flash_size
    # Ext
    flash_id_ext = int(gdb.parse_and_eval('sf_readId(1)'))
    if flash_id_ext in flash_info_table:
        flash_size_ext = flash_info_table[flash_id_ext]['size']
        flash_name_ext = flash_info_table[flash_id_ext]['name']
    elif flash_id_ext==0x0 or flash_id_ext==0xFFFFFF:
        flash_size_ext = 0
        flash_name_ext = 'None'
    else:
        flash_size_ext = 1 << (flash_id_ext&0xff)
        flash_size_ext = 'Unknown'
    # Inside
    flash_id = int(gdb.parse_and_eval('sf_readId(0)'))
    if flash_id in flash_info_table:
        flash_size = flash_info_table[flash_id]['size']
        flash_name = flash_info_table[flash_id]['name']
    elif flash_id==0x0 or flash_id==0xFFFFFF:
        flash_size = 0
        flash_name = 'None'
    else:
        flash_size = 1 << (flash_id&0xff)
        flash_name = 'Unknown'
    print('Flash: {} {}KB (0x{:06X})'.format(flash_name, flash_size/1024, flash_id))
    print('FlashExt: {} {}KB (0x{:06X})'.format(flash_name_ext, flash_size_ext/1024, flash_id_ext))


def flash_finish():
    gdb.execute('file', to_string=True)


def mem32_read(addr):
    value = int(gdb.parse_and_eval('*{}'.format(addr)).cast(gdb.lookup_type('unsigned long')))
    return value


def mem32_write(addr, value):
    gdb.execute('set *{}={}'.format(addr, value))


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
    buffer = int(gdb.parse_and_eval('FlashDevice.sectors').cast(gdb.lookup_type('int')))

    # Erase
    print("  Erase...")
    gdb.execute('set $res=Init(0, 6000000, 1)')
    gdb.execute('set $res=ImageInfoReset({})'.format(flash_base_addr))
    addr = 0
    while addr < erase_size:
        gdb.execute('set $res=EraseSector({})'.format(addr))
        addr += flash_sector_size
    gdb.execute('set $res=UnInit(1)')

    # Program
    print("  Program...")
    gdb.execute('set $res=Init(0, 6000000, {})'.format(int(part_type)))
    gdb.execute('set $res=ImageInfoReset({})'.format(flash_base_addr))
    addr = 0
    while addr < file_size:
        left = file_size - addr
        len = left if left<flash_sector_size else flash_sector_size
        gdb.execute('restore {} binary {} {} {}'.format(file_path, buffer-addr, addr, addr+len), to_string=True)
        gdb.execute('set $res=ProgramPage({}, {}, {})'.format(addr, len, buffer))
        addr += flash_sector_size
    gdb.execute('set $res=UnInit({})'.format(int(part_type)))

    # Verify
    if is_verify:
        print("  Verify...")
        gdb.execute('set $res=Init(0, 6000000, 3)')
        gdb.execute('set $res=ImageInfoReset({})'.format(flash_base_addr))
        addr = 0
        while addr < file_size:
            left = file_size - addr
            len = left if left<flash_sector_size else flash_sector_size
            gdb.execute('restore {} binary {} {} {}'.format(file_path, buffer-addr, addr, addr+len), to_string=True)
            gdb.execute('set $res=Verify({}, {}, {})'.format(addr, len, buffer))
            res = int(gdb.parse_and_eval('$res').cast(gdb.lookup_type('int')))
            if res != addr + len:
                raise gdb.GdbError('  Verify FAIL: 0x{:08X}!=0x{:08X}'.format(res, addr+len))
            addr += flash_sector_size
        gdb.execute('set $res=UnInit(3)')

    # Finish
    print("Finish")
    flash_finish()


######################################################################
# CLASS
######################################################################

# remap to RAM
class remap2ram_register(gdb.Command):

    """HS662x remap to RAM
    """

    def __init__(self):
        super(self.__class__, self).__init__("remap2ram", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        gdb.execute('set *0x400e003c=0x336')
        gdb.execute('set *0x400e003c=0x336')


# remap to ROM
class remap2rom_register(gdb.Command):

    """HS662x remap to ROM
    """

    def __init__(self):
        super(self.__class__, self).__init__("remap2rom", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        gdb.execute('set *0x400e003c=0x335')
        gdb.execute('set *0x400e003c=0x335')


# reboot
class reboot_register(gdb.Command):

    """HS662x reboot
    """

    def __init__(self):
        super(self.__class__, self).__init__("reboot", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        gdb.execute('mon reset')
        gdb.execute('remap2rom')
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
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_upload", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Prepare
        flash_prepare_and_show()

        # flash image data
        flash_image = b''

        # Get file name
        if args == '':
            flash_file = 'flash_image.bin'
        else:
            flash_file = args

        # Read flash data
        print("  uploading... [{}]".format(flash_file))
        read_buffer = int(gdb.parse_and_eval('m_buffer').cast(gdb.lookup_type('int')))
        addr = 0
        while addr < flash_size:
            gdb.execute('set $res=flash_read(m_buffer, {}, {})'.format(addr, flash_sector_size))
            gdb.execute('dump memory /tmp/hs662x_upload.tmp {} {}'.format(read_buffer, read_buffer+flash_sector_size))
            addr += flash_sector_size
            flash_image += open('/tmp/hs662x_upload.tmp', 'rb').read()

        open(flash_file, 'wb').write(flash_image)

        # Finish
        print("Finish")
        flash_finish()


# download
class flash_download_image_register(gdb.Command):

    """HS662x download ALL image to flash
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
        print('{}: {}kB -> 0x{:X}'.format(file_path, file_size/1024, flash_addr))

        # get buffer
        buffer = int(gdb.parse_and_eval('FlashDevice.sectors').cast(gdb.lookup_type('int')))

        # Erase
        print("  Erase...")
        gdb.execute('set $res=flash_erase({}, {}, 0)'.format(flash_addr, file_size)) # last is CPFT data

        # Program
        print("  Program...")
        i = 0
        while flash_addr < flash_addr_end:
            left = file_size - i
            len = left if left<flash_sector_size else flash_sector_size
            gdb.execute('restore {} binary {} {} {}'.format(file_path, buffer-i, i, i+len), to_string=True)
            gdb.execute('set $res=flash_write({}, {}, {})'.format(flash_addr, buffer, len))
            i += flash_sector_size
            flash_addr += flash_sector_size

        # Finish
        print("Finish")
        flash_finish()


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


# erase
class flash_erase_register(gdb.Command):

    """HS662x flash erase
    flash_erase <begin_kB> <length_kB>
    """

    def __init__(self):
        super(self.__class__, self).__init__("flash_erase", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):

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

        # Prepare
        flash_prepare_and_show()

        # Info
        print("Erase begin={}kB length={}kB".format(begin/1024, length/1024))

        # Erase
        print("  Erase...")
        gdb.execute('set $res=flash_erase({}, {}, 0)'.format(begin, length))

        # Finish
        print("Finish")
        flash_finish()


# register
remap2ram_register()
remap2rom_register()
reboot_register()
device_info_register()
flash_upload_register()
flash_download_app_register()
flash_download_cfg_register()
flash_download_patch_register()
flash_download_image_register()
flash_erase_register()


# @} #


