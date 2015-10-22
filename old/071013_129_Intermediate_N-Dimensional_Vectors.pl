#!/usr/bin/env perl
use strict;
use warnings;

use List::Util qw< sum >;

my @vectors;

my $count = <>;
while ($count--) {
    my (undef, @v) = split ' ', <>;
    push @vectors, [ @v ];
}

my %dispatch;  # predeclare so 'l' is available for use in 'n'
%dispatch = (
    l => sub { sqrt sum map { $_ * $_ } @{ $vectors[ $_[0] ] } },
    n => sub {
        my $len = $dispatch{l}->( $_[0] );
        map { $_ / $len } @{ $vectors[ $_[0] ] };
    },
    d => sub {
        sum map {
            $vectors[ $_[0] ][$_] * $vectors[ $_[1] ][$_]
        } 0 .. $#{ $vectors[ $_[0] ] };
    },
);

$count = <>;
while ($count--) {
    my ($f, @i) = split ' ', <>;
    my @res = $dispatch{ $f }->( @i );
    printf join(' ', ("%0.5g") x @res) . "\n", @res;
}
