use v6;

unit module BalanceEquation;

use Solver;
use ParseEquation;

sub bag-mult($bag, $factor) {
  $bag.map( { $_.value *= $factor; $_ } );
}

sub to-string($model) {
  $model.map(-> $side {
    $side.map(-> $compound {
        join ' ',
          $compound<coefficient> > 1 ?? $compound<coefficient> !! (),
          $compound<repr>;
    }).join(' + ')
  }).join(' -> ');
}

sub replace-coefficients($model, @solution is copy) {
  $model.flatmap(-> $side {
    $side.map(-> $compound {
          $compound<coefficient> = @solution.shift;
    })
  });
  $model;
}

sub info($model) is export(:FOR-TESTING) {

  my ($lc, $rc) = $model.map(*.elems);

  my ($lb,$rb) = $model.map(-> $side {
    [(+)] $side.map(-> $compound {
      bag-mult($compound<compound>, $compound<coefficient>)
    })
  });

  my @cols = $lc + $rc;
  my @rows = $lb.keys.sort;

  my @M;
  # XXX - still ugly
  for [$model.flatmap(*.list)].kv -> $c, $v {
    my $sign = $lc <= $c < ($lc + $rc - 1) ?? -1 !! 1;
    for @rows.kv -> $i, $e {
      @M[$i][$c] = $sign * $v<compound>{$e};
    }
  }

  return {
    :matrix(@M),
    :transmuting($lb.Set !=== $rb.Set),
    :balanced($lb === $rb),
    :rows(@rows),
    :$lc, :$rc,
  };
}

sub balance-equation(Str $equation) returns Str is export {
  my $m = parse-equation($equation) // return "Nope! $equation.trim()";
  my $info = info($m);
  return to-string($m) if $info<balanced>;
  my $solution = solve-system($info<matrix>);
  replace-coefficients($m, $solution);
  return "Nope! transmutating" if $info<transmuting>;
  return to-string($m);
  CATCH {
    default { warn ~$_; return "Nope! error"; }
  }
}
