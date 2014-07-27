use 5.010001;
use warnings;
use strict;
use ExtUtils::MakeMaker;


my %prereqs_os_specific;
if ( $^O eq 'MSWin32' ) {
    %prereqs_os_specific = (
        'Win32::Console'       => 0,
        'Win32::Console::ANSI' => 0,
    );
}
else {
    %prereqs_os_specific = (
        'Term::ReadKey'        => 0,
    );
}


WriteMakefile(
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.010001',
    LICENSE          => 'perl',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
              type => 'git',
              web  => 'https://github.com/kuerbis/Term-ReadLine::Tiny',
              url  => 'https://github.com/kuerbis/Term-ReadLine::Tiny.git',
            },
        },
    },
    AUTHOR           => 'Matthaeus Kiem <cuer2s@gmail.com>',
    NAME             => 'Term::ReadLine::Tiny',
    ABSTRACT_FROM    => 'lib/Term/ReadLine/Tiny.pm',
    VERSION_FROM     => 'lib/Term/ReadLine/Tiny.pm',
    EXE_FILES        => [],
    BUILD_REQUIRES   => {
        'Test::More'        => 0,
    },
    PREREQ_PM => {
        'strict'            => 0,
        'warnings'          => 0,
        'Carp'              => 0,
        'Encode'            => 0,
        'Encode::Locale'    => 0,
        'Exporter'          => 0,
        'Unicode::GCString' => 0,
        %prereqs_os_specific,
    },
    dist  => {
        COMPRESS => 'gzip',
        SUFFIX   => '.gz',
        TARFLAGS => '--format=gnu -cvf',
    },
    clean => {
        FILES => 'Term-ReadLine-Tiny-*',
    },
);