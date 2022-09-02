
use strict;
use warnings;

use Cwd;
use Test::More ;
use Data::Dumper ;
use File::Temp qw( tempdir);
use File::Basename;
use File::Find;

my $tests_per_zip = 5 * 2 * 3 ;
plan tests => 82 * $tests_per_zip ;

sub run;

my $tempdir = tempdir(CLEANUP => 1);
my $HERE = getcwd;

my $ZSTD = findZstd();


my $Perl = ($ENV{'FULLPERL'} or $^X or 'perl') ;
$Perl = qq["$Perl"] if $^O eq 'MSWin32' ;

my %dirs;
my @exts = qw( zip zipx saz xlsx docx jar par tar war apk xpi) ;
my $exts = join "|",  @exts, map { "$_.zst" } @exts ;
my %skip_dirs = map { $_ => 1} qw( t/files/0010-apache-commons-compress/commons-compress-1.20 ) ;
my @failed = ();

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

        if ($z =~ /zst$/)
        {
            skip "ZSTD not available for test $dir/" . basename($zipfile), $tests_per_zip
                if ! $ZSTD;

            chdir $tempdir
                or die "cannot chdir: $!\n";

            $zipfile = $tempdir . '/' . $z;
            $zipfile =~ s/\.zst$//;

            system("$ZSTD -d -o $zipfile $HERE/$dir/$z") == 0
                or die "cannot unzstd: $!\n";

            chdir $HERE
                or die "cannot chdir: $!\n";
        }

        die "No zip file '$z' '$zipfile' in '$dir'"
            if ! -e $zipfile;

        for my $opt1 ('', '-v')
        {
            for my $opt2 ('', '--scan', '--walk')
            {
                diag "Testing $dir/" . basename($zipfile) . " $opt1 $opt2";

                my $golden_stdout_file = getOutputFilename( $dir, 'stdout', $opt1, $opt2);
                my $golden_stderr_file = getOutputFilename( $dir, 'stderr', $opt1, $opt2);

                my $golden_stdout = readOutFile($golden_stdout_file);
                my $golden_stderr = readOutFile($golden_stderr_file);

                my ($status, $stdout, $stderr) = run $zipfile, $opt1, $opt2, $golden_stdout_file, $golden_stderr_file ;

                my $ok = 1;
                $ok &= is $status, 0, "Exit Status 0";
                $ok &= is $stdout, $golden_stdout, "Expected stdout";
                $ok &= is $stderr, $golden_stderr, "Expected stderr";

                push @failed, "$dir $opt1 $opt2"
                    unless $ok;
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

    if (! -e $basename && -e "$basename.zst")
    {
        return `$ZSTD -d -c $basename`;
    }
    if (-e $basename )
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

    my $got = system("$Perl ./bin/zipdetails --utc $opt1 $opt2 $filename >$stdout 2>$stderr");
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

    open (F, "<$f")
        or die "Cannot open $f: $!\n" ;

    binmode F;
    local $/;
    my $data = <F> ;

    # normalise EOL
    $data =~ s/\r\n/\n/g;
    close F ;

    return $data;
}

sub writeFile
{
    my $filename = shift;
    my $content = shift;

    open my $fh, '>', $filename;
    print $fh $content;
    close $fh;

}

sub getOutputFilename
{
    my $dir  = shift ;
    my $base = shift ;
    my $opt1 = shift ;
    my $opt2 = shift ;

    return "$dir/$base$opt1$opt2"
        if -e "$dir/$base$opt1$opt2";

    return "$dir/$base$opt1"
        if -e "$dir/$base$opt1";

    return "" ;
}
