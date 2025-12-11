LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CPU IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        swInt : IN STD_LOGIC;
        inPort : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        outPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE struct OF CPU IS
    -- Signal and component declarations
    component Memory is
    port (
        clk        : in  std_logic;
        WriteEnable: in  std_logic;
        Address    : in  std_logic_vector(31 downto 0);
        WriteData  : in  std_logic_vector(31 downto 0);

        ReadData   : out std_logic_vector(31 downto 0)
    );
    end component;

    component RegFile is
    port(
        clk, rst      : in std_logic := '0';
        RegWriteEn    : in std_logic := '0';                  
        wa            : in std_logic_vector(2 downto 0) := "000"; 
        w_data        : in std_logic_vector(31 downto 0) := x"0000_0000";
        ra_1, ra_2    : in std_logic_vector(2 downto 0) := "000"; 

        r_data1, r_data2 : out std_logic_vector(31 downto 0) := x"0000_0000"
    );
    end component;
    component IF_ID_Register is
        port(
            clk, rst     : in std_logic := '0';
            enable       : in std_logic := '1';
            flush        : in std_logic := '0';

            instruction_F   : in std_logic_vector(31 downto 0);
            pc1_F           : in std_logic_vector(31 downto 0);

            instruction_D   : out std_logic_vector(31 downto 0);
            pc1_D           : out std_logic_vector(31 downto 0)
        );
    end component;

    component ID_EX_Register is
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
            MEMD            : in std_logic := '0';
            MemSelD         : in std_logic := '0';
            RegWriteEnD     : in std_logic := '0';
            WbSelD          : in std_logic_vector(1 downto 0) := "00";
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
            WbSel_E         : out std_logic_vector(1 downto 0) := "00";
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
    end component;

    component EX_MEM_Register is
        port(
            clk, rst        : in std_logic := '0';
            enable          : in std_logic := '1';
            flush           : in std_logic := '0';

            ExOutE          : in std_logic_vector(31 downto 0) := x"0000_0000";
            RD2_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            PC1_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            PSP_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            Imm_E           : in std_logic_vector(31 downto 0) := x"0000_0000";
            Rdst_E          : in std_logic_vector(2 downto 0) := "000";
            RETE            : in std_logic := '0';
            RTIE            : in std_logic := '0';
            CALLE           : in std_logic := '0';
            MEM_E           : in std_logic := '0';
            MemSel_E        : in std_logic := '0';
            RegWriteEn_E    : in std_logic := '0';
            WbSel_E         : in std_logic_vector(1 downto 0) := "00";
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
            Imm_M           : out std_logic_vector(31 downto 0) := x"0000_0000";
            Rdst_M          : out std_logic_vector(2 downto 0) := "000";
            RET_M           : out std_logic := '0';
            RTI_M           : out std_logic := '0';
            CALL_M          : out std_logic := '0';
            MEM_M           : out std_logic := '0';
            MemSel_M        : out std_logic := '0';
            RegWriteEn_M    : out std_logic := '0';
            WbSel_M         : out std_logic_vector(1 downto 0) := "00";
            MemWrite_M      : out std_logic := '0';
            OutEn_M         : out std_logic := '0';
            PUSH_M          : out std_logic := '0';
            POP_M           : out std_logic := '0';
            INT1_M          : out std_logic := '0';
            INT2_M          : out std_logic := '0'
        );
    end component;

    component MEM_WB_Register is
        port(
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
    end component;

        component Decode_Stage  IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            RSrc1D  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            RSrc2D  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); 

            SwapCtrl      : out std_logic_vector(1-1 downto 0);
            IsImm         : out std_logic_vector(1-1 downto 0);
            HLT           : out std_logic_vector(1-1 downto 0);
            RetD          : out std_logic_vector(1-1 downto 0);
            PopD          : out std_logic_vector(1-1 downto 0);
            RtiD          : out std_logic_vector(1-1 downto 0);
            PushD         : out std_logic_vector(1-1 downto 0);
            Int1D         : out std_logic_vector(1-1 downto 0);
            Int2D         : out std_logic_vector(1-1 downto 0);
            CallD         : out std_logic_vector(1-1 downto 0);
            MemDLoadStore : out std_logic_vector(1-1 downto 0);
            MemSelD       : out std_logic_vector(1-1 downto 0);
            RegWriteEnD   : out std_logic_vector(1-1 downto 0);
            WbSelD        : out std_logic_vector(2-1 downto 0);
            SwapD         : out std_logic_vector(2-1 downto 0);
            MemWriteD     : out std_logic_vector(1-1 downto 0);
            AluOpD        : out std_logic_vector(4-1 downto 0);
            JmpZD         : out std_logic_vector(1-1 downto 0);
            JmpCD         : out std_logic_vector(1-1 downto 0);
            JmpND         : out std_logic_vector(1-1 downto 0);
            JmpD          : out std_logic_vector(1-1 downto 0);
            ExOutSelD     : out std_logic_vector(1-1 downto 0);
            LoadUseD      : out std_logic_vector(1-1 downto 0);
            OutEnD        : out std_logic_vector(1-1 downto 0)
        );
    END component;

    component Memory_Fetch_Stages IS
        PORT (
            clk : IN STD_LOGIC;
            reset,interrupt : IN STD_LOGIC;

            Branch  : IN STD_LOGIC;
            SwapCtrl : IN STD_LOGIC;
            HLT    : IN STD_LOGIC;

            RETM  : IN STD_LOGIC;
            POPM  : IN STD_LOGIC;
            RTIM  : IN STD_LOGIC;
            PUSHM : IN STD_LOGIC;
            INT1M : IN STD_LOGIC;
            INT2M : IN STD_LOGIC;
            CALLM : IN STD_LOGIC;

            MemM        : IN STD_LOGIC;
            MemSelM     : IN STD_LOGIC;
            RegWriteENM : IN STD_LOGIC;

            PC1M  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            OutEnM : IN STD_LOGIC;
            ExOutM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RD2M   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ImmM   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RdstM  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            PSPM   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            SP     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            ImmE    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            RegWriteEnWM : OUT STD_LOGIC;
            EXOutWM      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ImmWM        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            RdstWM       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            outPort      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            MemAddr           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MemWriteData      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            PC1f : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END component;
    
    component Excute_Stage  IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;

            RD1     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RD2     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RSrc1D  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            RSrc2D  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ImmD    : IN std_logic_vector(31 downto 0);
            InputPort : IN std_logic_vector(31 downto 0);
            interrupt  : IN std_logic_vector(0 downto 0);

            SwapE         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            AluOpE        : IN std_logic_vector(3 downto 0);
            JmpZDE        : IN std_logic_vector(0 downto 0);
            JmpCE         : IN std_logic_vector(0 downto 0);
            JmpNE         : IN std_logic_vector(0 downto 0);
            JmpE          : IN std_logic_vector(0 downto 0);
            IsImmE        : IN std_logic_vector(0 downto 0);
            ExOutSelE     : IN std_logic_vector(0 downto 0);
            LoadUseE      : IN std_logic_vector(0 downto 0);

            CallE         : IN std_logic_vector(0 downto 0);
            RtiE          : IN std_logic_vector(0 downto 0);
            RetE          : IN std_logic_vector(0 downto 0);
            Int1E         : IN std_logic_vector(0 downto 0);
            PopE          : IN std_logic_vector(0 downto 0);
            PushE         : IN std_logic_vector(0 downto 0);

            Branch        : OUT std_logic_vector(0 downto 0);
            PSP           : out  std_logic_vector(31 downto 0);
            SP            : out std_logic_vector(31 downto 0);
            RdstE         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            ImmE          : OUT std_logic_vector(31 downto 0);
            RD2E          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ExoutE        : OUT std_logic_vector(31 downto 0)
        );
    END component;

    component WB_Stage IS
        PORT (
            clk          : IN STD_LOGIC;
            rst          : IN STD_LOGIC;

            WBSelWB      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            
            MemOutWB     : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
            EXOutWB      : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
            ImmWB        : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 

            RegDataWB    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END component;


    ----------------------------------------------------------------
    -- Global Control Signals
    ----------------------------------------------------------------
    signal clk_s     : std_logic;
    signal rst_s     : std_logic := '0';
    signal stall_s   : std_logic := '0';
    signal flush_s   : std_logic := '0';

    ----------------------------------------------------------------
    -- IF Stage
    ----------------------------------------------------------------
    signal IF_PC          : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_PCplus1     : std_logic_vector(31 downto 0) := (others => '0');
    signal IF_IR          : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- IF/ID Pipeline Register Outputs
    ----------------------------------------------------------------
    signal ID_PC          : std_logic_vector(31 downto 0) := (others => '0');
    signal ID_IR          : std_logic_vector(31 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- Control Unit Outputs (Decode Stage Controls)
    ----------------------------------------------------------------
    signal ID_Opcode      : std_logic_vector(4 downto 0);
    signal ID_SwapCtrl    : std_logic_vector(1 downto 0);
    signal ID_IsImm       : std_logic;
    signal ID_HLT         : std_logic;
    signal ID_Ret         : std_logic;
    signal ID_Pop         : std_logic;
    signal ID_Rti         : std_logic;
    signal ID_Push        : std_logic;
    signal ID_Int1        : std_logic;
    signal ID_Int2        : std_logic;
    signal ID_Call        : std_logic;
    signal ID_MemAccess   : std_logic;
    signal ID_MemSel      : std_logic;
    signal ID_RegWrite    : std_logic;
    signal ID_WbSel       : std_logic_vector(1 downto 0);
    signal ID_Swap        : std_logic_vector(1 downto 0);
    signal ID_MemWrite    : std_logic;
    signal ID_AluOp       : std_logic_vector(3 downto 0);
    signal ID_JmpZ        : std_logic;
    signal ID_JmpC        : std_logic;
    signal ID_JmpN        : std_logic;
    signal ID_Jmp         : std_logic;
    signal ID_ExOutSel    : std_logic;
    signal ID_NotInc      : std_logic;
    signal ID_LoadUse     : std_logic;
    signal ID_OutEn       : std_logic;

    ----------------------------------------------------------------
    -- ID Stage Datapath Signals
    ----------------------------------------------------------------
    signal ID_RegA        : std_logic_vector(31 downto 0);
    signal ID_RegB        : std_logic_vector(31 downto 0);
    signal ID_Rsrc1       : std_logic_vector(2 downto 0);
    signal ID_Rsrc2       : std_logic_vector(2 downto 0);
    signal ID_Rdst        : std_logic_vector(2 downto 0);
    signal ID_Imm         : std_logic_vector(31 downto 0);

    ----------------------------------------------------------------
    -- ID/EX Pipeline Register Outputs
    ----------------------------------------------------------------
    signal EX_PC          : std_logic_vector(31 downto 0);
    signal EX_RegA        : std_logic_vector(31 downto 0);
    signal EX_RegB        : std_logic_vector(31 downto 0);
    signal EX_Imm         : std_logic_vector(31 downto 0);
    signal EX_Rdst        : std_logic_vector(2 downto 0);

    -- EX control signals
    signal EX_IsImm       : std_logic;
    signal EX_Ret         : std_logic;
    signal EX_Pop         : std_logic;
    signal EX_Rti         : std_logic;
    signal EX_Push        : std_logic;
    signal EX_Int1        : std_logic;
    signal EX_Int2        : std_logic;
    signal EX_Call        : std_logic;
    signal EX_MemAccess   : std_logic;
    signal EX_MemSel      : std_logic;
    signal EX_RegWrite    : std_logic;
    signal EX_WbSel       : std_logic_vector(1 downto 0);
    signal EX_Swap        : std_logic_vector(1 downto 0);
    signal EX_MemWrite    : std_logic;
    signal EX_AluOp       : std_logic_vector(3 downto 0);
    signal EX_JmpZ        : std_logic;
    signal EX_JmpC        : std_logic;
    signal EX_JmpN        : std_logic;
    signal EX_Jmp         : std_logic;
    signal EX_ExOutSel    : std_logic;
    signal EX_LoadUse     : std_logic;
    signal EX_OutEn       : std_logic;

    ----------------------------------------------------------------
    -- EX Stage Internal Signals
    ----------------------------------------------------------------
    signal EX_SrcA        : std_logic_vector(31 downto 0);
    signal EX_SrcB        : std_logic_vector(31 downto 0);
    signal EX_ALUOut      : std_logic_vector(31 downto 0);
    signal EX_ZF          : std_logic;
    signal EX_CF          : std_logic;
    signal EX_NF          : std_logic;
    signal EX_FEN         : std_logic;

    ----------------------------------------------------------------
    -- EX/MEM Pipeline Register Outputs
    ----------------------------------------------------------------
    signal MEM_PC         : std_logic_vector(31 downto 0);
    signal MEM_ALUOut     : std_logic_vector(31 downto 0);
    signal MEM_RegB       : std_logic_vector(31 downto 0);
    signal MEM_Imm        : std_logic_vector(31 downto 0);
    signal MEM_Rdst       : std_logic_vector(2 downto 0);

    signal MEM_Ret        : std_logic;
    signal MEM_Rti        : std_logic;
    signal MEM_Call       : std_logic;
    signal MEM_MemAccess  : std_logic;
    signal MEM_MemSel     : std_logic;
    signal MEM_RegWrite   : std_logic;
    signal MEM_WbSel      : std_logic_vector(1 downto 0);
    signal MEM_MemWrite   : std_logic;
    signal MEM_OutEn      : std_logic;
    signal MEM_Push       : std_logic;
    signal MEM_Pop        : std_logic;
    signal MEM_Int1       : std_logic;
    signal MEM_Int2       : std_logic;

    ----------------------------------------------------------------
    -- Data Memory Output
    ----------------------------------------------------------------
    signal MEM_ReadData   : std_logic_vector(31 downto 0);

    ----------------------------------------------------------------
    -- MEM/WB Pipeline Register Outputs
    ----------------------------------------------------------------
    signal WB_ALUOut      : std_logic_vector(31 downto 0);
    signal WB_ReadData    : std_logic_vector(31 downto 0);
    signal WB_Imm         : std_logic_vector(31 downto 0);
    signal WB_Rdst        : std_logic_vector(2 downto 0);
    signal WB_RegWrite    : std_logic;
    signal WB_WbSel       : std_logic_vector(1 downto 0);

    ----------------------------------------------------------------
    -- Final Write-Back Multiplexed Data
    ----------------------------------------------------------------
    signal WB_Wdata       : std_logic_vector(31 downto 0);

    ----------------------------------------------------------------
    -- Stack Pointer and Processor State
    ----------------------------------------------------------------
    signal SP_Value       : std_logic_vector(31 downto 0);
    signal SP_PSP         : std_logic_vector(31 downto 0);


begin
    -- CPU architecture implementation goes here
    ----------------------------------------------------------------
    -- Simple port to internal signal wiring
    ----------------------------------------------------------------
    clk_s <= clk;
    rst_s <= rst;


END ARCHITECTURE;