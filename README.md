# NAME

zipdetails - display the internal structure of zip files

# SYNOPSIS

    zipdetails [options] zipfile.zip

# DESCRIPTION

This program creates a detailed report on the internal structure of zip
files. For each item of metadata within a zip file the program will output

- the offset into the zip file where the item is located.
- a textual representation for the item.
- an optional hex dump of the item.

The program assumes a prior understanding of the internal structure of Zip
files. You should have a copy of the Zip
[APPNOTE.TXT](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT) file
at hand to help understand the output from this program.

## Default Behaviour

By default the program expects to be given a well-formed zip file.  It will
navigate the Zip file by first parsing the zip central directory at the end
of the file.  If the central directory is found, it will then walk
sequentally through the zip records starting at the beginning of the file.
Badly formed zip data structures encountered are likely to terminate the
program. if you do encounter an unexpected termination please report it
(see ["SUPPORT"](#support)).

If the program finds any structural problems with the zip file it will
print a summary at the end of the output report. The set of error cases
reported is a work in progress, so don't rely on this feature to
find all the possible errors in a zip file. If you have suggestions for
use-cases where this could be enhanced please consider creating an
enhancement request (see ["SUPPORT"](#support)).

Date/time fields found in zip files are displayed in local time. Use the
`--utc` option to display these fields in Coordinated Universal Time
(UTC).

## Analysis of corrupt or non-standard zip files

If you have a corrupt or non-standard zip file, particulatly one where the
central directory metadata at the end of the file is absent/incomplete, you
can use either the `--walk` option or the `--scan` option to search for
any zip metadata that is still present in the file.

When either of these options is enabled, this program will bypass the
initial step of reading the central directory at the end of the file and
simply scan the zip file sequentially from the start of the file looking
for zip metedata records. Although this can be error prone, for the most
part it will find any zip file metadata that is still present in the file.

The difference between the two options is how aggressive the sequential
scan is: `--walk` is optimistic, while `--scan` is pessimistic.

To understand the difference in more detail you need to know a bit about
how zip file metadata is structured. Under the hood, a zip file uses a
series of 4-byte signatures to flag the start of a each of the metadata
records it uses. When the `--walk` or the `--scan` option is enabled both
work identically by scanning the file from the beginning looking for any
the of these valid 4-byte metadata signatures. When a 4-byte signature is
found both options will blindly assume that it has found a vald metadata
record and display it.

In the case of the `--walk` option it optimistically assumes that it has
found a real zip metatada record and so starts the scan for the next record
directly after the record it has just output.

The `--scan` option is pessimistic and assumes the 4-byte signature
sequence may have been a false-positive, so before starting the scan for
the next resord, it will rewind to the location in the file directly after
the 4-byte sequecce it just processed. This means it will rescan data that
has already been processed. For very lage zip files the `--scan` option
can be really realy slow, so  trying the `--walk` option first.

If the zip file being processed contains one or more nested zip files, and the
outer zip file uses the `STORE` compression method, the `--scan` option will
display the zip metadata for both the outer & inner zip files.

## OPTIONS

### General Options

- -h, --help

    Display help

- --redact

    Obscure filenames and payload data in the output. Handy for the use case where
    the zip files contains sensitive data that cannot be shared.

- --scan

    Pessimistically scan the zip file loking for possible zip records. Can be
    error-prone. For very large zip files this option is very slow. Consider using
    the `--walk` option first.  See ["Analysis of corrupt or non-standard zip
    files"](#analysis-of-corrupt-or-non-standard-zip-files)

- --utc

    By default, date/time fields are displayed in local time. Use this option to
    display them in in Coordinated Universal Time (UTC).

- -v

    Enable Verbose mode. See ["Verbose Output"](#verbose-output).

- --version

    Display version number of the program and exit.

- --walk

    Optimistically walk the zip file looking for possible zip records.
    See ["Analysis of corrupt or non-standard zip files"](#analysis-of-corrupt-or-non-standard-zip-files)

### Filename/Comment Encoding

- --encoding, --no-encoding

    Enable/disable filename & comment encoding.

    When enabled, use system encoding by default (or `cp437` if the program cannot
    determine the system emcoding) when reading filenames/comments from a zip file
    and when displaying the filename/comment to the display. Override using the
    `--input-encoding name` and `--output-encoding name` options.

    When disabled, read/write filenames/comments as a byte stream.

    Default enabled.

- --input-encoding name

    Use encoding "name" when reading filename/comments from the zip file.
    Uses system encoding by default

- --output-encoding name

    Use encoding "name" when writing filename/comments to the display
    Uses system encoding by default.

- --language-encoding, --no-language-encoding

    This option enables/disables the

    Modern zip files set a metadata entry in zip files, called the "Language
    encoding flag", when they need to write filenames/comments in UTF-8.

    Occasionally some applications set the "Language encoding flag" but write
    non-UTF-8 data in the filename/comment fields in the zip file. This will
    usually result in garbled text being output for the filenames/comments.

    To deal with this use-case, set the `--no-language-encoding` option and, if
    needed, set the `--input-encoding name` option to encoding actually used.

    Default is `--language-encoding`.

- --debug-encoding

    Display eatra info when a filename/comment encoding has changed.

### Message Control Options

- --messages, --no-messages

    Enable/disable the output of all info/warning/error messages. Default is
    enabled.

- --info-messages, --no-info-messages

    Enable/disable the output of all info messages. Default is enabled.

- --warning-messages, --no-warning-messages

    Enable/disable the output of all warning messages. Default is enabled.

- --error-messages, --no-error-messages

    Enable/disable the output of all error messages. Default is enabled.

- --exit-bitmask, --no-exit-bitmask

    Enable/disable exit status bitmask for messages. Default disabled.
    Bitmask values are: 1 for info, 2 for warning and 4 for error.

## Default Output

By default `zipdetails` will output the details of the zip file in three columns.

1. The offset, in hex, to the start of the field relative to the beginning of the
file.
2. The name of the field.
3. Information about the contents of the field.

    If the field contains a numeric value it will be displayed in hex. Zip files
    store most numbers in _little-endian_ - the value displayed will have the
    _little-endian_ encoding removed.

    Next, is an optional description of what the value means.

For example, assuming you have a zip file, `test,zip`, with one entry

    $ unzip -l  test.zip
    Archive:  test.zip
    Length      Date    Time    Name
    ---------  ---------- -----   ----
        16133  2023-02-21 16:42   file1.txt
    ---------                     -------
        16133                     1 file

Running `zipdetails` will gives this output

    $ zipdetails test.zip

    0000 LOCAL HEADER #1       04034B50
    0004 Extract Zip Spec      14 '2.0'
    0005 Extract OS            00 'MS-DOS'
    0006 General Purpose Flag  0000
         [Bits 1-2]            0 'Normal Compression'
    0008 Compression Method    0008 'Deflated'
    000A Last Mod Time         56558540 'Tue Feb 21 16:42:00 2023'
    000E CRC                   6A7EF2E1
    0012 Compressed Length     000011E1
    0016 Uncompressed Length   00003F05
    001A Filename Length       0009
    001C Extra Length          0000
    001E Filename              'file1.txt'
    0027 PAYLOAD

    1208 CENTRAL HEADER #1     02014B50
    120C Created Zip Spec      1E '3.0'
    120D Created OS            03 'Unix'
    120E Extract Zip Spec      14 '2.0'
    120F Extract OS            00 'MS-DOS'
    1210 General Purpose Flag  0000
         [Bits 1-2]            0 'Normal Compression'
    1212 Compression Method    0008 'Deflated'
    1214 Last Mod Time         56558540 'Tue Feb 21 16:42:00 2023'
    1218 CRC                   6A7EF2E1
    121C Compressed Length     000011E1
    1220 Uncompressed Length   00003F05
    1224 Filename Length       0009
    1226 Extra Length          0000
    1228 Comment Length        0000
    122A Disk Start            0000
    122C Int File Attributes   0001
         [Bit 0]               1 Text Data
    122E Ext File Attributes   81A40000
    1232 Local Header Offset   00000000
    1236 Filename              'file1.txt'

    123F END CENTRAL HEADER    06054B50
    1243 Number of this disk   0000
    1245 Central Dir Disk no   0000
    1247 Entries in this disk  0001
    1249 Total Entries         0001
    124B Size of Central Dir   00000037
    124F Offset to Central Dir 00001208
    1253 Comment Length        0000
    #
    # Done

## Verbose Output

If the `-v` option is present, the data output is split into the following
columns:

1. The offset, in hex, to the start of the field relative to the beginning of the
file.
2. The offset, in hex, to the end of the field relative to the beginning of the
file.
3. The length, in hex, of the field.
4. A hex dump of the bytes in field in the order they are stored in the zip file.
5. A textual description of the field.
6. Information about the contents of the field.

    If the field contains a numeric value it will be displayed in hex. Zip files
    store most numbers in _little-endian_ - the value displayed will have the
    _little-endian_ encoding removed.

    Next, is an optional description of what the value means.

Here is the same zip file, `test.zip`, dumped using the `zipdetails` `-v` option:

    $ zipdetails -v test.zip

    0000 0003 0004 50 4B 03 04 LOCAL HEADER #1       04034B50
    0004 0004 0001 14          Extract Zip Spec      14 '2.0'
    0005 0005 0001 00          Extract OS            00 'MS-DOS'
    0006 0007 0002 00 00       General Purpose Flag  0000
                               [Bits 1-2]            0 'Normal Compression'
    0008 0009 0002 08 00       Compression Method    0008 'Deflated'
    000A 000D 0004 40 85 55 56 Last Mod Time         56558540 'Tue Feb 21 16:42:00 2023'
    000E 0011 0004 E1 F2 7E 6A CRC                   6A7EF2E1
    0012 0015 0004 E1 11 00 00 Compressed Length     000011E1
    0016 0019 0004 05 3F 00 00 Uncompressed Length   00003F05
    001A 001B 0002 09 00       Filename Length       0009
    001C 001D 0002 00 00       Extra Length          0000
    001E 0026 0009 66 69 6C 65 Filename              'file1.txt'
                   31 2E 74 78
                   74
    0027 1207 11E1 ...         PAYLOAD

    1208 120B 0004 50 4B 01 02 CENTRAL HEADER #1     02014B50
    120C 120C 0001 1E          Created Zip Spec      1E '3.0'
    120D 120D 0001 03          Created OS            03 'Unix'
    120E 120E 0001 14          Extract Zip Spec      14 '2.0'
    120F 120F 0001 00          Extract OS            00 'MS-DOS'
    1210 1211 0002 00 00       General Purpose Flag  0000
                               [Bits 1-2]            0 'Normal Compression'
    1212 1213 0002 08 00       Compression Method    0008 'Deflated'
    1214 1217 0004 40 85 55 56 Last Mod Time         56558540 'Tue Feb 21 16:42:00 2023'
    1218 121B 0004 E1 F2 7E 6A CRC                   6A7EF2E1
    121C 121F 0004 E1 11 00 00 Compressed Length     000011E1
    1220 1223 0004 05 3F 00 00 Uncompressed Length   00003F05
    1224 1225 0002 09 00       Filename Length       0009
    1226 1227 0002 00 00       Extra Length          0000
    1228 1229 0002 00 00       Comment Length        0000
    122A 122B 0002 00 00       Disk Start            0000
    122C 122D 0002 01 00       Int File Attributes   0001
                               [Bit 0]               1 Text Data
    122E 1231 0004 00 00 A4 81 Ext File Attributes   81A40000
    1232 1235 0004 00 00 00 00 Local Header Offset   00000000
    1236 123E 0009 66 69 6C 65 Filename              'file1.txt'
                   31 2E 74 78
                   74

    123F 1242 0004 50 4B 05 06 END CENTRAL HEADER    06054B50
    1243 1244 0002 00 00       Number of this disk   0000
    1245 1246 0002 00 00       Central Dir Disk no   0000
    1247 1248 0002 01 00       Entries in this disk  0001
    1249 124A 0002 01 00       Total Entries         0001
    124B 124E 0004 37 00 00 00 Size of Central Dir   00000037
    124F 1252 0004 08 12 00 00 Offset to Central Dir 00001208
    1253 1254 0002 00 00       Comment Length        0000
    #
    # Done

# LIMITATIONS

The following zip file features are not supported by this program:

- Multi-part/Split/Spanned Zip Archives.

    This program cannot give an overall report on the combined parts of a multi-part
    zip file.

    The best you can do is run with either the `--scan` or `--walk` options
    against individual parts. Some will contains zipfile metadata which will be
    detected and some will only contain compressed payload data.

- Encrypted Central Directory

    When pkzip _strong encryption_ is enabled in a zip file this program can still
    parse most of the metadata in the zip file. The exception is when the Central
    Directory of a zip file is also encrypted. This program cannot parse any
    metadata from an encrypted Central Directory.

- Corrupt Zip files

    When `zipdetails` encounters a corrupt zip file, it will do one or more of
    the following

    - Display details of the corruption and carry on
    - Display details of the corruption and terminate
    - Terminate with a generic message

    Which of the above is output is dependent in the severity of the corruption.

# TODO

## JSON Output

Output some of the zip file metadata as a JSON document.

## Corrupt Zip files

Although the detection and reporting of common corruption use-cases is present
in `zipdetails`, there are likely to be other edge cases that need to be
supported.

If you have a corrupt Zip file that isn't being processed properly,
please report it (see  ["SUPPORT"](#support)).

# SUPPORT

General feedback/questions/bug reports should be sent to
[https://github.com/pmqs/zipdetails/issues](https://github.com/pmqs/zipdetails/issues).

# SEE ALSO

The primary reference for Zip files is
[APPNOTE.TXT](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT).

An alternative reference is the Info-Zip appnote. This is available from
[ftp://ftp.info-zip.org/pub/infozip/doc/](ftp://ftp.info-zip.org/pub/infozip/doc/)

For details of WinZip AES encryption see [AES Encryption Information:
Encryption Specification AE-1 and AE-2](https://www.winzip.com/en/support/aes-encryption/).

The `zipinfo` program that comes with the info-zip distribution
([http://www.info-zip.org/](http://www.info-zip.org/)) can also display details of the structure of
a zip file.

# AUTHOR

Paul Marquess `pmqs@cpan.org`.

# COPYRIGHT

Copyright (c) 2011-2023 Paul Marquess. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
