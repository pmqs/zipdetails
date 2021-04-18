
use strict;
use warnings;

use Cwd;
use Test::More ;
use Data::Dumper ;
use File::Temp qw( tempdir);
use File::Basename;
use File::Find;

plan tests => 20 * 10 ;

sub run;

my $HERE = getcwd;

my $Inc = join " ", map qq["-I$_"] => @INC;
$Inc = '"-MExtUtils::testlib"'
    if ! $ENV{PERL_CORE} && eval " require ExtUtils::testlib; " ;

my $Perl = ($ENV{'FULLPERL'} or $^X or 'perl') ;
$Perl = qq["$Perl"] if $^O eq 'MSWin32' ;

my $tempdir = tempdir(CLEANUP => 1);

my %dirs;
my $exts = join "|",  qw( zip zipx saz xlsx docx jar par tar war) ;
find(
        sub { $dirs{$File::Find::dir} = $_
                 if /\.($exts)$/;
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

        my $golden_stdout = readFile("$dir/stdout$opt");
        my $golden_stderr = '';
        $golden_stderr = readFile("$dir/stderr$opt")
            if -e "$dir/stderr$opt" ;

        my ($status, $stdout, $stderr) = run $zipfile, $opt ;

        is $status, 0, "Exit Status 0";
        is $stdout, $golden_stdout, "Expected stdout";
        is $stderr, $golden_stderr, "Expected stderr";

        unlink <$tempdir/*> ;
    }
}

exit;

sub run
{
    my $filename = shift ;
    my $opt = shift || "";

    my $stdout = "$tempdir/stdout";
    my $stderr = "$tempdir/stderr";

    unlink $stdout
        if -e $stdout;

    unlink $stderr
        if -e $stderr;

    ok ! -e $stdout, "stdout file does not exist" ;
    ok ! -e $stderr, "stderr file does not exist" ;

    my $got = system("$Perl ./bin/zipdetails --utc $opt $filename >$stdout 2>$stderr");
    my $out = readFile($stdout);
    my $err = readFile($stderr);

    unlink $stdout, $stderr;

    return ($got, $out, $err) ;
}

sub readFile
{
    my $f = shift ;

    my @strings ;

    {
        open (F, "<$f")
            or die "Cannot open $f: $!\n" ;
        binmode F;
        @strings = <F> ;
        close F ;
    }

    return @strings if wantarray ;
    return join "", @strings ;
}