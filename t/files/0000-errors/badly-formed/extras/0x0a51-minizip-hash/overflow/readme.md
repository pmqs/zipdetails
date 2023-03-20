# digest size too big

perl -MIO::Compress::Zip=:all -e 'zip \"abc" => "test.zip", Name => "filename", Stream => 0, Zip64 => 1, Method => 0'