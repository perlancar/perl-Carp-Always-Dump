package Carp::Always::Dump;

use 5.010001;
use strict;
use warnings;

use Data::Dump qw(dump);
use Data::Dump::OneLine qw(dump1);
use Monkey::Patch::Action qw(patch_package);
use Scalar::Util qw(blessed);

# VERSION

our $Color     = $ENV{COLOR} // $ENV{INTERACTIVE} // (-t STDOUT);
our $DumpObj   = 0;
our $MaxArgLen = 0;
our $Terse     = 1;

our $h;

require Carp;
require Carp::Always;

sub import {
    my ($self, %args) = @_;

    for my $k (keys %args) {
        my $v = $args{$k};
        if ($k =~ /^\$?Color$/) {
            $Color = $v;
        } elsif ($k =~ /^\$?DumpObj$/) {
            $DumpObj = $v;
        } elsif ($k =~ /^\$MaxArgLen$/) {
            $MaxArgLen = $v;
        } elsif ($k =~ /^\$?Terse$/) {
            $Terse = $v;
        } else {
            die "Unknown import argument $k, please use one of: ".
                "Color/DumpObj/MaxArgLen/Terse";
        }
    }

    $h = patch_package(
        "Carp", "format_arg", "replace",
        sub {
            my $arg = shift;
            my $res;

            if (blessed($arg) && !$DumpObj) {
                $res = "'$arg'";
            } else {
                if ($Terse) {
                    $res = dump1($arg);
                } else {
                    $res = dump($arg);
                }
                $res = substr($res, 0, $MaxArgLen) . "..."
                    if $MaxArgLen > 0 && $MaxArgLen < length($res);
            }

            state $colnum = 0;
            if ($Color) {
                my $col;
                if ($colnum++ % 2) {
                    $col = 33;
                } else {
                    $col = 36;
                }
                $res = "\e[$col;3m$res\e[0m";
            }

            return $res;
        }
    );
}

sub unimport {
    undef $h;
}

1;
# ABSTRACT: (DEPRECATED) Like Carp::Always, but dumps the content of function arguments

=head1 SYNOPSIS

 % perl -MCarp::Always::Dump script.pl


=head1 DESCRIPTION

B<NOTICE:> This module is deprecated. The same functionality is in
L<Devel::Confess>:

 % perl -d:Confess=dump ...

This module will be removed from CPAN.


=head1 VARIABLES

=head2 $Color => BOOL (default: from COLOR environment, or 1)

If set to true, will use terminal colors to help visually distinguish parameters
from one another.

=head2 $DumpObj => BOOL (default: 0)

If set to 1, will dump objects (blessed references) instead of showing
them as 'Foo::Bar=HASH(0x19c8ff8)'.

=head2 $MaxArgLen => INT (default: 0)

Like C<$MaxArgLen> in L<Carp>, to limit the number of characters of dump to
show.

=head2 $Terse => BOOL (default: 1)

If set to false, will use L<Data::Dump> instead of the terser
L<Data::Dump::OneLine> to produce the dumps.


=head1 IMPORTS

For each variable mentioned in L</"VARIABLES">, you can also set it via import
argument:

 use Carp::Always::Dump Color=>0, DumpObj=>1;

Via command-line:

 % perl -MCarp::Always::Dump=Color,1 ...


=head1 ENVIRONMENT

=head2 COLOR => BOOL

Used to set the default of C<$Color>.

=head2 INTERACTIVE => BOOL


=head1 SEE ALSO

L<Carp::Always> (and its variants such as: L<Carp::Always::Color>,
L<Carp::Always::SHS>)

L<Devel::SimpleTrace>, a simpler stack trace module, without showing function
arguments.

L<Monkey::Patch::Action>

=cut
