create zip files as follows (assumes zip version 3.0)

## Methods

    zip  --compression-method deflate               iz-linux-standard-deflate.zip       lorem.txt
    zip  --compression-method store                 iz-linux-standard-store.zip         lorem.txt
    zip  --compression-method bzip2                 iz-linux-standard-bzip2.zip         lorem.txt
    zip  --compression-method deflate --force-zip64 iz-linux-standard-deflate-zip64.zip lorem.txt

## Stream from stdin

    zip --force-zip64- iz-linux-stdin-nozip64.zip -  <lorem.txt
    zip --force-zip64  iz-linux-stdin-zip64.zip   -  <lorem.txt

## Weak Encryption

    zip -e -P password  iz-linux-encrypt.zip   lorem.txt

## Stream to stdout

    zip --force-zip64- - lorem.txt| cat >iz-linux-stream-nozip64.zip

## InfoZip Bugs

### missing ZIP64 records

Using zip 3.0 (1 Aug 2022) the command below creates an invalid file file. It is missing the central directory ZIP64 records `zip64 end of central directory record` and `zip64 end of central directory locator`

    echo abcde | zip --force-zip64 | cat >iz-linux-stream-zip64.zip

Issue reported https://sourceforge.net/p/infozip/bugs/68/. See also https://sourceforge.net/p/infozip/bugs/61/

Needs the `--scan` option to view it with `zipdetails`.

### Weak Encryption enables streaming

Create an encrypted zip

    zip -e -P password /tmp/pwd.zip lorem.txt

Partial dump show streaming artefacts

    0000 LOCAL HEADER #1       04034B50
    0004 Extract Zip Spec      14 '2.0'
    0005 Extract OS            00 'MS-DOS'
    0006 General Purpose Flag  0009
         [Bit  0]              1 'Encryption'
         [Bits 1-2]            0 'Normal Compression'
         [Bit  3]              1 'Streamed'   <================
    0008 Compression Method    0008 'Deflated'
    000A Last Mod Time         52988571 'Sat Apr 24 17:43:34 2021'
    000E CRC                   F90EE7FF
    0012 Compressed Length     0000011A
    0016 Uncompressed Length   000001BE
    001A Filename Length       0009
    001C Extra Length          001C
    001E Filename              'lorem.txt'
    0027 Extra ID #0001        5455 'UT: Extended Timestamp'
    0029   Length              0009
    002B   Flags               '03 mod access'
    002C   Mod Time            60843CA6 'Sat Apr 24 16:43:34 2021'
    0030   Access Time         62E7CDA3 'Mon Aug  1 13:57:07 2022'
    0034 Extra ID #0002        7875 'ux: Unix Extra Type 3'
    0036   Length              000B
    0038   Version             01
    0039   UID Size            04
    003A   UID                 000003E8
    003E   GID Size            04
    003F   GID                 000003E8
    0043 PAYLOAD

    015D STREAMING DATA HEADER 08074B50     <==============
    0161 CRC                   F90EE7FF
    0165 Compressed Length     0000011A
    0169 Uncompressed Length   000001BE

https://sourceforge.net/p/infozip/bugs/69/

# TODO

* UTF8?
* self extractor
* symlinks
* zip64



