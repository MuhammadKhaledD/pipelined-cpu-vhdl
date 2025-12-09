library ieee;
use ieee.std_logic_1164.all;


entity ForwardUnit is
    port (
        rs1         : in  std_logic_vector(2 downto 0);
        rs2         : in  std_logic_vector(2 downto 0);
        rd_MEM      : in  std_logic_vector(2 downto 0);
        rd_WB       : in  std_logic_vector(2 downto 0);
        regWrite_MEM: in  std_logic;
        regWrite_WB : in  std_logic;
        forwardA    : out std_logic_vector(1 downto 0);
        forwardB    : out std_logic_vector(1 downto 0)
    );
end entity ForwardUnit;

