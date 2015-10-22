use v6;
unit module ParseEquation;

grammar G {
  rule TOP {
    ^^ <compound-list> '->' <compound-list> $$
  }
  rule compound-list { <compound>+ % \+ }
  rule compound { <coefficient>?<.ws>?<molecules> }
  rule molecules { <molecule>+ }
  token molecule { <part><subscript>? }
  token part {
    <atom>
    | '(' ~ ')' <molecules>
    | '[' ~ ']' <molecules>
  }
  token atom { <.upper><.lower>? }
  token coefficient { <.digit>+ }
  token subscript { <.digit>+ }
}

class A {
  method TOP($/) { make [ $<compound-list>».made ] }
  method compound-list($/) { make [ $<compound>».made ] }
  method compound($/) {
    make {
      :coefficient($<coefficient> ?? +$<coefficient>  !! 1),
      :compound($<molecules>.made),
      :repr($<molecules>.trim),
    };
  }
  method molecules($/) { make [(+)] $<molecule>».made }
  method molecule($/) {
    my $bag = $<part>.made;
    $bag{$_} *= $<subscript> // 1 for $bag.keys;
    make $bag;
  }
  method part($/) {
    make $<atom>
      ?? $<atom>.made
      !! $<molecules>.made.BagHash; # Bag -> BagHash
  }
  method atom($/) { make BagHash.new(~$/) }
}

sub parse-equation(Str $string) is export {
  G.new.parse($string, actions => A.new).made
}
