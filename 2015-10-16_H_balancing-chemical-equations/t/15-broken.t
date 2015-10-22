# vim: ft=perl6
use v6;

use Test;
use Solver;
use ParseEquation;
use BalanceEquation :FOR-TESTING, :DEFAULT;

use lib 't/lib';
use TestData;

for test-data() -> $t {
  next if $t<matrix>:exists;
  my $m = parse-equation($t<input>);
  my $i = info($m);
  # say solve-system($i<matrix>[0..$i<lc>+$i<rc>-2]);
  is solve-system($i<matrix>), $t<solution>, "$t<input> => $t<output>";
}

for test-data()[0] -> $t {
  is balance-equation($t<input>), $t<output>, "balance-equation exported via :DEFAULT";
}

done-testing;
