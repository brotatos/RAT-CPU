----------------------------------------------------------------------------------
-- Company: Barefoot Engineering
-- Engineer: James Ratner
--
-- Create Date:    20:59:29 02/04/2013
-- Design Name:
-- Module Name:    RAT_Wrapper - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:  A RAT Wrapper that provides PS2 keyboard driver and VGA support.
--               The old CPE 133 SSEG driver is used also.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAT_wrapper is
    Port ( SWITCHES : in    STD_LOGIC_VECTOR(7 downto 0);
           --INT      : in    STD_LOGIC; -- driven internally
           RST      : in    STD_LOGIC;
           CLK      : in    STD_LOGIC;
           SSEG_OUT : out   STD_LOGIC_VECTOR(7 downto 0);
           SSEG_EN  : out   STD_LOGIC_VECTOR(3 downto 0);
           LEDS     : out   STD_LOGIC_VECTOR(7 downto 0);

           -- PS/2 signals
           ps2d, ps2c: inout  std_logic;

           -- VGA output signals
           VGA_RGB  : out std_logic_vector(7 downto 0);
           VGA_HS   : out std_logic;
           VGA_VS   : out std_logic);
end RAT_wrapper;



architecture Behavioral of RAT_wrapper is

   -- INPUT PORT IDS
   CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := x"20";
   CONSTANT VGA_READ_ID : STD_LOGIC_VECTOR(7 downto 0) := x"93";
   CONSTANT PS2_KEY_CODE_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"44";
   CONSTANT PS2_STATUS_ID    : STD_LOGIC_VECTOR (7 downto 0) := X"45";


   -- OUTPUT PORT IDS
   CONSTANT LEDS_ID      : STD_LOGIC_VECTOR(7 downto 0) := x"40";
   CONSTANT SSEG_ID      : STD_LOGIC_VECTOR(7 downto 0) := x"81";
   CONSTANT VGA_HADDR_ID : STD_LOGIC_VECTOR(7 downto 0) := x"90";
   CONSTANT VGA_LADDR_ID : STD_LOGIC_VECTOR(7 downto 0) := x"91";
   CONSTANT VGA_WRITE_ID : STD_LOGIC_VECTOR(7 downto 0) := x"92";
   CONSTANT PS2_CONTROL_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"46";

   -- Declare components -----------------------------------------------
   component RAT_CPU
       Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              RST      : in  STD_LOGIC;
              IO_OE    : out STD_LOGIC;
              INT_IN   : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
   end component RAT_CPU;

   component PS2_REGISTER is
      PORT (
         PS2_DATA_READY,
         PS2_ERROR            : out STD_LOGIC;
         PS2_KEY_CODE         : out STD_LOGIC_VECTOR(7 downto 0);
         PS2_CLK              : inout STD_LOGIC;
         PS2_DATA             : in STD_LOGIC;
         PS2_CLEAR_DATA_READY : in STD_LOGIC);
   end component;

   component db_1shot is
      Port ( A, CLK: in  STD_LOGIC;
             A_DB : out  STD_LOGIC);
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


   -- Signals for connecting RAT_CPU to RAT_wrapper
   signal input_port  : std_logic_vector (7 downto 0);
   signal output_port : std_logic_vector (7 downto 0);
   signal port_id     : std_logic_vector (7 downto 0);
   signal load        : std_logic;

   signal sseg_val     : std_logic_vector(7 downto 0) := x"FF";    -- initially blank/off


   -- VGA signals
   signal r_vga_we   : std_logic;                       -- Write enable
   signal r_vga_wa   : std_logic_vector(10 downto 0);   -- The address to read from / write to
   signal r_vga_wd   : std_logic_vector(7 downto 0);    -- The pixel data to write to the framebuffer
   signal r_vgaData  : std_logic_vector(7 downto 0);    -- The pixel data read from the framebuffer


   -- Keyboard signals
   signal kbd_data : std_logic_vector(7 downto 0);
   signal ps2KeyCode, ps2Status, ps2ControlReg       : std_logic_vector (7 downto 0);

begin

   -- Instantiate RAT_CPU
   CPU: RAT_CPU
      port map(IN_PORT  => input_port,
               OUT_PORT => output_port,
               PORT_ID  => port_id,
               RST      => RST,
               IO_OE    => load,
               INT_IN   => ps2Status(1),
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
               WE => r_vga_we,
               WA => r_vga_wa,
               WD => r_vga_wd,
               Rout => VGA_RGB(7 downto 5),
               Gout => VGA_RGB(4 downto 2),
               Bout => VGA_RGB(1 downto 0),
               HS => VGA_HS,
               VS => VGA_VS,
               pixelData => r_vgaData);

   PS2_DRIVER : PS2_REGISTER
   port map(PS2_DATA             => ps2d,
            PS2_CLK              => ps2c,
            PS2_CLEAR_DATA_READY => ps2ControlReg(0),
            PS2_KEY_CODE         => ps2KeyCode,
            PS2_DATA_READY       => ps2Status(1),
            PS2_ERROR            => ps2Status(0));


   -- Process for selecting what input to read
   INPUTS: process(CLK, port_id, SWITCHES, r_vgaData, ps2KeyCode, ps2Status)
   begin
      if port_id = SWITCHES_ID then
         input_port <= SWITCHES;
      elsif port_id = VGA_READ_ID then
         input_port <= r_vgaData;
      elsif port_id = PS2_KEY_CODE_ID then
         input_port <= ps2KeyCode;
      elsif port_id = PS2_STATUS_ID then
         input_port <= ps2Status;
      else
         input_port <= x"00";
      end if;
   end process INPUTS;



   -- Process for updating outputs
   OUTPUTS: process(load, CLK)
   begin
      if (rising_edge(CLK) and load = '1') then
        if port_id = LEDS_ID then
            LEDS <= output_port;

         -- PS2 Driver support ------------------------------------
         elsif port_id = PS2_CONTROL_ID  then
            ps2ControlReg  <= output_port;
         elsif port_id = SSEG_ID then
            sseg_val <= output_port;

         -- VGA support -------------------------------------------
         elsif (port_id = VGA_HADDR_ID) then
            r_vga_wa(10 downto 8) <= output_port(2 downto 0);
         elsif (port_id = VGA_LADDR_ID) then
            r_vga_wa(7 downto 0) <= output_port;
         elsif (port_id = VGA_WRITE_ID) then
            r_vga_wd <= output_port;
         end if;

         if( port_id = VGA_WRITE_ID ) then
            r_vga_we <= '1';
         else
            r_vga_we <= '0';
         end if;

      end if;
   end process OUTPUTS;


end Behavioral;
