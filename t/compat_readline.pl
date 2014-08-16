#!/usr/bin/env perl
use warnings;
use strict;
use 5.010000;
binmode STDOUT, ':utf8';
binmode STDIN, ':utf8';

use Term::ReadLine::Tiny;

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Readline;

my $a_ref  = Data_Test_Readline::return_test_data();

my $tiny = Term::ReadLine::Tiny->new();
$tiny->config( { compat => 1 } );

for my $ref ( @$a_ref ) {
    my $args  = $ref->{arguments};

    my $line = $tiny->readline( @$args );
    say "<$line>";
}
