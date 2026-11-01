--------------------------------------------------------------------------------
-- Implementation of an OR gate by using NAND gates.
--
-- Inputs:
--    a, b: OR gate inputs.
-- Outputs:
--    x: OR gate output.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity or_from_nand is
    port(a, b: in std_logic;
         x   : out std_logic);
end entity;

architecture behaviour of or_from_nand is
signal a_n, b_n: std_logic;
begin
    a_n <= a nand a;
    b_n <= b nand b;
    x   <= a_n nand b_n;
end architecture;
