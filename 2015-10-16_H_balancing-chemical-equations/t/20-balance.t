# vim: ft=perl6
use v6;

use Test;
use BalanceEquation;

use lib 't/lib';
use TestData;

for test-data() -> $t {
  is balance-equation($t<input>), $t<output>,
    "$t<input> => $t<output>";
}

done-testing;
