library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cu is
   port(
      clk    : in  std_logic;
      opcode : in  std_logic_vector(4 downto 0);

      SwapCtrl      : out std_logic;
      IsImm         : out std_logic;
      HLT           : out std_logic;
      RetD          : out std_logic;
      PopD          : out std_logic;
      RtiD          : out std_logic;
      PushD         : out std_logic;
      Int1D         : out std_logic;
      Int2D         : out std_logic;
      CallD         : out std_logic;
      MemDLoadStore : out std_logic;
      MemSelD       : out std_logic;
      RegWriteEnD   : out std_logic;
      WbSelD        : out std_logic;
      SwapD         : out std_logic_vector(1 downto 0);
      MemWriteD     : out std_logic;
      AluOpD        : out std_logic_vector(3 downto 0);
      JmpZD         : out std_logic;
      JmpCD         : out std_logic;
      JmpND         : out std_logic;
      JmpD          : out std_logic;
      ExOutSelD     : out std_logic;
      NotIncSignal  : out std_logic;
      LoadUseD      : out std_logic;
      OutEnD        : out std_logic;
      hwint         : out std_logic
   );
end cu;

architecture control_unit of cu is


   -- Width constants
constant SWAPD_WIDTH      : natural := 2;
constant ALUOPD_WIDTH     : natural := 4;

   -- Opcodes (5)
   constant OPC_SWAP : std_logic_vector(4 downto 0) := "10010"; -- 15
   constant OPC_INT  : std_logic_vector(4 downto 0) := "01101"; -- 11

   constant OPC_NOP  : std_logic_vector(4 downto 0) := "00000"; -- 1
   constant OPC_HLT  : std_logic_vector(4 downto 0) := "00001"; -- 2
   constant OPC_SETC : std_logic_vector(4 downto 0) := "00010"; -- 3
   constant OPC_RET  : std_logic_vector(4 downto 0) := "00011"; -- 4
   constant OPC_RTI  : std_logic_vector(4 downto 0) := "00100"; -- 5

   constant OPC_PUSH : std_logic_vector(4 downto 0) := "01000"; -- 6
   constant OPC_POP  : std_logic_vector(4 downto 0) := "01001"; -- 7
   constant OPC_OUT  : std_logic_vector(4 downto 0) := "01010"; -- 8
   constant OPC_IN   : std_logic_vector(4 downto 0) := "01011"; -- 9

   constant OPC_CALL : std_logic_vector(4 downto 0) := "01100"; --10
   constant OPC_INC  : std_logic_vector(4 downto 0) := "01110"; --12
   constant OPC_NOT  : std_logic_vector(4 downto 0) := "01111"; --13

   constant OPC_MOV  : std_logic_vector(4 downto 0) := "10000"; --14
   constant OPC_ADD  : std_logic_vector(4 downto 0) := "10011"; --16
   constant OPC_SUB  : std_logic_vector(4 downto 0) := "10100"; --17
   constant OPC_AND  : std_logic_vector(4 downto 0) := "10101"; --18

   constant OPC_JZ   : std_logic_vector(4 downto 0) := "11000"; --19
   constant OPC_JN   : std_logic_vector(4 downto 0) := "11001"; --20
   constant OPC_JC   : std_logic_vector(4 downto 0) := "11010"; --21
   constant OPC_JMP  : std_logic_vector(4 downto 0) := "11011"; --22

   constant OPC_IADD : std_logic_vector(4 downto 0) := "11100"; --23
   constant OPC_LDM  : std_logic_vector(4 downto 0) := "11101"; --24
   constant OPC_LDD  : std_logic_vector(4 downto 0) := "11110"; --25
   constant OPC_STD  : std_logic_vector(4 downto 0) := "11111"; --26

   -- ALU opcodes (4)
   constant ALU_NOP       : std_logic_vector(3 downto 0) := "0000";
   constant ALU_ADD       : std_logic_vector(3 downto 0) := "0001";
   constant ALU_SUB       : std_logic_vector(3 downto 0) := "0010";
   constant ALU_AND       : std_logic_vector(3 downto 0) := "0011";
   constant ALU_NOT       : std_logic_vector(3 downto 0) := "0100";
   constant ALU_INC       : std_logic_vector(3 downto 0) := "0101";
   constant ALU_R1        : std_logic_vector(3 downto 0) := "1001";
   constant ALU_R2        : std_logic_vector(3 downto 0) := "1010";
   constant ALU_ADD_PLUS2 : std_logic_vector(3 downto 0) := "1110";
   constant ALU_SET_C     : std_logic_vector(3 downto 0) := "1101";

   -- FSM-registered override outputs
   signal SwapCtrl_reg        : std_logic := '0';
   signal SwapD_reg           : std_logic_vector(SWAPD_WIDTH-1 downto 0) := (others => '0');
   signal RegWrite_override   : std_logic := '0';

   signal Int1_reg            : std_logic := '0';
   signal Int2_reg            : std_logic := '0';
   signal MemWrite_override   : std_logic := '0';
   signal AluOp_override      : std_logic_vector(ALUOPD_WIDTH-1 downto 0) := (others => '0');

   -- intermediate combinational outputs
   signal comb_IsImm        : std_logic := '0';
   signal comb_HLT          : std_logic := '0';
   signal comb_RetD         : std_logic := '0';
   signal comb_PopD         : std_logic := '0';
   signal comb_RtiD         : std_logic := '0';
   signal comb_PushD        : std_logic := '0';
   signal comb_CallD        : std_logic := '0';
   signal comb_MemDLoadStore: std_logic := '0';
   signal comb_MemSelD      : std_logic := '1'; -- default not store
   signal comb_RegWriteEnD  : std_logic := '0';
   signal comb_WbSelD       : std_logic := '0';
   signal comb_MemWriteD    : std_logic := '0';
   signal comb_AluOpD       : std_logic_vector(ALUOPD_WIDTH-1 downto 0) := (others => '0');
   signal comb_JmpZD        : std_logic := '0';
   signal comb_JmpCD        : std_logic := '0';
   signal comb_JmpND        : std_logic := '0';
   signal comb_JmpD         : std_logic := '0';
   signal comb_ExOutSelD    : std_logic := '0';
   signal comb_NotIncSignal : std_logic := '0';
   signal comb_LoadUseD     : std_logic := '0';
   signal comb_OutEnD       : std_logic := '0';

