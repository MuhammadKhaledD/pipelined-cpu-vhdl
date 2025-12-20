library ieee;
use ieee.std_logic_1164.all;

entity MEM_WB_Register is
    port(
        clk, rst        : in std_logic := '0';
        enable          : in std_logic := '1';
        flush           : in std_logic := '0';
        
        ExOutM          : in std_logic_vector(31 downto 0) := x"0000_0000"; -- ALU Result (for R-type/Immediate)
        MemOutM    : in std_logic_vector(31 downto 0) := x"0000_0000"; -- Data Read from Data Memory (for Load)
        ImmM            : in std_logic_vector(31 downto 0) := x"0000_0000"; -- Immediate Value (for LDI)
        RdstM           : in std_logic_vector(2 downto 0) := "000"; -- Destination Register Address
        RegWriteEnM     : in std_logic := '0'; -- Register Write Enable
        WbSelM          : in std_logic := '0'; -- Write-Back Selector


        ExOutW          : out std_logic_vector(31 downto 0) := x"0000_0000";
        MemOutW    : out std_logic_vector(31 downto 0) := x"0000_0000";
        ImmW            : out std_logic_vector(31 downto 0) := x"0000_0000";
        RdstW           : out std_logic_vector(2 downto 0) := "000";
        RegWriteEnW     : out std_logic := '0';
        WbSelW          : out std_logic := '0'
    );
end MEM_WB_Register;

architecture Behavioral of MEM_WB_Register is
    -- Constants for clearing fields on reset/flush (inserting a NOP bubble)
    constant NOP_DATA : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    constant REG_ADDR_NOP : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset: Clear all control signals and data paths to push a NOP
            RegWriteEnW <= '0'; WbSelW <= '0';
            
            ExOutW <= NOP_DATA; MemOutW <= NOP_DATA;
            ImmW <= NOP_DATA;
            RdstW <= REG_ADDR_NOP;

        elsif falling_edge(clk) then
            if flush = '1' then
                -- Flush: Clear RegWrite and all signals that affect control flow or register write
                RegWriteEnW <= '0'; WbSelW <= '0';

                ExOutW <= NOP_DATA; MemOutW <= NOP_DATA;
                ImmW <= NOP_DATA;
                RdstW <= REG_ADDR_NOP;

            elsif enable = '1' then
                -- Normal Operation: Pass all signals from MEM to WB
                RegWriteEnW <= RegWriteEnM; WbSelW <= WbSelM;

                ExOutW <= ExOutM; MemOutW <= MemOutM;
                ImmW <= ImmM;
                RdstW <= RdstM;
            -- else (enable = '0'): Hold current values (Stall)
            end if;
        end if;
    end process;
end Behavioral;
