-- =======================
-- YOUR ORIGINAL CODE (WITH UNNEEDED PARTS COMMENTED OUT)
-- =======================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity smart_desk is
  port (
    clk          : in  std_logic;   -- 50 MHz clock
    rst_n        : in  std_logic;   -- active-low reset

    presence_raw : in  std_logic;  -- PIR sensor (raw)
    btn_open     : in  std_logic;  -- manual open button
    btn_close    : in  std_logic;  -- manual close button
    light_dark   : in  std_logic;  -- digital LDR output (0=dark, 1=bright)

    led_on       : out std_logic_vector(9 downto 0);  -- LED control
    pwm_servo    : out std_logic;  -- PWM to SG90 servo

    seg_units    : out std_logic_vector(6 downto 0);
    seg_tens     : out std_logic_vector(6 downto 0)
  );
end smart_desk;

architecture arch_smart_desk of smart_desk is

  signal presence_s1        : std_logic;
  signal presence_s2        : std_logic;

  signal presence_prev_drawer : std_logic;
  signal presence_prev_led    : std_logic;

  signal drawer_open_flag   : std_logic := '0';
  signal auto_close_counter : unsigned(3 downto 0) := (others => '0');

  signal session_counter : integer range 0 to 99 := 0;
  signal units_digit     : integer range 0 to 9 := 0;
  signal tens_digit      : integer range 0 to 9 := 0;

  signal tick_1s     : std_logic := '0';
  signal tick_counter: unsigned(25 downto 0) := (others => '0');

  signal bo_s1, bo_s2, bo_prev : std_logic := '0';
  signal bc_s1, bc_s2, bc_prev : std_logic := '0';
  signal btn_open_pulse        : std_logic := '0';
  signal btn_close_pulse       : std_logic := '0';

