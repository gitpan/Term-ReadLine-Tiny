use 5.008000;
use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok( 'Term::ReadLine::Tiny' ) or print "Bail out!\n";
}

diag( "Testing Term::ReadLine::Tiny $Term::ReadLine::Tiny::VERSION, Perl $], $^X" );
