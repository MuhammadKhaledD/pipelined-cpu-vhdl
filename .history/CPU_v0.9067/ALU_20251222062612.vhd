library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        SrcA       : in  std_logic_vector(31 downto 0);
        SrcB       : in  std_logic_vector(31 downto 0);
        ALU_OPctrl : in  std_logic_vector(3 downto 0);
        RSTZF      : in  std_logic;
        RSTCF      : in  std_logic;
        RSTNF      : in  std_logic;
        AluOut     : out std_logic_vector(31 downto 0);
        ZF         : out std_logic;
        CF         : out std_logic;
        NF         : out std_logic;
        FEN        : out std_logic
    );
end entity;

architecture ALU_arch of ALU is

    signal A, B       : signed(31 downto 0);
    

    -- internal flags
    signal zf_i, cf_i, nf_i : std_logic;
    signal flagsen         : std_logic;

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
    variable tmp        : signed(32 downto 0);
    variable res_v      : signed(31 downto 0);
    variable carry_v    : std_logic;
begin
    -- defaults
    res_v   := (others => '0');
    carry_v := '0';
    flagsen <= '0';

    case ALU_OPctrl is

        when ALU_NOP =>
                null;
        when ALU_ADD =>
            tmp := resize(A, 33) + resize(B, 33);
            res_v   := tmp(31 downto 0);
            carry_v := tmp(32);
            flagsen <= '1';

        when ALU_SUB =>
            tmp := resize(A, 33) - resize(B, 33);
            res_v   := tmp(31 downto 0);
            carry_v := not tmp(32);
           flagsen <= '1';

        when ALU_AND =>
            res_v := A and B;
            flagsen <= '1';

        when ALU_NOT =>
            res_v := not A;
            flagsen <= '1';

        when ALU_INC =>
            tmp := resize(A, 33) + 1;
            res_v   := tmp(31 downto 0);
            carry_v := tmp(32);
            flagsen <= '1';

        when ALU_R1 =>
            res_v := A;

        when ALU_R2 =>
            res_v := B;

        when ALU_ADD_PLUS2 =>
            tmp := resize(B, 33) + 2;
            res_v   := tmp(31 downto 0);
            carry_v := tmp(32);

        when ALU_SET_C =>
            res_v   := (others => '0');
            carry_v := '1';
            flagsen <= '1';

        when others =>
            null;
    end case;

    if(res_v = 0) then
        zf_i <= '1';    
    else
        zf_i <= '0';
    end if;
    nf_i <= res_v(31);
    cf_i <= carry_v;

    AluOut  <= std_logic_vector(res_v);
    FEN     <= flagsen;
end process;


    ZF <= '0' when RSTZF = '1' else zf_i;
    CF <= '0' when RSTCF = '1' else cf_i;
    NF <= '0' when RSTNF = '1' else nf_i;
    FEN <= '1' when (RSTZF = '1' or RSTCF = '1' or RSTNF = '1') else flagsen;

end architecture;