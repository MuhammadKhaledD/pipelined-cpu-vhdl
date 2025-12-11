library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Hazard_Unit is
    Port (
        POPM : in std_logic;
        PUSM : in std_logic;
        Mem : in std_logic;
        CU_IsIMM : in std_logic;
        RTIM : in std_logic;
        Branch : in std_logic;
        RETM : in std_logic;
        CALLM : in std_logic;
        INT1D : in std_logic;
        INT1M : in std_logic;
        INT2M : in std_logic;
        ID_EX_LoadUse : in std_logic;
        IF_ID_Rs1 : in std_logic_vector(2 downto 0);
        IF_ID_Rs2 : in std_logic_vector(2 downto 0);
        ID_EX_Rd : in std_logic_vector(2 downto 0);
        PC_enable : out std_logic;
        IF_ID_stall : out std_logic;
        IF_ID_flush : out std_logic;
        ID_EX_stall : out std_logic;
        ID_EX_flush : out std_logic;
        EX_MEM_flush : out std_logic;
        MEM_WB_flush : out std_logic;
        NOP_ctrl : out std_logic
    );
end Hazard_Unit;

architecture Behavioral of Hazard_Unit is
begin
    process(POPM, PUSM, Mem, CU_IsIMM, RTIM, Branch, RETM, CALLM, INT1D, INT1M, INT2M, ID_EX_LoadUse, IF_ID_Rs1, IF_ID_Rs2, ID_EX_Rd)
    begin
        -- Default outputs
        PC_enable <= '0';
        IF_ID_stall <= '0';
        IF_ID_flush <= '0';
        ID_EX_stall <= '0';
        ID_EX_flush <= '0';
        EX_MEM_flush <= '0';
        MEM_WB_flush <= '0';
        

        -- Load-Use Hazard Detection
        if ID_EX_LoadUse = '1' and ID_EX_Rd /= "000" then
            if (ID_EX_Rd = IF_ID_Rs1) or (ID_EX_Rd = IF_ID_Rs2)  then
                PC_enable <= '0';
                IF_ID_stall <= '1';
                ID_EX_flush <= '1';
            end if;
        end if;

        -- Control Hazards for Branches and Jumps
        if (Branch = '1') or (RETM = '1') or (CALLM = '1') then
            IF_ID_flush <= '1';
            EX_MEM_flush <= '1';
        end if;

        -- Interrupt Handling
        if (INT1D = '1') or (INT1M = '1') or (INT2M = '1') then
            PC_enable <= '1';
            IF_ID_flush <= '1';
            ID_EX_flush <= '1';
            EX_MEM_flush <= '1';
            MEM_WB_flush <= '1';
        end if;
    end process;


end Behavioral;