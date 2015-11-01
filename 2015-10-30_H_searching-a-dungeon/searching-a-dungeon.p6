#!/usr/bin/env perl6
use v6;

constant draw-delay = @*ARGS[0] // 0;

# simple ANSI drawing.  &c_blink-at is mostly bogus
sub c_save { print "\e7" }
sub c_restore { print "\e8" }
sub c_erase { print "\e[2J" }
sub c_print-at($r,$c,$s) { print "\e[{$r+1};{$c+1}H{$s}" }
sub c_blink-at($r,$c,$s,$ss = ' ') { state ($rr,$cc);
  if $rr.defined { c_print-at($rr,$cc,$ss); }; $rr = $r; $cc = $c;
  c_print-at($r,$c,$s);
}

grammar D {
  my ($floor,$row,$col) = 0 xx *;
  my %locations;
  rule TOP {
    ^ <floor>+ % \n \n? $
    { make { :%locations, :map([ $<floor>».made ]) } }
  }
  token floor {
    ^^ <row>+ % \n $$
    { make [ $<row>».made ]; $floor++; $row = 0 }
  }
  token row {
    <square>+
    { make [ $<square>».Str ]; $row++; $col = 0 }
  }
  token square {
    $<square>=<[\h\*\#SGUD]>
    {
      if $<square> eq any <S G U D> {
        %locations{$<square>}.push: [$floor,$row,$col];
      }
      $col++
    }
  }
}

my @directions =
  (-1,-1), (-1, 0), (-1, 1),
  ( 0,-1),          ( 0, 1),
  ( 1,-1), ( 1, 0), ( 1, 1),
;

sub print-map($map) {
  say join "\n\n", $map.map: -> $f { join "\n", $f.map: -> $r { $r.join } };
}

# XXX - for want of @array[@multi]
sub at-loc($map,$loc) is rw { $map[$loc[0]][$loc[1]][$loc[2]] }

sub make-step($loc,$step) { (@$loc Z+ @$step) }

# only move through U, D, G, and <space>
# take G, U, D first, then any <space>.
# XXX - can probably be cleaner

sub open-steps($map,$loc) {
  my (@cand);
  for @directions -> $d {
    my $next = make-step($loc,(0,|@$d));
    given at-loc($map,$next) {
      when 'D'     { push @cand, ($_, make-step($loc, ( 1,|@$d)) ) }
      when 'U'     { push @cand, ($_, make-step($loc, (-1,|@$d)) ) }
      when 'G'|' ' { push @cand, ($_, $next                      ) }
    }
  }
  |@cand.grep(*.[0] eq 'G'    ).map(*.[1]),
  |@cand.grep(*.[0] eq 'U'|'D').map(*.[1]),
  |@cand.grep(*.[0] eq ' '    ).map(*.[1]),
  ;
}

my ($dungeon-text, $solution-text) = 'map2.dat'.IO.slurp.split(/^^\-+\n/);
my ($locations, $map) = D.new.parse($dungeon-text).made<locations map>;

my $start = $locations<S>[0];
my @stack = $start;
my %visited = $start => $start;
my $here;

while @stack {
  state $last-floor;
  once {
    c_save; c_erase;
    $last-floor = @stack[*-1][0];
    c_print-at(0,0,''); print-map([$map[$last-floor]]);
  }
  LAST { c_restore; }

  $here = pop @stack;

  if $last-floor !== $here[0] {
    $last-floor = $here[0];
    c_print-at(0,0,'');
    print-map([$map[$last-floor]]);
  }

  c_blink-at(|$here[1,2], '*', '*'); sleep draw-delay;

  last if at-loc($map,$here) eq 'G';

  for open-steps($map,$here) -> $step {
    next if %visited{~$step}:exists;
    %visited{~$step} = $here;
    unshift @stack, $step;
  }
}

my @path;
loop {
  push @path, $here;
  $here = %visited{~$here};
  last if $here ~~ $start;
  at-loc($map,$here) = '*';
}
push @path, $here;

print-map($map);
@path.say;
