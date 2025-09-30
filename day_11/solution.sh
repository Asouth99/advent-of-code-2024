#!/usr/bin/env bash

# Part 1
# Get given a list of 'stones (numbers separated by spaces)'
# Every blink the stones change according to the following rules:
# - If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
# - If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. 
#   The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone.
#   (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
# - If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
# EG:
# Initial arrangement:
# 125 17

# After 1 blink:
# 253000 1 7

# After 2 blinks:
# 253 0 2024 14168

# After 3 blinks:
# 512072 1 20 24 28676032

# After 4 blinks:
# 512 72 2024 2 0 2 4 2867 6032

# After 5 blinks:
# 1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32

# After 6 blinks:
# 2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2


solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    NUM_BLINKS=25
    read -ra stones < "$1"

    starting_stones=("${stones[@]}")
    ALL_ZEROS_REGEX="^0*$"
    STARTING_ZEROS_REGEX="^0+([0-9]*)$"
    for ((num_blink = 1 ; num_blink < $((NUM_BLINKS+1)) ; num_blink++ )); do
        ending_stones=()
        echo "Blink #$num_blink"
        # echo "  Starting stones: ${stones[*]}"

        for ((i = 0 ; i < "${#stones[*]}" ; i++ )); do
            stone="${stones[i]}"
            # if [[ "${stone:0:1}" = "0" && "${#stone}" -lt "1" ]]; then
            #     echo "ERROR: starting zero detected in $stone"
            # fi
            if [[ "$stone" == "0" ]]; then
                # Replace 0 with 1
                ending_stones+=("1")
            elif [[ $(("${#stone}" % 2)) == "0" ]]; then
                # split number in half. Left and right are new stones 
                #   (remove trailing 0s) 100000 -> 100 and 0
                #   (remove leading 0s) 512072 -> 512 and 72
                digit_count=$(( ${#stone} / 2))
                left=${stone::digit_count}
                right=${stone:digit_count}
                if [[ "$right" =~ $ALL_ZEROS_REGEX ]]; then
                    right="0"
                elif [[ "$right" =~ $STARTING_ZEROS_REGEX ]]; then
                    right="${BASH_REMATCH[1]}"
                fi
                ending_stones+=("$left")
                ending_stones+=("$right")
            else
                # Stones value multiplied by 2024
                stone_to_add=$(( stone * 2024 ))
                ending_stones+=("$stone_to_add")
            fi
        done

        stones=("${ending_stones[@]}")
        # echo "  End stones: ${stones[*]}"
    done
    
    answer=${#stones[*]}

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
solution_1 input.txt


# solution_2 example_input.txt
# echo
# solution_2 input.txt 
