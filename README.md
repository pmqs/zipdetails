# NAME

zipdetails - display the internal structure of zip files

# SYNOPSIS

    zipdetails [-v][--scan][--redact][--utc] zipfile.zip
    zipdetails -h
    zipdetails --version

# DESCRIPTION

`zipdetails` displays information about the internal record structure of zip
files. It is not concerned with displaying any details of the compressed
data stored in the zip file.

The program assumes prior understanding of the internal structure of a Zip
file. You should have a copy of the Zip [APPNOTE.TXT](http://www.pkware.com/documents/casestudies/APPNOTE.TXT)
file at hand to help understand the output from this program.

## Default Behaviour

By default the program expects to be given a well-formed zip file.  It will
navigate the Zip file by first parsing the zip central directory at the end
of the file.  If that is found, it will then walk through the zip records
starting at the beginning of the file. Any badly formed zip data structures
encountered are likely to terminate the program.

If the program finds any structural problems with the zip file it will
print a summary at the end of the output report. The set of error cases
reported is very much a work in progress, so don't rely on this feature to
find all the possible errors in a zip file. If you have suggestions for
use-cases where this could be enhanced please consider creating an
enhancement request (see ["SUPPORT"](#support)).

Date/time fields are found in zip files are displayed in local time. Use
the `--utc` option to display these fields in Coordinated Universal Time
(UTC).

## Scan-Mode

If you do have a potentially corrupt zip file, particulatly where the
central directory at the end of the file is absent/incomplete, you can try
usng the `--scan` option to search for zip records that are still present.

When Scan-mode is enabled, the program will walk the zip file from the
start blindly looking for the 4-byte signatures that preceed each of the
zip data structures. If it finds any of the recognised signatures it will
attempt to dump the associated zip record. For very large zip files, this
operation can take a long time to run.

Note that the 4-byte signatures used in zip files can sometimes match with
random data stored in the zip file, so care is needed interpreting the
results.

## OPTIONS

- -h

    Display help

- --redact

    Obscure filenames in the output. Handy for the use case where the zip files
    contains sensitive data that cannot be shared.

- --scan

    Walk the zip file loking for possible zip records. Can be error-prone.
    See ["Scan-Mode"](#scan-mode)

- --utc

    By default, date/time fields are displayed in local time. Use this option
    to display them in in Coordinated Universal Time (UTC).

- -v

    Enable Verbose mode. See ["Verbose Output"](#verbose-output).

- --version

    Display version number of the program and exit.

## Default Output

By default zipdetails will output the details of the zip file in three
columns.

- Column 1

    This contains the offset from the start of the file in hex.

- Column 2

    This contains a textual description of the field.

- Column 3

    If the field contains a numeric value it will be displayed in hex. Zip
    stores most numbers in little-endian format - the value displayed will have
    the little-endian encoding removed.

    Next, is an optional description of what the value means.

For example, assuming you have a zip file with two entries, like this

    $ unzip -l test.zip
    Archive:  setup/test.zip
    Length      Date    Time    Name
    ---------  ---------- -----   ----
            6  2021-03-23 18:52   latters.txt
            6  2021-03-23 18:52   numbers.txt
    ---------                     -------
        12                     2 files

Running `zipdetails` will gives this output

    $ zipdetails test.zip

    0000 LOCAL HEADER #1       04034B50
    0004 Extract Zip Spec      0A '1.0'
    0005 Extract OS            00 'MS-DOS'
    0006 General Purpose Flag  0000
    0008 Compression Method    0000 'Stored'
    000A Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    000E CRC                   0F8A149C
    0012 Compressed Length     00000006
    0016 Uncompressed Length   00000006
    001A Filename Length       000B
    001C Extra Length          0000
    001E Filename              'letters.txt'
    0029 PAYLOAD               abcde.

    002F LOCAL HEADER #2       04034B50
    0033 Extract Zip Spec      0A '1.0'
    0034 Extract OS            00 'MS-DOS'
    0035 General Purpose Flag  0000
    0037 Compression Method    0000 'Stored'
    0039 Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    003D CRC                   261DAFE6
    0041 Compressed Length     00000006
    0045 Uncompressed Length   00000006
    0049 Filename Length       000B
    004B Extra Length          0000
    004D Filename              'numbers.txt'
    0058 PAYLOAD               12345.

    005E CENTRAL HEADER #1     02014B50
    0062 Created Zip Spec      1E '3.0'
    0063 Created OS            03 'Unix'
    0064 Extract Zip Spec      0A '1.0'
    0065 Extract OS            00 'MS-DOS'
    0066 General Purpose Flag  0000
    0068 Compression Method    0000 'Stored'
    006A Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    006E CRC                   0F8A149C
    0072 Compressed Length     00000006
    0076 Uncompressed Length   00000006
    007A Filename Length       000B
    007C Extra Length          0000
    007E Comment Length        0000
    0080 Disk Start            0000
    0082 Int File Attributes   0001
         [Bit 0]               1 Text Data
    0084 Ext File Attributes   81B40000
    0088 Local Header Offset   00000000
    008C Filename              'letters.txt'

    0097 CENTRAL HEADER #2     02014B50
    009B Created Zip Spec      1E '3.0'
    009C Created OS            03 'Unix'
    009D Extract Zip Spec      0A '1.0'
    009E Extract OS            00 'MS-DOS'
    009F General Purpose Flag  0000
    00A1 Compression Method    0000 'Stored'
    00A3 Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    00A7 CRC                   261DAFE6
    00AB Compressed Length     00000006
    00AF Uncompressed Length   00000006
    00B3 Filename Length       000B
    00B5 Extra Length          0000
    00B7 Comment Length        0000
    00B9 Disk Start            0000
    00BB Int File Attributes   0001
         [Bit 0]               1 Text Data
    00BD Ext File Attributes   81B40000
    00C1 Local Header Offset   0000002F
    00C5 Filename              'numbers.txt'

    00D0 END CENTRAL HEADER    06054B50
    00D4 Number of this disk   0000
    00D6 Central Dir Disk no   0000
    00D8 Entries in this disk  0002
    00DA Total Entries         0002
    00DC Size of Central Dir   00000072
    00E0 Offset to Central Dir 0000005E
    00E4 Comment Length        0000
    Done

## Verbose Output

If the `-v` option is present, column 1 is expanded to include

- The offset from the start of the file in hex.
- The length of the field in hex.
- A hex dump of the bytes in field in the order they are stored in the zip
file.

Here is the same zip file dumped using the `zipdetails` <-v> option:

    $ zipdetails -v  test.zip

    0000 0004 50 4B 03 04 LOCAL HEADER #1       04034B50
    0004 0001 0A          Extract Zip Spec      0A '1.0'
    0005 0001 00          Extract OS            00 'MS-DOS'
    0006 0002 00 00       General Purpose Flag  0000
    0008 0002 00 00       Compression Method    0000 'Stored'
    000A 0004 3D 98 77 52 Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    000E 0004 9C 14 8A 0F CRC                   0F8A149C
    0012 0004 06 00 00 00 Compressed Length     00000006
    0016 0004 06 00 00 00 Uncompressed Length   00000006
    001A 0002 0B 00       Filename Length       000B
    001C 0002 00 00       Extra Length          0000
    001E 000B 6C 65 74 74 Filename              'letters.txt'
              65 72 73 2E
              74 78 74
    0029 0006 61 62 63 64 PAYLOAD               abcde.
              65 0A

    002F 0004 50 4B 03 04 LOCAL HEADER #2       04034B50
    0033 0001 0A          Extract Zip Spec      0A '1.0'
    0034 0001 00          Extract OS            00 'MS-DOS'
    0035 0002 00 00       General Purpose Flag  0000
    0037 0002 00 00       Compression Method    0000 'Stored'
    0039 0004 3D 98 77 52 Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    003D 0004 E6 AF 1D 26 CRC                   261DAFE6
    0041 0004 06 00 00 00 Compressed Length     00000006
    0045 0004 06 00 00 00 Uncompressed Length   00000006
    0049 0002 0B 00       Filename Length       000B
    004B 0002 00 00       Extra Length          0000
    004D 000B 6E 75 6D 62 Filename              'numbers.txt'
              65 72 73 2E
              74 78 74
    0058 0006 31 32 33 34 PAYLOAD               12345.
              35 0A

    005E 0004 50 4B 01 02 CENTRAL HEADER #1     02014B50
    0062 0001 1E          Created Zip Spec      1E '3.0'
    0063 0001 03          Created OS            03 'Unix'
    0064 0001 0A          Extract Zip Spec      0A '1.0'
    0065 0001 00          Extract OS            00 'MS-DOS'
    0066 0002 00 00       General Purpose Flag  0000
    0068 0002 00 00       Compression Method    0000 'Stored'
    006A 0004 3D 98 77 52 Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    006E 0004 9C 14 8A 0F CRC                   0F8A149C
    0072 0004 06 00 00 00 Compressed Length     00000006
    0076 0004 06 00 00 00 Uncompressed Length   00000006
    007A 0002 0B 00       Filename Length       000B
    007C 0002 00 00       Extra Length          0000
    007E 0002 00 00       Comment Length        0000
    0080 0002 00 00       Disk Start            0000
    0082 0002 01 00       Int File Attributes   0001
                          [Bit 0]               1 Text Data
    0084 0004 00 00 B4 81 Ext File Attributes   81B40000
    0088 0004 00 00 00 00 Local Header Offset   00000000
    008C 000B 6C 65 74 74 Filename              'letters.txt'
              65 72 73 2E
              74 78 74

    0097 0004 50 4B 01 02 CENTRAL HEADER #2     02014B50
    009B 0001 1E          Created Zip Spec      1E '3.0'
    009C 0001 03          Created OS            03 'Unix'
    009D 0001 0A          Extract Zip Spec      0A '1.0'
    009E 0001 00          Extract OS            00 'MS-DOS'
    009F 0002 00 00       General Purpose Flag  0000
    00A1 0002 00 00       Compression Method    0000 'Stored'
    00A3 0004 3D 98 77 52 Last Mod Time         5277983D 'Tue Mar 23 19:01:58 2021'
    00A7 0004 E6 AF 1D 26 CRC                   261DAFE6
    00AB 0004 06 00 00 00 Compressed Length     00000006
    00AF 0004 06 00 00 00 Uncompressed Length   00000006
    00B3 0002 0B 00       Filename Length       000B
    00B5 0002 00 00       Extra Length          0000
    00B7 0002 00 00       Comment Length        0000
    00B9 0002 00 00       Disk Start            0000
    00BB 0002 01 00       Int File Attributes   0001
                          [Bit 0]               1 Text Data
    00BD 0004 00 00 B4 81 Ext File Attributes   81B40000
    00C1 0004 2F 00 00 00 Local Header Offset   0000002F
    00C5 000B 6E 75 6D 62 Filename              'numbers.txt'
              65 72 73 2E
              74 78 74

    00D0 0004 50 4B 05 06 END CENTRAL HEADER    06054B50
    00D4 0002 00 00       Number of this disk   0000
    00D6 0002 00 00       Central Dir Disk no   0000
    00D8 0002 02 00       Entries in this disk  0002
    00DA 0002 02 00       Total Entries         0002
    00DC 0004 72 00 00 00 Size of Central Dir   00000072
    00E0 0004 5E 00 00 00 Offset to Central Dir 0000005E
    00E4 0002 00 00       Comment Length        0000
    Done

# LIMITATIONS

The following zip file features are not supported by this program:

- Multi-part archives.
- The strong encryption features defined in the [APPNOTE.TXT](http://www.pkware.com/documents/casestudies/APPNOTE.TXT) document.

# TODO

Error handling is a work in progress. If the program encounters a problem
reading a zip file it is likely to terminate with an unhelpful error
message.

# SUPPORT

General feedback/questions/bug reports should be sent to
[https://github.com/pmqs/zipdetails/issues](https://github.com/pmqs/zipdetails/issues).

# SEE ALSO

The primary reference for Zip files is
[APPNOTE.TXT](http://www.pkware.com/documents/casestudies/APPNOTE.TXT).

An alternative reference is the Info-Zip appnote. This is available from
[ftp://ftp.info-zip.org/pub/infozip/doc/](ftp://ftp.info-zip.org/pub/infozip/doc/)

The `zipinfo` program that comes with the info-zip distribution
([http://www.info-zip.org/](http://www.info-zip.org/)) can also display details of the structure of
a zip file.

# AUTHOR

Paul Marquess `pmqs@cpan.org`.

# COPYRIGHT

Copyright (c) 2011-2021 Paul Marquess. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
