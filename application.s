.data
count:     .word 4
newLine: .string "\n\n"
roundPrompt: .string "Reached Round"
restartPrompt: .string "Do you wish to restart? Enter 1 for Yes"
continuePrompt: .string "Do you wish to continue. Enter 1 for Yes, 0 to exit"
sequence:  .byte 0,0,0,0

.globl main
.text

# s0 = count
# s1 = 4 bit looper
# s2 = milliseconds

lw s0 count
li s1 4
li s2 200
main:
    # TODO: Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. We provided 
    # a declaration above that you can use if you want.
    # HINT: Use the rand function provided to generate each number
    
    # t4 = counter, t5 = address, t6 = offset
    li t4 0
    la t5 sequence
    loop:
        li a0 4
        jal rand
        mul t6 t4 s1
        add t6 t6 t5
        sb a0 0(t6)
        li a7 1
        ecall
        addi t4 t4 1
        blt t4 s0 loop
    
    
   
    # TODO: Now read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating
    
    # t4 = counter, t5 = address, t6 = offset, s3 = number
    li t4 0
    la t5 sequence
    li t6 0
    lightupLoop:
        mul t6 t4 s1
        add t6 t6 t5
        lb s3 0(t6)
        li s4 3
        bge s3 s4 threeLoop
        addi s4 s4 -1
        bge s3 s4 twoLoop
        addi s4 s4 -1
        bge s3 s4 oneLoop
        addi s4 s4 -1
        bge s3 s4 zeroLoop
        zeroLoop:
            # Up
            li a0 0xF4F614
            li a1 1
            li a2 0
            jal setLED
            mv a0 s2
            jal delay
            li a1 1
            li a2 0
            li a0 0x000000
            jal setLED
            j continue
        oneLoop:
            # Down
            li a0 0xF6A914
            li a1 1
            li a2 2
            jal setLED
            mv a0 s2
            jal delay
            li a1 1
            li a2 2
            li a0 0x000000
            jal setLED
            j continue
        twoLoop:
            # Left
            li a0 0x14F6F4
            li a1 0
            li a2 1
            jal setLED
            mv a0 s2
            jal delay
            li a1 0
            li a2 1
            li a0 0x000000
            jal setLED
            j continue
        threeLoop:
            # Right
            li a0 0xC036CF
            li a1 2
            li a2 1
            jal setLED
            mv a0 s2
            jal delay
            li a1 2
            li a2 1
            li a0 0x000000
            jal setLED       
        continue:
        mv t6 s2
        li s3 2
        mul t6 t6 s3
        mv a0 t6
        jal delay
        addi t4 t4 1
        blt t4 s0 lightupLoop
    
    
    
    # TODO: Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.

    
    # t4 = counter, t5 = address, t6 = offset, s3 = number
    li t4 0
    la t5 sequence
    answerLoop:
        mul t6 t4 s1
        add t6 t6 t5
        lb s3 0(t6)
        jal pollDpad
        li a7 1
        ecall
        # s4 = input
        mv s4 a0
        bne s4 s3 wrongInput
        addi t4 t4 1
        blt t4 s0 answerLoop
    li a0 0x47E05F
    li a1 1
    li a2 0
    jal setLED
    li a1 1
    li a2 2
    jal setLED
    li a1 0
    li a2 1
    jal setLED
    li a1 2
    li a2 1
    jal setLED
    li a0 300
    jal delay
    li a0 0x000000
    li a1 1
    li a2 0
    jal setLED
    li a1 1
    li a2 2
    jal setLED
    li a1 0
    li a2 1
    jal setLED
    li a1 2
    li a2 1
    jal setLED

    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.
    la a0 newLine
    li a7 4
    ecall
    la a0 roundPrompt
    li a7 4
    ecall
    # Increment count and array size
    addi s0 s0 1
    li t4 2
    div s2 s2 t4
    addi a0 s0 -3
    li a7 1
    ecall
    la a0 newLine
    li a7 4
    ecall
    la a0 continuePrompt
    li a7 4
    ecall
    call readInt
    li a1 1
    beq a0 a1 premain
    j exit
    

wrongInput:
    # Light the LEDs red
    li a0 0xE5655F
    li a1 1
    li a2 0
    jal setLED
    li a1 1
    li a2 2
    jal setLED
    li a1 0
    li a2 1
    jal setLED
    li a1 2
    li a2 1
    jal setLED
    li a0 300
    jal delay
    li a0 0x00000
    li a1 1
    li a2 0
    jal setLED
    li a1 1
    li a2 2
    jal setLED
    li a1 0
    li a2 1
    jal setLED
    li a1 2
    li a2 1
    jal setLED
    # Tell them the level they reached
    la a0 newLine
    li a7 4
    ecall
    la a0 roundPrompt
    li a7 4
    ecall
    li a7 1
    addi a0 s0 -3
    ecall
    # Ask if they want to play again
    la a0 newLine
    li a7 4
    ecall
    la a0 restartPrompt
    li a7 4
    ecall
    call readInt
    lw s0 count
    li s1 4
    li s2 200
    li a1 1
    beq a0 a1 main
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    remu   a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra

readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -3
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall

premain:
    li a0 1000
    jal delay
    j main