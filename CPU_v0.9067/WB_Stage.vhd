LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY WB_Stage IS
    PORT (
        WBSelWB      : IN STD_LOGIC := '0';
        
        MemOutWB     : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := x"0000_0000"; 
        EXOutWB      : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := x"0000_0000"; 
        RegDataWB    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := x"0000_0000"
    );
END ENTITY;

ARCHITECTURE Behavioral OF WB_Stage IS
BEGIN
    WITH WBSelWB SELECT
        RegDataWB <= EXOutWB   WHEN '0',
                     MemOutWB  WHEN '1',
                     x"0000_0000" WHEN OTHERS;
                     
END ARCHITECTURE;