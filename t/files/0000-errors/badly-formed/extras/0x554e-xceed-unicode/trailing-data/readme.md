# trailing data

# NUCX

NUCX
\x04\x00
freddy

NUCX
\x04\x00
\x00\x00
freddy

perl -MEncode -MIO::Compress::Zip=:all -e 'zip \"abc" => "test.zip", Name => "filename", Stream => 0, Method => 0, ExtraFieldLocal => ["NU" => "NUCX" . "\x04\x00" . encode("UTF16LE", "freddy")], ExtraFieldCentral => ["NU" => "NUCX" . "\x04\x00" . "\x00\x00" . encode("UTF16LE", "freddy")]'