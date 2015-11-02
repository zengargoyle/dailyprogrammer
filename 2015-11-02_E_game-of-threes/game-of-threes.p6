#!/usr/bin/env perl6
use v6;

my $big-num = @*ARGS.shift // 1_000.rand.Int;
say "Given: $big-num";
while $big-num != 1 {
  print "$big-num";
  given $big-num % 3 {
    when 2 { print " + 1"; $big-num += 1; }
    when 1 { print " - 1"; $big-num -= 1; }
    default { print " / 3"; $big-num /= 3; }
  }
  say " = $big-num";
}
