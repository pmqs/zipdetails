
# Apache Commons Compress

Apache Commons Compress lives at http://commons.apache.org/proper/commons-compress/

GitHub repository at https://github.com/apache/commons-compress

Jira is https://issues.apache.org/jira/projects/COMPRESS/issues/COMPRESS-598?filter=allopenissues

This library supports the Data Stream Alignment extra field (A11E) -- method to create is `ZipArchiveEntry.setAlignment`

# Testing

Tested with 1.20 -- April 2021

mkZip.java file derived from src/test/java/org/apache/commons/compress/archivers/zip/ZipFileTest.java in Apache Commons Compress

    wget https://apache.mirrors.nublue.co.uk//commons/compress/binaries/commons-compress-1.20-bin.zip
    unzip  commons-compress-1.20-bin.zip
    javac  -cp commons-compress-1.20/commons-compress-1.20.jar:/usr/share/java/commons-io.jar mkzip.java
    java -cp .:commons-compress-1.20/commons-compress-1.20.jar:/usr/share/java/commons-io.jar mkZip

# Observations with Commons Compress 1.20

Jira issues for Commons Compress are [here](https://issues.apache.org/jira/browse/COMPRESS-538?jql=status%20in%20(Open%2C%20%22In%20Progress%22%2C%20Reopened%2C%20Blocked%2C%20Continued%2C%20%22Patch%20Available%22%2C%20%22Patch%20Reviewed%22%2C%20Reviewable%2C%20%22Documentation%20Required%22%2C%20%22Testcases%20Required%22%2C%20%22Documentation%2FTestcases%20Required%22%2C%20%22Waiting%20for%20user%22%2C%20%22Waiting%20for%20Infra%22%2C%20Testing%2C%20Unknown%2C%20%22Requires%20Porting%22%2C%20%22Not%20Applicable%22%2C%20Ported%2C%20%22In%20Review%22%2C%20%22To%20Do%22%2C%20Accepted%2C%20%22Ready%20to%20Commit%22%2C%20%22Awaiting%20Feedback%22%2C%20New%2C%20Fixed%2C%20Invalid%2C%20FixedInBranch%2C%20Verified%2C%20WontFix%2C%20UnderReview%2C%20Started%2C%20%22For%20Review%22%2C%20Idea%2C%20Abandoned%2C%20%22Under%20Discussion%22%2C%20%22In%20Implementation%22%2C%20%22on%20hold%22%2C%20%22Triage%20Needed%22%2C%20%22Review%20In%20Progress%22%2C%20%22Changes%20Suggested%22%2C%20%22Requires%20Testing%22%2C%20Draft%2C%20Voting%2C%20Passed%2C%20Failed%2C%20Pending)%20AND%20text%20~%20%22zip64%22)

## Partial local header by default

local header incomplete Zip64

    static void no_alignment() throws Exception
    {

        File apache = new File("/tmp/no-alignment.zip");
        ZipArchiveOutputStream zipOutput = new ZipArchiveOutputStream(apache);

        final ZipArchiveEntry inflatedEntry = new ZipArchiveEntry("inflated.txt");
        inflatedEntry.setMethod(ZipEntry.DEFLATED);
        // inflatedEntry.setAlignment(1024);
        zipOutput.putArchiveEntry(inflatedEntry);
        zipOutput.write("Hello Deflated\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        final ZipArchiveEntry storedEntry = new ZipArchiveEntry("stored.txt");
        storedEntry.setMethod(ZipEntry.STORED);
        // storedEntry.setAlignment(1024);
        zipOutput.putArchiveEntry(storedEntry);
        zipOutput.write("Hello Stored\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        zipOutput.close() ;
    }


compressed & uncompressed lengths not FFFF

    0000 0004 50 4B 03 04 LOCAL HEADER #1       04034B50
    0004 0001 14          Extract Zip Spec      14 '2.0'
    0005 0001 00          Extract OS            00 'MS-DOS'
    0006 0002 00 08       General Purpose Flag  0800
                          [Bits 1-2]            0 'Normal Compression'
                          [Bit 11]              1 'Language Encoding'
    0008 0002 08 00       Compression Method    0008 'Deflated'
    000A 0004 68 81 8B 52 Last Mod Time         528B8168 'Sun Apr 11 15:11:16 2021'
    000E 0004 31 1B CD 8C CRC                   8CCD1B31
    0012 0004 11 00 00 00 Compressed Length     00000011
    0016 0004 0F 00 00 00 Uncompressed Length   0000000F
    001A 0002 0C 00       Filename Length       000C
    001C 0002 14 00       Extra Length          0014
    001E 000C 69 6E 66 6C Filename              'inflated.txt'
              61 74 65 64
              2E 74 78 74
    002A 0002 01 00       Extra ID #0001        0001 'ZIP64'
    002C 0002 10 00         Length              0010
    002E 0008 0F 00 00 00   Uncompressed Size   000000000000000F
              00 00 00 00
    0036 0008 11 00 00 00   Compressed Size     0000000000000011
              00 00 00 00
    003E 0011 F3 48 CD C9 PAYLOAD               .H...WpIM.I,IM...
              C9 57 70 49
              4D CB 49 2C
              49 4D E1 02
              00




## always zip64

    static void always_zip64() throws Exception
    {

        File apache = new File("/tmp/always-zip64.zip");
        ZipArchiveOutputStream zipOutput = new ZipArchiveOutputStream(apache);
        zipOutput.setUseZip64(Zip64Mode.Always);


        final ZipArchiveEntry inflatedEntry = new ZipArchiveEntry("inflated.txt");
        zipOutput.setMethod(ZipEntry.DEFLATED);

        zipOutput.putArchiveEntry(inflatedEntry);
        zipOutput.write("Hello Deflated\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        final ZipArchiveEntry storedEntry = new ZipArchiveEntry("stored.txt");
        storedEntry.setMethod(ZipEntry.STORED);
        zipOutput.putArchiveEntry(storedEntry);
        zipOutput.write("Hello Stored\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        zipOutput.close() ;
    }

Code  creates CD record like this - issue is the disk start field is not FFFF

    0098 0004 50 4B 01 02 CENTRAL HEADER #1     02014B50
    009C 0001 2D          Created Zip Spec      2D '4.5'
    009D 0001 00          Created OS            00 'MS-DOS'
    009E 0001 2D          Extract Zip Spec      2D '4.5'
    009F 0001 00          Extract OS            00 'MS-DOS'
    00A0 0002 00 08       General Purpose Flag  0800
                          [Bits 1-2]            0 'Normal Compression'
                          [Bit 11]              1 'Language Encoding'
    00A2 0002 08 00       Compression Method    0008 'Deflated'
    00A4 0004 68 81 8B 52 Last Mod Time         528B8168 'Sun Apr 11 15:11:16 2021'
    00A8 0004 31 1B CD 8C CRC                   8CCD1B31
    00AC 0004 FF FF FF FF Compressed Length     FFFFFFFF
    00B0 0004 FF FF FF FF Uncompressed Length   FFFFFFFF
    00B4 0002 0C 00       Filename Length       000C
    00B6 0002 20 00       Extra Length          0020
    00B8 0002 00 00       Comment Length        0000
    00BA 0002 00 00       Disk Start            0000
    00BC 0002 00 00       Int File Attributes   0000
                          [Bit 0]               0 'Binary Data'
    00BE 0004 00 00 00 00 Ext File Attributes   00000000
    00C2 0004 FF FF FF FF Local Header Offset   FFFFFFFF
    00C6 000C 69 6E 66 6C Filename              'inflated.txt'
              61 74 65 64
              2E 74 78 74
    00D2 0002 01 00       Extra ID #0001        0001 'ZIP64'
    00D4 0002 1C 00         Length              001C
    00D6 0008 0F 00 00 00   Uncompressed Size   000000000000000F
              00 00 00 00
    00DE 0008 11 00 00 00   Compressed Size     0000000000000011
              00 00 00 00
    00E6 0008 00 00 00 00   Offset to Local Dir 0000000000000000
              00 00 00 00
    00EE 0004 00 00 00 00   Disk Number         00000000


## APPNOTE

    4.5.3 -Zip64 Extended Information Extra Field (0x0001):
     
        The following is the layout of the zip64 extended
        information "extra" block. If one of the size or
        offset fields in the Local or Central directory
        record is too small to hold the required data,
        a Zip64 extended information record is created.
        The order of the fields in the zip64 extended
        information record is fixed, but the fields MUST
        only appear if the corresponding Local or Central
        directory record field is set to 0xFFFF or 0xFFFFFFFF.
     
        Note: all fields stored in Intel low-byte/high-byte order.
     
            Value      Size       Description
            -----      ----       -----------
    (ZIP64) 0x0001     2 bytes    Tag for this "extra" block type
            Size       2 bytes    Size of this "extra" block
            Original
            Size       8 bytes    Original uncompressed file size
            Compressed
            Size       8 bytes    Size of compressed data
            Relative Header
            Offset     8 bytes    Offset of local header record
            Disk Start
            Number     4 bytes    Number of the disk on which
                                this file starts
     
        This entry in the Local header MUST include BOTH original
        and compressed file size fields. If encrypting the
        central directory and bit 13 of the general purpose bit
        flag is set indicating masking, the value stored in the
        Local Header for the original file size will be zero.

and this

    4.4.13 disk number start: (2 bytes)
    The number of the disk on which this file begins.  If an
    archive is in ZIP64 format and the value in this field is
    0xFFFF, the size will be in the corresponding 4 byte zip64
    extended information extra field.
