LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Decode_Stage  IS
    PORT (
        clk : IN STD_LOGIC;
        RegWriteENWB : IN STD_LOGIC;
        RegWriteWB : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        RegDataWB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        RD1     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD2     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RSrc1D  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        RSrc2D  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        SwapCtrl      : out std_logic_vector(1-1 downto 0);
        IsImm         : out std_logic_vector(1-1 downto 0);
        HLT           : out std_logic_vector(1-1 downto 0);
        RetD          : out std_logic_vector(1-1 downto 0);
        PopD          : out std_logic_vector(1-1 downto 0);
        RtiD          : out std_logic_vector(1-1 downto 0);
        PushD         : out std_logic_vector(1-1 downto 0);
        Int1D         : out std_logic_vector(1-1 downto 0);
        Int2D         : out std_logic_vector(1-1 downto 0);
        CallD         : out std_logic_vector(1-1 downto 0);
        MemDLoadStore : out std_logic_vector(1-1 downto 0);
        MemSelD       : out std_logic_vector(1-1 downto 0);
        RegWriteEnD   : out std_logic_vector(1-1 downto 0);
        WbSelD        : out std_logic_vector(2-1 downto 0);
        SwapD         : out std_logic_vector(2-1 downto 0);
        MemWriteD     : out std_logic_vector(1-1 downto 0);
        AluOpD        : out std_logic_vector(4-1 downto 0);
        JmpZD         : out std_logic_vector(1-1 downto 0);
        JmpCD         : out std_logic_vector(1-1 downto 0);
        JmpND         : out std_logic_vector(1-1 downto 0);
        JmpD          : out std_logic_vector(1-1 downto 0);
        ExOutSelD     : out std_logic_vector(1-1 downto 0);
        LoadUseD      : out std_logic_vector(1-1 downto 0);
        OutEnD        : out std_logic_vector(1-1 downto 0)
    );
END ENTITY;

ARCHITECTURE struct OF Decode_Stage IS
BEGIN

End ARCHITECTURE;