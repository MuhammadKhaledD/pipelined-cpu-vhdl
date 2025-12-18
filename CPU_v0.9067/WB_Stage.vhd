LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY WB_Stage IS
    PORT (
        WBSelWB      : IN STD_LOGIC;
        
        MemOutWB     : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        EXOutWB      : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 

        RegDataWB    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE Behavioral OF WB_Stage IS

BEGIN
    
    WITH WBSelWB SELECT
        RegDataWB <= EXOutWB   WHEN "0",
                     MemOutWB  WHEN "1";

END ARCHITECTURE;
