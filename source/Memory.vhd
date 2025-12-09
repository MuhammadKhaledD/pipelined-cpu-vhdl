library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    port (
        clk        : in  std_logic;
        WriteEnable: in  std_logic;
        Address    : in  std_logic_vector(31 downto 0);
        WriteData  : in  std_logic_vector(31 downto 0);
        ReadData   : out std_logic_vector(31 downto 0)
    );
end entity Memory;

architecture Memory_arch of Memory is
    -- Memory array: 262144 words of 32 bits (1MB memory)
    type mem_array_t is array (0 to 262143) of std_logic_vector(31 downto 0);
    signal memory : mem_array_t := (others => (others => '0'));
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Write operation on rising edge
            if WriteEnable = '1' then
                memory(to_integer(unsigned(Address(17 downto 0)))) <= WriteData;
            end if;
        elsif falling_edge(clk) then
            -- Read operation on falling edge
            ReadData <= memory(to_integer(unsigned(Address(17 downto 0))));
        end if;
    end process;
    
end architecture Memory_arch;
