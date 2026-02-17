
import sys
if sys.platform != 'win32':
    print("This script only runs on Windows")
    sys.exit(1)

import ctypes
from ctypes import wintypes
import win32api
# import win32con

# Quick & Dirty script to get the file attribute bitmasks values for Windows files.
# Also displays extra details when the filename is a Symbolic Link/Junction


# WIN_FILE_ATTRIBUTE_READONLY            = 0x0001
# WIN_FILE_ATTRIBUTE_HIDDEN              = 0x0002
# WIN_FILE_ATTRIBUTE_SYSTEM              = 0x0004
# WIN_FILE_ATTRIBUTE_LABEL               = 0x0008
# WIN_FILE_ATTRIBUTE_DIRECTORY           = 0x0010
# WIN_FILE_ATTRIBUTE_ARCHIVE             = 0x0020
# WIN_FILE_ATTRIBUTE_SYMBOLIC_LINK       = 0x0040 # Not DEVICE
# WIN_FILE_ATTRIBUTE_EXECUTABLE          = 0x0080 # Not NORMAL
# WIN_FILE_ATTRIBUTE_TEMPORARY           = 0x0100
# WIN_FILE_ATTRIBUTE_SPARSE_FILE         = 0x0200
# WIN_FILE_ATTRIBUTE_REPARSE_POINT       = 0x0400
# WIN_FILE_ATTRIBUTE_COMPRESSED          = 0x0800
# WIN_FILE_ATTRIBUTE_OFFLINE             = 0x1000
# WIN_FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x2000
# WIN_FILE_ATTRIBUTE_ENCRYPTED           = 0x4000


# from https://learn.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants
# attr_lookup = {
#     0x0001: 'WIN_FILE_ATTRIBUTE_READONLY',
#     0x0002: 'WIN_FILE_ATTRIBUTE_HIDDEN',
#     0x0004: 'WIN_FILE_ATTRIBUTE_SYSTEM',
#     0x0008: 'WIN_FILE_ATTRIBUTE_LABEL',
#     0x0010: 'WIN_FILE_ATTRIBUTE_DIRECTORY',
#     0x0020: 'WIN_FILE_ATTRIBUTE_ARCHIVE',
#     0x0040: 'WIN_FILE_ATTRIBUTE_DEVICEK',
#     0x0080: 'WIN_FILE_ATTRIBUTE_NORMAL',
#     0x0100: 'WIN_FILE_ATTRIBUTE_TEMPORARY',
#     0x0200: 'WIN_FILE_ATTRIBUTE_SPARSE_FILE',
#     0x0400: 'WIN_FILE_ATTRIBUTE_REPARSE_POINT',
#     0x0800: 'WIN_FILE_ATTRIBUTE_COMPRESSED',
#     0x1000: 'WIN_FILE_ATTRIBUTE_OFFLINE',
#     0x2000: 'WIN_FILE_ATTRIBUTE_NOT_CONTENT_INDEXED',
#     0x4000: 'WIN_FILE_ATTRIBUTE_ENCRYPTED',
#     0x8000: 'FILE_ATTRIBUTE_INTEGRITY_STREAM',
#
#     0x10000: 'FILE_ATTRIBUTE_VIRTUAL',
#
# }

# Windows constants
FILE_ATTRIBUTE_REPARSE_POINT = 0x400
IO_REPARSE_TAG_MOUNT_POINT = 0xA0000003
IO_REPARSE_TAG_SYMLINK = 0xA000000C
SYMLINK_FLAG_RELATIVE = 0x00000001

FSCTL_GET_REPARSE_POINT = 0x900A8
MAXIMUM_REPARSE_DATA_BUFFER_SIZE = 16384

# Windows API functions
kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)


def parse(filename):

    # Get details on Symbolic Link/Junction

    kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)

    # Windows constants
    # FILE_ATTRIBUTE_REPARSE_POINT = 0x400
    # IO_REPARSE_TAG_MOUNT_POINT = 0xA0000003
    # IO_REPARSE_TAG_SYMLINK = 0xA000000C
    # SYMLINK_FLAG_RELATIVE = 0x00000001

    # FSCTL_GET_REPARSE_POINT = 0x900A8
    # MAXIMUM_REPARSE_DATA_BUFFER_SIZE = 16384

    # Use FindFirstFile to get the reparse tag
    class WIN32_FIND_DATAW(ctypes.Structure):
        _fields_ = [
            ('dwFileAttributes', wintypes.DWORD),
            ('ftCreationTime', wintypes.FILETIME),
            ('ftLastAccessTime', wintypes.FILETIME),
            ('ftLastWriteTime', wintypes.FILETIME),
            ('nFileSizeHigh', wintypes.DWORD),
            ('nFileSizeLow', wintypes.DWORD),
            ('dwReserved0', wintypes.DWORD),  # Reparse tag
            ('dwReserved1', wintypes.DWORD),
            ('cFileName', wintypes.WCHAR * 260),
            ('cAlternateFileName', wintypes.WCHAR * 14),
        ]

    print()
    find_data = WIN32_FIND_DATAW()
    handle = kernel32.FindFirstFileW(filename, ctypes.byref(find_data))

    if handle == -1:  # INVALID_HANDLE_VALUE
        error = ctypes.get_last_error()
        print(f"  Error: Could not find file (Error: {error})")
        return None

    kernel32.FindClose(handle)

    reparse_tag = find_data.dwReserved0
    print(f"  Reparse Tag: 0x{reparse_tag:08X} ({reparse_tag})")

    if reparse_tag == IO_REPARSE_TAG_MOUNT_POINT:
        print("    Type: Junction Point (Mount Point)")
        return "junction"
    elif reparse_tag == IO_REPARSE_TAG_SYMLINK:
        print("    Type: Symbolic Link")
        if attrs & 0x10:  # FILE_ATTRIBUTE_DIRECTORY
            print("  Link Type: Directory symbolic link")
        else:
            print("    Link Type: File symbolic link")
        return "symlink"
    else:
        print(f"    Type: Other reparse point (tag: 0x{reparse_tag:08X})")
        return "other"


