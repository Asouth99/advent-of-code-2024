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

perform_search () {
    local x=$1
    local y=$2
    local char=$3
    local perimeter=4
    # Mark this coord as seen
    map_seen_arr["$x,$y"]="true"

    # Calculate perimeter
    # left
    new_x=$((x-1))
    new_y=$y
    if [[ "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        ((perimeter--))
    fi
    # right
    new_x=$((x+1))
    new_y=$y
    if [[ "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        ((perimeter--))
    fi
    # up
    new_x=$x
    new_y=$((y-1))
    if [[ "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        ((perimeter--))
    fi
    # down
    new_x=$x
    new_y=$((y+1))
    if [[ "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        ((perimeter--))
    fi

    plants["$x,$y"]=$perimeter

    # left
    new_x=$((x-1))
    new_y=$y
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search "$new_x" "$new_y" "$char"
    fi
    # right
    new_x=$((x+1))
    new_y=$y
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search "$new_x" "$new_y" "$char"
    fi
    # up
    new_x=$x
    new_y=$((y-1))
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search "$new_x" "$new_y" "$char"
    fi
    # down
    new_x=$x
    new_y=$((y+1))
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search "$new_x" "$new_y" "$char"
    fi

    
}


solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

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

    # Search through entire map
    declare -g MAX_X MAX_Y
    MAX_X=$cols
    MAX_Y=$rows
    declare -gA map_seen_arr=()
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            if [[ "${map_seen_arr[$x,$y]}" = "true" ]]; then
                continue
            fi

            char="${map_arr[$x,$y]}"
            declare -gA plants=()
            perform_search "$x" "$y" "$char" map_arr
            area="${#plants[*]}"
            perimiter=0
            for i in "${plants[@]}"; do
                ((perimiter += i))
            done
            price=$((area * perimiter))
            echo "  ($char) | Area: $area | Perimiter: $perimiter | Price: $price"
            ((answer+=price))
        done
    done


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

perform_search2 () {
    local x=$1
    local y=$2
    local char=$3

    # Mark this coord as seen
    map_seen_arr["$x,$y"]="true"
    plants["$x,$y"]="true"

    local map_l="${map_arr[$((x-1)),$y]}"
    local map_t="${map_arr[$x,$((y-1))]}"
    local map_r="${map_arr[$((x+1)),$y]}"
    local map_b="${map_arr[$x,$((y+1))]}"
    local map_tl="${map_arr[$((x-1)),$((y-1))]}"
    local map_tr="${map_arr[$((x+1)),$((y-1))]}"
    local map_br="${map_arr[$((x+1)),$((y+1))]}"
    local map_bl="${map_arr[$((x-1)),$((y+1))]}"


    # Interior corners
    # XAX
    # A^X
    # XXX
    if [[ "$map_l" = "$char" && "$map_t" = "$char" && "$map_tl" != "$char" ]]; then
        ((num_corners+=1))
        # echo "    ($x,$y) adding 1 interior"
    fi
    # XAX
    # X^A
    # XXX
    if [[ "$map_r" = "$char" && "$map_t" = "$char" && "$map_tr" != "$char" ]]; then
        ((num_corners+=1))
        # echo "    ($x,$y) adding 1 interior"
    fi
    # XXX
    # X^A
    # XAX
    if [[ "$map_r" = "$char" && "$map_b" = "$char" && "$map_br" != "$char" ]]; then
        ((num_corners+=1))
        # echo "    ($x,$y) adding 1 interior"
    fi
    # XXX
    # A^X
    # XAX
    if [[ "$map_l" = "$char" && "$map_b" = "$char" && "$map_bl" != "$char" ]]; then
        ((num_corners+=1))
        # echo "    ($x,$y) adding 1 interior"
    fi
    
    # Exterior corners
    # AAX
    # A^X
    # XXX
    if [[ "$map_l" = "$char" && "$map_t" = "$char" && "$map_r" != "$char" && "$map_b" != "$char" ]]; then
        ((num_corners++))
        # echo "    ($x,$y) adding 1 exterior"
    fi
    # AAX
    # ^AX
    # XXX
    if [[ "$map_l" != "$char" && "$map_t" = "$char" && "$map_r" = "$char" && "$map_b" != "$char" ]]; then
        ((num_corners++))
        # echo "    ($x,$y) adding 1 exterior"
    fi
    # ^AX
    # AAX
    # XXX
    if [[ "$map_l" != "$char" && "$map_t" != "$char" && "$map_r" = "$char" && "$map_b" = "$char" ]]; then
        ((num_corners++))
        # echo "    ($x,$y) adding 1 exterior"
    fi
    # A^X
    # AAX
    # XXX
    if [[ "$map_l" = "$char" && "$map_t" != "$char" && "$map_r" != "$char" && "$map_b" = "$char" ]]; then
        ((num_corners++))
        # echo "    ($x,$y) adding 1 exterior"
    fi
    # XAX  XXX  XXX  XXX
    # X^X  A^X  X^X  X^A
    # XXX  XXX  XAX  XXX
    if [[ "$map_l" = "$char" && "$map_t" != "$char" && "$map_r" != "$char" && "$map_b" != "$char" ]]; then
        ((num_corners+=2))
        # echo "    ($x,$y) adding 2 exteriors"
    fi
    if [[ "$map_l" != "$char" && "$map_t" = "$char" && "$map_r" != "$char" && "$map_b" != "$char" ]]; then
        ((num_corners+=2))
        # echo "    ($x,$y) adding 2 exteriors"
    fi
    if [[ "$map_l" != "$char" && "$map_t" != "$char" && "$map_r" = "$char" && "$map_b" != "$char" ]]; then
        ((num_corners+=2))
        # echo "    ($x,$y) adding 2 exteriors"
    fi
    if [[ "$map_l" != "$char" && "$map_t" != "$char" && "$map_r" != "$char" && "$map_b" = "$char" ]]; then
        ((num_corners+=2))
        # echo "    ($x,$y) adding 2 exteriors"
    fi
    # XXX
    # X^X
    # XXX
    if [[ "$map_l" != "$char" && "$map_t" != "$char" && "$map_r" != "$char" && "$map_b" != "$char" ]]; then
        ((num_corners+=4))
        # echo "    ($x,$y) adding 4 exteriors"
    fi
    
    
    # Perform recursive searches
    # left
    new_x=$((x-1))
    new_y=$y
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search2 "$new_x" "$new_y" "$char"
    fi
    # right
    new_x=$((x+1))
    new_y=$y
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search2 "$new_x" "$new_y" "$char"
    fi
    # up
    new_x=$x
    new_y=$((y-1))
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search2 "$new_x" "$new_y" "$char"
    fi
    # down
    new_x=$x
    new_y=$((y+1))
    if [[ -z "${plants[$new_x,$new_y]}" && "${map_arr[$new_x,$new_y]}" = "$char" ]]; then
        perform_search2 "$new_x" "$new_y" "$char"
    fi

    
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    
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

    # Search through entire map
    declare -g MAX_X MAX_Y
    MAX_X=$cols
    MAX_Y=$rows
    declare -gA map_seen_arr=()
    for ((y = 0 ; y < "$MAX_Y" ; y++ )); do
        for ((x = 0 ; x < "$MAX_X" ; x++ )); do
            if [[ "${map_seen_arr[$x,$y]}" = "true" ]]; then
                continue
            fi

            char="${map_arr[$x,$y]}"
            declare -gA plants=()
            declare -g num_corners="0"
            perform_search2 "$x" "$y" "$char" map_arr
            area="${#plants[*]}"
            price=$((area * num_corners))
            echo "  ($char) | Area: $area | Corners: $num_corners | Price: $price"
            ((answer+=price))
        done
    done

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}


# solution_1 example_input.txt   # Should be 140
# solution_1 example_input_2.txt # Should be 772
# solution_1 example_input_3.txt # Should be 1930
# echo
# solution_1 input.txt


# solution_2 test_input.txt
# solution_2 example_input.txt   # Should be 80
# solution_2 example_input_2.txt   # Should be 436
# solution_2 example_input_4.txt # Should be 236
# solution_2 example_input_5.txt # Should be 368
# solution_2 example_input_3.txt # Should be 1206
# echo
solution_2 input.txt 
