#!/usr/bin/env bash

connected () {
    local c1=$1
    local c2=$2
    if [[ "$c1" < "$c2" ]]; then
        if [[ "${connections[$c1,$c2]}" = "true" ]] ; then
            return 0
        fi
    else
        if [[ "${connections[$c2,$c1]}" = "true" ]] ; then
            return 0
        fi
    fi
    return 1
}

all_connected () {
    local c1=$1
    local c2=$2
    local c3=$3

    if connected "$c1" "$c2" && connected "$c1" "$c3" && connected "$c2" "$c3"; then
        return 0
    fi

    return 1
}


solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    declare -A computers_start=()
    declare -A connections=()
    while read -r line; do
        IFS="-" read -r c1 c2 <<< "$line"
        computers_start["$c1"]="true"
        computers_start["$c2"]="true"
        
        if [[ "$c1" < "$c2" ]]; then
            connections["$c1,$c2"]="true"
        else
            connections["$c2,$c1"]="true"
        fi
    done < $1
    echo "There are ${#computers_start[@]} different computers"
    echo "There are ${#connections[@]} different connections"

    # We only care about computers that are connected to a computer that starts with 't'. So generate this list instead
    declare -A computers=()
    for connection in "${!connections[@]}"; do
        IFS="," read -r c1 c2 <<< "$connection"
        if [[ "${c1::1}" = "t" || "${c2::1}" = "t" ]]; then
            computers["$c1"]="true"
            computers["$c2"]="true"
        fi
    done
    echo "There are ${#computers[@]} different computers connected to a computer starting with 't'"

    # Create a non associative array of all computers
    declare -a computers_arr=()
    for computer in "${!computers[@]}"; do
        computers_arr+=("$computer")
    done

    # Generate all the different combination of 3 computers. We will then check everyone to see if the 3 computers are connected
    declare -a computer_combinations=()
    for ((i = 0 ; i < ${#computers_arr[@]} ; i++ )); do
        c1="${computers_arr[$i]}"
        # echo "  ($((i+1))/${#computers_arr[@]}) generating combinations for <$c1>"
        for ((j = (i+1) ; j < ${#computers_arr[@]} ; j++ )); do
            c2="${computers_arr[$j]}"
            for ((k = (j+1) ; k < ${#computers_arr[@]} ; k++ )); do
                c3="${computers_arr[$k]}"
                # Make sure at least one of them start with a 't'
                if [[ "${c1::1}" = "t" || "${c2::1}" = "t" || "${c3::1}" = "t" ]]; then
                    computer_combinations+=("$c1,$c2,$c3")
                fi
            done
        done
    done
    echo "Generated ${#computer_combinations[*]} different combinations of 3 computers where at least on starts with a 't'"

    # Go through each computer_combination and check if all computers are connected
    echo "Checking ${#computer_combinations[*]} different computer combinations"
    declare -a connected_combinations=()
    for combination in "${computer_combinations[@]}"; do
        IFS="," read -r c1 c2 c3 <<< "$combination"
        # echo -n "  Checking $combination --> "
        if all_connected "$c1" "$c2" "$c3"; then
            connected_combinations+=("$combination")
            # echo $'\033[0;32m'"Connected!"$'\033[0m'
        # else 
            # echo $'\033[0;31m'"Not Connected!"$'\033[0m'
        fi
    done
    echo "There are ${#connected_combinations[*]} combinations of connected computers"

    # DEBUG: Output all connected combinations just to view
    # for combination in "${connected_combinations[@]}"; do
    #     echo "$combination"
    # done

    answer="${#connected_combinations[*]}"

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

    declare -A computers_start=()
    declare -A connections=()
    while read -r line; do
        IFS="-" read -r c1 c2 <<< "$line"
        computers_start["$c1"]="true"
        computers_start["$c2"]="true"
        
        if [[ "$c1" < "$c2" ]]; then
            connections["$c1,$c2"]="true"
        else
            connections["$c2,$c1"]="true"
        fi
    done < $1
    echo "There are ${#computers_start[@]} different computers"
    echo "There are ${#connections[@]} different connections"

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt # 1411 took 64 seconds

# solution_2 example_input.txt
# echo
# solution_2 input.txt
