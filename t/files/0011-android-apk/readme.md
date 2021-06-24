# Android APK Files

See [Application Signing](https://source.android.com/security/apksigning) for APK signature scheme


## Small V2 APK file
`signed-release.apk` sourced from [ApkGolf](https://github.com/fractalwrench/ApkGolf) via https://issues.apache.org/jira/browse/COMPRESS-455

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

## Utilities

`parse_apk.py` sourced from https://github.com/cryptax/dextools/blob/master/parseapk/parse_apk.py (see also [An Android Package is no Longer a ZIP](https://www.fortinet.com/blog/threat-research/an-android-package-is-no-longer-a-zip) )
