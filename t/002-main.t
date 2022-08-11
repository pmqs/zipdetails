
use strict;
use warnings;

use Cwd;
use Test::More ;
use Data::Dumper ;
use File::Temp qw( tempdir);
use File::Basename;
use File::Find;

plan tests => 42 * 10 ;

sub run;

my $HERE = getcwd;

my $Inc = join " ", map qq["-I$_"] => @INC;
$Inc = '"-MExtUtils::testlib"'
    if ! $ENV{PERL_CORE} && eval " require ExtUtils::testlib; " ;

my $Perl = ($ENV{'FULLPERL'} or $^X or 'perl') ;
$Perl = qq["$Perl"] if $^O eq 'MSWin32' ;

my $tempdir = tempdir(CLEANUP => 1);

my %dirs;
my $exts = join "|",  qw( zip zipx saz xlsx docx jar par tar war apk xpi) ;
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
    my $z = $dirs{$dir};
    for my $opt ('', '-v')
    {
        my $zipfile = "$dir/$z";

        if ($z =~ /tar$/)
        {
            chdir $tempdir
                or die "cannot chdir: $!\n";
            system("tar xf $HERE/$dir/$z") == 0
                or die "cannot untar";

            $zipfile = $tempdir . '/' . $z;
            $zipfile =~ s/\.tar$//;

            chdir $HERE
                or die "cannot chdir: $!\n";
        }

        die "No zip file '$z' '$zipfile' in '$dir'"
            if ! -e $zipfile;

        diag "testing $dir/" . basename($zipfile) . " $opt";

        my $golden_stdout_file = "$dir/stdout$opt";
        my $golden_stderr_file = "$dir/stderr$opt";

        my $golden_stdout = readFile($golden_stdout_file);
        my $golden_stderr = '';
        $golden_stderr = readFile($golden_stderr_file)
            if -e $golden_stderr_file ;

        my ($status, $stdout, $stderr) = run $zipfile, $opt, $golden_stdout_file, $golden_stderr_file ;

        my $ok = 1;
        $ok &= is $status, 0, "Exit Status 0";
        $ok &= is $stdout, $golden_stdout, "Expected stdout";
        $ok &= is $stderr, $golden_stderr, "Expected stderr";

        push @failed, $dir
            unless $ok;

        unlink <$tempdir/*> ;
    }
}

if (@failed)
{
    diag "Failed tests are" ;
    diag "  $_" for @failed;
}

exit;

sub run
{
    my $filename = shift ;
    my $opt = shift ;
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

    my $got = system("$Perl ./bin/zipdetails --utc $opt $filename >$stdout 2>$stderr");
    my $out = readFile($stdout);
    my $err = readFile($stderr);

    # normalise EOL
    $out =~ s/\r\n/\n/g;
    $err =~ s/\r\n/\n/g;

    unlink $stdout, $stderr
        unless $keep;

    return ($got, $out, $err) ;
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