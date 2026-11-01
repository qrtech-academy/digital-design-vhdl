--------------------------------------------------------------------------------
-- 3-bit XOR gate implementation.
--
-- Inputs:
--     - a, b, c: XOR gate inputs.
-- Outputs:
--     - x: XOR gate output.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity xor3 is
    port(a, b, c: in std_logic;
         x      : out std_logic);
end entity;

architecture behaviour of xor3 is
begin
    x <= a xor b xor c;
end architecture;
