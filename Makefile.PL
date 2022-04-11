#! perl

use strict ;
use warnings;
require 5.010 ;

use ExtUtils::MakeMaker 5.16 ;

WriteMakefile(
    NAME            => 'App::zipdetails',
    VERSION         => '2.103',
    PREREQ_PM       => { 'Getopt::Long' => 0,
		                 'IO::File'     => 0,
                         'Encode'       => 0,
                         'Fcntl'        => 0,
		                },

     ( eval { ExtUtils::MakeMaker->VERSION(6.55_03) }
        ? ( BUILD_REQUIRES    => { 'Cwd'            => 0,
                                   'Test::More'     => 0,
                                   'File::Temp'     => 0,
                                   'File::Basename' => 0,
                                   'Data::Dumper'   => 0,
                                }
          )
        : ()
     ),

    ABSTRACT        => 'Display details about the internal structure of Zip files',
    AUTHOR          => 'Paul Marquess <pmqs@cpan.org>',
    EXE_FILES       => ['bin/zipdetails'],

    clean           => {FILES => "t/files/*.got t/files/*/*.got t/files/*/*/*.got" },

    ((ExtUtils::MakeMaker->VERSION() gt '6.30') ?
        ('LICENSE'  => 'perl')         : ()),

     ( eval { ExtUtils::MakeMaker->VERSION(6.46) }
        ? ( META_MERGE  => {

                "meta-spec" => { version => 2 },

                no_index => {
                    directory => [ 't' ],
                },

                resources   => {

                    bugtracker  => {
                        web     => 'https://github.com/pmqs/zipdetails/issues'
                    },

                    homepage    => 'https://github.com/pmqs/zipdetails',

                    repository  => {
                        type    => 'git',
                        url     => 'git://github.com/pmqs/zipdetails.git',
                        web     => 'https://github.com/pmqs/zipdetails',
                    },
                },
              }
            )
        : ()
    ),

) ;


# end of file Makefile.PL
