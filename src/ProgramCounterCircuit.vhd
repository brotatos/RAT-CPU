-------------------------------------------------------------------------------
-- Engineer: Robin Choudhury & Angela Yoeurng
--
-- Create Date:    15:10:54 01/13/2014
-- Design Name:
-- Module Name:    ProgramCounterCircuit - Behavioral
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ProgramCounterCircuit is
    Port ( FROM_IMMED : in  STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in  STD_LOGIC_VECTOR (9 downto 0);
           INTERRUPT  : in  STD_LOGIC_VECTOR (9 downto 0);
           PC_MUX_SEL : in  STD_LOGIC_VECTOR (1 downto 0);
           PC_OE      : in  STD_LOGIC;
           PC_LD      : in  STD_LOGIC;
           PC_INC     : in  STD_LOGIC;
           RST        : in  STD_LOGIC;
           CLK        : in  STD_LOGIC;
           PC_COUNT   : out  STD_LOGIC_VECTOR (9 downto 0);
           PC_TRI     : inout  STD_LOGIC_VECTOR (9 downto 0));
end ProgramCounterCircuit;

architecture Behavioral of ProgramCounterCircuit is

   component Mux is
      Port ( FROM_IMMED : in  STD_LOGIC_VECTOR (9 downto 0);
             FROM_STACK : in  STD_LOGIC_VECTOR (9 downto 0);
             INTERRUPT  : in  STD_LOGIC_VECTOR (9 downto 0);
             PC_MUX_SEL : in  STD_LOGIC_VECTOR (1 downto 0);
             D_IN       : out  STD_LOGIC_VECTOR (9 downto 0));
   end component;

   component ProgramCounter is
      Port ( D_IN     : in  STD_LOGIC_VECTOR (9 downto 0);
             PC_OE    : in  STD_LOGIC;
             PC_LD    : in  STD_LOGIC;
             PC_INC   : in  STD_LOGIC;
             RST      : in  STD_LOGIC;
             CLK      : in  STD_LOGIC;
             PC_COUNT : out  STD_LOGIC_VECTOR (9 downto 0);
             PC_TRI   : inout  STD_LOGIC_VECTOR (9 downto 0));
   end component;

   signal d_in_to_use : STD_LOGIC_VECTOR(9 downto 0);

begin

   the_mux : Mux
   port map ( FROM_IMMED => FROM_IMMED,
              FROM_STACK => FROM_STACK,
              INTERRUPT  => INTERRUPT,
              PC_MUX_SEL => PC_MUX_SEL,
              D_IN       => d_in_to_use);

   counter : ProgramCounter
   port map ( D_IN     => d_in_to_use,
              PC_OE    => PC_OE,
              PC_LD    => PC_LD,
              PC_INC   => PC_INC,
              RST      => RST,
              CLK      => CLK,
              PC_COUNT => PC_COUNT,
              PC_TRI   => PC_TRI);


end Behavioral;

