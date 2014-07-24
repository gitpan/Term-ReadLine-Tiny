package # hide from PAUSE
Term::ReadLine::Tiny::Constants;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.003';

use Exporter qw( import );

our @EXPORT_OK = qw(
        UP RIGHT LEFT LF CR
        BEEP CLEAR_SCREEN CLEAR_TO_END_OF_SCREEN
        SAVE_CURSOR_POSITION RESTORE_CURSOR_POSITION
        NEXT_get_key
        CONTROL_A CONTROL_B CONTROL_D CONTROL_E CONTROL_F CONTROL_H CONTROL_U KEY_BTAB KEY_TAB
        KEY_ENTER KEY_ESC KEY_Tilde KEY_BSPACE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
);

our %EXPORT_TAGS = (
    rl => [ qw(
        UP RIGHT LEFT LF CR
        BEEP CLEAR_SCREEN CLEAR_TO_END_OF_SCREEN
        SAVE_CURSOR_POSITION RESTORE_CURSOR_POSITION
        NEXT_get_key
        CONTROL_A CONTROL_B CONTROL_D CONTROL_E CONTROL_F CONTROL_H CONTROL_U KEY_BTAB KEY_TAB
        KEY_ENTER KEY_ESC KEY_Tilde KEY_BSPACE
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
    ) ],
    linux  => [ qw(
        NEXT_get_key
        KEY_BTAB KEY_ESC
        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
    ) ],
#    win32  => [ qw(
#        VK_END VK_HOME VK_LEFT VK_UP VK_RIGHT VK_DELETE
#    ) ]
);



sub UP                     () { "\e[A" }
sub RIGHT                  () { "\e[C" }
sub LEFT                   () { "\e[D" }
sub LF                     () { "\n" }
sub CR                     () { "\r" }

sub BEEP                   () { "\a" }
sub CLEAR_SCREEN           () { "\e[2J\e[1;1H" }
sub CLEAR_TO_END_OF_SCREEN () { "\e[0J" }

sub SAVE_CURSOR_POSITION    () { "\e[s" }
sub RESTORE_CURSOR_POSITION () { "\e[u" }


sub NEXT_get_key  () { -1 }

#sub CONTROL_SPACE () { 0x00 }
sub CONTROL_A     () { 0x01 }
sub CONTROL_B     () { 0x02 }
#sub CONTROL_C     () { 0x03 }
sub CONTROL_D     () { 0x04 }
sub CONTROL_E     () { 0x05 }
sub CONTROL_F     () { 0x06 }
sub CONTROL_H     () { 0x08 }
sub KEY_BTAB      () { 0x08 }
#sub CONTROL_I     () { 0x09 }
sub KEY_TAB       () { 0x09 }
sub KEY_ENTER     () { 0x0d }
sub CONTROL_U     () { 0x15 }
sub KEY_ESC       () { 0x1b }
#sub KEY_Tilde     () { 0x7e }
sub KEY_BSPACE    () { 0x7f }

#sub VK_PAGE_UP    () { 333 }
#sub VK_PAGE_DOWN  () { 334 }
sub VK_END        () { 335 }
sub VK_HOME       () { 336 }
sub VK_LEFT       () { 337 }
sub VK_UP         () { 338 }
sub VK_RIGHT      () { 339 }
#sub VK_DOWN       () { 340 }
#sub VK_INSERT     () { 345 }
sub VK_DELETE     () { 346 }



1;

__END__
