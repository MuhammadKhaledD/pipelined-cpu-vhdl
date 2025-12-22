LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU IS
    PORT (
        clk     : IN  STD_LOGIC;
        rst     : IN  STD_LOGIC;
        hwInt   : IN  STD_LOGIC;
        inPort  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);

        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY CPU;

ARCHITECTURE struct OF CPU IS

    -- ================================================================
    -- COMPONENT DECLARATIONS
    -- ================================================================

    component Memory is
        port (
            clk         : in  std_logic;
            WriteEnable : in  std_logic;
            Address     : in  std_logic_vector(31 downto 0);
            WriteData   : in  std_logic_vector(31 downto 0);

            ReadData    : out std_logic_vector(31 downto 0)
        );
    end component Memory;

    component RegFile is
        port (
            clk         : in  std_logic := '0';
            rst         : in  std_logic := '0';
            RegWriteEn  : in  std_logic := '0';
            wa          : in  std_logic_vector(2 downto 0) := "000";
            w_data      : in  std_logic_vector(31 downto 0) := x"0000_0000";
            ra_1, ra_2  : in  std_logic_vector(2 downto 0) := "000";

            r_data1, r_data2 : out std_logic_vector(31 downto 0) := x"0000_0000"
        );
    end component RegFile;

    component IF_ID_Register is
        port (
            clk, rst        : in std_logic := '0';
            enable          : in std_logic := '1';
            flush           : in std_logic := '0';
            instruction_F   : in std_logic_vector(31 downto 0) := x"0000_0000";
            pc1_F           : in std_logic_vector(31 downto 0) := x"0000_0000";

            instruction_D   : out std_logic_vector(31 downto 0) := x"0000_0000";
            pc1_D           : out std_logic_vector(31 downto 0) := x"0000_0000"
        );
    end component IF_ID_Register;

    component ID_EX_Register is
        port (
            clk, rst        : in std_logic := '0';
            enable          : in std_logic := '1';
            flush           : in std_logic := '0';
            IsIMMD          : in std_logic := '0';
            RETD            : in std_logic := '0';
            POPD            : in std_logic := '0';
            RTID            : in std_logic := '0';
            PUSHD           : in std_logic := '0';
            INT1D           : in std_logic := '0';
            INT2D           : in std_logic := '0';
            CALLD           : in std_logic := '0';
            MEMD            : in std_logic := '0';
            MemSelD         : in std_logic := '0';
            RegWriteEnD     : in std_logic := '0';
            WbSelD          : in std_logic := '0';
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
            Imm_E           : out std_logic_vector(31 downto 0) := x"0000_0000"
        );
    end component ID_EX_Register;

    component EX_MEM_Register is
        port (
            clk, rst        : in std_logic := '0';
            enable          : in std_logic := '1';
            flush           : in std_logic := '0';
            ExOutE          : in std_logic_vector(31 downto 0) := x"0000_0000";
            RD2_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            PC1_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            PSP_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            Rdst_E          : in std_logic_vector(2 downto 0) := "000";
            RETE            : in std_logic := '0';
            RTIE            : in std_logic := '0';
            CALLE           : in std_logic := '0';
            MEM_E           : in std_logic := '0';
            MemSel_E        : in std_logic := '0';
            RegWriteEn_E    : in std_logic := '0';
            WbSel_E         : in std_logic := '0';
            MemWrite_E      : in std_logic := '0';
            OutEn_E         : in std_logic := '0';
            PUSH_E          : in std_logic := '0';
            POP_E           : in std_logic := '0';
            INT1_E          : in std_logic := '0';
            INT2_E          : in std_logic := '0';

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
    end component EX_MEM_Register;

    component MEM_WB_Register is
        port (
            clk, rst        : in std_logic := '0';
            enable          : in std_logic := '1';
            flush           : in std_logic := '0';
            ExOutM          : in std_logic_vector(31 downto 0) := x"0000_0000";
            MemOutM         : in std_logic_vector(31 downto 0) := x"0000_0000";
            ImmM            : in std_logic_vector(31 downto 0) := x"0000_0000";
            RdstM           : in std_logic_vector(2 downto 0) := "000";
            RegWriteEnM     : in std_logic := '0';
            WbSelM          : in std_logic := '0';
            ExOutW          : out std_logic_vector(31 downto 0) := x"0000_0000";
            MemOutW         : out std_logic_vector(31 downto 0) := x"0000_0000";
            ImmW            : out std_logic_vector(31 downto 0) := x"0000_0000";
            RdstW           : out std_logic_vector(2 downto 0) := "000";
            RegWriteEnW     : out std_logic := '0';
            WbSelW          : out std_logic := '0'
        );
    end component MEM_WB_Register;

    component Decode_Stage is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            instruction : in std_logic_vector(31 downto 0);

            RSrc1D      : out std_logic_vector(2 downto 0);
            RSrc2D      : out std_logic_vector(2 downto 0);
            Rdst        : out std_logic_vector(2 downto 0);
            SwapCtrl    : out std_logic;
            IsImm       : out std_logic;
            HLT         : out std_logic;
            RetD        : out std_logic;
            PopD        : out std_logic;
            RtiD        : out std_logic;
            PushD       : out std_logic;
            Int1D       : out std_logic;
            Int2D       : out std_logic;
            CallD       : out std_logic;
            MemDLoadStore : out std_logic;
            MemSelD     : out std_logic;
            RegWriteEnD : out std_logic;
            WbSelD      : out std_logic;
            SwapD       : out std_logic_vector(1 downto 0);
            MemWriteD   : out std_logic;
            AluOpD      : out std_logic_vector(3 downto 0);
            JmpZD       : out std_logic;
            JmpCD       : out std_logic;
            JmpND       : out std_logic;
            JmpD        : out std_logic;
            ExOutSelD   : out std_logic;
            LoadUseD    : out std_logic;
            OutEnD      : out std_logic
        );
    end component Decode_Stage;

    component Excute_Stage is
        port (
            clk        : in std_logic;
            rst        : in std_logic;
            RD1        : in std_logic_vector(31 downto 0);
            RD2        : in std_logic_vector(31 downto 0);
            RSrc1D     : in std_logic_vector(2 downto 0);
            RSrc2D     : in std_logic_vector(2 downto 0);
            Rdst       : in std_logic_vector(2 downto 0);
            ImmE       : in std_logic_vector(31 downto 0);
            InputPort  : in std_logic_vector(31 downto 0);
            interrupt  : in std_logic;
            ExoutM     : in std_logic_vector(31 downto 0);
            RegDataWB  : in std_logic_vector(31 downto 0);
            ForwardA   : in std_logic_vector(1 downto 0);
            ForwardB   : in std_logic_vector(1 downto 0);
            SwapE      : in std_logic_vector(1 downto 0);
            AluOpE     : in std_logic_vector(3 downto 0);
            JmpZDE     : in std_logic;
            JmpCE      : in std_logic;
            JmpNE      : in std_logic;
            JmpE       : in std_logic;
            IsImmE     : in std_logic;
            ExOutSelE  : in std_logic;
            CallE      : in std_logic;
            RtiE       : in std_logic;
            RetE       : in std_logic;
            Int1E      : in std_logic;
            PopE       : in std_logic;
            PushE      : in std_logic;

            Branch     : out std_logic;
            PSP        : out std_logic_vector(31 downto 0);
            SP         : out std_logic_vector(31 downto 0);
            RdstE      : out std_logic_vector(2 downto 0);
            RD2E       : out std_logic_vector(31 downto 0);
            ExoutE     : out std_logic_vector(31 downto 0)
        );
    end component Excute_Stage;

    component Memory_Fetch_Stages is
        port (
            clk            : in std_logic;
            reset          : in std_logic;
            interrupt      : in std_logic;
            Branch         : in std_logic;
            SwapCtrl       : in std_logic;
            HLT            : in std_logic;
            RETM           : in std_logic;
            POPM           : in std_logic;
            RTIM           : in std_logic;
            PUSHM          : in std_logic;
            INT1M          : in std_logic;
            INT2M          : in std_logic;
            CALLM          : in std_logic;
            MemM           : in std_logic;
            MemSelM        : in std_logic;
            RegWriteENM    : in std_logic;
            PC1M           : in std_logic_vector(31 downto 0);
            OutEnM         : in std_logic;
            ExOutM         : in std_logic_vector(31 downto 0);
            RD2M           : in std_logic_vector(31 downto 0);
            RdstM          : in std_logic_vector(2 downto 0);
            PSPM           : in std_logic_vector(31 downto 0);
            SP             : in std_logic_vector(31 downto 0);
            MemDataM       : in std_logic_vector(31 downto 0);
            ResetData      : in std_logic_vector(31 downto 0);
            ImmE           : in std_logic_vector(31 downto 0);
            PC_enableH     : in std_logic;

            RegWriteEnWM   : out std_logic;
            EXOutWM        : out std_logic_vector(31 downto 0);
            RdstWM         : out std_logic_vector(2 downto 0);
            outPort        : out std_logic_vector(31 downto 0);
            MemAddr        : out std_logic_vector(31 downto 0);
            MemWriteData   : out std_logic_vector(31 downto 0);
            PC1f           : out std_logic_vector(31 downto 0)
        );
    end component Memory_Fetch_Stages;

    component WB_Stage is
        port (
            WBSelWB      : in std_logic := '0';
            MemOutWB     : in std_logic_vector(31 downto 0) := x"0000_0000";
            EXOutWB      : in std_logic_vector(31 downto 0) := x"0000_0000";

            RegDataWB    : out std_logic_vector(31 downto 0) := x"0000_0000"
        );
    end component WB_Stage;

    component ForwardUnit is
        port (
            rs1         : in std_logic_vector(2 downto 0);
            rs2         : in std_logic_vector(2 downto 0);
            rd_MEM      : in std_logic_vector(2 downto 0);
            rd_WB       : in std_logic_vector(2 downto 0);
            SwapE       : in std_logic_vector(1 downto 0);
            regWrite_MEM: in std_logic;
            regWrite_WB : in std_logic;

            forwardA    : out std_logic_vector(1 downto 0);
            forwardB    : out std_logic_vector(1 downto 0)
        );
    end component ForwardUnit;

    component Hazard_Unit is
        port (
            POPM        : in std_logic;
            PUSM        : in std_logic;
            Mem         : in std_logic;
            CU_IsIMM    : in std_logic;
            RTIM        : in std_logic;
            Branch      : in std_logic;
            RETM        : in std_logic;
            CALLM       : in std_logic;
            INT1D       : in std_logic;
            INT1M       : in std_logic;
            INT2M       : in std_logic;
            ID_EX_LoadUse : in std_logic;
            IF_ID_Rs1   : in std_logic_vector(2 downto 0);
            IF_ID_Rs2   : in std_logic_vector(2 downto 0);
            ID_EX_Rd    : in std_logic_vector(2 downto 0);

            PC_enableH   : out std_logic;
            IF_ID_enable : out std_logic;
            IF_ID_flush : out std_logic;
            ID_EX_enable : out std_logic;
            ID_EX_flush : out std_logic;
            EX_MEM_flush : out std_logic;
            MEM_WB_flush : out std_logic;
            NOP_ctrl    : out std_logic
        );
    end component Hazard_Unit;

    -- ================================================================
    -- PIPELINE REGISTER SIGNALS
    -- ================================================================
    constant NOP_INSTRUCTION : std_logic_vector(31 downto 0) := x"0000_0000";
    
    -- IF/ID Register outputs (Decode stage inputs)
    signal sig_IF_ID_instruction : std_logic_vector(31 downto 0);
    signal sig_IF_ID_pc1         : std_logic_vector(31 downto 0);

    -- Decode Stage outputs
    signal sig_ID_Rsrc1    : std_logic_vector(2 downto 0);
    signal sig_ID_Rsrc2    : std_logic_vector(2 downto 0);
    signal sig_ID_Rdst     : std_logic_vector(2 downto 0);
    signal sig_ID_IsImm    : std_logic;
    signal sig_ID_SwapCtrl : std_logic;
    signal sig_ID_HLT      : std_logic;
    signal sig_ID_RetD     : std_logic;
    signal sig_ID_PopD     : std_logic;
    signal sig_ID_RtiD     : std_logic;
    signal sig_ID_PushD    : std_logic;
    signal sig_ID_Int1D    : std_logic;
    signal sig_ID_Int2D    : std_logic;
    signal sig_ID_CallD    : std_logic;
    signal sig_ID_MemAccess : std_logic;
    signal sig_ID_MemSelD  : std_logic;
    signal sig_ID_RegWrite : std_logic;
    signal sig_ID_WbSel    : std_logic;
    signal sig_ID_SwapD    : std_logic_vector(1 downto 0);
    signal sig_ID_MemWrite : std_logic;
    signal sig_ID_AluOp    : std_logic_vector(3 downto 0);
    signal sig_ID_JmpZ     : std_logic;
    signal sig_ID_JmpC     : std_logic;
    signal sig_ID_JmpN     : std_logic;
    signal sig_ID_JmpD     : std_logic;
    signal sig_ID_ExOutSel : std_logic;
    signal sig_ID_LoadUse  : std_logic;
    signal sig_ID_OutEn    : std_logic;

    -- RegFile outputs
    signal sig_RegFile_RD1 : std_logic_vector(31 downto 0);
    signal sig_RegFile_RD2 : std_logic_vector(31 downto 0);

    -- ID/EX Register outputs (Execute stage inputs)
    signal sig_ID_EX_Rsrc1    : std_logic_vector(2 downto 0);
    signal sig_ID_EX_Rsrc2    : std_logic_vector(2 downto 0);
    signal sig_ID_EX_Rdst     : std_logic_vector(2 downto 0);
    signal sig_ID_EX_RD1      : std_logic_vector(31 downto 0);
    signal sig_ID_EX_RD2      : std_logic_vector(31 downto 0);
    signal sig_ID_EX_Imm      : std_logic_vector(31 downto 0);
    signal sig_ID_EX_PC1      : std_logic_vector(31 downto 0);
    signal sig_ID_EX_IsImm    : std_logic;
    signal sig_ID_EX_SwapE    : std_logic_vector(1 downto 0);
    signal sig_ID_EX_AluOp    : std_logic_vector(3 downto 0);
    signal sig_ID_EX_JmpZ     : std_logic;
    signal sig_ID_EX_JmpC     : std_logic;
    signal sig_ID_EX_JmpN     : std_logic;
    signal sig_ID_EX_JmpE     : std_logic;
    signal sig_ID_EX_ExOutSel : std_logic;
    signal sig_ID_EX_LoadUse  : std_logic;
    signal sig_ID_EX_CallE    : std_logic;
    signal sig_ID_EX_RtiE     : std_logic;
    signal sig_ID_EX_RetE     : std_logic;
    signal sig_ID_EX_Int1E    : std_logic;
    signal sig_ID_EX_Int2E    : std_logic;
    signal sig_ID_EX_PopE     : std_logic;
    signal sig_ID_EX_PushE    : std_logic;
    signal sig_ID_EX_MemE     : std_logic;
    signal sig_ID_EX_MemSelE     : std_logic;
    signal sig_ID_EX_RegWriteEn : std_logic;
    signal sig_ID_EX_WbSel    : std_logic;
    signal sig_ID_EX_MemWrite : std_logic;
    signal sig_ID_EX_OutEn    : std_logic;

    -- Execute Stage outputs
    signal sig_EX_Branch   : std_logic;
    signal sig_EX_SP       : std_logic_vector(31 downto 0);
    signal sig_EX_PSP      : std_logic_vector(31 downto 0);
    signal sig_EX_RdstE    : std_logic_vector(2 downto 0);
    signal sig_EX_RD2E     : std_logic_vector(31 downto 0);
    signal sig_EX_ExoutE   : std_logic_vector(31 downto 0);

    -- EX/MEM Register outputs (Memory stage inputs)
    signal sig_EX_MEM_ExOut   : std_logic_vector(31 downto 0);
    signal sig_EX_MEM_RD2     : std_logic_vector(31 downto 0);
    signal sig_EX_MEM_PC1     : std_logic_vector(31 downto 0);
    signal sig_EX_MEM_PSP     : std_logic_vector(31 downto 0);
    signal sig_EX_MEM_Rdst    : std_logic_vector(2 downto 0);
    signal sig_EX_MEM_Rsrc2    : std_logic_vector(2 downto 0);
    signal sig_EX_MEM_RET     : std_logic;
    signal sig_EX_MEM_RTI     : std_logic;
    signal sig_EX_MEM_CALL    : std_logic;
    signal sig_EX_MEM_MEM     : std_logic;
    signal sig_EX_MEM_MemSel  : std_logic;
    signal sig_EX_MEM_RegWrite : std_logic;
    signal sig_EX_MEM_WbSel   : std_logic;
    signal sig_EX_MEM_MemWrite : std_logic;
    signal sig_EX_MEM_OutEn   : std_logic;
    signal sig_EX_MEM_PUSH    : std_logic;
    signal sig_EX_MEM_POP     : std_logic;
    signal sig_EX_MEM_INT1    : std_logic;
    signal sig_EX_MEM_INT2    : std_logic;

    -- Memory stage outputs  
    signal sig_MEM_RegWriteEnWM : std_logic;
    signal sig_MEM_EXOutWM      : std_logic_vector(31 downto 0);
    signal sig_MEM_RdstWM       : std_logic_vector(2 downto 0);
    signal sig_MEM_outPort      : std_logic_vector(31 downto 0);
    signal sig_MEM_MemAddr      : std_logic_vector(31 downto 0);
    signal sig_MEM_MemWriteData : std_logic_vector(31 downto 0);
    signal sig_MEM_PC1f         : std_logic_vector(31 downto 0);

    -- Data Memory (connected to Memory_Fetch_Stage outputs)
    signal sig_DataMemory_ReadData : std_logic_vector(31 downto 0);

    -- MEM/WB Register outputs (Write-Back stage inputs)
    signal sig_MEM_WB_ExOut   : std_logic_vector(31 downto 0);
    signal sig_MEM_WB_MemOut  : std_logic_vector(31 downto 0);
    signal sig_MEM_WB_Rdst    : std_logic_vector(2 downto 0);
    signal sig_MEM_WB_RegWrite : std_logic;
    signal sig_MEM_WB_WbSel   : std_logic;

    -- Write-Back Stage output
    signal sig_WB_RegDataWB   : std_logic_vector(31 downto 0);

    -- Control signal MUXes

    -- Forwarding Unit outputs
    signal sig_ForwardA : std_logic_vector(1 downto 0);
    signal sig_ForwardB : std_logic_vector(1 downto 0);

    -- Hazard Unit outputs
    signal sig_PC_enable      : std_logic;
    signal sig_IF_ID_enable   : std_logic;
    signal sig_IF_ID_flush    : std_logic;
    signal sig_ID_EX_enable   : std_logic;
    signal sig_ID_EX_flush    : std_logic;
    signal sig_EX_MEM_flush   : std_logic;
    signal sig_MEM_WB_flush   : std_logic;
    signal sig_NOP_ctrl       : std_logic;
    -- helper signals
    signal sig_insFetch      : std_logic_vector(31 downto 0);
    signal sig_en_fd         : std_logic;