begin

  -------------------------------------------------------------------
  -- PIR Synchronizer (KEEP)
  -------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      presence_s1 <= presence_raw;
      presence_s2 <= presence_s1;
    end if;
  end process;

  -------------------------------------------------------------------
  -- 1-second tick generator (KEEP)
  -------------------------------------------------------------------
  process(clk, rst_n)
  begin
    if rst_n='0' then
      tick_counter <= (others => '0');
      tick_1s      <= '0';
    elsif rising_edge(clk) then
      if tick_counter = to_unsigned(49_999_999, tick_counter'length) then
        tick_counter <= (others => '0');
        tick_1s      <= '1';
      else
        tick_counter <= tick_counter + 1;
        tick_1s      <= '0';
      end if;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Button sync + pulses (NOT NEEDED)
  -------------------------------------------------------------------
   process(clk, rst_n)
   begin
     if rst_n='0' then
       bo_s1 <= '0'; bo_s2 <= '0'; bo_prev <= '0';
       bc_s1 <= '0'; bc_s2 <= '0'; bc_prev <= '0';
     elsif rising_edge(clk) then
       bo_s1   <= btn_open;
       bo_s2   <= bo_s1;
       bo_prev <= bo_s2;
  
       bc_s1   <= btn_close;
       bc_s2   <= bc_s1;
       bc_prev <= bc_s2;
     end if;
   end process;
  
   btn_open_pulse  <= bo_s2 and not bo_prev;
   btn_close_pulse <= bc_s2 and not bc_prev;

  -------------------------------------------------------------------
  -- Drawer logic (NOT NEEDED)
  -------------------------------------------------------------------
   process(clk, rst_n)
   begin
     if rst_n='0' then
       drawer_open_flag    <= '0';
       auto_close_counter  <= (others => '0');
       presence_prev_drawer<= '1';
     elsif rising_edge(clk) then
       if presence_s2='0' and presence_prev_drawer='1' then
         drawer_open_flag   <= '1';
         auto_close_counter <= to_unsigned(10, auto_close_counter'length);
       end if;
		 
		 if presence_s2='1' and presence_prev_drawer='0' then
         drawer_open_flag   <= '0';
         --auto_close_counter <= to_unsigned(10, auto_close_counter'length);
       end if;
  
       if btn_open_pulse='1' then
         drawer_open_flag   <= '1';
         auto_close_counter <= to_unsigned(10, auto_close_counter'length);
       end if;
  
       if btn_close_pulse='1' then
         drawer_open_flag   <= '0';
         auto_close_counter <= (others => '0');
       end if;
  
       if drawer_open_flag='1' and tick_1s='1' then
         if auto_close_counter > 0 then
           auto_close_counter <= auto_close_counter - 1;
         end if;
         if auto_close_counter = 0 then
           drawer_open_flag <= '0';
         end if;
       end if;
  
       presence_prev_drawer <= presence_s2;
     end if;
   end process;

  -------------------------------------------------------------------
  -- LED logic
  -------------------------------------------------------------------
   process(clk, rst_n)
   begin
     if rst_n='0' then
       presence_prev_led <= '1';
       led_on            <= "1111111111";
     elsif rising_edge(clk) then
       if presence_s2='0' then --and presence_prev_led='1' then
         if light_dark = '0' then
           led_on <= "0000000000";
         else
           led_on <= "1111111111";
         end if;
       end if;
  
       --presence_prev_led <= presence_s2;
     end if;
   end process;

  --led_on <= '0'; -- force off for testing

  -------------------------------------------------------------------
  -- Session timer (KEEP)
  -------------------------------------------------------------------
  process(clk, rst_n)
  begin
    if rst_n='0' then
      session_counter <= 0;
    elsif rising_edge(clk) then
      if tick_1s='1' and presence_s2='0' then
        if session_counter < 99 then
          session_counter <= session_counter + 1;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Split counter into digits (KEEP)
  -------------------------------------------------------------------
  process(session_counter)
  begin
    units_digit <= session_counter mod 10;
    tens_digit  <= session_counter / 10;
  end process;

  -------------------------------------------------------------------
  -- Units digit decoder (KEEP)
  -------------------------------------------------------------------
  process(units_digit)
begin
  case units_digit is
    when 0 => seg_units <= "1000000"; -- 0
    when 1 => seg_units <= "1111001"; -- 1
    when 2 => seg_units <= "0100100"; -- 2
    when 3 => seg_units <= "0110000"; -- 3
    when 4 => seg_units <= "0011001"; -- 4
    when 5 => seg_units <= "0010010"; -- 5
    when 6 => seg_units <= "0000010"; -- 6
    when 7 => seg_units <= "1111000"; -- 7
    when 8 => seg_units <= "0000000"; -- 8
    when 9 => seg_units <= "0010000"; -- 9
    when others => seg_units <= "1111111"; -- OFF
  end case;
end process;

  -------------------------------------------------------------------
  -- Tens digit decoder (KEEP)
  -------------------------------------------------------------------
 process(tens_digit)
begin
  case tens_digit is
    when 0 => seg_tens <= "1000000"; -- 0
    when 1 => seg_tens <= "1111001"; -- 1
    when 2 => seg_tens <= "0100100"; -- 2
    when 3 => seg_tens <= "0110000"; -- 3
    when 4 => seg_tens <= "0011001"; -- 4
    when 5 => seg_tens <= "0010010"; -- 5
    when 6 => seg_tens <= "0000010"; -- 6
    when 7 => seg_tens <= "1111000"; -- 7
    when 8 => seg_tens <= "0000000"; -- 8
    when 9 => seg_tens <= "0010000"; -- 9
    when others => seg_tens <= "1111111"; -- OFF
  end case;
end process;

  -------------------------------------------------------------------
  -- Servo driver (NOT NEEDED)
  -------------------------------------------------------------------
  u_servo_driver : entity work.servo_driver
     port map (
       clk         => clk,
       rst_n       => rst_n,
       drawer_open => drawer_open_flag,
       pwm_servo   => pwm_servo
    );

  --pwm_servo <= '0'; -- force low for testing

end arch_smart_desk;