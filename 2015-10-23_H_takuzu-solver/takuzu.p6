#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 0;

sub possible-lines($size) {
  my $lower = gather loop { .take for <0 0 1> }
  my $upper = gather loop { .take for <1 1 0> }
  gather TOP:
  for :2($lower[^$size].join) .. :2($upper[^$size].join) -> $i {
    my $line = $i.fmt: "\%0{$size}b";
    for ^$size -> $p {
      state $ones;
      state @last = <x x x>;
      my $o = substr $line, $p, 1;
      $ones++ if $o eq '1';
      push @last, $o;
      next TOP if [eq] @last;
      LAST { next TOP unless $ones == $size/2 }
    }
    take $line;
  }
}

sub test-solution(@ps) {
  gather TOP:
  for @ps -> @s {
    my @T = ([Z] @s>>.comb)>>.join;
    my $size = @T.elems;
    for @T -> $line {
      for ^$size -> $p {
        state $ones = 0;
        state @last = <x x x>;
        my $o = substr $line, $p, 1;
        $ones++ if $o eq '1';
        push @last, $o;
        next TOP if [eq] @last;
        LAST { next TOP unless $ones == $size/2 }
      }
    }
    take @s;
  }
}

sub inflate-puzzle(@pl,@in) {
  @in.map(-> $row {@pl.grep(/<$row>/)});
}

sub possible-solution(@fl) { gather for [X] @fl { .take } }


subset File of Str where { $_.IO ~~ :e & :f };

sub MAIN('test', File(File) :$datfile = "takuzu.dat") {
  use Test;

  my @Tests = slurp($datfile).chomp.split(/\n\n/).map(
    -> $input, $output { (:$input, :$output).Hash }
  );

  for @Tests[^1].kv -> $num, $test {

    my @in = split /\n/, $test<input>;
    my $size = @in.elems;

    say "Solving";
    say $test<input>;
    say "Size $size";

    my @pl = possible-lines($size);
    my @fl = inflate-puzzle(@pl,@in);
    my @ps = possible-solution(@fl);
    my @fs = test-solution(@ps);
    say "Solutions";
    my $found;
    for @fs -> @solution {
      state $first;
      $first = say "-" x 20 unless $first;
      $found = join "\n", @solution;
      $found.say;
    }
    is $found, $test<output>, "pass $num";
  }

  done-testing;
}
