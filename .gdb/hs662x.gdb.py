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
    flash_id = int(gdb.parse_and_eval('sf_readId(0)'))
    if flash_id in flash_info_table:
        flash_size = flash_info_table[flash_id]['size']
        flash_name = flash_info_table[flash_id]['name']
    else:
        flash_size = 1 << (flash_id&0xff)
        flash_name = 'Unknown'
    print('Flash: {} {}KB (0x{:06X})'.format(flash_name, flash_size/1024, flash_id))


def mem32_read(addr):
    value = int(gdb.parse_and_eval('*{}'.format(addr)).cast(gdb.lookup_type('unsigned long')))
    return value


def mem32_write(addr, value):
    gdb.execute('set *{}={}'.format(addr, value))


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


# info
class device_info_register(gdb.Command):

    """HS662x info
    """

    def __init__(self):
        super(self.__class__, self).__init__("device_info", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        flash_prepare_and_show()


# upload
class upload_register(gdb.Command):

    """HS662x upload from flash
    """

    def __init__(self):
        super(self.__class__, self).__init__("upload", gdb.COMMAND_USER)

    def invoke(self, args, from_tty):
        flash_image = b''
        flash_file = './hs662x_upload_flash_image.bin'

        # Prepare
        flash_prepare_and_show()

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
        gdb.execute('file')


# download
class download_register(gdb.Command):

    """HS662x download to flash
    """

    def __init__(self):
        super(self.__class__, self).__init__("download", gdb.COMMAND_USER, gdb.COMPLETE_FILENAME)

    def invoke(self, args, from_tty):

        # Prepare
        flash_prepare_and_show()

        # Get file name
        if args == '':
            file_path = 'a.bin'
        else:
            file_path = args

        # Get file size
        file_size = os.path.getsize(file_path)

        # show burn application info
        print('{}: {}kB'.format(file_path, file_size/1024))

        # get buffer
        buffer = int(gdb.parse_and_eval('FlashDevice.sectors').cast(gdb.lookup_type('int')))

        # Erase
        print("  Erase...")
        gdb.execute('set $res=Init(0, 6000000, 1)')
        addr = 0
        while addr < file_size:
            gdb.execute('set $res=EraseSector({})'.format(addr))
            addr += flash_sector_size
        gdb.execute('set $res=UnInit(1)')

        # Program
        print("  Program...")
        gdb.execute('set $res=Init(0, 6000000, 2)')
        addr = 0
        while addr < file_size:
            left = file_size - addr
            len = left if left<flash_sector_size else flash_sector_size
            gdb.execute('restore {} binary {} {} {}'.format(file_path, buffer-addr, addr, addr+len), to_string=True)
            gdb.execute('set $res=ProgramPage({}, {}, {})'.format(addr, len, buffer))
            addr += flash_sector_size
        gdb.execute('set $res=UnInit(2)')

        # Verify
        print("  Verify...")
        gdb.execute('set $res=Init(0, 6000000, 3)')
        addr = 0
        while addr < file_size:
            left = file_size - addr
            len = left if left<flash_sector_size else flash_sector_size
            gdb.execute('restore {} binary {} {} {}'.format(file_path, buffer-addr, addr, addr+len), to_string=True)
            gdb.execute('set $res=Verify({}, {}, {})'.format(addr, len, buffer))
            res = int(gdb.parse_and_eval('$res').cast(gdb.lookup_type('int')))
            if res != addr + len:
                raise gdb.GdbError('!!! Fail !!!')
            addr += flash_sector_size
        gdb.execute('set $res=UnInit(3)')

        # Finish
        print("Finish")
        gdb.execute('file')


# register
remap2ram_register()
remap2rom_register()
device_info_register()
upload_register()
download_register()



# @} #


