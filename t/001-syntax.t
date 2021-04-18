
use strict;
use warnings;

use Cwd;
use Test::More ;
use Data::Dumper ;
use File::Temp qw( tempdir);

plan tests => 1 ;


my $Inc = join " ", map qq["-I$_"] => @INC;
$Inc = '"-MExtUtils::testlib"'
    if ! $ENV{PERL_CORE} && eval " require ExtUtils::testlib; " ;

my $Perl = ($ENV{'FULLPERL'} or $^X or 'perl') ;
$Perl = qq["$Perl"] if $^O eq 'MSWin32' ;

$Perl = "$Perl -w" ;

my $tempdir = tempdir(CLEANUP => 1);
my $stdout = "$tempdir/stdout";
my $stderr = "$tempdir/stderr";

my $got = system("$Perl -c ./bin/zipdetails >$stdout 2>$stderr");
my $out = readFile($stdout);
my $err = readFile($stderr);

is $got, 0, "Syntax ok"
    or diag <<EOM;
STATUS [$got]
STDOUT [$out]
STDERR [$err]
EOM

exit;


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