--------------------------------------------------------------------------------
-- Self-checking testbench for adas (the braking assistant from Appendix A.6).
--
-- Write your own adas.vhd in THIS directory, then run:
--   ghdl -a --std=93 adas.vhd adas_tb.vhd
--   ghdl -e --std=93 adas_tb
--   ghdl -r --std=93 adas_tb --assert-level=error --stop-time=10ms
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adas_tb is
end entity;

architecture behaviour of adas_tb is
constant INPUT_WIDTH: natural := 4;
constant INPUT_MAX  : natural := 2**INPUT_WIDTH - 1;
constant WAIT_NS    : time := 10 ns;

-- The expected output for every input combination, transcribed from A.6's truth table and
-- indexed by (driver_brake, sensor, radar, error) read as a 4-bit number.
--
-- The other testbenches in this lecture restate their rule as an expression, which works
-- when the rule is one operator wide. This one is a table on purpose: an expression here
-- would be the same four gates the module under test is supposed to contain, so it would
-- agree with a wrong design that made the same mistake. The requirement, written out row by
-- row, cannot.
constant EXPECTED: std_logic_vector(0 to INPUT_MAX) := "0010101011111111";

signal driver_brake, sensor, radar, error, engine_brake: std_logic;
begin
    dut: entity work.adas
        port map(driver_brake, sensor, radar, error, engine_brake);

    SIM_PROCESS: process is
    begin
        for i in 0 to INPUT_MAX loop
            (driver_brake, sensor, radar, error) <=
                std_logic_vector(to_unsigned(i, INPUT_WIDTH));
            wait for WAIT_NS;
            assert engine_brake = EXPECTED(i)
                report "adas: wrong output at i = " & integer'image(i)
                     & " (driver_brake=" & std_logic'image(driver_brake)
                     & " sensor=" & std_logic'image(sensor)
                     & " radar=" & std_logic'image(radar)
                     & " error=" & std_logic'image(error)
                     & "), expected " & std_logic'image(EXPECTED(i))
                     & " but got " & std_logic'image(engine_brake) & "!"
                severity failure;
        end loop;
        report "adas: all checks passed!" severity note;
        wait;
    end process;
end architecture;
