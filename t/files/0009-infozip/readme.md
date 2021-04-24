create zip files as follows

    zip  --compression-method deflate               iz-linux-standard-deflate.zip       lorem.txt
    zip  --compression-method store                 iz-linux-standard-store.zip         lorem.txt
    zip  --compression-method bzip2                 iz-linux-standard-bzip2.zip         lorem.txt
    zip  --compression-method deflate --force-zip64 iz-linux-standard-deflate-zip64.zip lorem.txt


    zip --force-zip64- iz-linux-stream-nozip64.zip -  <lorem.txt
    zip --force-zip64  iz-linux-stream-zip64.zip   -  <lorem.txt


