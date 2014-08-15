use 5.010000;
use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok( 'Term::ReadLine::Tiny' ) or say 'Bail out!';
}

diag( "Testing Term::ReadLine::Tiny $Term::ReadLine::Tiny::VERSION, Perl $], $^X" );
