library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_Register is
    port(
        clk, rst     : in std_logic := '0';
        enable       : in std_logic := '1';  -- For stalling
        flush        : in std_logic := '0';  -- For flushing (branch misprediction)
        
        -- Inputs from IF stage
        instruction_F   : in std_logic_vector(31 downto 0) := x"0000_0000";
        pc1_F           : in std_logic_vector(31 downto 0) := x"0000_0000";
        
        -- Outputs to ID stage
        instruction_D   : out std_logic_vector(31 downto 0) := x"0000_0000";
        pc1_D           : out std_logic_vector(31 downto 0) := x"0000_0000"
    );
end IF_ID_Register;

architecture Behavioral of IF_ID_Register is

-- NOP instruction (all zeros) for flushing/resetting
constant NOP : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";


begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset: Insert NOP and clear PC
            instruction_D <= NOP;
            pc1_D <= NOP; 
        elsif falling_edge(clk) then
            if flush = '1' then
                -- Flush: Insert NOP into the pipeline register
                instruction_D <= NOP;
                pc1_D <= NOP; 
            elsif enable = '1' then
                -- Normal Operation: Pass data through
                instruction_D <= instruction_F;
                pc1_D <= pc1_F;
            -- else (enable = '0'): Hold current values (Stall)
            end if;
        end if;
    end process;
end Behavioral;
