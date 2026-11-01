--------------------------------------------------------------------------------
-- 2-bit NAND gate implementation.
--
-- Inputs:
--     - a, b: NAND gate inputs.
-- Outputs:
--     - x: NAND gate output.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity nand_gate is
    port(a, b: in std_logic;
         x   : out std_logic);
end entity;

architecture behaviour of nand_gate is
begin
    x <= a nand b;
end architecture;
