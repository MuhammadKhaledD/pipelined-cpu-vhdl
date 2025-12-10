LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY WB_Stage IS
    PORT (
        clk          : IN STD_LOGIC;
        rst          : IN STD_LOGIC;

        WBSelWB      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        MemOutWB     : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        EXOutWB      : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        ImmWB        : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 

        RegDataWB    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE Behavioral OF WB_Stage IS

BEGIN
    
    WITH WBSelWB SELECT
        RegDataWB <= EXOutWB   WHEN "00",
                     ImmWB     WHEN "01",
                     MemOutWB  WHEN "10",
                     EXOutWB   WHEN OTHERS;

END ARCHITECTURE;
