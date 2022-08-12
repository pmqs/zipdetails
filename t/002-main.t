
use strict;
use warnings;

use Cwd;
use Test::More ;
use Data::Dumper ;
use File::Temp qw( tempdir);
use File::Basename;
use File::Find;

my $tests_per_zip = 10;
plan tests => 43 * $tests_per_zip ;

sub run;

my $tempdir = tempdir(CLEANUP => 1);
my $HERE = getcwd;

my $BZIP2 = findBzip2();


my $Perl = ($ENV{'FULLPERL'} or $^X or 'perl') ;
$Perl = qq["$Perl"] if $^O eq 'MSWin32' ;

my %dirs;
my @exts = qw( zip zipx saz xlsx docx jar par tar war apk xpi) ;
my $exts = join "|",  @exts, map { "$_.bz2" } @exts ;
my %skip_dirs = map { $_ => 1} qw( t/files/0010-apache-commons-compress/commons-compress-1.20 ) ;
my @failed = ();

find(
        sub { $dirs{$File::Find::dir} = $_
                 if /\.($exts)$/i && ! $skip_dirs{ $File::Find::dir };
             },
             't/files'
    );

SKIP:
for my $dir (sort keys %dirs)
{
    SKIP:
    {
        my $z = $dirs{$dir};
        my $zipfile = "$dir/$z";

        if ($z =~ /bz2$/)
        {
            skip "BZIP2 not available for test $dir/" . basename($zipfile), $tests_per_zip
                if ! $BZIP2;

            chdir $tempdir
                or die "cannot chdir: $!\n";

            $zipfile = $tempdir . '/' . $z;
            $zipfile =~ s/\.bz2$//;

            system("$BZIP2 -d -c $HERE/$dir/$z >$zipfile") == 0
                or die "cannot bunzip2: $!\n";

            chdir $HERE
                or die "cannot chdir: $!\n";
        }

        die "No zip file '$z' '$zipfile' in '$dir'"
            if ! -e $zipfile;

        for my $opt ('', '-v')
        {
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

sub findBzip2
{
    # Check external bzip2 is available
    my $name  = $^O =~ /mswin/i ? 'bzip2.exe' : 'bzip2';
    my $split = $^O =~ /mswin/i ? ";" : ":";

    my $bzip2 ;
    for my $dir (reverse split $split, $ENV{PATH})
    {
        $bzip2 = File::Spec->catfile($dir,$name)
            if -x File::Spec->catfile($dir,$name)
    }

    # Handle spaces in path to bzip2
    $bzip2 =  qq["$bzip2"]
        if defined $bzip2 && $bzip2 =~ /\s/;

    return undef
        if ! ExternalBzip2Works($bzip2);

    return $bzip2 ;
}

sub ExternalBzip2Works
{
    my $bzip2 = shift ;

    my $outfile = $tempdir . '/testfile';

    my $content = qq {
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Ut tempus odio id
 dolor. Camelus perlus.  Larrius in lumen numen.  Dolor en quiquum filia
 est.  Quintus cenum parat.
};

    writeWithBzip2($bzip2, $outfile, $content)
        or return 0;

    my $got ;
    readWithBzip2($bzip2, $outfile, $got)
        or return 0;

    if ($content ne $got)
    {
        diag "Uncompressed content is wrong";
        return 0 ;
    }

    return 1 ;
}

sub readWithBzip2
{
    my $bzip2 = shift ;
    my $file = shift ;

    my $outfile = $tempdir . '/outfile';

    my $comp = "$bzip2 -d -c" ;

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

sub writeWithBzip2
{
    my $bzip2 = shift ;
    my $file = shift ;
    my $content = shift ;
    my $options = shift || '';

    my $infile = $tempdir . '/infile';

    writeFile($infile, $content);

    unlink $file ;
    my $comp = "$bzip2 -c $options $infile >$file" ;

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