library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- Majority gate: the output is high whenever a majority of the inputs is high.
--
-- Inputs:
--    - a, b, c: Majority inputs.
-- Outputs:
--    - x: Majority output.
--------------------------------------------------------------------------------
entity majority3 is
    port(a, b, c: in std_logic;
         x      : out std_logic);
end entity;

architecture behaviour of majority3 is
begin
    x <= (a and b) or ((a xor b) and c);
end architecture;
