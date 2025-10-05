#!/usr/bin/env bash

print_map () {
    local -n array=$1
    local padding=$2
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        echo -n "$padding"
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

    # Get size of input map
    declare -g MAX_X MAX_Y
    MAX_Y=0
    while read -r line; do
        if [[ ${line::1} = "#" ]]; then
            ((MAX_Y++))
            MAX_X=${#line}
        fi
    done < "$1"
    echo "$1 has $MAX_Y rows and $MAX_X columns"

    # Read input into map_arr
    declare -gA map_arr=()
    declare robot_actions=""
    robot_x=""
    robot_y=""
    y=0
    while read -r line; do
        if [[ ${line::1} = "#" ]]; then
            for ((x = 0 ; x < "$MAX_X" ; x++ )); do
                map_arr["$x,$y"]="${line:$x:1}"
                if [[ "${map_arr[$x,$y]}" = "@" ]]; then
                    robot_x="$x"
                    robot_y="$y"
                fi
            done
        else
            robot_actions="${robot_actions}${line}"
        fi
        ((y++))
    done < "$1"

    echo "----- Initial Map -----"
    print_map map_arr
    echo
    echo "Robot Actions: ${robot_actions}"

    for ((i = 0 ; i < "${#robot_actions}" ; i++ )); do
        # if [[ "$i" -ge "5" ]]; then
        #     break
        # fi

        robot_action="${robot_actions:$i:1}"
        echo "  Moving robot $robot_action..."

        robot_can_move="false"
        char="${map_arr[$robot_x,$robot_y]}"
        x=$robot_x
        y=$robot_y
        # echo "    Starting robot_can_move check: robot_x,y = $robot_x,$robot_y"
        while [[ $robot_can_move = "false" ]]; do
            case $robot_action in
                "^")
                    new_x=$x
                    ((new_y=y-1))
                    ;;
                ">")
                    ((new_x=x+1))
                    new_y=$y
                    ;;
                "v")
                    new_x=$x
                    ((new_y=y+1))
                    ;;
                "<")
                    ((new_x=x-1))
                    new_y=$y
                    ;;
                "*")
                    echo "ERROR: Incorrect robot action <$robot_action> identified"
                    exit 1
                    ;;
            esac
            char="${map_arr[$new_x,$new_y]}"
            if [[ $char = "." ]]; then
                robot_can_move="true"
            elif [[ $char = "#" ]]; then
                robot_can_move="false"
                break
            elif [[ $char = "O" ]]; then
                robot_can_move="false"
                # Do not break as we need to check the char next to it until we hit a wall
            fi
            x=$new_x
            y=$new_y
            # echo "      Next char: char = $char | x,y = $x,$y"
        done
        # We have figured out that the robot can move so now move it and all the boxes in front
        if [[ "$robot_can_move" = "false" ]]; then
            echo "    Can't move robot $robot_action"
            continue
        fi
        # echo "    robot_can_move check passed: robot_x,y = $robot_x,$robot_y | char = $char | x,y = $x,$y"
        # echo "    last_char = <$char> | x,y = $x,$y"
        # echo "    robot_x,y = $robot_x,$robot_y | x,y = $x,$y | new_x,y = $new_x,$new_y"
        while [[ "$x" != "$robot_x" || "$y" != "$robot_y" ]]; do
            x=$new_x
            y=$new_y
            case $robot_action in
                "^")
                    new_x=$x
                    ((new_y=y+1))
                    ;;
                ">")
                    ((new_x=x-1))
                    new_y=$y
                    ;;
                "v")
                    new_x=$x
                    ((new_y=y-1))
                    ;;
                "<")
                    ((new_x=x+1))
                    new_y=$y
                    ;;
                "*")
                    echo "ERROR: Incorrect robot action <$robot_action> identified"
                    exit 1
                    ;;
            esac
            char="${map_arr[$new_x,$new_y]}"
            if [[ $char = "O" ]]; then
                map_arr["$x,$y"]="O"
            elif [[ $char = "@" ]]; then
                map_arr["$x,$y"]="@"
                map_arr["$new_x,$new_y"]="."
                robot_x=$x
                robot_y=$y
            else
                echo "ERROR: Something has gone wrong. Expected <@> or <O> recieved <$char>"
                print_map map_arr
                exit 1
            fi
            # echo "      Moved object/robot from new_x,y = $new_x,$new_y to x,y = $x,$y | robot_x,y = $robot_x,$robot_y"
        done

        # print_map map_arr "      "
    done


    echo
    echo "----- Ending Map -----"
    print_map map_arr
    echo

    # Get all GPS coordinates of each box
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            char="${map_arr[$x,$y]}"
            if [[ $char != "O" ]]; then
                continue
            fi
            ((gps_coord=100*y + x))
            # echo "x,y = $x,$y | gps_coord = $gps_coord"
            ((answer+=gps_coord))
        done
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

# solution_1 example_input_2.txt
# solution_1 example_input.txt
# echo
solution_1 input.txt # 1514353 took 8 seconds

# solution_2 example_input.txt
# echo
# solution_2 input.txt
