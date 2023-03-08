# https://riptutorial.com/perl/example/18192/handling-invalid-utf-8

# test will set input-encoding to something other than utf8 to check that the efs bit overrides & assumes utf8

perl -MIO::Compress::Zip=:all -e 'zip \"abcd" => "test.zip", efs => 1, Minimal => 1, Stream => 0, Name => "\x{61}\x{E5}\x{61}"'