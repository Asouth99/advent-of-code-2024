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
                "S"|"E")
                    # echo -n $'\033[0;32m' # GREEN
                    # echo -n $'\033[0;34m' # BLUE
                    echo -n $'\033[0;36m' # CYAN
                    ;;
                "O")
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
    local start_coord=$1
    local end_coord=$2
    local s_x s_y e_x e_y
    local diff_x diff_y diff

    IFS="," read -r s_x s_y <<< "$start_coord"
    IFS="," read -r e_x e_y <<< "$end_coord"

    if [[ $s_x -lt $e_x ]]; then
        diff_x=$((e_x - s_x))
    else
        diff_x=$((s_x - e_x))
    fi

    if [[ $s_y -lt $e_y ]]; then
        diff_y=$((e_y - s_y))
    else    
        diff_y=$((s_y - e_y))
    fi

    # echo "$((diff_x+diff_y))"
    diff=$((diff_x**2+diff_y**2))
    diff=$(echo "scale=2; sqrt($diff)" | bc)
    diff=${diff%.*} # We only want an integer
    echo $diff
    return 0
}

a_star() {
    
    local start=$1
    local end=$2
    local start_h start_f
    local node neighbour_g neighbour_h neighbour_f
    local -A neighbours

    # Initialise vars
    g_scores=([$start]="0")                    # Acutal cost from where we are to the start. 0 for start->start
    start_h=$(a_star_h "$start" "$end")        # Heuristic (estimated) cost from start to end
    start_f=$((${g_scores[$start]} + start_h)) # Total estimated cost. start->start (G) + start->end (H)
    f_scores=([$start]="$start_f")             # Initialise f cost of the start
    openList=([$start]="true")                 # Nodes that need to be evaluated

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
        # echo "  Node with lowest F value is $x,$y with f = $min_f. Current = $current"
        
        # move current node from openList to closedList
        unset "openList[$current]"
        closedList["$current"]="true"
        # echo "  Removed current node from openList"

        # check if we have reached the goal
        if [[ "$current" = "$end" ]]; then
            # echo "  We have reached the end with a score of ${g_scores[$current]}"
            # Figure out what path we have just taken
            current_node=$current
            path=(["$current_node"]="${g_scores[$current]}")
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
            return 0
        fi

        # echo "Closed List: ${!closedList[@]}"
        # check all neighbouring nodes
            # Skip if the neighbour is in closedList already
            # calculate the g score
        neighbours=()
            # NORTH
        new_x=$x
        new_y=$((y-1))
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" && "$new_y" -ge "0" ]]; then
            neighbours["$new_x,$new_y"]="0"
        fi
            # EAST
        new_x=$((x+1))
        new_y=$y
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" && "$new_x" -lt "$MAX_X" ]]; then
            neighbours["$new_x,$new_y"]="1"
        fi
            # SOUTH
        new_x=$x
        new_y=$((y+1))
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" && "$new_y" -lt "$MAX_Y" ]]; then
            neighbours["$new_x,$new_y"]="2"
        fi
            # WEST
        new_x=$((x-1))
        new_y=$y
        if [[ "${map_arr[$new_x,$new_y]}" != "#" && "${closedList[$new_x,$new_y]}" = "" && "$new_x" -ge "0" ]]; then
            neighbours["$new_x,$new_y"]="3"
        fi
        # echo "  Neighbours to check: ${!neighbours[@]}"
        for node in "${!neighbours[@]}"; do
            neighbour_g=$((${g_scores[$current]} + 1))    # Calculate their g scores (g of current + score of moving to the neighbour)
            neighbour_h=$(a_star_h "$node" "$end" )       # Calculate their h scores
            neighbour_f=$((neighbour_g + neighbour_h))    # Calculate their f scores (g+h)
            # echo "    Neighbour $node has values f,g,h $neighbour_f, $neighbour_g, $neighbour_h"
            if [[ "${g_scores[$node]}" -gt "$neighbour_g" ]]; then # If the g_score of the neighbour is better than anything we have seen before then update it
                continue
            fi
            g_scores["$node"]="$neighbour_g"
            f_scores["$node"]="$neighbour_f"
            openList["$node"]="true"
            parents["$node"]="$current"
        done
        # echo "  G Scores: ${!g_scores[@]} ${g_scores[*]}"
    done
}

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
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
    declare -g start end
    
    y=0
    while read -r line; do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="${line:$x:1}"
            if [[ "${map_arr[$x,$y]}" = "S" ]]; then
                start="$x,$y"
            elif [[ "${map_arr[$x,$y]}" = "E" ]]; then
                end="$x,$y"
            fi
        done
        ((y++))
    done < "$1"

    # Print initial map
    echo "----- Initial Map -----"
    print_map_colors map_arr
    echo "Start: $start | End: $end"
    echo

    # Start of A_star algorithm
    declare -A g_scores=()   # Actual Cost from start to point X
    declare -A f_scores=()   # Total estimated cost. start->X (g_score) + X->end (estimated heuristic score)
    declare -A openList=()   # Nodes that need to be evaluated
    declare -A closedList=() # Nodes that have already been evaluated
    declare -A parents=()    # Holds the parent node in the path so we can print it later
    declare -A path=()       # Holds the resulting path
    a_star "$start" "$end"
    for node in "${!closedList[@]}"; do
        if [[ "$node" = "$start" || "$node" = "$end" ]]; then
            continue
        fi
        map_arr[$node]="x"
    done
    for node in "${!path[@]}"; do
        # if [[ "$node" = "$start" || "$node" = "$end" ]]; then
        #     continue
        # fi
        if [[ "${closedList[$node]}" != "" ]]; then
            map_arr[$node]="O"
        fi
    done
    first_steps=$((${#path[@]}-1))
    echo "----- First search of Map -----"
    print_map_colors map_arr
    echo "Path takes $first_steps PICOSECONDS"
    echo

    # Get list of obstacles that are next to two O's like O#O. 
    declare -gA obstacles=()
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            char="${map_arr[$x,$y]}"
            if [[ "$char" = "#" ]]; then
                if [[ ("${map_arr[$((x+1)),$y]}" = "O" && "${map_arr[$((x-1)),$y]}" = "O") || ("${map_arr[$x,$((y+1))]}" = "O" && "${map_arr[$x,$((y-1))]}" = "O") ]]; then
                    obstacles["$x,$y"]="true"
                fi
            fi
        done
    done
    echo "Number of Obstacles to attempt to remove: ${#obstacles[@]}"

    # Check the position in the path of each obstacle and calculate the time saving
    declare -A cheats=()
    for node in "${!obstacles[@]}"; do
        IFS="," read -r x y <<< "$node"
        # echo "Node: $node is $x,$y"
        n_u="${map_arr[$((x-1)),$y]}" 
        n_d="${map_arr[$((x+1)),$y]}" 
        n_l="${map_arr[$x,$((y-1))]}" 
        n_r="${map_arr[$x,$((y+1))]}"
        
        if [[ "$n_u" = "O" && "$n_d" = "O" ]]; then
            n_1="$((x-1)),$y"
            n_2="$((x+1)),$y"
        elif [[ "$n_l" = "O" && "$n_r" = "O" ]]; then
            n_1="$x,$((y-1))"
            n_2="$x,$((y+1))"
        else
            echo "ERROR: Obstacle has not got opposite neighbours in the path" >&2
        fi

        if [[ "${path[$n_1]}" -gt "${path[$n_2]}" ]]; then
            tmp=$n_2
            n_2=$n_1
            n_1=$tmp
        fi
        # echo "n_1: $n_1 and n_2: $n_2"
        path_1="${path[$n_1]}"
        path_2="${path[$n_2]}"

        time_saving=$(( path_2 - path_1 - 2))
        cheats["$node"]="$time_saving"
    done

    # Get cheats that save 100 or more PICOSECONDS
    for cheat in "${!cheats[@]}"; do
        time_saving="${cheats[$cheat]}"
        echo "Removing obstacle at $cheat saves $time_saving PICOSECONDS"
        if [[ "$time_saving" -ge "100" ]]; then
            ((answer++))
        fi
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
    declare -g start end
    
    y=0
    while read -r line; do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="${line:$x:1}"
            if [[ "${map_arr[$x,$y]}" = "S" ]]; then
                start="$x,$y"
            elif [[ "${map_arr[$x,$y]}" = "E" ]]; then
                end="$x,$y"
            fi
        done
        ((y++))
    done < "$1"

    # Print initial map
    echo "----- Initial Map -----"
    print_map_colors map_arr
    echo "Start: $start | End: $end"
    echo

    # No need for a star algo. Path is completely covered in walls so easy to determine path
    declare -A path=()
    previous=""
    current="$start"
    i="0"
    while [[ "$current" != "$end" ]]; do
        IFS="," read -r x y <<< "$current"
        # add to the path
        path+=(["$current"]="$i")

        # Get neighbours. If '.' then move to that one
        declare -A neighbours=(
            ["$x,$((y-1))"]="${map_arr[$x,$((y-1))]}"
            ["$x,$((y+1))"]="${map_arr[$x,$((y+1))]}"
            ["$((x+1)),$y"]="${map_arr[$((x+1)),$y]}"
            ["$((x-1)),$y"]="${map_arr[$((x-1)),$y]}"
        )
        for node in "${!neighbours[@]}"; do
            if [[ "$node" = "$previous" ]]; then
                continue
            fi
            case "${neighbours[$node]}" in
                ".") next=$node; break ;;
                "E") next=$node; path+=(["$node"]="$((i+1))"); break ;;
                *) continue ;;
            esac
        done

        if [[ -z "$next" ]]; then
            echo "ERROR: No neighbour found to move to!" >&2
            exit 1
        fi
        previous=$current
        current=$next
        # echo "  Moved from $previous -> $current"
        ((i++))
    done

    # Print map after first search through
    # echo "${!path[@]}"
    for node in "${!path[@]}"; do
        map_arr[$node]="O"
    done
    first_steps=$((${#path[@]}-1))
    echo "----- First search of Map -----"
    print_map_colors map_arr
    echo "Path takes $first_steps PICOSECONDS"
    echo

    # At every point on the path perform a search through '#s' until you reach an O that is more steps away than you have taken
    # for node in "${!path[@]}"; do
    # done


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt

solution_2 example_input.txt
# echo
# solution_2 input.txt
