#! perl -w

use strict ;
require 5.010 ;

use ExtUtils::MakeMaker 5.16 ;

WriteMakefile(
    NAME            => 'zipdetails',
    VERSION         => '2.01',
    PREREQ_PM       => { 'Getopt::Long' => 0,
		                 'IO::File'     => 0,
                         'Encode'       => 0,
		                },
    ABSTRACT        => 'Display details about the internal structure of Zip files',
    AUTHOR          => 'Paul Marquess <pmqs@cpan.org>',
    EXE_FILES       => ['bin/zipdetails'],

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


# sub MY::postamble
# {
#     return ''
#         if $ENV{PERL_CORE} ;

#     my @files = getPerlFiles('MANIFEST');

#     # Note: Once you remove all the layers of shell/makefile escaping
#     # the regular expression below reads
#     #
#     #    /^\s*local\s*\(\s*\$^W\s*\)/
#     #
#     my $postamble = '

# MyTrebleCheck:
# 	@echo Checking for $$^W in files: '. "@files" . '
# 	perl -ne \'						\
# 	    exit 1 if /^\s*local\s*\(\s*\$$\^W\s*\)/; \'		\
#          ' . " @files || " . '				\
# 	(echo found unexpected $$^W ; exit 1)
# 	@echo All is ok.

# ';

#     return $postamble;
# }

# end of file Makefile.PL
