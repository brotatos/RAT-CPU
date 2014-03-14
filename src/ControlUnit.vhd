----------------------------------------------------------------------------------
-- Company: CPE 233
-- Engineer:
-- -------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity ControlUnit is
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
end ControlUnit;

architecture Behavioral of ControlUnit is

   type state_type is (ST_init, ST_fet, ST_exec, ST_interrupt);
      signal PS,NS : state_type;

   signal sig_OPCODE_7: std_logic_vector (6 downto 0);
begin
   -- concatenate the all opcodes into a 7-bit complete opcode for
   -- easy instruction decoding.
   sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

   sync_p: process (CLK, NS, RST)
   begin
      -- Drive it lower after setting it to high in test bench.
      -- Drag it into test bench and watch PC go from init, fetch, execute and
      -- repeat.
      if (RST = '1') then
         PS <= ST_init;
      elsif (rising_edge(CLK)) then
         PS <= NS;
      end if;
   end process sync_p;


   comb_p: process (sig_OPCODE_7, PS, NS, Z, C, INT)
   begin
   case PS is

         -- STATE: the init cycle ------------------------------------
         -- Initialize all control outputs to non-active states and reset the PC and SP to all zeros.
         when ST_init =>
            NS <= ST_fet;

            PC_LD         <= '0';   PC_MUX_SEL <= "00";   PC_RST       <= '1';   PC_OE <= '0';   PC_INC   <= '0';
            SP_LD         <= '0';   SP_MUX_SEL <= "00";   SP_RST       <= '1';
            RF_WR         <= '0';   RF_WR_SEL  <= "00";   RF_OE        <= '0';
            REG_IMMED_SEL <= '0';   ALU_SEL    <= "0000";
            SCR_WR        <= '0';   SCR_OE     <= '0';    SCR_ADDR_SEL <= "00";
            C_LD       <= '0';    C_SET        <= '0';  C_CLR  <= '0';  SHAD_C_LD <= '0';
            Z_LD       <= '0';    Z_SET        <= '0';  Z_CLR  <= '0';  SHAD_Z_LD <= '0';
            I_SET         <= '0';   I_CLR      <= '0';
            IO_OE         <= '0';
            -- Shadows
            SHAD_C_SEL <= '0';
            SHAD_Z_SEL <= '0';

         -- STATE: the fetch cycle -----------------------------------
         when ST_fet =>
            NS <= ST_exec;

            PC_LD         <= '0';   PC_MUX_SEL <= "00";   PC_RST <= '0';
            PC_OE        <= '0';   PC_INC <= '1'; -- modified on fetch (it's supposed to increment!)
            SP_LD         <= '0';   SP_MUX_SEL <= "00";   SP_RST <= '0';
            RF_WR         <= '0';   RF_WR_SEL  <= "00";   RF_OE    <= '0';
            REG_IMMED_SEL <= '0';   ALU_SEL    <= "0000";
            SCR_WR        <= '0';   SCR_OE     <= '0';    SCR_ADDR_SEL <= "00";
            C_LD  <= '0';    C_SET   <= '0';  C_CLR <= '0';  SHAD_C_LD <= '0';
            Z_LD  <= '0';    Z_SET   <= '0';  Z_CLR <= '0';  SHAD_Z_LD <= '0';
            I_SET    <= '0';   I_CLR <= '0';
            IO_OE  <= '0';
            -- Shadows
            SHAD_C_SEL <= '0';
            SHAD_Z_SEL <= '0';

         -- STATE: the interrupt cycle ---------------------------------
         when ST_interrupt =>
            NS <= ST_fet;

            -- Use interrupts values.
            PC_LD         <= '1';   PC_RST     <= '0';    PC_OE        <= '1';      PC_INC <= '0';
            SP_LD         <= '1';   SP_MUX_SEL <= "10";   SP_RST       <= '0';      PC_MUX_SEL <= "10";
            RF_WR         <= '0';   RF_WR_SEL  <= "00";   RF_OE        <= '0';
            REG_IMMED_SEL <= '0';   ALU_SEL    <= "0000";
            SCR_WR        <= '1';   SCR_OE     <= '0';    SCR_ADDR_SEL <= "11";
            C_LD       <= '0';    C_SET        <= '0';  C_CLR      <= '0';  SHAD_C_LD  <= '1';
            Z_LD       <= '0';    Z_SET        <= '0';  Z_CLR      <= '0';  SHAD_Z_LD  <= '1';
            I_SET         <= '0';   I_CLR      <= '1';
            IO_OE         <= '0';
            -- Shadows
            SHAD_C_SEL <= '0';
            SHAD_Z_SEL <= '0';

         -- STATE: the execute cycle ---------------------------------
         when ST_exec =>
            -- support for interrupts
            if (INT = '0') then
               NS <= ST_fet;
            else
               NS <= ST_interrupt;
            end if;

            -- Repeat the default block for all variables here, noting that any output values desired to be different
            -- from init values shown below will be assigned in the following case statements for each opcode.
            PC_LD         <= '0';   PC_RST     <= '0';    PC_OE        <= '0';      PC_INC <= '0';
            SP_LD         <= '0';   SP_MUX_SEL <= "00";   SP_RST       <= '0';      PC_MUX_SEL <= "00";
            RF_WR         <= '0';   RF_WR_SEL  <= "00";   RF_OE        <= '0';
            REG_IMMED_SEL <= '0';   ALU_SEL    <= "0000";
            SCR_WR        <= '0';   SCR_OE     <= '0';    SCR_ADDR_SEL <= "00";
            C_LD       <= '0';    C_SET        <= '0';  C_CLR      <= '0';  SHAD_C_LD  <= '0';
            Z_LD       <= '0';    Z_SET        <= '0';  Z_CLR      <= '0';  SHAD_Z_LD  <= '0';
            I_SET         <= '0';   I_CLR      <= '0';
            IO_OE         <= '0';
            -- Shadows
            SHAD_C_SEL <= '0';
            SHAD_Z_SEL <= '0';


            case sig_OPCODE_7 is

               -- ADD Rd <- Rd + Rs --------- ***WORKS
               when "0000100" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  ALU_SEL <= "0000";
                  -- C
                  C_LD <= '1';
                  -- Z
                  Z_LD <= '1';

               -- ADD Rd <- Rd + IMMED_VALUE --------- ***WORKS
               when "1010000" | "1010001" | "1010010" | "1010011" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '1';
                  ALU_SEL <= "0000";
                  -- C
                  C_LD <= '1';
                  -- Z
                  Z_LD <= '1';

               -- ADDC Rd <- Rd + Rs + C ---------
               when "0000101" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  ALU_SEL <= "0001";
                  -- C
                  C_LD <= '1';
                  -- Z
                  Z_LD <= '1';

               -- ADDC Rd <- Rd + IMMED_VALUE + C ---------
               when "1010100" | "1010101" | "1010110" | "1010111" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  REG_IMMED_SEL <= '1';
                  -- ALU
                  ALU_SEL <= "0001";
                  -- C
                  C_LD <= '1';
                  -- Z
                  Z_LD <= '1';

               -- AND Rd <- Rd + Rs --------- ***WORKS
               when "0000000" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '0';
                  ALU_SEL <= "0101";
                  -- Z
                  Z_LD <= '1';

               -- AND Rd <- Rd + IMMED_VALUE --------- ***WORKS
               when "1000000" | "1000001" | "1000010" | "1000011" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '1';
                  ALU_SEL <= "0101";
                  -- Z
                  Z_LD <= '1';

               -- ASR Rd <- Rd(7) & Rd(6) & Rd(6:1), C <- Rd(0) ---- ***WORKS
               when "0100100" =>
                   -- Reg File
                   RF_OE <= '1';
                   RF_WR <= '1';
                   -- ALU
                   ALU_SEL <= "1101";
                   -- C
                   C_LD <= '1';
                   -- Z
                   Z_LD <= '1';

               -- BRCC ------------------- ***WORKS
               when "0010101" =>
                  if (C = '0') then
                     -- Program Counter
                     PC_LD <= '1';
                  end if;

               -- BRCS ------------------- ***WORKS
               when "0010100" =>
                  if (C = '1') then
                     -- Program Counter
                     PC_LD <= '1';
                  end if;

               -- BREQ ------------------- ***WORKS
               when "0010010" =>
                  if (Z = '1') then
                     -- Program Counter
                     PC_LD <= '1';
                  end if;

               -- BRN ------------------- ***WORKS
               when "0010000" =>
                  -- Program Counter
                  PC_LD <= '1';

               -- BRNE ------------------- ***WORKS
               when "0010011" =>
                  if (Z = '0') then
                     -- Program Counter
                     PC_LD <= '1';
                     PC_MUX_SEL <= "00";
                  end if;

               -- CALL PC <- IMMED, SP <- PC  --------- ***WORKS
               when "0010001" =>
                  -- Program Counter
                  PC_OE <= '1';
                  PC_LD <= '1';
                  -- Stack Pointer
                  SP_LD <= '1';
                  SP_MUX_SEL <= "10";
                  -- Scratch RAM
                  SCR_WR <= '1';
                  SCR_ADDR_SEL <= "11";

               -- CLC C <- 0  ---------
               when "0110000" =>
                  C_CLR <= '1';

               -- CLI C <- 0  --------- ***WORKS
               when "0110101" =>
                  I_CLR <= '1';

               -- CMP Rd - Rs --------- ***WORKS
               when "0001000" =>
                  -- Reg File
                  RF_OE <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '0';
                  ALU_SEL <= "0100";
                  -- Z
                  Z_LD <= '1';
                  -- C
                  C_LD <= '1';

               -- CMP Rd - IMMED_VALUE -------- ***WORKS
               when "1100000" | "1100001" | "1100010" | "1100011" =>
                  -- Reg File
                  RF_OE <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '1';
                  ALU_SEL <= "0100";
                  -- Z
                  Z_LD <= '1';
                  -- C
                  C_LD <= '1';

               -- EXOR reg-reg  --------- ***WORKS
               when "0000010" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '0';
                  ALU_SEL <= "0111";
                  -- Z
                  Z_LD <= '1';


               -- EXOR reg-immed  ------ ***WORKS
               when "1001000" | "1001001" | "1001010" | "1001011" =>
                  -- Reg File
                  RF_OE <= '1';
                  RF_WR <= '1';
                  -- ALU
                  REG_IMMED_SEL <= '1';
                  ALU_SEL <= "0111";
                  -- Z
                  Z_LD <= '1';

               -- IN Rd <- in_port(imm_val)  ------ ***WORKS
               when "1100100" | "1100101" | "1100110" | "1100111" =>
                  -- Reg File
                  RF_WR            <= '1';
                  RF_WR_SEL        <= "11";

               -- LD Rd <- (Rs) ------ ***WORKS
               when "0001010" =>
                  -- Reg File
                  RF_WR            <= '1';
                  RF_OE            <= '0';
                  RF_WR_SEL        <= "01";
                  -- Scratch RAM
                  SCR_OE <= '1';

               -- LD Rd <- IMMED_VALUE ------ ***WORKS
               when "1110000" | "1110001" | "1110010" | "1110011" =>
                  -- Reg File
                  RF_WR            <= '1';
                  RF_WR_SEL        <= "01";
                  -- Scratch RAM
                  SCR_OE <= '1';
                  SCR_ADDR_SEL <= "01";

               -- LSL Rd <- Rd(6:0) & C, C <- Rd(7)  ------ ***WORKS
               when "0100000" =>
                  -- Reg File
                  RF_WR            <= '1';
                  RF_OE            <= '1';
                  RF_WR_SEL        <= "00";
                  -- ALU
                  ALU_SEL          <= "1001";
                  -- C
                  C_LD <= '1';
                  -- Z
                  Z_LD <= '1';

               -- LSR Rd <- C & Rd(6:0), C <-- Rd(0)  ------ ***WORKS
               when "0100001" =>
                  -- Reg File
                  RF_WR            <= '1';
                  RF_OE            <= '1';
                  RF_WR_SEL        <= "00";
                  -- ALU
                  ALU_SEL          <= "1010";
                  -- C
                  C_LD <= '1';
                  -- Z
                  Z_LD <= '1';

               -- MOV Rd <- Rs ----- ***WORKS
               when "0001001" =>
                  -- Reg File
                  RF_WR            <= '1';
                  RF_OE            <= '1';
                  RF_WR_SEL        <= "00";
                  -- ALU
                  ALU_SEL          <= "1110";

               -- MOV Rd <- IMMED_VALUE  ------ ***WORKS
               when "1101100" | "1101101" | "1101110" | "1101111"  =>
                  -- Reg File
                  RF_WR <= '1';
                  RF_OE <= '1';
                  -- ALU
                  ALU_SEL <= "1110";
                  REG_IMMED_SEL <= '1';

               -- OR Rd <- Rd + Rs ---- *** WORKS
               when "0000001" =>
                   -- Reg File
                   RF_OE <= '1';
                   RF_WR <= '1';
                   -- ALU
                   ALU_SEL <= "0110";
                   -- Z
                   Z_LD <= '1';

               -- OR Rd <- Rd + IMMED_VALUE ---- ***WORKS
               when "1000100" | "1000101" | "1000110" | "1000111" =>
                   -- Reg File
                   RF_OE <= '1';
                   RF_WR <= '1';
                   -- ALU
                   ALU_SEL <= "0110";
                   REG_IMMED_SEL <= '1';
                   -- Z
                   Z_LD <= '1';

               -- OUT ---- ***WORKS
               when "1101000" | "1101001" | "1101010" | "1101011" =>
                   -- Reg File
                   RF_OE            <= '1';
                   -- Output
                   IO_OE            <= '1';

               -- POP Rd <- (SP), SP <- SP + 1 ----
               when "0100110"=>
                   -- Reg File
                   RF_WR            <= '1';
                   RF_WR_SEL        <= "01";
                   -- Stack Pointer
                   SP_LD <= '1';
                   SP_MUX_SEL <= "11";
                   -- Scratch RAM
                   SCR_OE <= '1';
                   SCR_ADDR_SEL <= "10";

               -- PUSH (SP) <- Rd, SP <- SP - 1 ---- ***WORKS
               when "0100101"=>
                   -- Reg File
                   RF_OE            <= '1';
                   -- Stack Pointer
                   SP_LD <= '1';
                   SP_MUX_SEL <= "10";
                   -- Scratch RAM
                   SCR_WR <= '1';
                   SCR_ADDR_SEL <= "11";

               -- RET PC <- (SP), SP + 1 ---- ***WORKS
               when "0110010" =>
                   -- Program Counter
                   PC_LD <= '1';
                   PC_MUX_SEL <= "01";
                   -- Stack Pointer
                   SP_LD <= '1';
                   SP_MUX_SEL <= "11";
                   -- Scratch RAM
                   SCR_OE <= '1';
                   SCR_ADDR_SEL <= "10";

               -- RETID PC <- (SP), SP + 1, Z <- ShadZ, C <- ShadC, IF <- 0 --
               when "0110110" =>
                   -- Program Counter
                   PC_LD <= '1';
                   PC_MUX_SEL <= "01";
                   -- Stack Pointer
                   SP_LD <= '1';
                   SP_MUX_SEL <= "11";
                   -- Scratch RAM
                   SCR_OE <= '1';
                   SCR_ADDR_SEL <= "10";
                   -- C Flag
                   --C_CLR <= '1';
                   C_LD <= '1';
                   SHAD_C_SEL <= '1';
                   -- Z Flag
                   Z_LD <= '1';
                   SHAD_Z_SEL <= '1';
                   -- I Flag
                   I_CLR <= '1';

               -- RETIE PC <- (SP), SP + 1, Z <- ShadZ, C <- ShadC, IF <- 1 --
               when "0110111" =>
                   -- Program Counter
                   PC_LD <= '1';
                   PC_MUX_SEL <= "01";
                   -- Stack Pointer
                   SP_LD <= '1';
                   SP_MUX_SEL <= "11";
                   -- Scratch RAM
                   SCR_OE <= '1';
                   SCR_ADDR_SEL <= "10";
                   -- C Flag
                   C_LD <= '1';
                   SHAD_C_SEL <= '1';
                   -- Z Flag
                   Z_LD <= '1';
                   SHAD_Z_SEL <= '1';
                   -- I Flag
                   I_SET <= '1';

               -- ROL Rd <- Rd(6:0) & Rd(7), C <- Rd(7) ---- ***WORKS
               when "0100010" =>
                   -- Reg File
                   RF_OE <= '1';
                   RF_WR <= '1';
                   -- ALU
                   ALU_SEL <= "1011";
                   -- C
                   C_LD <= '1';
                   -- Z
                   Z_LD <= '1';

               -- ROR Rd <- Rd(0) & Rd(7:1), C <- Rd(0) ---- *** WORKS
               when "0100011" =>
                   -- Reg File
                   RF_OE <= '1';
                   RF_WR <= '1';
                   -- ALU
                   ALU_SEL <= "1100";
                   -- C
                   C_LD <= '1';
                   -- Z
                   Z_LD <= '1';

               -- SEC C <- 1---- ***WORKS
               when "0110001" =>
                   C_SET <= '1';

               -- SEI IF <- 1---- ***WORKS
               when "0110100" =>
                   I_SET <= '1';

               -- ST (Rd) <- Rs ---- ***WORKS
               when "0001011" =>
                   -- Reg File
                   RF_OE <= '1';
                   -- Scratch RAM
                   SCR_WR <= '1';

               -- ST (IMMED_VALUE) <- Rd ---- ***WORKS
               when "1110100" | "1110101" | "1110110" | "1110111" =>
                   -- Reg File
                   RF_OE <= '1';
                   -- Scratch RAM
                   SCR_WR <= '1';
                   SCR_ADDR_SEL <= "01";

               -- SUB Rd <- Rd - IMMED_VALUE ---- ***WORKS
               when "1011000" | "1011001" | "1011010" | "1011011" =>
                   -- Reg File
                   RF_WR <= '1';
                   RF_OE <= '1';
                   -- ALU
                   ALU_SEL <= "0010";
                   REG_IMMED_SEL <= '1';
                   -- Z
                   Z_LD <= '1';
                   -- C
                   C_LD <= '1';

               -- SUB Rd <- Rd - Rs ----
               when "0000110" =>
                   -- Reg File
                   RF_WR <= '1';
                   RF_OE <= '1';
                   -- ALU
                   ALU_SEL <= "0010";
                   REG_IMMED_SEL <= '0';
                   -- Z
                   Z_LD <= '1';
                   -- C
                   C_LD <= '1';

               -- SUBC Rd <- Rd - Rs - C ---- ***WORKS
               when "0000111" =>
                   -- Reg File
                   RF_WR <= '1';
                   RF_OE <= '1';
                   -- ALU
                   ALU_SEL <= "0011";
                   -- Z
                   Z_LD <= '1';
                   -- C
                   C_LD <= '1';

               -- SUBC Rd <- Rd - IMMED_VALUE - C ---- ***WORKS
               when "1011100" | "1011101" | "1011110" | "1011111" =>
                   -- Reg File
                   RF_WR <= '1';
                   RF_OE <= '1';
                   -- ALU
                   ALU_SEL <= "0011";
                   REG_IMMED_SEL <= '1';
                   -- Z
                   Z_LD <= '1';
                   -- C
                   C_LD <= '1';

               -- TEST R1 AND R4 ---- ***WORKS
               when "0000011" =>
                   -- Reg File
                   RF_OE            <= '1';
                   -- ALU
                   ALU_SEL <= "1000";
                   REG_IMMED_SEL <= '1';
                   -- Z
                   Z_LD <= '1';

               -- TEST R1 AND IMMED_VALUE ---- ***WORKS
               when "1001100" | "1001101" | "1001110" | "1001111" =>
                   -- Reg File
                   RF_OE            <= '1';
                   -- ALU
                   ALU_SEL <= "1000";
                   -- Z
                   Z_LD <= '1';

               -- WSP SP <- Rd ---- ***WORKS
               when "0101000"=>
                   -- Reg File
                   RF_OE            <= '1';
                   -- Stack Pointer
                   SP_LD <= '1';


               when others =>
                  -- repeat the default block here to avoid incompletely specified outputs and hence avoid
                  -- the problem of inadvertently created latches within the synthesized system.
                  PC_LD         <= '0';   PC_MUX_SEL <= "00";   PC_RST <= '0';   PC_OE        <= '0';    PC_INC <= '0';
                  SP_LD         <= '0';   SP_MUX_SEL <= "00";   SP_RST <= '0';
                  RF_WR         <= '0';   RF_WR_SEL  <= "00";   RF_OE    <= '0';
                  REG_IMMED_SEL <= '0';   ALU_SEL    <= "0000";
                  SCR_WR        <= '0';   SCR_OE     <= '0';    SCR_ADDR_SEL <= "00";
                  C_LD  <= '0';    C_SET   <= '0';  C_CLR <= '0';  SHAD_C_LD <= '0';
                  Z_LD  <= '0';    Z_SET   <= '0';  Z_CLR <= '0';  SHAD_Z_LD <= '0';
                  I_SET    <= '0';   I_CLR <= '0';
                  IO_OE  <= '0';
                  -- Shadows
                  SHAD_C_SEL <= '0';
                  SHAD_Z_SEL <= '0';

             end case;

          when others =>
            NS <= ST_fet;

            -- repeat the default block here to avoid incompletely specified outputs and hence avoid
            -- the problem of inadvertently created latches within the synthesized system.
            PC_LD         <= '0';   PC_MUX_SEL <= "00";   PC_RST <= '0';   PC_OE        <= '0';   PC_INC <= '0';
            SP_LD         <= '0';   SP_MUX_SEL <= "00";   SP_RST <= '0';
            RF_WR         <= '0';   RF_WR_SEL  <= "00";   RF_OE    <= '0';
            REG_IMMED_SEL <= '0';   ALU_SEL    <= "0000";
            SCR_WR        <= '0';   SCR_OE     <= '0';    SCR_ADDR_SEL <= "00";
            C_LD  <= '0';    C_SET   <= '0';  C_CLR <= '0';  SHAD_C_LD <= '0';
            Z_LD  <= '0';    Z_SET   <= '0';  Z_CLR <= '0';  SHAD_Z_LD <= '0';
            I_SET    <= '0';   I_CLR <= '0';
            IO_OE  <= '0';
            -- Shadows
            SHAD_C_SEL <= '0';
            SHAD_Z_SEL <= '0';

       end case;
   end process comb_p;
end Behavioral;
