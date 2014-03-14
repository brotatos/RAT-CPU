--------------------------------------------------------------------------------
-- Engineer: Robin Choudhury & Angela Yoeurng
-- Revision 0.01 - File Created
-- Additional Comments:  To be used for shadow registers.
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FlagMux is
    Port ( ALU_FLAG        : in  STD_LOGIC;
           SHADOW_FLAG     : in  STD_LOGIC;
           SHADOW_FLAG_SEL : in  STD_LOGIC;
           OUT_FLAG        : out STD_LOGIC);
end FlagMux;

architecture Behavioral of FlagMux is

begin
   with SHADOW_FLAG_SEL select
      OUT_FLAG <=
      --SHADOW_FLAG when '0',
      --ALU_FLAG when others;
            ALU_FLAG    when '0',
            SHADOW_FLAG when others;

end Behavioral;