def get_reparse_target(path):
    """Get the target of a reparse point on Windows."""

    # print(f"\n  Getting target for: {path}")

    # Open the file with reparse point access
    GENERIC_READ = 0x80000000
    FILE_SHARE_READ = 0x1
    FILE_SHARE_WRITE = 0x2
    FILE_SHARE_DELETE = 0x4
    OPEN_EXISTING = 3
    FILE_FLAG_BACKUP_SEMANTICS = 0x02000000
    FILE_FLAG_OPEN_REPARSE_POINT = 0x00200000

    handle = kernel32.CreateFileW(
        path,
        0,  # No access needed
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        None,
        OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT,
        None
    )

    if handle == -1:  # INVALID_HANDLE_VALUE
        error = ctypes.get_last_error()
        print(f"  Error: Could not open file (Error: {error})")
        return None

    # Prepare buffer for reparse data
    buffer = ctypes.create_string_buffer(MAXIMUM_REPARSE_DATA_BUFFER_SIZE)
    bytes_returned = wintypes.DWORD()

    # Get reparse point data
    success = kernel32.DeviceIoControl(
        handle,
        FSCTL_GET_REPARSE_POINT,
        None,
        0,
        buffer,
        MAXIMUM_REPARSE_DATA_BUFFER_SIZE,
        ctypes.byref(bytes_returned),
        None
    )

    if not success:
        error = ctypes.get_last_error()
        print(f"  Error: Could not get reparse data (Error: {error})")
        kernel32.CloseHandle(handle)
        return None

    # Parse reparse tag
    reparse_tag = ctypes.c_ulong.from_buffer_copy(buffer, 0).value

    if reparse_tag == IO_REPARSE_TAG_SYMLINK:
        # Parse symlink structure
        offset = 8  # Skip ReparseTag and ReparseDataLength
        substitute_name_offset = ctypes.c_ushort.from_buffer_copy(buffer, offset).value
        substitute_name_length = ctypes.c_ushort.from_buffer_copy(buffer, offset + 2).value
        flags = ctypes.c_ulong.from_buffer_copy(buffer, offset + 8).value

        path_buffer_offset = offset + 12
        target_offset = path_buffer_offset + substitute_name_offset

        target = buffer[target_offset:target_offset + substitute_name_length].decode('utf-16-le', errors='ignore')

        # print("  Type: Symbolic Link")
        print(f"    Target Filename: '{target}'")
        print(f"    Flags: 0x{flags:08X} {'(Relative)' if flags & SYMLINK_FLAG_RELATIVE else '(Absolute)'}")

        kernel32.CloseHandle(handle)
        return target

    elif reparse_tag == IO_REPARSE_TAG_MOUNT_POINT:
        # Parse mount point structure
        offset = 8  # Skip ReparseTag and ReparseDataLength
        substitute_name_offset = ctypes.c_ushort.from_buffer_copy(buffer, offset).value
        substitute_name_length = ctypes.c_ushort.from_buffer_copy(buffer, offset + 2).value

        path_buffer_offset = offset + 8
        target_offset = path_buffer_offset + substitute_name_offset

        target = buffer[target_offset:target_offset + substitute_name_length].decode('utf-16-le', errors='ignore')

        # print("  Type: Junction Point")
        print(f"    Target Filename: '{target}'")

        kernel32.CloseHandle(handle)
        return target
    else:
        print(f"    Type: Other reparse point (tag: 0x{reparse_tag:08X})")
        kernel32.CloseHandle(handle)
        return None


# from https://learn.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants
attr_lookup = [
     'Read Only',
     'Hidden',
     'System',
     'Label',
     'Directory',
     'Archive',
     'Device',
     'Normal',
     'Temporary',
     'Sparse File',
     'Reparse Point',
     'Compressed',
     'Offline',
     'Not Content Indexed',
     'Encrypted',
     'Integrity Stream',
     'Virtual',
]

for filename in sys.argv[1:]:

    print(f"Filename: {filename}")
    # Get attributes
    attrs = win32api.GetFileAttributes(filename)

    print(f"  File Attributes: 0x{attrs:04x} ({attrs})")

    # for bit, name in attr_lookup.items():
    for bit, name in enumerate(attr_lookup, start=0):
        bitmask = 1 << bit

        if attrs & bitmask == bitmask:
            print(f"    [Bit {bit:2d}] 0x{bitmask:04x} ({bitmask:4d}): {name}")

    if attrs & 0x400: # Reparse Point
        parse(filename)
        get_reparse_target(filename)

    print()
