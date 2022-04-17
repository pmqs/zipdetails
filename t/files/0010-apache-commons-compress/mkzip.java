

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ResourceAlignmentExtraField;
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream;
import org.apache.commons.compress.archivers.zip.Zip64Mode;

import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.RandomAccessFile;
import java.io.FileOutputStream;
import java.io.InputStream;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import org.apache.commons.compress.utils.CharsetNames;
import org.apache.commons.compress.archivers.zip.UnicodePathExtraField;
import org.apache.commons.compress.archivers.zip.ZipEncodingHelper;
import org.apache.commons.compress.archivers.zip.ZipEncoding;
import java.nio.ByteBuffer;

class mkZip
{
    public static void main(String args[])
    {
        try
        {
            alignment();
            no_alignment();
            no_zip64();
            always_zip64();
            COMPRESS_565();

            createTestFile("efs_off-extra_off-US_ASCII.zip", CharsetNames.US_ASCII, false, false);
            createTestFile("efs_off-extra_off-UTF_8.zip", CharsetNames.UTF_8, false, false);

            createTestFile("efs_off-extra_on-US_ASCII.zip", CharsetNames.US_ASCII, false, true);
            createTestFile("efs_off-extra_on-UTF_8.zip", CharsetNames.UTF_8, false, true);

            createTestFile("efs_on-extra_off-US_ASCII.zip", CharsetNames.US_ASCII, true, false);
            createTestFile("efs_on-extra_off-UTF_8.zip", CharsetNames.UTF_8, true, false);

            createTestFile("efs_on-extra_on-US_ASCII.zip", CharsetNames.US_ASCII, true, true);
            createTestFile("efs_on-extra_on-UTF_8.zip", CharsetNames.UTF_8, true, true);
        }
        catch (final Exception e) {
            e.printStackTrace();;
        }
    }

    static void alignment() throws Exception
    {
        File apache = new File("/tmp/data-stream-alignment.zip");
        ZipArchiveOutputStream zipOutput = new ZipArchiveOutputStream(apache);

        final ZipArchiveEntry inflatedEntry = new ZipArchiveEntry("inflated.txt");
        inflatedEntry.setMethod(ZipEntry.DEFLATED);

        inflatedEntry.setAlignment(64);
        zipOutput.putArchiveEntry(inflatedEntry);
        zipOutput.write("Hello Deflated\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        final ZipArchiveEntry storedEntry = new ZipArchiveEntry("stored.txt");
        storedEntry.setMethod(ZipEntry.STORED);

        ResourceAlignmentExtraField resourceAlignment = new ResourceAlignmentExtraField(32, true, 3);
        storedEntry.addExtraField(resourceAlignment) ;
        // storedEntry.setAlignment(1024);
        zipOutput.putArchiveEntry(storedEntry);
        zipOutput.write("Hello Stored\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        zipOutput.close() ;
    }


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

    static void no_zip64() throws Exception
    {

        File apache = new File("/tmp/no-zip64.zip");
        ZipArchiveOutputStream zipOutput = new ZipArchiveOutputStream(apache);

        zipOutput.setUseZip64(Zip64Mode.Never);

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



    private static void createTestFile(final String filename,
                                       final String encoding,
                                       final boolean withEFS,
                                       final boolean withExplicitUnicodeExtra)
                                       throws IOException
    {

        final String OIL_BARREL_TXT = "\u00D6lf\u00E4sser.txt";
        final String CP437 = "cp437";
        final String ASCII_TXT = "ascii.txt";
        final String EURO_FOR_DOLLAR_TXT = "\u20AC_for_Dollar.txt";

        File file = new File(filename);

        final ZipEncoding zipEncoding = ZipEncodingHelper.getZipEncoding(encoding);

        ZipArchiveOutputStream zos = null;
        try {
            zos = new ZipArchiveOutputStream(file);
            zos.setUseZip64(Zip64Mode.Always);
            zos.setEncoding(encoding);
            zos.setUseLanguageEncodingFlag(withEFS);
            zos.setCreateUnicodeExtraFields(withExplicitUnicodeExtra ?
                                            ZipArchiveOutputStream
                                            .UnicodeExtraFieldPolicy.NEVER
                                            : ZipArchiveOutputStream
                                            .UnicodeExtraFieldPolicy.ALWAYS);



            ZipArchiveEntry ze = new ZipArchiveEntry(OIL_BARREL_TXT);
            if (withExplicitUnicodeExtra
                && !zipEncoding.canEncode(ze.getName())) {

                final ByteBuffer en = zipEncoding.encode(ze.getName());

                ze.addExtraField(new UnicodePathExtraField(ze.getName(),
                                                           en.array(),
                                                           en.arrayOffset(),
                                                           en.limit()
                                                           - en.position()));
            }

            zos.putArchiveEntry(ze);
            zos.write("Hello, world!".getBytes(StandardCharsets.US_ASCII));
            zos.closeArchiveEntry();

            // ze = new ZipArchiveEntry(EURO_FOR_DOLLAR_TXT);
            // if (withExplicitUnicodeExtra
            //     && !zipEncoding.canEncode(ze.getName())) {

            //     final ByteBuffer en = zipEncoding.encode(ze.getName());

            //     ze.addExtraField(new UnicodePathExtraField(ze.getName(),
            //                                                en.array(),
            //                                                en.arrayOffset(),
            //                                                en.limit()
            //                                                - en.position()));
            // }

            // zos.putArchiveEntry(ze);
            // zos.write("Give me your money!".getBytes(StandardCharsets.US_ASCII));
            // zos.closeArchiveEntry();

            // ze = new ZipArchiveEntry(ASCII_TXT);

            // if (withExplicitUnicodeExtra
            //     && !zipEncoding.canEncode(ze.getName())) {

            //     final ByteBuffer en = zipEncoding.encode(ze.getName());

            //     ze.addExtraField(new UnicodePathExtraField(ze.getName(),
            //                                                en.array(),
            //                                                en.arrayOffset(),
            //                                                en.limit()
            //                                                - en.position()));
            // }

            // zos.putArchiveEntry(ze);
            // zos.write("ascii".getBytes(StandardCharsets.US_ASCII));
            // zos.closeArchiveEntry();

            zos.finish();
        } finally {
            if (zos != null) {
                try {
                    zos.close();
                } catch (final IOException e) { /* swallow */ }
            }
        }
    }



    static void COMPRESS_565() throws Exception
    {
        // https://issues.apache.org/jira/browse/COMPRESS-565

        RandomAccessFile randomAccessFile = new RandomAccessFile("input.bin", "rw");
        randomAccessFile.setLength(1024L * 1024 * 1024 * 5);

        File outputFile = new File("COMPRESS_565.zip");
        outputFile.createNewFile();
        try(ZipArchiveOutputStream zipArchiveOutputStream = new ZipArchiveOutputStream(new BufferedOutputStream(new FileOutputStream(outputFile)))) {
            zipArchiveOutputStream.setUseZip64(Zip64Mode.Always);
            zipArchiveOutputStream.setMethod(ZipEntry.DEFLATED);
            zipArchiveOutputStream.setCreateUnicodeExtraFields(ZipArchiveOutputStream.UnicodeExtraFieldPolicy.ALWAYS);

             zipArchiveOutputStream.putArchiveEntry(new ZipArchiveEntry("input.bin"));

            InputStream inputStream = new FileInputStream("input.bin");
            IOUtils.copy(inputStream, zipArchiveOutputStream);

            zipArchiveOutputStream.closeArchiveEntry();
        }
    }
}