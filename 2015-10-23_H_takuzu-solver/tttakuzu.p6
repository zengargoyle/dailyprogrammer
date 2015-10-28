#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 0;

#| generates all valid lines for a puzzle of $size
sub possible-lines($size) is cached {
  my $lower = gather loop { .take for <0 0 1> }
  my $upper = gather loop { .take for <1 1 0> }
  do for :2($lower[^$size].join) .. :2($upper[^$size].join) -> $i {
    my $line = $i.fmt: "\%0{$size}b";
    next if $line ~~ / 000 | 111 /;
    next unless @($line ~~ m:g/1/).elems == $size/2;
    $line;
  }
}

sub is-solved(@in) {
  my $size = @in.elems;
  my $half = @in.elems / 2;
  return False if any @in».match('.');
  return False if any @in».match(/111|000/);
  return False unless $half == all @in».match('1',:g)».elems;
  return False unless @in.Set.elems == $size;
  my @copy = @in;
  transpose(@copy);
  return False if any @copy».match(/111|000/);
  return False unless $half == all @copy».match('1',:g)».elems;
  return False unless @copy.Set.elems == $size;
  True;
}

sub transpose(@in) {
  @in = ([Z] @in».comb)».join;
}

#| apply the 'no more than two in a row' rule
sub aab(@in) {
  .=trans(
    < .00 0.0 00. .11 1.1 11. > =>
    < 100 010 001 011 101 110 >
  ) for @in;
  @in;
}

#| one dot left can be determined
sub single(@in) {
  my $size = @in.elems;
  my $half = $size / 2;
  for @in <-> $row {
    if @($row ~~ m:g/\./).elems == 1 {
      my $ones = @($row ~~ m:g/1/).elems;
      $row.=subst('.', $ones == $half ?? '0' !! '1');
    }
  }
}

#
#
#

subset File of Str where { $_.IO ~~ :e & :f };

sub MAIN('test', File(File) :$datfile = "takuzu.dat") {
  use Test;

  my @Tests = slurp($datfile).chomp.split(/\n\n/).map(
    -> $input, $output { (:$input, :$output).Hash }
  );

  for @Tests[0]:kv -> $test-num, $test {

    say "Starting test $test-num with";
    say $test<input>;
    say "Expecting";
    say $test<output>;
    say '-' x 15;

    my @in = $test<input>.lines;

    #| valid solution arrive on this Channel
    my $solution = Channel.new;
    #| keep track of concurrent solve threads
    my @solvers;

    #| solve the given puzzle or create new solvers for easier puzzles
    sub solve(@in) {
      my @original;

      # apply rules both row and column wise until no more changes
      # can be made
      repeat {
        @original = @in;
        for 1,2 {
          aab(@in);
          single(@in);
          transpose(@in);
        }
      } until @original eqv @in;

      # yay, found a solution
      if is-solved(@in) {
        $solution.send(@in);
        return;
      }

      # find row with fewest number of dots
      my $mindot = @in.pairs.map({ $_.key => @($_.value ~~ m:g/\./).elems})\
        .sort(*.value).first(*.value > 0).key;
      return unless $mindot.defined;

      # find possible values for the row
      my @lines = possible-lines(@in.elems).grep(/<$(@in[$mindot])>/);
      # that aren't already being used (no duplicate rows)
      @lines = @lines.grep(* eq none @in);
      @lines.say if $DEBUG;

      # start a new solve task for each possible row
      for @lines -> $newline {
        @in[$mindot] = $newline;
        my @new = @in;
        say join "\n", "Solve restarting $mindot" if $DEBUG;

        @solvers.push: start { solve(@new) };
      }
    }

    # start initial solver
    @solvers.push: start { solve(@in) }

    # remove finished solvers and shutdown Channel when there are no more
    # solvers active
    my $reap = start {
      loop {
        my $done = await Promise.anyof: @solvers;
        @solvers = @solvers.grep(?!*);
        if !@solvers {
          $solution.close;
          last;
        }
      }
    }

    # gather and print solutions arriving on Channel
    loop {
      earliest $solution {
        more * {
          my $maybe = join "\n", |$_;
          my $found-solution = $maybe eq $test<output>;

          say join "\n",
            "Solution" ~ ($found-solution ?? " WOOOOOOOOO" !! ''),
            $maybe,
            '-' x 15;

          ok $found-solution, "found expected solution for case $test-num";
          # XXX exit early when testing the 3rd challenge input
          # it will exhaust the search in reasonable time on first two
          # challenges and hit the 'Finished' below.
          exit if $found-solution;
        }
        done * {
          say "Finished!";
          last;
        }
        wait 30 {
          say "Active solvers: @solvers.elems()";
        }
      }
    }
  }

  done-testing;
}
