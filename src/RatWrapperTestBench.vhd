--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   08:17:10 02/10/2014
-- Design Name:
-- Module Name:   /home/robin/class/cpe233/RatCPU/RatWrapperTestBench.vhd
-- Project Name:  RatCPU
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: RAT_wrapper
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY RatWrapperTestBench IS
END RatWrapperTestBench;

ARCHITECTURE behavior OF RatWrapperTestBench IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT RAT_wrapper
    PORT(
         LEDS     : OUT  std_logic_vector(7 downto 0);
         BUTTON3  : IN std_logic;
         SWITCHES : IN  std_logic_vector(7 downto 0);
         RST      : IN  std_logic;
         CLK      : IN  std_logic
        );
    END COMPONENT;


   --Inputs
   signal SWITCHES : std_logic_vector(7 downto 0) := (others => '0');
   signal RST : std_logic := '0';
   signal CLK : std_logic := '0';
   signal BUTTON3 : std_logic := '0';
   --Outputs
   signal LEDS : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: RAT_wrapper PORT MAP (
          BUTTON3 => BUTTON3,
          LEDS => LEDS,
          SWITCHES => SWITCHES,
          RST => RST,
          CLK => CLK
        );

   -- Clock process definitions
   CLK_process :process
   begin
      CLK <= '0';
      wait for CLK_period/2;
      CLK <= '1';
      wait for CLK_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 10 ns.
      wait for 100 ns;

      --SWITCHES <= "00000000";
      BUTTON3 <= '0';
      wait for 1000 ns;

      BUTTON3 <= '1';
      wait for 100 ns;

      BUTTON3 <= '0';
      wait for 1000 ns;

      BUTTON3 <= '1';
      wait for 100 ns;

      BUTTON3 <= '0';
      wait for 500 ns;

      BUTTON3 <= '1';
      wait for 100 ns;
      wait;
   end process;

END;
