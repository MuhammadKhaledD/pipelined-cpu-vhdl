entity Hazard_Unit is
    Port (
        POPM : in std_logic;
        PUSM : in std_logic;
        Mem : in std_logic;
        CU_IsIMM : in std_logic;
        CU_SwapE : in std_logic;
        RTIM : in std_logic;
        Branch : in std_logic;
        RETM : in std_logic;
        CALLM : in std_logic;
        INT1D : in std_logic;
        INT1M : in std_logic;
        INT2M : in std_logic;
        ID_EX_LoadUse : in
    );
end Hazard_Unit;