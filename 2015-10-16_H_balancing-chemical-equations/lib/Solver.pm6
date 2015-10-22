#
# Solver - use Gaussian elimination to solve a system of linear
# equations to find the coefficient needed for each molecule
#
# https://en.wikipedia.org/wiki/Gaussian_elimination
#
use v6;
unit module Solver;

sub build-echelon(@Matrix) {

  my @M = @Matrix.perl.EVAL;  # XXX .clone ???
  @M = @M[0..@M[0].elems - 2];  # fewer rows than columns...

  my $m = @M.end;
  my $n = @M[0].end;
  my $min = [min] $m, $n;

  for 0..$min  -> $k {

    # find k-th pivot
    my $i_max = ($k .. $m)\
      .map({ [ $^i, @M[$^i][$k].abs ] })\
      .sort(*.[1])[*-1][0];

    die "Matrix is singular!"
      if @M[$i_max][$k] == 0;

    # swap
    # XXX (a,b) = (b,a) -- unsure of list flattening magic
    if $i_max != $k {
      my $t = @M[$i_max];
      @M[$i_max] = @M[$k];
      @M[$k] = $t;
    }

    # do for all rows below pivot
    for $k+1 .. $m -> $i {
      # do for all remaining elements in current row
      for $k+1 .. $n -> $j {
        @M[$i][$j] = @M[$i][$j] - @M[$k][$j] * (@M[$i][$k] / @M[$k][$k]);
      }
      # fill lower triangular matrix with zeros
      @M[$i][$k] = 0;
    }
  }

  return @M;
}

sub reduce-echelon(@Matrix) {

  my @M = @Matrix.perl.EVAL;  # XXX .clone ???

  my $m = @M.end;
  my $n = @M[0].end;

  for $m ... 0 -> $i {
    # XXX clean this up a bit
    my $o = 0;
    for $i+1 .. $m -> $v {
      $o++;
      @M[$i][$v] *= @M[$i+$o][$n];
      @M[$i][$n] -= @M[$i][$v];
      @M[$i][$v] = 0;
    }
    @M[$i][$n] /= @M[$i][$i];
    @M[$i][$i] = 1;
  }

  return @M;
}

# solution for N-1 variables is in last column
# solution for N variable is taken as 1 (our degree of freedom)
#
sub extract-variables(@Matrix, :$free-variable) {
  return |@Matrix.map(*.[*-1]), $free-variable;
}

# ensure all coefficients are Integer.  Perl 6 defaults to using
# Rationals (numerator/denominator) instead of floating-point,
# scale solutions by the product of the denominators and then
# reduce by greatest-common-denominator to get a nice set of
# Integer solutions.

sub integer-solution(@v) {
  my $mult = [*] @v.grep(* ~~ Rat).map(*.nude.[1]);
  my @scaled = @v.map(* * $mult);
  my $gcd = [gcd] @scaled;
  my @reduced = @scaled.map(* / $gcd);
  return @reduced;
}

# wrap up the whole of Gaussian elimination -> Integer solution
sub solve-system(@Matrix, Bool :$integer = True, :$free-variable = 1) is export {
  my @e = build-echelon(@Matrix);
  my @r = reduce-echelon(@e);
  my @v = extract-variables(@r, :$free-variable);
  return $integer ?? integer-solution(@v) !! @v;
}
