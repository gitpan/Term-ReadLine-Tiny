use 5.008000;
use warnings;
use strict;
use Test::More;
use Test::Fatal;
use Term::ReadLine::Tiny;


subtest 'config_valid_arg', sub {
    my $valid_values = {
        default => [ 'string', '' ],
        no_echo => [ 0, 1, 2 ],
        compat  => [ 0, 1 ],
        reinit_encoding => [ 'cp65001', 'encoding(UTF-8)' ],
    };

    my $new = Term::ReadLine::Tiny->new( 'name' );

    for my $opt ( sort keys %$valid_values ) {
        for my $val ( @{$valid_values->{$opt}}, undef ) {
            my $exception = exception { $new->config( { $opt => $val } ) };
            my $value = ! defined $val ? 'undef' : $val;
            ok( ! defined $exception, "\$new->config( { $opt => $value } )" );
        }
    }
    my $exception;

    my $mixed_1 = { default => 'blue', no_echo => 0, compat => 1, reinit_encoding => 'cp65001' };
    $exception = exception { $new->config( $mixed_1 ) };
    ok( ! defined $exception, "\$new->config( { %$mixed_1 } )" );

    my $mixed_2 = { reinit_encoding => undef, compat => 0, no_echo => 1,  default => 'green' };
    $exception = exception { $new->config( $mixed_2 ) };
    ok( ! defined $exception, "\$new->config( { %$mixed_2 } )" );

    done_testing();
};


subtest 'config_invalid_arg', sub {
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

    done_testing();
};


done_testing();
