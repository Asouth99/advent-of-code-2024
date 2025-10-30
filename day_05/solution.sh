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

solution_2 () {
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
            # echo "  Checking page $value"
            new_i=""
            # if [[ "$valid_update" == "false" ]]; then break; fi
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
            previous_values=("${update_arr[*]:0:$i}")
            for v in ${nums_right_violations[*]}; do
                # echo "    Searching for $v"
                prev_v_index=0
                for prev_v in ${previous_values[*]}; do
                    if [[ "$prev_v" == "$v" ]]; then
                        # echo "    $value appears after $v"
                        valid_update=false
                        if [[ ! -z "$new_i" ]]; then
                            index=$new_i
                        else
                            index=$i
                        fi
                        # echo "      Need to swap ${update_arr[$index]} and ${update_arr[$prev_v_index]}"
                        new_i=$prev_v_index
                        tmp=${update_arr[$index]}
                        update_arr[$index]=${update_arr[$prev_v_index]}
                        update_arr[$prev_v_index]=$tmp
                        # echo "      Previous Values: ${previous_values[*]}"
                        echo "      New update: ${update_arr[*]}"
                        previous_values=("${update_arr[*]:0:$i}")
                        # echo "      Previous Values update: ${previous_values[*]}"
                    fi
                    ((prev_v_index++))
                done
                # if [[ "$valid_update" == "false" ]]; then break; fi
            done
            ((i++))
        done
        if [[ "$valid_update" == "true" ]]; then
            echo "VALID"
            # middle_index=$(( ${#update_arr[*]} / 2 + ${#update_arr[*]} % 2 - 1))
            # echo $middle_index
            # answer=$((answer + ${update_arr[$middle_index]}))
        else
            echo "INVALID"
            middle_index=$(( ${#update_arr[*]} / 2 + ${#update_arr[*]} % 2 - 1))
            # echo $middle_index
            answer=$((answer + ${update_arr[$middle_index]}))
        fi
    done

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_1 example_input.txt
echo
solution_1 input.txt # Took 83 seconds to calculate

# solution_2 example_input.txt
# echo
# solution_2 input.txt