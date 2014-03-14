-------------------------------------------------------------------------------
-- Engineer: Robin Choudhury & Angela Yoeurng
--
-- Module Name:    RAT_wrapper - Behavioral
--
-- A wrapper module that connects the RAT CPU to all it's inputs and outputs.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_wrapper is
    Port ( RST                   : in    STD_LOGIC;
           CLK                   : in    STD_LOGIC;
           SSEG_OUT              : out   STD_LOGIC_VECTOR(7 downto 0);
           SSEG_EN               : out   STD_LOGIC_VECTOR(3 downto 0);
           LEDS                  : out   STD_LOGIC_VECTOR(7 downto 0);
           RANDOM_NUM            : out   STD_LOGIC_VECTOR(7 downto 0);

           -- PS/2 signals
           ps2c, ps2d            : inout std_logic;

           -- VGA output signals
           VGA_RGB               : out std_logic_vector(7 downto 0);
           VGA_HS                : out std_logic;
           VGA_VS                : out std_logic);

end RAT_wrapper;

architecture Behavioral of RAT_wrapper is


-- INPUT PORT IDS
CONSTANT VGA_READ_ID        : STD_LOGIC_VECTOR(7 downto 0)  := x"93";
CONSTANT PS2_KEY_CODE_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"44";
CONSTANT PS2_STATUS_ID      : STD_LOGIC_VECTOR (7 downto 0) := X"45";
CONSTANT RANDOM_NUMBER_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"75";

-- OUTPUT PORT IDS
CONSTANT SSEG_ID        : STD_LOGIC_VECTOR(7 downto 0)  := x"81";
CONSTANT VGA_HADDR_ID   : STD_LOGIC_VECTOR(7 downto 0)  := x"90";
CONSTANT VGA_LADDR_ID   : STD_LOGIC_VECTOR(7 downto 0)  := x"91";
CONSTANT VGA_WRITE_ID   : STD_LOGIC_VECTOR(7 downto 0)  := x"92";
CONSTANT PS2_CONTROL_ID : STD_LOGIC_VECTOR (7 downto 0) := X"46";

-- Declare components
component RAT_CPU
    Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
           OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
           RST      : in  STD_LOGIC;
           IO_OE    : out STD_LOGIC;
           INT_IN   : in  STD_LOGIC;
           CLK      : in  STD_LOGIC);
end component RAT_CPU;

component clk_div2 is
    Port (  clk : in std_logic;
           sclk : out std_logic);
end component;

component PS2_REGISTER is
   PORT (
      PS2_DATA_READY,
      PS2_ERROR            : out STD_LOGIC;
      PS2_KEY_CODE         : out STD_LOGIC_VECTOR(7 downto 0);
      PS2_CLK              : inout STD_LOGIC;
      PS2_DATA             : in STD_LOGIC;
      PS2_CLEAR_DATA_READY : in STD_LOGIC);
end component;

component sseg_dec is
    Port (ALU_VAL : in std_logic_vector(7 downto 0);
          SIGN : in std_logic;
          VALID : in std_logic;
          CLK : in std_logic;
          DISP_EN : out std_logic_vector(3 downto 0);
          SEGMENTS : out std_logic_vector(7 downto 0));
end component;

component vgaDriverBuffer is
   Port (CLK, we : in std_logic;
         wa   : in std_logic_vector (10 downto 0);
         wd   : in std_logic_vector (7 downto 0);
         Rout : out std_logic_vector(2 downto 0);
         Gout : out std_logic_vector(2 downto 0);
         Bout : out std_logic_vector(1 downto 0);
         HS   : out std_logic;
         VS   : out std_logic;
         pixelData : out std_logic_vector(7 downto 0));
end component;

component pseudo_random is
   Port (                clk : in std_logic;
           pseudo_random_num : out std_logic_vector (7 downto 0));
end component;

signal slow_clk   : std_logic;

-- Signals for connecting RAT_CPU to RAT_wrapper
signal input_port  : std_logic_vector (7 downto 0);
signal output_port : std_logic_vector (7 downto 0);
signal port_id     : std_logic_vector (7 downto 0);
signal load        : std_logic;
signal sseg_val     : std_logic_vector(7 downto 0) := x"00";    -- initially blank/off

-- Random Numbers
signal random_number  : std_logic_vector (7 downto 0);


-- VGA signals
signal vga_we   : std_logic;                       -- Write enable
signal vga_wa   : std_logic_vector(10 downto 0);   -- The address to read from / write to
signal vga_wd   : std_logic_vector(7 downto 0);    -- The pixel data to write to the framebuffer
signal vgaData  : std_logic_vector(7 downto 0);    -- The pixel data read from the framebuffer

