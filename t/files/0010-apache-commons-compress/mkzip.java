
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ResourceAlignmentExtraField;
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream;
import org.apache.commons.compress.archivers.zip.Zip64Mode;

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

        inflatedEntry.setAlignment(1024);
        zipOutput.putArchiveEntry(inflatedEntry);
        zipOutput.write("Hello Deflated\n".getBytes(StandardCharsets.UTF_8));
        zipOutput.closeArchiveEntry();

        final ZipArchiveEntry storedEntry = new ZipArchiveEntry("stored.txt");
        storedEntry.setMethod(ZipEntry.STORED);

        ResourceAlignmentExtraField resourceAlignment = new ResourceAlignmentExtraField(1025, true, 3);
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
}
