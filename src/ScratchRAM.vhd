----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    09:38:31 01/22/2014
-- Design Name:
-- Module Name:    ScratchRAM - Behavioral
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ScratchRAM is
    Port ( DY_OUT               : in STD_LOGIC_VECTOR(7 downto 0);
           PROG_ROM_INSTRUCTION : in STD_LOGIC_VECTOR(7 downto 0);
           SP_OUT               : in STD_LOGIC_VECTOR(7 downto 0);
           SP_DECREMENT         : in STD_LOGIC_VECTOR(7 downto 0);
           SCR_ADDR_SEL         : in STD_LOGIC_VECTOR(1 downto 0);
           SCR_OE               : in  STD_LOGIC;
           SCR_WE               : in  STD_LOGIC;
           CLK                  : in  STD_LOGIC;
           SCR_DATA             : inout  STD_LOGIC_VECTOR (9 downto 0));
end ScratchRAM;

architecture scratch_ram of ScratchRAM is
   type ram_type is array (0 to 255) of std_logic_vector (9 downto 0);
   signal gen_ram : ram_type := (others=>(others=>'0'));
   signal SCR_ADDR : STD_LOGIC_VECTOR (7 downto 0); -- going to be replaced by mux
begin

   mux_select: process(SCR_ADDR, DY_OUT, PROG_ROM_INSTRUCTION, SP_OUT, SP_DECREMENT, SCR_ADDR_SEL)
   begin
      if (SCR_ADDR_SEL = "00") then
         SCR_ADDR <= DY_OUT;
      elsif (SCR_ADDR_SEL = "01") then
         SCR_ADDR <= PROG_ROM_INSTRUCTION;
      elsif (SCR_ADDR_SEL = "10") then
         SCR_ADDR <= SP_OUT;
      else
         SCR_ADDR <= SP_DECREMENT;
      end if;
   end process mux_select;

   ram_write: process (CLK, SCR_WE, SCR_DATA, gen_ram, SCR_ADDR)
   begin
      --- writes to RAM
      ---------------------------------------------------(1)
      if (rising_edge(CLK)) then
         if (SCR_WE = '1') then
            gen_ram(conv_integer(SCR_ADDR)) <= SCR_DATA;
         end if;
      end if;
   end process ram_write;
   --- reads from RAM
   ------------------------------------------------------(2)
   SCR_DATA <= gen_ram(conv_integer(SCR_ADDR)) when SCR_OE='1' else (others => 'Z');
end scratch_ram;
