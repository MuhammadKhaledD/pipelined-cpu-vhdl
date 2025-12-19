-- cu_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity cu_tb is
end cu_tb;

architecture testbench of cu_tb is
   -- Component declaration
   component cu is
      port(
         clk    : in  std_logic;
         opcode : in  std_logic_vector(4 downto 0);
         SwapCtrl      : out std_logic_vector(0 downto 0);
         IsImm         : out std_logic_vector(0 downto 0);
         HLT           : out std_logic_vector(0 downto 0);
         RetD          : out std_logic_vector(0 downto 0);
         PopD          : out std_logic_vector(0 downto 0);
         RtiD          : out std_logic_vector(0 downto 0);
         PushD         : out std_logic_vector(0 downto 0);
         Int1D         : out std_logic_vector(0 downto 0);
         Int2D         : out std_logic_vector(0 downto 0);
         CallD         : out std_logic_vector(0 downto 0);
         MemDLoadStore : out std_logic_vector(0 downto 0);
         MemSelD       : out std_logic_vector(0 downto 0);
         RegWriteEnD   : out std_logic_vector(0 downto 0);
         WbSelD        : out std_logic;
         SwapD         : out std_logic_vector(1 downto 0);
         MemWriteD     : out std_logic_vector(0 downto 0);
         AluOpD        : out std_logic_vector(3 downto 0);
         JmpZD         : out std_logic_vector(0 downto 0);
         JmpCD         : out std_logic_vector(0 downto 0);
         JmpND         : out std_logic_vector(0 downto 0);
         JmpD          : out std_logic_vector(0 downto 0);
         ExOutSelD     : out std_logic_vector(0 downto 0);
         NotIncSignal  : out std_logic_vector(0 downto 0);
         LoadUseD      : out std_logic_vector(0 downto 0);
         OutEnD        : out std_logic_vector(0 downto 0)
      );
   end component;

   -- Test signals
   signal clk           : std_logic := '0';
   signal opcode        : std_logic_vector(4 downto 0) := (others => '0');
   signal SwapCtrl      : std_logic_vector(0 downto 0);
   signal IsImm         : std_logic_vector(0 downto 0);
   signal HLT           : std_logic_vector(0 downto 0);
   signal RetD          : std_logic_vector(0 downto 0);
   signal PopD          : std_logic_vector(0 downto 0);
   signal RtiD          : std_logic_vector(0 downto 0);
   signal PushD         : std_logic_vector(0 downto 0);
   signal Int1D         : std_logic_vector(0 downto 0);
   signal Int2D         : std_logic_vector(0 downto 0);
   signal CallD         : std_logic_vector(0 downto 0);
   signal MemDLoadStore : std_logic_vector(0 downto 0);
   signal MemSelD       : std_logic_vector(0 downto 0);
   signal RegWriteEnD   : std_logic_vector(0 downto 0);
   signal WbSelD        : std_logic;
   signal SwapD         : std_logic_vector(1 downto 0);
   signal MemWriteD     : std_logic_vector(0 downto 0);
   signal AluOpD        : std_logic_vector(3 downto 0);
   signal JmpZD         : std_logic_vector(0 downto 0);
   signal JmpCD         : std_logic_vector(0 downto 0);
   signal JmpND         : std_logic_vector(0 downto 0);
   signal JmpD          : std_logic_vector(0 downto 0);
   signal ExOutSelD     : std_logic_vector(0 downto 0);
   signal NotIncSignal  : std_logic_vector(0 downto 0);
   signal LoadUseD      : std_logic_vector(0 downto 0);
   signal OutEnD        : std_logic_vector(0 downto 0);

   -- Clock period
   constant clk_period : time := 10 ns;
   signal stop_sim : boolean := false;

   -- Test counters
   signal test_num : integer := 0;
   signal pass_count : integer := 0;
   signal fail_count : integer := 0;

   -- Opcodes constants
   constant OPC_NOP  : std_logic_vector(4 downto 0) := "00000";
   constant OPC_HLT  : std_logic_vector(4 downto 0) := "00001";
   constant OPC_SETC : std_logic_vector(4 downto 0) := "00010";
   constant OPC_RET  : std_logic_vector(4 downto 0) := "00011";
   constant OPC_RTI  : std_logic_vector(4 downto 0) := "00100";
   constant OPC_PUSH : std_logic_vector(4 downto 0) := "01000";
   constant OPC_POP  : std_logic_vector(4 downto 0) := "01001";
   constant OPC_OUT  : std_logic_vector(4 downto 0) := "01010";
   constant OPC_IN   : std_logic_vector(4 downto 0) := "01011";
   constant OPC_CALL : std_logic_vector(4 downto 0) := "01100";
   constant OPC_INT  : std_logic_vector(4 downto 0) := "01101";
   constant OPC_INC  : std_logic_vector(4 downto 0) := "01110";
   constant OPC_NOT  : std_logic_vector(4 downto 0) := "01111";
   constant OPC_MOV  : std_logic_vector(4 downto 0) := "10000";
   constant OPC_SWAP : std_logic_vector(4 downto 0) := "10010";
   constant OPC_ADD  : std_logic_vector(4 downto 0) := "10011";
   constant OPC_SUB  : std_logic_vector(4 downto 0) := "10100";
   constant OPC_AND  : std_logic_vector(4 downto 0) := "10101";
   constant OPC_JZ   : std_logic_vector(4 downto 0) := "11000";
   constant OPC_JN   : std_logic_vector(4 downto 0) := "11001";
   constant OPC_JC   : std_logic_vector(4 downto 0) := "11010";
   constant OPC_JMP  : std_logic_vector(4 downto 0) := "11011";
   constant OPC_IADD : std_logic_vector(4 downto 0) := "11100";
   constant OPC_LDM  : std_logic_vector(4 downto 0) := "11101";
   constant OPC_LDD  : std_logic_vector(4 downto 0) := "11110";
   constant OPC_STD  : std_logic_vector(4 downto 0) := "11111";

   -- ALU opcodes
   constant ALU_NOP       : std_logic_vector(3 downto 0) := "0000";
   constant ALU_ADD       : std_logic_vector(3 downto 0) := "0001";
   constant ALU_SUB       : std_logic_vector(3 downto 0) := "0010";
   constant ALU_AND       : std_logic_vector(3 downto 0) := "0011";
   constant ALU_NOT       : std_logic_vector(3 downto 0) := "0100";
   constant ALU_INC       : std_logic_vector(3 downto 0) := "0101";
   constant ALU_R1        : std_logic_vector(3 downto 0) := "1001";
   constant ALU_R2        : std_logic_vector(3 downto 0) := "1010";
   constant ALU_SET_C     : std_logic_vector(3 downto 0) := "1101";
   constant ALU_ADD_PLUS2 : std_logic_vector(3 downto 0) := "1110";

   -- Helper procedure for checking results
   procedure check_signal(
      signal sig : in std_logic_vector;
      expected : in std_logic_vector;
      name : in string;
      signal pass_cnt : inout integer;
      signal fail_cnt : inout integer
   ) is
   begin
      if sig = expected then
         pass_cnt <= pass_cnt + 1;
      else
         fail_cnt <= fail_cnt + 1;
         report "FAIL: " & name & " expected " & 
                integer'image(to_integer(unsigned(expected))) & 
                " got " & integer'image(to_integer(unsigned(sig))) severity warning;
      end if;
   end procedure;

   procedure check_signal_bit(
      signal sig : in std_logic;
      expected : in std_logic;
      name : in string;
      signal pass_cnt : inout integer;
      signal fail_cnt : inout integer
   ) is
   begin
      if sig = expected then
         pass_cnt <= pass_cnt + 1;
      else
         fail_cnt <= fail_cnt + 1;
         report "FAIL: " & name & " expected " & std_logic'image(expected) & 
                " got " & std_logic'image(sig) severity warning;
      end if;
   end procedure;

