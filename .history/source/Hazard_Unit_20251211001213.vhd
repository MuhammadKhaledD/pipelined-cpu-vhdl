entity Hazard_Unit is
    Port (
        A       : in  STD_LOGIC_VECTOR (31 downto 0);
        B       : in  STD_LOGIC_VECTOR (31 downto 0);
        EX_MEM_RegWrite : in  STD_LOGIC;
        EX_MEM_RegisterRd : in  STD_LOGIC_VECTOR (4 downto 0);
        MEM_WB_RegWrite : in  STD_LOGIC;
        MEM_WB_RegisterRd : in  STD_LOGIC_VECTOR (4 downto 0);
        ID_EX_RegisterRs : in  STD_LOGIC_VECTOR (4 downto 0);
        ID_EX_RegisterRt : in  STD_LOGIC_VECTOR (4 downto 0);
        Stall   : out STD_LOGIC
    );
end Hazard_Unit;