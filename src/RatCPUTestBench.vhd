--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   22:26:38 02/09/2014
-- Design Name:
-- Module Name:   /home/robin/class/cpe233/RatCPU/RatCPUTestBench.vhd
-- Project Name:  RatCPU
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: RAT_CPU
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

ENTITY RatCPUTestBench IS
END RatCPUTestBench;

ARCHITECTURE behavior OF RatCPUTestBench IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT RAT_CPU
    PORT(
         IN_PORT : IN  std_logic_vector(7 downto 0);
         RST : IN  std_logic;
         INT_IN : IN  std_logic;
         CLK : IN  std_logic;
         OUT_PORT : OUT  std_logic_vector(7 downto 0);
         PORT_ID : OUT  std_logic_vector(7 downto 0);
         IO_OE : OUT  std_logic
        );
    END COMPONENT;


   --Inputs
   signal IN_PORT : std_logic_vector(7 downto 0) := (others => '0');
   signal RST : std_logic := '0';
   signal INT_IN : std_logic := '0';
   signal CLK : std_logic := '0';

   --Outputs
   signal OUT_PORT : std_logic_vector(7 downto 0);
   signal PORT_ID : std_logic_vector(7 downto 0);
   signal IO_OE : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: RAT_CPU PORT MAP (
          IN_PORT => IN_PORT,
          RST => RST,
          INT_IN => INT_IN,
          CLK => CLK,
          OUT_PORT => OUT_PORT,
          PORT_ID => PORT_ID,
          IO_OE => IO_OE
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
      -- hold reset state for 100 ns.
      wait for 100 ns;


      -- insert stimulus here
      SWITCHES <= "00000000";
      RST <= '0';

      wait for CLK_period*10;

      wait;
   end process;

END;
