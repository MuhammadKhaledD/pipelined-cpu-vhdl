#!/usr/bin/env python3
import sys
import os
import argparse
import re

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
RE_OFFSET = re.compile(r'([^\(]+)\(([^)]+)\)')


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
    elif t.isdigit():
        v = int(t, 10)
    else:
        raise ValueError(f"Invalid number '{t}'")
    return -v if neg else v


def encode_instruction(m, ops_str):
    m = m.upper()
    opc = OPCODES.get(m)
    if opc is None:
        raise ValueError(f"Unknown mnemonic '{m}'")

    word = (opc & 0x1F) << 25
    rdst = rsrc1 = rsrc2 = 0
    ops = [o.strip() for o in ops_str.split(",") if o.strip()]

    # Instructions with no operands
    if m in ("NOP", "HLT", "SETC", "RET", "RTI"):
        if len(ops) != 0:
            raise ValueError(f"{m} takes no operands")

    # Instructions with one source register
    elif m in ("PUSH", "OUT", "INC", "NOT"):
        if len(ops) != 1:
            raise ValueError(f"{m} requires 1 register")
        rsrc1 = parse_reg(ops[0])

    # Instructions with one destination register
    elif m in ("POP", "IN"):
        if len(ops) != 1:
            raise ValueError(f"{m} requires 1 register")
        rdst = parse_reg(ops[0])

    # MOV: source, destination
    elif m == "MOV":
        if len(ops) != 2:
            raise ValueError("MOV Rsrc, Rdst")
        rsrc1 = parse_reg(ops[0])
        rdst = parse_reg(ops[1])

    # SWAP: two source registers
    elif m == "SWAP":
        if len(ops) != 2:
            raise ValueError("SWAP Rsrc1, Rsrc2")
        rsrc1 = parse_reg(ops[0])
        rsrc2 = parse_reg(ops[1])

    # ALU operations: destination, source1, source2
    elif m in ("ADD", "SUB", "AND"):
        if len(ops) != 3:
            raise ValueError(f"{m} Rdst, Rsrc1, Rsrc2")
        rdst = parse_reg(ops[0])
        rsrc1 = parse_reg(ops[1])
        rsrc2 = parse_reg(ops[2])

    # LDM: destination, immediate
    elif m == "LDM":
        if len(ops) != 2:
            raise ValueError("LDM Rdst, IMM")
        rdst = parse_reg(ops[0])

    # IADD: destination, source, immediate
    elif m == "IADD":
        if len(ops) != 3:
            raise ValueError("IADD Rdst, Rsrc, IMM")
        rdst = parse_reg(ops[0])
        rsrc1 = parse_reg(ops[1])

    # Jump/Call instructions: immediate only
    elif m in ("JZ", "JN", "JC", "JMP", "CALL", "INT"):
        if len(ops) != 1:
            raise ValueError(f"{m} requires 1 immediate operand")

    # LDD: destination, offset(source)
    elif m == "LDD":
        if len(ops) != 2:
            raise ValueError("LDD Rdst, offset(Rsrc)")
        rdst = parse_reg(ops[0])
        mo = RE_OFFSET.match(ops[1])
        if not mo:
            raise ValueError("LDD expects offset(Rsrc)")
        rsrc1 = parse_reg(mo.group(2).strip())

    # STD: source, offset(source2)
    elif m == "STD":
        if len(ops) != 2:
            raise ValueError("STD Rsrc, offset(Rsrc2)")
        rsrc1 = parse_reg(ops[0])
        mo = RE_OFFSET.match(ops[1])
        if not mo:
            raise ValueError("STD expects offset(Rsrc)")
        rsrc2 = parse_reg(mo.group(2).strip())

    word |= (rdst & 7) << 22
    word |= (rsrc1 & 7) << 19
    word |= (rsrc2 & 7) << 16
    return word


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
    words = []
    with open(src) as f:
        for i, line in enumerate(f, start=1):
            line = RE_COMMENT.sub("", line).strip()
            if not line:
                continue
            parts = line.split(None, 1)
            mnemonic = parts[0]
            ops_str = parts[1] if len(parts) > 1 else ""

            try:
                instr = encode_instruction(mnemonic, ops_str)
                words.append(instr)
                if mnemonic.upper() in IMM_FOLLOWS:
                    words.append(get_immediate(mnemonic, ops_str))
            except Exception as e:
                raise ValueError(f"{src}:{i}: {e}")

    with open(dst, "w") as f:
        for w in words:
            f.write(f"{w:032b}\n")

    print(f"Wrote {len(words)} words to {dst}")


def main():
    prog = os.path.basename(sys.argv[0])

    parser = argparse.ArgumentParser(
        prog=prog,
        description="Assemble simple CPU assembly into 32-bit binary words.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument("src", help="input assembly file (e.g., code.asm)")
    parser.add_argument("-o", "--out", required=True,
                        help="output text file (binary words)")

    try:
        args = parser.parse_args()
        assemble_file(args.src, args.out)
    except FileNotFoundError:
        sys.stderr.write("Error: source file not found\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"Assembly error: {e}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()