--
-- Declares a clock divider to synchronize the VGA scanlines
--
-- Original author: unknown
--
-- Peter Heatwole, Aaron Barton
-- CPE233, Winter 2012, CalPoly
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_clk_div is
  port(clk 		: in std_logic;
		 clkout 	: out std_logic);
end vga_clk_div;

architecture Behavioral of vga_clk_div is

signal tmp_clkf : std_logic;

begin

   my_div_fast: process (clk,tmp_clkf)
      variable div_cnt : integer := 0;
   begin
      if (rising_edge(clk)) then
         if (div_cnt = 0) then
            tmp_clkf <= not tmp_clkf;
            div_cnt := 0;
         else
            div_cnt := div_cnt + 1;
         end if;
      end if;
      clkout <= tmp_clkf;
   end process my_div_fast;

end Behavioral;

