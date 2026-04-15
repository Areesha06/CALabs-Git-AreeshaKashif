# # =============================================================================
# # Task B - Verification Assembly Program
# # Tests all three new instructions: SLTI, SRA, BLTU
# # =============================================================================
# # Register usage:
# #   x10 (a0) = output register (visible on LEDs)
# #   x1       = temporary / test values
# #   x2       = temporary / test values
# #   x3       = expected result
# #   x4       = pass counter
# # =============================================================================

.text
.globl main
main:

# # -----------------------------------------------------------------------------
# # TEST 1: SLTI (I-type) -- Set Less Than Immediate, signed
# # Instruction format: slti rd, rs1, imm
# # rd = 1 if rs1 < imm (signed), else 0
# # -----------------------------------------------------------------------------

#     addi x4, x0, 0         # x4 = pass counter = 0

#     # Test 1a: 3 < 10 -> expect x1 = 1
#     addi x1, x0, 3         # x1 = 3
#     slti x2, x1, 10        # x2 = (3 < 10) = 1
#     addi x3, x0, 1         # x3 = expected = 1
#     beq  x2, x3, slti_1a_pass
#     jal  x0, test_fail
# slti_1a_pass:
#     addi x4, x4, 1         # pass++

#     # Test 1b: 10 < 3 -> expect x2 = 0
#     addi x1, x0, 10        # x1 = 10
#     slti x2, x1, 3         # x2 = (10 < 3) = 0
#     addi x3, x0, 0         # x3 = expected = 0
#     beq  x2, x3, slti_1b_pass
#     jal  x0, test_fail
# slti_1b_pass:
#     addi x4, x4, 1         # pass++

#     # Test 1c: negative number < 0 -> expect x2 = 1
#     addi x1, x0, -5        # x1 = -5
#     slti x2, x1, 0         # x2 = (-5 < 0) = 1  [signed comparison]
#     addi x3, x0, 1         # x3 = expected = 1
#     beq  x2, x3, slti_1c_pass
#     jal  x0, test_fail
# slti_1c_pass:
#     addi x4, x4, 1         # pass++

# # -----------------------------------------------------------------------------
# # TEST 2: SRA (R-type) -- Shift Right Arithmetic
# # Instruction format: sra rd, rs1, rs2
# # rd = rs1 >> rs2[4:0]  (sign-bit is preserved / filled)
# # -----------------------------------------------------------------------------

#     # Test 2a: SRA of positive number (same as SRL)
#     # 0x00000010 (16) >> 1 = 0x00000008 (8), sign=0 so same as logical
#     addi x1, x0, 16        # x1 = 16
#     addi x5, x0, 1         # x5 = shift amount = 1
#     sra  x2, x1, x5        # x2 = 16 >> 1 = 8 (arithmetic)
#     addi x3, x0, 8         # x3 = expected = 8
#     beq  x2, x3, sra_2a_pass
#     jal  x0, test_fail
# sra_2a_pass:
#     addi x4, x4, 1         # pass++

#     # Test 2b: SRA of negative number (sign extension fills with 1s)
#     # -8 in 32-bit = 0xFFFFFFF8; SRA by 1 = 0xFFFFFFFC = -4
#     addi x1, x0, -8        # x1 = -8 (0xFFFFFFF8)
#     addi x5, x0, 1         # x5 = shift amount = 1
#     sra  x2, x1, x5        # x2 = -8 >> 1 = -4  (arithmetic, fills with 1)
#     addi x3, x0, -4        # x3 = expected = -4
#     beq  x2, x3, sra_2b_pass
#     jal  x0, test_fail
# sra_2b_pass:
#     addi x4, x4, 1         # pass++

#     # Test 2c: SRA by 0 = no change
#     addi x1, x0, 25        # x1 = 25
#     addi x5, x0, 0         # x5 = shift = 0
#     sra  x2, x1, x5        # x2 = 25
#     addi x3, x0, 25        # x3 = expected = 25
#     beq  x2, x3, sra_2c_pass
#     jal  x0, test_fail
# sra_2c_pass:
#     addi x4, x4, 1         # pass++

# # -----------------------------------------------------------------------------
# # TEST 3: BLTU (B-type) -- Branch if Less Than Unsigned
# # Instruction format: bltu rs1, rs2, offset
# # Branches if rs1 < rs2 (UNSIGNED comparison)
# # Key difference from BLT: large positive numbers are greater than
# # negative-looking 2's complement values when compared unsigned.
# # -----------------------------------------------------------------------------

#     # Test 3a: 3 < 7 unsigned -> should branch
#     addi x1, x0, 3         # x1 = 3
#     addi x2, x0, 7         # x2 = 7
#     bltu x1, x2, bltu_3a_pass  # 3 < 7 unsigned -> branch taken
#     jal  x0, test_fail
# bltu_3a_pass:
#     addi x4, x4, 1         # pass++

#     # Test 3b: 7 < 3 unsigned -> should NOT branch
#     addi x1, x0, 7         # x1 = 7
#     addi x2, x0, 3         # x2 = 3
#     bltu x1, x2, test_fail # 7 < 3 is FALSE -> branch NOT taken
#     addi x4, x4, 1         # pass++ (only reached if branch not taken)

#     # Test 3c: unsigned compare: 0 vs 0xFFFFFFFF (-1 signed, but largest unsigned)
#     # 0 < 0xFFFFFFFF unsigned -> should branch
#     addi x1, x0, 0         # x1 = 0
#     addi x2, x0, -1        # x2 = 0xFFFFFFFF (largest unsigned 32-bit)
#     bltu x1, x2, bltu_3c_pass  # 0 < 0xFFFFFFFF unsigned -> taken
#     jal  x0, test_fail
# bltu_3c_pass:
#     addi x4, x4, 1         # pass++

# # -----------------------------------------------------------------------------
# # All tests passed -- output pass count on LEDs via x10
# # x4 should = 9 (all 9 sub-tests passed) -> LEDs show 0b00001001
# # -----------------------------------------------------------------------------
# all_pass:
#     addi x10, x4, 0        # a0 = pass count (should be 9 = 0x09)
#     jal  x0, done          # loop to end

# test_fail:
#     addi x10, x0, 0xFF     # a0 = 0xFF -> all LEDs ON = FAIL indicator
#     jal  x0, done

# done:
#     jal  x0, done          # infinite loop (halt)




   # Setup
   addi x1, x0, 20       # x1 = 20
   addi x2, x0, 8        # x2 = 8
   addi x5, x0, 2        # x5 = shift amount = 2

   # Test SLTI (I-type) - ctrl shows 195
   slti x3, x1, 25       # x3 = (20 < 25) = 1  
   slti x4, x1, 10       # x4 = (20 < 10) = 0 

   # Test SRA (R-type) - ctrl shows 130
   sra  x6, x1, x5       # x6 = 20 >> 2 = 5    - arithmetic shift
   addi x7, x0, -16      # x7 = -16 (0xFFFFFFF0)
   sra  x8, x7, x5       # x8 = -16 >> 2 = -4  - sign preserved

   # Test BLTU (B-type) - ctrl shows 5
   addi x9,  x0, 3       # x9  = 3
   addi x10, x0, 7       # x10 = 7
   bltu x9, x10, skip    # 3 < 7 unsigned = branch taken
   addi x0, x0, 0        # NOP (skipped)
   skip:
   addi x11, x0, 1       # x11 = 1 (proof branch was taken)

   # Loop back to show signals repeatedly
   jal  x0, -52          # jump back to SLTI test