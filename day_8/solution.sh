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

    # Get size of input map
    rows=$(wc -l "$1" | cut -d ' ' -f1)
    chars=$(wc -m "$1" | cut -d ' ' -f1)
    cols=$((chars / rows - 1))
    echo "$1 has $rows rows and $cols columns"

    # Read input map into a key value array
    declare -A map_arr
    declare -A antinode_arr
    r=0
    while read -r line; do
        for ((c = 0 ; c < "$cols" ; c++ )); do
            map_arr["$c,$r"]="${line:$c:1}"
            antinode_arr["$c,$r"]="${line:$c:1}"
        done
        ((r++))
    done < "$1"

    # Print map after we have read into an array
    echo "Input map looks like:"
    print_map "$rows" "$cols" map_arr

    # Place antinodes
    max_x=$cols
    max_y=$rows
    CHAR_REGEX="^[0-9,a-z,A-Z]"
    ANTINODE_REGEX="#$"
    for ((y = 0 ; y < "$max_y" ; y++ )); do
        for ((x = 0 ; x < "$max_x" ; x++ )); do
            if [[ "${map_arr[$x,$y]}" =~ $CHAR_REGEX ]]; then
                # echo "($x,$y) = ${map_arr["$x,$y"]}, antenna found"
                char="${map_arr["$x,$y"]:0:1}"

                for ((yy = "$y" ; yy < "$max_y" ; yy++ )); do
                    for ((xx = 0 ; xx < "$max_x" ; xx++ )); do
                        if [[ "$xx" = "$x" && "$yy" = "$y" ]]; then
                            continue
                        fi
                        if [[ "${map_arr[$xx,$yy]:0:1}" == "$char" ]]; then
                            # echo "    ($xx, $yy) = ${map_arr["$x,$y"]}, same antenna found"
                            diff_x=$(($xx - $x))
                            diff_y=$(($yy - $y))
                            antinode_location_x1=$(($x - $diff_x))
                            antinode_location_y1=$(($y - $diff_y))
                            antinode_location_x2=$(($xx + $diff_x))
                            antinode_location_y2=$(($yy + $diff_y))
                            # echo "    Placing antinodes at ($antinode_location_x1, $antinode_location_y1) and ($antinode_location_x2, $antinode_location_y2)"
                            antinode_arr[$antinode_location_x1,$antinode_location_y1]="#"
                            antinode_arr[$antinode_location_x2,$antinode_location_y2]="#"
                        fi
                    done
                done

            fi
        done
    done

    # Count how many anitnodes there are
    for ((y = 0 ; y < "$max_y" ; y++ )); do
        for ((x = 0 ; x < "$max_x" ; x++ )); do
            if [[ "${antinode_arr[$x,$y]}" = "#" ]]; then
                ((answer++))
            fi
        done
    done

    echo "Output map after placing antinodes:"
    print_map "$rows" "$cols" antinode_arr

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


solution_1 example_input.txt
echo
solution_1 input.txt

# solution_2 example_input.txt
# echo
# solution_2 input.txt 
