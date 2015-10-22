#!/usr/bin/env perl6

constant $DEBUG = True;

grammar box {
  token TOP { ^ <lines> $ }
  token lines { <line>+ % \n }
  token line { <thing>+ }
  token thing { <top-bottom> | <side> | <empty> }
  token top-bottom { '+' '-' * '+' }
  token side { '|' }
  token empty { ' ' + }
}

class box-actions {
  has $left = 0;
  has $depth = 0;
  has @open-box = ();

  method depth($c) {
    @open-box.grep({
      $_.defined && ( $_[0] < $c < $_[1] )
    }).elems
  }

  method TOP($/) { make $/<lines>.made }
  method lines($/) { make join "\n", $/<line>».made }
  method line($/) {
    $left = $/.to + 1;
    make [~] $/<thing>».made;
  }
  method thing($/) { make $/{*}.[0].made }
  method empty($/) { make ~self.depth( $/.from - $left ) x $/.chars }
  method side($/) { make ~$/ }
  method top-bottom($/) {
    my @span = $/.from-$left, $/.to-$left;
    if @open-box.pairs.grep({$_.value ~~ @span}) -> @p {
      my $i = @p[*-1].key;
      @open-box[$i]:delete;
    }
    else {
      @open-box.push: @span;
    }
    make ~$/
  }
}

subset File of Str where { $_.IO ~~ :e & :f };

sub MAIN('test', File(File) :$datfile = "heightmap.dat") {
  use Test;

  my @Tests = slurp($datfile).chomp.split(/\n\n/).map(
    -> $input, $output { (:$input, :$output).Hash }
  );

  for @Tests.kv -> $num, $test {

    my $B = box.new;
    ok $B.parse($test<input>), "parse: $num";

    my $p;
    my $actions = box-actions.new;

    ok $p = $B.parse($test<input>, :$actions), "parse actions: $num";
    is $p.made, $test<output>, "output: $num is correct";
  }

  done-testing;
}
