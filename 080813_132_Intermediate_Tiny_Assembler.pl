#!/usr/bin/env perl
use strict;
use warnings;

use Try::Tiny;

my $input = <<_END;
Mov [2] 0
Mov [3] 0
Jeq 6 [3] [1]
Add [3] 1
Add [2] [0]
Jmp 2
Mov [0] [2]
Halt
_END

my $expected_output = <<_END;
0x08 0x02 0x00
0x08 0x03 0x00
0x15 0x06 0x03 0x01
0x0B 0x03 0x01
0x0A 0x02 0x00
0x0F 0x02
0x07 0x00 0x02
0xFF
_END

my $op_table = {
  AND => {
    # 0x00 [a] [b]
    # 0x01 [a] b
    mode => {
      '11' => 0x00,
      '10' => 0x01,
    },
  },
  OR => {
    # 0x02 [a] [b]
    # 0x03 [a] b
    mode => {
      '11' => 0x02,
      '10' => 0x03,
    },
  },
  XOR => {
    # 0x04 [a] [b]
    # 0x05 [a] b
    mode => {
      '11' => 0x04,
      '10' => 0x05,
    },
  },
  NOT => {
    # 0x06 [a]
    mode => {
      '1' => 0x06,
    },
  },
  MOV => {
    # 0x07 [a] [b]
    # 0x08 [a] b
    mode => {
      '11' => 0x07,
      '10' => 0x08,
    },
  },
  RANDOM => {
    # 0x09 [a]
    mode => {
      '1' => 0x09,
    },
  },
  ADD => {
    # 0x0a [a] [b]
    # 0x0b [a] b
    mode => {
      '11' => 0x0a,
      '10' => 0x0b,
    },
  },
  SUB => {
    # 0x0c [a] [b]
    # 0x0d [a] b
    mode => {
      '11' => 0x0c,
      '10' => 0x0d,
    },
  },
  JMP => {
    # 0x0e [x]
    # 0x0f x
    mode => {
      '1' => 0x0e,
      '0' => 0x0f,
    },
  },
  JZ => {
    # 0x10 [x] [a]
    # 0x11 [x] a
    # 0x12 x [a]
    # 0x13 x a
    mode => {
      '11' => 0x10,
      '10' => 0x11,
      '01' => 0x12,
      '00' => 0x13,
    },
  },
  JEQ => {
    # 0x14 [x] [a] [b]
    # 0x15 x [a] [b]
    # 0x16 [x] [a] b
    # 0x17 x [a] b
    mode => {
      '111' => 0x14,
      '011' => 0x15,
      '110' => 0x16,
      '010' => 0x17,
    },
  },
  JLS => {
    # 0x18 [x] [a] [b]
    # 0x19 x [a] [b]
    # 0x1a [x] [a] b
    # 0x1b x [a] b
    mode => {
      '111' => 0x18,
      '011' => 0x19,
      '110' => 0x1a,
      '010' => 0x1b,
    },
  },
  JGT => {
    # 0x1c [x] [a] [b]
    # 0x1d x [a] [b]
    # 0x1e [x] [a] b
    # 0x1f x [a] b
    mode => {
      '111' => 0x1c,
      '011' => 0x1d,
      '110' => 0x1e,
      '010' => 0x1f,
    },
  },
  HALT => {
    # 0xff
    mode => 0xff,
  },
  APRINT => {
    # 0x20 [a]
    # 0x21 a
    mode => {
      '1' => 0x20,
      '0' => 0x21,
    },
  },
  DPRINT => {
    # 0x22 [a]
    # 0x23 a
    mode => {
      '1' => 0x22,
      '0' => 0x23,
    },
  },
};

open my $fh, '<', \$input;
while (<$fh>) {
  my ($op, @args) = split;
  my $opmap = $op_table->{uc $op} or die "$op is not an op at line $.\n";
  my ($op_code, $arg_types, $arg_vals);
  try {
    ($op_code, $arg_types, $arg_vals) = get_op( $opmap,  @args );
  }
  catch {
    use Data::Dump; dd [ types => $arg_types ];
    my @types = @$_;
    die "$op does not support ".
      join( ' ', map { $_ ? '[?]' : '?' } @$_ ).
      " at line $.\n";
  };
  print join( ' ', map { sprintf "0x%02X", $_ } $op_code, @$arg_vals ), "\n";
}

