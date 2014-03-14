----------------------------------------------------------------------------------
-- Company: Unknown
-- Engineer: The Unknown Engineer
--
-- Create Date:    17:12:22 11/07/2012
-- Design Name:
-- Module Name:    PS2_REGISTER - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: PS/2 driver with basic PS/2 receive functionality only
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity PS2_REGISTER is
   PORT (
      PS2_DATA_READY,
      PS2_ERROR            : out STD_LOGIC;
      PS2_KEY_CODE         : out STD_LOGIC_VECTOR(7 downto 0);
      PS2_CLK              : inout STD_LOGIC;
      PS2_DATA             : in STD_LOGIC;
      PS2_CLEAR_DATA_READY : in STD_LOGIC);
end PS2_REGISTER;

architecture Behavioral of PS2_REGISTER is

   signal reg   : STD_LOGIC_VECTOR(10 downto 0) := "11111111111";
   signal s_key_code : STD_LOGIC_VECTOR(7 downto 0);
   signal isParityCorrect : STD_LOGIC;

begin


   PS2_ERROR <= ((reg(0))   or (not reg(10)) or (not isParityCorrect));
   --           (start bit) or (stop bit)   or (parity)

   isParityCorrect <= reg(1) xor reg(2) xor reg(3) xor reg(4) xor reg(5) xor reg(6) xor reg(7) xor reg(8) xor reg(9);
                                   --reg(0) is a start bit, reg(10) stop bit
                                   --reg(0) should be low
                                   --reg(10)  should be high
                                   -- ps2 key boards use odd parity, so if theres an even
                                   --   number of 1's then a 1 will be sent as the parity,
                                   --   the total number of ones excluding the start and stop
                                   --   should be an odd number
                                   --if I xor all the data bits together with the parity, it
                                   -- should come out as a 1.
                                   -- all together: the data is ready when I have a correct
                                   -- stop bit, start bit, and parity bit


   PS2_KEY_CODE   <= reg(8 downto 1);
   PS2_DATA_READY <= not(reg(0));

   pauseKeyboard: process (reg(0), PS2_CLEAR_DATA_READY) is
   begin
      if ((reg(0) = '0')or (PS2_CLEAR_DATA_READY = '1'))then
         PS2_CLK <= '0';
      else
         PS2_CLK <= 'Z';
      end if;
   end process pauseKeyboard;


   shiftRegister: process (PS2_CLK, PS2_CLEAR_DATA_READY) is
   begin
      if ((PS2_CLEAR_DATA_READY = '1')) then
         reg <= "11111111111";
      elsif (falling_edge(PS2_CLK)) then
         reg <= PS2_DATA & reg(10 downto 1);
      end if;
   end process shiftRegister;

end Behavioral;

