#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    IFS=' '
    answer=0
    while read -r line; do
        read -ra line_arr <<< $line
        
        local decreasing=false
        local increasing=false
        local safe=true
        for ((i = 0 ; i < $(( ${#line_arr[*]}-1 )); i++ )); do
            diff=$(( ${line_arr[$i]} - ${line_arr[ $(($i+1)) ]} ))

            # If absolute diff is greater than 3 then it is unsafe
            [[ $diff -gt 3 ]] && safe=false && break
            [[ $diff -lt -3 ]] && safe=false && break
            
            if [[ $diff -lt 0 ]]; then
                [[ "$decreasing" == "true" ]] && safe=false && break
                decreasing=false
                increasing=true
            elif [[ $diff -eq 0 ]]; then
                decreasing=false
                increasing=false
                safe=false # All numbers need to be increasing or decreasing
            else
                [[ "$increasing" == "true" ]] && safe=false
                decreasing=true
                increasing=false
            fi
        done 
        # echo "Line: $line | Safe: $safe"
        [[ "$safe" == "true" ]] && ((answer++))
    done < $1
    unset $IFS

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$(($seconds_end - $seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}


is_safe () { # returns 0 if SAFE. Else returns 1
    local decreasing=false
    local increasing=false
    local safe=true
    array=("$@")
    # echo "Array is ${array[*]}"
    for ((i = 0 ; i < $(( ${#array[*]}-1 )); i++ )); do
        diff=$(( ${array[$i]} - ${array[ $((i+1)) ]} ))

        # If absolute diff is greater than 3 then it is unsafe
        [[ $diff -gt 3 ]] && safe=false && break
        [[ $diff -lt -3 ]] && safe=false && break
        
        if [[ $diff -lt 0 ]]; then
            [[ "$decreasing" == "true" ]] && safe=false && break
            decreasing=false
            increasing=true
        elif [[ $diff -eq 0 ]]; then
            decreasing=false
            increasing=false
            safe=false # All numbers need to be increasing or decreasing
        else
            [[ "$increasing" == "true" ]] && safe=false
            decreasing=true
            increasing=false
        fi
    done
    [[ "$safe" == "true" ]] && return 0 || return 1
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"

    IFS=' '
    answer=0
    while read -r line; do
        read -ra line_arr <<< "$line"
        # echo "Line_arr: ${line_arr[*]}"
        
        local safe=false
        if ( is_safe "${line_arr[@]}" ); then
            safe=true
        else
            # If the original array is not safe then try deleting each index and check if each of those are safe
            for ((j = 0 ; j < ${#line_arr[*]} ; j++ )); do
                new_arr=()
                for ((i = 0 ; i < ${#line_arr[*]} ; i++ )); do
                    [[ $j -eq $i ]] || new_arr+=("${line_arr[$i]}")
                done
                # echo "New_arr: ${new_arr[*]}"
                if ( is_safe "${new_arr[@]}" ); then
                    safe=true
                fi
                [[ "$safe" == "true" ]] && break
            done
        fi
        [[ "$safe" == "true" ]] && ((answer++))
    done < $1
    unset $IFS


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt

solution_2 example_input.txt
echo
solution_2 input.txt