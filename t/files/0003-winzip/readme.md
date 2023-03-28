# WinZip

 -
## Reference

New feature in WinZip 25 that detects duplicate file and stores a reference entry.
See https://www.winzip.com/en/support/compression-methods/.

Create three files that have same content: f1, f2, f3.

    wzzip -a -e0 winzip-duplicate.zip f1 f2 f3

## zip64

    truncate -s4G 4gig-plus1
    wzzip -a -e0 winzip-zip64-4gig-plus1 4gig-plus1

    truncate -s4G 4gig
    truncate -s-1 4gig

    wzzip -a -e0 winzip-zip64-4gig 4gig

## zip64: 32k files

    mkdir files
    cd files
    perl -e "for (1 .. 0xFFFF ) { my $h = sprintf qq[%X], $_; print qq[$h\n]; open F, qq[>$h] or die qq[cannot open: $!\n] ; print F $h or die qq[$!]; close F  }"
    wzzip -a -e0 ..\winzip-zip64-32kfiles.zip *
    cd ..
    del files
    rmdir files


## zip64:  32k files plus one

    mkdir files
    cd files
    perl -e "for (1 .. 0xFFFF+1 ) { my $h = sprintf qq[%X], $_; print qq[$h\n]; open F, qq[>$h] or die qq[cannot open: $!\n] ; print F $h or die qq[$!]; close F  }"
    wzzip -a -e0 ..\winzip-zip64-32kfiles-plus1.zip *
    cd ..
    del files
    rmdir files

## enhanced Deflate (9)

    wzzip -a -ee

## lzma

    wzzip -a -el

## Filename encoding

    wzzip -a -yu -C

## Encryption

See https://www.winzip.com/en/support/aes-encryption/

    wzzip -a -spassword winzip-encrypt-std.zip lorem.txt
    wzzip -a -spassword -yc winzip-encrypt-aes128.zip lorem.txt
    wzzip -a -spassword -ycAES256 winzip-encrypt-aes256.zip lorem.txt

## Split Archive

Single

    zip -0 lorem.zip lorem.txt
    wzzip -ys64 lorem.zip lorem-split.zip

Multi segment archive diesn't contain any special markers
