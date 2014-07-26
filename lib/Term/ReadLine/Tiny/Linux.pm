package # hide from PAUSE
Term::ReadLine::Tiny::Linux;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.004';

use Encode qw( decode );

use Encode::Locale qw();
use Term::ReadKey  qw( GetTerminalSize ReadKey ReadMode );

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
    my $c1 = ReadKey( 0 );
    return if ! defined $c1;
    if ( $c1 eq "\e" ) {
        my $c2 = ReadKey( 0.10 );
        if ( ! defined $c2 ) {
            return  NEXT_get_key; # KEY_ESC
        }
        elsif ( $c2 eq '[' ) {
            my $c3 = ReadKey( 0 );
               if ( $c3 eq 'C' ) { return VK_RIGHT; }
            elsif ( $c3 eq 'D' ) { return VK_LEFT; }
            elsif ( $c3 eq 'F' ) { return VK_END; }
            elsif ( $c3 eq 'H' ) { return VK_HOME; }
            elsif ( $c3 eq 'Z' ) { return KEY_BTAB; } #
            elsif ( $c3 =~ /^[0-9]$/ ) {
                my $c4 = ReadKey( 0 );
                if ( $c4 eq '~' ) {
                       if ( $c3 eq '1' ) { return VK_END; }
                    elsif ( $c3 eq '3' ) { return VK_DELETE; }
                    elsif ( $c3 eq '4' ) { return VK_HOME; }
                    else {
                        return NEXT_get_key;
                    }
                }
                elsif ( $c4 =~ /^[;0-9]$/ ) { # response to "\e[6n"
                    my $abs_curs_y = $c3;
                    my $ry = $c4;
                    while ( $ry =~ m/^[0-9]$/ ) {
                        $abs_curs_y .= $ry;
                        $ry = ReadKey( 0 );
                    }
                    return NEXT_get_key if $ry ne ';';
                    my $abs_curs_x = '';
                    my $rx = ReadKey( 0 );
                    while ( $rx =~ m/^[0-9]$/ ) {
                        $abs_curs_x .= $rx;
                        $rx = ReadKey( 0 );
                    }
                    if ( $rx eq 'R' ) {
                        #$self->{abs_cursor_x} = $abs_curs_x;
                        $self->{abs_cursor_y} = $abs_curs_y;
                    }
                    return NEXT_get_key;
                }
                else {
                    return NEXT_get_key;
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
    else {
        #return ord decode( 'console_in', $c1 ) if $^O eq 'MSWin32';
        return ord $c1;
    }
};


sub __get_cursor_row_position {
    my ( $self ) = @_;
    #$self->{abs_cursor_y} = 1;
    print GET_CURSOR_POSITION;
    my $dummy = $self->__get_key();
    return $self->{abs_cursor_y};
}

sub __set_cursor_position {
    my ( $self, $row, $col ) = @_;
    print "\e[${row};${col}H";
}


1;

__END__
