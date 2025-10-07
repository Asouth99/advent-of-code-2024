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

check_can_move () {
    local x=$1
    local y=$2
    local direction=$3
    local is_box="false"
    local new_x new_y
    local new_x_right new_y_right new_x_left new_y_left
    # echo "        Trying to check $x,$y ${map_arr[$x,$y]}"
    if [[ "${map_arr[$x,$y]}" = "." ]]; then 
        return 0
    elif [[ "${map_arr[$x,$y]}" = "#" ]]; then 
        return 1
    elif [[ "${map_arr[$x,$y]}" = "[" ]]; then 
        is_box="true"
        local x_right=$((x+1))
        local y_right=$y
        local x_left=$x
        local y_left=$y
    elif [[ "${map_arr[$x,$y]}" = "]" ]]; then
        is_box="true"
        local x_right=$x
        local y_right=$y
        local x_left=$((x-1))
        local y_left=$y
    fi

    case $direction in
        "^")
            if [[ "$is_box" = "true" ]]; then
                new_x_right=$x_right
                ((new_y_right=y_right-1))
                new_x_left=$x_left
                ((new_y_left=y_left-1))
            else
                new_x=$x
                ((new_y=y-1))
            fi
            ;;
        ">")
            if [[ "$is_box" = "true" ]]; then
                new_x_right=$((x_right+1))
                new_y_right=$y_right
                new_x_left=$((x_left+1))
                new_y_left=$y_left
            else
                ((new_x=x+1))
                new_y=$y
            fi
            ;;
        "v")
            if [[ "$is_box" = "true" ]]; then
                new_x_right=$x_right
                ((new_y_right=y_right+1))
                new_x_left=$x_left
                ((new_y_left=y_left+1))
            else
                new_x=$x
                ((new_y=y+1))
            fi
            ;;
        "<")
            if [[ "$is_box" = "true" ]]; then
                new_x_right=$((x_right-1))
                new_y_right=$y_right
                new_x_left=$((x_left-1))
                new_y_left=$y_left
            else
                ((new_x=x-1))
                new_y=$y
            fi
            ;;
        "*")
            echo "ERROR: Incorrect robot action <$robot_action> identified"
            exit 1
            ;;
    esac

    if [[ "$is_box" = "true" ]]; then
        case $direction in
            "<")
                check_can_move "$new_x_left" "$new_y_left" "$direction"
                return $?
                ;;
            ">")
                check_can_move "$new_x_right" "$new_y_right" "$direction"
                return $?
                ;;
            "^"|"v")
                check_can_move "$new_x_right" "$new_y_right" "$direction"
                local right_can_move=$?
                check_can_move "$new_x_left" "$new_y_left" "$direction"
                local left_can_move=$?
                if [[ $right_can_move -eq 0 && $left_can_move -eq 0 ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            "*")
                echo "ERROR: Incorrect robot action <$robot_action> identified"
                exit 1
            ;;
        esac
    else
        check_can_move "$new_x" "$new_y" "$direction"
        return $?
    fi
}

