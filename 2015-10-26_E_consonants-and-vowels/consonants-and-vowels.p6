#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 1;

my @alphabet = 'a' .. 'z';
my @vowels = <a e i o u>;
my @consonants = @alphabet.grep({!/@vowels/});

my %generators =
  c => sub { @consonants.pick },
  v => sub { @vowels.pick },
;

sub validate-pattern($pattern) {
  $pattern ~~ rx:i / ^ (<[cv]>)+ { make [$0».Str] } /;
  my $good-chars = $/ ?? $/.chars !! 0;
  unless $good-chars == $pattern.chars {
    fail "bad input: " ~
      $pattern.substr(0,$good-chars+1) ~
      '*' ~
      $pattern.substr($good-chars+1) ~
      "\n(error before '*'" ~ "\n";
  }
  $/.made;
}

sub string-for($pattern) {
  my @pattern = validate-pattern($pattern);

  my @result-chars = do for @pattern -> $c {
    my $random-char = %generators{$c.lc}();
    $random-char.=uc if $c eq $c.uc;
    $random-char;
  }

  @result-chars.join;
}

sub MAIN(*@pattern) {
  @pattern or die "Usage: $*PROGRAM-NAME <pattern>+" ~ "\n";

  say string-for($_) for @pattern;
  # say string-for($pattern);

  CATCH { when * { say .message; exit; } }
}
