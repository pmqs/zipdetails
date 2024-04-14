# bsdtar/libarchive

```
$ bsdtar --version
bsdtar 3.6.2 - libarchive 3.6.2 zlib/1.2.13 liblzma/5.4.0 bz2lib/1.0.8 liblz4/1.9.4 libzstd/1.5.2
```

## deflate

bsdtar -a --options zip:compression=deflate -cvf deflate.zip lorem.txt

## store

bsdtar -a --options zip:compression=store -cvf store.zip lorem.txt

## weak encryption

Password is `password`

bsdtar -a --options zip:encryption=zipcrypt -cvf encrypt-zipcrypt.zip lorem.txt

## aes128

bsdtar -a --options zip:encryption=aes128 -cvf encrypt-aes128.zip lorem.txt

## aes256

bsdtar -a --options zip:encryption=aes256 -cvf encrypt-aes256.zip lorem.txt

## directory

mkdir dir
bsdtar -a -cvf directory.zip  dir
rmdir dir

## unicode

bsdtar -a -cvf unicode.zip Café