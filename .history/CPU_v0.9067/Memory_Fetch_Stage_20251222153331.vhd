LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Memory_Fetch_Stages IS
    PORT (
        clk : IN STD_LOGIC;
	    reset : IN STD_LOGIC;

        Branch  : IN STD_LOGIC;
        SwapCtrl : IN STD_LOGIC;
        HLT    : IN STD_LOGIC;

        RETM  : IN STD_LOGIC;
        POPM  : IN STD_LOGIC;
        RTIM  : IN STD_LOGIC;
        PUSHM : IN STD_LOGIC;
        INT1M : IN STD_LOGIC;
        INT2M : IN STD_LOGIC;
        hwint1M : IN STD_LOGIC;
        hwint2M : IN STD_LOGIC;
        CALLM : IN STD_LOGIC;

        MemM        : IN STD_LOGIC;
        MemSelM     : IN STD_LOGIC;
        RegWriteENM : IN STD_LOGIC;

        PC1M        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        OutEnM      : IN STD_LOGIC;
        ExOutM      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD2M        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RdstM       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        PSPM        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemDataM    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ResetData   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ImmE        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_enableH  : IN STD_LOGIC;

        RegWriteEnWM : OUT STD_LOGIC;
        EXOutWM      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RdstWM       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        outPort      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        MemAddr           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemWriteData      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        PC1f : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE struct OF Memory_Fetch_Stages IS

    SIGNAL AddressM   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WriteDataM : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL S0M : STD_LOGIC;
    SIGNAL S1M : STD_LOGIC;
    SIGNAL S2M : STD_LOGIC;

    SIGNAL S0F : STD_LOGIC;
    SIGNAL S1F : STD_LOGIC;
    SIGNAL PCen : STD_LOGIC;

    signal PC_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PC_src_s  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PC_out_s : STD_LOGIC_VECTOR(31 DOWNTO 0);

    component PC_Register is
        port (
            clk       : in  std_logic;
            en     : in  std_logic;
            PC_src     : in  std_logic_vector(31 downto 0);
            PC_out    : out std_logic_vector(31 downto 0)
        );
    end component;

BEGIN

    -- outPort assignment
    outPort <= ExOutM when OutEnM = '1';
    -------------------------------------------------
    -- Address MUX
    -------------------------------------------------
    ----
    -- fetch stage
    ------------------------------
    S0F <= Branch OR reset ;
    S1F <= INT2M OR reset or hwint2M  or RTIM OR RETM;
    PCen <= not SwapCtrl and not HLT and PC_enableH;


    PC_src_s <= PC_addr when (S1F='0' and S0F='0') else
                ImmE when (S1F='0' and S0F='1') else
                MemDataM when (S1F='1' and S0F='0') else
                ResetData when (S1F='1' and S0F='1') else
                (others => '0');

    PCport : entity work.PC_Register
        port map (
            clk    => clk,
            en     => PCen,
            PC_src => PC_src_s,
            PC_out => PC_out_s
        );

    PC_addr <= std_logic_vector(unsigned(PC_out_s) + 1);
    PC1f <= std_logic_vector(unsigned(PC_out_s) + 2);


    -------------------------------------------------
    -- memory stage
    
    S0M <= (MemM OR INT2M or hwint2M) OR (POPM OR RTIM OR RETM);
    S1M <= (PUSHM OR CALLM  or hwint1M  OR INT1M) OR (POPM OR RTIM OR RETM);
    S2M <= reset;

    AddressM <= PC_out_s                         when (S2M='0' and S1M='0' and S0M='0') else   -- 0
                ExOutM                           when (S2M='0' and S1M='0' and S0M='1') else   -- 1
                PSPM                             when (S2M='0' and S1M='1' and S0M='0') else   -- 2
                SP                               when (S2M='0' and S1M='1' and S0M='1') else   -- 3
                (others => '0')                  when (S2M='1' and S1M='0' and S0M='0') else
                (others => '0');                                        -- 4 ? small mux = 1

    -- -------------------------------------------------
    -- -- Write Data MUX
    -- -------------------------------------------------
    	WriteDataM <= RD2M WHEN MemSelM = '0' ELSE
         	      PC1M WHEN hwint1='0' ELSE
                  std_logic_vector(unsigned(PC1M) - 1);
    -------------------------------------------------


    	MemAddr <= AddressM;
    	MemWriteData <= WriteDataM;
    -------------------------------------------------
    -- Forward to WriteBack
    -------------------------------------------------
    RdstWM <= RdstM;
    RegWriteEnWM <= RegWriteENM;
    EXOutWM <= ExOutM;

END ARCHITECTURE;

