package Term::ReadLine::Tiny;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.003';

use Carp   qw( croak carp );
use Encode qw( encode decode );

use Encode::Locale    qw();
use Unicode::GCString qw();

use Term::ReadLine::Tiny::Constants qw( :rl );

my $Plugin_Package;

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        require Win32::Console::ANSI;
        if ( $ENV{READLINE_TINY_READKEY} ) { # undocumented
            require Term::ReadLine::Tiny::Linux;
            $Plugin_Package = 'Term::ReadLine::Tiny::Linux';
        }
        else {
            require Term::ReadLine::Tiny::Win32;
            $Plugin_Package = 'Term::ReadLine::Tiny::Win32';
        }
    }
    else {
        require Term::ReadLine::Tiny::Linux;
        $Plugin_Package = 'Term::ReadLine::Tiny::Linux';
    }
}

sub ReadLine { 'Term::ReadLine::Tiny' }
sub IN {
    my ( $self ) = @_;
    return $self->{handle_in};
}
sub OUT {
    my ( $self ) = @_;
    return $self->{handle_out};
}
sub MinLine { undef }
sub Attribs { {} }
sub Features { { no_features => 1 } }
sub addhistory {}
sub ornaments {}


sub new {
    my $class = shift;
    my ( $name ) = @_;
    my $self = bless {
        name       => $name,
        handle_in  => \*STDIN,
        handle_out => \*STDOUT,
    }, $class;
    $self->__set_defaults();
    $self->{plugin} = $Plugin_Package->new();
    return $self;
}


sub DESTROY {
    my ( $self ) = @_;
    $self->__reset_term();
}


sub __set_defaults {
    my ( $self ) = @_;
    $self->{compat}          //= undef;
    $self->{reinit_encoding} //= undef;
    $self->{asterix}         //= '*';
    $self->{default}         //= '';
    $self->{no_echo}         //= 0;
}


sub __validate_options {
    my ( $self, $opt ) = @_;
    return if ! defined $opt;
    my $valid = {
        no_echo         => '[ 0 1 ]',
        compat          => '[ 0 1 ]',
        reinit_encoding => '',
        default         => '',
        asterix         => '',
    };
    my $sub =  ( caller( 1 ) )[3];
    $sub =~ s/^.+::([^:]+)\z/$1/;
    for my $key ( keys %$opt ) {
        if ( ! exists $valid->{$key} ) {
            croak $sub . ": '$key' is not a valid option name";
        }
        next if ! defined $opt->{$key};
        if ( ref $opt->{$key} ) {
            croak $sub . ": option '$key' : a reference is not a valid value.";
        }
        next if $valid->{$key} eq '';
        if ( $opt->{$key} !~ m/^$valid->{$key}\z/x ) {
            croak $sub . ": option '$key' : '$opt->{$key}' is not a valid value.";
        }
    }
}


sub __init_term {
    my ( $self ) = @_;
    $self->{plugin}->__set_mode();
    if ( $self->{reinit_encoding} ) {
        Encode::Locale::reinit( $self->{reinit_encoding} );
    }

}


sub __reset_term {
    my ( $self ) = @_;
    if ( defined $self->{plugin} ) {
        $self->{plugin}->__reset_mode();
    }
}


sub config {
    my ( $self, $opt ) = @_;
    if ( defined $opt ) {
        croak "config: the (optional) argument must be a HASH reference" if ref $opt ne 'HASH';
        $self->__validate_options( $opt );
        for my $option ( %$opt ) {
            $self->{$option} = $opt->{$option};
        }
    }
}


