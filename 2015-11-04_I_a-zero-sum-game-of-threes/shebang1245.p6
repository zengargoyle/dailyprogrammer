#!/usr/bin/env perl6
#
# https://www.reddit.com/r/dailyprogrammer/comments/3rhzdj/20151104_challenge_239_intermediate_a_zerosum/cwopn34
# https://www.reddit.com/user/shebang1245
#
# NOTE: ($ = &?ROUTINE(…)) construct is bug workaround should be
# just &?ROUTINE(…)
#
use v6;

my $num = @*ARGS.shift // 929;

sub dp($t,$a,$s) is rw {
  state @x;
  return-rw @x[$t][$a][$s+82];
}

sub next-num(Int() $num, $t, $s = 0, $a = 0) {
  dp($t,$a,$s).defined or dp($t,$a,$s) = do
  # dp($t,$a,$s) //= do
    if $num <= 0 { 3 }
    elsif $num == 1 { $s == 0 ?? 0 !! 3 }
    elsif $num %% 3 {
      next-num($num div 3, $t + 1, $s, $a) == 3 ?? 3 !! 0
    }
    elsif next-num($num div 3, $t + 1, $s - $num % 3, 0) !== 3 {
       -($num % 3)
    }
    elsif next-num($num div 3 + 1, $t + 1, $s+ 3 - $num % 3, 1) !== 3 {
       3 - ($num % 3)
    }
    else { 3 }
  dp($t,$a,$s)
}

if next-num($num,0) == 3 {
  say "Impossible"; exit;
}
loop (my $i = 0, my $s = 0; $num != 1; ++$i) {
  my $n = next-num($num, $i, $s);
  say "$num $n";
  $num=($num+$n)/3;
  $s+=$n;
}
say "1";
