# zip file with prefix data -- zip64 enabled

Use `-fz` to force `ZIP64` headers.

    zip -fz dummy.zip lorem*.txt
    echo -n abcd >test.zip
    cat dummy.zip >>test.zip
    rm dummy.zip
