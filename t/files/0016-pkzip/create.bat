@REM Wipe all zip files

del *.zip

@REM  Creata a default.zip

pkzipc -add pkzip-default.zip lorem*.txt

@REM 204

pkzipc -add -204 pkzip-204.zip lorem*.txt

@REM Add a directory

mkdir somedir
pkzipc -add -dir pkzip-dir.zip somedir


@REM Zip64

@REM Create a file 64bit file


@REM zip64 stored

perl -e "open(F, '>xxx'); seek(F, 0xFFFFFFFF-1, 1); print F qq[X]"
pkzipc -add -store pkzip-zip64-store-4gig xxx
del xxx

perl -e "open(F, '>xxx'); seek(F, 0xFFFFFFFF, 1); print F qq[X]"
pkzipc -add -store pkzip-zip64-store-4gig-plus1 xxx
del xxx



@REM zip64 stored & encrypted

pkzipc -add -store -passphrase=password  pkzip-zip64-store-passphrase xxx

@REM zip64 stored & encrypted with encrypted CD

pkzipc -add -store -passphrase=password  -cd-encrypt pkzip-zip64-store-passphrase-cd xxx


@REM zip64 - 32k files


mkdir files
cd files
perl -e "for (1 .. 0xFFFF ) { my $h = sprintf qq[%X\n], $_; print qq[$h\n]; open F, qq[>$h] or die qq[cannot open: $!\n] ; print F $h or die qq[$!]; close F  }"
pkzipc -store -add ..\pkzip-zip64-32kfiles.zip *
cd ..
del files
rmdir files


@REM zip64 - 32k files plus one


mkdir files
cd files
perl -e "for (1 .. 0xFFFF+1 ) { my $h = sprintf qq[%X], $_; print qq[$h\n]; open F, qq[>$h] or die qq[cannot open: $!\n] ; print F $h or die qq[$!]; close F  }"
pkzipc -store -add ..\pkzip-zip64-32kfiles-plus-one.zip *
cd ..
del files
rmdir files

@REM  Signing

pkzipc -add  -certificate=#example.p12 -sign=all  pkzip-sign.zip lorem*.txt

@REM hash to use when signing
pkzipc -add  -certificate=#example.p12 -sign=all -hash=sha1     pkzip-sign-sha1.zip lorem*.txt
pkzipc -add  -certificate=#example.p12 -sign=all -hash=sha256   pkzip-sign-sha256.zip lorem*.txt
pkzipc -add  -certificate=#example.p12 -sign=all -hash=sha384   pkzip-sign-sha384.zip lorem*.txt
pkzipc -add  -certificate=#example.p12 -sign=all -hash=md5      pkzip-sign-md5.zip lorem*.txt


@REM # methods
pkzipc -add  -store      pkzip-method-store      lorem*.txt
pkzipc -add  -bzip2      pkzip-method-bzip2      lorem*.txt
pkzipc -add  -lzma       pkzip-method-lzma       lorem*.txt
pkzipc -add  -dclimplode pkzip-method-dclimplode lorem*.txt
pkzipc -add  -ppmd       pkzip-method-ppmd       lorem*.txt
pkzipc -add  -deflate64  pkzip-method-deflate64  lorem*.txt


@REM ## passphrase

pkzipc -add -passphrase=password -cd=normal pkzip-encrypt-passphrase.zip lorem*.txt
pkzipc -add -passphrase=password -cd=encrypt pkzip-encrypt-passphrase-cd.zip lorem*.txt

pkzipc -add -passphrase=password -cd=normal -lzma pkzip-method-lzma-encrypt-passphrase.zip lorem*.txt

@REM ## cryptalgorithms

@REM pkzipc -listcryptalgorithms
@REM SecureZIP(R) Command Line  Version 14 for Windows Evaluation Version
@REM Portions copyright (C) 1989-2014 PKWARE, Inc.  All Rights Reserved.
@REM Reg. U.S. Pat. and Tm. Off.  Patent No. 5,051,745  7,793,099  7,844,579
@REM 7,890,465  7,895,434;  Other patents pending

@REM Thank you for evaluating PKZIP(R). There are 29 days left in your evaluation period. Use of this software after the
@REM evaluation period requires purchase of a license for this machine. Contact PKWARE, Inc. at http://www.pkware.com/ for
@REM information on licensing this product.

@REM     Available encryption algorithms: pass

@REM             AES,256        AES (256-bit)
@REM             AES,192        AES (192-bit)
@REM             AES,128        AES (128-bit)
@REM             3DES,168       3DES (168-bit)


pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=aes,128 pkzip-encrypt-passphrase-aes128.zip lorem*.txt
pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=aes,192 pkzip-encrypt-passphrase-aes192.zip lorem*.txt
pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=aes,256 pkzip-encrypt-passphrase-aes256.zip lorem*.txt
pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=3des,168 pkzip-encrypt-passphrase-3des168.zip lorem*.txt

pkzipc -add -passphrase=password -cd=encrypt -cryptalgorithm=aes,128 pkzip-encrypt-passphrase-aes128-cd.zip lorem*.txt
pkzipc -add -passphrase=password -cd=encrypt -cryptalgorithm=aes,192 pkzip-encrypt-passphrase-aes192-cd.zip lorem*.txt
pkzipc -add -passphrase=password -cd=encrypt -cryptalgorithm=aes,256 pkzip-encrypt-passphrase-aes256-cd.zip lorem*.txt
pkzipc -add -passphrase=password -cd=encrypt -cryptalgorithm=3des,168 pkzip-encrypt-passphrase-3des168-cd.zip lorem*.txt

pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=normal -cryptalgorithm=aes,128 pkzip-encrypt-recipient-aes128.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=normal -cryptalgorithm=aes,192 pkzip-encrypt-recipient-aes192.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=normal -cryptalgorithm=aes,256 pkzip-encrypt-recipient-aes256.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=normal -cryptalgorithm=3des,168 pkzip-encrypt-recipient-3des168.zip lorem*.txt

pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=encrypt -cryptalgorithm=aes,128 pkzip-encrypt-recipient-aes128-cd.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=encrypt -cryptalgorithm=aes,192 pkzip-encrypt-recipient-aes192-cd.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=encrypt -cryptalgorithm=aes,256 pkzip-encrypt-recipient-aes256-cd.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=encrypt -cryptalgorithm=3des,168 pkzip-encrypt-recipient-3des168-cd.zip lorem*.txt

pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=normal -nosmartcard pkzip-encrypt-recipient-nosmartcard.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=encrypt -certificate=#example.p12 -sign=all pkzip-sign-encrypt-recipient-cd.zip lorem*.txt
pkzipc -add -recipient=#cert1.p12 -recipient=#cert2.p12 -cd=normal -certificate=#example.p12 -sign=all pkzip-sign-encrypt-recipient.zip lorem*.txt
