library ieee;
use ieee.std_logic_1164.all;

entity EX_MEM_Register is
    port(
        clk, rst        : in std_logic := '0';
        enable          : in std_logic := '1';
        flush           : in std_logic := '0';
        
        ExOutE          : in std_logic_vector(31 downto 0) := x"0000_0000"; -- ALU Result / Execution Output
        RD2_E           : in std_logic_vector(31 downto 0) := x"0000_0000"; -- Data for Memory Write
        PC1_E           : in std_logic_vector(31 downto 0) := x"0000_0000"; -- PC + 1
        PSP_E           : in std_logic_vector(31 downto 0) := x"0000_0000"; -- Stack Pointer Value
        
        Rdst_E          : in std_logic_vector(2 downto 0) := "000"; -- Destination Register Address
        
        
        RETE            : in std_logic := '0';
        RTIE            : in std_logic := '0';
        CALLE           : in std_logic := '0';
        MEM_E           : in std_logic := '0';     -- Generic Memory Access (Load/Store)
        MemSel_E        : in std_logic := '0';     -- Memory Selector
        RegWriteEn_E    : in std_logic := '0';
        WbSel_E         : in std_logic := '0';     -- Write-Back Selector
        MemWrite_E      : in std_logic := '0';     -- Memory Write Enable (Store)
        OutEn_E         : in std_logic := '0';     -- Output Enable (IO)
        PUSH_E          : in std_logic := '0';     -- Stack Push Enable (NEW)
        POP_E           : in std_logic := '0';     -- Stack Pop Enable (NEW)
        INT1_E          : in std_logic := '0';     -- Interrupt 1 Enable (NEW)
        INT2_E          : in std_logic := '0';     -- Interrupt 2 Enable (NEW)

        -- Outputs to MEM stage (Suffix '_M' for Memory)
        ExOutM          : out std_logic_vector(31 downto 0) := x"0000_0000";
        RD2_M           : out std_logic_vector(31 downto 0) := x"0000_0000";
        PC1_M           : out std_logic_vector(31 downto 0) := x"0000_0000";
        PSP_M           : out std_logic_vector(31 downto 0) := x"0000_0000";
        
        Rdst_M          : out std_logic_vector(2 downto 0) := "000";
        
        RET_M           : out std_logic := '0';
        RTI_M           : out std_logic := '0';
        CALL_M          : out std_logic := '0';
        MEM_M           : out std_logic := '0';
        MemSel_M        : out std_logic := '0';
        RegWriteEn_M    : out std_logic := '0';
        WbSel_M         : out std_logic := '0';
        MemWrite_M      : out std_logic := '0';
        OutEn_M         : out std_logic := '0';
        PUSH_M          : out std_logic := '0';
        POP_M           : out std_logic := '0';
        INT1_M          : out std_logic := '0';
        INT2_M          : out std_logic := '0'
    );
end EX_MEM_Register;

architecture Behavioral of EX_MEM_Register is
    -- Constants for clearing fields on reset/flush (inserting a NOP bubble)
    constant NOP_DATA : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    constant REG_ADDR_NOP : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset: Clear all control signals and data paths to push a NOP
            RET_M <= '0'; RTI_M <= '0'; CALL_M <= '0'; MEM_M <= '0'; MemSel_M <= '0';
            RegWriteEn_M <= '0'; WbSel_M <= '0'; MemWrite_M <= '0'; OutEn_M <= '0';
            PUSH_M <= '0'; POP_M <= '0'; INT1_M <= '0'; INT2_M <= '0';
            
            ExOutM <= NOP_DATA; RD2_M <= NOP_DATA; PC1_M <= NOP_DATA; PSP_M <= NOP_DATA;
            Rdst_M <= REG_ADDR_NOP;

        elsif falling_edge(clk) then
            if flush = '1' then
                -- Flush: Clear all control signals to insert a NOP bubble
                RET_M <= '0'; RTI_M <= '0'; CALL_M <= '0'; MEM_M <= '0'; MemSel_M <= '0';
                RegWriteEn_M <= '0'; WbSel_M <= '0'; MemWrite_M <= '0'; OutEn_M <= '0';
                PUSH_M <= '0'; POP_M <= '0'; INT1_M <= '0'; INT2_M <= '0';
                
                ExOutM <= NOP_DATA; RD2_M <= NOP_DATA; PC1_M <= NOP_DATA; PSP_M <= NOP_DATA;
                Rdst_M <= REG_ADDR_NOP;

            elsif enable = '1' then
                -- Normal Operation: Pass all signals from EX to MEM
                RET_M <= RETE; RTI_M <= RTIE; CALL_M <= CALLE; MEM_M <= MEM_E; MemSel_M <= MemSel_E;
                RegWriteEn_M <= RegWriteEn_E; WbSel_M <= WbSel_E; MemWrite_M <= MemWrite_E; OutEn_M <= OutEn_E;
                PUSH_M <= PUSH_E; POP_M <= POP_E; INT1_M <= INT1_E; INT2_M <= INT2_E;

                ExOutM <= ExOutE; RD2_M <= RD2_E; PC1_M <= PC1_E; PSP_M <= PSP_E;
                Rdst_M <= Rdst_E;
            -- else (enable = '0'): Hold current values (Stall)
            end if;
        end if;
    end process;
end Behavioral;
