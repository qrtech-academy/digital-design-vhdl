--------------------------------------------------------------------------------
-- 2-bit AND gate implementation.
--
-- Inputs:
--     - a, b: AND gate inputs.
-- Outputs:
--     - x: AND gate output.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity and_gate is
    port(a, b: in std_logic;
         x   : out std_logic);
end entity;

architecture behaviour of and_gate is
begin
    x <= a and b;
end architecture;
