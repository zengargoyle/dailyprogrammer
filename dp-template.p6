#!/usr/bin/env perl6
use v6;

constant $DEBUG = %*ENV<DEBUG> // 1;

subset File of Str where { $_.IO ~~ :e & :f };
my $TEST-FILE = $*PROGRAM-NAME.subst(/'.p6'?$/, '.dat');

sub get-tests($datfile) {
  slurp($datfile).chomp.split(/\n\n/).map(
    -> $input, $output { (:$input, :$output).Hash }
  )
}

sub MAIN('test', File(File) :$datfile = $TEST-FILE) {
  use Test;
  my @Tests = get-tests($datfile);

  for @Tests.kv -> $num, $test {

  }

  done-testing;
}
