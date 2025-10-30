#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    line_num=0

    rows=$(wc -l "$1" | cut -d ' ' -f1)
    chars=$(wc -m "$1" | cut -d ' ' -f1)
    cols=$((chars / rows - 1))
    echo "$1 has $rows rows and $cols columns"

    # Create word_arr
    declare -a word_arr
    while read -r line; do
        ((line_num++))
        # echo "$line_num: $line"
        for ((i = 0 ; i < "$cols" ; i++ )); do
            word_arr+=("${line:$i:1}")
        done
        # echo "Word Array: ${word_arr[*]}"
    done < "$1"
    # word_arr is a flattened 1D array containing all chars in input file
    # column N , row M is accessed by word_arr[ (( $M * $cols )) + $N ]

    

    i=0
    horizontals=0
    verticals=0
    diagonals=0
    for char in ${word_arr[*]}; do
        # echo "Char: $char"
        if [[ "$char" == "X" ]]; then
            # echo "Checking for XMAS"
            pos_col=$(($i % $cols))
            pos_row=$(($i / $rows))
            # echo "C: $pos_col | R: $pos_row"

            # Check Horizontally (2)
            if [[ $pos_col -lt $(( cols - 4 + 1)) ]]; then
                # echo "Checking right"
                word="${word_arr[*]:$i:4}"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((horizontals++))
                fi
            fi
            if [[ $pos_col -gt 2 ]]; then
                # echo "Checking left"
                word="${word_arr[*]:(($i-3)):4}"
                if [[ "$word" == "S A M X" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((horizontals++))
                fi
            fi
            
            # Check Vertically   (2)
            if [[ $pos_row -gt 2 ]]; then
                # echo "Checking up"
                word="${word_arr[$i]} ${word_arr[$((i - $cols * 1))]} ${word_arr[$((i - $cols * 2))]} ${word_arr[$((i - $cols * 3))]}"
                # echo "Word: $word"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((verticals++))
                fi
            fi
            if [[ $pos_row -lt $(( rows - 4 + 1)) ]]; then
                # echo "Checking down"
                word="${word_arr[$i]} ${word_arr[$((i + $cols * 1))]} ${word_arr[$((i + $cols * 2))]} ${word_arr[$((i + $cols * 3))]}"
                # echo "Word: $word"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((verticals++))
                fi
            fi
            
            # Check diagonally (4)
            if [[ $pos_col -lt $(( cols - 4 + 1)) && $pos_row -gt 2 ]]; then
                # echo "Checking up-right"
                word="${word_arr[$i]} ${word_arr[$((i + 1 - $cols * 1))]} ${word_arr[$((i + 2 - $cols * 2))]} ${word_arr[$((i + 3 - $cols * 3))]}"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((diagonals++))
                fi
            fi
            if [[ $pos_col -gt 2 && $pos_row -gt 2 ]]; then
                # echo "Checking up-left"
                word="${word_arr[$i]} ${word_arr[$((i - 1 - $cols * 1))]} ${word_arr[$((i - 2 - $cols * 2))]} ${word_arr[$((i - 3 - $cols * 3))]}"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((diagonals++))
                fi
            fi
            if [[ $pos_col -lt $(( cols - 4 + 1)) && $pos_row -lt $(( rows - 4 + 1)) ]]; then
                # echo "Checking down-right"
                word="${word_arr[$i]} ${word_arr[$((i + 1 + $cols * 1))]} ${word_arr[$((i + 2 + $cols * 2))]} ${word_arr[$((i + 3 + $cols * 3))]}"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((diagonals++))
                fi
            fi
            if [[ $pos_col -gt 2 && $pos_row -lt $(( rows - 4 + 1)) ]]; then
                # echo "Checking down-left"
                word="${word_arr[$i]} ${word_arr[$((i - 1 + $cols * 1))]} ${word_arr[$((i - 2 + $cols * 2))]} ${word_arr[$((i - 3 + $cols * 3))]}"
                if [[ "$word" == "X M A S" ]]; then
                    # echo "Found: $word"
                    ((answer++))
                    ((diagonals++))
                fi
            fi
        fi
        ((i++))
    done

    echo "Found $horizontals Horizontals | $verticals Verticals | $diagonals Diagonals"

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0


        line_num=0

    rows=$(wc -l "$1" | cut -d ' ' -f1)
    chars=$(wc -m "$1" | cut -d ' ' -f1)
    cols=$((chars / rows - 1))
    echo "$1 has $rows rows and $cols columns"

    # Create word_arr
    declare -a word_arr
    while read -r line; do
        ((line_num++))
        # echo "$line_num: $line"
        for ((i = 0 ; i < "$cols" ; i++ )); do
            word_arr+=("${line:$i:1}")
        done
        # echo "Word Array: ${word_arr[*]}"
    done < "$1"

    i=0
    for char in ${word_arr[*]}; do
        if [[ "$char" == "A" ]]; then
            pos_col=$(( i % cols))
            pos_row=$(( i / rows))
            # echo "C: $pos_col | R: $pos_row"

            if [[ ("$pos_col" -gt "0") && ("$pos_col" -lt "$((cols - 1))") && ("$pos_row" -gt "0") && ("$pos_row" -lt "$((rows - 1))") ]]; then
                word1="${word_arr[$((i - 1 - $cols * 1))]} ${word_arr[$i]} ${word_arr[$((i + 1 + $cols * 1))]}"
                word2="${word_arr[$((i + 1 - $cols * 1))]} ${word_arr[$i]} ${word_arr[$((i - 1 + $cols * 1))]}"
                if [[ ( "$word1" == "M A S" || "$word1" == "S A M" ) && ( "$word2" == "M A S" || "$word2" == "S A M" ) ]]; then
                    # echo "top-left -> bottom-right: $word1"
                    # echo "top-right -> bottom-left: $word2"
                    ((answer++))
                fi
            fi
        fi
        ((i++))
    done

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt

solution_2 example_input.txt
echo
solution_2 input.txt