minizip -0 -z minizip-z.zip lorem.txt

minizip -0 -z -s -p password minizip-z-s.zip lorem.txt

## Add a directory

    mkdir somedir
    minizip directory.zip somedir
    rmdir somedir