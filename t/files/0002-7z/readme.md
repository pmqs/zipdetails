
7z man page is https://documentation.help/7-Zip/start.htm

create zip files as follows

    7z a  7z-linux-aes128.zip    lorem.txt -mem=aes128    -ppassword
    7z a  7z-linux-aes192.zip    lorem.txt -mem=aes192    -ppassword
    7z a  7z-linux-aes256.zip    lorem.txt -mem=aes256    -ppassword
    7z a  7z-linux-zipcrypto.zip lorem.txt -mem=zipcrypto -ppassword

    7z a  7z-linux-sfx.zip       lorem.txt -sfx

    7z a  7z-linux-bzip2.zip     lorem.txt -mm=bzip2
    7z a  7z-linux-copy.zip      lorem.txt -mm=copy
    7z a  7z-linux-deflate64.zip lorem.txt -mm=deflate64
    7z a  7z-linux-lzma.zip lorem.txt -mm=lzma
    7z a  7z-linux-ppmd.zip lorem.txt -mm=ppmd

Create a directory

    mkdir somedir
    7z a 7z-linux-directory.zip somedir
    rmdif somedir

# Notes

7z on Linux creates the NTFS extra field in the central directory