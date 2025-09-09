#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    rows=$(wc -l "$1" | cut -d ' ' -f1)
    chars=$(wc -m "$1" | cut -d ' ' -f1)
    cols=$((chars / rows - 1))
    echo "$1 has $rows rows and $cols columns"

    declare -a map_arr
    guard_pos=""
    j=0
    while read -r line; do
        # echo "Line: $line"
        for ((i = 0 ; i < "$cols" ; i++ )); do
            if [[ "${line:$i:1}" == "^" ]]; then
                guard_pos=$(( j * cols + i ))
            fi
            map_arr+=("${line:$i:1}")
        done
        ((j++))
    done < "$1"

    guard_row=$((guard_pos / $cols )) # y position
    guard_col=$((guard_pos % $cols )) # x position
    echo "Guard is at (${guard_col}, ${guard_row})"

    guard_is_in_lab=true
    guard_direction="0"
    i=0
    while [[ $guard_is_in_lab == "true" ]] ; do
        
        map_arr[guard_pos]="X"

        case $guard_direction in
            "0")
                # UP
                new_pos=$(( guard_pos - cols ))
                if [[ "$new_pos" -lt "0" ]]; then
                    echo "Guard escaped!"
                    guard_is_in_lab="false"
                elif [[ "${map_arr[$new_pos]}" == "#" ]]; then
                    guard_direction=$(((guard_direction + 1) % 4))
                    # echo "  Found obstacle. New direction is ${guard_direction}."
                else 
                    # Guard can move
                    guard_pos=$new_pos
                    guard_row=$((guard_pos / $cols )) # y position
                    guard_col=$((guard_pos % $cols )) # x position
                    # echo "  Guard moved up to (${guard_col}, ${guard_row})"
                fi
                ;;
            "1")
                # RIGHT
                new_pos=$(( guard_pos + 1 ))
                if [[ $((new_pos % cols )) -gt $((cols - 1)) ]]; then
                    echo "Guard escaped!"
                    guard_is_in_lab="false"
                elif [[ "${map_arr[$new_pos]}" == "#" ]]; then
                    guard_direction=$(((guard_direction + 1) % 4))
                    # echo "  Found obstacle. New direction is ${guard_direction}."
                else 
                    # Guard can move
                    guard_pos=$new_pos
                    guard_row=$((guard_pos / $cols )) # y position
                    guard_col=$((guard_pos % $cols )) # x position
                    # echo "  Guard moved right to (${guard_col}, ${guard_row})"
                fi
                ;;
            "2")
                # DOWN
                new_pos=$(( guard_pos + cols ))
                if [[ "$new_pos" -gt $(( rows * cols )) ]]; then
                    echo "Guard escaped!"
                    guard_is_in_lab="false"
                elif [[ "${map_arr[$new_pos]}" == "#" ]]; then
                    guard_direction=$(((guard_direction + 1) % 4))
                    # echo "  Found obstacle. New direction is ${guard_direction}."
                else 
                    # Guard can move
                    guard_pos=$new_pos
                    guard_row=$((guard_pos / $cols )) # y position
                    guard_col=$((guard_pos % $cols )) # x position
                    # echo "  Guard moved down to (${guard_col}, ${guard_row})"
                fi
                ;;
            "3")
                # LEFT
                new_pos=$(( guard_pos - 1 ))
                if [[ $((new_pos % cols )) -lt 0 ]]; then
                    echo "Guard has escaped!"
                    guard_is_in_lab="false"
                elif [[ "${map_arr[$new_pos]}" == "#" ]]; then
                    guard_direction=$(((guard_direction + 1) % 4))
                    # echo "  Found obstacle. New direction is ${guard_direction}."
                else 
                    # Guard can move
                    guard_pos=$new_pos
                    guard_row=$((guard_pos / $cols )) # y position
                    guard_col=$((guard_pos % $cols )) # x position
                    # echo "  Guard moved left to (${guard_col}, ${guard_row})"
                fi
                ;;
        esac
        [[ $i -gt "1000000" ]] && guard_is_in_lab="false" # Just to catch it if we get stuck in an endless loop
        ((i++))
    done
    
    # print out map nicely for debugging
    for ((i = 0 ; i < "$cols" ; i++ )); do
        for ((j = 0 ; j < "$rows" ; j++ )); do
            echo -n "${map_arr[$((i * cols + j))]}"
            [[ "${map_arr[$((i * cols + j))]}" == "X" ]] && ((answer++))
        done
        echo
    done    


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