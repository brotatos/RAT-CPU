-------------------------------------------------------------------------------
-- Company: Winter Quarter 2014
-- Engineer: Robin Choudhury & Angela Yoeurng
-- Create Date:    18:26:28 02/05/2014
-- Design Name:    RAT_CPU
-- Module Name:    RAT_CPU - Behavioral
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAT_CPU is
    Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
           RST      : in  STD_LOGIC;
           INT_IN   : in  STD_LOGIC;
           CLK      : in  STD_LOGIC;
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID  : out  STD_LOGIC_VECTOR (7 downto 0);
           IO_OE    : out  STD_LOGIC);
end RAT_CPU;

architecture Behavioral of RAT_CPU is

   component FlagMux is
      Port ( ALU_FLAG        : in  STD_LOGIC;
             SHADOW_FLAG     : in  STD_LOGIC;
             SHADOW_FLAG_SEL : in  STD_LOGIC;
             OUT_FLAG        : out STD_LOGIC);
   end component;

   component ShadowReg is
      Port ( IN_FLAG       : in  STD_LOGIC; --flag input
             SHADOW_LD     : in  STD_LOGIC; --load the out_flag with the in_flag value
             SHAD_OUT_FLAG : out  STD_LOGIC); --flag output
   end component;

   component FlagReg is
      Port ( IN_FLAG  : in  STD_LOGIC; --flag input
             LD       : in  STD_LOGIC; --load the out_flag with the in_flag value
             SET      : in  STD_LOGIC; --set the flag to '1'
             CLR      : in  STD_LOGIC; --clear the flag to '0'
             CLK      : in  STD_LOGIC; --system clock
             OUT_FLAG : out  STD_LOGIC); --flag output
   end component;

   component prog_rom is
      Port (     ADDRESS : in std_logic_vector(9 downto 0);
             INSTRUCTION : out std_logic_vector(17 downto 0);
                     CLK : in std_logic);
   end component;

   component RegisterFile is
      Port ( RF_WR_SEL : in STD_LOGIC_VECTOR(1 downto 0);
             IN_PORT   : in STD_LOGIC_VECTOR(7 downto 0);
             ALU_SUM   : in STD_LOGIC_VECTOR(7 downto 0);
             MULTI_BUS : in STD_LOGIC_VECTOR(7 downto 0);
             ADRX      : in STD_LOGIC_VECTOR (4 downto 0);
             ADRY      : in STD_LOGIC_VECTOR (4 downto 0);
             DX_OE     : in STD_LOGIC;
             WE        : in STD_LOGIC;
             CLK       : in STD_LOGIC;
             DX_OUT    : inout STD_LOGIC_VECTOR (7 downto 0);
             DY_OUT    : out STD_LOGIC_VECTOR (7 downto 0));
   end component;

   component alu is
      Port ( A           : in  STD_LOGIC_VECTOR (7 downto 0);
             FROM_IMMED  : in STD_LOGIC_VECTOR (7 downto 0);
             REG_IN      : in STD_LOGIC_VECTOR (7 downto 0);
             ALU_MUX_SEL : in STD_LOGIC;
             C_IN        : in  STD_LOGIC;
             SEL         : in  STD_LOGIC_VECTOR (3 downto 0);
             SUM         : out  STD_LOGIC_VECTOR (7 downto 0);
             C_FLAG      : out  STD_LOGIC;
             Z_FLAG      : out  STD_LOGIC);
   end component;

   component ProgramCounterCircuit is
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
   end component;

   component StackPointer is
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
   end component;

   component ScratchRAM is
      Port ( DY_OUT               : in STD_LOGIC_VECTOR(7 downto 0);
             PROG_ROM_INSTRUCTION : in STD_LOGIC_VECTOR(7 downto 0);
             SP_OUT               : in STD_LOGIC_VECTOR(7 downto 0);
             SP_DECREMENT         : in STD_LOGIC_VECTOR(7 downto 0);
             SCR_ADDR_SEL         : in STD_LOGIC_VECTOR(1 downto 0);
             SCR_OE               : in  STD_LOGIC;
             SCR_WE               : in  STD_LOGIC;
             CLK                  : in  STD_LOGIC;
             SCR_DATA             : inout  STD_LOGIC_VECTOR (9 downto 0));
   end component;

   component ControlUnit is
      Port ( CLK           : in   STD_LOGIC;
             C             : in   STD_LOGIC;
             Z             : in   STD_LOGIC;
             INT           : in   STD_LOGIC;
             RST           : in   STD_LOGIC;
             OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
             OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
             PC_LD         : out  STD_LOGIC;
             PC_INC        : out  STD_LOGIC;
             PC_RST        : out  STD_LOGIC;
             PC_OE         : out  STD_LOGIC;
             PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);
             SP_LD         : out  STD_LOGIC;
             SP_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);
             SP_RST        : out  STD_LOGIC;
             RF_WR         : out  STD_LOGIC;
             RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);
             RF_OE         : out  STD_LOGIC;
             REG_IMMED_SEL : out  STD_LOGIC;
             ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);
             SCR_WR        : out  STD_LOGIC;
             SCR_OE        : out  STD_LOGIC;
             SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);
             C_LD          : out  STD_LOGIC;
             C_SET         : out  STD_LOGIC;
             C_CLR         : out  STD_LOGIC;
             SHAD_C_LD     : out  STD_LOGIC;
             SHAD_C_SEL    : out  STD_LOGIC;
             Z_LD          : out  STD_LOGIC;
             Z_SET         : out  STD_LOGIC;
             Z_CLR         : out  STD_LOGIC;
             SHAD_Z_LD     : out  STD_LOGIC;
             SHAD_Z_SEL    : out  STD_LOGIC;
             I_SET         : out  STD_LOGIC;
             I_CLR         : out  STD_LOGIC;
             IO_OE         : out  STD_LOGIC);
   end component;

   component alu_mux is
      Port ( A           : in  STD_LOGIC_VECTOR (7 downto 0);
             B           : in  STD_LOGIC_VECTOR (7 downto 0);
             ALU_MUX_SEL : in  STD_LOGIC;
             B_OUT       : out STD_LOGIC_VECTOR (7 downto 0));
   end component;

   -- Register File -----------------------------------------------------------
   -- Flags
   signal RF_OE_FLAG, RF_WR_FLAG, REG_IMMED_SEL_FLAG : STD_LOGIC;
   -- MUX Select Signal
   signal RF_WR_SEL_SIG : STD_LOGIC_VECTOR (1 downto 0);
   -- Address Outputs
   signal DY_OUT_SIG : STD_LOGIC_VECTOR (7 downto 0);
   ----------------------------------------------------------------------------

   -- Program Counter ---------------------------------------------------------
   signal PC_LD_FLAG, PC_INC_FLAG, PC_RST_FLAG, PC_OE_FLAG : STD_LOGIC;
   -- MUX Select Signal
   signal PC_MUX_SEL_SIG : STD_LOGIC_VECTOR (1 downto 0);
   signal PROG_ROM_INSTRUCTION : STD_LOGIC_VECTOR (17 downto 0);
   -- Outputs
   signal PC_COUNT_SIG : STD_LOGIC_VECTOR (9 downto 0);
   ----------------------------------------------------------------------------

   -- ALU ---------------------------------------------------------------------
   -- Output
   signal ALU_SUM : STD_LOGIC_VECTOR (7 downto 0);
   -- Command Select (i.e. ADD => "0000")
   signal ALU_SEL_SIG : STD_LOGIC_VECTOR(3 downto 0);
   ----------------------------------------------------------------------------

   -- Stack Pointer -----------------------------------------------------------
   -- Flags
   signal SP_LD_FLAG, SP_RST_FLAG : STD_LOGIC;
   -- MUX Select Signal
   signal SP_MUX_SEL_SIG : STD_LOGIC_VECTOR (1 downto 0);
   -- Outputs
   signal SP_OUT_SIG, SP_INCREMENT_SIG : STD_LOGIC_VECTOR (7 downto 0);
   signal SP_DECREMENT_SIG : STD_LOGIC_VECTOR (7 downto 0);
   ----------------------------------------------------------------------------

   -- Scratch RAM  ------------------------------------------------------------
   -- Flags
   signal SCR_WR_FLAG, SCR_OE_FLAG : STD_LOGIC;
   -- MUX Select Signal
   signal SCR_ADDR_SEL_SIG : STD_LOGIC_VECTOR (1 downto 0);
   signal MULTI_BUS_SIG : STD_LOGIC_VECTOR (9 downto 0);
   ----------------------------------------------------------------------------

   -- Shadow flags
   signal SHAD_Z_LD_FLAG, SHAD_C_LD_FLAG, SHAD_Z_SEL_SIG, SHAD_C_SEL_SIG : STD_LOGIC;
   signal SHAD_Z_FLAG, SHAD_C_FLAG : STD_LOGIC;


   -- C Flag flags
   signal C_MUX_FLAG, C_LD_FLAG, C_SET_FLAG, C_CLR_FLAG, C_FLAG_ALU, C_FLAG_OUT : STD_LOGIC;

   -- Z Flag flags
   signal Z_MUX_FLAG, Z_LD_FLAG, Z_SET_FLAG, Z_CLR_FLAG, Z_FLAG_ALU, Z_FLAG_OUT : STD_LOGIC;

   -- Interrupt flags
   signal I_FLAG_OUT, I_SET_FLAG, I_CLR_FLAG, int_and : STD_LOGIC;

