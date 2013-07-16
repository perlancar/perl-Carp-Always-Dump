package Carp::Always::Dump;

use 5.010001;
use strict;
use warnings;

use Data::Dump::OneLine qw(dump1);
use Monkey::Patch::Action qw(patch_package);
use Scalar::Util qw(blessed);

# VERSION

our $DumpObjects = 0;
our $MaxArgLen   = 0; # XXX not yet implemented

require Carp;
require Carp::Always;
our $h = patch_package(
    "Carp", "format_arg", "replace",
    sub {
        my $arg = shift;
        if (blessed($arg) && !$DumpObjects) {
            return "'$arg'";
        } else {
            return dump1($arg);
        }
    });

1;
# ABSTRACT: Like Carp::Always, but dumps the content of function arguments

=head1 SYNOPSIS

 % perl -MCarp::Always::Dump script.pl


=head1 SEE ALSO

L<Carp::Always> (and its variants such as: L<Carp::Always::Color>,
L<Carp::Always::SHS>)

L<Devel::SimpleTrace>, a simpler stack trace module, without showing function
arguments.

L<Monkey::Patch::Action>

=cut
