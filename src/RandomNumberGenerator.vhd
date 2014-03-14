----------------------------------------------------------------------------------
-- Company: Rat Technologies
-- Engineer: Various Rats
--
-- Create Date:    15:06:58 10/02/2013
-- Design Name:
-- Module Name:    mux_4to1_programnCounter - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description: Simple pseudo-random number generator based on a linear feedback
--              shift register.
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: This was originally written/provided by Jeff Gerfen.
--   Bryan Mealy made a few modificaitons to it in the general hope of making
--   the thing work better.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity pseudo_random is
port (                clk : in std_logic;
        pseudo_random_num : out std_logic_vector (7 downto 0));
end pseudo_random;


architecture Behavioral of pseudo_random is
begin
   process(clk)
      variable rand_temp : std_logic_vector(7 downto 0):= (others => '0');
      variable temp0 : std_logic;
      variable temp5 : std_logic;

   begin
   if(rising_edge(clk)) then
      temp5 := not rand_temp(2);
      temp0 := rand_temp(7) xor rand_temp(6);
      rand_temp := rand_temp(4 downto 3) & temp5 & rand_temp(1 downto 0) &
                   rand_temp(6 downto 5) & temp0;
   end if;

   pseudo_random_num <= conv_std_logic_vector((conv_integer(rand_temp) mod 4),7);
   --pseudo_random_num <= rand_temp;

   end process;
end;
