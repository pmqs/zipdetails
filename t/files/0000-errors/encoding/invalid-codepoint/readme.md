# 
# check that a UTF filename with an invalid codepoint is detected
# this will be trapped when using "utf-8-strict" when decoding in the code
# but not when "utf8" is used.

perl -MIO::Compress::Zip=:all -e 'zip \"abcd" => "test.zip", Minimal => 1, Stream => 0, efs =>1, Name => "\xFA\x80\xA0\x89\xB6" '

# codepoint 0x2020276 in UTF8 is
"\xFA\x80\xA0\x89\xB6" '