BEGIN

    -- ================================================================
    -- -- STAGE 1: FETCH (implicit with PC/Memory)
    -- ================================================================
    MEMORY_FETCH_STAGE_INST : entity work.Memory_Fetch_Stages
        port map (
            clk           => clk,
            reset         => rst,
            interrupt     => hwInt,
            Branch        => sig_EX_Branch,
            SwapCtrl      => sig_ID_SwapCtrl,
            HLT           => sig_ID_HLT,
            RETM          => sig_EX_MEM_RET,
            POPM          => sig_EX_MEM_POP,
            RTIM          => sig_EX_MEM_RTI,
            PUSHM         => sig_EX_MEM_PUSH,
            INT1M         => sig_EX_MEM_INT1,
            INT2M         => sig_EX_MEM_INT2,
            CALLM         => sig_EX_MEM_CALL,
            MemM          => sig_EX_MEM_MEM,
            MemSelM       => sig_EX_MEM_MemSel,
            RegWriteENM   => sig_EX_MEM_RegWrite,
            PC1M          => sig_EX_MEM_PC1,
            OutEnM        => sig_EX_MEM_OutEn,
            ExOutM        => sig_EX_MEM_ExOut,
            RD2M          => sig_EX_MEM_RD2,
            RegDataWB     => sig_WB_RegDataWB,
            rd_WB        => sig_MEM_WB_Rdst,
            RdstM         => sig_EX_MEM_Rdst,
            Rsrc2
            PSPM          => sig_EX_MEM_PSP,
            SP            => sig_EX_SP,
            MemDataM      => sig_DataMemory_ReadData,
            ResetData     => sig_DataMemory_ReadData,
            ImmE          => sig_ID_EX_Imm,
            PC_enableH    => sig_PC_enable,
            RegWriteEnWM  => sig_MEM_RegWriteEnWM,
            EXOutWM       => sig_MEM_EXOutWM,
            RdstWM        => sig_MEM_RdstWM,
            outPort       => sig_MEM_outPort,
            MemAddr       => sig_MEM_MemAddr,
            MemWriteData  => sig_MEM_MemWriteData,
            PC1f          => sig_MEM_PC1f
        );
        
    -- Data Memory component
    DATA_MEMORY_INST : entity work.Memory
        port map (
            clk         => clk,
            WriteEnable => sig_EX_MEM_MemWrite,
            Address     => sig_MEM_MemAddr,
            WriteData   => sig_MEM_MemWriteData,
            ReadData    => sig_DataMemory_ReadData
        );

    sig_insFetch <= sig_DataMemory_ReadData when sig_NOP_ctrl = '0' else NOP_INSTRUCTION;

    -- ================================================================
    -- -- FETCH/DECODE PIPELINE REGISTER (IF/ID)
    -- ================================================================
    sig_en_fd <= sig_IF_ID_enable and not sig_ID_SwapCtrl and not sig_ID_HLT;
    IF_ID_REG : entity work.IF_ID_Register
        port map (
            clk           => clk,
            rst           => rst,
            enable        => sig_en_fd,  -- Disable IF/ID update on a swap to insert NOP
            flush         => sig_IF_ID_flush,
            instruction_F => sig_insFetch,  -- From Fetch (PC+1 repurposed as instr in this design)
            pc1_F         => sig_MEM_PC1f,
            instruction_D => sig_IF_ID_instruction,
            pc1_D         => sig_IF_ID_pc1
        );

    -- ================================================================
    -- -- STAGE 2: DECODE
    -- ================================================================
    DECODE_STAGE_INST : entity work.Decode_Stage
        port map (
            clk           => clk,
            rst           => rst,
            instruction   => sig_IF_ID_instruction,
            RSrc1D        => sig_ID_Rsrc1,
            RSrc2D        => sig_ID_Rsrc2,
            Rdst          => sig_ID_Rdst,
            SwapCtrl      => sig_ID_SwapCtrl,
            IsImm         => sig_ID_IsImm,
            HLT           => sig_ID_HLT,
            RetD          => sig_ID_RetD,
            PopD          => sig_ID_PopD,
            RtiD          => sig_ID_RtiD,
            PushD         => sig_ID_PushD,
            Int1D         => sig_ID_Int1D,
            Int2D         => sig_ID_Int2D,
            CallD         => sig_ID_CallD,
            MemDLoadStore => sig_ID_MemAccess,
            MemSelD       => sig_ID_MemSelD,
            RegWriteEnD   => sig_ID_RegWrite,
            WbSelD      => sig_ID_WbSel,
            SwapD         => sig_ID_SwapD,
            MemWriteD     => sig_ID_MemWrite,
            AluOpD        => sig_ID_AluOp,
            JmpZD         => sig_ID_JmpZ,
            JmpCD         => sig_ID_JmpC,
            JmpND         => sig_ID_JmpN,
            JmpD          => sig_ID_JmpD,
            ExOutSelD     => sig_ID_ExOutSel,
            LoadUseD      => sig_ID_LoadUse,
            OutEnD        => sig_ID_OutEn
        );

    -- RegFile is inside Decode_Stage, instantiate separately for write-back
    REGFILE_INST : entity work.RegFile
        port map (
            clk         => clk,
            rst         => rst,
            RegWriteEn  => sig_MEM_WB_RegWrite,
            wa          => sig_MEM_WB_Rdst,
            w_data      => sig_WB_RegDataWB,
            ra_1        => sig_ID_Rsrc1,
            ra_2        => sig_ID_Rsrc2,
            r_data1     => sig_RegFile_RD1,
            r_data2     => sig_RegFile_RD2
        );

    -- Extract immediate from instruction (bits 15:0 sign-extended to 32 bits)


    -- ================================================================
    -- -- DECODE/EXECUTE PIPELINE REGISTER (ID/EX)
    -- ================================================================
    ID_EX_REG : entity work.ID_EX_Register
        port map (
            clk         => clk,
            rst         => rst,
            enable      => sig_ID_EX_enable,
            flush       => sig_ID_EX_flush,
            IsIMMD      => sig_ID_IsImm,
            RETD        => sig_ID_RetD,
            POPD        => sig_ID_PopD,
            RTID        => sig_ID_RtiD,
            PUSHD       => sig_ID_PushD,
            INT1D       => sig_ID_Int1D,
            INT2D       => sig_ID_Int2D,
            CALLD       => sig_ID_CallD,
            MEMD        => sig_ID_MemAccess,
            MemSelD     => sig_ID_MemSelD,
            RegWriteEnD => sig_ID_RegWrite,
            WbSelD      => sig_ID_WbSel,
            SwapD       => sig_ID_SwapD,
            MemWriteD   => sig_ID_MemWrite,
            AluOpD      => sig_ID_AluOp,
            JmpZD       => sig_ID_JmpZ,
            JmpCD       => sig_ID_JmpC,
            JmpND       => sig_ID_JmpN,
            JmpD        => sig_ID_JmpD,
            ExOutSelD   => sig_ID_ExOutSel,
            LoadUseD    => sig_ID_LoadUse,
            OutEnD      => sig_ID_OutEn,
            PC1D        => sig_IF_ID_pc1,
            RD1_D       => sig_RegFile_RD1,
            RD2_D       => sig_RegFile_RD2,
            Rsrc1D      => sig_ID_Rsrc1,
            Rsrc2D      => sig_ID_Rsrc2,
            RdstD       => sig_ID_Rdst,
            ImmF        => sig_DataMemory_ReadData,
            IsIMM_E     => sig_ID_EX_IsImm,
            RET_E       => sig_ID_EX_RetE,
            POP_E       => sig_ID_EX_PopE,
            RTI_E       => sig_ID_EX_RtiE,
            PUSH_E      => sig_ID_EX_PushE,
            INT1_E      => sig_ID_EX_Int1E,
            INT2_E      => sig_ID_EX_Int2E,
            CALL_E      => sig_ID_EX_CallE,
            MEM_E       => sig_ID_EX_MemE,
            MemSel_E    => sig_ID_EX_MemSelE,
            RegWriteEn_E => sig_ID_EX_RegWriteEn,
            WbSel_E     => sig_ID_EX_WbSel,
            Swap_E      => sig_ID_EX_SwapE,
            MemWrite_E  => sig_ID_EX_MemWrite,
            AluOp_E     => sig_ID_EX_AluOp,
            JmpZ_E      => sig_ID_EX_JmpZ,
            JmpC_E      => sig_ID_EX_JmpC,
            JmpN_E      => sig_ID_EX_JmpN,
            Jmp_E       => sig_ID_EX_JmpE,
            ExOutSel_E  => sig_ID_EX_ExOutSel,
            LoadUse_E   => sig_ID_EX_LoadUse,
            OutEn_E     => sig_ID_EX_OutEn,
            PC1_E       => sig_ID_EX_PC1,
            RD1_E       => sig_ID_EX_RD1,
            RD2_E       => sig_ID_EX_RD2,
            Rsrc1_E     => sig_ID_EX_Rsrc1,
            Rsrc2_E     => sig_ID_EX_Rsrc2,
            Rdst_E      => sig_ID_EX_Rdst,
            Imm_E       => sig_ID_EX_Imm
        );

    -- ================================================================
    -- -- FORWARDING UNIT
    -- ================================================================
    FORWARD_UNIT_INST : entity work.ForwardUnit
        port map (
            rs1          => sig_ID_EX_Rsrc1,
            rs2          => sig_ID_EX_Rsrc2,
            rd_MEM       => sig_EX_MEM_Rdst,
            rd_WB        => sig_MEM_WB_Rdst,
            SwapE        => sig_ID_EX_SwapE,
            regWrite_MEM => sig_EX_MEM_RegWrite,
            regWrite_WB  => sig_MEM_WB_RegWrite,
            forwardA     => sig_ForwardA,
            forwardB     => sig_ForwardB
        );

    -- ================================================================
    -- -- STAGE 3: EXECUTE
    -- ================================================================
    EXECUTE_STAGE_INST : entity work.Excute_Stage
        port map (
            clk         => clk,
            rst         => rst,
            RD1         => sig_ID_EX_RD1,
            RD2         => sig_ID_EX_RD2,
            RSrc1D      => sig_ID_EX_Rsrc1,
            RSrc2D      => sig_ID_EX_Rsrc2,
            Rdst        => sig_ID_EX_Rdst,
            ImmE        => sig_ID_EX_Imm,
            InputPort   => inPort,
            interrupt   => hwInt,
            ExoutM      => sig_EX_MEM_ExOut,
            RegDataWB   => sig_WB_RegDataWB,
            ForwardA    => sig_ForwardA,
            ForwardB    => sig_ForwardB,
            SwapE       => sig_ID_EX_SwapE,
            AluOpE      => sig_ID_EX_AluOp,
            JmpZDE      => sig_ID_EX_JmpZ,
            JmpCE       => sig_ID_EX_JmpC,
            JmpNE       => sig_ID_EX_JmpN,
            JmpE        => sig_ID_EX_JmpE,
            IsImmE      => sig_ID_EX_IsImm,
            ExOutSelE   => sig_ID_EX_ExOutSel,
            CallE       => sig_ID_EX_CallE,
            RtiE        => sig_ID_EX_RtiE,
            RetE        => sig_ID_EX_RetE,
            Int1E       => sig_ID_EX_Int1E,
            PopE        => sig_ID_EX_PopE,
            PushE       => sig_ID_EX_PushE,
            Branch      => sig_EX_Branch,
            PSP         => sig_EX_PSP,
            SP          => sig_EX_SP,
            RdstE       => sig_EX_RdstE,
            RD2E        => sig_EX_RD2E,
            ExoutE      => sig_EX_ExoutE
        );

    -- ================================================================
    -- -- EXECUTE/MEMORY PIPELINE REGISTER (EX/MEM)
    -- ================================================================
    EX_MEM_REG : entity work.EX_MEM_Register
        port map (
            clk         => clk,
            rst         => rst,
            enable      => '1',
            flush       => sig_EX_MEM_flush,
            ExOutE      => sig_EX_ExoutE,
            RD2_E       => sig_EX_RD2E,
            PC1_E       => sig_ID_EX_PC1,
            PSP_E       => sig_EX_PSP,
            Rdst_E      => sig_EX_RdstE,
            Rsrc2_E     => sig_ID_EX_Rsrc2,
            RETE        => sig_ID_EX_RetE,
            RTIE        => sig_ID_EX_RtiE,
            CALLE       => sig_ID_EX_CallE,
            MEM_E       => sig_ID_EX_MemE,
            MemSel_E    => sig_ID_EX_MemSelE,
            RegWriteEn_E => sig_ID_EX_RegWriteEn,
            WbSel_E     => sig_ID_EX_WbSel,
            MemWrite_E  => sig_ID_EX_MemWrite,
            OutEn_E     => sig_ID_EX_OutEn,
            PUSH_E      => sig_ID_EX_PushE,
            POP_E       => sig_ID_EX_PopE,
            INT1_E      => sig_ID_EX_Int1E,
            INT2_E      => sig_ID_EX_Int2E,
            ExOutM      => sig_EX_MEM_ExOut,
            RD2_M       => sig_EX_MEM_RD2,
            PC1_M       => sig_EX_MEM_PC1,
            PSP_M       => sig_EX_MEM_PSP,
            Rdst_M      => sig_EX_MEM_Rdst,
            Rsrc2_M     => sig_EX_MEM_Rsrc2,
            RET_M       => sig_EX_MEM_RET,
            RTI_M       => sig_EX_MEM_RTI,
            CALL_M      => sig_EX_MEM_CALL,
            MEM_M       => sig_EX_MEM_MEM,
            MemSel_M    => sig_EX_MEM_MemSel,
            RegWriteEn_M => sig_EX_MEM_RegWrite,
            WbSel_M     => sig_EX_MEM_WbSel,
            MemWrite_M  => sig_EX_MEM_MemWrite,
            OutEn_M     => sig_EX_MEM_OutEn,
            PUSH_M      => sig_EX_MEM_PUSH,
            POP_M       => sig_EX_MEM_POP,
            INT1_M      => sig_EX_MEM_INT1,
            INT2_M      => sig_EX_MEM_INT2
        );


    -- ================================================================
    -- -- MEMORY/WRITE-BACK PIPELINE REGISTER (MEM/WB)
    -- ================================================================
    MEM_WB_REG : entity work.MEM_WB_Register
        port map (
            clk         => clk,
            rst         => rst,
            enable      => '1',
            flush       => sig_MEM_WB_flush,
            ExOutM      => sig_MEM_EXOutWM,
            MemOutM     => sig_DataMemory_ReadData,
            ImmM        => sig_ID_EX_Imm,
            RdstM       => sig_MEM_RdstWM,
            RegWriteEnM => sig_MEM_RegWriteEnWM,
            WbSelM      => sig_EX_MEM_WbSel,  -- Always select EXOut for now

            ExOutW      => sig_MEM_WB_ExOut,    
            MemOutW     => sig_MEM_WB_MemOut,
            ImmW        => open,
            RdstW       => sig_MEM_WB_Rdst,
            RegWriteEnW => sig_MEM_WB_RegWrite,
            WbSelW      => sig_MEM_WB_WbSel
        );

    -- ================================================================
    -- -- STAGE 5: WRITE-BACK
    -- ================================================================
    WB_STAGE_INST : entity work.WB_Stage
        port map (
            WBSelWB      => sig_MEM_WB_WbSel,
            MemOutWB     => sig_MEM_WB_MemOut,
            EXOutWB      => sig_MEM_WB_ExOut,
            RegDataWB    => sig_WB_RegDataWB
        );

    -- ================================================================
    -- -- HAZARD UNIT
    -- ================================================================
    HAZARD_UNIT_INST : entity work.Hazard_Unit
        port map (
            POPM         => sig_EX_MEM_POP,
            PUSM         => sig_EX_MEM_PUSH,
            Mem          => sig_EX_MEM_MEM,
            CU_IsIMM     => sig_ID_IsImm,
            RTIM         => sig_EX_MEM_RTI,
            Branch       => sig_EX_Branch,
            RETM         => sig_EX_MEM_RET,
            CALLM        => sig_EX_MEM_CALL,
            INT1D        => sig_ID_Int1D,
            INT1M        => sig_EX_MEM_INT1,
            INT2M        => sig_EX_MEM_INT2,
            ID_EX_LoadUse => sig_ID_EX_LoadUse,
            IF_ID_Rs1    => sig_ID_Rsrc1,
            IF_ID_Rs2    => sig_ID_Rsrc2,
            ID_EX_Rd     => sig_ID_EX_Rdst,
            PC_enable    => sig_PC_enable,
            IF_ID_enable => sig_IF_ID_enable,
            IF_ID_flush  => sig_IF_ID_flush,
            ID_EX_enable => sig_ID_EX_enable,
            ID_EX_flush  => sig_ID_EX_flush,
            EX_MEM_flush => sig_EX_MEM_flush,
            MEM_WB_flush => sig_MEM_WB_flush,
            NOP_ctrl     => sig_NOP_ctrl
        );

    -- ================================================================
    -- -- OUTPUT ASSIGNMENTS
    -- ================================================================
    outPort <= sig_MEM_outPort;

END ARCHITECTURE struct;

