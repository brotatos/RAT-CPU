------------------------------------------------------------------------------
-- Engineer: Robin Choudhury & Angela Yoeurng
--
-- Create Date:    21:57:41 02/12/2014 Winter Quarter 2014
-- Module Name:    StackPointer - Behavioral
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity StackPointer is
    Port ( LD                : in  STD_LOGIC;
           RST               : in  STD_LOGIC;
           INCREMENT         : in STD_LOGIC_VECTOR (7 downto 0);
           DECREMENT         : in STD_LOGIC_VECTOR (7 downto 0);
           MULTI_BUS         : in STD_LOGIC_VECTOR (7 downto 0);
           SP_MUX_SEL        : in  STD_LOGIC_VECTOR (1 downto 0);
           CLK               : in  STD_LOGIC;
           SP_OUT            : out  STD_LOGIC_VECTOR (7 downto 0);
           DECREMENT_POINTER : out STD_LOGIC_VECTOR(7 downto 0);
           INCREMENT_POINTER : out STD_LOGIC_VECTOR(7 downto 0));
end StackPointer;

architecture Behavioral of StackPointer is

   signal current_pointer, sp_in : STD_LOGIC_VECTOR (7 downto 0);

begin

   process (MULTI_BUS, INCREMENT, DECREMENT, SP_MUX_SEL)
   begin
      if (SP_MUX_SEL = "00") then
         sp_in <= MULTI_BUS;
      elsif (SP_MUX_SEL = "10" ) then
         sp_in <= DECREMENT;
      elsif (SP_MUX_SEL = "11" ) then
         sp_in <= INCREMENT;
      else
         sp_in <= (others => '0');
      end if;
   end process;

   process (CLK, LD, RST)
   begin
      if (RST = '1') then
         current_pointer <= (others => '0');
      elsif (rising_edge(CLK)) then
         if (LD = '1') then
            current_pointer <= SP_IN;
         end if;
      end if;
   end process;

   SP_OUT <= current_pointer;
   DECREMENT_POINTER <= current_pointer - 1;
   INCREMENT_POINTER <= current_pointer + 1;


end Behavioral;
