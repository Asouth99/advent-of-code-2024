#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    # COMBO OPERANDS VALUES
    # 0 - 3 represent literal values 0 - 3.
    # 4 represents the value of register A.
    # 5 represents the value of register B.
    # 6 represents the value of register C.
    # 7 is reserved and will not appear in valid programs. 

    # Eight different instructions
    # OPCODE   INSTRUCTION   DESCRIPTION
    # 0        adv           Division.    Result is truncated to an integer and written to the A register. Operand X is a COMBO OPERAND. X=[0-3]: A / (2^X) X=[4,5,6]: A / (2^[A,B,C]). X=7 is not valid
    # 1        bxl           Bitwise XOR. Operand X is a LITERAL OPERAND. B XOR X. Stores result in register B.
    # 2        bst           Modulo 8.    Operand X is a COMBO OPERAND. X_C % 8. Stores result in register B
    # 3        jnz           Does nothing if A = 0. A != 0 then jumps the instruction pointer to the value of its LITERAL OPERAND, instruction pointer does not increase by 2 afterwards.
    # 4        bxc           Bitwise XOR. B XOR C. Stores result in register B. Accepts an operand but does nothing with it
    # 5        out           Modulo 8.    Operand X is a COMBO OPERAND. X_C % 8. Outputs the value - if multiple outputs then they are comma separated.
    # 6        bdv           Division.    Result is truncated to an integer and written to the B register. Operand X is a COMBO OPERAND. X=[0-3]: A / (2^X) X=[4,5,6]: A / (2^[A,B,C]). X=7 is not valid
    # 7        cdv           Division.    Result is truncated to an integer and written to the C register. Operand X is a COMBO OPERAND. X=[0-3]: A / (2^X) X=[4,5,6]: A / (2^[A,B,C]). X=7 is not valid

    declare REG_A REG_B REG_C INSTRUCTION_PTR
    declare -a PROGRAM
    


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0



    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt

# solution_2 example_input.txt
# echo
# solution_2 input.txt