move () {
    local x=$1
    local y=$2
    local direction=$3
    local is_box="false"
    local next_x next_y
    local next_x_right next_y_right next_x_left next_y_left

    # echo "        Trying to move $x,$y ${map_arr[$x,$y]}"

    if [[ "${map_arr[$x,$y]}" = "#" ]]; then
        echo "ERROR: Something has gone wrong here. check_can_move function must have failed" >&2
        return 1
    elif [[ "${map_arr[$x,$y]}" = "[" ]]; then 
        is_box="true"
        local x_right=$((x+1))
        local y_right=$y
        local x_left=$x
        local y_left=$y
    elif [[ "${map_arr[$x,$y]}" = "]" ]]; then
        is_box="true"
        local x_right=$x
        local y_right=$y
        local x_left=$((x-1))
        local y_left=$y
    fi

    # calculate where to move to
    case $direction in
        "^")
            if [[ "$is_box" = "true" ]]; then
                next_x_right=$x_right
                ((next_y_right=y_right-1))
                next_x_left=$x_left
                ((next_y_left=y_left-1))
            else
                next_x=$x
                ((next_y=y-1))
            fi
            ;;
        ">")
            if [[ "$is_box" = "true" ]]; then
                next_x_right=$((x_right+1))
                next_y_right=$y_right
                next_x_left=$((x_left+1))
                next_y_left=$y_left
            else
                ((next_x=x+1))
                next_y=$y
            fi
            ;;
        "v")
            if [[ "$is_box" = "true" ]]; then
                next_x_right=$x_right
                ((next_y_right=y_right+1))
                next_x_left=$x_left
                ((next_y_left=y_left+1))
            else
                next_x=$x
                ((next_y=y+1))
            fi
            ;;
        "<")
            if [[ "$is_box" = "true" ]]; then
                next_x_right=$((x_right-1))
                next_y_right=$y_right
                next_x_left=$((x_left-1))
                next_y_left=$y_left
            else
                ((next_x=x-1))
                next_y=$y
            fi
            ;;
        "*")
            echo "ERROR: Incorrect robot action <$robot_action> identified"
            exit 1
            ;;
    esac

    # if next object is a dot (we can move) then move
    if [[ $is_box = "true" ]]; then
        case $direction in
            "<")
                if [[ "${map_arr[$next_x_left,$next_y_left]}" = "." ]]; then
                    # echo "      Next to a dot so moving $x_left,$y_left and $x_right,$y_right <${map_arr[$x_left,$y_left]}${map_arr[$x_right,$y_right]}> to $next_x_left,$next_y_left and $next_x_right,$next_y_right <${map_arr[$next_x_left,$next_y_left]}${map_arr[$next_x_right,$next_y_right]}>..."
                    map_arr["$next_x_left,$next_y_left"]="${map_arr[$x_left,$y_left]}"
                    map_arr["$x_left,$y_left"]="."
                    map_arr["$next_x_right,$next_y_right"]="${map_arr[$x_right,$y_right]}"
                    map_arr["$x_right,$y_right"]="."
                    return 0
                fi
                ;;
            ">")
                if [[ "${map_arr[$next_x_right,$next_y_right]}" = "." ]]; then
                    # echo "      Next to a dot so moving $x_left,$y_left and $x_right,$y_right <${map_arr[$x_left,$y_left]}${map_arr[$x_right,$y_right]}> to $next_x_left,$next_y_left and $next_x_right,$next_y_right <${map_arr[$next_x_left,$next_y_left]}${map_arr[$next_x_right,$next_y_right]}>..."
                    map_arr["$next_x_right,$next_y_right"]="${map_arr[$x_right,$y_right]}"
                    map_arr["$x_right,$y_right"]="."
                    map_arr["$next_x_left,$next_y_left"]="${map_arr[$x_left,$y_left]}"
                    map_arr["$x_left,$y_left"]="."
                    return 0
                fi
                ;;
            "^"|"v")
                if [[ "${map_arr[$next_x_left,$next_y_left]}" = "." && "${map_arr[$next_x_right,$next_y_right]}" = "." ]]; then
                    # echo "      Next to a dot so moving $x_left,$y_left and $x_right,$y_right <${map_arr[$x_left,$y_left]}${map_arr[$x_right,$y_right]}> to $next_x_left,$next_y_left and $next_x_right,$next_y_right <${map_arr[$next_x_left,$next_y_left]}${map_arr[$next_x_right,$next_y_right]}>..."
                    map_arr["$next_x_right,$next_y_right"]="${map_arr[$x_right,$y_right]}"
                    map_arr["$x_right,$y_right"]="."
                    map_arr["$next_x_left,$next_y_left"]="${map_arr[$x_left,$y_left]}"
                    map_arr["$x_left,$y_left"]="."
                    return 0
                fi
                ;;
            "*")
                echo "ERROR: Incorrect robot action <$robot_action> identified"
                exit 1
            ;;
        esac
    else
        if [[ "${map_arr[$next_x,$next_y]}" = "." ]]; then
            # echo "      Next to a dot so moving $x,$y <${map_arr[$x,$y]}> to $next_x,$next_y <${map_arr[$next_x,$next_y]}>..."
            if [[ "${map_arr[$x,$y]}" = "@" ]]; then
                robot_x=$next_x
                robot_y=$next_y
            fi
            map_arr["$next_x,$next_y"]="${map_arr[$x,$y]}"
            map_arr["$x,$y"]="."
            return 0
        elif [[ "${map_arr[$next_x,$next_y]}" = "#" ]]; then
            echo "ERROR: x,y is $x,$y Next item $next_x,$next_y in map_arr is a #. Can't move object"
            return 1
        fi
    fi

    # Not next to a dot so there's an object next to us so move it.
    if [[ $is_box = "true" ]]; then
        case $direction in
            "<")
                move "$next_x_left" "$next_y_left" "$direction"
                ;;
            ">")
                move "$next_x_right" "$next_y_right" "$direction"
                ;;
            "^"|"v")
                # if we are moving a box next to us then only move one side of it
                if [[ "${map_arr[$next_x_left,$next_y_left]}${map_arr[$next_x_right,$next_y_right]}" = "[]" ]]; then
                    move "$next_x_right" "$next_y_right" "$direction"
                else
                    if [[ "${map_arr[$next_x_left,$next_y_left]}" != "." ]]; then
                        move "$next_x_left" "$next_y_left" "$direction"
                    fi
                    if [[ "${map_arr[$next_x_right,$next_y_right]}" != "." ]]; then
                        move "$next_x_right" "$next_y_right" "$direction"
                    fi
                fi
                ;;
            "*")
                echo "ERROR: Incorrect robot action <$robot_action> identified"
                exit 1
            ;;
        esac
    else
        move "$next_x" "$next_y" "$direction"
    fi
    
    # we have moved the object next to us so now we need to move ourselves
    if [[ $is_box = "true" ]]; then
        # echo "      Previous obj has moved. Moving $x_left,$y_left and $x_right,$y_right <${map_arr[$x_left,$y_left]}${map_arr[$x_right,$y_right]}> to $next_x_left,$next_y_left and $next_x_right,$next_y_right <${map_arr[$next_x_left,$next_y_left]}${map_arr[$next_x_right,$next_y_right]}>..."
        case $direction in
            "<")
                map_arr["$next_x_left,$next_y_left"]="${map_arr[$x_left,$y_left]}"
                map_arr["$x_left,$y_left"]="."
                map_arr["$next_x_right,$next_y_right"]="${map_arr[$x_right,$y_right]}"
                map_arr["$x_right,$y_right"]="."
                return 0
                ;;
            ">")
                map_arr["$next_x_right,$next_y_right"]="${map_arr[$x_right,$y_right]}"
                map_arr["$x_right,$y_right"]="."
                map_arr["$next_x_left,$next_y_left"]="${map_arr[$x_left,$y_left]}"
                map_arr["$x_left,$y_left"]="."
                return 0
                ;;
            "^"|"v")
                map_arr["$next_x_right,$next_y_right"]="${map_arr[$x_right,$y_right]}"
                map_arr["$x_right,$y_right"]="."
                map_arr["$next_x_left,$next_y_left"]="${map_arr[$x_left,$y_left]}"
                map_arr["$x_left,$y_left"]="."
                return 0
                ;;
            "*")
                echo "ERROR: Incorrect robot action <$robot_action> identified"
                exit 1
            ;;
        esac
    else
        # echo "      Previous obj has moved. Moving $x,$y <${map_arr[$x,$y]}> to $next_x,$next_y <${map_arr[$next_x,$next_y]}>..."
        if [[ "${map_arr[$x,$y]}" = "@" ]]; then
            robot_x=$next_x
            robot_y=$next_y
        fi
        map_arr["$next_x,$next_y"]="${map_arr[$x,$y]}"
        map_arr["$x,$y"]="."
        return 0
    fi
}

