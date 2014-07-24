package # hide from PAUSE
Term::ReadLine::Tiny::Linux;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.003';

use Term::ReadKey qw( GetTerminalSize ReadKey ReadMode );

use Term::ReadLine::Tiny::Constants qw( :linux );


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
    my ( $self ) = @_;
    my ( $term_width ) = GetTerminalSize();
    return $term_width;
}


sub __get_key {
    my ( $self ) = @_;
    my $key = ReadKey( 0 );
    return if ! defined $key;
    if ( $key eq "\e" ) {
        my @chars = ( $key );
        while ( my $char = ReadKey( -1 ) ) {
            push @chars, $char;
        }
        if ( @chars == 1 ) {
            while ( my $char = ReadKey( 1 ) ) {
                push @chars, $char;
                last if @chars == 3;
            }
        }
        if ( @chars == 3 ) {
            if ( $chars[1] eq '[' ) {
                   if ( $chars[2] eq 'C' ) { return VK_RIGHT }
                elsif ( $chars[2] eq 'D' ) { return VK_LEFT  }
                elsif ( $chars[2] eq 'F' ) { return VK_END   }
                elsif ( $chars[2] eq 'H' ) { return VK_HOME  }
                else {
                    return  NEXT_get_key;
                }
            }
            else {
                return NEXT_get_key;
            }
        }
        elsif ( @chars == 4 ) {
            if ( $chars[3] ne '~' ) {
                return;
            }
            if ( $chars[1] eq '[' ) {
                   if ( $chars[2] eq '1' ) { return VK_HOME   }
                elsif ( $chars[2] eq '3' ) { return VK_DELETE }
                elsif ( $chars[2] eq '4' ) { return VK_END    }
                else {
                    return  NEXT_get_key;
                }
            }
            else {
                return NEXT_get_key;
            }
        }
        else {
            return NEXT_get_key;
        }
    }
    return ord $key;
}



1;

__END__
