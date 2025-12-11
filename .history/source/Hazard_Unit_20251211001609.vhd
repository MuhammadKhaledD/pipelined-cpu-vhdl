entity Hazard_Unit is
    Port (
        POPM : in std_logic;
        PUSM : in std_logic;
        Mem : in std_logic;
        IsIMM : in std_logic;
        RTIM : in std_logic;
        Branch : in std_logic;
        RETM : in std_logic;
        CALLM : in std_logic;
        
    );
end Hazard_Unit;