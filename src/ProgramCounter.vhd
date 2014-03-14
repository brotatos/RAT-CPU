-------------------------------------------------------------------------------
-- Engineer: Angela Yoeurng & Robin Choudhury
--
-- Create Date:    09:37:40 01/13/2014
-- Module Name:    ProgramCounter - Behavioral
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port ( D_IN     : in  STD_LOGIC_VECTOR (9 downto 0);
           PC_OE    : in  STD_LOGIC;
           PC_LD    : in  STD_LOGIC;
           PC_INC   : in  STD_LOGIC;
           RST      : in  STD_LOGIC;
           CLK      : in  STD_LOGIC;
           PC_COUNT : out  STD_LOGIC_VECTOR (9 downto 0);
           PC_TRI   : inout  STD_LOGIC_VECTOR (9 downto 0));
end ProgramCounter;

architecture Behavioral of ProgramCounter is
   -- internal working copy of PC
   signal sig_pc : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
begin
   write: process(CLK, D_IN, PC_OE, PC_LD, PC_INC, RST)
   begin
      if (RST = '1') then
         sig_pc <= (others => '0');
      elsif(rising_edge(CLK)) then
         -- PC_COUNT logic
         if (PC_LD = '1') then
            sig_pc <= D_IN;
         elsif (PC_INC = '1') then
            sig_pc <= sig_pc + 1;
         end if;
      end if;
   end process;

   PC_COUNT <= sig_pc;
   PC_TRI <= sig_pc when (PC_OE = '1') else (others => 'Z');

end Behavioral;
