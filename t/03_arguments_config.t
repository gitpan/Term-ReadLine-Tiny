use 5.010000;
use warnings;
use strict;
use Test::More;
use Test::Fatal;
use Term::ReadLine::Tiny;


subtest 'config_valid_arg', sub {
    if( Test::Builder->VERSION < 2 ) {
        binmode Test::More->builder->output(), ':encoding(UTF-8)';
        binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';
    }

    my $valid_values = {
        default => [ 'string', "\x{263a}\x{263b}" ],
        no_echo => [ 0, 1, 2 ],
        compat  => [ 0, 1 ],
        reinit_encoding => [ 'cp65001', 'encoding(UTF-8)' ],
    };

    my $new = Term::ReadLine::Tiny->new( 'name' );

    for my $opt ( sort keys %$valid_values ) {
        for my $val ( @{$valid_values->{$opt}}, undef ) {
            my $exception = exception { $new->config( { $opt => $val } ) };
            ok( ! defined $exception, "\$new->config( { $opt => " . ( $val // 'undef' ) . " } )" );
        }
    }
    my $exception;

    my $mixed_1 = { default => 'blue', no_echo => 0, compat => 0, reinit_encoding => undef };
    $exception = exception { $new->config( $mixed_1 ) };
    ok( ! defined $exception, "\$new->config( { %$mixed_1 } )" );

    my $mixed_2 = { reinit_encoding => 'encoding(UTF-8)', compat => 1, no_echo => 1,  default => "\x{842c}\x{91cc}\x{9577}\x{57ce}" };
    $exception = exception { $new->config( $mixed_2 ) };
    ok( ! defined $exception, "\$new->config( { %$mixed_2 } )" );
};


subtest 'config_invalid_arg', sub {
    if( Test::Builder->VERSION < 2 ) {
        binmode Test::More->builder->output(), ':encoding(UTF-8)';
        binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';
    }

    my $invalid_values = {
        default => [ [], {} ],
        no_echo => [ -1, 3, [], {}, 'a' ],
        compat  => [ -1, 2, [], {}, 'a' ],
        reinit_encoding => [ {}, [] ],
    };

    my $new = Term::ReadLine::Tiny->new();

    for my $opt ( sort keys %$invalid_values ) {
        for my $val ( @{$invalid_values->{$opt}} ) {
            my $exception = exception { $new->config( { $opt => $val }  ) };
            ok( $exception =~ /config:/, "\$new->config( { $opt => $val } ) => $exception" );
        }
    }
    my $exception;

    my $mixed_invalid_1 = { reinit_encoding => 'encoding(UTF-8)', compat => -1, no_echo => 1,  default => 'Default' };
    $exception = exception { $new->config( $mixed_invalid_1  ) };
    ok( $exception =~ /config:/, "\$new->config( { %$mixed_invalid_1 } ) => $exception" );


    my $mixed_invalid_2 = { reinit_encoding => 'encoding(UTF-8)', compat => 1, no_echo => 1,  default => {} };
    $exception = exception { $new->config( $mixed_invalid_2 ) };
    ok( $exception =~ /config:/, "\$new->config( { %$mixed_invalid_2 } ) => $exception" );

};


done_testing();
