# Open VMS Notes

See infozip `vms` directory for sample code

Infer the 11 fields used in the zip file from this data structure in from `vms_pk.c`

    static PK_info_t PK_def_info =
    {
            ATR$C_RECATTR,  ATR$S_RECATTR,  {0},
            ATR$C_UCHAR,    ATR$S_UCHAR,    {0},
            ATR$C_CREDATE,  ATR$S_CREDATE,  {0},
            ATR$C_REVDATE,  ATR$S_REVDATE,  {0},
            ATR$C_EXPDATE,  ATR$S_EXPDATE,  {0},
            ATR$C_BAKDATE,  ATR$S_BAKDATE,  {0},
            ATR$C_ASCDATES, sizeof(ush),    0,
            ATR$C_UIC,      ATR$S_UIC,      {0},
            ATR$C_FPRO,     ATR$S_FPRO,     {0},
            ATR$C_RPRO,     ATR$S_RPRO,     {0},
            ATR$C_JOURNAL,  ATR$S_JOURNAL,  {0}
    };

Plus seeing 12th field `ATR$C_ADDACLENT` in some files.

Details below sourced from `atrdef.h` and VMS documentation.

| Index | Field Name        | ID      | Notes |
| ------|-------------------|---------|-------|
| 1     | ATR$C_RECATTR     |  4 0x04 | Record attribute area. “ACP-QIO Record Attributes Area” on page 45 describes the record attribute area in detail. |
| 2     | ATR$C_UCHAR       |  3 0x03 | 4-byte file characteristics. (The file characteristics bits are listed following this table.) |
| 3     | ATR$C_CREDATE     | 17 0x11 | 64-bit creation date and time.|
| 4     | ATR$C_REVDATE     | 18 0x12 | 64-bit revision date and time. |
| 5     | ATR$C_EXPDATE     | 19 0x13 | 64-bit expiration date and time. |
| 6     | ATR$C_BAKDATE     | 20 0x14 | 64-bit backup date and time |
| 7     | ATR$C_ASCDATES    | 13 0x0D | Revision count (2 binary bytes), revision date, creation date, and expiration date, in ASCII. Format: DDMMMYY (revision date), HHMMSS (time), DDMMMYY (creation date), HHMMSS (time), DDMMMYY (expiration date). (The format contains noembedded spaces or commas.) ||
| 8     | ATR$C_UIC         | 21 0x15 | 4-byte file owner UIC |
| 9     | ATR$C_FPRO        | 22 0x16 | File protection. |
| 10    | ATR$C_RPRO        | 23 0x17 | 2-byte record protection |
| 11    | ATR$C_JOURNAL     | 29 0x1D | Journal control flags. |
| 12    | ATR$C_ADDACLENT   | 31 0x1F | add an access control entry |

## ATR$C_ASCDATES

Although  the definition of `ATR$C_ASCDATES` above suggests the presence of various ASCII dates, the data structuire used in
`vms_pk.c` and `vms.h` is only two bytes -- assuming this is just the file revision count.

## UCHAR

File Characteristics Bits

| IN                | Bit| Notes |
|-------------------|----|-------|
|FCH$M_NOBACKUP     |  1 | Do not back up file.
|FCH$M_READCHECK    |  2 | Verify all read operations.
|FCH$M_WRITCHECK    |  3 | Verify all write operations.
|FCH$M_CONTIGB      |  5 | Keep file as contiguous as possible.
|FCH$M_LOCKED       |  6 | File is deaccess-locked.
|FCH$M_CONTIG       |  7 | File is contiguous.
|FCH$M_BADACL       | 11 | File's ACL is corrupt.
|FCH$M_SPOOL        | 12 | File is an intermediate spool file.
|FCH$M_DIRECTORY    | 13 | File is a directory.
|FCH$M_BADBLOCK     | 14 | File contains bad blocks.
|FCH$M_MARKDEL      | 15 | File is marked for deletion.
|FCH$M_ERASE        | 17 | Erase file contents before deletion.
|FCH$M_ASSOCIATED1  | ?? | File has an associated file.
|FCH$M_EXISTENCE1   |    | Suppress existence of file.
|FCH$M_NOMOVE       | 21 | Disable movefile operations on this file.
|FCH$M_NOSHELVABLE  | 22 | File is not shelvable.
|FCH$M_SHELVED      | 19 |File is shelved.


## VMS Date Time

Below from http://odl.sysworks.biz/disk$vaxdocdec022/opsys/vmsos73/vmsos73/5841/5841pro_072.html

    27.1 System Time Format
    The operating system maintains the current date and time in 64-bit format. The time value is a binary number in 100-nanosecond (ns) units offset from the system base date and time, which is 00:00 o'clock, November 17, 1858 (the Smithsonian base date and time for the astronomic calendar). Time values must be passed to or returned from system services as the address of a quadword containing the time in 64-bit format. A time value can be expressed as either of the following:

    An absolute time that is a specific date or time of day, or both. Absolute times are always positive values (or 0).
    A delta time that is an offset from the current time to a time or date in the future. Delta times are always expressed as negative values.


Offset from VMS epoch (1 November 1858) to Unix epoch (1 Jan 1970) is 3506716800 (0x007C95674C3DA5C0).

    unixtime = int( ( vmstime - 0x007C95674C3DA5C0 ) / 10000000)
    nanoseconds = ( ( vmstime - 0x007C95674C3DA5C0 ) % 10000000 ) * 100

## File protection (ATR$C_FPRO)

`ATR$C_FPRO` is arranged as four 4-bit fields for System, Owner, Group & World.

# References

## Sample OpenVMS zip files
https://ftp.zx.net.nz/pub/archive/ftp.hp.com/pub/openvms/opensource/

The file `FW80_ZIP.ZIP`, used in the test harness, came from here.

## VMS man pages
http://sdpha2.ucsd.edu/Lab_Equip_Manuals/vms_io_users_manual.pdf
contains definitions of the attributes

## VMS to Unix time
https://groups.google.com/g/comp.os.vms/c/0bCcHTumgl8
https://groups.google.com/g/comp.os.vms/c/3ETrUGpCFmo
https://metacpan.org/pod/VMS::Time

## VMS include files

http://mail.digiater.nl/openvms/decus/vmslt97b/gnusoftware/gccaxp/7_1/vms/
