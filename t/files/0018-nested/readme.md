## Nested Zip files

If a zip file is `stored` (i.e. uncompressed) in anothert zip file, the `--scan` option will find the nested entries

# Create

    zip  -fz- -X inner.zip lorem.txt
    zip  -fz- -0 -X outer.zip inner.zip