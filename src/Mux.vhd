-------------------------------------------------------------------------------
-- Engineer: Robin Choudhury & Angela Yoeurng
--
-- Create Date:    09:38:32 01/13/2014
-- Module Name:    Mux - Behavioral
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_mux is
    Port ( A           : in  STD_LOGIC_VECTOR (7 downto 0);
           B           : in  STD_LOGIC_VECTOR (7 downto 0);
           ALU_MUX_SEL : in  STD_LOGIC;
           B_OUT       : out STD_LOGIC_VECTOR (7 downto 0));
end alu_mux;

architecture Behavioral of alu_mux is

begin
   with ALU_MUX_SEL select
      B_OUT <= A when '0', -- switches
               B when others;

end Behavioral;

