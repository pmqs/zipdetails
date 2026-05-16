use strict;
use warnings;

use IO::Compress::Zip qw(:all);

# Create zip files with a range of uid/gid sizes

sub hexDump
{
    return uc join ' ', unpack('(H2)*', $_[0]);
}

sub packID
{
    my $byte_count = shift;
    my $value = shift;

    return pack "C", 0
        if $byte_count == 0;

    my %lookup = (
        1 => 'C',
        2 => 'v',
        4 => 'V',
        8 => 'Q<',
    );


    # die "bad length $byte_count\n"
    #     if ! $lookup{$byte_count} ;

    my $packed ;
    $packed  = pack "C", $byte_count;
    if ($lookup{$byte_count})
    {
        $packed .= pack($lookup{$byte_count}, $value);
    }
    else
    {
        # invalid length, so just store th ebyte count
        $packed .= pack("C", $byte_count) x $byte_count;
    }


    # print "Packing $byte_count => $value -> " . hexDump($packed) . "\n";

    return $packed;
}

sub createZip
{
    my $filename = shift;
    my $byte_count = shift;

    my $UID = packID($byte_count, 0x1234) ;
    my $GID = packID($byte_count, 0x2456) ;

    my $uxData = pack "C", 1 ;#      #  version
    $uxData .= $UID . $GID;

    zip \"abcd" => $filename,
            Name    => "test",
            Minimal => 0,
            Stream => 0,
            ExtraFieldLocal   => ['ux', $uxData],
            ExtraFieldCentral => ['ux', $uxData]
    or die "xxx $ZipError";

    print "Created $filename\n";
}

createZip("ux-0.zip", 0);
createZip("ux-1.zip", 1);
createZip("ux-2.zip", 2);
createZip("ux-3.zip", 3);
createZip("ux-4.zip", 4);
createZip("ux-5.zip", 5);
createZip("ux-6.zip", 6);
createZip("ux-7.zip", 7);
createZip("ux-8.zip", 8);
createZip("ux-9.zip", 9);
createZip("ux-256.zip", 0xff);

# my $filename = "ux.zip";
# my $UID = packID(8, 0x1234) ;
# my $GID = packID(8, 0x2456) ;
#
# my $uxData = pack "C", 1 ;#      #  version
# $uxData .= $UID . $GID;
#
# zip \"abcd" => "ux.zip",
#         Name    => "test",
#         Minimal => 0,
#         ExtraFieldLocal   => ['ux', $uxData],
#         ExtraFieldCentral => ['ux', $uxData]
# or die "xxx $ZipError";
