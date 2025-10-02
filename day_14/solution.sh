#!/usr/bin/env bash

print_map () {
    local -n array=$1
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            echo -n "${array[$x,$y]}"
        done
        echo
    done
}

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    declare -a robot_positions_x=()
    declare -a robot_positions_y=()
    declare -a robot_speed_x=()
    declare -a robot_speed_y=()
    declare -A map_arr=()

    # Initialise map_arr
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="."
        done
    done

    # echo "----- Initialised Map -----"
    # print_map map_arr
    # echo

    LINE_REGEX="^p=([0-9]+),([0-9]+)\s+v=(-?[0-9]+),(-?[0-9]+)$"
    i=0
    while read -r line; do
        if [[ "$line" =~ $LINE_REGEX ]]; then
            robot_positions_x+=("${BASH_REMATCH[1]}")
            robot_positions_y+=("${BASH_REMATCH[2]}")
            robot_speed_x+=("${BASH_REMATCH[3]}")
            robot_speed_y+=("${BASH_REMATCH[4]}")
            # echo "p=$robot_x, $robot_y v=$robot_dx, $robot_dy"
        else
            echo "ERROR: Parsing <$line> failed"
            exit 1
        fi
        ((i++))
    done < $1

    # Update map_arr with robot positions
    for ((i = 0 ; i < "${#robot_positions_x[*]}" ; i++ )); do
        index="${robot_positions_x[$i]},${robot_positions_y[$i]}"
        current_count="${map_arr[$index]}"
        if [[ $current_count = "." ]]; then
            map_arr[$index]="1"
        else
            map_arr[$index]=$((current_count+1))
        fi
    done

    echo "----- Initial robot positions -----"
    print_map map_arr
    echo

    for ((i = 0 ; i < "${#robot_positions_x[*]}" ; i++ )); do
        x="${robot_positions_x[$i]}"
        y="${robot_positions_y[$i]}"
        dx="${robot_speed_x[$i]}"
        dy="${robot_speed_y[$i]}"
        
        new_x=$(( (x + dx * SIMULATED_SECONDS) % MAX_X ))
        new_y=$(( (y + dy * SIMULATED_SECONDS) % MAX_Y ))
        if [[ "${new_x::1}" = "-" ]]; then
            ((new_x+=MAX_X))
        fi
        if [[ "${new_y::1}" = "-" ]]; then
            ((new_y+=MAX_Y))
        fi
        robot_positions_x[$i]=$new_x
        robot_positions_y[$i]=$new_y
    done

    # re-initialise map_arr
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="."
        done
    done
    # Update map_arr with new robot positions
    for ((i = 0 ; i < "${#robot_positions_x[*]}" ; i++ )); do
        index="${robot_positions_x[$i]},${robot_positions_y[$i]}"
        current_count="${map_arr[$index]}"
        if [[ $current_count = "." ]]; then
            map_arr[$index]="1"
        else
            map_arr[$index]=$((current_count+1))
        fi
    done


    echo "----- Robot positions after ${SIMULATED_SECONDS}s -----"
    # echo "X: ${robot_positions_x[*]}"
    # echo "Y: ${robot_positions_y[*]}"
    print_map map_arr
    echo

    # Count the number of robots in each quadrant (exclude ones in the middle)
    quad_tl_count=0
    quad_tr_count=0
    quad_br_count=0
    quad_bl_count=0
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            count="${map_arr[$x,$y]}"
            if [[ $count != "." ]]; then
                if [[ $x -lt $((MAX_X/2)) && $y -lt $((MAX_Y/2)) ]]; then
                    ((quad_tl_count+=count))
                fi
                if [[ $x -gt $((MAX_X/2)) && $y -lt $((MAX_Y/2)) ]]; then
                    ((quad_tr_count+=count))
                fi
                if [[ $x -lt $((MAX_X/2)) && $y -gt $((MAX_Y/2)) ]]; then
                    ((quad_bl_count+=count))
                fi
                if [[ $x -gt $((MAX_X/2)) && $y -gt $((MAX_Y/2)) ]]; then
                    ((quad_br_count+=count))
                fi
            fi
        done
    done

    ((answer=quad_tl_count * quad_tr_count * quad_br_count * quad_bl_count))

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    declare -a robot_positions_x=()
    declare -a robot_positions_y=()
    declare -a robot_speed_x=()
    declare -a robot_speed_y=()
    declare -A map_arr=()

    # Initialise map_arr
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="."
        done
    done

    # echo "----- Initialised Map -----"
    # print_map map_arr
    # echo

    LINE_REGEX="^p=([0-9]+),([0-9]+)\s+v=(-?[0-9]+),(-?[0-9]+)$"
    i=0
    while read -r line; do
        if [[ "$line" =~ $LINE_REGEX ]]; then
            robot_positions_x+=("${BASH_REMATCH[1]}")
            robot_positions_y+=("${BASH_REMATCH[2]}")
            robot_speed_x+=("${BASH_REMATCH[3]}")
            robot_speed_y+=("${BASH_REMATCH[4]}")
            # echo "p=$robot_x, $robot_y v=$robot_dx, $robot_dy"
        else
            echo "ERROR: Parsing <$line> failed"
            exit 1
        fi
        ((i++))
    done < $1

    # Update map_arr with robot positions
    for ((i = 0 ; i < "${#robot_positions_x[*]}" ; i++ )); do
        index="${robot_positions_x[$i]},${robot_positions_y[$i]}"
        current_count="${map_arr[$index]}"
        if [[ $current_count = "." ]]; then
            map_arr[$index]="1"
        else
            map_arr[$index]=$((current_count+1))
        fi
    done

    # echo "----- Initial robot positions -----"
    # print_map map_arr
    # echo

    echo "---- Running simulations ----"
    for ((s = 0 ; s < "$NUMBER_OF_SIMULATIONS" ; s++ )); do
        echo -n "$((SIMULATED_SECONDS * (s+1))),"
        for ((i = 0 ; i < "${#robot_positions_x[*]}" ; i++ )); do
            x="${robot_positions_x[$i]}"
            y="${robot_positions_y[$i]}"
            dx="${robot_speed_x[$i]}"
            dy="${robot_speed_y[$i]}"
            
            new_x=$(( (x + dx * SIMULATED_SECONDS) % MAX_X ))
            new_y=$(( (y + dy * SIMULATED_SECONDS) % MAX_Y ))
            if [[ "${new_x::1}" = "-" ]]; then
                ((new_x+=MAX_X))
            fi
            if [[ "${new_y::1}" = "-" ]]; then
                ((new_y+=MAX_Y))
            fi
            robot_positions_x[$i]=$new_x
            robot_positions_y[$i]=$new_y
            
            # Update map_arr
            prev_count="${map_arr[$x,$y]}"
            if [[ $prev_count != "." ]]; then
                prev_count_updated=$((prev_count-1))
                if [[ $prev_count_updated = "0" ]]; then
                    prev_count_updated="."
                fi
                map_arr["$x,$y"]=$prev_count_updated
            fi

            current_count="${map_arr[$new_x,$new_y]}"
            if [[ $current_count = "." ]]; then
                map_arr["$new_x,$new_y"]="1"
            else
                map_arr["$new_x,$new_y"]=$((current_count+1))
            fi
        done

        # Run some sort of check to see if there is a christmas tree
        possible_christmas_tree="false"

        # Check if we have lots of numbers horizontally next to each other
        # total_num_row="0"
        # for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        #     num_row="0"
        #     for ((x = 0 ; x < "$MAX_X" ; x++ )); do
        #         prev_char="${map_arr[$((x-1)),$y]}"
        #         next_char="${map_arr[$((x+1)),$y]}"
        #         char="${map_arr[$x,$y]}"
        #         if [[ $char != "." && ($prev_char != "." || $next_char != ".") ]]; then
        #             ((num_row++))
        #         fi
        #     done
        #     ((total_num_row+=num_row))
        # done
        # if [[ $total_num_row -gt "100" ]]; then
        #     possible_christmas_tree="true"
        # fi

        # Check if we have a robot surrounded by other robots.
        # for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        #     for ((x = 0 ; x < "$MAX_X" ; x++ )); do
        #         char="${map_arr[$x,$y]}"
        #         if [[ $char != "." ]]; then
        #             continue
        #         fi
        #         if [[ "${map_arr[$((x)),$((y-1))]}" != "." && "${map_arr[$((x+1)),$((y-1))]}" != "." && "${map_arr[$((x+1)),$((y))]}" != "." && "${map_arr[$((x+1)),$((y+1))]}" != "." && "${map_arr[$((x)),$((y+1))]}" != "." && "${map_arr[$((x-1)),$((y+1))]}" != "." && "${map_arr[$((x-1)),$((y))]}" != "." ]]; then
        #             possible_christmas_tree="true"
        #         fi
        #     done
        # done
        # Rather than checking the entire map, just check the symbol in the middle
        # x=$((MAX_X/2))
        # y=$((MAX_Y/2))
        # if [[ "${map_arr[$x,$y]}" != "." && "${map_arr[$((x)),$((y-1))]}" != "." && "${map_arr[$((x+1)),$((y-1))]}" != "." && "${map_arr[$((x+1)),$((y))]}" != "." && "${map_arr[$((x+1)),$((y+1))]}" != "." && "${map_arr[$((x)),$((y+1))]}" != "." && "${map_arr[$((x-1)),$((y+1))]}" != "." && "${map_arr[$((x-1)),$((y))]}" != "." ]]; then
        #     possible_christmas_tree="true"
        # fi

        # See if it has 10 numbers in a row
        CHRISTMAS_TREE_REGEX="([0-9] ){10}"
        if [[ "${map_arr[*]}" =~ $CHRISTMAS_TREE_REGEX ]]; then
            possible_christmas_tree="true"
        fi

        if [[ $possible_christmas_tree = "true" ]]; then
            echo "----- Possible Christmas Tree after $((SIMULATED_SECONDS * (s+1)))s -----"
            print_map map_arr
            echo
        fi
    done



    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

declare -g MAX_X=11
declare -g MAX_Y=7
declare -g SIMULATED_SECONDS=100
# SIMULATED_SECONDS=7
# solution_1 example_input.txt
# echo
# MAX_X=101
# MAX_Y=103
# solution_1 input.txt

declare -g NUMBER_OF_SIMULATIONS
SIMULATED_SECONDS=1
NUMBER_OF_SIMULATIONS=10000
# solution_2 example_input.txt
# echo
MAX_X=101
MAX_Y=103
solution_2 input.txt # 6644 seconds
