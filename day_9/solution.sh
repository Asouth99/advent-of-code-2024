#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    echo

    # Read input
    echo "step 0 - reading number"
    declare -a input_number=()
    while read -r -n 1 char; do
        input_number+=("$char")
    done < "$1"
    for num in "${input_number[@]}"; do # Echo input number
        echo -n "$num"
    done
    echo

    # Format number
    declare -a formatted_number=()
    digit_count=0
    echo
    echo "step 1 - formatting number"
    for ((i = 0 ; i < "${#input_number[@]}" ; i++ )); do
        number="${input_number[$i]}"
        if [[ $((i % 2)) = "0" ]]; then
            char="$((i/2))"
            ((digit_count+=number))
        else
            char="."
        fi
        for ((j = 0 ; j < number ; j++ )); do
            formatted_number+=("$char")
        done
    done
    for num in "${formatted_number[@]}"; do # Echo formatted number
        echo -n "$num"
    done
    echo
    echo "There are $digit_count digits in the formatted number"

    # Rearrange number
    declare -a rearraneged_number=()
    echo
    echo "step 2 - rearrange number"
    end_index=$(( ${#formatted_number[@]} - 1 ))
    for ((i = 0 ; i < digit_count ; i++ )); do
        char="${formatted_number[$i]}"

        end_char="${formatted_number[$end_index]}"
        while [[ "$end_char" = "." ]]; do
            ((end_index--))
            if [[ "$end_index" -lt "0" ]]; then break; fi
            end_char="${formatted_number[$end_index]}"
        done

        if [[ "$char" = "." ]]; then
            rearraneged_number+=("$end_char")
            ((end_index--))
        else
            rearraneged_number+=("$char")
        fi
    done
    for num in "${rearraneged_number[@]}"; do # Echo rearranged number
        echo -n "$num"
    done
    echo

    # Calculate checksum
    checksum="0"
    echo
    echo "step 3 - calculating checksum"
    for ((i = 0 ; i < ${#rearraneged_number[@]} ; i++ )); do
        char="${rearraneged_number[$i]}"
        (( checksum+=($i * $char) ))
    done
    echo "Checksum is $checksum"

    answer="$checksum"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}



solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    
    # Test how much a var can store in bash
    # a=""
    # for ((i = 0 ; i < 30000 ; i++ )); do
    #     a="${a}1"
    # done
    # echo "$a" > test.txt

    # a=()
    # for ((i = 0 ; i < 300000 ; i++ )); do
    #     a+=("1")
    # done
    # echo "${a[@]}" > test2.txt

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}


# solution_1 example_input.txt
# echo
# solution_1 input.txt # 6299243228569 took 10 seconds

# solution_2 example_input.txt
# echo
# solution_2 input.txt 


6299243228569