--------------------------------------------------------------------------------
-- Advanced Driver Assistance System (ADAS) for a vehicle.
--
-- Inputs:
--    - driver_brake: The driver is on the brake pedal.
--    - sensor      : The object in front of the vehicle is approaching.
--    - camera      : There is an object in front of the vehicle.
--    - error       : The assistance system is reporting a fault.
-- Outputs:
--     - engine_brake: Apply the brakes.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity adas is
    port(driver_brake, sensor, camera, error: in std_logic;
         engine_brake                       : out std_logic);
end entity;

architecture behaviour of adas is
signal adas_brake: std_logic;
begin
    adas_brake   <= sensor and camera and (not error);
    engine_brake <= driver_brake or adas_brake;
end architecture;
