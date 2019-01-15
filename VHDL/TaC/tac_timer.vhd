--
-- TeC7 VHDL Source Code
--    Tokuyama kousen Educational Computer Ver.7
--
-- Copyright (C) 2012 - 2018 by
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
-- TaC/tac_timer.vhd : TaC TIMER
--
-- 2018.12.31 : CPU ����~���̓^�C�}�[����~����悤�ɕύX
-- 2016.01.08 : TMR_ENA �����������o�O�����
-- 2012.03.02 : �V�K�쐬
--
-- $Id
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity TAC_TIMER is
    Port ( P_CLK     : in  std_logic;
           P_RESET   : in  std_logic;
           P_EN      : in  std_logic;
           P_IOR     : in  std_logic;
           P_IOW     : in  std_logic;
           P_INT     : out std_logic;
           P_ADDR    : in  std_logic;
           P_1kHz    : in  std_logic;              -- 1kHz pulse
           P_DIN     : in  std_logic_vector (15 downto 0);
           P_DOUT    : out std_logic_vector (15 downto 0);
           P_STOP    : in  std_logic
         );
end TAC_TIMER;

architecture Behavioral of TAC_TIMER is
signal TMR_Cnt    : std_logic_vector(15 downto 0);  -- �^�C�}�[�̃J�E���^
signal TMR_Max    : std_logic_vector(15 downto 0);  -- �^�C�}�[�̎���
signal TMR_Ena  : std_logic;                     -- �^�C�}�[�̃X�^�[�g/�X�g�b�v
signal TMR_Int    : std_logic;                     -- �^�C�}�[�����ݔ�����
signal TMR_Int_Ena: std_logic;                     -- �^�C�}�[�����݋���
signal I_TMR_Mat  : std_logic;                     -- Max �� Cnt ����v����
signal I_INT_TMR_P: std_logic;                     -- �����ݔ������Ƀp���X�𔭐�

begin
  I_TMR_Mat <= '1' when (TMR_CNT=TMR_Max) else '0';  -- �J�E���^ = �ړI�̒l
  I_INT_TMR_P <= P_1kHz and I_TMR_Mat;               -- �����ݔ����p���X
  P_INT <= I_INT_TMR_P and TMR_Int_Ena;
  P_DOUT <= TMR_CNT when (P_ADDR='0') else
            TMR_Int & "000000000000000";
            
  process (P_CLK, P_RESET)
  begin
    if (P_RESET='0') then
      TMR_CNT <= "0000000000000000";
      TMR_Max <= "0000000000000001";
      TMR_Ena <= '0';
      TMR_Int <= '0';
      TMR_Int_Ena <= '0';
    elsif (P_CLK'event and P_CLK='1') then
      -- ����,�X�^�[�g�X�g�b�v,�X�^�[�g�X�g�b�v
      if (P_EN='1' and P_IOW='1') then
        if (P_ADDR='0') then
          TMR_Max <= P_DIN;               -- ������ύX
          TMR_Ena <= '0';                 -- �ύX���Ɏ����I�Ɏ~�܂�
        else
          TMR_Ena <= P_DIN(0);            -- �X�^�[�g�X�g�b�v
          TMR_Int_Ena <= P_DIN(15);       -- �����݋���
        end if;
      end if;

      -- 
      if (I_INT_TMR_P='1') then
        TMR_Int <= '1';
      elsif (P_EN='1' and P_IOR='1') then
        TMR_Int <= '0';
      end if;

      -- �^�C�}�[�̃J�E���^����
      if ((P_EN='1' and P_IOW='1' and
           P_ADDR='1') or I_INT_TMR_P='1') then
        TMR_CNT <= "0000000000000000";  -- Start/Stop�A�R���y�A�}�b�`�Ń��Z�b�g
      elsif (P_1kHz='1' and TMR_Ena='1' and P_STOP='0') then
        TMR_CNT <= TMR_CNT + 1;         -- ����ȊO�ł̓J�E���g�A�b�v
      end if;
    end if;
  end process;
end Behavioral;

