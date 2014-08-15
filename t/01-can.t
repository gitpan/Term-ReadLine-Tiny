use 5.010000;
use strict;
use warnings;
use Test::More;
use Term::ReadLine::Tiny;

my $package = 'Term::ReadLine::Tiny';

ok( $package->can( 'VERSION' ), "$package can 'VERSION'" );

my $v;
ok( $v = $package->VERSION, "$package VERSION is '$v'" );

done_testing;
