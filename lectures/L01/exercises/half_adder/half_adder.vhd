--------------------------------------------------------------------------------
-- Half adder implementation.
--
-- Inputs:
--    - a, b: Half adder inputs.
-- Outputs:
--    - sum  : Sum of the inputs.
--    - carry: Carry-bit from the addition.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
    port(a, b      : in std_logic;
         sum, carry: out std_logic);
end entity;

architecture behaviour of half_adder is
begin
    sum   <= a xor b;
    carry <= a and b;
end architecture;