begin

   -- Shadow Muxes
   shadow_z_mux : FlagMux
    port map ( ALU_FLAG        => Z_FLAG_ALU,
               SHADOW_FLAG     => SHAD_Z_FLAG,
               SHADOW_FLAG_SEL => SHAD_Z_SEL_SIG,
               OUT_FLAG        => Z_MUX_FLAG);

   shadow_c_mux : FlagMux
    port map ( ALU_FLAG        => C_FLAG_ALU,
               SHADOW_FLAG     => SHAD_C_FLAG,
               SHADOW_FLAG_SEL => SHAD_C_SEL_SIG,
               OUT_FLAG        => C_MUX_FLAG);

   -- Shadow registers
   shadow_z_reg : ShadowReg
    port map ( IN_FLAG       => Z_FLAG_OUT,
               SHADOW_LD     => SHAD_Z_LD_FLAG,
               SHAD_OUT_FLAG => SHAD_Z_FLAG);

   shadow_c_reg : ShadowReg
    port map ( IN_FLAG       => C_FLAG_OUT,
               SHADOW_LD     => SHAD_C_LD_FLAG,
               SHAD_OUT_FLAG => SHAD_C_FLAG);

   -- Flag registers
   i_flag : FlagReg
      port map ( IN_FLAG  => INT_IN,
                 LD       => '0',
                 SET      => I_SET_FLAG,
                 CLR      => I_CLR_FLAG,
                 CLK      => CLK,
                 OUT_FLAG => I_FLAG_OUT);

   c_flag : FlagReg
      port map ( IN_FLAG  => C_MUX_FLAG,
                 LD       => C_LD_FLAG,
                 SET      => C_SET_FLAG,
                 CLR      => C_CLR_FLAG,
                 CLK      => CLK,
                 OUT_FLAG => C_FLAG_OUT);

   z_flag : FlagReg
      port map ( IN_FLAG  => Z_MUX_FLAG,
                 LD       => Z_LD_FLAG,
                 SET      => Z_SET_FLAG,
                 CLR      => Z_CLR_FLAG,
                 CLK      => CLK,
                 OUT_FLAG => Z_FLAG_OUT);

   reg_file : RegisterFile
      port map ( RF_WR_SEL => RF_WR_SEL_SIG,
                 IN_PORT   => IN_PORT,
                 ALU_SUM   => ALU_SUM,
                 MULTI_BUS => MULTI_BUS_SIG(7 downto 0),
                 ADRX      => PROG_ROM_INSTRUCTION(12 downto 8),
                 ADRY      => PROG_ROM_INSTRUCTION(7 downto 3),
                 DX_OE     => RF_OE_FLAG,
                 WE        => RF_WR_FLAG,
                 CLK       => CLK,
                 DX_OUT    => MULTI_BUS_SIG(7 downto 0),
                 DY_OUT    => DY_OUT_SIG);

   prog : prog_rom
      port map (     ADDRESS => PC_COUNT_SIG (9 downto 0),
                        CLK  => CLK,
                INSTRUCTION  => PROG_ROM_INSTRUCTION);

   the_alu : alu
      port map ( A           => MULTI_BUS_SIG(7 downto 0),
                 FROM_IMMED  => PROG_ROM_INSTRUCTION(7 downto 0),
                 REG_IN      => DY_OUT_SIG,
                 ALU_MUX_SEL => REG_IMMED_SEL_FLAG,
                 C_IN        => C_FLAG_OUT,
                 SEL         => ALU_SEL_SIG,
                 SUM         => ALU_SUM,
                 C_FLAG      => C_FLAG_ALU,
                 Z_FLAG      => Z_FLAG_ALU);


   ProgramCounter : ProgramCounterCircuit
    port map ( FROM_IMMED => PROG_ROM_INSTRUCTION(12 downto 3),
               FROM_STACK => MULTI_BUS_SIG,
               INTERRUPT  => "1111111111",
               PC_MUX_SEL => PC_MUX_SEL_SIG,
               PC_OE      => PC_OE_FLAG,
               PC_LD      => PC_LD_FLAG,
               PC_INC     => PC_INC_FLAG,
               RST        => PC_RST_FLAG,
               CLK        => CLK,
               PC_COUNT   => PC_COUNT_SIG,
               PC_TRI     => MULTI_BUS_SIG);

   stack : StackPointer
    port map ( LD                => SP_LD_FLAG,
               RST               => SP_RST_FLAG,
               INCREMENT         => SP_INCREMENT_SIG,
               DECREMENT         => SP_DECREMENT_SIG,
               MULTI_BUS         => MULTI_BUS_SIG(7 downto 0),
               SP_MUX_SEL        => SP_MUX_SEL_SIG,
               CLK               => CLK,
               SP_OUT            => SP_OUT_SIG,
               DECREMENT_POINTER => SP_DECREMENT_SIG,
               INCREMENT_POINTER => SP_INCREMENT_SIG);

   scratch : ScratchRAM
      port map ( DY_OUT               => DY_OUT_SIG,
                 PROG_ROM_INSTRUCTION => PROG_ROM_INSTRUCTION(7 downto 0),
                 SP_OUT               => SP_OUT_SIG,
                 SP_DECREMENT         => SP_DECREMENT_SIG,
                 SCR_ADDR_SEL         => SCR_ADDR_SEL_SIG,
                 SCR_OE               => SCR_OE_FLAG,
                 SCR_WE               => SCR_WR_FLAG,
                 CLK                  => CLK,
                 SCR_DATA             => MULTI_BUS_SIG);

   int_and <= INT_IN AND I_FLAG_OUT;

   control_unit : ControlUnit
      port map ( CLK           => CLK,
                 C             => C_FLAG_OUT,
                 Z             => Z_FLAG_OUT,
                 -- Interrupt
                 INT           => int_and,
                 RST           => RST,
                 OPCODE_HI_5   => PROG_ROM_INSTRUCTION (17 downto 13),
                 OPCODE_LO_2   => PROG_ROM_INSTRUCTION (1 downto 0),
                 -- Program Counter
                 PC_LD         => PC_LD_FLAG,
                 PC_INC        => PC_INC_FLAG,
                 PC_RST        => PC_RST_FLAG,
                 PC_OE         => PC_OE_FLAG,
                 PC_MUX_SEL    => PC_MUX_SEL_SIG,
                 -- Stack Pointer
                 SP_LD         => SP_LD_FLAG,
                 SP_MUX_SEL    => SP_MUX_SEL_SIG,
                 SP_RST        => SP_RST_FLAG,
                 -- Register File
                 RF_WR         => RF_WR_FLAG,
                 RF_WR_SEL     => RF_WR_SEL_SIG,
                 RF_OE         => RF_OE_FLAG,
                 -- ALU
                 REG_IMMED_SEL => REG_IMMED_SEL_FLAG,
                 ALU_SEL       => ALU_SEL_SIG,
                 -- Scratch RAM
                 SCR_WR        => SCR_WR_FLAG,
                 SCR_OE        => SCR_OE_FLAG,
                 SCR_ADDR_SEL  => SCR_ADDR_SEL_SIG,
                 -- C Flag
                 C_LD          => C_LD_FLAG,
                 C_SET         => C_SET_FLAG,
                 C_CLR         => C_CLR_FLAG,
                 SHAD_C_LD     => SHAD_C_LD_FLAG,
                 SHAD_C_SEL    => SHAD_C_SEL_SIG,
                 -- Z Flag
                 Z_LD          => Z_LD_FLAG,
                 Z_SET         => Z_SET_FLAG,
                 Z_CLR         => Z_CLR_FLAG,
                 SHAD_Z_LD     => SHAD_Z_LD_FLAG,
                 SHAD_Z_SEL    => SHAD_Z_SEL_SIG,
                 -- I Flag
                 I_SET         => I_SET_FLAG,
                 I_CLR         => I_CLR_FLAG,
                 -- I/O
                 IO_OE         => IO_OE);

   PORT_ID <= PROG_ROM_INSTRUCTION(7 downto 0);
   OUT_PORT <= MULTI_BUS_SIG(7 downto 0);

end Behavioral;
