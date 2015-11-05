#!/usr/bin/env perl6
#
# https://www.reddit.com/r/dailyprogrammer/comments/3rhzdj/20151104_challenge_239_intermediate_a_zerosum/cwopn34
# https://www.reddit.com/user/shebang1245
#
use v6;

my $num = @*ARGS.shift // 929;

# NOTE: multidimensional shaped arrays are coming soon, ATM things are
# in a bit of flux implementation wise.

# sub dp($t,$a,$s) is rw { @[$t][$a][$s+82] }    # should work, but doesn't
# sub dp($t,$a,$s) is rw { @.[$t].[$a].[$s+82] } # does work
# sub dp($t,$a,$s) is rw { @[$t;$a;$s+82] }      # may work in future
sub dp($t,$a,$s) is rw { @.[$t;$a;$s+82] }       # will work better in future

sub next-num(Int(Cool) $num, $t = 0, $s = 0, $a = 0) {
  dp($t,$a,$s) orelse dp($t,$a,$s) = do
    if $num <= 0 { 3 }
    elsif $num == 1 { $s == 0 ?? 0 !! 3 }
    elsif $num %% 3 {
      next-num($num div 3, $t + 1, $s, $a) == 3 ?? 3 !! 0
    }
    elsif next-num($num div 3, $t + 1, $s - $num % 3, 0) !== 3 {
       -($num % 3)
    }
    elsif next-num($num div 3 + 1, $t + 1, $s + 3 - $num % 3, 1) !== 3 {
       3 - ($num % 3)
    }
    else { 3 }
}

for ^Inf -> $i {
  state $s = 0;
  my $n = next-num($num, $i, $s);
  once if $n == 3 { say "Impossible"; exit }
  say "$num $n";
  $num = ($num + $n) / 3;
  if $num == 1 { last };
  $s += $n;
  LAST { say "1" }
}
