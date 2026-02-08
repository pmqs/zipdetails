# Windows Symlinks

Windows symbolic links/Junctions can reference directories.
This means the `zipdetails` needs to be careful not to emit a warning when these have a payload

## Files created

```
echo abcd >target
mkdir targetdir

mklink slink target
mklink /d  target linkd

# create a junction
mklink /j  slinkdir targetdir


>dir
...

07/02/2026  22:56    <SYMLINKD>     linkd [target]
07/02/2026  14:39    <SYMLINK>      slink [target]
07/02/2026  14:39    <JUNCTION>     slinkdir [C:\develop\iztest\scratch\sym\targetdir]
07/02/2026  14:37                 7 target
07/02/2026  14:39    <DIR>          targetdir

```

```
zip -y /tmp/za.zip slink slinkdir linkd

7za a -snl 7za.zip slink slinkdir linkd
tar caf bsdtar.zip linkd slink slinkdir
```