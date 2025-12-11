LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU IS
    PORT (
        clk     : IN  STD_LOGIC;
        rst     : IN  STD_LOGIC;
        swInt   : IN  STD_LOGIC;
        inPort  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY CPU;

ARCHITECTURE struct OF CPU IS

    ----------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------
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
            clk         : in  std_logic;
            rst         : in  std_logic;
            RegWriteEn  : in  std_logic;
            wa          : in  std_logic_vector(2 downto 0);
            w_data      : in  std_logic_vector(31 downto 0);
            ra_1        : in  std_logic_vector(2 downto 0);
            ra_2        : in  std_logic_vector(2 downto 0);
            r_data1     : out std_logic_vector(31 downto 0);
            r_data2     : out std_logic_vector(31 downto 0)
        );
    end component RegFile;

    component IF_ID_Register is
        port (
            clk          : in std_logic;
            rst          : in std_logic;
            enable       : in std_logic;
            flush        : in std_logic;
            instruction_F: in std_logic_vector(31 downto 0);
            pc1_F        : in std_logic_vector(31 downto 0);
            instruction_D: out std_logic_vector(31 downto 0);
            pc1_D        : out std_logic_vector(31 downto 0)
        );
    end component IF_ID_Register;

    component ID_EX_Register is
        port (
            clk, rst      : in std_logic;
            enable        : in std_logic;
            flush         : in std_logic;

            -- control inputs (from ID)
            IsIMMD         : in std_logic;
            RETD           : in std_logic;
            POPD           : in std_logic;
            RTID           : in std_logic;
            PUSHD          : in std_logic;
            INT1D          : in std_logic;
            INT2D          : in std_logic;
            CALLD          : in std_logic;
            MEMD           : in std_logic;
            MemSelD        : in std_logic;
            RegWriteEnD    : in std_logic;
            WbSelD         : in std_logic_vector(1 downto 0);
            SwapD          : in std_logic_vector(1 downto 0);
            MemWriteD      : in std_logic;
            AluOpD         : in std_logic_vector(3 downto 0);
            JmpZD          : in std_logic;
            JmpCD          : in std_logic;
            JmpND          : in std_logic;
            JmpD           : in std_logic;
            ExOutSelD      : in std_logic;
            LoadUseD       : in std_logic;
            OutEnD         : in std_logic;

            -- datapath inputs (from ID)
            PC1D           : in std_logic_vector(31 downto 0);
            RD1_D          : in std_logic_vector(31 downto 0);
            RD2_D          : in std_logic_vector(31 downto 0);
            Rsrc1D         : in std_logic_vector(2 downto 0);
            Rsrc2D         : in std_logic_vector(2 downto 0);
            RdstD          : in std_logic_vector(2 downto 0);
            ImmF           : in std_logic_vector(31 downto 0);

            -- outputs to EX
            IsIMM_E        : out std_logic;
            RET_E          : out std_logic;
            POP_E          : out std_logic;
            RTI_E          : out std_logic;
            PUSH_E         : out std_logic;
            INT1_E         : out std_logic;
            INT2_E         : out std_logic;
            CALL_E         : out std_logic;
            MEM_E          : out std_logic;
            MemSel_E       : out std_logic;
            RegWriteEn_E   : out std_logic;
            WbSel_E        : out std_logic_vector(1 downto 0);
            Swap_E         : out std_logic_vector(1 downto 0);
            MemWrite_E     : out std_logic;
            AluOp_E        : out std_logic_vector(3 downto 0);
            JmpZ_E         : out std_logic;
            JmpC_E         : out std_logic;
            JmpN_E         : out std_logic;
            Jmp_E          : out std_logic;
            ExOutSel_E     : out std_logic;
            LoadUse_E      : out std_logic;
            OutEn_E        : out std_logic;
            PC1_E          : out std_logic_vector(31 downto 0);
            RD1_E          : out std_logic_vector(31 downto 0);
            RD2_E          : out std_logic_vector(31 downto 0);
            Rsrc1_E        : out std_logic_vector(2 downto 0);
            Rsrc2_E        : out std_logic_vector(2 downto 0);
            Rdst_E         : out std_logic_vector(2 downto 0);
            Imm_E          : out std_logic_vector(31 downto 0)
        );
    end component ID_EX_Register;

    component EX_MEM_Register is
        port (
            clk, rst      : in std_logic;
            enable        : in std_logic;
            flush         : in std_logic;

            -- inputs from EX
            ExOutE        : in std_logic_vector(31 downto 0);
            RD2_E         : in std_logic_vector(31 downto 0);
            PC1_E         : in std_logic_vector(31 downto 0);
            PSP_E         : in std_logic_vector(31 downto 0);
            Imm_E         : in std_logic_vector(31 downto 0);
            Rdst_E        : in std_logic_vector(2 downto 0);

            RETE          : in std_logic;
            RTIE          : in std_logic;
            CALLE         : in std_logic;
            MEM_E         : in std_logic;
            MemSel_E      : in std_logic;
            RegWriteEn_E  : in std_logic;
            WbSel_E       : in std_logic_vector(1 downto 0);
            MemWrite_E    : in std_logic;
            OutEn_E       : in std_logic;
            PUSH_E        : in std_logic;
            POP_E         : in std_logic;
            INT1_E        : in std_logic;
            INT2_E        : in std_logic;

            -- outputs to MEM
            ExOutM        : out std_logic_vector(31 downto 0);
            RD2_M         : out std_logic_vector(31 downto 0);
            PC1_M         : out std_logic_vector(31 downto 0);
            PSP_M         : out std_logic_vector(31 downto 0);
            Imm_M         : out std_logic_vector(31 downto 0);
            Rdst_M        : out std_logic_vector(2 downto 0);

            RET_M         : out std_logic;
            RTI_M         : out std_logic;
            CALL_M        : out std_logic;
            MEM_M         : out std_logic;
            MemSel_M      : out std_logic;
            RegWriteEn_M  : out std_logic;
            WbSel_M       : out std_logic_vector(1 downto 0);
            MemWrite_M    : out std_logic;
            OutEn_M       : out std_logic;
            PUSH_M        : out std_logic;
            POP_M         : out std_logic;
            INT1_M        : out std_logic;
            INT2_M        : out std_logic
        );
    end component EX_MEM_Register;

    component MEM_WB_Register is
        port (
            clk, rst     : in std_logic;
            enable       : in std_logic;
            flush        : in std_logic;

            -- inputs from MEM
            ExOutM       : in std_logic_vector(31 downto 0);
            MemOutM      : in std_logic_vector(31 downto 0);
            ImmM         : in std_logic_vector(31 downto 0);
            RdstM        : in std_logic_vector(2 downto 0);
            RegWriteEnM  : in std_logic;
            WbSelM       : in std_logic_vector(1 downto 0);

            -- outputs to WB
            ExOutW       : out std_logic_vector(31 downto 0);
            MemOutW      : out std_logic_vector(31 downto 0);
            ImmW         : out std_logic_vector(31 downto 0);
            RdstW        : out std_logic_vector(2 downto 0);
            RegWriteEnW  : out std_logic;
            WbSelW       : out std_logic_vector(1 downto 0)
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

            SwapCtrl    : out std_logic_vector(0 downto 0);
            IsImm       : out std_logic_vector(0 downto 0);
            HLT         : out std_logic_vector(0 downto 0);
            RetD        : out std_logic_vector(0 downto 0);
            PopD        : out std_logic_vector(0 downto 0);
            RtiD        : out std_logic_vector(0 downto 0);
            PushD       : out std_logic_vector(0 downto 0);
            Int1D       : out std_logic_vector(0 downto 0);
            Int2D       : out std_logic_vector(0 downto 0);
            CallD       : out std_logic_vector(0 downto 0);
            MemDLoadStore: out std_logic_vector(0 downto 0);
            MemSelD     : out std_logic_vector(0 downto 0);
            RegWriteEnD : out std_logic_vector(0 downto 0);
            WbSelD      : out std_logic_vector(1 downto 0);
            SwapD       : out std_logic_vector(1 downto 0);
            MemWriteD   : out std_logic_vector(0 downto 0);
            AluOpD      : out std_logic_vector(3 downto 0);
            JmpZD       : out std_logic_vector(0 downto 0);
            JmpCD       : out std_logic_vector(0 downto 0);
            JmpND       : out std_logic_vector(0 downto 0);
            JmpD        : out std_logic_vector(0 downto 0);
            ExOutSelD   : out std_logic_vector(0 downto 0);
            LoadUseD    : out std_logic_vector(0 downto 0);
            OutEnD      : out std_logic_vector(0 downto 0)
        );
    end component Decode_Stage;

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
            ImmM           : in std_logic_vector(31 downto 0);
            RdstM          : in std_logic_vector(2 downto 0);
            PSPM           : in std_logic_vector(31 downto 0);
            SP             : in std_logic_vector(31 downto 0);

            ImmE           : in std_logic_vector(31 downto 0);

            RegWriteEnWM   : out std_logic;
            EXOutWM        : out std_logic_vector(31 downto 0);
            ImmWM          : out std_logic_vector(31 downto 0);
            RdstWM         : out std_logic_vector(2 downto 0);
            outPort        : out std_logic_vector(31 downto 0);

            MemAddr        : out std_logic_vector(31 downto 0);
            MemWriteData   : out std_logic_vector(31 downto 0);

            PC1f           : out std_logic_vector(31 downto 0)
        );
    end component Memory_Fetch_Stages;

    component Excute_Stage is
        port (
            clk        : in std_logic;
            rst        : in std_logic;

            RD1        : in std_logic_vector(31 downto 0);
            RD2        : in std_logic_vector(31 downto 0);
            RSrc1D     : in std_logic_vector(2 downto 0);
            RSrc2D     : in std_logic_vector(2 downto 0);
            Rdst       : in std_logic_vector(2 downto 0);
            ImmD       : in std_logic_vector(31 downto 0);
            InputPort  : in std_logic_vector(31 downto 0);
            interrupt  : in std_logic_vector(0 downto 0);

            SwapE      : in std_logic_vector(1 downto 0);
            AluOpE     : in std_logic_vector(3 downto 0);
            JmpZDE     : in std_logic_vector(0 downto 0);
            JmpCE      : in std_logic_vector(0 downto 0);
            JmpNE      : in std_logic_vector(0 downto 0);
            JmpE       : in std_logic_vector(0 downto 0);
            IsImmE     : in std_logic_vector(0 downto 0);
            ExOutSelE  : in std_logic_vector(0 downto 0);
            LoadUseE   : in std_logic_vector(0 downto 0);

            CallE      : in std_logic_vector(0 downto 0);
            RtiE       : in std_logic_vector(0 downto 0);
            RetE       : in std_logic_vector(0 downto 0);
            Int1E      : in std_logic_vector(0 downto 0);
            PopE       : in std_logic_vector(0 downto 0);
            PushE      : in std_logic_vector(0 downto 0);

            Branch     : out std_logic_vector(0 downto 0);
            PSP        : out std_logic_vector(31 downto 0);
            SP         : out std_logic_vector(31 downto 0);
            RdstE      : out std_logic_vector(2 downto 0);
            ImmE       : out std_logic_vector(31 downto 0);
            RD2E       : out std_logic_vector(31 downto 0);
            ExoutE     : out std_logic_vector(31 downto 0)
        );
    end component Excute_Stage;

    component WB_Stage is
        port (
            clk          : in std_logic;
            rst          : in std_logic;

            WBSelWB      : in std_logic_vector(1 downto 0);
            MemOutWB     : in std_logic_vector(31 downto 0);
            EXOutWB      : in std_logic_vector(31 downto 0);
            ImmWB        : in std_logic_vector(31 downto 0);

            RegDataWB    : out std_logic_vector(31 downto 0)
        );
    end component WB_Stage;

    ----------------------------------------------------------------
    -- Global control signals
    ----------------------------------------------------------------
    signal clk_s   : std_logic;
    signal rst_s   : std_logic := '0';
    signal stall_s : std_logic := '0';
    signal flush_s : std_logic := '0';

    ----------------------------------------------------------------
    -- IF stage signals
    ----------------------------------------------------------------
    signal IF_PC        : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_PCplus1   : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_IR        : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- IF/ID outputs
    ----------------------------------------------------------------
    signal ID_PC        : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_IR        : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- Decode (control) outputs
    ----------------------------------------------------------------
    signal ID_Opcode    : std_logic_vector(4 downto 0) := (others => '0');
    signal ID_SwapCtrl  : std_logic_vector(1 downto 0) := (others => '0');
    signal ID_IsImm     : std_logic := '0';
    signal ID_HLT       : std_logic := '0';
    signal ID_Ret       : std_logic := '0';
    signal ID_Pop       : std_logic := '0';
    signal ID_Rti       : std_logic := '0';
    signal ID_Push      : std_logic := '0';
    signal ID_Int1      : std_logic := '0';
    signal ID_Int2      : std_logic := '0';
    signal ID_Call      : std_logic := '0';
    signal ID_MemAccess : std_logic := '0';
    signal ID_MemSel    : std_logic := '0';
    signal ID_RegWrite  : std_logic := '0';
    signal ID_WbSel     : std_logic_vector(1 downto 0) := (others => '0');
    signal ID_Swap      : std_logic_vector(1 downto 0) := (others => '0');
    signal ID_MemWrite  : std_logic := '0';
    signal ID_AluOp     : std_logic_vector(3 downto 0) := (others => '0');
    signal ID_JmpZ      : std_logic := '0';
    signal ID_JmpC      : std_logic := '0';
    signal ID_JmpN      : std_logic := '0';
    signal ID_Jmp       : std_logic := '0';
    signal ID_ExOutSel  : std_logic := '0';
    signal ID_NotInc    : std_logic := '0';
    signal ID_LoadUse   : std_logic := '0';
    signal ID_OutEn     : std_logic := '0';

    ----------------------------------------------------------------
    -- ID datapath signals
    ----------------------------------------------------------------
    signal ID_RegA      : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_RegB      : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_Rsrc1     : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_Rsrc2     : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_Rdst      : std_logic_vector(2 downto 0) := (others => '0');
    signal ID_Imm       : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- ID/EX outputs (to EX)
    ----------------------------------------------------------------
    signal EX_PC        : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_RegA      : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_RegB      : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_Imm       : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_Rdst      : std_logic_vector(2 downto 0) := (others => '0');

    -- EX control signals
    signal EX_IsImm     : std_logic := '0';
    signal EX_Ret       : std_logic := '0';
    signal EX_Pop       : std_logic := '0';
    signal EX_Rti       : std_logic := '0';
    signal EX_Push      : std_logic := '0';
    signal EX_Int1      : std_logic := '0';
    signal EX_Int2      : std_logic := '0';
    signal EX_Call      : std_logic := '0';
    signal EX_MemAccess : std_logic := '0';
    signal EX_MemSel    : std_logic := '0';
    signal EX_RegWrite  : std_logic := '0';
    signal EX_WbSel     : std_logic_vector(1 downto 0) := (others => '0');
    signal EX_Swap      : std_logic_vector(1 downto 0) := (others => '0');
    signal EX_MemWrite  : std_logic := '0';
    signal EX_AluOp     : std_logic_vector(3 downto 0) := (others => '0');
    signal EX_JmpZ      : std_logic := '0';
    signal EX_JmpC      : std_logic := '0';
    signal EX_JmpN      : std_logic := '0';
    signal EX_Jmp       : std_logic := '0';
    signal EX_ExOutSel  : std_logic := '0';
    signal EX_LoadUse   : std_logic := '0';
    signal EX_OutEn     : std_logic := '0';

    ----------------------------------------------------------------
    -- EX internal signals (ALU, flags, etc.)
    ----------------------------------------------------------------
    signal EX_SrcA      : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_SrcB      : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_ALUOut    : std_logic_vector(31 downto 0) := (others => '0');
    signal EX_ZF        : std_logic := '0';
    signal EX_CF        : std_logic := '0';
    signal EX_NF        : std_logic := '0';
    signal EX_FEN       : std_logic := '0';

    ----------------------------------------------------------------
    -- EX/MEM outputs
    ----------------------------------------------------------------
    signal MEM_PC       : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_ALUOut   : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_RegB     : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_Imm      : std_logic_vector(31 downto 0) := (others => '0');
    signal MEM_Rdst     : std_logic_vector(2 downto 0) := (others => '0');

    signal MEM_Ret      : std_logic := '0';
    signal MEM_Rti      : std_logic := '0';
    signal MEM_Call     : std_logic := '0';
    signal MEM_MemAccess: std_logic := '0';
    signal MEM_MemSel   : std_logic := '0';
    signal MEM_RegWrite : std_logic := '0';
    signal MEM_WbSel    : std_logic_vector(1 downto 0) := (others => '0');
    signal MEM_MemWrite : std_logic := '0';
    signal MEM_OutEn    : std_logic := '0';
    signal MEM_Push     : std_logic := '0';
    signal MEM_Pop      : std_logic := '0';
    signal MEM_Int1     : std_logic := '0';
    signal MEM_Int2     : std_logic := '0';

    ----------------------------------------------------------------
    -- Data memory (MEM) signals
    ----------------------------------------------------------------
    signal MEM_ReadData : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- MEM/WB outputs
    ----------------------------------------------------------------
    signal WB_ALUOut    : std_logic_vector(31 downto 0) := (others => '0');
    signal WB_ReadData  : std_logic_vector(31 downto 0) := (others => '0');
    signal WB_Imm       : std_logic_vector(31 downto 0) := (others => '0');
    signal WB_Rdst      : std_logic_vector(2 downto 0) := (others => '0');
    signal WB_RegWrite  : std_logic := '0';
    signal WB_WbSel     : std_logic_vector(1 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- Final write-back data
    ----------------------------------------------------------------
    signal WB_Wdata     : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- Stack pointer / processor state
    ----------------------------------------------------------------
    signal SP_Value     : std_logic_vector(31 downto 0) := (others => '0');
    signal SP_PSP       : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- Optional auxiliary / helper signals (hazard, flush, enables)
    ----------------------------------------------------------------
    signal B1enable     : std_logic := '1';
    signal B2enable     : std_logic := '1';
    signal FLUSH        : std_logic := '0';

BEGIN

    ----------------------------------------------------------------
    -- Simple port wiring to internal signals
    -- (keep these; they let you reference clk_s/rst_s internally)
    ----------------------------------------------------------------
    clk_s <= clk;
    rst_s <= rst;

    ----------------------------------------------------------------
    -- Architecture implementation placeholder
    --
    -- Instantiate your stages and pipeline registers here:
    --   - Fetch  -> IF_ID_Register -> Decode_Stage -> ID_EX_Register
    --   - Execute (ALU) -> EX_MEM_Register -> Memory -> MEM_WB_Register -> WB_Stage
    --
    -- Example locations:
    --   -- instantiate Fetch:  FETCH_U : entity work.Fetch port map(...)
    --   -- instantiate IF/ID:  IF_ID_U : entity work.IF_ID_Register port map(...)
    --
    -- The signals declared above cover common control and datapath wires.
    ----------------------------------------------------------------

    -- << PLACE YOUR STAGE INSTANCES, PIPELINE REGISTERS, AND PROCESS LOGIC HERE >>

END ARCHITECTURE struct;
