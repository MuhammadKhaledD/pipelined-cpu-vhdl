library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegFile is
    port(
        clk, rst      : in std_logic := '0';
        RegWriteEn    : in std_logic := '0';                  
        wa            : in std_logic_vector(2 downto 0) := "000"; 
        w_data        : in std_logic_vector(31 downto 0) := x"0000_0000";
        ra_1, ra_2    : in std_logic_vector(2 downto 0) := "000"; 
        r_data1, r_data2 : out std_logic_vector(31 downto 0) := x"0000_0000"
    );
end RegFile;

architecture Behavioral of RegFile is
    type reg_array_t is array (0 to 7) of std_logic_vector(31 downto 0);
    signal registers : reg_array_t := (others => (others => '0'));
begin
    -- Write process: triggered on rising edge (first half of clock)
    write_proc: process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if RegWriteEn = '1' then
                registers(to_integer(unsigned(wa))) <= w_data;
            end if;
        end if;
    end process;
    
    -- Read process: triggered on falling edge (second half of clock)
    read_proc: process(clk, rst)
    begin
        if rst = '1' then
            r_data1 <= x"0000_0000";
            r_data2 <= x"0000_0000";
        elsif falling_edge(clk) then
            r_data1 <= registers(to_integer(unsigned(ra_1)));
            r_data2 <= registers(to_integer(unsigned(ra_2)));
        end if;
    end process;
    
end Behavioral;