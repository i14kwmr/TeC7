--
-- TeC7 VHDL Source Code
--    Tokuyama kousen Educational Computer Ver.7
--
-- Copyright (C) 2012-2018 by
--                      Dept. of Computer Science and Electronic Engineering,
--                      Tokuyama College of Technology, JAPAN
--
--   ��L���쌠�҂́CFree Software Foundation �ɂ���Č��J����Ă��� GNU ��ʌ�
-- �O���p�����_�񏑃o�[�W�����Q�ɋL�q����Ă�������𖞂����ꍇ�Ɍ���C�{�\�[�X
-- �R�[�h(�{�\�[�X�R�[�h�����ς������̂��܂ށD�ȉ����l)���g�p�E�����E���ρE�Ĕz
-- �z���邱�Ƃ𖳏��ŋ�������D
--
--   �{�\�[�X�R�[�h�́��S���̖��ۏ؁��Œ񋟂������̂ł���B��L���쌠�҂����
-- �֘A�@�ցE�l�͖{�\�[�X�R�[�h�Ɋւ��āC���̓K�p�\������߂āC�����Ȃ�ۏ�
-- ���s��Ȃ��D�܂��C�{�\�[�X�R�[�h�̗��p�ɂ�蒼�ړI�܂��͊ԐړI�ɐ�����������
-- �鑹�Q�Ɋւ��Ă��C���̐ӔC�𕉂�Ȃ��D
--
--

--
-- TaC/tac_pio.vhd : TaC PIO
--
-- 2018.12.09           : PIO�̏o�͂��ő� 12 �r�b�g��
-- 2012.01.10           : �V�K�쐬
--
-- $Id
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity TAC_PIO is
    Port ( P_CLK : in  std_logic;
           P_RESET : in  std_logic;
           P_EN : in  std_logic;
           P_IOR : in  std_logic;
           P_IOW : in  std_logic;
           P_INT : out  std_logic;
           P_ADDR : in  std_logic_vector (1 downto 0);
           P_DIN : in  std_logic_vector (7 downto 0);
           P_DOUT : out  std_logic_vector (7 downto 0);

           P_ADC_REF  : out  std_logic_vector(7 downto 0);
           P_EXT_IN   : in   std_logic_vector(7 downto 0);
           P_EXT_OUT  : out  std_logic_vector(11 downto 0);
           P_EXT_MODE : out  std_logic;
           P_MODE     : in   std_logic_vector(1 downto 0)
         );
end TAC_PIO;

architecture Behavioral of TAC_PIO is
  signal i_ext_out  : std_logic_vector(11 downto 0);
  signal i_ext_mode : std_logic;
  signal i_adc  : std_logic_vector(7 downto 0);

begin
  process(P_RESET, P_CLK)
    begin
      if (P_RESET='0') then
        i_ext_out <= "000000000000";
        i_adc <= "00000000";
      elsif (P_CLK'event and P_CLK='1') then
        if (P_EN='1' and P_IOW='1') then
          if (P_ADDR(1)='0') then
            if (P_ADDR(0)='0') then
              i_ext_out(7 downto 0) <= P_DIN;
            else
              i_adc <= P_DIN;
            end if;
          else
            i_ext_mode <= P_DIN(7);
            i_ext_out(11 downto 8) <= P_DIN(3 downto 0);
          end if;
        end if;
      end if;
    end process;
      
  P_DOUT <= P_EXT_IN when (P_ADDR(0)='0') else "000000" & P_MODE;
  P_ADC_REF <= i_adc;
  P_EXT_OUT <= i_ext_out;
  P_EXT_MODE <= i_ext_mode;
  P_INT <= '0';
end Behavioral;

