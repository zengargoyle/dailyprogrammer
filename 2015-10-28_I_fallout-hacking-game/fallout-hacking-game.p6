#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 1;

# most favorite one pass random picker
class RandomAccumulator {
  has $.value;
  has $!count = 0;
  method accumulate($input) {
    $!value = $input if rand < 1 / ++$!count;
    self;
  }
}

# get count random words with some filtering
sub random-words(
  Int :$count = 1,
  Int :$length = 5,
  Regex :$match = rx/^<:Letter>+$/,
) {
  my @acc = RandomAccumulator.new xx $count;
  for "/usr/share/dict/words".IO.lines.grep(*.chars == $length)\
    .grep($match) -> $word {
    .accumulate($word) for @acc;
  }
  @acc.map: *.value;
}

sub count-matching-chars(Str $a, Str $b) {
  ($a.comb Zeq $b.comb).grep(?*).elems
}

sub MAIN {

  my $difficulty;

  repeat {
    $difficulty = prompt("Difficulty (1-5): ");
  } until 1 <= $difficulty <= 5;

  # first pass at difficulty levels, tweak as desired
  # maybe pick count/length as some function of $difficulty
  my %level =
    1 => ( count => 5, length => 4 ),
    2 => ( count => 5, length => 4 ),
    3 => ( count => 5, length => 4 ),
    4 => ( count => 5, length => 4 ),
    5 => ( count => 15, length => 15 ),
    ;

  # |% -> named; |@ -> positional
  my @words = random-words(|%level{$difficulty}.hash).map(*.fc);
  my $target = @words.pick;
  say "target: $target" if $DEBUG;

  @words.join("\n").say;

  my $won = False;
  for ^4 {
    my $guess = fc prompt "Guess ({4-$_} left): ";
    if ($guess eq $target) { $won = True; last }
    say "You got &count-matching-chars($guess,$target) characters correct.";
  }

  if $won {
    say "You won!";
  }
  else {
    say "You loose!";
  }

}
