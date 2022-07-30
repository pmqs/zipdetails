# Xceed BWT Compression

File, `Sample.bwt`, created by 2BrightSparks SyncBack. Under the hood it uses the [Xceed zip library](https://xceed.com/en/our-products/product/zip-for-net).

In the [Xceed Acknowledgements](https://doc.xceed.com/xceed-zip-for-activex/webframe.html#Acknowledgments.html) documentation it suggest the file may actually be a cut-down `bzip2`

    Libbzip2
    The BWT compression algorithm introduced in Xceed Zip Compression Library v4.5 is based on the Libbzip2 library, written by Julian Seward. 

Below is from [CompressionMethod property](https://doc.xceed.com/xceed-zip-for-activex/webframe.html#CompressionMethod_property.html)

    xcmBurrowsWheeler

    Use the BWT compression method.

    The raw BWT block-sorting algorithm. Produces smaller compressed output than the BZip2 method, but is not compatible with WinZip. It is compatible with zip files created using the BWT compression method offered by Xceed Zip for .NET.

This library uses Compression Method code `18` for `BWT`. [APPNOTE.txt](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT) already has this code allocated, as follows

        18 - File is compressed using IBM TERSE (new)

TERSE is from IBM OS/2, so it ancient history.

No sign of support for this compression method with unzip/7z, so this is likely to be uncompressible only with the Xceed library.