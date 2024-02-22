# create a streamed zip file with data before the zip file

Two variants

1. where the offsets in the zip file assumes the start of the zip file is at offest zero.
2. where the offsets in the zip file take the prefix data into account


```
echo abcd >prefix-and-streamed-zero.zip
perl -MIO::Compress::Zip=:all -e 'zip \"abcde" => "/tmp/z.zip", name => "fred", minimal =>1'
cat /tmp/z.zip >>prefix-and-streamed-zero.zip
```
