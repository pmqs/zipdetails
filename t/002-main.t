
# Env variables
#
# ZIPDETAILS_TEST_MATCH         only run test that match regex
# ZIPDETAILS_TEST_KEEP_OUTPUT   keep the output from all tests
# ZIPDETAILS_TEST_DIFF          run "diff" if the output isn't correct
# ZIPDETAILS_TEST_REFRESH       refresh the stdout/stderr files
# ZIPDETAILS_COVERAGE           run Devel::NYTProf profiler

#
#  nytprofmerge --out nytprof.out `find -name \*nytprof.out`
#  nytprofhtml --open
#

use 5.010;

use strict;
use warnings;
use feature 'say';
use feature 'state';

use Cwd;
use Test::More ;
use Data::Dumper ;
use File::Temp qw( tempdir);
use File::Basename;
use File::Find;
use Fcntl qw(SEEK_SET);


my $tests_per_zip = 6  ;
my $tests_per_zip_full = $tests_per_zip * 2 * 3 * 2 ;
plan tests => 210 * $tests_per_zip_full ;

sub run;
sub compareWithGolden;

my $tempdir = tempdir(CLEANUP => 1);
my $HERE = getcwd;
my $zipdetails_binary = "$HERE/bin/zipdetails";

my $ZSTD = findZstd();


my $Perl = ($ENV{'FULLPERL'} or $^X or 'perl') ;
$Perl = qq["$Perl"] if $^O eq 'MSWin32' ;

my %dirs;
my @exts = qw(
   aar
    apk
    cbz
    crx
    dwf
    epub
    exe
    fmu
    ipa
    ja
    jar
    jmod
    kmz
    nupkg
    ods
    par
    rock
    saz
    usdz
    war
    whl
    wmz
    xpi
    zip
    zipx

    doc
    docx
    docm

    ppt
    pptx
    pptm

    xls
    xlsx
    xlsm
    ) ;

my $exts = join "|",  @exts, map { "$_.zst" } @exts ;
my %skip_dirs = map { $_ => 1} qw( t/files/0010-apache-commons-compress/commons-compress-1.20 ) ;
my @failed = ();

$ENV{ZIPDETAILS_TESTHARNESS} = 1 ;

my $COVERAGE = '';

if ($ENV{ZIPDETAILS_COVERAGE})
{
    $COVERAGE = '-d:NYTProf' ;
    $ENV{NYTPROF}  = "blocks=1";
}

find(
        sub { $dirs{$File::Find::dir} = $_
                 if /\.($exts)$/i && ! $skip_dirs{ $File::Find::dir };
             },
             't/files'
    );

