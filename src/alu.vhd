-------------------------------------------------------------------------------
-- Engineer: Robin Choudhury & Angela Yoeurng
--
-- Create Date:    09:37:23 01/27/2014
-- Module Name:    alu - Behavioral
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
    Port ( A           : in  STD_LOGIC_VECTOR (7 downto 0);
           FROM_IMMED  : in STD_LOGIC_VECTOR (7 downto 0);
           REG_IN      : in STD_LOGIC_VECTOR (7 downto 0);
           ALU_MUX_SEL : in STD_LOGIC;
           C_IN        : in  STD_LOGIC;
           SEL         : in  STD_LOGIC_VECTOR (3 downto 0);
           SUM         : out  STD_LOGIC_VECTOR (7 downto 0);
           C_FLAG      : out  STD_LOGIC;
           Z_FLAG      : out  STD_LOGIC);
end alu;

architecture Behavioral of alu is

   signal sum_copy : STD_LOGIC_VECTOR(7 downto 0);
   signal B : STD_LOGIC_VECTOR (7 downto 0);



begin
-- select the B input before utilizing it
process (ALU_MUX_SEL,REG_IN, FROM_IMMED)
begin
   if (ALU_MUX_SEL = '0') then
      B <= REG_IN;
   elsif (ALU_MUX_SEL = '1') then
      B <= FROM_IMMED;
   else
      B <= (others => '0');
   end if;
end process;

   -- Shift operations are performed on A input.
process(A, B, C_IN, SEL)
   variable result : STD_LOGIC_VECTOR (8 downto 0);
   variable carry : STD_LOGIC;
   begin
      case SEL is
         -- ADD
         when "0000" =>
            result := ('0' & A) + ('0' & B);
            -- The MSB represents the carry in.
            carry := result(8);
         -- ADDC
         when "0001" =>
            result := ('0' & A) + ('0' & B) + (x"00" & C_IN);
            carry := result(8);
         -- SUB
         when "0010" =>
            result := ('0' & A) - ('0' & B);
            carry := result(8);
         -- SUBC
         when "0011" =>
            result := ('0' & A) - ('0' & B) - (x"00" & C_IN);
            carry := result(8);
         -- CMP
         when "0100" =>
            result := ('0' & A) - ('0' & B);
            carry := result(8);
         -- AND
         when "0101" =>
            result := ('0' & A) and ('0' & B);
            carry := C_IN;
         -- OR
         when "0110" =>
            result := ('0' & A) or ('0' & B);
            carry := C_IN;
         -- EXOR
         when "0111" =>
            result := ('0' & A) xor ('0' & B);
            carry := C_IN;
         -- TEST
         when "1000" =>
            result := ('0' & A) and ('0' & B);
            carry := C_IN;
         -- LSL
         when "1001" =>
            result := ('0' & A(6 downto 0) & C_IN);
            carry := A(7);
         -- LSR
         when "1010" =>
            result := ('0' & C_IN & A(7 downto 1));
            carry := A(0);
         -- ROL
         when "1011" =>
            result := ('0' & A(6 downto 0) & A(7));
            carry := A(7);
         -- ROR
         when "1100" =>
            result := ('0' & A(0) & A(7 downto 1));
            carry := A(0);
         -- ASR
         when "1101" =>
            result := ('0' & A(7) & A(7) & A(6 downto 1));
            carry := A(0);
         -- MOV
         when "1110" =>
            result := '0' & B;
            carry := C_IN; -- <carry$mux0000> created at line 50
         when others =>
            result := (others => '0');
            carry := C_IN;
      end case;
      SUM <= result(7 downto 0);
      sum_copy <= result(7 downto 0);
      C_FLAG <= carry;
end process;

process(sum_copy)
   begin
      if (sum_copy = "0000000") then
         Z_FLAG <= '1';
      else
         Z_FLAG <= '0';
      end if;
end process;

end Behavioral;
