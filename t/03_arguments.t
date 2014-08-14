use 5.010000;
use warnings;
use strict;
use utf8;
use Test::More;
use Test::Fatal;

if( Test::Builder->VERSION < 2 ) {
    for my $method ( qw( output failure_output todo_output ) ) {
        binmode Test::More->builder->$method(), ':encoding(UTF-8)';
    }
}

use Term::ReadLine::Tiny;

{
    my $new;
    my $exception = exception { $new = Term::ReadLine::Tiny->new() };
    ok( ! defined $exception, '$new = Term::ReadLine::Tiny->new()' );
    ok( $new, '$new = Term::ReadLine::Tiny->new()' );
}

{
    my $new;
    my $exception = exception { $new = Term::ReadLine::Tiny->new( 'name' ) };
    ok( ! defined $exception, '$new = Term::ReadLine::Tiny->new( "name" )' );
    ok( $new, '$new = Term::ReadLine::Tiny->new( "name" )' );
}



my $valid_values = {
    default => [ 'string', "\x{263a}\x{263b}" ],
    no_echo => [ 0, 1, 2 ],
    compat  => [ 0, 1 ],
    reinit_encoding => [ 'cp65001', 'encoding(UTF-8)' ],
};

for my $opt ( sort keys %$valid_values ) {
    for my $val ( @{$valid_values->{$opt}}, undef ) {
        my $new = Term::ReadLine::Tiny->new( 'name' );
        my $exception = exception { $new->config( { $opt => $val } ) };
        ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )" );
    }
}

{
    my $new = Term::ReadLine::Tiny->new( 'name' );
    my $mixed_1 = { default => 'blue', no_echo => 0, compat => 0, reinit_encoding => undef };
    my $exception = exception { $new->config( $mixed_1 ) };
    ok( ! defined $exception, "\$new->config( { %$mixed_1 } )" );
}


{
    my $new = Term::ReadLine::Tiny->new( 'name' );
    my $mixed_2 = { reinit_encoding => 'encoding(UTF-8)', compat => 1, no_echo => 1,  default => "\x{842c}\x{91cc}\x{9577}\x{57ce}" };
    my $exception = exception { $new->config( $mixed_2 ) };
    ok( ! defined $exception, "\$new->config( { %$mixed_2 } )" );
}


done_testing();