for my $dir (sort keys %dirs)
{
    SKIP:
    {
        my $z = $dirs{$dir};
        my $zipfile = "$dir/$z";

        if (defined $ENV{ZIPDETAILS_TEST_MATCH})
        {
            # skip "Test '$dir' doesn't match ZIPDETAILS_TEST_MATCH/" . basename($zipfile), $tests_per_zip_full
            next
                unless $zipfile =~ /$ENV{ZIPDETAILS_TEST_MATCH}/;
        }

        # these tests fail - looks like a FORMAT issue
        skip "skipping", $tests_per_zip_full
            if $zipfile =~ m<0000-errors/encoding/bad-encode> && $] < 5.020;

        if ($z =~ /zst$/)
        {
            skip "ZSTD not available for test $dir/" . basename($zipfile), $tests_per_zip_full
                if ! $ZSTD;

            chdir $tempdir
                or die "cannot chdir: $!\n";

            $zipfile = $tempdir . '/' . $z;
            $zipfile =~ s/\.zst$//;

            system("$ZSTD -d -q -o $zipfile $HERE/$dir/$z") == 0
                or die "cannot unzstd: $!\n";

            chdir $HERE
                or die "cannot chdir: $!\n";
        }

        die "No zip file '$z' '$zipfile' in '$dir'"
            if ! -e $zipfile;

        my %controlData = parseControl($dir);

        # default options assume
        my $options = '--encoding utf8 --output-encoding utf8';

        if (-e "$dir/options" )
        {
            $options = readFile("$dir/options") ;
            $options =~ s/\n+/ /g;
        }

        # diag "OPTIONS [$options]";

        for my $opt1 ('', '-v')
        {
            for my $opt2 ('', '--scan', '--walk')
            {
                SKIP:
                for my $opt3 ('', '--redact')
                {
                    my $test = "$dir/" . basename($zipfile) . " $opt1 $opt2 $opt3";
                    diag "Testing $test" ;

                    my $ctlData = reconcileControl(\%controlData, $opt1, $opt2, $opt3);

                    my ($golden_stdout_name, $golden_stdout_file) = ($ctlData->{'stdout'}, "$dir/$ctlData->{stdout}");
                    my ($golden_stderr_name, $golden_stderr_file) = ($ctlData->{'stderr'}, "$dir/$ctlData->{stderr}");
                    my $exit_status = $ctlData->{'exit-status'};

                    my $golden_stdout = readOutFile($golden_stdout_file);
                    my $golden_stderr = readOutFile($golden_stderr_file);

                    zapGolden($golden_stdout);
                    zapGolden($golden_stderr);

                    if ($opt3 && $golden_stdout !~ /$opt3$/)
                    {
                        skip "No Redact test for " . basename($zipfile), $tests_per_zip;
                    }

                    my ($status, $stdout, $stderr) = run $zipfile, $opt1, $opt2, $options, $golden_stdout_file, $golden_stderr_file ;

                    my $ok = 1;
                    $ok &= is $status, $exit_status, "Exit Status is $exit_status [got $status] for '$test'";
                    $ok &= compareWithGolden  $golden_stdout_file, $stdout, $golden_stdout, "Expected stdout[$golden_stdout_name] for '$test'";
                    $ok &= compareWithGolden  $golden_stderr_file, $stderr, $golden_stderr, "Expected stderr[$golden_stderr_name] for '$test'";

                    $ok &= compareBytesWithZipFile($opt1, $opt2, $opt3, $zipfile, $stdout);

                    push @failed, "$dir $opt1 $opt2"
                        unless $ok;
                }
            }
        }

        unlink <$tempdir/*> ;
    }
}

if (@failed)
{
    diag "Failed tests are" ;
    diag "  $_" for @failed;
}

exit;

sub readOutFile
{
    my $basename = shift;

    return "" unless $basename;

    if (! -e $basename && -f "$basename.zst")
    {
        return `$ZSTD -d -c $basename`;
    }
    if (-f $basename )
    {
        return readFile($basename);
    }

    return "";
}

sub run
{
    my $filename = shift ;
    my $opt1 = shift ;
    my $opt2 = shift ;
    my $options = shift;
    my $stdout_golden = shift ;
    my $stderr_golden = shift ;

    my $keep = defined $ENV{ZIPDETAILS_TEST_KEEP_OUTPUT};
    my $stdout ;
    my $stderr ;

    if ($keep)
    {
        $stdout = $stdout_golden . ".got";
        $stderr = $stderr_golden . ".got";
    }
    else
    {
        $stdout = "$tempdir/stdout";
        $stderr = "$tempdir/stderr";
    }

    unlink $stdout
        if -e $stdout;

    unlink $stderr
        if -e $stderr;

    ok ! -e $stdout, "stdout file does not exist" ;
    ok ! -e $stderr, "stderr file does not exist" ;

    my $basename = basename($filename);
    # say "basename is $basename";
    my $dir = dirname($filename);

    my $here = getcwd;
    chdir $dir;

    local $ENV{NYTPROF} .= ":file=./" . basename($stdout_golden) . ".nytprof.out" ;

    # diag "RUN " . qq[$Perl $COVERAGE $zipdetails_binary --utc $opt1 $opt2 $options "$basename" >"$stdout" 2>"$stderr"];
    my $got = system(qq[$Perl $COVERAGE $zipdetails_binary --utc $opt1 $opt2 $options "$basename" >"$stdout" 2>"$stderr"]);

    chdir $here;

    $got = $? >>= 8;
    my $out = readFile($stdout);
    my $err = readFile($stderr);

    # normalise EOL
    $out =~ s/\r\n/\n/g;
    $err =~ s/\r\n/\n/g;

    unlink $stdout, $stderr
        unless $keep;

    return ($got, $out, $err) ;
}

sub findZstd
{
    # Check external Zstd is available
    my $name  = $^O =~ /mswin/i ? 'zstd.exe' : 'zstd';
    my $split = $^O =~ /mswin/i ? ";" : ":";

    my $zstd ;
    for my $dir (reverse split $split, $ENV{PATH})
    {
        $zstd = File::Spec->catfile($dir,$name)
            if -x File::Spec->catfile($dir,$name)
    }

    # Handle spaces in path to zstd
    $zstd =  qq["$zstd"]
        if defined $zstd && $zstd =~ /\s/;

    return undef
        if ! ExternalZstdWorks($zstd);

    return $zstd ;
}

sub ExternalZstdWorks
{
    my $zstd = shift ;

    my $outfile = $tempdir . '/testfile';

    my $content = qq {
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut tempus odio id
 dolor. Camelus perlus.  Larrius in lumen numen.  Dolor en quiquum filia
 est.  Quintus cenum parat.
};

    writeWithZstd($zstd, $outfile, $content)
        or return 0;

    my $got ;
    readWithZstd($zstd, $outfile, $got)
        or return 0;

    if ($content ne $got)
    {
        diag "Uncompressed content is wrong";
        return 0 ;
    }

    return 1 ;
}

sub readWithZstd
{
    my $zstd = shift ;
    my $file = shift ;

    my $outfile = $tempdir . '/outfile';

    my $comp = "$zstd --no-progress -d -c" ;

    if ( system("$comp $file >$outfile") == 0 )
    {
        $_[0] = readFile($outfile);
        unlink $file ;

        return 1
    }

    diag "'$comp' failed: \$?=$? \$!=$!";
    unlink $file ;

    return 0 ;
}

sub writeWithZstd
{
    my $zstd = shift ;
    my $file = shift ;
    my $content = shift ;
    my $options = shift || '';

    my $infile = $tempdir . '/infile';

    writeFile($infile, $content);

    unlink $file ;
    my $comp = "$zstd --no-progress -c $options $infile >$file" ;

    return 1
        if system($comp) == 0 ;

    diag "'$comp' failed: \$?=$? \$!=$!";
    return 0 ;
}

sub readFile
{
    my $f = shift ;

    open (F, "<", $f)
        or die "Cannot open '$f': $!\n" ;

    binmode F;
    my @strings = map { s/\r\n/\n/g ; $_ } # normalise EOL
                  <F> ;
    close F ;

    return @strings if wantarray ;
    return join "", @strings ;
}

sub writeFile
{
    my $filename = shift;
    my $content = shift;

    open my $fh, '>', $filename;
    print $fh $content;
    close $fh;

}

sub reconcileControl
{
    my $control = shift;
    my $opt1 = shift ;
    my $opt2 = shift ;
    my $opt3 = shift ;

    for my $name ("$opt1$opt2$opt3",
                  "$opt1$opt2",
                  "$opt1",
                  "",
        )
    {
        if ($control->{$name})
        {
            return $control->{$name};
        }
    }

    die "xxx"

}

# sub getOutputFilenameNew
# {
#     my $dir  = shift ;
#     my $base = shift ;
#     my $ctl = shift ;

#     return ("$base$opt1$opt2$opt3", "$dir/$base$opt1$opt2$opt3") ;
# }

sub getOutputFilename
{
    my $dir  = shift ;
    my $base = shift ;
    my $opt1 = shift ;
    my $opt2 = shift ;
    my $opt3 = shift ;

    return ("$base$opt1$opt2$opt3", "$dir/$base$opt1$opt2$opt3")
        if -e "$dir/$base$opt1$opt2$opt3";

    return  ("$base$opt1", "$dir/$base$opt1")
        if -e "$dir/$base$opt1";

    return ("", "") ;
}

sub getExitStatus
{
    my $dir  = shift ;
    my $opt1 = shift ;
    my $opt2 = shift ;
    my $opt3 = shift ;

    my %files = map { m/^(.+)=(\d+)$/ && $1 => $2 }
                <$dir/exit-status*>;

    for my $name ("$dir/exit-status$opt1$opt2$opt3",
                  "$dir/exit-status$opt1$opt2",
                  "$dir/exit-status$opt1",
                  "$dir/exit-status",
        )
    {
        return ($name, $files{$name})
            if exists $files{$name};
    }

    return ("default", 0) ;
}

sub compareWithGolden
{
    my $golden_filename = shift;
    my $got = shift;
    my $expected = shift;
    my $message = shift;

    my $ok;

    if($ENV{ZIPDETAILS_TEST_DIFF} && $got ne $expected)
    {
        writeFile("$tempdir/got", $got);
        writeFile("$tempdir/expected", $expected);
        my $diff =  `diff -u $tempdir/got $tempdir/expected`;
        $ok = $? == 0 ;
        ok $ok, $message ;

        diag $diff
            if ! $ok;
    }
    else
    {
        $ok = is $got, $expected, $message ;
    }

    refresh($golden_filename, $got);

    return $ok;
}

sub refresh
{
    my $filename = shift ;
    my $data = shift ;

    return if length $data == 0;

    return
        unless $ENV{ZIPDETAILS_TEST_REFRESH};

    diag "Refreshing $filename";

    my $zst = ($filename =~ s/.zst$//) ;

    writeFile($filename, $data);

    if ($zst)
    {
        system "zstd --rm $filename";
    }
}

sub compareBytesWithZipFile
{
    my $opt1 = shift ;
    my $opt2 = shift ;
    my $opt3 = shift ;
    my $filename = shift ;
    my $stdout = shift;

    if (! -f $filename)
    {
        ok 1, 'Not a standard file' ;
        return 1;
    }

    if ($opt1 ne '-v')
    {
        ok 1, 'Not Verbose' ;
        return 1;
    }

    # open my $in, '<', $stdout
    #     or die "Cannot open $stdout: $!\n";
    open my $fh, '<', $filename
        or die "Cannot open $filename: $!\n";

    binmode $fh ; # for windows
    my $hexValue = '(?: [[:xdigit:]] )+' ;
    my $hexByte  = '[[:xdigit:]] [[:xdigit:]]' ;

    my $offset = 0;
    my $offset_to = 0;
    my $count = 0;
    my $padding = 0;
    my @stdin = split "\n", $stdout;

    for (@stdin)
    {
        next if /^\s*$/ ;

        # substr($_, 21, -1, '');
        # s/\s+//;
        # $offset = substr($_, 0, 4) ;
        # $count  = substr($_, 4,) ;

        # say "LINE [$_]";
        if (/ ^ ( ( $hexValue ) \s+ ( $hexValue ) \s+ ( $hexValue ) ) ( (?: \s $hexByte ){1,4} )/x)
        {
            # Match this
            # 000000 000004 50 4B 03 04 LOCAL HEADER #1       04034B50
            # <=======================>

            $padding = length($1);

            # if (/UNEXPECTED PADDING/)
            # {
            #     next ;
            # }

            {
                # silence "Hexadecimal number > 0xffffffff non-portable"
                no warnings 'portable';

                $offset = hex($2) + 0;
                $offset_to = hex($3) + 0;
                $count = hex($4) + 0 ;
            }

            die "Offset-to $offset_to is wrong - should be " . ($offset + $count -1)
                if $offset + $count - 1 != $offset_to;

            my $valuesString = $5;
            $valuesString =~ s/\s+//g;
            my $binaryValue = pack "H*", $valuesString;
            my $len = length($binaryValue) ;
            # say sprintf "xxxx 0x%X $count $valuesString $len ", $offset;

            seek($fh, $offset, SEEK_SET)
                or die "Cannot seek to $offset: $!\n";
            read($fh, my $data, $len) == $len
                or die "Error reading $len bytes @ offset $offset: $!\n";
            $data eq $binaryValue
                or die sprintf "Binary mismatch in $filename, opt '$opt1 $opt2 $opt3' \@ 0x%X : Got[%s] Want[$valuesString]",
                        $offset,
                        unpack("H*", $data);

            $offset += length($binaryValue);

        }
        elsif (/ ^ \s{$padding} (  (?: \s ${hexByte} ){1,4} ) /x)
        {

            # Match this
            #               66 72 65 65
            #

            my $valuesString = $1;
            $valuesString =~ s/\s+//g;
            my $binaryValue = pack "H*", $valuesString;
            my $len = length($binaryValue) ;
            # say sprintf "yyyy 0x%X $count $valuesString $len ", $offset;

            seek($fh, $offset, SEEK_SET)
                or die "Cannot seek to $offset: $!\n";
            read($fh, my $data, $len) == $len
                or die "Error reading $len bytes @ offset $offset: $!\n";
            $data eq $binaryValue
                or die sprintf "Binary mismatch in $filename \@ 0x%X : Got[%s] Want[$valuesString]",
                        $offset,
                        unpack("H*", $data);

            $offset += length($binaryValue);

        }
    }

    ok 1, 'Bytes Match';
    return 1;
}

sub parseControl
{
    my $directory = shift;

    my $filename = "$directory/control";

    state $keywords = { map { $_ => 1}
                        qw( exit-status stdout stderr )
                      };

    return ( '' => {
                    'exit-status' => 0,
                    'stdout'      => 'stdout',
                    'stderr'      => '',
                    },
            '-v' => {
                    'exit-status' => 0,
                    'stdout'      => 'stdout-v',
                    'stderr'      => '',
                    }
            )
        if !-e $filename ;

    # default
    #     exit-status 0
    #     stdout      stdout
    #     stderr      NULL
    #
    # -v --walk
    #     exit-status 0
    #     stdout      stdout-v
    #     stderr      NULL
    #
    # -v --walk --redact
    #     same-as     -v --walk

    my @records ;
    my %results;

    {
        local $/ = ""; # paragraph mode

        open my $fh, '<', $filename
            or die "Cannot open '$filename': $!\n";

        @records = map { [ split "\n", $_ ] }
                   <$fh>;

        close $fh;
    }

    for my $record (@records)
    {
        my @lines = grep { ! /^\s*$/ && ! /^\s*#/ }
                    @$record;

        my $type = shift @lines;
        $type =~ s/\s+//g;
        $type = ''
            if lc $type eq 'default';

        for my $line (@lines)
        {
            next if $line =~ /^\s*$/;
            $line =~ /^\s*(\S+)\s+(.+)/;
            my $keyword = lc $1;
            my $value = $2;

            $value = ''
                if lc $value eq 'null';

            die "Invalid keyword '$keyword' in $filename\n"
                unless $keywords->{$keyword} ;

            $results{$type}{$keyword} = $value;
        }
    }

    return %results;

}


sub getNativeLocale
{
    state $enc;

    if (! $enc)
    {
        $enc = 'unknown';

        eval
        {
            require encoding ;
            my $encoding = encoding::_get_locale_encoding() // 'cp437';
            $enc = Encode::find_encoding($encoding) ;
        } ;

        $enc = $enc->name()
            if $enc;
    }

    return $enc;
}


sub getUTF8String
{
    state $string ;

    if (! defined $string)
    {
        use Encode;
        my $latin1 = "\x{61}\x{E5}\x{61}" ;
        eval { my $name = Encode::decode('utf8', $latin1, Encode::FB_CROAK) };

        $@ =~ /^(\S+) "\\xE5" does not map to Unicode/;

        $string = $1;
    }

    # warn "GOTT [$Perl][$]][$string]\n";
    return $string ;
}

sub zapGolden
{
    my $locale_charset = getNativeLocale();
    $_[0] =~ s<^(#\s*System Default Encoding:\s*)('.+?')><$1'$locale_charset'>mg ;

    # Encode changed from using utf8 to UTF-8 at some point
    my $UTF = getUTF8String();
    $_[0] =~ s<\S+ (\S+) does not map to Unicode><$UTF $1 does not map to Unicode>g ;
}