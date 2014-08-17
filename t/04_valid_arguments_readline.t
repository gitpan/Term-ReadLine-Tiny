use 5.010000;
use warnings;
use strict;
use Test::More;
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
my @parameters  = ( $script );

my $exp = Expect->new();
$exp->raw_pty( 1 );
$exp->log_stdout( 0 );
$exp->slave->clone_winsize_from( \*STDIN );
$exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";

my $a_ref = Data_Test_Arguments::valid_args();

for my $ref ( @$a_ref ) {
    my $expected = $ref->{expected};

    $exp->send( "\n" );
    my $ret = $exp->expect( 2, [ qr/<.*>/ ] );

    ok( $ret, 'matched something' );

    my $result = $exp->match() // '';
    ok( $result eq $expected, "expected: '$expected', got: '$result'" );
}

$exp->hard_close();


done_testing();