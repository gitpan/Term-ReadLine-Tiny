use 5.010000;
use warnings;
use strict;
use Test::More;
use Encode;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );
binmode STDOUT, ':utf8';

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: no escape sequences.";
    }
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib $RealBin;
use Data_Test_Readline;

my $command = $^X;
my $key = Data_Test_Readline::key_seq();
my $a_ref = Data_Test_Readline::return_test_data();


subtest 'readline', sub {
    my $readline_pl = catfile $RealBin, 'readline.pl';
    my @parameters = ( $readline_pl );

    if( Test::Builder->VERSION < 2 ) {
        binmode Test::More->builder->output(), ':encoding(UTF-8)';
        binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';
    }

    my $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->clone_winsize_from( \*STDIN );
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

    for my $ref ( @$a_ref ) {
        my $pressed_keys = $ref->{used_keys};
        my $expected     = $ref->{expected};

        my @seq;
        for my $k ( @$pressed_keys ) {
            push @seq, exists $key->{$k} ? $key->{$k} : $k;
        }
        $exp->send( @seq );
        my $ret = $exp->expect( 2, [ qr/<.*>/ ] );
        my $result = decode( 'utf8', $exp->match() // '' );

        ok( $ret, 'matched something' );
        ok( $result eq $expected, "expected: '$expected', got: '$result'" );

    }
    $exp->hard_close();

    done_testing();
};


subtest 'readline_compat', sub {
    my $compat_readline_pl = catfile $RealBin, 'compat_readline.pl';
    my @parameters = ( $compat_readline_pl );

    if( Test::Builder->VERSION < 2 ) {
        binmode Test::More->builder->output(), ':encoding(UTF-8)';
        binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';
    }

    my $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->clone_winsize_from( \*STDIN );
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

    for my $ref ( @$a_ref ) {
        my $pressed_keys = $ref->{used_keys};
        my $expected     = encode( 'utf8', $ref->{expected} );

        my @seq;
        for my $k ( @$pressed_keys ) {
            push @seq, exists $key->{$k} ? $key->{$k} : $k;
        }
        $exp->send( @seq );
        my $ret = $exp->expect( 2, [ qr/<.*>/ ] );
        my $result = decode( 'utf8', $exp->match() // '' );

        ok( $ret, 'matched something' );
        ok( $result eq $expected, "expected: '$expected', got: '$result'" );

    }
    $exp->hard_close();

    done_testing();
};



subtest 'env_readline_compat', sub {
    my $env_compat_readline_pl = catfile $RealBin, 'env_compat_readline.pl';
    my @parameters = ( $env_compat_readline_pl );

    if( Test::Builder->VERSION < 2 ) {
        binmode Test::More->builder->output(), ':encoding(UTF-8)';
        binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';
    }

    my $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->clone_winsize_from( \*STDIN );
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

    for my $ref ( @$a_ref ) {
        my $pressed_keys = $ref->{used_keys};
        my $expected     = encode( 'utf8', $ref->{expected} );

        my @seq;
        for my $k ( @$pressed_keys ) {
            push @seq, exists $key->{$k} ? $key->{$k} : $k;
        }
        $exp->send( @seq );
        my $ret = $exp->expect( 2, [ qr/<.*>/ ] );
        my $result = decode( 'utf8', $exp->match() // '' );

        ok( $ret, 'matched something' );
        ok( $result eq $expected, "expected: '$expected', got: '$result'" );

    }
    $exp->hard_close();

    done_testing();
};



done_testing();
