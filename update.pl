#!/usr/bin/perl

use strict;
use warnings;

no warnings 'portable';

my $hexValue = '(?: [[:xdigit:]] + )' ;
my $hexByte  = '[[:xdigit:]] [[:xdigit:]]' ;

my $offset = 0;
my $count = 0;
my $padding = 0;
my $width = 0;

while(<>)
{
    # if (/^([[:xdigit:]]+)\s+([[:xdigit:]]+)(.+)/x)
    # {
    #     my $from = hex $1;
    #     my $size = hex $2;
    #     my $rest = $3;

    #     my $width = length $1 ;

    #     my $to = sprintf "%0${width}X", $from + $size -1 ;

    #     print "$1 $to $2$rest\n";
    #     next;

    # }
    # elsif (/^(\s+)(.+)/)
    # {

    # }

    if (/ ^ ( ( $hexValue ) \s+ ( $hexValue ) ) ( .+ ) $/x)
    {
        # Match this
        # 000000 000004 50 4B 03 04 LOCAL HEADER #1       04034B50
        # <=======================>

        $padding = length($1) ;
        $width = length $2 ;        

        # if (/UNEXPECTED PADDING/)
        # {
        #     next ;
        # }

        {
            # silence "Hexadecimal number > 0xffffffff non-portable"
            no warnings 'portable';
            $offset = hex($2);
            $count = hex($3) ;
        }

        my $to = sprintf "%0${width}X", $offset + $count - 1 ;
        # say sprintf "xxxx 0x%X $count $valuesString $len ", $offset;
        print "$2 $to $3$4\n";

        next;
    }

    # elsif (/ ^ \s{$padding} (  (?: \s ${hexByte} ){1,4} ) /x)
    # {

    #     # Match this
    #     #               66 72 65 65
    #     #

    #     my $valuesString = $1;
    #     $valuesString =~ s/\s+//g;
    #     my $binaryValue = pack "H*", $valuesString;
    #     my $len = length($binaryValue) ;
    #     # say sprintf "yyyy 0x%X $count $valuesString $len ", $offset;


    # }  


    s/^ \s{$padding} /' ' x ($padding + $width + 1) /xe 
       unless /^\s*$/ ;

    print;
}