--
-- A flip-flop to store the the register values for C Flag and Z flag.
-- To be used in the RAT CPU.
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ShadowReg is
    Port ( IN_FLAG       : in  STD_LOGIC; --flag input
           SHADOW_LD     : in  STD_LOGIC; --load the out_flag with the in_flag value
           SHAD_OUT_FLAG : out  STD_LOGIC); --flag output
end ShadowReg;

architecture Behavioral of ShadowReg is
begin
    process(IN_FLAG, SHADOW_LD)
    begin
       if(SHADOW_LD = '1') then
          SHAD_OUT_FLAG <= IN_FLAG;
       --else
       --   SHAD_OUT_FLAG <= 'Z';
       end if;
    end process;
end Behavioral;
