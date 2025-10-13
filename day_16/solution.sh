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
print_map_colors () {
    local -n array=$1
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            char="${array[$x,$y]}"
            case $char in
                "#")
                    echo -n $'\033[0;31m' # RED
                    ;;
                "^"|">"|"<"|"v")
                    echo -n $'\033[0;32m' # GREEN
                    ;;
                *)
                    ;;
            esac
            echo -n "$char"
            echo -n $'\033[0m' # RESET
        done
        echo
    done
}

a_star_h () {
    local start_x=$1
    local start_y=$2
    local direction=$3
    local end_x=$4
    local end_y=$5

    local distance distance_x distance_y
    local number_of_turns_required="0"

    if [[ $start_x -lt $end_x ]]; then
        # Need to move EAST
        distance_x=$((end_x-start_x))
        case $direction in
            "0"|"2")
                ((number_of_turns_required++))
                ;;
            "3")
                ((number_of_turns_required+=2))
                ;;
        esac
    else
        # Need to move WEST
        distance_x=$((start_x-end_x))
        case $direction in
            "0"|"2")
                ((number_of_turns_required++))
                ;;
            "1")
                ((number_of_turns_required+=2))
                ;;
        esac
    fi

    if [[ $start_y -lt $end_y ]]; then
        # Need to move NORTH
        distance_y=$((end_y-start_y))
        distance_x=$((start_x-end_x))
        case $direction in
            "1"|"3")
                ((number_of_turns_required++))
                ;;
            "2")
                ((number_of_turns_required+=2))
                ;;
        esac
    else    
        # Need to move SOUTH
        distance_y=$((start_y-end_y))
        case $direction in
            "1"|"3")
                ((number_of_turns_required++))
                ;;
            "0")
                ((number_of_turns_required+=2))
                ;;
        esac
    fi

    distance=$((distance_x+distance_y))
    local score=$((distance*SCORE_MOVING + number_of_turns_required*SCORE_ROTATING))

    echo "$score"
    return 0
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
    declare start_x start_y end_x end_y
    y=0
    while read -r line; do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="${line:$x:1}"
            if [[ "${map_arr[$x,$y]}" = "S" ]]; then
                start_x="$x"
                start_y="$y"
            elif [[ "${map_arr[$x,$y]}" = "E" ]]; then
                end_x="$x"
                end_y="$y"
            fi
        done
        ((y++))
    done < "$1"

    # Initialise starting conditions
    declare direction="1" # Starting direction is EAST. N=0 E=1 W=2 S=3
    declare SCORE_MOVING="1"
    declare SCORE_ROTATING="1000"

    # Print initial map
    echo "----- Initial Map -----"
    print_map map_arr
    echo "Start: $start_x,$start_y | End: $end_x,$end_y"
    echo

    # Start of A_star algorithm
    declare -A g_scores=([$start_x,$start_y]="0")                  # Actual Cost from start to X (0 for start to start)
    start_h=$(a_star_h $start_x $start_y $direction $end_x $end_y) # Estimated cost from X to end
    start_f=$((${g_scores[$start_x,$start_y]}+start_h))            # Total estimated cost. start->start + start->end
    declare -A f_scores=([$start_x,$start_y]="$start_f")           # Total estimated cost. start->X + X->end
    declare -A openList=([$start_x,$start_y]=$direction)             # Nodes that need to be evaluated
    declare -A closedList=()                                       # Nodes that have already been evaluated
    declare -A parents=()                                          # Holds the parent node in the path

    while [[ "${openList[*]}" != "" ]]; do
        # echo "Open List contains: ${!openList[@]}"
        # Get node in openList with the lowest f value
        min_f=""
        min_node=""
        for node in "${!openList[@]}"; do
            f="${f_scores[$node]}"
            # echo $node $f
            if [[ -z $min_f ]]; then
                min_f=$f
                min_node=$node
                continue
            fi
            if [[ "$min_f" -gt "$f" ]]; then
                min_f=$f
                min_node=$node
            fi
        done
        current=$min_node
        IFS="," read -r x y <<< "$current"
        # echo "  Node with lowest F value is current = $x,$y with f = $min_f"
        direction="${openList[$current]}"
        
        # move current node from openList to closedList
        unset "openList[$current]"
        closedList["$current"]="$direction"
        # echo "  Removed current node from openList"

        # check if we have reached the goal
        if [[ "$current" = "$end_x,$end_y" ]]; then
            echo "  We have reached the end with a score of ${g_scores[$current]}"
            ((answer+=${g_scores[$current]}))
            # Figure out what path we have just taken
            current_node=$current
            declare -A path=(["$current_node"]="${g_scores[$current]}")
            while [[ "${parents[$current_node]}" != "" ]]; do
                parent="${parents[$current_node]}"
                path+=(["$parent"]="${g_scores[$parent]}")
                current_node="$parent"
                if [[ -z $g_scores_path ]]; then
                    g_scores_path="${g_scores[$parent]}"
                    path_string="$parent"
                else
                    g_scores_path="$g_scores_path,${g_scores[$parent]}"
                    path_string="$path_string | $parent"
                fi
            done
            # echo "PATH: ${path[*]}"
            # break # Uncommenting this makes the algo exit as soon as it hits the end. # Commenting make its search the entire map
        fi

        # check all neighbouring nodes
            # Skip if the neighbour is in closedList already
            # calculate the g score
        declare -A neighbours=()
            # NORTH
        new_x=$x
        new_y=$((y-1))
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" ]]; then
            neighbours["$new_x,$new_y"]="0"
        fi
            # EAST
        new_x=$((x+1))
        new_y=$y
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" ]]; then
            neighbours["$new_x,$new_y"]="1"
        fi
            # SOUTH
        new_x=$x
        new_y=$((y+1))
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" ]]; then
            neighbours["$new_x,$new_y"]="2"
        fi
            # WEST
        new_x=$((x-1))
        new_y=$y
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" ]]; then
            neighbours["$new_x,$new_y"]="3"
        fi
        # echo "  Neighbours to check: ${!neighbours[@]}"
        for node in "${!neighbours[@]}"; do
            IFS="," read -r neighbour_x neighbour_y <<< "$node"
            neighbour_direction="${neighbours[$node]}"
            diff_direction=$((direction-neighbour_direction))
            if [[ "$diff_direction" = "3" || "$diff_direction" = "-3" ]]; then
                diff_direction="1"
            fi
            diff_direction=${diff_direction#-} # get absolute value. Removes '-'
            neighbour_g=$((${g_scores[$x,$y]} + SCORE_MOVING + SCORE_ROTATING * diff_direction)) # Calculate their g scores (g of current + score of moving to the neighbour)
            neighbour_h=$(a_star_h "$neighbour_x" "$neighbour_y" "$neighbour_direction" "$end_x" "$end_y" ) # Calculate their h scores
            neighbour_f=$((neighbour_g + neighbour_h)) # calculate their f scores (g+h)
            # echo "    Neighbour $node has values f,g,h $neighbour_f, $neighbour_g, $neighbour_h"
            # if [[ "${openList[$node]}" = "" ]]; then    # If neighbour not in openList then add it. If it is then check if neighbour_g is lower than g_scores, if it update it.
            #     g_scores["$node"]="$neighbour_g"
            #     f_scores["$node"]="$neighbour_f"
            #     openList["$node"]="$neighbour_direction"
            if [[ "${g_scores[$node]}" -ge "$neighbour_g" ]]; then # If the g_score of the neighbour is better than anything we have seen before then update it
                continue
            fi
            g_scores["$node"]="$neighbour_g"
            f_scores["$node"]="$neighbour_f"
            openList["$node"]="$neighbour_direction"
            parents["$node"]="$current"
        done
        # echo "  G Scores: ${!g_scores[@]} ${g_scores[*]}"
    done
    
    # Show on map all the places we have tried to move to
    for node in "${!closedList[@]}"; do
        map_arr[$node]="x"
    done
    # Show the path we took on the map and count the length and num of turns to verify our score
    num_turns_in_path="0"
    length_of_path="-1"
    previous_dir="${closedList[$end_x,$end_y]}"
    for node in "${!path[@]}"; do
        node_dir="${closedList[$node]}"
        ((length_of_path++))
        if [[ "$node_dir" != "$previous_dir" ]]; then
            ((num_turns_in_path++))
        fi
        case $node_dir in
            0)
                symbol="^"
                ;;
            1)
                symbol=">"
                ;;
            2)
                symbol="v"
                ;;
            3)
                symbol="<"
                ;;
        esac
        map_arr[$node]="$symbol"
        previous_dir=$node_dir
    done

    # Print Ending map
    echo
    echo "----- Ending Map -----"
    print_map_colors map_arr
    echo "Path contained $num_turns_in_path ROTATIONS and $length_of_path MOVEMENTS"
    echo "$path_string"
    echo "$g_scores_path"

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

# solution_1 example_input.txt # Best score = 7036
###############
#.......#....E#
#.#.###.#.###^#
#.....#.#...#^#
#.###.#####.#^#
#.#.#.......#^#
#.#.#####.###^#
#..>>>>>>>>v#^#
###^#.#####v#^#
#>>^#.....#v#^#
#^#.#.###.#v#^#
#^....#...#v#^#
#^###.#.#.#v#^#
#S..#.....#>>^#
###############

# solution_1 example_input_2.txt # Best score = 11048
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#^#
#.#.#.#...#...#^#
#.#.#.#.###.#.#^#
#>>v#.#.#.....#^#
#^#v#.#.#.#####^#
#^#v..#.#.#>>>>^#
#^#v#####.#^###.#
#^#v#..>>>>^#...#
#^#v###^#####.###
#^#v#>>^#.....#.#
#^#v#^#####.###.#
#^#v#^........#.#
#^#v#^#########.#
#S#>>^..........#
#################

solution_1 input.txt # 97420 - took 15s to calculate TOO HIGH

# solution_2 example_input.txt
# echo
# solution_2 input.txt
