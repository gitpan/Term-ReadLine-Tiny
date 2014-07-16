package # hide from PAUSE
Term::ReadLine::Tiny::Win32;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.002';

use Win32::Console qw( STD_INPUT_HANDLE STD_OUTPUT_HANDLE ENABLE_PROCESSED_INPUT );



sub new {
    return bless {}, $_[0];
}


sub __set_mode {
    my ( $self ) = @_;
    $self->{input} = Win32::Console->new( STD_INPUT_HANDLE );
    $self->{old_in_mode} = $self->{input}->Mode();
    $self->{input}->Mode( ENABLE_PROCESSED_INPUT );
}


sub __reset_mode {
    my ( $self ) = @_;
    if ( defined $self->{input} ) {
        if ( defined $self->{old_in_mode} ) {
            $self->{input}->Mode( $self->{old_in_mode} );
            delete $self->{old_in_mode};
        }
        $self->{input}->Flush;
        # workaround Bug #33513:
        delete $self->{input}{handle};
        #$self->{input}{handle} = undef;
    }
}


sub __get_key {
    my ( $self ) = @_;
    return $self->{input}->InputChar();
}


sub __flush_input {
    my ( $self ) = @_;
}


sub __term_buff_width {
    my ( $self ) = @_;
    my ( $term_width ) = Win32::Console->new()->MaxWindow();
    return $term_width;
}



1;

__END__
