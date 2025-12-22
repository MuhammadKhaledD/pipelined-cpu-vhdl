import sys, os, argparse, re

OPCODES = {
    "NOP": 0b00000, "HLT": 0b00001, "SETC": 0b00010, "RET": 0b00011,
    "RTI": 0b00100, "PUSH": 0b01000, "POP": 0b01001, "OUT": 0b01010,
    "IN": 0b01011, "CALL": 0b01100, "INT": 0b01101, "INC": 0b01110,
    "NOT": 0b01111, "MOV": 0b10000, "SWAP": 0b10010, "ADD": 0b10011,
    "SUB": 0b10100, "AND": 0b10101, "JZ": 0b11000, "JN": 0b11001,
    "JC": 0b11010, "JMP": 0b11011, "IADD": 0b11100, "LDM": 0b11101,
    "LDD": 0b11110, "STD": 0b11111,
}

IMM_FOLLOWS = {"LDM", "IADD", "JZ", "JN", "JC", "JMP", "CALL", "INT", "LDD", "STD"}

RE_COMMENT = re.compile(r'[;#].*')
RE_OFFSET = re.compile(r'([^\(]+)\(([^)]+)\)')    # captures "offset(base)"

def parse_reg(reg_str):
    s = reg_str.strip().upper()
    if not s.startswith('R'):
        raise ValueError(f"Invalid register '{reg_str}' (expected Rn)")
    if not s[1:].isdigit():
        raise ValueError(f"Invalid register '{reg_str}' (bad number)")
    n = int(s[1:])
    if not (0 <= n <= 7):
        raise ValueError(f"Register out of range '{reg_str}' (expect R0..R7)")
    return n

def parse_int(t):
    t = t.strip()
    if not t:
        raise ValueError("empty immediate")
    neg = t.startswith('-')
    if neg:
        t = t[1:]
    if t.startswith(("0x", "0X")):
        v = int(t, 16)
    elif t.startswith(("0b", "0B")):
        v = int(t, 2)
    else:
        # Try to parse as hex (handles both 0-9 and A-F without 0x prefix)
        try:
            v = int(t, 16)
        except ValueError:
            raise ValueError(f"Invalid number '{t}'")
    return -v if neg else v

def encode_instruction(m, ops_str):
    m = m.upper()
    opc = OPCODES.get(m)
    if opc is None:
        raise ValueError(f"Unknown mnemonic '{m}'")

    # OPCODE[29:25], RDST[24:22], RSRC1[21:19], RSRC2[18:16], Unused[15:0]
    word = (opc & 0x1F) << 25
    rdst = rsrc1 = rsrc2 = 0
    ops = [o.strip() for o in ops_str.split(",") if o.strip()]

    # no-operand instructions
    if m in ("NOP", "HLT", "SETC", "RET", "RTI"):
        if len(ops) != 0:
            raise ValueError(f"{m} takes no operands")

    # single-source register
    elif m == "PUSH":
        if len(ops) != 1:
            raise ValueError("PUSH requires 1 register")
        rsrc2 = parse_reg(ops[0])

    elif m in ("OUT", "INC", "NOT"):
        if len(ops) != 1:
            raise ValueError(f"{m} requires 1 register")
        rsrc1 = parse_reg(ops[0])

    # single-destination register
    elif m in ("POP", "IN"):
        if len(ops) != 1:
            raise ValueError(f"{m} requires 1 register")
        rdst = parse_reg(ops[0])

    elif m == "MOV":
        if len(ops) != 2:
            raise ValueError("MOV Rsrc, Rdst")
        rsrc1 = parse_reg(ops[0]); rdst = parse_reg(ops[1])

    elif m == "SWAP":
        if len(ops) != 2:
            raise ValueError("SWAP Rsrc1, Rsrc2")
        rsrc1 = parse_reg(ops[0]); rsrc2 = parse_reg(ops[1])

    elif m in ("ADD", "SUB", "AND"):
        if len(ops) != 3:
            raise ValueError(f"{m} Rdst, Rsrc1, Rsrc2")
        rdst = parse_reg(ops[0]); rsrc1 = parse_reg(ops[1]); rsrc2 = parse_reg(ops[2])

    elif m == "LDM":
        if len(ops) != 2:
            raise ValueError("LDM Rdst, IMM")
        rdst = parse_reg(ops[0])

    elif m == "IADD":
        if len(ops) != 3:
            raise ValueError("IADD Rdst, Rsrc, IMM")
        rdst = parse_reg(ops[0]); rsrc1 = parse_reg(ops[1])

    elif m in ("JZ", "JN", "JC", "JMP", "CALL", "INT"):
        if len(ops) != 1:
            raise ValueError(f"{m} requires 1 immediate operand")

    elif m == "LDD":
        if len(ops) != 2:
            raise ValueError("LDD Rdst, offset(Rsrc)")
        rdst = parse_reg(ops[0])
        mo = RE_OFFSET.match(ops[1])
        if not mo:
            raise ValueError("LDD expects offset(Rsrc)")
        rsrc1 = parse_reg(mo.group(2).strip())

    elif m == "STD":
        if len(ops) != 2:
            raise ValueError("STD Rsrc, offset(Rsrc2)")
        rsrc2 = parse_reg(ops[0])
        mo = RE_OFFSET.match(ops[1])
        if not mo:
            raise ValueError("STD expects offset(Rsrc)")
        rsrc2 = parse_reg(mo.group(2).strip())

    # pack fields
    word |= (rdst & 7) << 22
    word |= (rsrc1 & 7) << 19
    word |= (rsrc2 & 7) << 16

    return word & 0xFFFFFFFF

