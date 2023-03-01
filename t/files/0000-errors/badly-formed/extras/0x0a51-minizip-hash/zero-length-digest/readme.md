# create a zero length digest & unknown algorithm

perl -MIO::Compress::Zip=:all -e 'zip \"abc" => "test.zip", Name => "filename", Stream => 0, Method => 0, ExtraFieldLocal => ["\x51\x1A" => "\x44\x00\x00\x00"], ExtraFieldCentral => ["\x51\x1A" => "\x44\x00\x00\x00"]'