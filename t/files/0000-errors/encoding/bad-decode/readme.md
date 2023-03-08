# https://riptutorial.com/perl/example/18192/handling-invalid-utf-8

perl -MIO::Compress::Zip=:all -e 'zip \"abcd" => "test.zip", Minimal => 1, Stream => 0, Name => "\x{61}\x{E5}\x{61}"'