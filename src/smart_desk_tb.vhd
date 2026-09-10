library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity smart_desk_tb is
end smart_desk_tb;

architecture tb of smart_desk_tb is

  -- DUT inputs
  signal clk_tb          : std_logic := '0';
  signal rst_n_tb        : std_logic := '0';
  signal presence_raw_tb : std_logic := '1';   -- PIR idle (active?low)
  signal btn_open_tb     : std_logic := '0';
  signal btn_close_tb    : std_logic := '0';
  signal light_dark_tb   : std_logic := '1';   -- bright

  -- DUT outputs
  signal led_on_tb    : std_logic_vector(9 downto 0);
  signal pwm_servo_tb : std_logic;
  signal seg_units_tb : std_logic_vector(6 downto 0);
  signal seg_tens_tb  : std_logic_vector(6 downto 0);

begin

  --------------------------------------------------------------------
  -- Instantiate DUT
  --------------------------------------------------------------------
  uut : entity work.smart_desk
    port map (
      clk          => clk_tb,
      rst_n        => rst_n_tb,
      presence_raw => presence_raw_tb,
      btn_open     => btn_open_tb,
      btn_close    => btn_close_tb,
      light_dark   => light_dark_tb,
      led_on       => led_on_tb,
      pwm_servo    => pwm_servo_tb,
      seg_units    => seg_units_tb,
      seg_tens     => seg_tens_tb
    );

  --------------------------------------------------------------------
  -- 50 MHz clock (20 ns period)
  --------------------------------------------------------------------
  clk_process : process
  begin
    clk_tb <= '0';
    wait for 10 ns;
    clk_tb <= '1';
    wait for 10 ns;
  end process;

  --------------------------------------------------------------------
  -- Test sequence
  --------------------------------------------------------------------
  stim : process
  begin
    ----------------------------------------------------------------
    -- RESET
    ----------------------------------------------------------------
    rst_n_tb <= '0';
    wait for 200 ns;
    rst_n_tb <= '1';
    wait for 200 ns;

    ----------------------------------------------------------------
    -- PIR detects person (active?low)
    ----------------------------------------------------------------
    presence_raw_tb <= '0';   -- person detected
    wait for 200 ms;          -- allow drawer to open + servo to move

    ----------------------------------------------------------------
    -- PIR goes idle (person leaves)
    ----------------------------------------------------------------
    presence_raw_tb <= '1';
    wait for 200 ms;

    ----------------------------------------------------------------
    -- Person returns
    ----------------------------------------------------------------
    presence_raw_tb <= '0';
    wait for 200 ms;

    ----------------------------------------------------------------
    -- Manual open button
    ----------------------------------------------------------------
    btn_open_tb <= '1';
    wait for 40 ns;
    btn_open_tb <= '0';
    wait for 200 ms;

    ----------------------------------------------------------------
    -- Manual close button
    ----------------------------------------------------------------
    btn_close_tb <= '1';
    wait for 40 ns;
    btn_close_tb <= '0';
    wait for 200 ms;

    ----------------------------------------------------------------
    -- End simulation
    ----------------------------------------------------------------
    wait;
  end process;

end tb;
