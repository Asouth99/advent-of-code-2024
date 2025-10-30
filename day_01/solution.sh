#!/usr/bin/env bash

solution_1 () {

    echo "Reading file: $1"
    local left=()
    local right=()
    while read -r line; do
        # echo "Line: $line"
        left+=("${line%% *}")
        right+=("${line##* }")
    done < $1

    IFS=$'\n'
    left=($(sort -n <<<"${left[*]}"))
    right=($(sort -n <<<"${right[*]}"))
    unset $IFS

    # echo "Left: ${left[*]}"
    # echo
    # echo "Right: ${right[*]}"

    local answer=0
    local i=0
    for num in ${left[@]}; do
        l_n=$num
        r_n="${right[$i]}"
        # echo "Left: $l_n | Right: $r_n" 
        diff=$(($l_n - $r_n))
        diff="${diff/#-}"
        # echo "Diff: $diff"
        answer=$(($answer + $diff))
        ((i++))
    done
    echo "Answer is: $answer"
}


solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    local left=()
    local right=()
    while read -r line; do
        # echo "Line: $line"
        left+=("${line%% *}")
        right+=("${line##* }")
    done < $1

    # No longer need to sort the lists
    # IFS=$'\n'
    # left=($(sort -n <<<"${left[*]}"))
    # right=($(sort -n <<<"${right[*]}"))
    # unset $IFS
    
    local answer=0
    local i=0
    for l_n in ${left[@]}; do
        local count=0
        for r_n in ${right[@]}; do
            [[ l_n -eq r_n ]] && ((count++))
            # echo "left: ${l_n} | right: ${r_n} | count: ${count}"
        done
        answer=$((answer + $l_n * $count))
        ((i++))
    done
    
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$(($seconds_end - $seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# solution_1 input.txt

solution_2 example_input.txt
echo
solution_2 input.txt