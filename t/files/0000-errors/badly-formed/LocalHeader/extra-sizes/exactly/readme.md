

perl -MIO::Compress::Zip=:all -e 'zip \"abcde"  => "test.zip", Name => "filename", Stream => 0, Method => 0, ExtraFieldLocal => ["\x03\x99" => ""]'
