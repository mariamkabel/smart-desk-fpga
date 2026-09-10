-- =======================
-- SERVO DRIVER (UNCHANGED)
-- =======================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_driver is
  port (
    clk         : in  std_logic;   -- 50 MHz system clock
    rst_n       : in  std_logic;   -- active-low reset
    drawer_open : in  std_logic;   -- flag from smart desk logic
    pwm_servo   : out std_logic    -- PWM output to SG90 control pin
  );
end servo_driver;

architecture arch_servo of servo_driver is
  -- Constants for 50 Hz PWM at 50 MHz clock
  constant CLK_FREQ        : integer := 50_000_000;
  constant PWM_FREQ        : integer := 50; -- 50 Hz
  constant PERIOD_TICKS    : integer := CLK_FREQ / PWM_FREQ; -- 1,000,000 cycles

  -- Pulse width bounds (ticks)
  constant PULSE_MIN_TICKS : integer := 50_000;   -- ~1.0 ms (0°)
  constant PULSE_MAX_TICKS : integer := 100_000;  -- ~2.0 ms (180°)

  -- Angle selection for open/close
  constant CLOSE_DEG       : integer := 0;    -- drawer closed
  constant OPEN_DEG        : integer := 180;  -- drawer fully open

  -- Internal signals
  signal angle_deg   : integer range 0 to 180 := CLOSE_DEG;
  signal high_ticks  : integer range PULSE_MIN_TICKS to PULSE_MAX_TICKS := PULSE_MIN_TICKS;
  signal cnt         : integer range 0 to PERIOD_TICKS := 0;
begin

  process(clk, rst_n)
    variable span : integer := PULSE_MAX_TICKS - PULSE_MIN_TICKS;
  begin
    if rst_n = '0' then
      angle_deg  <= CLOSE_DEG;
      high_ticks <= PULSE_MIN_TICKS;
      cnt        <= 0;
      pwm_servo  <= '0';
    elsif rising_edge(clk) then
      -- Select angle based on drawer_open flag
      if drawer_open = '1' then
        angle_deg <= OPEN_DEG;   -- 180° fully open
      else
        angle_deg <= CLOSE_DEG;  -- 0° closed
      end if;

      -- Compute pulse width from current angle
      high_ticks <= PULSE_MIN_TICKS + (angle_deg * span) / 180;

      -- PWM counter for 20 ms frame
      if cnt = PERIOD_TICKS - 1 then
        cnt <= 0;
      else
        cnt <= cnt + 1;
      end if;

      -- PWM output: HIGH during first high_ticks cycles
      if cnt < high_ticks then
        pwm_servo <= '1';
      else
        pwm_servo <= '0';
      end if;
    end if;
  end process;

end arch_servo;