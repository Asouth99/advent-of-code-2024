#!/usr/bin/env bash

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

declare -g REG_A REG_B REG_C
declare -g INSTRUCTION_PTR=0
declare -g PROGRAM PROGRAM_STRING
declare -g OUTPUT
declare -g HAS_JUMPED="false"

declare -g OPCODE_TO_INSTRUCTION=(
    ["0"]="adv"
    ["1"]="bxl"
    ["2"]="bst"
    ["3"]="jnz"
    ["4"]="bxc"
    ["5"]="out"
    ["6"]="bdv"
    ["7"]="cdv"
)
declare OPCODE_OPERAND_TYPE=(
    ["0"]="COMBO"
    ["1"]="LITERAL"
    ["2"]="COMBO"
    ["3"]="LITERAL"
    ["4"]="LITERAL" # Does nothing with it tho
    ["5"]="COMBO"
    ["6"]="COMBO"
    ["7"]="COMBO"
)

adv () {
    local operand=$1
    local top=$REG_A
    local bottom=$((2**operand))
    result=$((top/bottom))
    # echo "    REG_A=$REG_A, adv $1 = $result, stored in REG_A"
    REG_A=$result #store result in A register
}
bxl () {
    local operand=$1
    result=$(( REG_B ^ operand )) # REG_B XOR operand
    # echo "    REG_B=$REG_B, bxl $1 = $result, stored in REG_B"
    REG_B=$result #store result in B register
}
bst () {
    local operand=$1
    result=$(( operand % 8 ))
    # echo "    bst $1 = $result, stored in REG_B"
    REG_B=$result #store result in B register
}
jnz () {
    if [[ "$REG_A" = "0" ]]; then
        return
    fi
    local operand=$1
    HAS_JUMPED="true"
    # echo -n "    REG_A=$REG_A, jnz $1 moved INSTRUCTION_PTR $INSTRUCTION_PTR->"
    INSTRUCTION_PTR=$operand
    # echo "$INSTRUCTION_PTR"
}
bxc () {
    local operand=$1
    result=$(( REG_B ^ REG_C ))
    # echo "    REG_B=$REG_B, REG_C=$REG_C,  bxc $1 = $result, stored in REG_B"
    REG_B=$result #store result in B register
}
out () {
    local operand=$1
    result=$(( operand % 8 ))
    # echo "    out $1 = $result, stored in OUTPUT"
    OUTPUT="$OUTPUT,$result" #store result in OUTPUT
}
bdv () {
    local operand=$1
    local top=$REG_A
    local bottom=$((2**operand))
    result=$((top/bottom))
    # echo "    REG_A=$REG_A, bdv $1 = $result, stored in REG_B"
    REG_B=$result #store result in B register
}
cdv () {
    local operand=$1
    local top=$REG_A
    local bottom=$((2**operand))
    result=$((top/bottom))
    # echo "    REG_A=$REG_A, cdv $1 = $result, stored in REG_C"
    REG_C=$result #store result in C register
}


solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    i=0
    while read -r line; do
        read -ra line_arr <<< "$line"
        case "$i" in
            0) REG_A="${line_arr[2]}" ;;
            1) REG_B="${line_arr[2]}" ;;
            2) REG_C="${line_arr[2]}" ;;
            4) PROGRAM="${line_arr[1]}";;
        esac
        ((i++))
    done < $1
    IFS="," read -a PROGRAM <<< "$PROGRAM"

    echo "----- Initializing System -----"
    echo "REG_A: $REG_A | REG_B: $REG_B | REG_C: $REG_C"
    echo "PROGRAM: ${PROGRAM[*]}"
    echo 

    echo "----- Starting Program -----"
    while [[ "${PROGRAM[$INSTRUCTION_PTR]}" != "" ]]; do
        opcode="${PROGRAM[$INSTRUCTION_PTR]}"
        opcode_function="${OPCODE_TO_INSTRUCTION[$opcode]}"
        operand="${PROGRAM[$((INSTRUCTION_PTR+1))]}"
        echo "Executing opcode <$opcode> <$opcode_function> on operand <$operand>..."

        # If operand is a combo operand then do stuff
        operand_type="${OPCODE_OPERAND_TYPE[$opcode]}"
        if [[ "$operand_type" = "COMBO" ]]; then
            case "$operand" in
                "0"|"1"|"2"|"3") ;;
                "4") operand=$REG_A ;;
                "5") operand=$REG_B ;;
                "6") operand=$REG_C ;;
                "7") echo "Combo operand 7 found. This is not valid" >&2 ;;
                "*") echo "ERROR: Combo operand <$operand> unknown." >&2 ; exit 1 ;;
            esac
            echo "  Combo operand so new operand is <$operand>"
        fi

        eval $opcode_function $operand

        if [[ $HAS_JUMPED = "true" ]]; then
            HAS_JUMPED="false"
        else
            ((INSTRUCTION_PTR+=2))
        fi
    done

    OUTPUT=${OUTPUT:1}
    echo
    echo "----- End State of System -----"
    echo "REG_A: $REG_A | REG_B: $REG_B | REG_C: $REG_C"
    echo "OUTPUT: $OUTPUT"
    echo 

    answer=$OUTPUT

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

