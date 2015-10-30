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
    $<square>=<[\*\h\#SGUD]>
    {
      if $<square> eq any <S G U D> {
        %locations{$<square>}.push: [$floor,$row,$col];
      }
      $col++
    }
  }
}

my @direction =
           (-1, 0),
  ( 0,-1),          ( 0, 1),
           ( 1, 0)
;

sub print-map($map) {
  say join "\n\n", $map.map: -> $f { join "\n", $f.map: -> $r { $r.join } };
}

sub at-loc($map,$loc) is rw { $map[$loc[0]][$loc[1]][$loc[2]] }
sub make-step($loc,$step) { (@$loc Z+ @$step) }

sub open-steps($map,$loc) {
  gather for @direction -> $d {
    my $new = make-step($loc,(0,|@$d));
    given at-loc($map,$new) {
      when 'D' { take make-step($new, (1,0,0)) }
      when 'U' { take make-step($new, (-1,0,0)) }
      when ' '|'G' { take $new }
    }
  }
}

my ($dungeon-text, $solution-text) = 'map1.dat'.IO.slurp.split(/^^\-+\n/);
my ($locations, $map) = D.new.parse($dungeon-text).made<locations map>;
my @walk;
sub walk($map,$loc,@path) {
  my @taken = @path;
  @taken.push: [ at-loc($map,$loc), $loc ];
  @walk.push: @taken;
  at-loc($map,$loc) = 'v';
  my @new;
  for open-steps($map,$loc) -> $s {
    push @new, walk($map,$s,@taken);
  }
  if @new {
    return [@new.map(|*)];
  }
  @taken;
}

my @path;
@path = walk($map,$locations<S>[0],[]);
say "-" x 10;
for @walk.grep({$_.[*-1][0] eq 'G'}).sort(:by(*.elems)).[0] -> @p {
  @p.say;
  print-map($map);
}
