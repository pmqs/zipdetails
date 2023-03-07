

perl -MIO::Compress::Zip=:all -e 'zip \"abcd" => "test.zip", Name => "", zip64 => 0, minimal=>1, stream= > 0, Method => 0 or die '