#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 0;

sub possible-lines($size) {
  my $lower = gather loop { .take for <0 0 1> }
  my $upper = gather loop { .take for <1 1 0> }
  gather TOP:
  for :2($lower[^$size].join) .. :2($upper[^$size].join) -> $i {
    my $line = $i.fmt: "\%0{$size}b";
    next if $line ~~ / 000 | 111 /;
    next unless @($line ~~ m:g/1/).elems == $size/2;
    take $line;
  }
}

sub test-solution(@ps) {
  # @ps.say;
  gather TOP:
  for @ps -> @s {
    state $counter = 0;
    print '.';
    say $counter if $counter++ %% 1000;
    next TOP unless @s.Set.elems == @s.elems;
    my @T = ([Z] @s>>.comb)>>.join;
    my $size = @T.elems;
    for @T -> $line {
      next TOP if $line ~~ /000|111/;
      next TOP unless @($line ~~ m:g/1/).elems == $size/2;
      next TOP unless @T.Set.elems == @T.elems;
    }
    take @s;
  }
}

sub inflate-puzzle(@pl,@in) {
  # say "here: @pl[]";
  @in.map(-> $row {@pl.grep(/<$row>/)});
}

sub do-obvious(@in) {
  sub do-trans(@in) {
    for @in <-> $row {
      my $r = $row.=trans(
        < .00 0.0 00. .11 1.1 11. > =>
        < 100 010 001 011 101 110 >
      );
      if @($row ~~ m:g/\./).elems == 1 {
        my $c = @($row ~~ m:g/1/).elems;
        $row.=subst(/\./, $c == $row.chars/2 ?? 0 !! 1);
      }
    }
  }

  my @old;
  repeat {
    @old = @in;
    do-trans(@in);
    @in = ([Z] @in>>.comb)>>.join;
    do-trans(@in);
    @in = ([Z] @in>>.comb)>>.join;
    say join "\n", ([Z] @old, ' ' x 5 xx @old, @in)>>.join;
    say '-' x 24;
  } until @in ~~ @old;

  return ! [||] @in>>.match(/\./);
}

 sub possible-solution(@fl) { [X] @fl }


subset File of Str where { $_.IO ~~ :e & :f };

sub MAIN('test', File(File) :$datfile = "takuzu.dat") {
  use Test;

  my @Tests = slurp($datfile).chomp.split(/\n\n/).map(
    -> $input, $output { (:$input, :$output).Hash }
  );

  sub test(@in) {
    my $size = @in.elems;

    say "Solving";
    say @in;
    say "Size $size";

    my @pl = possible-lines($size);
    # say @pl;
    # is @pl, ('0011', '0101', '0110', '1001', '1010', '1100'), 'possibles';
    @in.join("\n").say;
    say '-' x $size, 'Obvious', '-' x $size;
    if do-obvious(@in) {
      say "SOLVED";
      @in.join("\n").say;
      return;
    }
    @in.join("\n").say;
    say "inflating";
    my @fl = inflate-puzzle(@pl,@in);
    # @fl.say;
    say "generating possibilities";
    # my $p = [*] @fl>>.elems;
    my $ps = possible-solution(@fl);
    say "looking at @p solutions";
    # @ps.say;
    my @fs = test-solution($ps).race;
    say "Solutions";
    my $found;
    for @fs -> @solution {
      $found = join "\n", @solution;
      $found.say;
      say "-" x 20;
    }
    # is $found, $test<output>, "pass $num";
  }

  test(split /\n/, @Tests[0]<input>);

  for @Tests[^3].kv -> $num, $test {
    my @in = split /\n/, $test<input>;
    test(@in);
  }

  done-testing;
}
