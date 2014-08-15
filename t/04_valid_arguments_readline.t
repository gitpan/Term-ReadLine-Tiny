use 5.010000;
use warnings;
use strict;
use Test::More;
use Encode                qw( decode );
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

eval "use Expect";
if ( $@ ) {
    plan skip_all => "Expect required for $0.";
}

use lib $RealBin;
use Data_Test_Arguments;

my $command = $^X;
my $script = catfile $RealBin, 'readline_valid_args.pl';
eval { -r $script or die "$script is NOT readable" } or plan skip_all => $@;

if( Test::Builder->VERSION < 2 ) {
    binmode Test::More->builder->output(), ':encoding(UTF-8)';
    binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';
}

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->clone_winsize_from( \*STDIN );
my @parameters  = ( $script );
$exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

my $a_ref = Data_Test_Arguments::valid_args();

for my $ref ( @$a_ref ) {
    my $expected = $ref->{expected};

    $exp->send( "\n" );
    my $ret = $exp->expect( 2, [ qr/<.*>/ ] );

    ok( $ret, 'matched something' );
    my $result = decode( 'utf8', $exp->match() // '' );
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}

$exp->hard_close();


done_testing();
