use 5.008000;
use strict;
use warnings;
use Test::More;
use Term::ReadLine::Tiny;

my $package = 'Term::ReadLine::Tiny';

ok( $package->ReadLine() eq 'Term::ReadLine::Tiny', "$package->ReadLine() eq 'Term::ReadLine::Tiny'" );

my $new;
ok( $new = $package->new( 'name' ), "$package->new( 'name' )" );

my $features;
ok( ref( $features = $new->Features() ) eq 'HASH', "ref( \$new->Features() ) is 'HASH'" );
ok( $features->{no_features} == 1, "Features: 'no_features' == 1" );


ok( ref( my $attributes = $new->Attribs() ) eq 'HASH', "ref( \$new->Attribs() ) is 'HASH'" );

ok( ! defined( my $out         = $new->OUT() ),        "\$new->OUT() ) returns nothing" );
ok( ! defined( my $in          = $new->IN() ),         "\$new->IN() ) returns nothing" );
ok( ! defined( my $min_line    = $new->MinLine() ),    "\$new->MinLine() returns nothing" );
ok( ! defined( my $add_history = $new->addhistory() ), "\$new->addhistory() returns nothing" );
ok( ! defined( my $ornaments   = $new->ornaments() ),  "\$new->ornaments() returns nothing" );


done_testing;