-- Keyboard signals
signal kbd_data : std_logic_vector(7 downto 0);
signal ps2KeyCode, ps2Status, new_ps2Status, ps2ControlReg       : std_logic_vector (7 downto 0);


begin
-- This filters the output of the keyboard diver to keep it from freezing your program ---

stopbug: process (ps2KeyCode, ps2Status, CLK)
   begin
   if(rising_edge(CLK)) then
      case ps2KeyCode is
      when  x"F0" | x"FF" | x"15" | x"1D" | x"24" | x"1C" | x"23" | x"1A" | x"22" | x"21" | x"6C" | x"75" | x"7D" | x"6B" | x"74" | x"69" | x"72" | x"7A" | x"2D" | x"2C" | x"35" | x"3C" | x"43" | x"44"
          | x"4D" | x"54" | x"5B" | x"5D" | x"58" | x"1B" | x"2B" | x"34" | x"33" | x"3B" | x"42" | x"4B" | x"4C" | x"52" | x"5A" | x"12" | x"2A" | x"32" | x"31" | x"3A" | x"41" | x"49" | x"4A"
          | x"59" | x"14" | x"11" | x"29" | x"73" | x"70" | x"71" | x"79" | x"7B" | x"7C" | x"77"      =>
         new_ps2Status <= ps2Status;
      when others =>
      new_ps2Status <= ps2Status(7 downto 2) & '0' & ps2Status(0);
      end case;
   end if;
   end process stopbug;

   -- Instantiate RAT_CPU
   CPU: RAT_CPU
      port map(IN_PORT  => input_port,
               OUT_PORT => output_port,
               PORT_ID  => port_id,
               RST      => RST,
               IO_OE    => load,
               INT_IN   => new_ps2Status(1),
               CLK      => CLK);

   SSEG: sseg_dec
      port map(ALU_VAL => sseg_val,
               SIGN => '0',
               VALID => '1',
               CLK => CLK,
               DISP_EN => SSEG_EN,
               SEGMENTS => SSEG_OUT);

   VGA: vgaDriverBuffer
      port map(CLK => CLK,
               WE => vga_we,
               WA => vga_wa,
               WD => vga_wd,
               Rout => VGA_RGB(7 downto 5),
               Gout => VGA_RGB(4 downto 2),
               Bout => VGA_RGB(1 downto 0),
               HS => VGA_HS,
               VS => VGA_VS,
               pixelData => vgaData);

   PS2_DRIVER : PS2_REGISTER
      port map(PS2_DATA             => PS2D,
               PS2_CLK              => ps2c,
               PS2_CLEAR_DATA_READY => ps2ControlReg(0),
               PS2_KEY_CODE         => ps2KeyCode,
               PS2_DATA_READY       => ps2Status(1),
               PS2_ERROR            => ps2Status(0));

   slow : clk_div2
    Port map(  clk => clk,
              sclk => slow_clk);

   random: pseudo_random
      port map( clk               => slow_clk,
                pseudo_random_num => random_number);

   LEDS <= random_number;

   -- Process for selecting what input to read
   INPUTS: process(CLK,port_id, ps2KeyCode, ps2Status, vgaData)
   begin
      if port_id = VGA_READ_ID then
         input_port <= vgaData;
     elsif port_id = PS2_KEY_CODE_ID then
         input_port <= ps2KeyCode;
      elsif port_id = PS2_STATUS_ID then
         input_port <= new_ps2Status;
      elsif port_id = RANDOM_NUMBER_ID then
         input_port <= random_number;
      else
         input_port <= x"00";
      end if;
   end process INPUTS;


  -- Process for updating outputs
   OUTPUTS: process(load, CLK)
   begin
      if (rising_edge(CLK) and load = '1') then
         if port_id = SSEG_ID then
            sseg_val <= output_port;
         -- PS2 Driver support ------------------------------------
         elsif port_id = PS2_CONTROL_ID  then
            ps2ControlReg  <= output_port;

         -- VGA
         elsif port_id = VGA_HADDR_ID then
            vga_wa(10 downto 8) <= output_port(2 downto 0);
         elsif port_id = VGA_LADDR_ID then
            vga_wa(7 downto 0) <= output_port;
         elsif port_id = VGA_WRITE_ID then
            vga_wd <= output_port;

         end if;

         if( port_id = VGA_WRITE_ID ) then
            vga_we <= '1';
         else
            vga_we <= '0';
         end if;

      end if;
   end process OUTPUTS;

end Behavioral;
