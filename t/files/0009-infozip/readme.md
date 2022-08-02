create zip files as follows (assumes zip version 3.0)

## Methods

    zip  --compression-method deflate               iz-linux-standard-deflate.zip       lorem.txt
    zip  --compression-method store                 iz-linux-standard-store.zip         lorem.txt
    zip  --compression-method bzip2                 iz-linux-standard-bzip2.zip         lorem.txt
    zip  --compression-method deflate --force-zip64 iz-linux-standard-deflate-zip64.zip lorem.txt

## Stream from stdin

    zip --force-zip64- iz-linux-stdin-nozip64.zip -  <lorem.txt
    zip --force-zip64  iz-linux-stdin-zip64.zip   -  <lorem.txt


## Stream to stdout

    zip --force-zip64- - lorem.txt| cat >iz-linux-stream-nozip64.zip

## InfoZip Bugs

Using zip 3.0 (1 Aug 2022) the command below creates an invalid file file. It is missing the central directory ZIP64 records `zip64 end of central directory record` and `zip64 end of central directory locator`

    echo abcde | zip --force-zip64 | cat >iz-linux-stream-zip64.zip

Issue reported https://sourceforge.net/p/infozip/bugs/68/. See also https://sourceforge.net/p/infozip/bugs/61/

Needs the `--scan` option to view it with `zipdetails`.

# TODO

* Encryption (-e & -P)
* UTF8?
* self extractor
* symlinks



