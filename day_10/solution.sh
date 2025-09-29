#!/usr/bin/env bash

print_map () {
    local rows=$1
    local cols=$2
    local -n array=$3
    for ((r = 0 ; r < "$rows" ; r++ )); do
        for ((c = 0 ; c < "$cols" ; c++ )); do
            echo -n "${array[$c,$r]}"
        done
        echo
    done
}

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    # Trail starts at a 0 (trailhead)
    # Trail must go from 0->1->2->3...->9
    # Number of unique 9's reached by a single 0 = the trailheads score


    # Get size of input map
    rows=0
    while read -r line; do
        ((rows++))
        cols=${#line}
    done < "$1"
    echo "$1 has $rows rows and $cols columns"

    # Read input map into a key value array
    declare -gA map_arr
    r=0
    while read -r line; do
        for ((c = 0 ; c < "$cols" ; c++ )); do
            map_arr["$c,$r"]="${line:$c:1}"
        done
        ((r++))
    done < "$1"

    # Print map after we have read into an array
    echo "Input map looks like:"
    print_map "$rows" "$cols" map_arr
    
    # Find all trailheads
    max_x=$cols
    max_y=$rows
    for ((y = 0 ; y < "$max_y" ; y++ )); do
        for ((x = 0 ; x < "$max_x" ; x++ )); do
            if [[ "${map_arr[$x,$y]}" = "0" ]]; then
                echo "Started trail '${map_arr[$x,$y]}' at ($x,$y)"
                # Call Traverse - this will be a recursive function which will search through entire map until it finds a 9
                echo "  Traversing..."
                declare -gA pathEndCoords
                pathEndCoords=()
                traverse $x $y
                score=0
                for i in "${!pathEndCoords[@]}"; do
                    # echo -n "$i = ${pathEndCoords[$i]} | "
                    ((score++))
                done
                echo "  Score is $score"
                ((answer+=score))
            fi
        done
    done

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

traverse () {
    # echo "$rows $cols"
    local start_x=$1
    local start_y=$2

    if [[ "${map_arr[$start_x,$start_y]}" = "9" ]]; then
        # Found the end of the trail
        # echo "    Ended trail '${map_arr[$start_x,$start_y]}' at ($start_x,$start_y)"
        pathEndCoords["$start_x,$start_y"]="true"
        return
    fi

    # Move left
    new_x=$((start_x - 1))
    new_y=$start_y
    diff=$(( ${map_arr[$new_x,$new_y]} - ${map_arr[$start_x,$start_y]} ))
    if [[ ( "$new_x" -ge "0" || "$new_x" -lt "$max_x" || "$new_y" -ge "0" || "$new_y" -lt "$max_y" ) && "$diff" = "1" ]]; then
        # echo "    moved left"
        traverse $new_x $new_y
    fi
    # Move right
    new_x=$((start_x + 1))
    new_y=$start_y
    diff=$(( ${map_arr[$new_x,$new_y]} - ${map_arr[$start_x,$start_y]} ))
    if [[ ( "$new_x" -ge "0" || "$new_x" -lt "$max_x" || "$new_y" -ge "0" || "$new_y" -lt "$max_y" ) && "$diff" = "1" ]]; then
        # echo "    moved right"
        traverse $new_x $new_y
    fi
    
    # Move up
    new_x=$start_x
    new_y=$((start_y - 1))
    diff=$(( ${map_arr[$new_x,$new_y]} - ${map_arr[$start_x,$start_y]} ))
    if [[ ( "$new_x" -ge "0" || "$new_x" -lt "$max_x" || "$new_y" -ge "0" || "$new_y" -lt "$max_y" ) && "$diff" = "1" ]]; then
        # echo "    moved up"
        traverse $new_x $new_y
    fi
    
    # Move down
    new_x=$start_x
    new_y=$((start_y + 1))
    diff=$(( ${map_arr[$new_x,$new_y]} - ${map_arr[$start_x,$start_y]} ))
    if [[ ( "$new_x" -ge "0" || "$new_x" -lt "$max_x" || "$new_y" -ge "0" || "$new_y" -lt "$max_y" ) && "$diff" = "1" ]]; then
        # echo "    moved down"
        traverse $new_x $new_y
    fi
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


# solution_1 example_input_simple.txt
solution_1 example_input.txt
echo
solution_1 input.txt


# solution_2 example_input.txt
# echo
# solution_2 input.txt 
