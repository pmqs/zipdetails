# trailing data after digext

perl -MIO::Compress::Zip=:all -e 'zip \"abc" => "test.zip", Name => "filename", Stream => 0, Method => 0, ExtraFieldLocal => ["\x51\x1A" => "\x0A\x00\x02\x00\x01\x02\x03"], ExtraFieldCentral => ["\x51\x1A" => "\x0A\x00\x02\x00\x01\x02\x03"]'