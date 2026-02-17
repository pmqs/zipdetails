This directory contains a few random scripts

##  dostime

A Perl script to decode the raw Windows/Dos datetime value stored in a zip file and outputs
1. the equivalent elapsed time since Unix epoch
2. A human-readable datetime

Input to the scrip is a dos datetome number

```
$ perl dostime 1383569469
Unix Elapsed   : 1616526118
Unix Printable : Tue Mar 23 19:01:58 2021
```

## winstat.py

Quick & Dirty python script to get the file attribute bitmasks values for Windows files.
Also displays extra details when the filename is a Symbolic Link/Junction.

```
> python  winstat.py slink
Filename: slink
  File Attributes: 0x0420 (1056)
    [Bit  5] 0x0020 (  32): Archive
    [Bit 10] 0x0400 (1024): Reparse Point

  Reparse Tag: 0xA000000C (2684354572)
    Type: Symbolic Link
    Link Type: File symbolic link
    Target Filename: 'target'
    Flags: 0x00000001 (Relative)
```
