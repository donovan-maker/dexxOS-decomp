from capstone import Cs, CS_ARCH_X86, CS_MODE_16

code = bytes.fromhex(input("Hex code (at least 6 bytes):").lower())
place = int(input("Place as hex:").lower(), 16)

mode = Cs(CS_ARCH_X86, CS_MODE_16)
for i in mode.disasm(code, place):
    print("%s %s" %(i.mnemonic, i.op_str))