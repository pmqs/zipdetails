perl -MIO::Compress::Zip=:all -e 'zip \"abcde"  => "test.zip", Name => "filename", Stream => 0, Method => 0, ExtraFieldLocal => ["ux" => "\x02\x00\x00"], ExtraFieldCentral => ["ux" => "\x03\x00\x00"]';