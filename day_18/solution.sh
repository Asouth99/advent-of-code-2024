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

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    declare -gA map_arr=()
    declare -g bytes=() 
    
    declare -g start="0,0"
    declare -g end="$((MAX_X-1)),$((MAX_Y-1))"

    # Read input
    while read -r line; do
        bytes+=("$line")
    done < $1

    # Initialise map
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            map_arr["$x,$y"]="."
        done
    done
    for ((i = 0 ; i < "$BYTES_TO_SIMULATE" ; i++ )); do
        byte="${bytes[$i]}"
        map_arr["$byte"]="#"
    done

    # Print initial map
    echo "----- Initial Map -----"
    print_map map_arr
    echo
    echo "Finding path from $start to $end"


    # Start of A_star algorithm
    declare -A g_scores=([$start]="0")                # Actual Cost from start to X (0 for start to start)
    start_h=$(a_star_h "$start" "$end")               # Estimated cost from X to end
    start_f=$((${g_scores[$start]}+start_h))          # Total estimated cost. start->start + start->end
    declare -A f_scores=([$start]="$start_f")         # Total estimated cost. start->X + X->end
    declare -A openList=([$start]="true")             # Nodes that need to be evaluated
    declare -A closedList=()                          # Nodes that have already been evaluated
    declare -A parents=()                             # Holds the parent node in the path

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
            echo "  We have reached the end with a score of ${g_scores[$current]}"
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
            break # Uncommenting this makes the algo exit as soon as it hits the end. # Commenting make its search the entire map
        fi

        # echo "Closed List: ${!closedList[@]}"
        # check all neighbouring nodes
            # Skip if the neighbour is in closedList already
            # calculate the g score
        declare -A neighbours=()
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

    for node in "${!closedList[@]}"; do
        map_arr[$node]="x"
    done
    for node in "${!path[@]}"; do
        if [[ "${closedList[$node]}" != "" ]]; then
            map_arr[$node]="O"
        fi
    done

    echo
    echo "----- Ending Map -----"
    print_map_colors map_arr
    echo "Path contained $((${#path[@]}-1)) STEPS"
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

    
    declare -gA map_arr=()
    declare -g bytes=() 
    
    declare -g start="0,0"
    declare -g end="$((MAX_X-1)),$((MAX_Y-1))"

    # Read input
    while read -r line; do
        bytes+=("$line")
    done < $1

    for ((SIMULATION = "$BYTES_TO_SIMULATE_START" ; SIMULATION <= "$BYTES_TO_SIMULATE_END" ; SIMULATION++ )); do
        HAVE_REACHED_END="false"
        byte_to_add="${bytes[$SIMULATION]}"
        echo -n "Running simulation $SIMULATION/$BYTES_TO_SIMULATE_END. Placing obstacle at $byte_to_add."

        # Initialise map
        for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
            for ((x = 0 ; x < "$MAX_X" ; x++ )); do
                map_arr["$x,$y"]="."
            done
        done
        for ((i = 0 ; i <= "$SIMULATION" ; i++ )); do
            byte="${bytes[$i]}"
            map_arr["$byte"]="#"
        done

        # Print initial map
        # echo "----- Initial Map -----"
        # print_map map_arr
        # echo
        # echo "Finding path from $start to $end"


        # Start of A_star algorithm
        declare -A g_scores=([$start]="0")                # Actual Cost from start to X (0 for start to start)
        start_h=$(a_star_h "$start" "$end")               # Estimated cost from X to end
        start_f=$((${g_scores[$start]}+start_h))          # Total estimated cost. start->start + start->end
        declare -A f_scores=([$start]="$start_f")         # Total estimated cost. start->X + X->end
        declare -A openList=([$start]="true")             # Nodes that need to be evaluated
        declare -A closedList=()                          # Nodes that have already been evaluated
        declare -A parents=()                             # Holds the parent node in the path

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
                HAVE_REACHED_END="true"
                echo -n $'\033[0;31m'" Reached end!"$'\033[0m'
                # echo "  We have reached the end with a score of ${g_scores[$current]}"
                # # Figure out what path we have just taken
                # current_node=$current
                # declare -A path=(["$current_node"]="${g_scores[$current]}")
                # while [[ "${parents[$current_node]}" != "" ]]; do
                #     parent="${parents[$current_node]}"
                #     path+=(["$parent"]="${g_scores[$parent]}")
                #     current_node="$parent"
                #     if [[ -z $g_scores_path ]]; then
                #         g_scores_path="${g_scores[$parent]}"
                #         path_string="$parent"
                #     else
                #         g_scores_path="$g_scores_path,${g_scores[$parent]}"
                #         path_string="$path_string | $parent"
                #     fi
                # done
                # echo "PATH: ${path[*]}"
                break # Uncommenting this makes the algo exit as soon as it hits the end. # Commenting make its search the entire map
            fi

            # echo "Closed List: ${!closedList[@]}"
            # check all neighbouring nodes
                # Skip if the neighbour is in closedList already
                # calculate the g score
            declare -A neighbours=()
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


        if [[ "$HAVE_REACHED_END" = "false" ]]; then
            for node in "${!closedList[@]}"; do
                map_arr[$node]="x"
            done

            echo
            echo "----- Ending Map -----"
            echo "Adding $byte_to_add prevents escape!"
            print_map_colors map_arr
            echo
            
            break
        fi

        echo

    done


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# declare -g MAX_X=7
# declare -g MAX_Y=7
# declare -g BYTES_TO_SIMULATE=12
# solution_1 example_input.txt
# declare -g MAX_X=71
# declare -g MAX_Y=71
# declare -g BYTES_TO_SIMULATE=1024
# solution_1 input.txt # 416 - took 28 seconds

# declare -g MAX_X=7
# declare -g MAX_Y=7
# declare -g BYTES_TO_SIMULATE_START=10
# declare -g BYTES_TO_SIMULATE_END=21
# solution_2 example_input.txt
# echo
declare -g MAX_X=71
declare -g MAX_Y=71
declare -g BYTES_TO_SIMULATE_START=2865 # Found by manually changing and running the script
declare -g BYTES_TO_SIMULATE_END=2870   
solution_2 input.txt
