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


print_map () {
    local cols=$1
    local rows=$2
    local -n array=$3
    local i
    # print out map nicely for debugging
    for ((i = 0 ; i < "$cols" ; i++ )); do
        for ((j = 0 ; j < "$rows" ; j++ )); do
            echo -n "${array[$((i * cols + j))]}"
        done
        echo
    done
}

can_escape () { # returns 0 if CAN_ESCAPE. Else returns 1
    local -n array=$1
    local start_index=$2
    local guard_start_index=$2
    local guard_is_in_lab=true
    local guard_stuck_in_loop=false
    local guard_direction="0"
    local i=0
    # local path_since_last_obstacle=()
    local postions_where_guard_has_travelled_up=()
    local postions_where_guard_has_travelled_right=()
    local postions_where_guard_has_travelled_down=()
    local postions_where_guard_has_travelled_left=()

    while [[ $guard_is_in_lab == "true" ]] ; do
        
        # path_since_last_obstacle+=("${array[$start_index]}")
        array[start_index]="X"

        case $guard_direction in
            "0")
                # UP
                new_index=$(( start_index - cols ))
                postions_where_guard_has_travelled_up[$start_index]=true
                if [[ "$new_index" -lt "0" ]]; then
                    guard_is_in_lab="false"
                fi
                ;;
            "1")
                # RIGHT
                new_index=$(( start_index + 1 ))
                postions_where_guard_has_travelled_right[$start_index]=true
                if [[ $((new_index % cols )) == 0 ]]; then
                    guard_is_in_lab="false"
                fi
                ;;
            "2")
                # DOWN
                new_index=$(( start_index + cols ))
                postions_where_guard_has_travelled_down[$start_index]=true
                if [[ "$new_index" -gt $(( rows * cols )) ]]; then
                    guard_is_in_lab="false"
                fi
                ;;
            "3")
                # LEFT
                new_index=$(( start_index - 1 ))
                postions_where_guard_has_travelled_left[$start_index]=true
                if [[ $((new_index % cols )) == $((cols - 1)) ]]; then
                    guard_is_in_lab="false"
                fi
                ;;
        esac

        if [[ "$guard_is_in_lab" == "false" ]]; then
            break
        # elif [[ "$guard_stuck_in_loop" == "true" ]]; then
        # elif [[ "${array[$new_index]}" == "X" ]]; then
        #     case $guard_direction in
        #         "0")
        #             if [[ "${postions_where_guard_has_travelled_up[$new_index]}" == "true" ]]; then
        #                 guard_stuck_in_loop=true
        #             fi
        #             ;;
        #         "1")
        #             if [[ "${postions_where_guard_has_travelled_right[$new_index]}" == "true" ]]; then
        #                 guard_stuck_in_loop=true
        #             fi
        #             ;;
        #         "2")
        #             if [[ "${postions_where_guard_has_travelled_down[$new_index]}" == "true" ]]; then
        #                 guard_stuck_in_loop=true
        #             fi
        #             ;;
        #         "3")
        #             if [[ "${postions_where_guard_has_travelled_left[$new_index]}" == "true" ]]; then
        #                 guard_stuck_in_loop=true
        #             fi
        #             ;;
        #     esac
        #     if [[ "$guard_stuck_in_loop" == "true" ]]; then
        #         echo "Guard is stuck in a loop!"
        #         break
        #     fi
        elif [[ "${array[$new_index]}" == "#" ]]; then
            guard_direction=$(((guard_direction + 1) % 4))

            # Check if the path_since_last_obstacle is ALL X
            # echo "    Path since last obstacle: ${path_since_last_obstacle[*]}"
            # x_count=0
            # for char in ${path_since_last_obstacle[*]}; do
            #     [[ "$char" == "X" ]] && ((x_count++))
            # done
            # if [[ "$x_count" == "${#path_since_last_obstacle[@]}" && "$x_count" -gt "1" && "$guard_start_index" != "$start_index" ]]; then
                # guard_row=$((start_index / $cols + 1)) # y position
                # guard_col=$((start_index % $cols + 1)) # x position
                # echo "    Hit another obstacle at $start_index, ($guard_col, $guard_row)"
            #     guard_stuck_in_loop=true
            # else
            #     path_since_last_obstacle=()
            # fi
            # echo "  Found obstacle. New direction is ${guard_direction}."
        else
            if [[ "${array[$new_index]}" == "X" ]]; then
                case $guard_direction in
                    "0")
                        if [[ "${postions_where_guard_has_travelled_up[$new_index]}" == "true" ]]; then
                            guard_stuck_in_loop=true
                        fi
                        ;;
                    "1")
                        if [[ "${postions_where_guard_has_travelled_right[$new_index]}" == "true" ]]; then
                            guard_stuck_in_loop=true
                        fi
                        ;;
                    "2")
                        if [[ "${postions_where_guard_has_travelled_down[$new_index]}" == "true" ]]; then
                            guard_stuck_in_loop=true
                        fi
                        ;;
                    "3")
                        if [[ "${postions_where_guard_has_travelled_left[$new_index]}" == "true" ]]; then
                            guard_stuck_in_loop=true
                        fi
                        ;;
                esac
                if [[ "$guard_stuck_in_loop" == "true" ]]; then
                    # echo "Guard is stuck in a loop!"
                    break
                fi
            fi
            start_index=$new_index
            # guard_row=$((start_index / $cols )) # y position
            # guard_col=$((start_index % $cols )) # x position
            # echo "  Guard moved to (${guard_col}, ${guard_row})"
        fi
        ((i++))
    done


    if [[ "$guard_is_in_lab" == "false" ]]; then
        return 0
    elif [[ "$guard_stuck_in_loop" == "true" ]]; then
        return 1
    else 
        return 2
    fi
}


