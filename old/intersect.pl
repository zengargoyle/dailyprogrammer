#!/usr/bin/perl
use strict;
use warnings;

BEGIN {
  $::p = shift;
}

use bignum p => $::p, 'PI';
use feature qw( say );
our $PI = 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117068;

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
my $expr = shift;
my $theta = eval $expr;
if($@){ die $@ };
say "theta: $theta";
my @d = ( cos($theta), -sin($theta) );
say for intersect( 6.5, 6.5, 6.5+$d[0], 6.5+$d[1], 0,6, 10,6);
say for intersect( 6.5, 6.5, 6.5+$d[0], 6.5+$d[1], 0,5, 10,5);
say '---67';
say for intersect( 6.5, 6.5, 6.5+$d[0], 6.5+$d[1], 6,6, 7,6);
say '---78';
say for intersect( 6.5, 6.5, 6.5+$d[0], 6.5+$d[1], 7,6, 8,6);
say '---';

