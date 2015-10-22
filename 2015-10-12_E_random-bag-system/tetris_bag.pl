#!/usr/bin/env perl
#
use v5.20;
use warnings;

use experimental qw( signatures postderef );

package BagOfReplenishing {

  use List::Util qw( shuffle );

  sub with_items($class, @items) {
    my $self = bless { items => [ @items ], bag => [], }, $class;
    $self;
  };

  sub _refill_maybe($self) {
    $self->{bag} = [ shuffle $self->{items}->@* ]
      unless $self->{bag}->@*;
    $self->{bag};
  }

  sub pick($self, $count) {
    my @items;
    while ($count-- > 0) {
      push @items, shift $self->_refill_maybe->@*;
    }
    @items;
  }

}

use Test::More;
use List::MoreUtils qw( uniq );

my @items = qw( O I S Z L J T );
my $tetris = BagOfReplenishing->with_items( @items );

sub sequence_ok {
  my @seq = @_;
  my $ok = 1;
  while (@seq >= @items) {
    my @chunk = splice @seq, 0, scalar @items;
    $ok = 0 unless @items == uniq @chunk;
  }
  $ok;
}

my @seq;

# NOTE: keep tests mod @items or 2nd+ tests will have duplicates.

@seq = $tetris->pick(49);
ok sequence_ok(@seq), join '', @seq;

@seq = $tetris->pick(49);
ok sequence_ok(@seq), join '', @seq;

@seq = $tetris->pick(49);
ok sequence_ok(@seq), join '', @seq;

@seq = $tetris->pick(49);
ok sequence_ok(@seq), join '', @seq;


# other sizes ok if start with a new bag

$tetris = BagOfReplenishing->with_items( @items );
@seq = $tetris->pick(50);
ok sequence_ok(@seq), join '', @seq;

$tetris = BagOfReplenishing->with_items( @items );
@seq = $tetris->pick(50);
ok sequence_ok(@seq), join '', @seq;

$tetris = BagOfReplenishing->with_items( @items );
@seq = $tetris->pick(50);
ok sequence_ok(@seq), join '', @seq;

done_testing;
