LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Excute_Stage  IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        RD1     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD2     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSrc1D  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        RSrc2D  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ImmE    : IN std_logic_vector(31 downto 0);
        InputPort : IN std_logic_vector(31 downto 0);
        interrupt  : IN std_logic_vector(0 downto 0);
  -- forward unit controls
        ExoutM  : IN std_logic_vector(31 downto 0);
        RegDataWB : IN std_logic_vector(31 downto 0);
        ForwardA : IN std_logic_vector(1 downto 0);
        ForwardB : IN std_logic_vector(1 downto 0);
        SwapE         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        AluOpE        : IN std_logic_vector(3 downto 0);
        JmpZDE        : IN std_logic_vector(0 downto 0);
        JmpCE         : IN std_logic_vector(0 downto 0);
        JmpNE         : IN std_logic_vector(0 downto 0);
        JmpE          : IN std_logic_vector(0 downto 0);
        IsImmE        : IN std_logic_vector(0 downto 0);
        ExOutSelE     : IN std_logic_vector(0 downto 0);

        CallE         : IN std_logic_vector(0 downto 0);
        RtiE          : IN std_logic_vector(0 downto 0);
        RetE          : IN std_logic_vector(0 downto 0);
        Int1E         : IN std_logic_vector(0 downto 0);
        PopE          : IN std_logic_vector(0 downto 0);
        PushE         : IN std_logic_vector(0 downto 0);

        Branch        : OUT std_logic_vector(0 downto 0);
        PSP           : out  std_logic_vector(31 downto 0);
        SP            : out std_logic_vector(31 downto 0);
        RdstE         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        RD2E          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ExoutE        : OUT std_logic_vector(31 downto 0)
    );
END ENTITY;

