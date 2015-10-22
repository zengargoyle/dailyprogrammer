#!/usr/bin/env perl
use strict;
use warnings;

use v5.16;

# want our program and teminal to have utf8 goodness
use utf8;
binmode STDOUT, ':encoding(UTF-8)';

my ($low, $high) = split ' ', <STDIN>;

# a mapping of our operators as an array of hashes in the
# order of their precedence level and the code to evaluate them.
my @op = (
    {
        '·' => sub { $_[0] * $_[1] },  # rfc1345(.M) \x{00b7} \N{MIDDLE DOT}
    },
    {
        '+' => sub { $_[0] + $_[1] },
        '-' => sub { $_[0] - $_[1] },
    },
);

my @ops = map keys %$_, @op;  # for rolling

# pick one random item from an array
sub roll { $_[rand(@_)] }

# our equation template: d == digit, o == operator
my $eqn_tmpl = 'd o d o d o d';

# named scopes and redo/next/last are handy
EQN: {

    # copy template and replace items with random suitable things
    # to create a random equation
    my $eqn = $eqn_tmpl;
    $eqn =~ s/d/roll($low..$high)/ge;
    $eqn =~ s/o/roll(@ops)/ge;

    # copy equation and solve it.
    # go through the array of operator precedence groupings
    # and create a match string (that escapes any operator that
    # might be a special character in regex).  match each
    # ( digit op digit ) group and replace with its solution.
    my $ans = $eqn;
    for my $ops ( @op ) {
        my $match = join '|', map quotemeta, keys %$ops;
        1 while $ans =~ s/(\d+) ($match) (\d+)/$ops->{$2}->($1,$3)/e;
    }

    ASK: {

        # show equation and get a guess
        say $eqn;  # print "--> $ans\n";  # debug
        my $guess = <>;
        chomp $guess;

        # maybe quit
        $guess =~ /^q/i && last EQN;

        # test guess and do another equation or try this one again
       if ($guess == $ans) { say "Correct"; redo EQN; }
       say "Try again";
       redo ASK;
    }
}