begin
   -- Instantiate DUT
   dut: cu
      port map (
         clk           => clk,
         opcode        => opcode,
         SwapCtrl      => SwapCtrl,
         IsImm         => IsImm,
         HLT           => HLT,
         RetD          => RetD,
         PopD          => PopD,
         RtiD          => RtiD,
         PushD         => PushD,
         Int1D         => Int1D,
         Int2D         => Int2D,
         CallD         => CallD,
         MemDLoadStore => MemDLoadStore,
         MemSelD       => MemSelD,
         RegWriteEnD   => RegWriteEnD,
         WbSelD        => WbSelD,
         SwapD         => SwapD,
         MemWriteD     => MemWriteD,
         AluOpD        => AluOpD,
         JmpZD         => JmpZD,
         JmpCD         => JmpCD,
         JmpND         => JmpND,
         JmpD          => JmpD,
         ExOutSelD     => ExOutSelD,
         NotIncSignal  => NotIncSignal,
         LoadUseD      => LoadUseD,
         OutEnD        => OutEnD
      );

   -- Clock generation
   clk_process: process
   begin
      while not stop_sim loop
         clk <= '0';
         wait for clk_period/2;
         clk <= '1';
         wait for clk_period/2;
      end loop;
      wait;
   end process;

   -- Test process
   test_proc: process
   begin
      report "==== Starting Control Unit Testbench ====";
      
      -- Wait for initial stability
      wait for clk_period * 2;

      -- ========================================
      -- Test 1: NOP Instruction
      -- ========================================
      test_num <= 1;
      report "Test 1: NOP Instruction";
      opcode <= OPC_NOP;
      wait for clk_period/10;
      check_signal(AluOpD, ALU_NOP, "NOP AluOpD", pass_count, fail_count);
      check_signal(RegWriteEnD, "0", "NOP RegWriteEnD", pass_count, fail_count);
      check_signal(MemWriteD, "0", "NOP MemWriteD", pass_count, fail_count);

      -- ========================================
      -- Test 2: HLT Instruction
      -- ========================================
      test_num <= 2;
      report "Test 2: HLT Instruction";
      opcode <= OPC_HLT;
      wait for clk_period/10;
      check_signal(HLT, "1", "HLT signal", pass_count, fail_count);

      -- ========================================
      -- Test 3: SETC Instruction
      -- ========================================
      test_num <= 3;
      report "Test 3: SETC Instruction";
      opcode <= OPC_SETC;
      wait for clk_period/10;
      check_signal(AluOpD, ALU_SET_C, "SETC AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 4: RET Instruction
      -- ========================================
      test_num <= 4;
      report "Test 4: RET Instruction";
      opcode <= OPC_RET;
      wait for clk_period/10;
      check_signal(RetD, "1", "RET RetD", pass_count, fail_count);

      -- ========================================
      -- Test 5: RTI Instruction
      -- ========================================
      test_num <= 5;
      report "Test 5: RTI Instruction";
      opcode <= OPC_RTI;
      wait for clk_period/10;
      check_signal(RtiD, "1", "RTI RtiD", pass_count, fail_count);

      -- ========================================
      -- Test 6: PUSH Instruction
      -- ========================================
      test_num <= 6;
      report "Test 6: PUSH Instruction";
      opcode <= OPC_PUSH;
      wait for clk_period/10;
      check_signal(PushD, "1", "PUSH PushD", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "PUSH MemDLoadStore", pass_count, fail_count);
      check_signal(MemWriteD, "1", "PUSH MemWriteD", pass_count, fail_count);
      check_signal(MemSelD, "0", "PUSH MemSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_R2, "PUSH AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 7: POP Instruction
      -- ========================================
      test_num <= 7;
      report "Test 7: POP Instruction";
      opcode <= OPC_POP;
      wait for clk_period/10;
      check_signal(PopD, "1", "POP PopD", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "POP MemDLoadStore", pass_count, fail_count);
      check_signal(MemWriteD, "0", "POP MemWriteD", pass_count, fail_count);
      check_signal(RegWriteEnD, "1", "POP RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '1', "POP WbSelD", pass_count, fail_count);
      check_signal(LoadUseD, "1", "POP LoadUseD", pass_count, fail_count);

      -- ========================================
      -- Test 8: OUT Instruction
      -- ========================================
      test_num <= 8;
      report "Test 8: OUT Instruction";
      opcode <= OPC_OUT;
      wait for clk_period/10;
      check_signal(OutEnD, "1", "OUT OutEnD", pass_count, fail_count);
      check_signal(AluOpD, ALU_R1, "OUT AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 9: IN Instruction
      -- ========================================
      test_num <= 9;
      report "Test 9: IN Instruction";
      opcode <= OPC_IN;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "IN RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "IN WbSelD", pass_count, fail_count);
      check_signal(ExOutSelD, "1", "IN ExOutSelD", pass_count, fail_count);

      -- ========================================
      -- Test 10: CALL Instruction
      -- ========================================
      test_num <= 10;
      report "Test 10: CALL Instruction";
      opcode <= OPC_CALL;
      wait for clk_period/10;
      check_signal(CallD, "1", "CALL CallD", pass_count, fail_count);
      check_signal(IsImm, "1", "CALL IsImm", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "CALL MemDLoadStore", pass_count, fail_count);
      check_signal(MemWriteD, "1", "CALL MemWriteD", pass_count, fail_count);
      check_signal(MemSelD, "1", "CALL MemSelD", pass_count, fail_count);

      -- ========================================
      -- Test 11: INC Instruction
      -- ========================================
      test_num <= 11;
      report "Test 11: INC Instruction";
      opcode <= OPC_INC;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "INC RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "INC WbSelD", pass_count, fail_count);
      check_signal(NotIncSignal, "1", "INC NotIncSignal", pass_count, fail_count);
      check_signal(AluOpD, ALU_INC, "INC AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 12: NOT Instruction
      -- ========================================
      test_num <= 12;
      report "Test 12: NOT Instruction";
      opcode <= OPC_NOT;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "NOT RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "NOT WbSelD", pass_count, fail_count);
      check_signal(NotIncSignal, "1", "NOT NotIncSignal", pass_count, fail_count);
      check_signal(AluOpD, ALU_NOT, "NOT AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 13: MOV Instruction
      -- ========================================
      test_num <= 13;
      report "Test 13: MOV Instruction";
      opcode <= OPC_MOV;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "MOV RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "MOV WbSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_R1, "MOV AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 14: ADD Instruction
      -- ========================================
      test_num <= 14;
      report "Test 14: ADD Instruction";
      opcode <= OPC_ADD;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "ADD RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "ADD WbSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_ADD, "ADD AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 15: SUB Instruction
      -- ========================================
      test_num <= 15;
      report "Test 15: SUB Instruction";
      opcode <= OPC_SUB;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "SUB RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "SUB WbSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_SUB, "SUB AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 16: AND Instruction
      -- ========================================
      test_num <= 16;
      report "Test 16: AND Instruction";
      opcode <= OPC_AND;
      wait for clk_period/10;
      check_signal(RegWriteEnD, "1", "AND RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "AND WbSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_AND, "AND AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 17: JZ Instruction
      -- ========================================
      test_num <= 17;
      report "Test 17: JZ Instruction";
      opcode <= OPC_JZ;
      wait for clk_period/10;
      check_signal(JmpZD, "1", "JZ JmpZD", pass_count, fail_count);
      check_signal(IsImm, "1", "JZ IsImm", pass_count, fail_count);
      check_signal(AluOpD, ALU_NOP, "JZ AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 18: JN Instruction
      -- ========================================
      test_num <= 18;
      report "Test 18: JN Instruction";
      opcode <= OPC_JN;
      wait for clk_period/10;
      check_signal(JmpND, "1", "JN JmpND", pass_count, fail_count);
      check_signal(IsImm, "1", "JN IsImm", pass_count, fail_count);
      check_signal(AluOpD, ALU_NOP, "JN AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 19: JC Instruction
      -- ========================================
      test_num <= 19;
      report "Test 19: JC Instruction";
      opcode <= OPC_JC;
      wait for clk_period/10;
      check_signal(JmpCD, "1", "JC JmpCD", pass_count, fail_count);
      check_signal(IsImm, "1", "JC IsImm", pass_count, fail_count);
      check_signal(AluOpD, ALU_NOP, "JC AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 20: JMP Instruction
      -- ========================================
      test_num <= 20;
      report "Test 20: JMP Instruction";
      opcode <= OPC_JMP;
      wait for clk_period/10;
      check_signal(JmpD, "1", "JMP JmpD", pass_count, fail_count);
      check_signal(IsImm, "1", "JMP IsImm", pass_count, fail_count);
      check_signal(AluOpD, ALU_NOP, "JMP AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 21: IADD Instruction
      -- ========================================
      test_num <= 21;
      report "Test 21: IADD Instruction";
      opcode <= OPC_IADD;
      wait for clk_period/10;
      check_signal(IsImm, "1", "IADD IsImm", pass_count, fail_count);
      check_signal(RegWriteEnD, "1", "IADD RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "IADD WbSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_ADD, "IADD AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 22: LDM Instruction
      -- ========================================
      test_num <= 22;
      report "Test 22: LDM Instruction";
      opcode <= OPC_LDM;
      wait for clk_period/10;
      check_signal(IsImm, "1", "LDM IsImm", pass_count, fail_count);
      check_signal(RegWriteEnD, "1", "LDM RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '0', "LDM WbSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_R2, "LDM AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 23: LDD Instruction
      -- ========================================
      test_num <= 23;
      report "Test 23: LDD Instruction";
      opcode <= OPC_LDD;
      wait for clk_period/10;
      check_signal(IsImm, "1", "LDD IsImm", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "LDD MemDLoadStore", pass_count, fail_count);
      check_signal(MemWriteD, "0", "LDD MemWriteD", pass_count, fail_count);
      check_signal(RegWriteEnD, "1", "LDD RegWriteEnD", pass_count, fail_count);
      check_signal_bit(WbSelD, '1', "LDD WbSelD", pass_count, fail_count);
      check_signal(LoadUseD, "1", "LDD LoadUseD", pass_count, fail_count);
      check_signal(AluOpD, ALU_ADD, "LDD AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 24: STD Instruction
      -- ========================================
      test_num <= 24;
      report "Test 24: STD Instruction";
      opcode <= OPC_STD;
      wait for clk_period/10;
      check_signal(IsImm, "1", "STD IsImm", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "STD MemDLoadStore", pass_count, fail_count);
      check_signal(MemWriteD, "1", "STD MemWriteD", pass_count, fail_count);
      check_signal(MemSelD, "0", "STD MemSelD", pass_count, fail_count);
      check_signal(AluOpD, ALU_ADD, "STD AluOpD", pass_count, fail_count);

      -- ========================================
      -- Test 25: SWAP Instruction (2-cycle FSM)
      -- ========================================
      test_num <= 25;
      report "Test 25: SWAP Instruction - 2-cycle FSM";
      opcode <= OPC_SWAP;
      
      -- Cycle 1: Phase 1
      wait for clk_period/10;
      report "  SWAP Cycle 1 (phase 1)";
      check_signal(SwapCtrl, "1", "SWAP SwapCtrl phase1", pass_count, fail_count);
      check_signal(SwapD, "01", "SWAP SwapD phase1", pass_count, fail_count);
      check_signal(RegWriteEnD, "1", "SWAP RegWriteEnD phase1", pass_count, fail_count);
      check_signal(AluOpD, ALU_R2, "SWAP AluOpD phase1", pass_count, fail_count);
      
      -- Cycle 2: Phase 2
      wait for clk_period;
      report "  SWAP Cycle 2 (phase 2)";
      check_signal(SwapCtrl, "0", "SWAP SwapCtrl phase2", pass_count, fail_count);
      check_signal(SwapD, "10", "SWAP SwapD phase2", pass_count, fail_count);
      check_signal(RegWriteEnD, "1", "SWAP RegWriteEnD phase2", pass_count, fail_count);
      check_signal(AluOpD, ALU_R1, "SWAP AluOpD phase2", pass_count, fail_count);
      wait for clk_period;
      
      -- Return to idle
      opcode <= OPC_NOP;
      wait for clk_period/10;
      report "  SWAP idle";
      check_signal(SwapCtrl, "0", "SWAP SwapCtrl idle", pass_count, fail_count);
      check_signal(SwapD, "00", "SWAP SwapD idle", pass_count, fail_count);

      -- ========================================
      -- Test 26: INT Instruction (2-cycle FSM)
      -- ========================================
      test_num <= 26;
      report "Test 26: INT Instruction - 2-cycle FSM";
      opcode <= OPC_INT;
      
      -- Cycle 1: Phase 1 (store)
      wait for clk_period/10;
      report "  INT Cycle 1 (phase 1 - store)";
      check_signal(IsImm, "1", "INT IsImm", pass_count, fail_count);
      check_signal(Int1D, "1", "INT Int1D phase1", pass_count, fail_count);
      check_signal(Int2D, "0", "INT Int2D phase1", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "INT MemDLoadStore phase1", pass_count, fail_count);
      check_signal(MemWriteD, "1", "INT MemWriteD phase1", pass_count, fail_count);
      
      -- Cycle 2: Phase 2 (load + add2)
      wait for clk_period;
      report "  INT Cycle 2 (phase 2 - load)";
      check_signal(Int1D, "0", "INT Int1D phase2", pass_count, fail_count);
      check_signal(Int2D, "1", "INT Int2D phase2", pass_count, fail_count);
      check_signal(MemDLoadStore, "1", "INT MemDLoadStore phase2", pass_count, fail_count);
      check_signal(MemWriteD, "0", "INT MemWriteD phase2", pass_count, fail_count);
      check_signal(AluOpD, ALU_ADD_PLUS2, "INT AluOpD phase2", pass_count, fail_count);
      wait for clk_period;
      
      -- Return to idle
      opcode <= OPC_NOP;
      wait for clk_period/10;
      report "  INT idle";
      check_signal(Int1D, "0", "INT Int1D idle", pass_count, fail_count);
      check_signal(Int2D, "0", "INT Int2D idle", pass_count, fail_count);

      -- ========================================
      -- Final Summary
      -- ========================================
      wait for clk_period * 2;
      
      report "==== Testbench Complete ====";
      report "Total Tests Passed: " & integer'image(pass_count);
      report "Total Tests Failed: " & integer'image(fail_count);
      
      if fail_count = 0 then
         report "*** ALL TESTS PASSED ***" severity note;
      else
         report "*** SOME TESTS FAILED ***" severity warning;
      end if;
      
      stop_sim <= true;
      wait;
   end process;

end testbench;
