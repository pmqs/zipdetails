
perl -MIO::Compress::Zip=:all -e 'zip \"abcd" => "test.zip", Minimal => 1, Stream => 0, Name => ".."'