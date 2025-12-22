    library ieee;
    use ieee.std_logic_1164.all;


    entity PC_Register is
        port (
            clk       : in  std_logic;
            en     : in  std_logic;
            PC_src     : in  std_logic_vector(31 downto 0);
            PC_out    : out std_logic_vector(31 downto 0)
        );
    end entity PC_Register;

    architecture PC_Register_arch of PC_Register is
    begin
        process(clk)
        begin
            if falling_edge(clk) then
                if en = '1' then
                    PC_out <= PC_src;
                end if;
            end if;
        end process;
    end architecture PC_Register_arch;