use Params::Util qw( _HASH );

sub get_op {
  my $opmap = shift;
  my $mode = $opmap->{mode};
  if ( ! _HASH($mode) ) {
    return ($mode, [], [] );
  }
  my @types = map { /\[/ ? 1 : 0 } @_;
  #use Data::Dump; dd [ types => \@types ];
  my $opcode = $mode->{ join '', @types }
    or die \@types;
  my @vals = map { my ($v) = /(\d+)/; $v } @_;
  #use Data::Dump; dd [ vals => [ @_, "@_", \@vals ] ];
  return ($opcode, \@types, \@vals);
}

__END__
Group   Instruction   Byte Code   Description
1. Logic  AND a b   2 Ops, 3 bytes:   M[a] = M[a] bit-wise and M[b]
    0x00 [a] [b]
    0x01 [a] b
  OR a b  2 Ops, 3 bytes:   M[a] = M[a] bit-wise or M[b]
    0x02 [a] [b]
    0x03 [a] b
  XOR a b   2 Ops, 3 bytes:   M[a] = M[a] bit-wise xor M[b]
    0x04 [a] [b]
    0x05 [a] b
  NOT a   1 Op, 2 bytes:  M[a] = bit-wise not M[a]
    0x06 [a]
2. Memory   MOV a b   2 Ops, 3 bytes:   M[a] = M[b], or the literal-set M[a] = b
    0x07 [a] [b]
    0x08 [a] b
3. Math   RANDOM a  2 Ops, 2 bytes:   M[a] = random value (0 to 25; equal probability distribution)
    0x09 [a]
  ADD a b   2 Ops, 3 bytes:   M[a] = M[a] + b; no overflow support
    0x0a [a] [b]
    0x0b [a] b
  SUB a b   2 Ops, 3 bytes:   M[a] = M[a] - b; no underflow support
    0x0c [a] [b]
    0x0d [a] b
4. Control  JMP x   2 Ops, 2 bytes:   Start executing instructions at index of value M[a] (So given a is zero, and M[0] is 10, we then execute instruction 10) or the literal a-value
    0x0e [x]
    0x0f x
  JZ x a  4 Ops, 3 bytes:   Start executing instructions at index x if M[a] == 0 (This is a nice short-hand version of )
    0x10 [x] [a]
    0x11 [x] a
    0x12 x [a]
    0x13 x a
  JEQ x a b   4 Ops, 4 bytes:   Jump to x or M[x] if M[a] is equal to M[b] or if M[a] is equal to the literal b.
    0x14 [x] [a] [b]
    0x15 x [a] [b]
    0x16 [x] [a] b
    0x17 x [a] b
  JLS x a b   4 Ops, 4 bytes:   Jump to x or M[x] if M[a] is less than M[b] or if M[a] is less than the literal b.
    0x18 [x] [a] [b]
    0x19 x [a] [b]
    0x1a [x] [a] b
    0x1b x [a] b
  JGT x a b   4 Ops, 4 bytes:   Jump to x or M[x] if M[a] is greater than M[b] or if M[a] is greater than the literal b.
    0x1c [x] [a] [b]
    0x1d x [a] [b]
    0x1e [x] [a] b
    0x1f x [a] b
  HALT  1 Op, 1 byte:   Halts the program / freeze flow of execution
    0xff
5. Utilities  APRINT a  4 Ops, 2 byte:  Print the contents of M[a] in either ASCII (if using APRINT) or as decimal (if using DPRINT). Memory ref or literals are supported in both instructions.
  DPRINT a  0x20 [a] (as ASCII; aprint)
    0x21 a (as ASCII)
    0x22 [a] (as Decimal; dprint)
    0x23 a (as Decimal)


