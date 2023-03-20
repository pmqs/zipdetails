
`test.zip` is based on `TestArchive.zip` sourced from https://dmkl.s3.eu-west-1.amazonaws.com/zip/TestArchive.zip via https://github.com/ananthakumaran/zstream/issues/18

Key point with this archive is the use of a Zip64 local header offset

```
0149 014C 0004 50 4B 01 02 CENTRAL HEADER #1     02014B50
014D 014D 0001 1E          Created Zip Spec      1E '3.0'
014E 014E 0001 03          Created OS            03 'Unix'
014F 014F 0001 2D          Extract Zip Spec      2D '4.5'
0150 0150 0001 00          Extract OS            00 'MS-DOS'
0151 0152 0002 00 00       General Purpose Flag  0000
                           [Bits 1-2]            0 'Normal Compression'
0153 0154 0002 08 00       Compression Method    0008 'Deflated'
0155 0158 0004 40 8B 81 55 Last Mod Time         55818B40 'Thu Dec  1 17:26:00 2022'
0159 015C 0004 FF E7 0E F9 CRC                   F90EE7FF
015D 0160 0004 0E 01 00 00 Compressed Length     0000010E
0161 0164 0004 BE 01 00 00 Uncompressed Length   000001BE
0165 0166 0002 09 00       Filename Length       0009
0167 0168 0002 0C 00       Extra Length          000C
0169 016A 0002 00 00       Comment Length        0000
016B 016C 0002 00 00       Disk Start            0000
016D 016E 0002 01 00       Int File Attributes   0001
                           [Bit 0]               1 'Text Data'
016F 0172 0004 00 00 ED 81 Ext File Attributes   81ED0000
                           [Bits 16-24]          01ED 'Unix attrib: rwxr-xr-x'
                           [Bits 28-31]          08 'Regular File'
0173 0176 0004 FF FF FF FF Local Header Offset   FFFFFFFF    <=============
0177 017F 0009 6C 6F 72 65 Filename              'lorem.txt'
               6D 2E 74 78
               74
0180 0181 0002 01 00       Extra ID #0001        0001 'ZIP64'
0182 0183 0002 08 00         Length              0008
0184 018B 0008 01 00 00 00   Offset to Local Dir 0000000000000001   <=============
               00 00 00 00
```

Create test file

first create a zip file

```
zip -fz -X test.zip lorem.txt
```
This has a single zip64 entry in CD, can zap that can be modified with perl code, below

```
0161 0164 0004 FF FF FF FF Uncompressed Length   FFFFFFFF <=== chamge to BE 01

0173 0176 0004 00 00 00 00 Local Header Offset   00000000 <==== change to ffffffff

0180 0181 0002 01 00       Extra ID #0001        0001 'ZIP64'
0182 0183 0002 08 00         Length              0008
0184 018B 0008 BE 01 00 00   Uncompressed Size   00000000000001BE <==== change to zero
               00 00 00 00
```

```
perl -e 'open my $fh, "+<", shift @ARGV or die "cannot open: $!\n"; seek($fh, shift(@ARGV) + 0, 0); print $fh pack("C*", map ($_ + 0, @ARGV))' test.zip 0x161 0xBE 0x01 0x00 0x00
perl -e 'open my $fh, "+<", shift @ARGV or die "cannot open: $!\n"; seek($fh, shift(@ARGV) + 0, 0); print $fh pack("C*", map ($_ + 0, @ARGV))' test.zip 0x173 0xFF 0xFF 0xFF 0xFF
perl -e 'open my $fh, "+<", shift @ARGV or die "cannot open: $!\n"; seek($fh, shift(@ARGV) + 0, 0); print $fh pack("C*", map ($_ + 0, @ARGV))' test.zip 0x184 0x00 0x00

```







