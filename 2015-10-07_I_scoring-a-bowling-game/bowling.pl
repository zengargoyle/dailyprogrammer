#!/usr/bin/env perl
use v5.16;
use warnings;

my $Tests;
while (<DATA>) {
  chomp;
  my ($score,$sheet) = split ' ', $_, 2;
  push @$Tests, { sheet => $sheet, score => $score };
}

use Test::More;
for my $t (@$Tests) {
  is score_sheet($t->{sheet}), $t->{score}, $t->{sheet};
}
done_testing;

sub score_sheet {
  my @balls;
  for (split //, shift) {
    if( m{   X  }x ) { push @balls, 10 }
    if( m{   /  }x ) { push @balls, 10 - $balls[-1] }
    if( m{ (\d) }x ) { push @balls, $1 }
    if( m{   -  }x ) { push @balls, 0 }
  }
  my ($ball, $score) = (0,0);
  for (my $i = 0; $i < 10; $i++) {
    if( $balls[$ball] == 10 ) {
      $score += $balls[$ball] + $balls[$ball+1] + $balls[$ball+2];
      $ball += 1;
    }
    else {
      if( ($balls[$ball] + $balls[$ball+1]) == 10 ) {
        $score += $balls[$ball] + $balls[$ball+1] + $balls[$ball+2];
      }
      else {
        $score += $balls[$ball] + $balls[$ball+1];
      }
      $ball += 2;
    }
  }
  return $score;
}

__END__
300	X X X X X X X X X XXX
137	X -/ X 5- 8/ 9- X 81 1- 4/X
140	62 71 X 9- 8/ X X 35 72 5/8
168	X 7/ 72 9/ X X X 23 6/ 7/3
247	X X X X 9/ X X 9/ 9/ XXX
149	8/ 54 9- X X 5/ 53 63 9/ 9/X
167	X 7/ 9- X -8 8/ -6 X X X81
187	X 9/ 5/ 72 X X X 9- 8/ 9/X
280	X -/ X X X X X X X XXX
280	X 1/ X X X X X X X XXX
280	X 2/ X X X X X X X XXX
280	X 3/ X X X X X X X XXX
280	X 4/ X X X X X X X XXX
280	X 5/ X X X X X X X XXX
280	X 6/ X X X X X X X XXX
280	X 7/ X X X X X X X XXX
280	X 8/ X X X X X X X XXX
280	X 9/ X X X X X X X XXX
280	-/ X X X X X X X X XX-
280	1/ X X X X X X X X XX-
280	2/ X X X X X X X X XX-
280	3/ X X X X X X X X XX-
280	4/ X X X X X X X X XX-
280	5/ X X X X X X X X XX-
280	6/ X X X X X X X X XX-
280	7/ X X X X X X X X XX-
280	8/ X X X X X X X X XX-
280	9/ X X X X X X X X XX-
280	X X X X X X X X X X-/
280	X X X X X X X X X X18
280	X X X X X X X X X X26
280	X X X X X X X X X X34
280	X X X X X X X X X X42
280	X X X X X X X X X X5-
281	-/ X X X X X X X X XX1
281	1/ X X X X X X X X XX1
281	2/ X X X X X X X X XX1
281	3/ X X X X X X X X XX1
281	4/ X X X X X X X X XX1
281	5/ X X X X X X X X XX1
281	6/ X X X X X X X X XX1
281	7/ X X X X X X X X XX1
281	8/ X X X X X X X X XX1
281	9/ X X X X X X X X XX1
281	X X X X X X X X X X1/
281	X X X X X X X X X X27
281	X X X X X X X X X X35
281	X X X X X X X X X X43
281	X X X X X X X X X X51
