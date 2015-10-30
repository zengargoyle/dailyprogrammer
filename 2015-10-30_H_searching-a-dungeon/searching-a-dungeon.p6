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

my ($dungeon-text, $solution-text) = 'map1.dat'.IO.slurp.split(/^^\-+\n/);
say $dungeon-text;

my ($locations, $map) = D.new.parse($dungeon-text).made<locations map>;

sub print-map($map) {
  say join "\n\n", $map.map: -> $f { join "\n", $f.map: -> $r { $r.join } };
}

print-map($map);
