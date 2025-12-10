library ieee;
use ieee.std_logic_1164.all;

entity CCR_Register is
    port(
        clk, rst          : in std_logic := '0';
        enable            : in std_logic := '0';
        Z_in, N_in, C_in  : in std_logic := '0';
        preserve          : in std_logic := '0';  -- For interrupt (preserve current flags)
        restore           : in std_logic := '0';  -- For RTI (restore saved flags)
        Z_out, N_out, C_out : out std_logic := '0';  -- Output flags
        CCR_out           : out std_logic_vector(2 downto 0) := "000";  -- Full CCR output
    );
end CCR_Register;

architecture Behavioral of CCR_Register is
    signal CCR : std_logic_vector(3 downto 0) := "000";  -- CCR<3:0>
    signal  saved_flags       :  std_logic_vector(2 downto 0) := "000";  -- Saved flags for restore

    
begin
    process(clk, rst)
    begin
        if rst = '1' then
            CCR <= "000";
        elsif rising_edge(clk) then
            if restore = '1' then
                -- Restore flags from saved state (RTI instruction)
                CCR(2 downto 0) <= saved_flags;
            elsif preserve = '1' then
                -- Keep current flags (for interrupt)
                saved_flags <= CCR;
            elsif enable = '1' then
                -- Update flags normally
                CCR(0) <= Z_in;  -- Zero flag
                CCR(1) <= N_in;  -- Negative flag
                CCR(2) <= C_in;  -- Carry flag
            end if;
        end if;
    end process;

    Z_out <= CCR(0);
    N_out <= CCR(1);
    C_out <= CCR(2);
    CCR_out <= CCR;    
end Behavioral;
