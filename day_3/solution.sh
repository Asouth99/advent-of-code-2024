#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    full_string=""
    MUL_REGEX="mul\\(([0-9]*),([0-9]*)\\)"
    while read -r line; do
        full_string+=$'\n'
        full_string+=$(grep -oP "$MUL_REGEX" <<< "$line")
    done < "$1"

    
    while read -r line; do
        # echo "Line: $line"
        if [[ $line =~ $MUL_REGEX ]]; then
            n_1=${BASH_REMATCH[1]}
            n_2=${BASH_REMATCH[2]}
            # echo "N1: $n_1 | N2: $n_2"
            answer=$((answer + n_1 * n_2))
        fi
    done <<< "$full_string"


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    full_string=""
    MUL_REGEX="mul\\(([0-9]*),([0-9]*)\\)"
    DO_REGEX="do\\(\\)"
    DONT_REGEX="don't\\(\\)"
    while read -r line; do
        full_string+=$'\n'
        full_string+=$(grep -oP "$MUL_REGEX|$DO_REGEX|$DONT_REGEX" <<< "$line")
    done < "$1"

    do_enabled=true
    while read -r line; do
        # echo "Line: $line"
        if [[ $line =~ $DO_REGEX ]]; then
            do_enabled=true
        elif [[ $line =~ $DONT_REGEX ]]; then
            do_enabled=false
        elif [[ $line =~ $MUL_REGEX ]]; then
            n_1=${BASH_REMATCH[1]}
            n_2=${BASH_REMATCH[2]}
            # echo "N1: $n_1 | N2: $n_2"
            if [[ "$do_enabled" == "true" ]]; then
                answer=$((answer + n_1 * n_2))
            fi
        fi
    done <<< "$full_string"

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt

solution_2 example_input_2.txt
echo
solution_2 input.txt