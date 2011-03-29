########################################################################
# Signal::StackTrace::CarpLike - run a stack dump on a signal.
########################################################################
########################################################################
# housekeeping
########################################################################

package Signal::StackTrace::CarpLike;

use 5.006;

use strict;

use Carp;
use Config;

use Data::Dumper;

########################################################################
# package variables
########################################################################

our $VERSION = 0.01;

my %known_sigz  = ();

@known_sigz{ split ' ', $Config{ sig_name } } = ();

########################################################################
# install the signal handlers
########################################################################

sub import
{
    # discard this package;
    # remainder of the stack are signal names.

    shift;

    if( @_ ) 
    {
        if( my @junk = grep { ! exists $known_sigz{ $_ } } @_ )
        {
            croak "Unknown signals: unknown signals @junk";
        }

        # all the signals are known, install them all
        # with the cluck handler.

        @SIG{ @_ } = ( \&Carp::cluck ) x @_;
    }
    else
    {
        $SIG{ USR1 } = \&Carp::cluck;
    }

    return
}

# keep require happy

1

__END__

=head1 NAME

Signal::StackTrace::CarpLike - install signal handler to print a Carp-like stacktrace

=head1 SYNOPSIS

    # default installs the handler on USR1
    # these have the same result.

    use Signal::StackTrace::CarpLike;
    use Signal::StackTrace::CarpLike qw( USR1 );

    # install the handler on any valid signals

    use Signal::StackTrace::CarpLike qw( HUP );
    use Signal::StackTrace::CarpLike qw( HUP USR1 USR2 );

    # this will fail: FOOBAR is not a valid
    # signal (on any system I know of at least).

    use Signal::StackTrace::CarpLike qw( FOOBAR );

=head1 DESCRIPTION

This will print a stack trace to STDERR -- 
similar to the sigtrap module but without the 
core dump using simpler syntax.

The module arguemts are signals on which to 
print the stack trace. For normally-terminating
signals (e.g., TERM, QUIT) it is proably a bad
idea in production environments but would be
handy for tracking down errors; for non-trapable
signals (e.g., KILL) this won't do anything.

The import will croak on signal names unknown to 
Config.pm ( see $Config{ sig_name } ).

The stack trace looks something like:

  Caller level 1:
  {
    Bitmask => '',
    Evaltext => undef,
    Filename => '(eval 9)[/usr/lib/perl5/site_perl/5.8.8/i686-linux/Term/ReadKey.pm:411]',
    Hasargs => 0,
    Hints => 0,
    'Line-No' => 7,
    Package => 'Term::ReadKey',
    Require => undef,
    Subroutine => '(eval)',
    Wantarray => 0
  }

  ...

  Caller level 8:
  {
    Bitmask => '',
    Evaltext => undef,
    Filename => '-e',
    Hasargs => 0,
    Hints => 0,
    'Line-No' => 1,
    Package => 'main',
    Require => undef,
    Subroutine => 'DB::DB',
    Wantarray => 1
  }


  End of trace



=head1 KNOWN BUGS

None, yet.

=head1 SEE ALSO

=over 4

=item perlipc

Dealing with signals in perl.

=item sigtrap

Trapping signals with supplied handlers, getting 
core dumps.

=item Config

$Config{ sig_name } gives the valid signal 
names.

=back

=head1 AUTHOR

Shawn M Moore <sartak@gmail.com>

=head2 ORIGINAL AUTHOR

Steven Lembark <lembark@wrkhors.com> was the original author of
L<Signal::StackTrace> from which this module was forked.

=head1 LICENSE

This code is licensed under the same terms as Perl 5.8
or any later version of perl at the users preference.
