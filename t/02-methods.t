use 5.010001;
use strict;
use warnings;
use Test::More;
use Term::ReadLine::Tiny;

my $package = 'Term::ReadLine::Tiny';



ok( $package->ReadLine() eq 'Term::ReadLine::Tiny', "$package->ReadLine() eq 'Term::ReadLine::Tiny'" );

my $new;

ok( $new = $package->new( 'name' ), "$package->new( 'name' )" );

my $h_ref;
ok( ref( $h_ref = $new->Features() ) eq 'HASH', "ref( \$new->Features() ) is 'HASH'" );
ok( $h_ref->{no_features} == 1, "Features: 'no_features' == 1" );

ok( ref( $h_ref = $new->Attribs() ) eq 'HASH', "ref( \$new->Attribs() ) is 'HASH'" );

ok( ref( my $out = $new->OUT() ) eq 'GLOB', "ref( \$new->OUT() ) is 'GLOB'" );
ok( ref( my $in  = $new->IN() )  eq 'GLOB', "ref( \$new->IN() )  is 'GLOB'" );

ok( ! defined( my $ml = $new->MinLine() ),    "\$new->MinLine() returns nothing" );
ok( ! defined( my $ah = $new->addhistory() ), "\$new->addhistory() returns nothing" );
ok( ! defined( my $or = $new->ornaments() ),  "\$new->ornaments() returns nothing" );


done_testing;