sub readline {
    my ( $self, $prompt, $opt ) = @_;
    if ( defined $prompt ) {
        croak "readline: a reference is not a valid prompt." if ref $prompt;
    }
    else {
        $prompt = '';
    }
    if ( defined $opt ) {
        if ( ! ref $opt ) {
            $opt = { default => $opt };
        }
        elsif ( ref $opt ne 'HASH' ) {
            croak "readline: the (optional) second argument must be a string or a HASH reference";
        }
        else {
            $self->__validate_options( $opt );
        }
    }
    else {
        $opt = {};
    }
    $opt->{default} //= $self->{default};
    $opt->{no_echo} //= $self->{no_echo};
    $opt->{asterix} //= $self->{asterix};
    local $| = 1;
    $self->__init_term();
    print SAVE_CURSOR_POSITION;
    my $gcs_prompt = Unicode::GCString->new( $prompt );
    my $length_prompt = $gcs_prompt->columns();
    my $str = Unicode::GCString->new( $prompt . $opt->{default} );
    my $pos = $str->columns();
    $self->__print_readline( $opt, $prompt, $str, $pos );

    while ( 1 ) {
        my $key = $self->{plugin}->__get_key();
        if ( ! defined $key ) {
            $self->__reset_term();
            carp "EOT: $!";
            return;
        }
        next if $key == NEXT_get_key;
        next if $key == KEY_TAB;
        if ( $key == KEY_BSPACE || $key == CONTROL_H ) {
            if ( $pos - $length_prompt ) {
                $pos--;
                $str->substr( $pos, 1, '' );
            }
        }
        elsif ( $key == CONTROL_U ) {
            $str->substr( $length_prompt, $str->columns(), '' );
            $pos = $length_prompt;
        }
        elsif ( $key == VK_DELETE || $key == CONTROL_D ) {
            if ( $str->columns() - $length_prompt ) {
                if ( $pos < $str->columns() ) {
                    $str->substr( $pos, 1, '' );
                }
            }
            else {
                print "\n";
                $self->__reset_term();
                return;
            }
        }
        elsif ( $key == VK_RIGHT || $key == CONTROL_F ) {
            $pos++ if $pos < $str->columns();
        }
        elsif ( $key == VK_LEFT || $key == CONTROL_B ) {
            $pos-- if $pos > $length_prompt;
        }
        elsif ( $key == VK_END || $key == CONTROL_E ) {
            $pos = $str->columns();
        }
        elsif ( $key == VK_HOME || $key == CONTROL_A ) {
            $pos = $length_prompt;
        }
        else {
            $key = chr $key;
            utf8::upgrade $key;
            if ( $key eq "\n" or $key eq "\r" ) {
                $str->substr( 0, $length_prompt, '' );
                print "\n";
                $self->__reset_term();
                if ( $self->{compat} || ! defined $self->{compat} && $ENV{READLINE_TINY_COMPAT} ) {
                    return encode( 'console_in', $str->as_string );
                }
                return $str->as_string;
            }
            else {
                $str->substr( $pos, 0, $key );
                $pos++;
            }
        }
        $self->__print_readline( $opt, $prompt, $str, $pos );
    }
}


sub __print_readline {
    my ( $self, $opt, $prompt, $str, $pos ) = @_;
    my $row = int( $str->columns() / $self->{plugin}->__term_buff_width() );
    my $col = $str->columns() % $self->{plugin}->__term_buff_width();
    print RESTORE_CURSOR_POSITION;
    if ( $row ) {
        print "\n" x $row;
        print UP x $row;
    }
    print CLEAR_TO_END_OF_SCREEN;
    print SAVE_CURSOR_POSITION;
    if ( $opt->{no_echo} ) {
        my $gcs_prompt = Unicode::GCString->new( $prompt );
        print $prompt . ( $opt->{asterix} x ( $str->columns() - $gcs_prompt->columns() ) );
    }
    else {
        print $str->as_string;
    }
    my $curs_row = int( $pos / $self->{plugin}->__term_buff_width() );
    my $curs_col = $pos % $self->{plugin}->__term_buff_width();
    my $up = $row - $curs_row;
    if ( $up ) {
        print UP x $up;
    }
    if ( $col > $curs_col ) {
        print LEFT x ( $col - $curs_col );
    }
    elsif ( $col < $curs_col ) {
        print RIGHT x ( $curs_col - $col );
    }
}




1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Term::ReadLine::Tiny - Read a line from STDIN.

=head1 VERSION

Version 0.003

=cut

