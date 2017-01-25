--
-- TeC7 VHDL Source Code
--    Tokuyama kousen Educational Computer Ver.7
--
-- Copyright (C) 2002-2017 by
--                      Dept. of Computer Science and Electronic Engineering,
--                      Tokuyama College of Technology, JAPAN
--
--   ��L���쌠�҂́CFree Software Foundation �ɂ���Č��J����Ă��� GNU ��ʌ�
-- �O���p�����_�񏑃o�[�W�����Q�ɋL�q����Ă�������𖞂����ꍇ�Ɍ���C�{�\�[�X
-- �R�[�h(�{�\�[�X�R�[�h�����ς������̂��܂ށD�ȉ����l)���g�p�E�����E���ρE�Ĕz
-- �z���邱�Ƃ𖳏��ŋ�������D
--
--   �{�\�[�X�R�[�h�́��S���̖��ۏ؁��Œ񋟂������̂ł���B��L���쌠�҂����
-- �֘A�@�ցE�l�͖{�\�[�X�R�[�h�Ɋւ��āC���̓K�p�\�����܂߂āC�����Ȃ�ۏ�
-- ���s��Ȃ��D�܂��C�{�\�[�X�R�[�h�̗��p�ɂ�蒼�ړI�܂��͊ԐړI�ɐ�����������
-- �鑹�Q�Ɋւ��Ă��C���̐ӔC�𕉂�Ȃ��D
--
--
-- tec7.vhd : TeC7 Top Level
--
-- 2017.01.25 : PS2�AVGA�֘A�̃��W���[���y�уV�O�i�����폜
-- 2016.01.08 : P_PS2_CLK �� inout �ɕύX(�o�O����)
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- library UNISIM;
-- use UNISIM.VComponents.all;

entity TeC7 is
    Port ( CLK_IN    : in    std_logic;
           JP_IN     : inout std_logic_vector (1 downto 0);

           -- CONSOLE(INPUT)
           DATA_SW   : in   std_logic_vector (7 downto 0);
           RESET_SW  : in   std_logic;
           SETA_SW   : in   std_logic;
           INCA_SW   : in   std_logic;
           DECA_SW   : in   std_logic;
           WRITE_SW  : in   std_logic;
           STEP_SW   : in   std_logic;
           BREAK_SW  : in   std_logic;
           STOP_SW   : in   std_logic;
           RUN_SW    : in   std_logic;
           RIGHT_SW  : in   std_logic;
           LEFT_SW   : in   std_logic;

           -- CONSOLE(OUTPUT)
           ADDR_LED  : out  std_logic_vector (7 downto 0);
           DATA_LED  : out  std_logic_vector (7 downto 0);
           RUN_LED   : out  std_logic;
           C_LED     : out  std_logic;
           S_LED     : out  std_logic;
           Z_LED     : out  std_logic;
           G0_LED    : out  std_logic;
           G1_LED    : out  std_logic;
           G2_LED    : out  std_logic;
           SP_LED    : out  std_logic;
           PC_LED    : out  std_logic;
           MM_LED    : out  std_logic;
           SPK_OUT   : out  std_logic;

           -- SIO
           SIO_RXD   : in   std_logic;
           SIO_TXD   : out  std_logic;

           -- PIO
           EXT_IN    : in   std_logic_vector (7 downto 0);
           ADC_REF   : out  std_logic_vector (7 downto 0);
           EXT_OUT   : out  std_logic_vector (7 downto 0);

           -- uSD
           SPI_SCLK  : out  std_logic;
           SPI_DIN   : in   std_logic;
           SPI_DOUT  : out  std_logic;
           SPI_CS    : out  std_logic;
           ACC_LED   : out  std_logic

         );
end TeC7;

architecture Behavioral of TeC7 is
signal i_reset_tec   : std_logic;
signal i_reset_tac   : std_logic;
signal i_mode        : std_logic_vector (1 downto 0);  -- mode
signal i_locked_tac  : std_logic;
signal i_locked_delay: std_logic;
signal i_locked_tec  : std_logic;
signal i_locked      : std_logic;
signal i_49_1520MHzNB: std_logic;
signal i_2_4576MHz   : std_logic;
signal i_9_8304MHz   : std_logic;
signal i_25_1221MHz  : std_logic;
signal i_49_1520MHz0 : std_logic;
signal i_49_1520MHz90: std_logic;

signal i_in          : std_logic_vector(27 downto 0);
signal i_in_tec      : std_logic_vector(27 downto 0);
signal i_in_tac      : std_logic_vector(27 downto 0);

signal i_out         : std_logic_vector(43 downto 0);
signal i_out_tec     : std_logic_vector(43 downto 0);
signal i_out_tac     : std_logic_vector(43 downto 0);

signal i_com_ctr     : std_logic;                      -- TaC��TeC�̃R���\�[�����o�͂��邽�߂̐؂�ւ��M�����i�ǋL�F2016/10/6�j
signal i_console_ctr : std_logic;                      -- TacOS��ŃR���\�[�����o�͂�TeC���[�h�ɕύX���邽�߂̐؂�ւ��M�����i�ǋL�F2016/10/6�j
signal i_serial_ctr  : std_logic;                      -- TeC/TaC���V���A���ʐM���邽�߂̐؂�ւ��M�����i�ǋL�F2016/9/5�j
signal i_com_line    : std_logic_vector(18 downto 0);  -- TaC�ɂ��TeC�̃R���\�[���ł����ݗp(�ǋL�F2016/8/30)

signal i_in_tac_sio  : std_logic;
signal i_out_tac_sio : std_logic;

component IBUFG
    port ( I         : in     std_logic;
           O         : out    std_logic
         );
end component;

component DCM_TAC
    port ( CLK_IN1   : in     std_logic;  --  9.8304MHz
           CLK_OUT1  : out    std_logic;  -- 49.1520MHz 0'
--           CLKFB_IN  : in     std_logic;
--           CLKFB_OUT : in     std_logic;
           LOCKED    : out    std_logic
         );
end component;

component DELAY90
    port ( CLK_IN1   : in     std_logic;  -- 49.1520MHz 0'
           CLK_OUT1  : out    std_logic;  -- 49.1520MHz 0'
           CLK_OUT2  : out    std_logic;  -- 49.1520MHz 90'
           LOCKED    : out    std_logic
         );
end component;

component DCM_TEC
    port ( CLK_IN1   : in     std_logic;  --  9.8304MHz
           CLK_OUT1  : out    std_logic;  --  2.4576MHz
           CLK_OUT2  : out    std_logic;  -- 25.1221MHz
           LOCKED    : out    std_logic
         );
end component;

component MODE
    port ( P_CLK    : in    std_logic;
           P_LOCKED : in    std_logic;
           P_JP     : inout std_logic_vector(1 downto 0);
           P_MODE   : out   std_logic_vector(1 downto 0);
           P_RESET  : out   std_logic
          );
end component;

component TEC
    port ( P_RESET    : in    std_logic;
           P_MODE     : in    std_logic_vector(1 downto 0);
           P_CLK      : in    std_logic;                      -- 2.4576MHz

           -- CONSOLE(INPUT)
           P_DATA_SW  : in    std_logic_vector(7 downto 0);   -- Data  SW
           P_RESET_SW : in    std_logic;
           P_SETA_SW  : in    std_logic;                      -- SETA  SW
           P_INCA_SW  : in    std_logic;                      -- INCA  SW
           P_DECA_SW  : in    std_logic;                      -- DECA  SW
           P_WRITE_SW : in    std_logic;                      -- WRITE SW
           P_STEP_SW  : in    std_logic;                      -- STEP  SW
           P_BREAK_SW : in    std_logic;                      -- BREAK SW
           P_STOP_SW  : in    std_logic;                      -- STOP  SW
           P_RUN_SW   : in    std_logic;                      -- RUN   SW
           P_RCW_SW   : in    std_logic;                      -- Rotate SW(CW)
           P_RCCW_SW  : in    std_logic;                      -- Rotate SW(CCW)

           -- CONSOLE(OUTPUT)
           P_A_LED    : out   std_logic_vector(7 downto 0);   -- Address LED
           P_D_LED    : out   std_logic_vector(7 downto 0);   -- Data LED
           P_R_LED    : out   std_logic;                      -- RUN   LED
           P_C_LED    : out   std_logic;                      -- Carry LED
           P_S_LED    : out   std_logic;                      -- Sing  LED
           P_Z_LED    : out   std_logic;                      -- Zero  LED
           P_G0_LED   : out   std_logic;                      -- G0    LED
           P_G1_LED   : out   std_logic;                      -- G1    LED
           P_G2_LED   : out   std_logic;                      -- G2    LED
           P_SP_LED   : out   std_logic;                      -- SP    LED
           P_PC_LED   : out   std_logic;                      -- PC    LED
           P_MM_LED   : out   std_logic;                      -- MM    LED
           P_BUZ      : out   std_logic;                      -- BUZZER OUT

           -- SIO
           P_SIO_RXD  : in    std_logic;                      -- SIO Receive
           P_SIO_TXD  : out   std_logic;                      -- SIO Transmit
            
           -- PIO
           P_EXT_IN   : in   std_logic_vector (7 downto 0);
           P_ADC_REF  : out  std_logic_vector (7 downto 0);
           P_EXT_OUT  : out  std_logic_vector (7 downto 0)
         );
end component;

component TAC
    Port ( P_CLK0     : in std_logic;                         -- 49.152MHz 0'
           P_CLK90    : in std_logic;                         -- 49.152MHz 90'
           P_MODE     : in std_logic_vector(1 downto 0);      -- 0:TeC,1:TaC,
           P_RESET    : in std_logic;                         -- 2,3:Demo1,2

           -- CONSOLE(INPUT)
           P_DATA_SW  : in    std_logic_vector(7 downto 0);   -- Data  SW
           P_RESET_SW : in    std_logic;
           P_SETA_SW  : in    std_logic;                      -- SETA  SW
           P_INCA_SW  : in    std_logic;                      -- INCA  SW
           P_DECA_SW  : in    std_logic;                      -- DECA  SW
           P_WRITE_SW : in    std_logic;                      -- WRITE SW
           P_STEP_SW  : in    std_logic;                      -- STEP  SW
           P_BREAK_SW : in    std_logic;                      -- BREAK SW
           P_STOP_SW  : in    std_logic;                      -- STOP  SW
           P_RUN_SW   : in    std_logic;                      -- RUN   SW
           P_RCW_SW   : in    std_logic;                      -- Rotate SW(CW)
           P_RCCW_SW  : in    std_logic;                      -- Rotate SW(CCW)

           -- CONSOLE(OUTPUT)
           P_A_LED    : out   std_logic_vector(7 downto 0);   -- Address LED
           P_D_LED    : out   std_logic_vector(7 downto 0);   -- Data LED
           P_R_LED    : out   std_logic;                      -- RUN   LED
           P_C_LED    : out   std_logic;                      -- Carry LED
           P_S_LED    : out   std_logic;                      -- Sing  LED
           P_Z_LED    : out   std_logic;                      -- Zero  LED
           P_G0_LED   : out   std_logic;                      -- G0    LED
           P_G1_LED   : out   std_logic;                      -- G1    LED
           P_G2_LED   : out   std_logic;                      -- G2    LED
           P_SP_LED   : out   std_logic;                      -- SP    LED
           P_PC_LED   : out   std_logic;                      -- PC    LED
           P_MM_LED   : out   std_logic;                      -- MM    LED
           P_BUZ      : out   std_logic;                      -- BUZZER OUT

           -- SIO
           P_SIO_RXD  : in    std_logic;                      -- SIO Receive
           P_SIO_TXD  : out   std_logic;                      -- SIO Transmit

           P_SIO_RXD2  : in    std_logic;                     -- SIO Receive2
           P_SIO_TXD2  : out   std_logic;                     -- SIO Transmit2

           -- PIO
           P_ADC_REF  : out  std_logic_vector (7 downto 0);
           P_EXT_OUT  : out  std_logic_vector (7 downto 0);
           P_EXT_IN   : in  std_logic_vector (7 downto 0);

           -- COM
           P_COM_CTR     : out  std_logic;
           P_CONSOLE_CTR : out  std_logic;
           P_SERIAL_CTR  : out  std_logic;
           P_COM_LINE    : out  std_logic_vector (18 downto 0);

           -- uSD
           P_SPI_SCLK : out  std_logic;
           P_SPI_DIN  : in  std_logic;
           P_SPI_DOUT : out  std_logic;
           P_SPI_CS   : out  std_logic;
           P_ACC_LED  : out  std_logic

    );
end component;

begin
  IBUFG1 : IBUFG
    port map ( O => i_9_8304MHz, I => CLK_IN );
     
  DCM_TAC1 : DCM_TAC
    port map ( CLK_IN1  => i_9_8304MHz,
               CLK_OUT1 => i_49_1520MHzNB,
--               CLKFB_IN => i_dcm_fb,
--               CLKFB_OUT=> i_dcm_fb,
               LOCKED   => i_locked_tac
             );
				 
  DELAY : DELAY90
    port map ( CLK_IN1  => i_49_1520MHzNB,
               CLK_OUT1 => i_49_1520MHz0,
               CLK_OUT2 => i_49_1520MHz90,
               LOCKED   => i_locked_delay
             );

  DCM_TEC1 : DCM_TEC
    port map ( CLK_IN1  => i_9_8304MHz,
               CLK_OUT1 => i_2_4576MHz,
               CLK_OUT2 => i_25_1221MHz,
               LOCKED   => i_locked_tec
             );

  i_locked <= i_locked_tac and i_locked_delay and i_locked_tec;

  -- Determin TeC/TaC/DEMO1/DEMO2 mode
  MODE1 : MODE
    port map ( P_CLK     => i_2_4576MHz,
               P_LOCKED  => i_locked,
               P_JP      => JP_IN,
               P_MODE    => i_mode,
               P_RESET   => i_reset_tec
             );

  -- Synchronize TaC reset with TaC closk
  process(i_49_1520MHz0)
    begin
      if (i_49_1520MHz0'event and i_49_1520MHz0='1') then
        i_reset_tac <= i_reset_tec;
      end if;
    end process;

  -- I/O Switch (select TeC/TaC)
  -- INPUT
  i_in(27 downto 20) <= EXT_IN;
  -- TeC/TaC�ʐM�p�̐ڑ����I�𕔕�(�ǋL�F2016/8/30)
  i_in(19 downto 1) <= i_com_line when i_com_ctr='1' else
                       DATA_SW  & -- i_in(19 downto 12)
                       RESET_SW & -- i_in(11)
                       SETA_SW  & -- i_in(10)
                       INCA_SW  & -- i_in(9)
                       DECA_SW  & -- i_in(8)
                       WRITE_SW & -- i_in(7)
                       STEP_SW  & -- i_in(6)
                       BREAK_SW & -- i_in(5)
                       STOP_SW  & -- i_in(4)
                       RUN_SW   & -- i_in(3)
                       RIGHT_SW & -- i_in(2)
                       LEFT_SW;   -- i_in(1)
  i_in(0) <= SIO_RXD;
  i_in_tec(27 downto 1) <= "000000000000000000000000000" when (i_mode="01" and i_console_ctr='0') else i_in(27 downto 1);
  i_in_tac(27 downto 1) <= i_in(27 downto 1) when (i_mode="01" and i_console_ctr='0') else "000000000000000000000000000";
  
  -- TaC���^�[�~�i���\�t�g�Ƃ��ė��p����ۂ̐؂�ւ�
  i_in_tec(0) <= i_out_tac_sio when i_serial_ctr='1' else i_in(0);
  i_in_tac_sio <= i_out_tec(0) when i_serial_ctr='1' else '0';
  i_in_tac(0) <=  i_in(0);
  
  -- OUTPUT
  ADC_REF <= i_out(43 downto 36);
  EXT_OUT <= i_out(35 downto 28);
  ADDR_LED <= not i_out(27 downto 20);
  DATA_LED <= not i_out(19 downto 12);  
  RUN_LED <= not i_out(11);
  C_LED <= not i_out(10);
  S_LED <= not i_out(9);
  Z_LED <= not i_out(8);
  G0_LED <= not i_out(7);
  G1_LED <= not i_out(6);
  G2_LED <= not i_out(5);
  SP_LED <= not i_out(4);
  PC_LED <= not i_out(3);
  MM_LED <= not i_out(2);
  SPK_OUT <= i_out(1);
  SIO_TXD <= i_out(0);
  i_out(43 downto 1) <= i_out_tac(43 downto 1) when (i_mode="01" and i_console_ctr='0') else i_out_tec(43 downto 1);
  i_out(0) <= i_out_tac(0) when (i_mode="01") else i_out_tec(0);

  TEC1     : TEC
    port map(
         P_RESET    => i_reset_tec,                         -- CLK ���L��
         P_MODE     => i_mode,                              -- 1-2:TeC 3:TaC
         P_CLK      => i_2_4576MHz,                         -- 2.4576MHz
            
         -- CONSOLE(INPUT)
         P_DATA_SW  => i_in_tec(19 downto 12),              -- DATA  SW
         P_RESET_SW => i_in_tec(11),                        -- RESET SW
         P_SETA_SW  => i_in_tec(10),                        -- SETA  SW
         P_INCA_SW  => i_in_tec(9),                         -- INCA  SW
         P_DECA_SW  => i_in_tec(8),                         -- DECA  SW
         P_WRITE_SW => i_in_tec(7),                         -- WRITE SW
         P_STEP_SW  => i_in_tec(6),                         -- STEP  SW
         P_BREAK_SW => i_in_tec(5),                         -- BREAK SW
         P_STOP_SW  => i_in_tec(4),                         -- STOP  SW
         P_RUN_SW   => i_in_tec(3),                         -- RUN   SW
         P_RCW_SW   => i_in_tec(2),                         -- Rotate SW(CW)
         P_RCCW_SW  => i_in_tec(1),                         -- Rotate SW(CCW)

         -- CONSOLE(OUTPUT)
         P_A_LED    => i_out_tec(27 downto 20),             -- Address LED
         P_D_LED    => i_out_tec(19 downto 12),             -- Data LED
         P_R_LED    => i_out_tec(11),                       -- RUN   LED
         P_C_LED    => i_out_tec(10),                       -- Carry LED
         P_S_LED    => i_out_tec(9),                        -- Sing  LED
         P_Z_LED    => i_out_tec(8),                        -- Zero  LED
         P_G0_LED   => i_out_tec(7),                        -- G0    LED
         P_G1_LED   => i_out_tec(6),                        -- G1    LED
         P_G2_LED   => i_out_tec(5),                        -- G2    LED
         P_SP_LED   => i_out_tec(4),                        -- SP    LED
         P_PC_LED   => i_out_tec(3),                        -- PC    LED
         P_MM_LED   => i_out_tec(2),                        -- MM    LED
         P_BUZ      => i_out_tec(1),                        -- BUZZER OUT

         -- SIO
         P_SIO_RXD  => i_in_tec(0),                         -- SIO Receive
         P_SIO_TXD  => i_out_tec(0),                        -- SIO Transmit

         -- PIO
         P_EXT_IN   => i_in_tec(27 downto 20),
         P_ADC_REF  => i_out_tec(43 downto 36),
         P_EXT_OUT  => i_out_tec(35 downto 28)
    );

  TAC1 : TAC
    port map (
         P_CLK0     => i_49_1520MHz0,                       -- 49.152MHz 0'
         P_CLK90    => i_49_1520MHz90,                      -- 49.152MHz 90'
         P_MODE     => i_mode,                              -- 0-2:TeC 3:TaC
         P_RESET    => i_reset_tac,

         -- CONSOLE(INPUT)
         P_DATA_SW  => i_in_tac(19 downto 12),          -- Data  SW
         P_RESET_SW => i_in_tac(11),                    -- RESET SW
         P_SETA_SW  => i_in_tac(10),                    -- SETA  SW
         P_INCA_SW  => i_in_tac(9),                     -- INCA  SW
         P_DECA_SW  => i_in_tac(8),                     -- DECA  SW
         P_WRITE_SW => i_in_tac(7),                     -- WRITE SW
         P_STEP_SW  => i_in_tac(6),                     -- STEP  SW
         P_BREAK_SW => i_in_tac(5),                     -- BREAK SW
         P_STOP_SW  => i_in_tac(4),                     -- STOP  SW
         P_RUN_SW   => i_in_tac(3),                     -- RUN   SW
         P_RCW_SW   => i_in_tac(2),                     -- Rotate SW(CW)
         P_RCCW_SW  => i_in_tac(1),                     -- Rotate SW(CCW)

         -- CONSOLE(OUTPUT)
         P_A_LED    => i_out_tac(27 downto 20),         -- Address LED
         P_D_LED    => i_out_tac(19 downto 12),         -- Data LED
         P_R_LED    => i_out_tac(11),                   -- RUN   LED
         P_C_LED    => i_out_tac(10),                   -- Carry LED
         P_S_LED    => i_out_tac(9),                    -- Sing  LED
         P_Z_LED    => i_out_tac(8),                    -- Zero  LED
         P_G0_LED   => i_out_tac(7),                    -- G0    LED
         P_G1_LED   => i_out_tac(6),                    -- G1    LED
         P_G2_LED   => i_out_tac(5),                    -- G2    LED
         P_SP_LED   => i_out_tac(4),                    -- SP    LED
         P_PC_LED   => i_out_tac(3),                    -- PC    LED
         P_MM_LED   => i_out_tac(2),                    -- MM    LED
         P_BUZ      => i_out_tac(1),                    -- BUZZER OUT

         -- SIO
         P_SIO_RXD  => i_in_tac(0),                     -- SIO Receive
         P_SIO_TXD  => i_out_tac(0),                    -- SIO Transmit

         P_SIO_RXD2  => i_in_tac_sio,                   -- SIO Receive2
         P_SIO_TXD2  => i_out_tac_sio,                  -- SIO Transmit2

         -- COM
         P_COM_CTR      => i_com_ctr,
         P_CONSOLE_CTR  => i_console_ctr,
         P_SERIAL_CTR   => i_serial_ctr,
         P_COM_LINE     => i_com_line,

         -- I/O
         P_EXT_IN   => i_in_tac(27 downto 20),
         P_ADC_REF  => i_out_tac(43 downto 36),
         P_EXT_OUT  => i_out_tac(35 downto 28),

         -- uSD
         P_SPI_SCLK => SPI_SCLK,
         P_SPI_DIN  => SPI_DIN,
         P_SPI_DOUT => SPI_DOUT,
         P_SPI_CS   => SPI_CS,
         P_ACC_LED  => ACC_LED

    );

  end Behavioral;
