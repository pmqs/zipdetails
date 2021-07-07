
zipalign home is https://developer.android.com/studio/command-line/zipalign


## Create test file

zip -X0 za.zip lorem.txt
zipalign -p 32 za.zip zipalign.zip
rm za.zip
