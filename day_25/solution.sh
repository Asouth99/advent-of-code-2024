#!/usr/bin/env bash

key_fits_lock() {
    local k=$1
    local l=$2
    local k_arr l_arr

    IFS=" " read -r -a k_arr <<< "$k"
    IFS=" " read -r -a l_arr <<< "$l"

    for (( i = 0 ; i < "${#k_arr[@]}" ; i++ )); do
        # echo "key: ${k_arr[$i]} and lock: ${l_arr[$i]}"
        if [[ $(( ${k_arr[$i]} + ${l_arr[$i]} )) -gt "5" ]]; then
            # echo "OVERLAPPING"
            return 1
        fi
    done
    return 0 
}

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    declare -a key_heights=()
    declare -a lock_heights=()

    while mapfile -t -n 8 array && ((${#array[@]})); do
        top="${array[0]}"
        bottom="${array[6]}"

        if [[ "$top" = "#####" ]]; then
            is_key="false"
        elif [[ "$bottom" = "#####" ]]; then
            is_key="true"
        else
            echo "ERROR: Parsing input failed" >&2
            exit 1
        fi

        heights=( "0" "0" "0" "0" "0" )
        if [[ "$is_key" = "false" ]]; then
            for (( i = 5 ; i > 0 ; i-- )); do
                line="${array[$i]}"
                for (( j = 0 ; j < 5 ; j++ )); do
                    if [[ "${line:$j:1}" = "#" && "${heights[$j]}" = "0" ]]; then
                        heights["$j"]="$i"
                    fi
                done
            done
            lock_heights+=("${heights[*]}")
        else
            for (( i = 1 ; i < 6 ; i++ )); do
                line="${array[$i]}"
                for (( j = 0 ; j < 5 ; j++ )); do
                    if [[ "${line:$j:1}" = "#" && "${heights[$j]}" = "0" ]]; then
                        heights["$j"]="$((6-i))"
                    fi
                done
            done
            key_heights+=("${heights[*]}")
        fi
    done < "$1"

    echo "-- Lock Heights --"
    for lock_height in "${lock_heights[@]}"; do
        echo "  $lock_height"
    done
    echo "-- Key Heights --"
    for key_height in "${key_heights[@]}"; do
        echo "  $key_height"
    done

    # Testing each lock against each key
    echo "-- Testing keys against locks --"
    num="0"
    for lock in "${lock_heights[@]}"; do
        for key in "${key_heights[@]}"; do
            echo "  Testing L:$lock with K:$key"
            if key_fits_lock "$key" "$lock"; then
                ((num++))
            fi
        done
    done
    echo "There are $num unique lock/key pairs"

    answer="$num"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
solution_1 input.txt # 3223 - took 8 seconds

# solution_2 example_input.txt
# echo
# solution_2 input.txt
