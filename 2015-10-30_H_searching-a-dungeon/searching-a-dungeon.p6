#!/usr/bin/env perl6
use v6;

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
(-1,0), (1,0), (0,-1), (0,1);
# (-1,-1), (-1,1), (-1,-1), (1,1),
# (-1,0), (1,0), (0,-1), (0,1);

sub print-map($map) {
  say join "\n\n", $map.map: -> $f { join "\n", $f.map: -> $r { $r.join } };
}

#| for want of @array[@multi]
sub at-loc($map,$loc) is rw { $map[$loc[0]][$loc[1]][$loc[2]] }

sub make-step($loc,$step) { (@$loc Z+ @$step) }

# only move through U, D, G, and empty
# take U, D, G as soon as possible.  for empty, collect all
# and then take in order of distance to travel.
sub open-steps($map,$loc) {
  my (@cand);
  gather for @directions -> $d {
    my $next = make-step($loc,(0,|@$d));
    given at-loc($map,$next) {
      when 'D' { @cand=(); take make-step($next, (1,0,0)) }
      when 'U' { @cand=(); take make-step($next, (-1,0,0)) }
      when 'G' { @cand=(); take $next }
      when ' ' { push @cand, ($next, $d) }
    }
    LAST {
      if @cand {
        my @c = @cand.sort({
          $_[1][0]*$_[1][0] + $_[1][1]*$_[1][1]
        });
        for @c.map(*.[0]) { .take }
      }
    }
  }
}

my ($dungeon-text, $solution-text) = 'map3.dat'.IO.slurp.split(/^^\-+\n/);
my ($locations, $map) = D.new.parse($dungeon-text).made<locations map>;

my $start = $locations<S>[0];
my @stack = $start;
my %visited = $start => $start;
my $here;

my $last-floor;
my @found-paths;

c_save;
c_erase;

while @stack {
  $here = pop @stack;

  if !$last-floor.defined || $last-floor !== $here[0] {
    $last-floor = $here[0];
    c_print-at(0,0,'');
    print-map($map);
  }
  c_blink-at(|$here[1,2], '*', '*');
  sleep 0.1;

  # last if at-loc($map,$here) eq 'G';
  if at-loc($map,$here) eq 'G' {
    my @path = $here;
    loop {
      $here = %visited{~$here};
      push @path, $here;
      last if $here ~~ $start;
    }
    push @found-paths, @path;
    # @stack = $start;
    next;
  }

  for open-steps($map,$here) -> $step {
    next if %visited{~$step}:exists;
    %visited{~$step} = $here;
    push @stack, $step;
  }
}

c_restore;

$here = $locations<G>[0];
loop {
  $here = %visited{~$here};
  last if $here ~~ $start;
  at-loc($map,$here) = '*';
}

print-map($map);
.say for @found-paths;
