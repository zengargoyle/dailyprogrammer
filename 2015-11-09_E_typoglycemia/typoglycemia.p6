#!/usr/bin/env perl6
use v6;

my $input = $*IN.slurp-rest;
for $input.lines.match(/\w+/, :g).map({ $_.from, $_.chars }) -> [ $f, $l ] {
  next unless $l > 3;
  $input.substr-rw( $f+1, $l-2) = $input.substr($f+1, $l-2).comb.pick(*).join;
}
say $input;
