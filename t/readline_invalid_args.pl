#!/usr/bin/env perl
use strict;
use warnings;
use 5.010000;

use Term::ReadLine::Tiny;

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Arguments;

my $tiny  = Term::ReadLine::Tiny->new();
my $a_ref = Data_Test_Arguments::invalid_args();

for my $ref ( @$a_ref  ) {
    my $args = $ref->{args};
    eval {
        my $line = $tiny->readline( @$args );
        say "<$line>";
        1;
    }
    or do {
        my $error = $@;
        chomp $error;
        say "<$error>";
    }
}