solution_2 () {
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
    echo "--------- Initial map display ---------"
    print_map "$cols" "$rows" map_arr

    declare -a tmp_arr
    
    # Run this once to find out the guards path
    pos_col=$(($guard_pos % $cols + 1))
    pos_row=$(($guard_pos / $rows + 1))
    echo "Guard starting pos is: $guard_pos, ($pos_col, $pos_row)"
    tmp_arr=("${map_arr[@]}")
    can_escape "tmp_arr" "$guard_pos"

    echo "--------- Solved map display ---------"
    print_map "$cols" "$rows" tmp_arr

    # Get positions of the guards path - these will be where we try to place obstacles
    declare -a obstacle_positions_to_try
    i=0
    for char in ${tmp_arr[*]}; do
        if [[ "$char" == "X" ]]; then
            [[ "$i" != "$guard_pos" ]] && obstacle_positions_to_try+=($i) # Obstacle can't be placed at the guards starting position
        fi
        ((i++))
    done
    # echo "Obstacle positions to try: ${obstacle_positions_to_try[*]}"
    echo "Number of obstacle positions to try: ${#obstacle_positions_to_try[*]}"

    # Try placing obstacles at each of those positions and checking if CAN_ESCAPE or not
    # obstacle_positions_to_try[0]="63" # For debugging. Placing here definately causes a loop for example input
    i=0
    for new_obstacle_pos in ${obstacle_positions_to_try[*]}; do
        # [[ $i -gt 2 ]] && break # Just for debugging

        pos_col=$(($new_obstacle_pos % $cols + 1))
        pos_row=$(($new_obstacle_pos / $rows + 1))
        # echo "  Attempting to place new obstacle at $new_obstacle_pos, ($pos_col, $pos_row)"
        
        tmp_arr=("${map_arr[@]}")
        tmp_arr[new_obstacle_pos]="#"
        if ! can_escape "tmp_arr" "$guard_pos"; then
            echo "  Placing obstacle at $new_obstacle_pos, ($pos_col, $pos_row) causes the guard to get stuck in loop!"
            ((answer++))
            # print_map "$cols" "$rows" tmp_arr
        # else
        #     echo "  Guard can escape!"
        fi
        ((i++))
    done


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
solution_2 input.txt # 1725 -> incorrect (too high) Took 757 seconds . Error with how I was checking if guard was stuck in a loop | 1697 took 547 seconds