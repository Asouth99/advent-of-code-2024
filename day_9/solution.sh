#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    echo

    # Read input
    echo "step 0 - reading number"
    declare -a input_number=()
    while read -r -n 1 char; do
        input_number+=("$char")
    done < "$1"
    for num in "${input_number[@]}"; do # Echo input number
        echo -n "$num"
    done
    echo

    # Format number
    declare -a formatted_number=()
    digit_count=0
    echo
    echo "step 1 - formatting number"
    for ((i = 0 ; i < "${#input_number[@]}" ; i++ )); do
        number="${input_number[$i]}"
        if [[ $((i % 2)) = "0" ]]; then
            char="$((i/2))"
            ((digit_count+=number))
        else
            char="."
        fi
        for ((j = 0 ; j < number ; j++ )); do
            formatted_number+=("$char")
        done
    done
    for num in "${formatted_number[@]}"; do # Echo formatted number
        echo -n "$num"
    done
    echo
    echo "There are $digit_count digits in the formatted number"

    # Rearrange number
    declare -a rearraneged_number=()
    echo
    echo "step 2 - rearrange number"
    end_index=$(( ${#formatted_number[@]} - 1 ))
    for ((i = 0 ; i < digit_count ; i++ )); do
        char="${formatted_number[$i]}"

        end_char="${formatted_number[$end_index]}"
        while [[ "$end_char" = "." ]]; do
            ((end_index--))
            if [[ "$end_index" -lt "0" ]]; then break; fi
            end_char="${formatted_number[$end_index]}"
        done

        if [[ "$char" = "." ]]; then
            rearraneged_number+=("$end_char")
            ((end_index--))
        else
            rearraneged_number+=("$char")
        fi
    done
    for num in "${rearraneged_number[@]}"; do # Echo rearranged number
        echo -n "$num"
    done
    echo

    # Calculate checksum
    checksum="0"
    echo
    echo "step 3 - calculating checksum"
    for ((i = 0 ; i < ${#rearraneged_number[@]} ; i++ )); do
        char="${rearraneged_number[$i]}"
        (( checksum+=($i * $char) ))
    done
    echo "Checksum is $checksum"

    answer="$checksum"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}



solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    echo
    
    # Read input
    echo "step 0 - reading number"
    declare -a input_number=()
    while read -r -n 1 char; do
        input_number+=("$char")
    done < "$1"
    for num in "${input_number[@]}"; do # Echo input number
        echo -n "$num"
    done
    echo

    # Format number
    declare -a formatted_number=()
    file_count=0
    echo
    echo "step 1 - formatting number"
    for ((i = 0 ; i < "${#input_number[@]}" ; i++ )); do
        number="${input_number[$i]}"
        if [[ $((i % 2)) = "0" ]]; then
            char="$((i/2))"
            file_count=$char
        else
            char="."
        fi
        for ((j = 0 ; j < number ; j++ )); do
            formatted_number+=("$char")
        done
    done
    for num in "${formatted_number[@]}"; do # Echo formatted number
        echo -n "$num"
    done
    echo
    echo "Highest file ID is $file_count in the formatted number"

    # Rearrange number
    declare -a rearraneged_number=("${formatted_number[@]}")
    echo
    echo "step 2 - rearrange number"
    file_index_r=$(( ${#formatted_number[@]} - 1 ))
    file_index_l=$(( ${#formatted_number[@]} - 1 ))
    file_id="$file_count"
    for ((i = file_id ; i >= 0 ; i-- )); do
        file_id=$i
        echo "  Rearranging file ID $file_id"

        # Find the LEFT index of the file ID
        while [[ "${formatted_number[$file_index_r]}" != "$file_id" ]]; do
            ((file_index_r--))
            if [[ "$file_index_r" -lt "0" ]]; then break; fi
        done
        # Find the LEFT index of the file ID
        file_index_l=$file_index_r
        while [[ "${formatted_number[$file_index_l]}" = "$file_id" ]]; do
            ((file_index_l--))
            if [[ "$file_index_l" -lt "0" ]]; then break; fi
        done
        file_size=$((file_index_r - file_index_l))
        ((file_index_l++))
        # echo "  Found file ID $file_id at L:$file_index_l, R:$file_index_r with size $file_size"

        # Check if there is a space availble that fits file ID
        space_available="false"
        for ((j = 0 ; j < file_index_l ; j++ )); do
            space_index_l=$j
            char="${rearraneged_number[$j]}"
            if [[ "$char" != "." ]]; then
                continue
            fi
            space_index_r="$j"
            while [[ "${rearraneged_number[$space_index_r]}" = "." ]]; do
                ((space_index_r++))
                if [[ "$space_index_r" -ge "${#rearraneged_number[@]}" ]]; then break 2; fi
            done
            space=$((space_index_r - space_index_l))
            if [[ "$space" -ge "$file_size" ]]; then
                space_available="true"
                break
            fi
        done
        ((space_index_r--))
        if [[ "$space_available" = "false" ]]; then
            # echo "    No space available to move file ID $file_id with size $file_size"
            continue
        fi
        # echo "  Found space for file ID $file_id at L:$space_index_l, R:$space_index_r with size $file_size"

        # There is space so make the swap
        for ((j = 0 ; j < file_size ; j++ )); do
            rearraneged_number["$(( j + space_index_l ))"]="$file_id"
            rearraneged_number["$(( j + file_index_l ))"]="."
        done

    done
    for num in "${rearraneged_number[@]}"; do # Echo rearranged number
        echo -n "$num"
    done
    echo

    # Calculate checksum
    checksum="0"
    echo
    echo "step 3 - calculating checksum"
    for ((i = 0 ; i < ${#rearraneged_number[@]} ; i++ )); do
        char="${rearraneged_number[$i]}"
        if [[ "$char" = "." ]]; then continue; fi
        (( checksum+=(i * char) ))
    done
    echo "Checksum is $checksum"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}


# solution_1 example_input.txt
# echo
# solution_1 input.txt # 6299243228569 took 10 seconds

solution_2 example_input.txt # Should be 2858
# echo
solution_2 input.txt # 6326952672104 took 2311 seconds