#! perl

use strict ;
use warnings;
require 5.010 ;

use ExtUtils::MakeMaker 5.16 ;

# Check for a 32-bit Perl
if (!eval { pack "Q", 1 }) {
    warn "zipdetails requires 64 bit integers, ",
            "this Perl has 32 bit integers.\n";
    exit(1);
}

my %WriteMakefileArgs = (

    NAME            => 'App::zipdetails',
    VERSION_FROM    => 'lib/App/zipdetails.pm',

    PREREQ_PM       => { 'Getopt::Long' => 0,
		                 'IO::File'     => 0,
                         'Encode'       => 0,
                         'Fcntl'        => 0,
                         'Time::Local'  => 0,
		                },

    BUILD_REQUIRES    => { 'Cwd'            => 0,
                           'Test::More'     => 0,
                           'File::Temp'     => 0,
                           'File::Basename' => 0,
                           'Data::Dumper'   => 0,
                           'Pod::Markdown'  => 0
                        },

    ABSTRACT        => 'Display details about the internal structure of Zip files',
    AUTHOR          => 'Paul Marquess <pmqs@cpan.org>',
    LICENSE         => 'perl',
    EXE_FILES       => ['bin/zipdetails'],

    META_MERGE  => {

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
                },


    clean     => { FILES => "t/files/*.got t/files/*/*.got t/files/*/*/*.got" },
    depend    => { manifypods => 'READMEmd' },
) ;

delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION(6.30) } ;

delete $WriteMakefileArgs{META_MERGE}
    unless eval { ExtUtils::MakeMaker->VERSION(6.46) } ;

delete $WriteMakefileArgs{BUILD_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION(6.55_03) } ;

WriteMakefile(%WriteMakefileArgs);


sub MY::postamble
{
    my $postamble = '';

    if (-e '.github') {
        $postamble = <<EOM;

READMEmd: README.md

README.md: bin/zipdetails .github/badges
	\@echo Creating README.md from bin/zipdetails
	\$(NOECHO) \$(CHMOD) \$(PERM_RW) .github/badges README.md
	\$(NOECHO) \$(CP) .github/badges README.md
	\$(NOECHO) \$(ECHO) "" >> README.md
	\$(NOECHO) pod2markdown bin/zipdetails >>README.md

EOM
    }
    else {
        $postamble .= <<EOM;

READMEmd:

EOM
    }

    return $postamble;
}

# end of file Makefile.PL
