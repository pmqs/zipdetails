# pkzip (aka SecureZIP)

Executable lives at "C:\Program Files\PKWARE\PKZIPC\pkzipc.exe"

## Encrypted CD plus a comment

need a zip with cd encrypted + a zip comment to test the logic that finds the CD records.


    pkzipc -add -header="This is a comment"  -passphrase=password  -cd=encrypt pkzip-zip64-store-passphrase-cd-header-comment.zip lorem.txt lorem2.txt

## default

    pkzipc -add pkzip-default.zip lorem.txt

## streamed

Output looks like a normal zip, so appares that pkzip doesn't support writing streamed zip files.

    pkzipc -add -noarchiveextension -silent=normal - lorem.txt

## signed

Sign both central & individual file

    pkzipc -add  -certificate=#example.p12 -sign=all  pkzip-signed.zip lorem.txt

## passphrase

    pkzipc -add -passphrase=password -cd=normal  pkzip-encrypt-passphrase.zip lorem.txt
    pkzipc -add -passphrase=password -cd=encrypt  pkzip-encrypt-passphrase-cd.zip lorem.txt


## cryptalgorithms

<!-- pkzipc -listcryptalgorithms
SecureZIP(R) Command Line  Version 14 for Windows Evaluation Version
Portions copyright (C) 1989-2014 PKWARE, Inc.  All Rights Reserved.
Reg. U.S. Pat. and Tm. Off.  Patent No. 5,051,745  7,793,099  7,844,579
7,890,465  7,895,434;  Other patents pending

Thank you for evaluating PKZIP(R). There are 29 days left in your evaluation period. Use of this software after the
evaluation period requires purchase of a license for this machine. Contact PKWARE, Inc. at http://www.pkware.com/ for
information on licensing this product.

    Available encryption algorithms:

            AES,256        AES (256-bit)
            AES,192        AES (192-bit)
            AES,128        AES (128-bit)
            3DES,168        3DES (168-bit) -->


    pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=aes,128 pkzip-encrypt-passphrase-aes128.zip lorem.txt
    pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=aes,192 pkzip-encrypt-passphrase-aes192.zip lorem.txt
    pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=aes,256 pkzip-encrypt-passphrase-aes256.zip lorem.txt
    pkzipc -add -passphrase=password -cd=normal -cryptalgorithm=3des,168 pkzip-encrypt-passphrase-3des168.zip lorem.txt

## encrypt header


######

    pkzipc -add -passphrase=password encrypt-passphrase.zip lorem.txt
    pkzipc -add -passphrase=password -cd=encrypt encrypt-passphrase-header.zip lorem.txt
    pkzipc -add -passphrase=password -recipient="me" -cd=encrypt encrypt-passphrase-header-recipient.zip lorem.txt

## Methods
    pkzipc -add  -store      pkzip-method-store      lorem.txt
    pkzipc -add  -bzip2      pkzip-method-bzip2      lorem.txt
    pkzipc -add  -lzma       pkzip-method-lzma       lorem.txt
    pkzipc -add  -dclimplode pkzip-method-dclimplode lorem.txt
    pkzipc -add  -ppmd       pkzip-method-ppmd       lorem.txt
    pkzipc -add  -deflate64  pkzip-method-deflate64  lorem.txt

## passphrase

    pkzipc -add -passphrase=password -cd=normal pkzip-encrypt-passphrase.zip lorem.txt
    pkzipc -add -passphrase=password -cd=encrypt pkzip-encrypt-passphrase-cd.zip lorem.txt

# Creating Certificates

    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes   -keyout example.key -out example.crt -extensions san -config   <(echo "[req]";
        echo distinguished_name=req;
        echo "[san]";
        echo subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1
        )   -subj "/CN=example.com"

    openssl pkcs12 -export -out example.p12 -inkey example.key -in example.crt


    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes   -keyout cert1.key -out cert1.crt -extensions san -config   <(echo "[req]";
        echo distinguished_name=req;
        echo "[san]";
        echo subjectAltName=DNS:cert1.com,DNS:www.cert1.net,IP:10.0.0.1
        )   -subj "/CN=cert1.com"

    openssl pkcs12 -export -out cert1.p12 -inkey cert1.key -in cert1.crt

    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes   -keyout cert2.key -out cert2.crt -extensions san -config   <(echo "[req]";
        echo distinguished_name=req;
        echo "[san]";
        echo subjectAltName=DNS:cert2.com,DNS:www.cert2.net,IP:10.0.0.1
        )   -subj "/CN=cert2.com"

    openssl pkcs12 -export -out cert2.p12 -inkey cert2.key -in cert2.crt

    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes   -keyout cert3.key -out cert3.crt -extensions san -config   <(echo "[req]";
        echo distinguished_name=req;
        echo "[san]";
        echo subjectAltName=DNS:cert3.com,DNS:www.cert3.net,IP:10.0.0.1
        )   -subj "/CN=cert3.com"

    openssl pkcs12 -export -out cert3.p12 -inkey cert3.key -in cert3.crt

## Spanned Archives

    truncate -s1m onemeg
    pkzipc -add -store -span=360 pkzip-span-multi-segment.zip onemeg

    pkzipc -add -store -span=360 pkzip-span-single-segment.zip lorem.txt