solution_2 () {
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
    declare -g robot_x=""
    declare -g robot_y=""
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
        # if [[ "$i" -ge "1193" ]]; then
        #     break
        # fi
        # if [[ "$i" -ge "1190" ]]; then
        #     print_map map_arr "      "
        # fi

        direction="${robot_actions:$i:1}"
        echo "  ($i/${#robot_actions}) Moving robot: $direction"

        robot_can_move="false"
        char="${map_arr[$robot_x,$robot_y]}"
        x=$robot_x
        y=$robot_y
        # echo "    Starting check_can_move check: robot_x,y = $robot_x,$robot_y"

        # declare -gA can_move_arr
        # can_move_arr=()
        check_can_move "$x" "$y" "$direction"
        can_move=$?
        # echo "    check_can_move returned: $can_move"
        if [[ $can_move -ne 0 ]]; then
            # print_map map_arr "      "
            continue
        fi
        
        move "$x" "$y" "$direction"
        # print_map map_arr "      "

        # clear
        # echo "($i/${#robot_actions}) $direction"
        # print_map map_arr "      "
        # sleep 0.2
    done

    echo
    echo "----- Ending Map -----"
    print_map map_arr
    echo

    # Get all GPS coordinates of each box
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            char="${map_arr[$x,$y]}"
            if [[ $char != "[" ]]; then
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

# solution_1 example_input_2.txt
# solution_1 example_input.txt
# echo
# solution_1 input.txt # 1514353 took 8 seconds

# solution_2 example_input_3.txt
# solution_2 example_input_4.txt
# echo
solution_2 input_part2.txt # 1533076 - 17 seconds
