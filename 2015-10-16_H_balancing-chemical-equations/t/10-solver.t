# vim: ft=perl6
use v6;

use Test;
use Solver;

use lib 't/lib';
use TestData;

is solve-system([
  [ 2, 0, 2 ],
  [ 0, 2, 1 ],
]), [ 2, 1, 2 ], 'H2 + O2 -> H2O => 2 H2 + O2 -> 2 H2O';

for test-data() -> $t {
  next unless $t<matrix>:exists;
  is solve-system($t<matrix>), $t<solution>,
    "$t<input> => $t<output>";
}

done-testing;
