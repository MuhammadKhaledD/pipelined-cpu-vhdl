library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_Register is
    port(
        clk, rst        : in std_logic := '0';
        enable          : in std_logic := '1'; 
        flush           : in std_logic := '0'; 
        
        -- Inputs from ID stage
        IsIMMD          : in std_logic := '0';
        RETD            : in std_logic := '0';
        POPD            : in std_logic := '0';
        RTID            : in std_logic := '0';
        PUSHD           : in std_logic := '0';
        INT1D           : in std_logic := '0';
        INT2D           : in std_logic := '0';
        CALLD           : in std_logic := '0';
        MEMD            : in std_logic := '0'; -- Generic Memory Access (Load/Store)
        MemSelD         : in std_logic := '0'; -- Memory Selector
        RegWriteEnD     : in std_logic := '0';
        WbSelD          : in std_logic := '0'; -- Write-Back Selector
        SwapD           : in std_logic_vector(1 downto 0) := "00";
        MemWriteD       : in std_logic := '0';
        AluOpD          : in std_logic_vector(3 downto 0) := "0000";
        JmpZD           : in std_logic := '0';
        JmpCD           : in std_logic := '0';
        JmpND           : in std_logic := '0';
        JmpD            : in std_logic := '0';
        ExOutSelD       : in std_logic := '0';
        LoadUseD        : in std_logic := '0';
        OutEnD          : in std_logic := '0';
        PC1D            : in std_logic_vector(31 downto 0) := x"0000_0000";
        RD1_D           : in std_logic_vector(31 downto 0) := x"0000_0000";
        RD2_D           : in std_logic_vector(31 downto 0) := x"0000_0000";
        Rsrc1D          : in std_logic_vector(2 downto 0) := "000";
        Rsrc2D          : in std_logic_vector(2 downto 0) := "000";
        RdstD           : in std_logic_vector(2 downto 0) := "000";
        ImmF            : in std_logic_vector(31 downto 0) := x"0000_0000";
        hwint1D          : in std_logic := '0';
        hwintD2          : in std_logic := '0';

        -- Outputs to EX stage (Suffix '_E' for Execute)
        IsIMM_E         : out std_logic := '0';
        RET_E           : out std_logic := '0';
        POP_E           : out std_logic := '0';
        RTI_E           : out std_logic := '0';
        PUSH_E          : out std_logic := '0';
        INT1_E          : out std_logic := '0';
        INT2_E          : out std_logic := '0';
        CALL_E          : out std_logic := '0';
        MEM_E           : out std_logic := '0';
        MemSel_E        : out std_logic := '0';
        RegWriteEn_E    : out std_logic := '0';
        WbSel_E         : out std_logic := '0';
        Swap_E          : out std_logic_vector(1 downto 0) := "00";
        MemWrite_E      : out std_logic := '0';
        AluOp_E         : out std_logic_vector(3 downto 0) := "0000";
        JmpZ_E          : out std_logic := '0';
        JmpC_E          : out std_logic := '0';
        JmpN_E          : out std_logic := '0';
        Jmp_E           : out std_logic := '0';
        ExOutSel_E      : out std_logic := '0';
        LoadUse_E       : out std_logic := '0';
        OutEn_E         : out std_logic := '0';
        PC1_E           : out std_logic_vector(31 downto 0) := x"0000_0000";
        RD1_E           : out std_logic_vector(31 downto 0) := x"0000_0000";
        RD2_E           : out std_logic_vector(31 downto 0) := x"0000_0000";
        Rsrc1_E         : out std_logic_vector(2 downto 0) := "000";
        Rsrc2_E         : out std_logic_vector(2 downto 0) := "000";
        Rdst_E          : out std_logic_vector(2 downto 0) := "000";
        Imm_E           : out std_logic_vector(31 downto 0) := x"0000_0000";
        hwint1E         : out std_logic := '0'
    );
end ID_EX_Register;

