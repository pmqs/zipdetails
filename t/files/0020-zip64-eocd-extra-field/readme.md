## Zip64 end of central directory extra filed


Not seen in the wild, so test file have been hand crafted

APPNOTE 6.3.9, Appendix lists only one extra field defined.
Note that `0x0065` is overloaded for other local/central extra fields.

    APPENDIX C - Zip64 Extensible Data Sector Mappings
    ---------------------------------------------------

            -Z390   Extra Field:

            The following is the general layout of the attributes for the
            ZIP 64 "extra" block for extended tape operations.

            Note: some fields stored in Big Endian format.  All text is
            in EBCDIC format unless otherwise specified.

            Value       Size          Description
            -----       ----          -----------
    (Z390)  0x0065      2 bytes       Tag for this "extra" block type
            Size        4 bytes       Size for the following data block
            Tag         4 bytes       EBCDIC "Z390"
            Length71    2 bytes       Big Endian
            Subcode71   2 bytes       Enote type code
            FMEPos      1 byte
            Length72    2 bytes       Big Endian
            Subcode72   2 bytes       Unit type code
            Unit        1 byte        Unit
            Length73    2 bytes       Big Endian
            Subcode73   2 bytes       Volume1 type code
            FirstVol    1 byte        Volume
            Length74    2 bytes       Big Endian
            Subcode74   2 bytes       FirstVol file sequence
            FileSeq     2 bytes       Sequence