begin

   ----------------------------------------------------------------
   -- Combinational decoder
   ----------------------------------------------------------------
   comb_decode: process(opcode)
   begin
      -- defaults
      comb_IsImm         <= '0';
      comb_HLT           <= '0';
      comb_RetD          <= '0';
      comb_PopD          <= '0';
      comb_RtiD          <= '0';
      comb_PushD         <= '0';
      comb_CallD         <= '0';
      comb_MemDLoadStore <= '0';
      comb_MemSelD       <= '1'; -- not store by default
      comb_RegWriteEnD   <= '0';
      comb_WbSelD        <=  '0';
      comb_MemWriteD     <= '0';
      comb_AluOpD        <= (others => '0');
      comb_JmpZD         <= '0';
      comb_JmpCD         <= '0';
      comb_JmpND         <= '0';
      comb_JmpD          <= '0';
      comb_ExOutSelD     <= '0';
      comb_NotIncSignal  <= '0';
      comb_LoadUseD      <= '0';
      comb_OutEnD        <= '0';

      -- Mapping
      case opcode is
         when OPC_NOP =>
            null;

         when OPC_HLT =>
            comb_HLT <= '1';

         when OPC_SETC =>
            comb_AluOpD <= ALU_SET_C;

         when OPC_RET =>
            comb_RetD <= '1';

         when OPC_RTI =>
            comb_RtiD <= '1';

         when OPC_PUSH =>
            comb_PushD <= '1';
            comb_MemWriteD <= '1';
            comb_MemSelD <= '0'; -- store
            comb_AluOpD <= ALU_R2;

         when OPC_POP =>
            comb_PopD <= '1';
            comb_MemWriteD <= '0';
            comb_RegWriteEnD <= '1';
               comb_WbSelD <= '1';
            comb_LoadUseD <= '1';

         when OPC_OUT =>
            comb_OutEnD <= '1';
            comb_AluOpD <= ALU_R1;

         when OPC_IN =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_ExOutSelD <= '1';

         when OPC_CALL =>
            comb_CallD <= '1';
            comb_IsImm <= '1';
            comb_MemWriteD <= '1';
            comb_MemSelD <= '1';

         when OPC_INC =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_NotIncSignal <= '1';
            comb_AluOpD <= ALU_INC;

         when OPC_NOT =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_NotIncSignal <= '1';
            comb_AluOpD <= ALU_NOT;

         when OPC_MOV =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_AluOpD <= ALU_R1;

         when OPC_ADD =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_AluOpD <= ALU_ADD;

         when OPC_SUB =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_AluOpD <= ALU_SUB;

         when OPC_AND =>
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_AluOpD <= ALU_AND;

         when OPC_JZ =>
            comb_JmpZD <= '1';
            comb_IsImm <= '1';
            comb_AluOpD <= ALU_NOP;

         when OPC_JN =>
            comb_JmpND <= '1';
            comb_IsImm <= '1';
            comb_AluOpD <= ALU_NOP;

         when OPC_JC =>
            comb_JmpCD <= '1';
            comb_IsImm <= '1';
            comb_AluOpD <= ALU_NOP;

         when OPC_JMP =>
            comb_JmpD <= '1';
            comb_IsImm <= '1';
            comb_AluOpD <= ALU_NOP;

         when OPC_IADD =>
            comb_IsImm <= '1';
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_AluOpD <= ALU_ADD;

         when OPC_LDM =>
            comb_IsImm <= '1';
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '0';
            comb_AluOpD <= ALU_R2;
         when OPC_LDD =>
            comb_IsImm <= '1';
            comb_MemDLoadStore <= '1';
            comb_MemWriteD <= '0';
            comb_RegWriteEnD <= '1';
            comb_WbSelD <= '1';
            comb_LoadUseD <= '1';
            comb_AluOpD <= ALU_ADD;

         when OPC_STD =>
            comb_IsImm <= '1';
            comb_MemDLoadStore <= '1';
            comb_MemWriteD <= '1';
            comb_MemSelD <= '0';
            comb_AluOpD <= ALU_ADD;
   
         when OPC_INT =>
            comb_IsImm <= '1';
            -- actual INT effects (mem/alu) come from FSM overrides

         when others =>
            null;
      end case;
   end process comb_decode;

   ----------------------------------------------------------------
   -- FSM process (registered) producing overrides.
   -- Transition: 0 -> 1 -> 2 -> 0
   -- Detection: swap_req/int_req reflect opcode at the clock edge.
   ----------------------------------------------------------------
   fsm_proc: process(clk)

   variable swap_state : integer range 0 to 2 := 0;
   variable int_state  : integer range 0 to 2 := 0;
   variable hwint_state    : std_logic := '0';

   begin
   SwapD_reg <= (others => '0');
   SwapCtrl_reg <= '0'; 
   RegWrite_override <= '0';
   AluOp_override <= (others => '0');
      if rising_edge(clk) then
         -- SWAP FSM
         if swap_state = 0 then
            if opcode = OPC_SWAP then
               swap_state := 1;
            else
               swap_state := 0;
            end if;
         elsif swap_state = 1 then
            swap_state := 2;
         elsif swap_state = 2 and opcode = OPC_SWAP then
            swap_state := 1;
         else
            swap_state := 0;
         end if;

         -- INT FSM
         if int_state = 0 then
            if opcode = OPC_INT then
               int_state := 1;
            else
               int_state := 0;
            end if;
         elsif int_state = 1 then
            int_state := 2;
         else -- int_state = 2
            int_state := 0;
         end if;

          -- hwint FSM
         if hwint_state = 0 then
            if hwint = '1' then
               hwint_state := 1;
            else
               hwint_state := 0;
            end if;
         elsif hwint_state = 1 then
            hwint_state := 2;
         else -- int_state = 2
            hwint_state := 0;
         end if;

         -- SWAP overrides (phase1: "01", phase2: "10")
         if swap_state = 0 and int_state = 0 then
            SwapD_reg <= (others => '0');
            SwapCtrl_reg <= '0';
            RegWrite_override <= '0';
            AluOp_override <= (others => '0');
         elsif swap_state = 1 and int_state = 0 then
            -- phase1
            SwapD_reg <= std_logic_vector(to_unsigned(1, SWAPD_WIDTH)); -- "01"
            SwapCtrl_reg <= '1';
            RegWrite_override <= '1'; -- SWAP is WB both cycles
            AluOp_override <= ALU_R2;
         elsif swap_state = 2 and int_state = 0 then
            -- phase2
            SwapD_reg <= std_logic_vector(to_unsigned(2, SWAPD_WIDTH)); -- "10"
            SwapCtrl_reg <= '0';
            RegWrite_override <= '1'; -- still WB
            AluOp_override <= ALU_R1;
         end if;

         -- INT overrides (phase1: Int1=1, Int2=0, mem store; phase2: Int1=0, Int2=1, memread + ALU_ADD_PLUS2)
         if int_state = 0 then
            Int1_reg <= '0';
            Int2_reg <= '0';
            MemWrite_override <= '0';
         elsif int_state = 1 then
            -- phase1
            Int1_reg <= '1';
            Int2_reg <= '0';
            MemWrite_override <= '1'; -- store
            AluOp_override <= (others => '0');
         else
            -- phase2
            Int1_reg <= '0';
            Int2_reg <= '1';
            MemWrite_override <= '0';
            AluOp_override <= ALU_ADD_PLUS2; -- perform +2 on index ig
         end if;
