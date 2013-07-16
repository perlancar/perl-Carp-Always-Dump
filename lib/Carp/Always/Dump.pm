package Carp::Always::Dump;

use 5.010001;
use strict;
use warnings;

use Data::Dump::OneLine qw(dump1);
use Monkey::Patch::Action qw(patch_package);
use Scalar::Util qw(blessed);

# VERSION

our $DumpObj   = 0;
our $MaxArgLen = 0;

require Carp;
require Carp::Always;
our $h = patch_package(
    "Carp", "format_arg", "replace",
    sub {
        my $arg = shift;
        if (blessed($arg) && !$DumpObj) {
            return "'$arg'";
        } else {
            my $dmp = dump1($arg);
            $dmp = substr($dmp, 0, $MaxArgLen) . "..."
                if $MaxArgLen > 0 && $MaxArgLen < length($dmp);
            return $dmp;
        }
    });

1;
# ABSTRACT: Like Carp::Always, but dumps the content of function arguments

=head1 SYNOPSIS

 % perl -MCarp::Always::Dump script.pl


=head1 VARIABLES

=head2 $DumpObj => BOOL (default: 0)

If set to 1, will dump objects (blessed references) instead of showing
them as 'Foo::Bar=HASH(0x19c8ff8)'.

=head2 $MaxArgLen => INT (default: 0)

Like C<$MaxArgLen> in L<Carp>, to limit the number of characters of dump to
show.


=head1 SEE ALSO

L<Carp::Always> (and its variants such as: L<Carp::Always::Color>,
L<Carp::Always::SHS>)

L<Devel::SimpleTrace>, a simpler stack trace module, without showing function
arguments.

L<Monkey::Patch::Action>

=cut
