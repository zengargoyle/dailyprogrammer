#!/usr/bin/env perl6
use v6;

# use NCurses;
# my $win;
# my @last;
# my $f;
# sub nc_init { $win = initscr; die "no ncurses\n" unless $win.defined; }
# sub nc_level($map,$floor) {
#   clear;
#   $f = $map[$floor];
#   @last = 0, 0, $f[0][0];
#   for $f.kv -> $i, $r {
#     mvaddstr( $i, 0, $r.join );
#   }
#   nc_refresh;
# }
# sub nc_quit {
#   endwin;
# }
# sub nc_move($r,$c) {
#   mvaddstr( |@last );
#   @last = $r, $c, $f[$r][$c];
#   mvaddstr( $r, $c, '*' );
#   nc_refresh;
# }

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
(-1,-1), (-1,1), (-1,-1), (1,1),
(-1,0), (1,0), (0,-1), (0,1);

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

my ($dungeon-text, $solution-text) = 'map2.dat'.IO.slurp.split(/^^\-+\n/);
my ($locations, $map) = D.new.parse($dungeon-text).made<locations map>;

my $start = $locations<S>[0];
my @stack = $start;
my %visited = $start => $start;
my $here;

my $last-floor = $start[0];
# nc_init;
# nc_level($map,$last-floor);
# nc_move($start[1], $start[2]);
while @stack {
  $here = pop @stack;
  if $here[0] !== $last-floor {
    # nc_level($map,$here[0]);
    $last-floor = $here[0];
  }
  # nc_move($here[1],$here[2]); sleep 0.9;
  last if at-loc($map,$here) eq 'G';
  for open-steps($map,$here) -> $step {
    next if %visited{~$step}:exists;
    %visited{~$step} = $here;
    push @stack, $step;
  }
}

# nc_quit;

loop {
  $here = %visited{~$here};
  last if $here ~~ $start;
  at-loc($map,$here) = '*';
}

print-map($map);
