package # hide from PAUSE
Term::ReadLine::Tiny::Win32;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.004';

use Encode qw( decode );

use Encode::Locale       qw();
use Win32::Console       qw( STD_INPUT_HANDLE ENABLE_PROCESSED_INPUT
                             RIGHT_ALT_PRESSED LEFT_ALT_PRESSED RIGHT_CTRL_PRESSED LEFT_CTRL_PRESSED SHIFT_PRESSED );
use Win32::Console::ANSI qw( Cursor XYMax );

use Term::ReadLine::Tiny::Constants qw( :win32 );


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
    }
}


sub SHIFTED_MASK () {
      RIGHT_ALT_PRESSED
    | LEFT_ALT_PRESSED
    | RIGHT_CTRL_PRESSED
    | LEFT_CTRL_PRESSED
    | SHIFT_PRESSED
}

sub __get_key {
    my ( $self ) = @_;
    my @event = $self->{input}->Input;
    my $event_type = shift @event;
    return NEXT_get_key if ! defined $event_type;
    if ( $event_type == 1 ) {
        my ( $key_down, $repeat_count, $v_key_code, $v_scan_code, $char, $ctrl_key_state ) = @event;
        return NEXT_get_key if ! $key_down;
        if ( $char ) {
            return ord decode( 'console_in', chr( $char & 0xff ) );
        }
        else{
            if ( $ctrl_key_state & SHIFTED_MASK ) {
                return NEXT_get_key;
            }
            elsif ( $v_key_code == VK_CODE_END )    { return VK_END }
            elsif ( $v_key_code == VK_CODE_HOME )   { return VK_HOME }
            elsif ( $v_key_code == VK_CODE_LEFT )   { return VK_LEFT }
            elsif ( $v_key_code == VK_CODE_UP )     { return VK_UP }
            elsif ( $v_key_code == VK_CODE_RIGHT )  { return VK_RIGHT }
            elsif ( $v_key_code == VK_CODE_DELETE ) { return VK_DELETE }
            else {
                return NEXT_get_key;
            }
        }
    }
    else {
        return NEXT_get_key;
    }
}


sub __term_buff_width {
    my ( $self ) = @_;
    my ( $term_width ) = XYMax();
    return $term_width;
}


sub __get_cursor_row_position {
    my ( $self ) = @_;
    my ( $x, $y ) = Cursor();
    return $y;
}


sub __set_cursor_position {
    my ( $self, $row, $col ) = @_;
    Cursor( $col, $row );
}





1;

__END__
