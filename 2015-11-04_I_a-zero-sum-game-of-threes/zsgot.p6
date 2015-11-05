#!/usr/bin/env perl6
use v6;

my $num = @*ARGS.shift // 31;

my @adj = [0], [-1, 2], [-2, 1];

my @path;

sub solve($num --> Bool) {
  # say "$num @path[]";
  return True if $num == 1 and 0 == [+] @path».[1];
  return False if $num < 3;
  for @adj[$num % 3][*] -> $try {
    @path.push: [$num, $try];
    return True if solve(($num+$try)/3);
    @path.pop;
  }
  return False;
}


if solve($num) {
  say "$_[]" for @path;
  say "1";
}
else {
  say "Impossible!";
}
