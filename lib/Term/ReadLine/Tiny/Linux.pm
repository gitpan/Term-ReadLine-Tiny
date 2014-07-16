package # hide from PAUSE
Term::ReadLine::Tiny::Linux;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.002';

use Term::ReadKey qw( GetTerminalSize ReadKey ReadMode );



sub new {
    return bless {}, $_[0];
}


sub __set_mode {
    my ( $self ) = @_;
    ReadMode( 'cbreak' );
};


sub __reset_mode {
    my ( $self ) = @_;
    ReadMode( 'restore' );
}


sub __term_buff_width {
    my ( $self, $handle_out ) = @_;
    my ( $term_width ) = GetTerminalSize();
    return $term_width;
}


sub __get_key {
    my ( $self ) = @_;
    return ReadKey( 0 );
}


sub __flush_input {
    my ( $self ) = @_;
    my $key;
    while ( defined( $key = ReadKey( -1 ) ) ) {
    }
}


1;

__END__
