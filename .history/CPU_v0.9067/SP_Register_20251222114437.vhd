library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

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
    signal sp_internal : unsigned(31 downto 0)
        := to_unsigned(262143, 32);

    signal Past_SP : unsigned(31 downto 0) 
        := to_unsigned(262143, 32);
begin
    write_proc : process(clk)
    begin
        if rising_edge(clk) then
            if Plus = '1' then
                Past_SP <= sp_internal;     
                sp_internal <= sp_internal + 1;
            elsif Minus = '1' then
            
                sp_internal <= sp_internal - 1;
            end if;
        end if;
    end process;
            SP  <= std_logic_vector(sp_internal);
            PSP <= std_logic_vector(Past_SP);
end architecture SP_Register_arch;