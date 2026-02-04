# README for Pipelined CPU in VHDL

Here's a comprehensive README for this repository:

---

# Pipelined CPU - VHDL Implementation

A complete 5-stage pipelined CPU implementation in VHDL with a custom instruction set architecture (ISA) and Python-based assembler. This project features a fully functional processor with 26 instructions, hardware interrupt support, and comprehensive hazard management.

## Features

### CPU Architecture
- **5-stage pipeline**: Fetch, Decode, Execute, Memory, Write-Back [1](#0-0) 
- **8 general-purpose registers** (R0-R7) with 32-bit width
- **1MB unified memory** for instructions and data [2](#0-1) 
- **Hardware interrupt support** with automatic context preservation
- **Condition Code Register** with Zero, Negative, and Carry flags
- **Dedicated Stack Pointer** register
- **Data forwarding** to resolve RAW hazards [3](#0-2) 
- **Hazard detection unit** for pipeline stalls and flushes [4](#0-3) 

![MIPS32 Pipelined Processor - MIPS](./design/lightone.svg)



> For a clearer and scalable view of the architecture, open the block diagram SVG files on your PC (You can find it in design folder u can find dark and light one). This allows full zoom and editing capabilities.


### Instruction Set
- **26 instructions** including arithmetic, logic, memory, branch, and interrupt operations [5](#0-4) 
- **No-operand instructions**: NOP, HLT, SETC, RET, RTI
- **Register operations**: PUSH, POP, IN, OUT, INC, NOT, MOV, SWAP
- **Arithmetic/Logic**: ADD, SUB, AND, IADD
- **Memory operations**: LDM, LDD, STD
- **Control flow**: JZ, JN, JC, JMP, CALL, INT [6](#0-5) 

### Assembler
- **Single-pass assembler** written in Python [7](#0-6) 
- **Multiple number formats**: decimal, hexadecimal (0x), binary (0b)
- **`.ORG` directive** for specifying memory addresses [8](#0-7) 
- **Dual output formats**: binary `.mem` files or VHDL text format
- **SWAP instruction optimization** for consecutive SWAP operations [9](#0-8) 

## Repository Structure

```
pipelined-cpu-vhdl/
├── assembler/
│   ├── assembler.py              # Python assembler
│   ├── cheat_sheet.txt           # ISA quick reference
│   ├── src/                      # Example assembly programs
│   └── results/                  # Assembled output files
│
└── CPU_v0.9067/                  # VHDL source files
    ├── CPU.vhd                   # Top-level CPU entity
    ├── cu.vhd                    # Control Unit
    ├── Decode_Stage.vhd          # Decode stage
    ├── Execute_Stage.vhd         # Execute stage
    ├── Memory_Fetch_Stage.vhd    # Fetch/Memory stages
    ├── WB_Stage.vhd              # Write-back stage
    ├── Hazard_Unit.vhd           # Hazard detection
    ├── ForwardUnit.vhd           # Data forwarding logic
    ├── ALU.vhd                   # Arithmetic Logic Unit
    ├── RegisterFile.vhd          # Register file
    ├── Memory.vhd                # Memory array
    └── [Pipeline registers and other components]
```

## Quick Start

### 1. Write Assembly Code

Create an assembly file (e.g., `program.asm`) using the supported instruction set:

```assembly
.ORG 0          # Start at address 0
LDM R1, 0x100   # Load immediate value
ADD R2, R1, R1  # R2 = R1 + R1
OUT R2          # Output R2 to output port
HLT             # Halt execution
```

### 2. Assemble to Machine Code

Run the assembler: [10](#0-9) 

```bash
python3 assembler/assembler.py program.asm -o output.mem
```

**Output formats:**
- `.mem` extension → Binary format (32-bit little-endian words) [11](#0-10) 
- Other extensions → VHDL text format for ModelSim [12](#0-11) 

### 3. Simulate or Synthesize

Load the assembled code into the CPU's memory and run simulation using ModelSim/QuestaSim or synthesize for FPGA deployment.

## Instruction Format

Instructions are encoded as 32-bit words: [13](#0-12) 

```
[31:30] - Unused
[29:25] - Opcode (5 bits)
[24:22] - Destination Register (3 bits)
[21:19] - Source Register 1 (3 bits)
[18:16] - Source Register 2 (3 bits)
[15:0]  - Unused
```

**Two-word instructions**: Some instructions (LDM, IADD, JZ, JN, JC, JMP, CALL, INT, LDD, STD) emit an additional 32-bit immediate word. [14](#0-13) 

## CPU Interface

The CPU has the following ports: [15](#0-14) 

- `clk` - Clock input
- `rst` - Reset signal
- `hwInt` - Hardware interrupt request
- `inPort` - 32-bit input port (read by IN instruction)
- `outPort` - 32-bit output port (written by OUT instruction)

## Assembler Reference

For detailed instruction syntax and examples, see the cheat sheet: [16](#0-15) 

**Supported number formats:**
- Decimal: `123`, `-5`
- Hexadecimal: `0x1A2F`, `FF` (0x prefix optional)
- Binary: `0b101101`

**Comments:**
```assembly
; This is a comment
# This is also a comment
```

## Examples

Example assembly programs are provided in the `assembler/src/` directory:
- `Branch.asm` - Branch and jump instruction tests [17](#0-16) 
- `TestF.asm` - General functionality tests
- `BranchPrediction.asm` - Branch prediction scenarios

## License

This project is licensed under the GNU General Public License v3.0. [18](#0-17) 

---