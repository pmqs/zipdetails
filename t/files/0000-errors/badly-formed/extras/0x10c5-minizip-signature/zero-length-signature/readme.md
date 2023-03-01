# create a zero length signature

perl -MIO::Compress::Zip=:all -e 'zip \"abc" => "test.zip", Name => "filename", Stream => 0, Method => 0, ExtraFieldLocal => ["\xC5\x10" => ""], ExtraFieldCentral => ["\xC5\x10" => ""]'