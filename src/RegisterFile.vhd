library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegisterFile is
    Port ( RF_WR_SEL : in STD_LOGIC_VECTOR(1 downto 0);
           IN_PORT   : in STD_LOGIC_VECTOR(7 downto 0);
           ALU_SUM   : in STD_LOGIC_VECTOR(7 downto 0);
           MULTI_BUS : in STD_LOGIC_VECTOR(7 downto 0);
           ADRX      : in     STD_LOGIC_VECTOR (4 downto 0);
           ADRY      : in     STD_LOGIC_VECTOR (4 downto 0);
           DX_OE     : in     STD_LOGIC;
           WE        : in     STD_LOGIC;
           CLK       : in     STD_LOGIC;
           DX_OUT    : inout  STD_LOGIC_VECTOR (7 downto 0);
           DY_OUT    : out    STD_LOGIC_VECTOR (7 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is
   TYPE memory is array (0 to 31) of std_logic_vector(7 downto 0);
   SIGNAL REG: memory := (others=>(others=>'0'));
   signal D_IN : STD_LOGIC_VECTOR(7 downto 0);
begin

   process (RF_WR_SEL, IN_PORT, ALU_SUM, MULTI_BUS) begin
      if (RF_WR_SEL <= "00") then
         D_IN <= ALU_SUM;
      elsif (RF_WR_SEL <= "01") then
         D_IN <= MULTI_BUS;
      elsif (RF_WR_SEL <= "11") then
         D_IN <= IN_PORT;
      else
         D_IN <= (others=>'Z');
      end if;
   end process;

   process(clk)
   begin
      if (rising_edge(clk)) then
            if (WE = '1') then
               REG(conv_integer(ADRX)) <= D_IN;
        end if;
      end if;
   end process;

   DX_OUT <= REG(conv_integer(ADRX)) when DX_OE='1' else (others=>'Z');
   DY_OUT <= REG(conv_integer(ADRY));

end Behavioral;
