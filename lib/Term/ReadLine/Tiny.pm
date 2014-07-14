package Term::ReadLine::Tiny;

use warnings;
use strict;
use 5.010001;

our $VERSION = '0.001';
use Exporter 'import';
our @EXPORT_OK = qw( readline );

use Carp   qw( croak );
use Encode qw( encode decode );

use Encode::Locale    qw();
use Unicode::GCString qw();


sub BSPACE                  () { 0x7f }
sub ESC                     () { 0x1b }
sub UP                      () { "\e[A" }
sub CLEAR_TO_END_OF_SCREEN  () { "\e[0J" }
sub CLEAR_SCREEN            () { "\e[1;1H\e[0J" }
sub SAVE_CURSOR_POSITION    () { "\e[s" }
sub RESTORE_CURSOR_POSITION () { "\e[u" }


my $Plugin_Package;

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        require Win32::Console::ANSI;
        require Term::ReadLine::Tiny::Win32;
        $Plugin_Package = 'Term::ReadLine::Tiny::Win32';
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
sub Features { {} }
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
#    if ( defined $opt ) {
#        croak "new: the (optional) argument must be a HASH reference" if ref $opt ne 'HASH';
#        $self->__validate_options( $opt );
#        for my $option ( %$opt ) {
#            $self->{$option} = $opt->{$option};
#        }
#    }
    $self->{plugin} = $Plugin_Package->new();
    return $self;
}


sub DESTROY {
    my ( $self ) = @_;
    $self->__reset_term();
}


sub __set_defaults {
    my ( $self ) = @_;
    $self->{no_echo}         //= 0;
    $self->{reinit_encoding} //= undef;
    $self->{default}         //= '';
    $self->{asterix}         //= '*';
}


sub __validate_options {
    my ( $self, $opt ) = @_;
    return if ! defined $opt;
    my $valid = {
        no_echo         => '[ 0 1 ]',
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
        croak "new: the (optional) argument must be a HASH reference" if ref $opt ne 'HASH';
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
    $opt->{no_echo} //= $self->{no_echo};
    $opt->{asterix} //= $self->{asterix};
    my $str = encode( 'console_in', $opt->{default} // $self->{default} );
    local $| = 1;
    $self->__init_term();
    print SAVE_CURSOR_POSITION;
    $self->__print_readline( $opt, $prompt, $str );

    while ( 1 ) {
        my $key = $self->{plugin}->__get_key();
        return if ! defined $key;
        if ( $key eq "\cD" ) {
            if ( ! length $str ) {
                print "\n";
                $self->__reset_term();
                return;
            }
            $str = '';
            $self->__print_readline( $opt, $prompt, $str );
            next;
        }
        elsif ( $key eq "\n" or $key eq "\r" ) {
            print "\n";
            $self->__reset_term();
            return $str;
        }
        elsif ( ord $key == BSPACE || $key eq "\cH" ) {
            if ( length $str ) {
                $str = decode( 'console_in', $str );
                $str =~ s/\X\z//; # ?
                $str = encode( 'console_in', $str );
            }
            $self->__print_readline( $opt, $prompt, $str );
            next;
        }
        elsif ( ord $key == ESC ) {
            $self->{plugin}->__flush_input();
            $self->__print_readline( $opt, $prompt, $str );
            next;
        }
        #elsif ( $key !~ /^\p{Print}\z/ ) {
        #    $self->__print_readline( $opt, $prompt, $str );
        #    next;
        #}
        $key = encode( 'console_in', $key ) if utf8::is_utf8( $key );
        $str .= $key;
        $self->__print_readline( $opt, $prompt, $str );
    }
}


sub __print_readline {
    my ( $self, $opt, $prompt, $str ) = @_;
    my $gcs = Unicode::GCString->new( $prompt . $str );
    my $up = int( $gcs->columns() / $self->{plugin}->__term_buff_width() );
    print RESTORE_CURSOR_POSITION;
    if ( $up ) {
        print "\n" x $up;
        print UP x $up;
    }
    print CLEAR_TO_END_OF_SCREEN;
    print SAVE_CURSOR_POSITION;
    if ( $opt->{no_echo} ) {
        my $gcs = Unicode::GCString->new( decode( 'console_in', $str ) );
        print $prompt . ( $opt->{asterix} x $gcs->columns() );
    }
    else {
        print $prompt . decode( 'console_in', $str );
    }
}




1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Term::ReadLine::Tiny - Read a line from STDIN.

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

    use Term::ReadLine::Tiny;

    my $new = Term::ReadLine::Tiny->new( 'name' );
    my $line = $new->readline( 'Prompt: ', { default => 'abc' } );

=head1 DESCRIPTION

C<readline> reads a line from STDIN. As soon as C<Return> is pressed C<readline> returns the read string without the
newline character - so no C<chomp> is required. The returned string is not decoded.

A C<Strg-D> removes the input-puffer if any, else it causes C<readline> to return nothing.

C<BackSpace> (or C<Strg-H>) deletes the last character of the string.

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

=item

reinit_encoding

The get the right encoding C<Term::ReadLine::Tiny> uses L<Encode::Locale>. Passing an encoding to I<reinit_encoding>
changes the encoding reported by C<Encode::Locale>. See L<Encode::Locale/reinit-encoding> for more details.

Allowed values: an encoding which is recognized by the L<Encode> module.

Default: not set.

=back

=head2 readline

C<readline> reads a line from STDIN.

    $line = $new->readline( $prompt, [ \%options ] );

The fist argument is the prompt string. The optional second argument is the default string if it is not a reference. If
the second argument is a hash-reference the hash is used to set the different options. The keys/options are

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
