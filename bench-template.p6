#!/usr/bin/env perl6
use v6;
use Bench;


my $b = Bench.new;
$b.cmpthese(100, {
  regex => sub { my @x = possible-lines-r(12) },
  long => sub { my @x = possible-lines(12) },
});
