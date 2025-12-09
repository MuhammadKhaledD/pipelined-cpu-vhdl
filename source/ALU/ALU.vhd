library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        SrcA       : in  std_logic_vector(31 downto 0);
        SrcB    : in  std_logic_vector(31 downto 0);
        ALU_OPctrl : in  std_logic_vector(3 downto 0);
        RSTZF   : in  std_logic;
        RSTCF   : in  std_logic;
        RSTNF   : in  std_logic;
        AluOut  : out std_logic_vector(31 downto 0);
        ZF    : out std_logic;
        CF    : out std_logic;
        NF    : out std_logic;
        FEN  : out std_logic
        
    );
end entity ALU;

architecture ALU_arch of ALU is
    signal A, B       : signed(31 downto 0);
    signal result     : signed(31 downto 0);
    signal carry_flag : std_logic;
    signal flagsen     : std_logic;
     -- ALU opcodes (4)
   constant ALU_NOP       : std_logic_vector(3 downto 0) := "0000";
   constant ALU_ADD       : std_logic_vector(3 downto 0) := "0001";
   constant ALU_SUB       : std_logic_vector(3 downto 0) := "0010";
   constant ALU_AND       : std_logic_vector(3 downto 0) := "0011";
   constant ALU_NOT       : std_logic_vector(3 downto 0) := "0100";
   constant ALU_INC       : std_logic_vector(3 downto 0) := "0101";
   constant ALU_R1        : std_logic_vector(3 downto 0) := "1001";
   constant ALU_R2        : std_logic_vector(3 downto 0) := "1010";
   constant ALU_ADD_PLUS2 : std_logic_vector(3 downto 0) := "1110";
   constant ALU_SET_C     : std_logic_vector(3 downto 0) := "1101";
begin

    A <= signed(SrcA);
    B <= signed(SrcB);

    process(A, B, ALU_OPctrl)
        variable tmp : signed(32 downto 0); -- 33-bit for detecting carry/borrow
    begin

        -- Defaults
        result     <= (others => '0');
        carry_flag <= '0';
        flagsen     <= '0';

        case ALU_OPctrl is

            when ALU_NOP =>
                AluOut <= (others => '0');
                ZF <= '0';
                NF <= '0';
                CF <= '0';
                FEN <= '0';
                return;


            when ALU_ADD =>
                tmp := resize(A, 33) + resize(B, 33);
                result <= tmp(31 downto 0);
                carry_flag <= tmp(32);
                flagsen <= '1';

            when ALU_SUB =>
                tmp := resize(A, 33) - resize(B, 33);
                result <= tmp(31 downto 0);
                carry_flag <= not tmp(32);  -- CF = NOT borrow
                flagsen <= '1';
  
            when ALU_AND =>
                result <= A and B;
                flagsen <= '1';

   
            when ALU_NOT =>
                result <= not A;
                flagsen <= '1';

            when ALU_INC =>
                tmp := resize(A, 33) + 1;
                result <= tmp(31 downto 0);
                carry_flag <= tmp(32);
                flagsen <= '1';

            when ALU_R1 =>
                result <= A;
                flagsen <= '0';
         
            when ALU_R2 =>
                result <= B;
                flagsen <= '0';
            
            when ALU_ADD_PLUS2 =>
                tmp := resize(B, 33) + 2;
                result <= tmp(31 downto 0);
                carry_flag <= tmp(32);

            when ALU_SET_C =>
                result <= (others => '0');        
                carry_flag <= '1'; 

            when others =>
                result <= (others => '0');
        end case;


        if result = 0 then
            ZF <= '1';
        else
            ZF <= '0';
        end if;

        NF <= result(31);

        CF <= carry_flag;

        AluOut <= std_logic_vector(result);
        FEN <= flagsen;

    end process;

    ZF <= '0' when RSTZF = '1' else ZF;
    CF <= '0' when RSTCF = '1' else CF;
    NF <= '0' when RSTNF = '1' else NF;

end architecture;
