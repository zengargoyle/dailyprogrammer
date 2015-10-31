#!/usr/bin/env perl6
use v6;

grammar D {
  my ($floor,$row,$col) = 0 xx *;
  my %locations;
  rule TOP {
    ^ <floor>+ % \n \n? $
    { make { :%locations, :map([ $<floor>».made ]) } }
  }
  token floor {
    ^^ <row>+ % \n $$
    { make [ $<row>».made ]; $floor++; $row = 0 }
  }
  token row {
    <square>+
    { make [ $<square>».Str ]; $row++; $col = 0 }
  }
  token square {
    $<square>=<[\h\*\#SGUD]>
    {
      if $<square> eq any <S G U D> {
        %locations{$<square>}.push: [$floor,$row,$col];
      }
      $col++
    }
  }
}

my @directions = (-1, 0), (0,-1), (0, 1), (1, 0);

sub print-map($map) {
  say join "\n\n", $map.map: -> $f { join "\n", $f.map: -> $r { $r.join } };
}

#| for want of @array[@multi]
sub at-loc($map,$loc) is rw { $map[$loc[0]][$loc[1]][$loc[2]] }

sub make-step($loc,$step) { (@$loc Z+ @$step) }

# only move through U, D, G, and empty
sub open-steps($map,$loc) {
  gather for @directions -> $d {
    my $next = make-step($loc,(0,|@$d));
    given at-loc($map,$next) {
      when 'D' { take make-step($next, (1,0,0)) }
      when 'U' { take make-step($next, (-1,0,0)) }
      when ' '|'G' { take $next }
    }
  }
}

my ($dungeon-text, $solution-text) = 'map2.dat'.IO.slurp.split(/^^\-+\n/);
my ($locations, $map) = D.new.parse($dungeon-text).made<locations map>;

my $start = $locations<S>[0];
my @stack = $start;
my %visited = $start => $start;
my $here;

while @stack {
  $here = pop @stack;
  last if at-loc($map,$here) eq 'G';
  for open-steps($map,$here) -> $step {
    next if %visited{"$step"}:exists;
    %visited{"$step"} = $here;
    push @stack, $step;
  }
}

loop {
  $here = %visited{"$here"};
  last if $here ~~ $start;
  at-loc($map,$here) = '*';
}

print-map($map);
