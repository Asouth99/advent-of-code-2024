#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    nums_left=()
    nums_right=()
    updates=()
    NUMS_REGEX="^([0-9]{1,3})\\|([0-9]{1,3})$"
    UPDATES_REGEX="^[0-9]+(,[0-9]+)+$"
    while read -r line; do
        ((line_num++))
        # echo "$line_num: $line"
        if [[ $line =~ $NUMS_REGEX ]]; then
            # echo ${BASH_REMATCH[*]}
            nums_left+=("${BASH_REMATCH[1]}")
            nums_right+=("${BASH_REMATCH[2]}")
        elif [[ $line =~ $UPDATES_REGEX ]]; then
            updates+=("$line")
        fi
    done < "$1"

    # echo "Left numbers: ${nums_left[*]}"
    # echo "Right numbers: ${nums_right[*]}"
    # echo "Updates: ${updates[*]}"

    for update in ${updates[*]}; do
        IFS=','
        read -ra update_arr <<< "$update"
        unset IFS
        echo
        echo "Validating update $update"
        valid_update=true
        i=0
        for value in ${update_arr[*]}; do
            if [[ "$valid_update" == "false" ]]; then break; fi
            # Check if value exists in the nums_right list.
            nums_right_violations=() # If any number in this list comes before $value then it is a BAD update
            j=0
            for v in ${nums_left[*]}; do
                if [[ "$v" == "$value" ]]; then
                    nums_right_violations+=(${nums_right[$j]})
                fi
                ((j++))
            done
            # echo "Right numbers to search for: ${nums_right_violations[*]}"
            
            # Check if any number in $nums_right_violations comes before $value
            previous_values="${update_arr[*]:0:$i}"
            for v in ${nums_right_violations[*]}; do
                if echo "$previous_values" | grep -q "$v"; then
                    echo "$value appears after $v"
                    valid_update=false
                fi
                if [[ "$valid_update" == "false" ]]; then break; fi
            done
            ((i++))
        done
        if [[ "$valid_update" == "true" ]]; then
            echo "VALID"
            middle_index=$(( ${#update_arr[*]} / 2 + ${#update_arr[*]} % 2 - 1))
            # echo $middle_index
            answer=$((answer + ${update_arr[$middle_index]}))
        else
            echo "INVALID"
        fi
    done

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

is_valid_update() {
    # Requires global variable rules

    local update=$1
    local -n all_rules=$2
    local update_arr needs_to_appear_after needs_to_appear_after_arr 
    local -A needs_to_appear_after_hash=()
    local ii jj
    local num u

    IFS="," read -ra update_arr <<< "$update"
    ii=0
    for u in "${update_arr[@]}"; do
        # echo "  Checking value $u"

        # Check what values $u needs to appear after
        needs_to_appear_after="${all_rules[$u]}"
        IFS="," read -ra needs_to_appear_after_arr <<< "$needs_to_appear_after"
            # Read into a hash table kinda
        needs_to_appear_after_hash=()
        for num in "${needs_to_appear_after_arr[@]}"; do
            needs_to_appear_after_hash["$num"]="true"
        done

        # Echo needs_to_appear_after_hash for debugging
        # echo -n "    needs_to_appear_after_hash: "
        # for num in "${!needs_to_appear_after_hash[@]}"; do
        #     echo -n "$num,"
        # done
        # echo

        # Checking if any values left in the update appear in the needs_to_appear_after_hash table
        for ((jj = ($ii+1) ; jj < ${#update_arr[*]} ; jj++ )); do
            local u2="${update_arr[$jj]}"
            if [[ "${needs_to_appear_after_hash[$u2]}" = "true" ]]; then
                # echo $'\033[0;33m'"$u2 appears after $u"$'\033[0;0m' >&2

                if [[ "${indexes_to_swap[$update]}" = "" ]]; then
                    indexes_to_swap["$update"]="$jj,$ii"
                else
                    indexes_to_swap["$update"]="${indexes_to_swap[$update]},$jj,$ii"
                fi
                return 1
            fi
        done

        ((ii++))
    done

    return 0
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0


    # Read input
    declare -gA rules=() # rules[x] = a,b,c,d -> means x must appear after a,b,c and d otherwise it is invalid
    declare -ga updates=() 
    NUMS_REGEX="^([0-9]{1,3})\\|([0-9]{1,3})$"
    UPDATES_REGEX="^[0-9]+(,[0-9]+)+$"
    while read -r line; do
        ((line_num++))
        # echo "$line_num: $line"
        if [[ $line =~ $NUMS_REGEX ]]; then
            left="${BASH_REMATCH[1]}"
            right="${BASH_REMATCH[2]}"
            
            if [[ "${rules[$right]}" = "" ]]; then
                rules["$right"]="$left"
            else
                rules["$right"]="${rules[$right]},$left"
            fi
        elif [[ $line =~ $UPDATES_REGEX ]]; then
            updates+=("$line")
        fi
    done < "$1"

    # Echo input
    echo "Rules:"
    for r in "${!rules[@]}"; do
        echo "  $r=${rules[$r]}"
    done
    echo "Updates:"
    for u in "${!updates[@]}"; do
        echo "  $u : ${updates[$u]}"
    done
    echo

    # Check if each update is valid or invalid. If invalid then add to indexes_to_swap
    declare -gA indexes_to_swap=() # indexes_to_swap[$update_string]=0,3 -> indexes 0 and 3 need to swap in update_string
    invalid_updates=()
    echo "Checking if updates are valid..."
    for u in "${updates[@]}"; do
        # echo "Checking $u"
        if is_valid_update "$u" rules; then
            echo $'\033[0;32m'"  $u --> VALID"$'\033[0m'
        else
            echo $'\033[0;31m'"  $u --> INVALID"$'\033[0m'
            invalid_updates+=("$u")
        fi
    done
    echo

    # For each invalid update work out how to make them valid
    declare -a updates_for_answer=()
    for update in "${!indexes_to_swap[@]}"; do
        echo -n "Swapping indexes for $update --> "
        IFS="," read -ra u_arr <<< "$update"

        # echo "$update -> ${indexes_to_swap[$update]}"

        i=0
        while [[ "${indexes_to_swap[$update]}" != "" ]]; do
            # if [[ $i -gt "1" ]]; then break; fi

            # Swap the indexes
            indexes="${indexes_to_swap[$update]}"
            IFS="," read -ra indexes_arr <<< "$indexes"
            for ((ii = 0 ; ii < ${#indexes_arr[*]} ; ii+=2 )); do
                index_1="${indexes_arr[$ii]}"
                index_2="${indexes_arr[$((ii+1))]}"

                # echo "  Swapping $index_1 and $index_2"
                # echo -n "${u_arr[*]} -> "
                tmp="${u_arr[$index_1]}"
                u_arr["$index_1"]="${u_arr[$index_2]}"
                u_arr["$index_2"]="$tmp"
                # echo "${u_arr[*]}"
            done

            # Check if the new update is valid
            update="${u_arr[*]}"
            update="${update// /,}"
            is_valid_update "$update" rules
            
            ((i++))
        done
        echo "$update"
        updates_for_answer+=("$update")
    done




    # Add up middle values
    for u in "${updates_for_answer[@]}"; do
        IFS="," read -ra u_arr <<< "$u"
        middle_index=$(( ${#u_arr[@]} / 2 ))
        (( answer += ${u_arr[$middle_index]}))
    done


    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
echo
# solution_1 input.txt # Took 83 seconds to calculate

# solution_2 example_input.txt
# echo
solution_2 input.txt