LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Fetch_Stage  IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        swInt : IN STD_LOGIC;
        inPort : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE struct OF Fetch_Stage IS
BEGIN

End ARCHITECTURE;