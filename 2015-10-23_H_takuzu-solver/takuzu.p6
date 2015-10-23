#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 0;

sub MAIN('test') {
  use Test;

my @Test = for split /\n\n/ q:to/END/.chomp -> $in, $out { :$in, :$out };
0.0.
..0.
...1

1010
0101
1100
0011

110...
1...0.
..0...
11..10
....0.
......

110100
101100
010011
110010
001101
001011

0....11..0..
...1...0....
.0....1...00
1..1..11...1
.........1..
0.0...1.....
....0.......
....01.0....
..00..0.0..0
.....1....1.
10.0........
..1....1..00

010101101001
010101001011
101010110100
100100110011
011011001100
010010110011
101100101010
001101001101
110010010110
010101101010
101010010101
101011010100
END

my $width = @in[0].chars;
my $height = @in.elems;

my $lowest-possible = gather loop { .take for <0 0 1> }
my $highest-possible = gather loop { .take for <1 1 0> }

my $l = join '',  $lowest-possible[^$width];
my $h = join '',  $highest-possible[^$width];

say "searching $l to $h";

my @x = gather for :2($l)..:2($h) -> $x {
  my $t = $x.fmt("\%0{$width}b");
  next if $t ~~ / 000 | 111 /;
  next unless @($t ~~ m:g/1/).elems == $width / 2;
  take $t;
}

my @c = @in.map({my $i = $_; @x.grep(/<$i>/) });

my @try = gather for [X] @c -> @h {
  next unless @h.Set.elems == $width;
  take @h;
}

for @try -> @t {
  # @t.say;
  my @T = (zip @t>>.comb)>>.join;
  # say @T;
  next if any(@T.map(*.match(/000|111/)));
  next unless @T.Set.elems == $height;
  next unless all(@T.map({@(m:g/1/).elems == $height/2 }));
  # next unless @(@T[0] ~~ m:g/1/).elems == @(@t[0] ~~ m:g/1/).elems;
  say "solution";
  say @t.join("\n");
}


  pass "Template";
  done-testing;
}
