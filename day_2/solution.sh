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


solution_2 () {
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

# solution_1 example_input.txt
# echo
# solution_1 input.txt

solution_2 example_input.txt
echo
solution_2 input.txt