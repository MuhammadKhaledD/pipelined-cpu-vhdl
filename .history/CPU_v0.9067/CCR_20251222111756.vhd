library ieee;
use ieee.std_logic_1164.all;

entity CCR_Register is
    port(
        clk, rst          : in std_logic := '0';
        enable            : in std_logic_vector := "000";
        Z_in, N_in, C_in  : in std_logic := '0'; -- from ALU
        preserve          : in std_logic := '0';  -- For interrupt (preserve current flags)
        restore           : in std_logic := '0';  -- For RTI (restore saved flags)
        Z_out, N_out, C_out : out std_logic := '0';  -- Output flags
        CCR_out           : out std_logic_vector(2 downto 0) := "000"  -- Full CCR output
    );
end CCR_Register;

architecture Behavioral of CCR_Register is
    signal CCR         : std_logic_vector(2 downto 0) := "000";
    signal saved_flags : std_logic_vector(2 downto 0) := "000";
begin
    process(clk, rst)
    begin   
        if rst = '1' then
            CCR         <= "000";
            saved_flags <= "000";

        elsif rising_edge(clk) then

            -- Highest priority: restore on RTI
            if restore = '1' then
                CCR <= saved_flags;

            -- Next priority: preserve flags during interrupt
            elsif preserve = '1' then
                saved_flags <= CCR;

            -- Normal update
            ife
            
            end if;

        end if;
    end process;

    Z_out    <= CCR(0);
    N_out    <= CCR(1);
    C_out    <= CCR(2);
    CCR_out  <= CCR;

end Behavioral;

