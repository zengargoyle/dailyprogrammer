#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

=for posterity

"One of the miseries of life is that everybody names things
a little bit wrong." —- Richard Feynman

=cut

# calculate π
my $π = 4 * atan2(1,1);

# replace <DATA> with just <> to read from STDIN or file.

# read dimensions
my ($X, $Y) = split ' ', <DATA>;

# build a 2D array of 1/0 values 'x' -> 1, ' ' -> 0
my @M;
push @M, [ map $_ eq 'x' ? 1 : 0, <DATA> =~ m/(.)/g ] for  1 .. $Y;

# convert true (1) values into an arrayref of their own [ row, column ]
for (my $r = 0 ; $r < $Y ; $r++) {
  for (my $c = 0 ; $c < $X ; $c++) {
    $M[$r][$c] = [ $r, $c ] if $M[$r][$c];
  }
}

# debugging :)
#use Data::Dump;
#dd [ M => \@M ];

# read the start position and direction
my ($x, $y, $θ) = split ' ', <DATA>;

# second test. answer: 3.10000000003847 3
#my ($x, $y, $θ) = (3.2, 3.1, 2.35619449);

# intersection of 2 line segments stolen from wikipedia.
#
# returns nothing if the segments are parallel.
#
# returns nothing if the intersection point *is not* on the second
# segment.  (all non-parallel lines intersect somewhere in space, so
# throw them away unless they're actually on the wall).
#
# returns the point if the intersection is on the second segment.

sub intersect {
  my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4) = @_;
  my $x1y2_y1x2 = $x1 * $y2 - $y1 * $x2;
  my $x3y4_y3x4 = $x3 * $y4 - $y3 * $x4;
  my $x1_x2ty3_y4__y1_y2tx3_y4 = ($x1-$x2)*($y3-$y4) - ($y1-$y2) * ($x3-$x4)
    or return;  # parallel
  my ($x,$y) = (
    ($x1y2_y1x2*($x3-$x4) - ($x1-$x2)*$x3y4_y3x4)/$x1_x2ty3_y4__y1_y2tx3_y4,
    ($x1y2_y1x2*($y3-$y4) - ($y1-$y2)*$x3y4_y3x4)/$x1_x2ty3_y4__y1_y2tx3_y4
  );
  return ($x,$y) if $x >= $x3 and $x <= $x4; # lies on second segment
  return; # does not lie on second segment
}

# 012345
# 1
# 2
# 312*45
# 4
# 5

# this is a bit futz worthy...  try to reduce the matrix.  if we know
# we're going left -> chop off the things to the right.  if we know we're
# going down -> chop off the things above us.  etc.

if ($θ >= 0) {
  splice @M, int($y+1); # up
} else {
  splice @M, 0, int($y); #down
}

if ( abs($θ) <= $π/2 ) {
  splice @$_, 0, int($x) for @M; # right
} else {
  splice @$_, int($x+1) for @M; # left
}

#dd [ M => \@M ];

# make our point + direction into a unit segment... the sin is negated
# due to the coordinate system being evil.

my ($x2, $y2) = ( $x + cos($θ), $y + -sin($θ) );


# from our pared down matrix walk through and turn our row,column
# information into 4 line segments (being careful to always make
# the x2,y2 >= x1,y1 so the intersection 'lies on segment' test works
# correctly:  x >= x1 and x <= x2

my @match;

for my $r (@M) {
  for my $c (@$r) {
    next unless $c;  # skip the false(0) empty spaces
    my ($ry, $cx) = @$c; # extract row(y) and column(x) of the space

      # build the 4 walls of a filled square and test each for intersection
      # with our origin,direction segment we made earlier.
      #
      for my $seq (
        [ $cx, $ry, $cx+1, $ry ], # top
        [ $cx, $ry, $cx, $ry+1 ], # left
        [ $cx+1, $ry, $cx+1, $ry+1 ], # right
        [ $cx, $ry+1, $cx+1, $ry+1 ], # bottom
      ) {
        if (my ($px,$py) = intersect($x,$y,$x2,$y2,@$seq)) {
          # keep each intersection and calculate the distance from
          # our starting point
          push @match, [ sqrt(($px-$x)**2 + ($py-$y)**2), $px, $py ]
        }
      }
  }
}

# if we have any matches, the closest one to our origin is the
# one we would have hit first.
my ($match) = sort { $a->[0] <=> $b->[0] } @match;
if ($match) {
  printf "%0.3f %0.3f\n", @{$match}[1,2];
}

__DATA__
10 10
xxxxxxxxxx
x  x x   x
x  x x   x
x    x xxx
xxxx     x
x  x     x
x        x
x  x     x
x  x    xx
xxxxxxxxxx
6.5 6.5 1.571
