#
# Tests
#
use v6;
unit module TestData;

sub test-data() is export {
  [
    {
      input => 'H2 + O2 -> H2O',
      output => '2 H2 + O2 -> 2 H2O',
      variables => <H O>,
      matrix => [
        [ 2, 0, 2 ],
        [ 0, 2, 1 ],
      ],
      solution => [ 2, 1, 2 ],
    },
    #
    # XXX - skip this example adding Charge to the balancing
    # {
    #   input => 'Ceqeqvvd + H+NO3- + H+OH- -> Cd++ + NO3- + NO',
    #   output => '3 Cd + 8 H+NO3- + -4 H+OH- -> 3 Cd++ + 6 NO3- + 2 NO',
    #   variables => <Cd H N O e>,
    #   matrix => [
    #     [ 1, 0, 0, -1, 0, 0 ], # Cd
    #     [ 0, 1, -2, 0, 0, 0 ], # H
    #     [ 0, 1, 0, 0, -1, 1 ], # N
    #     [ 0, 3, -1, 0, -3, 1 ], # O
    #     [ 0, 0, 0, -2, 1, 0 ], # charge
    #   ],
    #   solution => [ 3, 8, -4, 3, 6, 2 ],
    # },
    {
      input => 'CH4 + O2 -> CO2 + H2O',
      output => 'CH4 + 2 O2 -> CO2 + 2 H2O',
      variables => <C H O>,
      matrix => [
        [ 1, 0, -1, 0 ],
        [ 4, 0, 0, 2 ],
        [ 0, 2, -2, 1 ],
      ],
      solution => [ 1, 2, 1, 2 ],
    },
    {
      input => 'P2I4 + P4 + H2O -> PH4I + H3PO4',
      output => '10 P2I4 + 13 P4 + 128 H2O -> 40 PH4I + 32 H3PO4',
      variables => <P I H O>,
      matrix => [
        [ 2, 4, 0, -1, 1],  #P
        [ 4, 0, 0, -1, 0], #I
        [ 0, 0, 2, -4, 3], #H
        [ 0, 0, 1, -0, 4], #O
      ],
      solution => [ 10, 13, 128, 40, 32 ],
    },
    #
    # from the challenge
    #
    {
      input => 'C5H12 + O2 -> CO2 + H2O',
      output => 'C5H12 + 8 O2 -> 5 CO2 + 6 H2O',
      matrix => [
        [ 5, 0, -1, 0 ],
        [ 12, 0, 0, 2 ],
        [ 0, 2, -2, 1 ],
      ],
      solution => [ 1, 8, 5, 6 ],
    },
    {
      input => 'Zn + HCl -> ZnCl2 + H2',
      output => 'Zn + 2 HCl -> ZnCl2 + H2',
      matrix => [
        [ 1, 0, -1, 0 ],
        [ 0, 1, 0, 2 ],
        [ 0, 1, -2, 0 ],
      ],
      solution => [ 1, 2, 1, 1 ],
    },
    {
      input => 'Ca(OH)2 + H3PO4 -> Ca3(PO4)2 + H2O',
      output => '3 Ca(OH)2 + 2 H3PO4 -> Ca3(PO4)2 + 6 H2O',
      solution => [ 3, 2, 1, 6 ],
    },
    {
      input => 'FeCl3 + NH4OH -> Fe(OH)3 + NH4Cl',
      output => 'FeCl3 + 3 NH4OH -> Fe(OH)3 + 3 NH4Cl',
      solution => [ 1, 3, 1, 3 ],
    },
    {
      input => 'K4[Fe(SCN)6] + K2Cr2O7 + H2SO4 -> Fe2(SO4)3 + Cr2(SO4)3 + CO2 + H2O + K2SO4 + KNO3',
      output => '6 K4[Fe(SCN)6] + 97 K2Cr2O7 + 355 H2SO4 -> 3 Fe2(SO4)3 + 97 Cr2(SO4)3 + 36 CO2 + 355 H2O + 91 K2SO4 + 36 KNO3',
      solution => [ 6, 97, 355, 3, 97, 36, 355, 91, 36 ],
    },
  ];
}
