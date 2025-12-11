LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Fetch_Stage IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
	    reset,interrupt : IN STD_LOGIC;

        RETM  : IN STD_LOGIC;
        POPM  : IN STD_LOGIC;
        RTIM  : IN STD_LOGIC;
        PUSHM : IN STD_LOGIC;
        INT1M : IN STD_LOGIC;
        INT2M : IN STD_LOGIC;
        CALLM : IN STD_LOGIC;

        MemM        : IN STD_LOGIC;
        MemSelM     : IN STD_LOGIC;
        RegWriteENM : IN STD_LOGIC;

	    PC  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC1M  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        OutEnM : IN STD_LOGIC;
        ExOutM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD2M   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ImmM   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        RdstM  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        PSPM   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        RegWriteEnWM : OUT STD_LOGIC;
        EXOutWM      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ImmWM        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RdstWM       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        outPort      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        MemAddr           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemWriteData      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE struct OF Memory_Stage IS

    SIGNAL AddressM   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WriteDataM : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL S0 : STD_LOGIC;
    SIGNAL S1 : STD_LOGIC;
    SIGNAL S2 : STD_LOGIC;

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
    outPort <= ExOutM when OutEnM = '1' else (others => '0');
    -------------------------------------------------
    -- Address MUX
    -------------------------------------------------
    S0 <= MemM OR INT2M;
    S1 <= PUSHM OR CALLM OR interrupt OR INT1M;
    S2 <= POPM OR RTIM OR RETM;

    AddressM <= PC WHEN (S2 ='0' AND S1 ='0' AND S0 = '0') ELSE
		ExOutM WHEN (S2 ='0' AND S1 ='0' AND S0 = '1') ELSE
		PSPM WHEN (S2 ='0' AND S1 ='1' AND S0 = '0') ELSE
		SP WHEN (S2 ='0' AND S1 ='1' AND S0 = '1') ELSE
		(others=>'0') WHEN (reset='1' OR interrupt='0') ELSE
		(31 DOWNTO 1 => '0') & '1';
    -------------------------------------------------
    -- Write Data MUX
    -------------------------------------------------
    WriteDataM <= RD2M WHEN MemSelM='0' ELSE
                  PC1M WHEN interrupt='0' ELSE
                  std_logic_vector(unsigned(PC1M) - 1);


    MemAddr <= AddressM;
    MemWriteData <= WriteDataM;

    -------------------------------------------------
    -- Forward to WriteBack
    -------------------------------------------------
    ImmWM <= ImmM;
    RdstWM <= RdstM;
    RegWriteEnWM <= RegWriteENM;
    EXOutWM <= ExOutM;

END ARCHITECTURE;