#!/usr/bin/env perl6

constant $DEBUG = %*ENV<DEBUG>;

sub can-type-set(:@keys, :@wordlist) {
  my @sets = @keys».comb».map({$_,$_.uc}).flatmap(*.Set);
  @sets.say if $DEBUG;
  my @found = [0,[]] xx @sets;

  for @wordlist -> $word {
    state $i;
    $word.say if $i++ %% 1000 && $DEBUG;
    my $wordset = $word.comb.Set;
    for @sets.keys -> $i {
      if $wordset (<=) @sets[$i] && $word.chars >= @found[$i][0] {
        if $word.chars > @found[$i][0] {
          @found[$i] = [ $word.chars, [$word] ]
        }
        else {
          @found[$i][1].push: $word
        }
      }
    }
  }
  return @found.map(*.[1]);
}

sub can-type-regex(:@keys, :@wordlist) {
  # my @xbars = @keys».comb».join("|");
  my @xbars = @keys.map({ "<[$_]>+" });
  my @regexs = @xbars.map(-> $xbar {rx:i /^^ <$xbar> $$/});
  @regexs.say if $DEBUG;
  my @found = [0,[]] xx @xbars;

  for @wordlist -> $word {
    state $i;
    $word.say if $i++ %% 1000 && $DEBUG;
    for @regexs.keys -> $i {
      if $word ~~ @regexs[$i] && $word.chars >= @found[$i][0] {
        if $word.chars > @found[$i][0] {
          @found[$i] = [ $word.chars, [$word] ]
        }
        else {
          @found[$i][1].push: $word
        }
      }
    }
  }
  return @found.map(*.[1]);
}

sub can-type-slurp(:@keys, :$wordstring) {
  my @regex = @keys.map({ "<[$_]>+" });
  my @found = [0,[]] xx @regex;

  for @keys.keys -> $i {
    for $wordstring ~~ m:g:i {^^<$(@regex[$i])>$$} -> $match {
      my $word = ~$match;
      given $word.chars {
        when * > @found[$i][0] {
          @found[$i] = [ $word.chars, [$word] ]
        }
        when * == @found[$i][0] {
          @found[$i][1].push: $word
        }
      }
    }
  }

  return @found.map(*.[1]);
}

multi sub MAIN('test', 'slurp') {
  my @keys = <edcf bnik poil vybu>;
  my @words = can-type-slurp(
    :@keys,
    :wordstring(slurp "/usr/share/dict/words"),
  );
  for @keys Z, @words -> ( $k, $w ) {
    say "$k: $w.join(',')";
  }
}

multi sub MAIN('test', $type = 'regex') {
  my @keys = <edcf bnik poil vybu>;
  my %func = 'regex' => &can-type-regex, 'set' => &can-type-set;
  my @words = %func{$type}(
    :@keys,
    :wordlist("/usr/share/dict/words".IO.open.lines),
  );
  for @keys Z, @words -> ( $k, $w ) {
    say "$k: $w.join(',')";
  }
}