-- INT overrides (phase1: Int1=1, Int2=0, mem store; phase2: Int1=0, Int2=1, memread + ALU_ADD_PLUS2)
         if int_state = 0 then
            Int1_reg <= '0';
            Int2_reg <= '0';
            MemWrite_override <= '0';
         elsif int_state = 1 then
            -- phase1
            Int1_reg <= '1';
            Int2_reg <= '0';
            MemWrite_override <= '1'; -- store
            AluOp_override <= (others => '0');
         else
            -- phase2
            Int1_reg <= '0';
            Int2_reg <= '1';
            MemWrite_override <= '0';
            AluOp_override <= ALU_ADD_PLUS2; -- perform +2 on index ig
         end if;
         

      end if;
   end process fsm_proc;

   ----------------------------------------------------------------
   -- Final outputs
   ----------------------------------------------------------------

   -- Direct FSM outputs
   SwapCtrl <= SwapCtrl_reg;
   SwapD    <= SwapD_reg;
   Int1D    <= Int1_reg;
   Int2D    <= Int2_reg;

   -- Simple OR combinations
   RegWriteEnD <= comb_RegWriteEnD or RegWrite_override;
   MemDLoadStore <= comb_MemDLoadStore;
   MemWriteD <= comb_MemWriteD or MemWrite_override;

   -- For AluOp: override if non-zero, else combinational
   AluOpD <= AluOp_override when (SwapD_reg = "01" or SwapD_reg = "10" or Int1_reg = '1' or Int2_reg = '1') else comb_AluOpD;

   -- Remaining outputs come straight from combinational decode (these are unaffected by FSM, except where we used overrides above)
   IsImm       <= comb_IsImm;
   HLT         <= comb_HLT;
   RetD        <= comb_RetD;
   PopD        <= comb_PopD;
   RtiD        <= comb_RtiD;
   PushD       <= comb_PushD;
   CallD       <= comb_CallD;
   MemSelD     <= comb_MemSelD;
   WbSelD      <= comb_WbSelD;
   JmpZD       <= comb_JmpZD;
   JmpCD       <= comb_JmpCD;
   JmpND       <= comb_JmpND;
   JmpD        <= comb_JmpD;
   ExOutSelD   <= comb_ExOutSelD;
   NotIncSignal<= comb_NotIncSignal;
   LoadUseD    <= comb_LoadUseD;
   OutEnD      <= comb_OutEnD;

end control_unit;