output_state() {
    OUTPUT=${OUTPUT:1}
    echo
    echo "Last REG_A attempt: $REG_A_ATTEMPT"
    echo "----- End State of System -----"
    echo "REG_A: $REG_A | REG_B: $REG_B | REG_C: $REG_C"
    echo "OUTPUT: $OUTPUT"
    echo 
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    i=0
    while read -r line; do
        read -ra line_arr <<< "$line"
        case "$i" in
            0) REG_A_ORG="${line_arr[2]}" ;;
            1) REG_B_ORG="${line_arr[2]}" ;;
            2) REG_C_ORG="${line_arr[2]}" ;;
            4) PROGRAM_STRING="${line_arr[1]}";;
        esac
        ((i++))
    done < $1
    IFS="," read -a PROGRAM <<< "$PROGRAM_STRING"

    trap output_state EXIT

    REG_A_ATTEMPT="2243330"
    while [[ "$PROGRAM_STRING" != "$OUTPUT" ]]; do
        ((REG_A_ATTEMPT+=1))
        # Reinitialise
        REG_A=$REG_A_ATTEMPT
        REG_B=$REG_B_ORG
        REG_C=$REG_C_ORG
        INSTRUCTION_PTR="0"
        HAS_JUMPED="false"
        OUTPUT=""

        # echo "----- Initializing System -----"
        # echo "REG_A: $REG_A | REG_B: $REG_B | REG_C: $REG_C"
        # echo "PROGRAM: $PROGRAM_STRING | ${PROGRAM[*]}"

        # echo "----- Starting Program -----"
        while [[ "${PROGRAM[$INSTRUCTION_PTR]}" != "" ]]; do
            opcode="${PROGRAM[$INSTRUCTION_PTR]}"
            opcode_function="${OPCODE_TO_INSTRUCTION[$opcode]}"
            operand="${PROGRAM[$((INSTRUCTION_PTR+1))]}"
            # echo "Executing opcode <$opcode> <$opcode_function> on operand <$operand>..."

            # If operand is a combo operand then do stuff
            operand_type="${OPCODE_OPERAND_TYPE[$opcode]}"
            if [[ "$operand_type" = "COMBO" ]]; then
                case "$operand" in
                    "0"|"1"|"2"|"3") ;;
                    "4") operand=$REG_A ;;
                    "5") operand=$REG_B ;;
                    "6") operand=$REG_C ;;
                    "7") echo "Combo operand 7 found. This is not valid" >&2 ;;
                    "*") echo "ERROR: Combo operand <$operand> unknown." >&2 ; exit 1 ;;
                esac
                # echo "  Combo operand so new operand is <$operand>"
            fi

            eval $opcode_function $operand

            if [[ $HAS_JUMPED = "true" ]]; then
                HAS_JUMPED="false"
            else
                ((INSTRUCTION_PTR+=2))
            fi
        done

        OUTPUT=${OUTPUT:1}
        # echo "----- End State of System -----"
        # echo "REG_A: $REG_A | REG_B: $REG_B | REG_C: $REG_C"
        # echo "OUTPUT: $OUTPUT"
        # echo 

    done

    answer=$REG_A_ATTEMPT

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt

# solution_2 example_input_2.txt # 117440 Took 93 seconds
# echo
solution_2 input.txt