def get_immediate(m, ops_str):
    m = m.upper()
    ops = [o.strip() for o in ops_str.split(',') if o.strip()]
    if m == "LDM":
        return parse_int(ops[1])
    if m == "IADD":
        return parse_int(ops[2])
    if m in ("JZ", "JN", "JC", "JMP", "CALL", "INT"):
        return parse_int(ops[0])
    if m in ("LDD", "STD"):
        mo = RE_OFFSET.match(ops[1])
        return parse_int(mo.group(1))
    raise ValueError(f"{m} has no immediate")

def assemble_file(src, dst):
    memory = {}  # address -> 32-bit word
    current_address = 0
    prev_mnemonic = None
    prev_ops_str = None
    
    with open(src, 'r') as f:
        for i, line in enumerate(f, start=1):
            original_line = line
            line = RE_COMMENT.sub("", line).strip()
            if not line:
                continue
            
            parts = line.split(None, 1)
            mnemonic = parts[0]
            ops_str = parts[1] if len(parts) > 1 else ""

            # Handle .ORG directive
            if mnemonic == ".ORG":
                if not ops_str:
                    raise ValueError(f"{src}:{i}: .ORG requires an address")
                try:
                    current_address = parse_int(ops_str)
                except Exception as e:
                    raise ValueError(f"{src}:{i}: .ORG invalid address: {e}")
                prev_mnemonic = None
                prev_ops_str = None
                continue
            
            # Handle immediate values (raw hex values in memory)
            if not mnemonic.upper() in OPCODES:
                try:
                    # Treat as immediate value
                    value = parse_int(mnemonic)
                    memory[current_address] = value & 0xFFFFFFFF
                    current_address += 1
                except Exception as e:
                    raise ValueError(f"{src}:{i}: Invalid instruction or immediate: {e}")
                prev_mnemonic = None
                prev_ops_str = None
                continue

            # SWAP optimization logic
            if mnemonic.upper() == "SWAP" and prev_mnemonic == "SWAP":
                # Parse operands of both SWAP instructions
                curr_ops = [o.strip() for o in ops_str.split(",") if o.strip()]
                prev_ops = [o.strip() for o in prev_ops_str.split(",") if o.strip()]
                
                if len(curr_ops) == 2 and len(prev_ops) == 2:
                    # Get register numbers
                    try:
                        curr_r1 = parse_reg(curr_ops[0])
                        curr_r2 = parse_reg(curr_ops[1])
                        prev_r1 = parse_reg(prev_ops[0])
                        prev_r2 = parse_reg(prev_ops[1])
                        
                        # Find which register is common and keep it in the same position
                        # If prev_r1 is the common register, it must stay in position 1
                        # If prev_r2 is the common register, it must stay in position 2
                        
                        if curr_r1 == prev_r1 or curr_r2 == prev_r1:
                            # Common register is prev_r1 (was in position 1)
                            # Make sure it's in position 1 of current SWAP
                            if curr_r2 == prev_r1:
                                # It's in position 2, flip to position 1
                                ops_str = f"{curr_ops[1]}, {curr_ops[0]}"
                                print(f"Optimized line {i}: SWAP operands flipped to {ops_str}")
                        
                        if curr_r1 == prev_r2 or curr_r2 == prev_r2:
                            # Common register is prev_r2 (was in position 2)
                            # Make sure it's in position 2 of current SWAP
                            if curr_r1 == prev_r2:
                                # It's in position 1, flip to position 2
                                ops_str = f"{curr_ops[1]}, {curr_ops[0]}"
                                print(f"Optimized line {i}: SWAP operands flipped to {ops_str}")
                            
                    except:
                        pass  # If parsing fails, just proceed normally

            try:
                instr = encode_instruction(mnemonic, ops_str)
                memory[current_address] = instr
                current_address += 1
                
                if mnemonic.upper() in IMM_FOLLOWS:
                    imm = get_immediate(mnemonic, ops_str)
                    # Represent immediate as a 32-bit two's-complement value
                    imm32 = imm & 0xFFFFFFFF
                    memory[current_address] = imm32
                    current_address += 1
            except Exception as e:
                raise ValueError(f"{src}:{i}: {e}")
            
            # Track previous instruction for SWAP optimization
            prev_mnemonic = mnemonic.upper()
            prev_ops_str = ops_str

    # write output based on file extension
    if dst.endswith('.mem'):
        # Binary .mem format - raw 32-bit words in little-endian
        with open(dst, 'wb') as out:
            for addr in sorted(memory.keys()):
                word = memory[addr]
                # Write as little-endian 32-bit value
                out.write(word.to_bytes(4, byteorder='little', signed=False))
    else:
        # Text format with addresses (VHDL memory format)
        with open(dst, "w") as out:
            out.write(r'''// memory data file (do not edit the following line - required for mem load use)
// instance=/ram/ram
// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1
''')
            for addr in sorted(memory.keys()):
                out.write(f'{addr}: {memory[addr]:032b}\n')

    print(f"Wrote {len(memory)} words to {dst}")

def main():

    prog = os.path.basename(sys.argv[0])
    usage_line = f"usage: {prog} src.asm -o dst.txt"

    if any(arg in ("-h", "--help") for arg in sys.argv[1:]):
        print(usage_line)
        sys.exit(0)

    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("src", nargs=1)
    parser.add_argument("-o", "--out", required=True)

    try:
        ns, extras = parser.parse_known_args()
    except SystemExit:
        sys.stderr.write(usage_line + "\n")
        sys.exit(1)

    if extras:
        sys.stderr.write(usage_line + "\n")
        sys.exit(1)

    try:
        assemble_file(ns.src[0], ns.out)
    except FileNotFoundError:
        sys.stderr.write("Error: source file not found\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"Assembly error: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()