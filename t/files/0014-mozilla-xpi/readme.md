# Mozilla XPI file

The Date & Time fields are all null. The Date filed is invalid because

* the day-of-month field should be in the renge 1-31, so zero is invalid
* the month field is also offset from 1, so again zero is invalid.

Before checkng for this use-case this null date/time breaks `Time::Local::timegm` as follows

    $ zipdetails --scan -v ublock_origin-1.43.0.xpi

    000000 000004 50 4B 03 04 LOCAL HEADER #1       04034B50
    000004 000001 14          Extract Zip Spec      14 '2.0'
    000005 000001 00          Extract OS            00 'MS-DOS'
    000006 000002 08 00       General Purpose Flag  0008
                              [Bits 1-2]            0 'Normal Compression'
                              [Bit  3]              1 'Streamed'
    000008 000002 08 00       Compression Method    0008 'Deflated'
    Month '-1' out of range 0..11 at ./bin/zipdetails line 2403.

# References

XPI file sourced  from https://addons.mozilla.org/firefox/downloads/file/3961087/ublock_origin-1.43.0.xpi
