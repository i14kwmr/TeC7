--
-- TeC7 VHDL Source Code
--    Tokuyama kousen Educational Computer Ver.7
--
-- Copyright (C) 2012 by
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
-- TaC/tac_com.vhd : TaC COM
--
-- 2016.08.30           : �V�K�쐬
--
-- $Id
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity TAC_COM is
    Port ( P_CLK : in  std_logic;
           P_RESET : in  std_logic;
           P_EN : in  std_logic;
           P_IOW : in  std_logic;
           P_ADDR : in  std_logic_vector (1 downto 0);
           P_DIN : in  std_logic_vector (7 downto 0);

           P_COM_CTR : out   std_logic;
           P_CONSOLE_CTR : out  std_logic;
           P_SERIAL_CTR : out  std_logic;
           P_COM_LINE : out  std_logic_vector(18 downto 0)
         );
end TAC_COM;

architecture Behavioral of TAC_COM is
  signal i_com_1   : std_logic_vector(7 downto 0);
  signal i_com_2   : std_logic_vector(7 downto 0);
  signal i_com_3   : std_logic_vector(7 downto 0);
begin
  process(P_RESET, P_CLK)
    begin
      if (P_RESET='0') then
        i_com_1 <= "00000000";
        i_com_2 <= "00000000";
        i_com_3 <= "00000000";
      elsif (P_CLK'event and P_CLK='1') then
        if (P_EN='1' and P_IOW='1') then
          if (P_ADDR(1)='1') then
            i_com_3 <= P_DIN;
          elsif (P_ADDR(0)='1') then
            i_com_2 <= P_DIN;
          else
            i_com_1 <= P_DIN;
          end if;
        end if;
      end if;
    end process;
      
  P_COM_LINE    <= i_com_1 & i_com_2 & i_com_3(7 downto 5);
  P_COM_CTR     <= i_com_3(3);
  P_CONSOLE_CTR <= i_com_3(2);
  P_SERIAL_CTR  <= i_com_3(1);
  
end Behavioral;

