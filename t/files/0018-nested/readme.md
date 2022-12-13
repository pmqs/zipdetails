## Nested Zip files

If a zip file is `stored` (i.e. uncompressed) in anothert zip file, the `--scan` option will find the nested entries

# Create

    zip  -fz- -X inner.zip lorem.txt
    zip  -fz- -0 -X outer.zip inner.zip
    rm inner.zip

    zip  -fz- -X inner.zip lorem.txt
    zip  -fz- -0 -X - inner.zip | cat >outer.zip
    rm inner.zip


    zip  -fz- -X inner1.zip lorem.txt
    zip  -fz- -0 -X inner2.zip inner1.zip
    zip  -fz- -0 -X outer.zip inner2.zip
    rm inner1.zip inner2.zip

    zip  -fz- -X inner1.zip lorem.txt
    zip  -fz- -0 -X - inner1.zip | cat >inner2.zip
    zip  -fz- -0 -X - inner2.zip | cat >outer.zip
    rm inner1.zip inner2.zip