=head1 SYNOPSIS

    use Term::ReadLine::Tiny;

    my $new = Term::ReadLine::Tiny->new( 'name' );
    my $line = $new->readline( 'Prompt: ', { default => 'abc' } );

=head1 DESCRIPTION

C<readline> reads a line from STDIN. As soon as C<Return> is pressed C<readline> returns the read string without the
newline character - so no C<chomp> is required.

=head2 Keys

C<BackSpace> or C<Strg-H>: Delete the character behind the cursor.

C<Delete> or C<Strg-D>: Delete  the  character at point. Return nothing if the input puffer is empty.

C<Strg-U>: Delete the line.

C<Right-Arrow> or C<Strg-F>: Move forward a character.

C<Left-Arrow> or C<Strg-B>: Move back a character.

C<Home> or C<Strg-A>: Move to the start of the line.

C<End> or C<Strg-E>: Move to the end of the line.

C<Delete>, C<Right-Arrow>, C<Left-Arrow>, C<Home> and C<End> are not supported if the OS is MSWin32.

C<Term::ReadLine::Tiny> is new so things may change in the next release.

=head1 METHODS

=head2 new

The C<new> method returns a C<Term::ReadLine::Tiny> object.

    my $new = Term::ReadLine::Tiny->new( 'name' );

The argument is the name of the application.

=head2 config

The method C<config> sets the defaults for the current C<Term::ReadLine::Tiny> object.

    $new->config( \%options );

The available options are:

=over

=item

asterix

Sets the default I<asterix>.

Allowed values: a decoded string.

Default: 'C<*>'.

=item

default

Sets the default I<default> string.

Allowed values: a decoded string.

Default: not set.

=item

no_echo

Sets the default value for I<no_echo>.

Allowed values: 0 or 1.

Default: 0.

=back

Options not available in the C<readline> method:

=over

=item

compat

If I<compat> is set to 1, the return value of C<readline> is not decoded else the return value of C<readline>
is decoded.

Setting the environment variable READLINE_TINY_COMPAT to a true value has the same effect as setting I<compat> to 1
unless I<compat> is defined. If I<compat> is defined, READLINE_TINY_COMPAT has no meaning.

Allowed values: 0 or 1.

Default: no set

=item

reinit_encoding

To get the right encoding C<Term::ReadLine::Tiny> uses L<Encode::Locale>. Passing an encoding to I<reinit_encoding>
changes the encoding reported by C<Encode::Locale>. See L<Encode::Locale/reinit-encoding> for more details.

Allowed values: an encoding which is recognized by the L<Encode> module.

Default: not set.

=back

=head2 readline

C<readline> reads a line from STDIN.

    $line = $new->readline( $prompt, [ \%options ] );

The fist argument is the prompt string. The optional second argument is the default string if it is not a reference. If
the second argument is a hash-reference, the hash is used to set the different options. The keys/options are

=over

=item

asterix

Sets the string, which is displayed instead of a character when I<no_echo> is enabled. To get no output at all in the
I<no_echo> mode set I<asterix> to the empty string.

=item

default

Sets a initial value of input.

=item

no_echo

If I<no_echo> is enabled, I<asterisk> strings are displayed instead of the characters.

=back

See L</config> for the default and allowed values.

=head1 REQUIREMENTS

=head2 Perl version

Requires Perl version 5.10.1 or greater.

=head2 Encoding layer for STDIN

It is required an appropriate encoding layer for STDIN else C<readline> will break if a non ascii character is entered.

=head2 Encoding layer for STDOUT

For a correct output it is required an appropriate encoding layer for STDOUT.

MSWin32: Adding C<print "\e(U"> to the code disables the Windows own codepage conversion (e.g. to make the script more
portable). See L<Win32::Console::ANSI/Escape_sequences_for_Select_Character_Set> for more details.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Term::ReadLine::Tiny

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Thanks to the L<Perl-Community.de|http://www.perl-community.de> and the people form
L<stackoverflow|http://stackoverflow.com> for the help.

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl 5.10.0. For
details, see the full text of the licenses in the file LICENSE.

=cut