architecture Behavioral of ID_EX_Register is
    constant NOP_DATA : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    -- NOP opcode for control fields on reset/flush
    constant ALU_NOP : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant SWAP_NOP : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant REG_ADDR_NOP : STD_LOGIC_VECTOR(2 downto 0) := "000";

begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset: Clear all control signals and data paths
            IsIMM_E <= '0'; RET_E <= '0'; POP_E <= '0'; RTI_E <= '0'; PUSH_E <= '0';
            INT1_E <= '0'; INT2_E <= '0'; CALL_E <= '0'; MEM_E <= '0'; MemSel_E <= '0';
            RegWriteEn_E <= '0'; WbSel_E <= '0'; Swap_E <= SWAP_NOP; MemWrite_E <= '0';
            AluOp_E <= ALU_NOP; JmpZ_E <= '0'; JmpC_E <= '0'; JmpN_E <= '0'; Jmp_E <= '0';
            ExOutSel_E <= '0'; LoadUse_E <= '0'; OutEn_E <= '0';

            PC1_E <= NOP_DATA; RD1_E <= NOP_DATA; RD2_E <= NOP_DATA;
            Imm_E <= NOP_DATA;
            Rsrc1_E <= REG_ADDR_NOP; Rsrc2_E <= REG_ADDR_NOP; Rdst_E <= REG_ADDR_NOP; hwintE <= '0';

        elsif falling_edge(clk) then
            if flush = '1' then
                -- Flush (Branch Misprediction): Insert a NOP bubble by clearing all
                -- control signals that would perform an action in later stages.
                IsIMM_E <= '0'; RET_E <= '0'; POP_E <= '0'; RTI_E <= '0'; PUSH_E <= '0';
                INT1_E <= '0'; INT2_E <= '0'; CALL_E <= '0'; MEM_E <= '0'; MemSel_E <= '0';
                RegWriteEn_E <= '0'; WbSel_E <= '0'; Swap_E <= SWAP_NOP; MemWrite_E <= '0';
                AluOp_E <= ALU_NOP; JmpZ_E <= '0'; JmpC_E <= '0'; JmpN_E <= '0'; Jmp_E <= '0';
                ExOutSel_E <= '0'; LoadUse_E <= '0'; OutEn_E <= '0';
                
                PC1_E <= NOP_DATA; RD1_E <= NOP_DATA; RD2_E <= NOP_DATA;
                Imm_E <= NOP_DATA;
                Rsrc1_E <= REG_ADDR_NOP; Rsrc2_E <= REG_ADDR_NOP; Rdst_E <= REG_ADDR_NOP;  hwintE <= '0';

            elsif enable = '1' then
                -- Normal Operation: Pass all signals from ID to EX
                IsIMM_E <= IsIMMD; RET_E <= RETD; POP_E <= POPD; RTI_E <= RTID; PUSH_E <= PUSHD;
                INT1_E <= INT1D; INT2_E <= INT2D; CALL_E <= CALLD; MEM_E <= MEMD; MemSel_E <= MemSelD;
                RegWriteEn_E <= RegWriteEnD; WbSel_E <= WbSelD; Swap_E <= SwapD; MemWrite_E <= MemWriteD;
                AluOp_E <= AluOpD; JmpZ_E <= JmpZD; JmpC_E <= JmpCD; JmpN_E <= JmpND; Jmp_E <= JmpD;
                ExOutSel_E <= ExOutSelD; LoadUse_E <= LoadUseD; OutEn_E <= OutEnD;

                PC1_E <= PC1D; RD1_E <= RD1_D; RD2_E <= RD2_D; Imm_E <= ImmF;
                Rsrc1_E <= Rsrc1D; Rsrc2_E <= Rsrc2D; Rdst_E <= RdstD; hwintE <= hwintD;
            -- else (enable = '0'): Hold current values (Stall)
            end if;
        end if;
    end process;
end Behavioral;