ARCHITECTURE struct OF Excute_Stage IS

    ----------------------------------------------------------------
    -- Component declarations (matching your entities)
    ----------------------------------------------------------------
    component SP_Register is
        port (
            clk   : in  std_logic;
            Plus  : in  std_logic;
            Minus : in  std_logic;
            PSP   : out std_logic_vector(31 downto 0);
            SP    : out std_logic_vector(31 downto 0)
        );
    end component;

    component ALU is
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
    end component;

    component CCR_Register is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            enable   : in  std_logic;
            Z_in     : in  std_logic;
            N_in     : in  std_logic;
            C_in     : in  std_logic;
            preserve : in  std_logic;
            restore  : in  std_logic;

            Z_out    : out std_logic;
            N_out    : out std_logic;
            C_out    : out std_logic;
            CCR_out  : out std_logic_vector(2 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- Internal signals
    ----------------------------------------------------------------
    signal s_Rsrc1   : std_logic_vector(2 downto 0);
    signal s_Rsrc2   : std_logic_vector(2 downto 0);
    signal s_Rdst    : std_logic_vector(2 downto 0);
    signal preserve_s : std_logic;
    signal sp_plus_s  : std_logic;
    signal sp_minus_s : std_logic;


    -- ALU wires
    signal alu_SrcA  : std_logic_vector(31 downto 0);
    signal alu_SrcB  : std_logic_vector(31 downto 0);
    signal alu_Out   : std_logic_vector(31 downto 0);
    signal alu_ZF    : std_logic;
    signal alu_CF    : std_logic;
    signal alu_NF    : std_logic;
    signal alu_FEN   : std_logic;

    -- CCR outputs (stable flags)
    signal ccr_Z     : std_logic;
    signal ccr_N     : std_logic;
    signal ccr_C     : std_logic;

    -- SP register wires
    signal sp_PSP    : std_logic_vector(31 downto 0);
    signal sp_SP     : std_logic_vector(31 downto 0);

    -- control helpers (scalar)
    signal sel_srcb_imm  : std_logic;
    signal sel_exout_in  : std_logic;
    signal sel_jmpz      : std_logic;
    signal sel_jmpc      : std_logic;
    signal sel_jmpn      : std_logic;
    signal sel_jmpe      : std_logic;
    signal sel_calle     : std_logic;
    signal sel_rtie      : std_logic;
    signal sel_rete      : std_logic;
    signal sel_int1e     : std_logic;
    signal sel_pope      : std_logic;
    signal sel_pushe     : std_logic;

    -- outputs to be driven
    signal s_Branch     : std_logic;
    signal s_RdstE      : std_logic_vector(2 downto 0);

    -- Intermediate signals for branch logic (ANDs) - also used as ALU resets
    signal zf_and_jz : std_logic;
    signal cf_and_jc : std_logic;
    signal nf_and_jn : std_logic;

begin

    ----------------------------------------------------------------
    -- Map input small vectors to scalar control bits for clarity
    ----------------------------------------------------------------
    sel_srcb_imm <= IsImmE(0);
    sel_exout_in <= ExOutSelE(0);

    sel_jmpz <= JmpZDE(0);
    sel_jmpc <= JmpCE(0);
    sel_jmpn <= JmpNE(0);
    sel_jmpe <= JmpE(0);

    sel_calle <= CallE(0);
    sel_rtie  <= RtiE(0);
    sel_rete  <= RetE(0);
    sel_int1e <= Int1E(0);
    sel_pope <= PopE(0);
    sel_pushe <= PushE(0);

    ----------------------------------------------------------------
    -- Register selector fields (from inputs)
    ----------------------------------------------------------------
    s_Rdst  <= Rdst;
    s_Rsrc1 <= RSrc1D;
    s_Rsrc2 <= RSrc2D;

    ----------------------------------------------------------------
    -- ALU source selection: SrcA = RD1, SrcB = (IsImm ? ImmD : RD2) , with forwarding
    ----------------------------------------------------------------
    alu_SrcA <= RD1 when ForwardA = "00" else
                ExoutM when ForwardA = "10" else
                RegDataWB when ForwardA = "01" else
                RD1;  -- default fallback
    alu_SrcB <= ImmD when sel_srcb_imm = '1' else RD2;

    alu_SrcB <= alu_SrcB when ForwardB = "00" else
                ExoutM when ForwardB = "10" else
                RegDataWB when ForwardB = "01" else
                alu_SrcB;  -- default fallback
    ----------------------------------------------------------------
    -- CCR: compute ANDs from registered flags + jump enables.
    -- These ANDs are used both for branch decision and to reset (consume) flags.
    ----------------------------------------------------------------
    zf_and_jz <= ccr_Z and sel_jmpz;
    cf_and_jc <= ccr_C and sel_jmpc;
    nf_and_jn <= ccr_N and sel_jmpn;

    preserve_s <= '1' when (sel_int1e = '1') or (interrupt(0) = '1') else '0';

    sp_plus_s  <= '1' when (sel_pope = '1') or (sel_rete = '1') or (sel_rtie = '1') else '0';

    sp_minus_s <= '1' when (sel_calle = '1') or (sel_pushe = '1') or (sel_int1e = '1') else '0';

    ----------------------------------------------------------------
    -- Instantiate ALU (direct entity instantiation)
    -- RSTZF/RSTCF/RSTNF are driven by the corresponding "consume" signals:
    -- when a conditional branch consumes the flag, that flag is forced to 0.
    ----------------------------------------------------------------
    ALU_inst : entity work.ALU
        port map (
            SrcA       => alu_SrcA,
            SrcB       => alu_SrcB,
            ALU_OPctrl => AluOpE,
            RSTZF      => zf_and_jz,   -- consume Z flag on successful JZ
            RSTCF      => cf_and_jc,   -- consume C flag on successful JC
            RSTNF      => nf_and_jn,   -- consume N flag on successful JN
            AluOut     => alu_Out,
            ZF         => alu_ZF,
            CF         => alu_CF,
            NF         => alu_NF,
            FEN        => alu_FEN
        );

    ----------------------------------------------------------------
    -- CCR: capture ALU flags when enabled (FEN). preserve/restore per Int1E/interrupt and RtiE
    -- preserve: asserted when an interrupt is requested (or Int1E) to save current flags.
    ----------------------------------------------------------------
    CCR_inst : entity work.CCR_Register
        port map (
            clk      => clk,
            rst      => rst,
            enable   => alu_FEN,                           -- update flags when ALU indicates valid
            Z_in     => alu_ZF,
            N_in     => alu_NF,
            C_in     => alu_CF,
            preserve => preserve_s,
            restore  => sel_rtie,
            Z_out    => ccr_Z,
            N_out    => ccr_N,
            C_out    => ccr_C,
            CCR_out  => open
        );

    ----------------------------------------------------------------
    -- Branch logic (concurrent)
    -- Branch <= CallE OR JmpE OR (Z_out AND JmpZDE) OR (C_out AND JmpCE) OR (N_out AND JmpNE)
    ----------------------------------------------------------------
    s_Branch <= '1' when (sel_calle = '1') or
                        (sel_jmpe = '1') or
                        (zf_and_jz = '1') or
                        (cf_and_jc = '1') or
                        (nf_and_jn = '1')
                else '0';

    Branch(0) <= s_Branch;

    ----------------------------------------------------------------
    -- ExoutE selection: 0 => ALU out ; 1 => InputPort
    ----------------------------------------------------------------
    ExoutE <= alu_Out when sel_exout_in = '0' else InputPort;

    ----------------------------------------------------------------
    -- Forward imm and rd2 to EX stage outputs (combinational forwarding)
    ----------------------------------------------------------------
    RD2E  <= RD2;

    ----------------------------------------------------------------
    -- RdstE selection (SwapE: "00" => Rdst, "01" => Rsrc1, "10" => Rsrc2)
    ----------------------------------------------------------------
    with SwapE select
        s_RdstE <= s_Rdst  when "00",
                  s_Rsrc1 when "01",
                  s_Rsrc2 when "10",
                  s_Rdst  when others;  -- fallback to Rdst

    RdstE <= s_RdstE;

    ----------------------------------------------------------------
    -- SP_Register instantiation and control signals
    -- Plus  = PopE or RetE or RtiE
    -- Minus = CallE or PushE or Int1E
    ----------------------------------------------------------------
    SP_inst : entity work.SP_Register
        port map (
            clk   => clk,
            Plus  => sp_plus_s,
            Minus => sp_minus_s,
            PSP   => sp_PSP,
            SP    => sp_SP
        );

    PSP <= sp_PSP;
    SP  <= sp_SP;

END ARCHITECTURE;
