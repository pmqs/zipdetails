Creata a zip with no extras


    echo abcde >letters.txt
    echo 12345 >numbers.txt

    zip -X -0 test.zip letters.txt numbers.txt

File gaps.zip have a padding byte after each payload. Done the hard way!