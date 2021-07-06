# Android APK Files

See [Application Signing](https://source.android.com/security/apksigning) for APK signature scheme


## Small V2 APK file
`signed-release.apk` sourced from [ApkGolf](https://github.com/fractalwrench/ApkGolf) via https://issues.apache.org/jira/browse/COMPRESS-455


## Padding
`test-services-1.4.0.apk` has extra data before and within the block (from https://maven.google.com/web/index.html?q=test-ser#androidx.test.services:test-services)

## Overlap
`test-services-1.1.0.apk` sourced from https://issues.apache.org/jira/browse/COMPRESS-562

```
$ unzip -t !$
unzip -t test-services-1.1.0.apk
Archive:  test-services-1.1.0.apk
error [test-services-1.1.0.apk]:  missing 237 bytes in zipfile
  (attempting to process anyway)
error: invalid zip file with overlapped components (possible zip bomb)
```

The end central header looks like this. Problem is the `Offset to Central Dir` field. It should be `17F13` rather then `18000`

```182A7 END CENTRAL HEADER    06054B50
182AB Number of this disk   0000
182AD Central Dir Disk no   0000
182AF Entries in this disk  000C
182B1 Total Entries         000C
182B3 Size of Central Dir   00000394
182B7 Offset to Central Dir 00018000
182BB Comment Length        0000
```


## Utilities

`parse_apk.py` sourced from https://github.com/cryptax/dextools/blob/master/parseapk/parse_apk.py (see also [An Android Package is no Longer a ZIP](https://www.fortinet.com/blog/threat-research/an-android-package-is-no-longer-a-zip) )
