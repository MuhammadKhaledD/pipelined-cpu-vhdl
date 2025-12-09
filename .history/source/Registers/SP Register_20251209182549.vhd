library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SP_Register is
    port (
        clk            : in  std_logic;
        Plus           : in  std_logic;
        Minus          : in  std_logic;
        PSP            : out  std_logic_vector(31 downto 0);
        SP             : out std_logic_vector(31 downto 0)
    );
end entity SP_Register;

architecture SP_Register_arch of SP_Register is
    signal sp_internal : std_logic_vector(31 downto 0) := d"262143"; -- Initial SP value
    signal Past_SP    : std_logic_vector(31 downto 0) := d"262143";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Write on rising edge
            if Plus = '1' then
                sp_internal <= std_logic_vector(unsigned(sp_internal) + 1);
            elsif Minus = '1' then
                sp_internal <= std_logic_vector(unsigned(sp_internal) - 1);
            end if;            -- Read on falling edge
            SP <= sp_internal;
            PSP <= Past_SP;
            Past_SP <= sp_internal;
        end if;
    end process;
end architecture SP_Register_arch;
