LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Decode_Stage  IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        interrupt : IN STD_LOGIC;
        -- RegWriteENWB : IN STD_LOGIC;
        -- RegWriteWB : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- RegDataWB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- RD1     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- RD2     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSrc1D  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        RSrc2D  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); 

        SwapCtrl      : out std_logic;
        IsImm         : out std_logic;
        HLT           : out std_logic;
        RetD          : out std_logic;
        PopD          : out std_logic;
        RtiD          : out std_logic;
        PushD         : out std_logic;
        Int1D         : out std_logic;
        Int2D         : out std_logic;
        hwint1D       : out std_logic;
        hwint2D       : out std_logic;
        CallD         : out std_logic;
        MemDLoadStore : out std_logic;
        MemSelD       : out std_logic;
        RegWriteEnD   : out std_logic;
        WbSelD        : out std_logic := '0';
        SwapD         : out std_logic_vector(1 downto 0);
        MemWriteD     : out std_logic;
        AluOpD        : out std_logic_vector(3 downto 0);
        JmpZD         : out std_logic;
        JmpCD         : out std_logic;
        JmpND         : out std_logic;
        JmpD          : out std_logic;
        ExOutSelD     : out std_logic;
        LoadUseD      : out std_logic;
        OutEnD        : out std_logic
    );
END ENTITY;

ARCHITECTURE struct OF Decode_Stage IS

    component cu is
       port(
            clk    : in  std_logic;
            opcode : in  std_logic_vector(4 downto 0);
            hwint  : in  std_logic;

            SwapCtrl      : out std_logic;
            IsImm         : out std_logic;
            HLT           : out std_logic;
            RetD          : out std_logic;
            PopD          : out std_logic;
            RtiD          : out std_logic;
            PushD         : out std_logic;
            Int1D         : out std_logic;
            Int2D         : out std_logic;
            hwint1D       : out std_logic;
            hwint2D       : out std_logic;
            CallD         : out std_logic;
            MemDLoadStore : out std_logic;
            MemSelD       : out std_logic;
            RegWriteEnD   : out std_logic;
            WbSelD        : out std_logic := '0';
            SwapD         : out std_logic_vector(1 downto 0);
            MemWriteD     : out std_logic;
            AluOpD        : out std_logic_vector(3 downto 0);
            JmpZD         : out std_logic;
            JmpCD         : out std_logic;
            JmpND         : out std_logic;
            JmpD          : out std_logic;
            ExOutSelD     : out std_logic;
            NotIncSignal  : out std_logic;
            LoadUseD      : out std_logic;
            OutEnD        : out std_logic
       );
    end component;

    -- internal signals for register file addresses / data
    signal s_Rsrc1    : std_logic_vector(2 downto 0);
    signal s_Rsrc2    : std_logic_vector(2 downto 0);
    signal s_Rdst     : std_logic_vector(2 downto 0);

    -- cu outputs that are not exposed as ports (we map most CU outputs directly to entity ports)
    signal s_NotIncSignal : std_logic;

begin

    ----------------------------------------------------------------
    -- Extract register fields from instruction (ISA: OPCODE[29:25], RDST[24:22], RSRC1[21:19], RSRC2[18:16])
    ----------------------------------------------------------------
    -- drive internal small fields from instruction (combinational)
    s_Rdst  <= instruction(24 downto 22);
    s_Rsrc1 <= instruction(21 downto 19);
    s_Rsrc2 <= instruction(18 downto 16);

    -- expose source fields as entity outputs (read-anytime)
    RSrc1D <= s_Rsrc1;
    RSrc2D <= s_Rsrc2;

    ----------------------------------------------------------------
    -- RegFile instantiation
    -- Reads: ra_1, ra_2 (read-anytime)
    -- Writes: wa/w_data when RegWriteENWB='1' on positive edge inside RegFile
    ----------------------------------------------------------------
    -- RegFile_inst : entity work.RegFile
    --     port map (
    --         clk        => clk,
    --         rst        => rst,
    --         RegWriteEn => RegWriteENWB,
    --         wa         => RegWriteWB,   -- write address from WB stage (input port)
    --         w_data     => RegDataWB,    -- write data from WB stage (input port)
    --         ra_1       => s_Rsrc1,
    --         ra_2       => s_Rsrc2,
    --         r_data1    => s_RD1,
    --         r_data2    => s_RD2
    --     );

    -- -- drive the decode outputs RD1/RD2 from regfile read data
    -- RD1 <= s_RD1;
    -- RD2 <= s_RD2;

    ----------------------------------------------------------------
    -- cu instantiation
    -- Map opcode field (bits 29 downto 25) and most outputs directly to entity outputs.
    -- NotIncSignal is captured into s_NotIncSignal for use in the mux below.
    ----------------------------------------------------------------
    CU_inst : entity work.cu
        port map (
            clk    => clk,
            opcode => instruction(29 downto 25),
            hwint  => interrupt,

            SwapCtrl      => SwapCtrl,
            IsImm         => IsImm,
            HLT           => HLT,
            RetD          => RetD,
            PopD          => PopD,
            RtiD          => RtiD,
            PushD         => PushD,
            Int1D         => Int1D,
            Int2D         => Int2D,
            hwint1D       => hwint1D,
            hwint2D       => hwint2D,
            CallD         => CallD,
            MemDLoadStore => MemDLoadStore,
            MemSelD       => MemSelD,
            RegWriteEnD   => RegWriteEnD,
            WbSelD        => WbSelD,
            SwapD         => SwapD,
            MemWriteD     => MemWriteD,
            AluOpD        => AluOpD,
            JmpZD         => JmpZD,
            JmpCD         => JmpCD,
            JmpND         => JmpND,
            JmpD          => JmpD,
            ExOutSelD     => ExOutSelD,
            NotIncSignal  => s_NotIncSignal,  -- internal: used for Rdst mux
            LoadUseD      => LoadUseD,
            OutEnD        => OutEnD
        );

    ----------------------------------------------------------------
    -- Rdst selection mux (concurrent conditional assignment)
    -- If NotIncSignal = '0' -> output original RDST
    -- If NotIncSignal = '1' -> output RSRC1
    -- (This matches: "if sel = 0 rdst will out; if = 1 rsrc1 will out")
    ----------------------------------------------------------------
    Rdst <= s_Rsrc1 when s_NotIncSignal = '1' else s_Rdst;

END ARCHITECTURE;
