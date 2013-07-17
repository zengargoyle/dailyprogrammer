#!/usr/bin/env perl
use strict;
use warnings;

my %info;
my $dispatch = {
    I => sub {  # on In save entry time for person
        my ($p, $r, undef, $t) = @_;
        $info{$r}{$p} = $t;
    },
    O => sub {  # on Out add duration of person visit and count
        my ($p, $r, undef, $t) = @_;
        $info{$r}{time} += $t - $info{$r}{$p};
        $info{$r}{count}++;
    }
};

while (<>) {
    my (@tok) = split;
    next unless @tok == 4;   # who needs linecount
    # dispatch on In/Out field
    $dispatch->{ $tok[2] }->( @tok );
}

for my $r (sort { $a <=> $b } keys %info) {
    printf "Room %d, %d minute average visit, %d visitor(s) total\n",
        $r, int($info{$r}{time}/$info{$r}{count}), $info{$r}{count};
}
