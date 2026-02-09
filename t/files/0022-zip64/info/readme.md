Create a zip file that has ZIP64 extra fields that should not be present

perl -MIO::Compress::Zip=:all -e '$extra = pack "Q<Q<Q<V",4,4,0,0;  zip \"abcd" => "test.zip", Name => "entry", Zip64 => 0, ExtraFieldCentr
al => [["\x1\x0" => $extra]], ExtraFieldLocal => [["\x1\x0" => $extra]], Stream => 0, method => 0  or die ; '