--
-- A flip-flop to store the the zero, carry, and interrupt flags.
-- To be used in the RAT CPU.
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FlagReg is
    Port ( IN_FLAG  : in  STD_LOGIC; --flag input
           LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
           SET      : in  STD_LOGIC; --set the flag to '1'
           CLR      : in  STD_LOGIC; --clear the flag to '0'
           CLK      : in  STD_LOGIC; --system clock
           OUT_FLAG : out  STD_LOGIC); --flag output
end FlagReg;

architecture Behavioral of FlagReg is
begin
    process(CLK)
    begin
        if( rising_edge(CLK) ) then
            if( LD = '1' ) then
                OUT_FLAG <= IN_FLAG;
            elsif( SET = '1' ) then
                OUT_FLAG <= '1';
            elsif( CLR = '1' ) then
                OUT_FLAG <= '0';
         end if;
      end if;
    end process;
end Behavioral;
