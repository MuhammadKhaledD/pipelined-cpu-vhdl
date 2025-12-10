LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        HWInt : IN STD_LOGIC;
        inPort : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE struct OF CPU IS
    -- Signal and component declarations

begin
    -- CPU architecture implementation goes here

END ARCHITECTURE;