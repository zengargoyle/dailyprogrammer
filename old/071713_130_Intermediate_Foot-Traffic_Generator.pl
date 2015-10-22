#!/usr/bin/env perl
use strict;
use warnings;

# skip stdin for test purposes.
#my ($E, $V, $R, $I, $O) = split ' ', <>;
my ($E, $V, $R, $I, $O) = (18, 8, 32, 300, 550);

my %p;
# person_id => { times => array_of_timestamps, rooms => array_of_rooms }

# since each I needs an O, create them in pairs.  so do $E times.
while ($E--) {

    # a random person, giving already picked people a double chance of
    # being picked again. :)
    my @p = ( keys %p, 0 .. $V );
    my $p = @p[ rand(@p) ];

    # a random room
    my $r = int(rand($R+1));

    # get a couple of times for I and O, checking that we don't
    # duplicate any timestamps.  may not be needed...
    my @t;
    while (@t != 2) {
        my $t = $I + int(rand($O-$I+1));
        push @t, $t unless grep { $_ == $t } @{ $p{$p}{times} || [] };
    }

    # give our random person a new room and I/O times, we'll sort and
    # match rooms to times later.
    push @{ $p{$p}{rooms} }, $r;
    push @{ $p{$p}{times} } , @t;
}

my @events;

# build the actual events
for my $p (keys %p) {

    # get a sorted set of times.
    my @t = sort { $a <=> $b } @{ $p{$p}{times} };

    for my $r ( @{ $p{$p}{rooms} } ) {
        # the times taken two at a time plus the room and person
        # create the I/O events.
        my ($in, $out) = splice @t, 0, 2;
        push @events, [ $p, $r, 'I', $in ], [ $p, $r, 'O', $out ];
    }
}

# output events.  we can sort however we like, this is by time then person
print scalar @events, "\n";
for (sort { $a->[3] <=> $b->[3] or $a->[0] <=> $b->[0] } @events ) {
    print "@{$_}\n";
}
