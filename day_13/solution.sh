#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    # Button A costs 3 tokens
    # Button B costs 1 token
    # What is the cheapest way to get to the prize?
    
    XY_REGEX="\+([0-9]+),.*\+([0-9]+)"
    PRIZE_REGEX="=([0-9]+),.*=([0-9]+)"
    A_TOKEN_COST=3
    B_TOKEN_COST=1
    while mapfile -t -n 4 array && ((${#array[@]})); do
        a="${array[0]}"
        b="${array[1]}"
        prize="${array[2]}"
        
        if [[ $a =~ $XY_REGEX ]]; then
            a_x="${BASH_REMATCH[1]}"
            a_y="${BASH_REMATCH[2]}"
        else
            echo "ERROR: $a didn't match $XY_REGEX"
        fi
        if [[ $b =~ $XY_REGEX ]]; then
            b_x="${BASH_REMATCH[1]}"
            b_y="${BASH_REMATCH[2]}"
        else
            echo "ERROR: $b didn't match $XY_REGEX"
        fi
        if [[ $prize =~ $PRIZE_REGEX ]]; then
            prize_x="${BASH_REMATCH[1]}"
            prize_y="${BASH_REMATCH[2]}"
        else
            echo "ERROR: $prize didn't match $XY_REGEX"
        fi
        # echo "-----------------------------------------"
        # echo "A_X: $a_x | A_Y: $a_y"
        # echo "B_X: $b_x | B_Y: $b_y"
        # echo "PRIZE_X: $prize_x | PRIZE_Y: $prize_y"

        solution_found="false"
        min_price="0"
        for (( i=prize_x/a_x ; i>=0 ; i-- )); do
            a_num=$i
            ((b_target_x = prize_x - a_x * i))
            if [[ $((b_target_x % b_x)) -eq "0" ]]; then    
                b_num=$((b_target_x / b_x))
            else
                continue
            fi
            # Check if this satisfies the y aswell
            if [[ $((a_num * a_y + b_num * b_y)) -eq "$prize_y" ]]; then
                # we have found a solution
                solution_found="true"
                price=$((a_num * A_TOKEN_COST + b_num * B_TOKEN_COST))
                if [[ "$price" -lt "$min_price" || "$min_price" -eq "0" ]]; then    
                    min_price=$price
                    continue
                fi
            else
                continue
            fi
        done


        if [[ "$solution_found" = "true" ]]; then
            echo "Solution Found - min price: $min_price"
            ((answer+=min_price))
        else
            echo "No Solution Found!"
        fi
        
    done < $1

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    
    # Button A costs 3 tokens
    # Button B costs 1 token
    # What is the cheapest way to get to the prize?
    # Part2: The actual prize X and Y is increased by 10000000000000

    XY_REGEX="\+([0-9]+),.*\+([0-9]+)"
    PRIZE_REGEX="=([0-9]+),.*=([0-9]+)"
    A_TOKEN_COST=3
    B_TOKEN_COST=1
    PART_2_ADJUSTMENT=10000000000000
    while mapfile -t -n 4 array && ((${#array[@]})); do
        a="${array[0]}"
        b="${array[1]}"
        prize="${array[2]}"
        
        if [[ $a =~ $XY_REGEX ]]; then
            a_x="${BASH_REMATCH[1]}"
            a_y="${BASH_REMATCH[2]}"
        else
            echo "ERROR: $a didn't match $XY_REGEX"
        fi
        if [[ $b =~ $XY_REGEX ]]; then
            b_x="${BASH_REMATCH[1]}"
            b_y="${BASH_REMATCH[2]}"
        else
            echo "ERROR: $b didn't match $XY_REGEX"
        fi
        if [[ $prize =~ $PRIZE_REGEX ]]; then
            prize_x="${BASH_REMATCH[1]}"
            prize_y="${BASH_REMATCH[2]}"
            ((prize_x+=PART_2_ADJUSTMENT))
            ((prize_y+=PART_2_ADJUSTMENT))
        else
            echo "ERROR: $prize didn't match $XY_REGEX"
        fi
        # echo "-----------------------------------------"
        # echo "A_X: $a_x | A_Y: $a_y"
        # echo "B_X: $b_x | B_Y: $b_y"
        # echo "PRIZE_X: $prize_x | PRIZE_Y: $prize_y"

        # simultaneous equations
        # (1) (a_x)a_num + (b_x)b_num = prize_x
        # (2) (a_y)a_num + (b_y)b_num = prize_y
        # (1)*a_y = (a_x*a_y)a_num  + (b_x*a_y)b_num = prize_x*a_y
        # (2)*a_x = (a_y*a_x)a_num  + (b_y*a_x)b_num = prize_y*a_x
        # (1)*a_y - (2)*a_x = (b_x*a_y - b_y*a_x)b_num = prize_x*a_y - prize_y*a_x (or the other way around if b_y*a_x > b_x*a_y)
        # b_num = (prize_x*a_y - prize_y*a_x) / (b_x*a_y - b_y*a_x) -> Solution found if this is non-negative, integer and results in a_num also being the same
        # using (1) a_num = (prize_x - b_x * b_num) / a_x
        if [[ $(( b_y*a_x )) -gt $(( b_x*a_y )) ]]; then
            if [[ $(((prize_y*a_x - prize_x*a_y) % (b_y*a_x - b_x*a_y))) = "0" ]]; then
                ((b_num=(prize_y*a_x - prize_x*a_y) / (b_y*a_x - b_x*a_y)))
                # Check if b_num is not negative
                if [[ "${b_num::1}" = "-" ]]; then   
                    b_found="false"
                else 
                    b_found="true"
                fi
            else
                b_found="false"
            fi
        else
            if [[ $(((prize_x*a_y - prize_y*a_x) % (b_x*a_y - b_y*a_x))) = "0" ]]; then
                ((b_num=(prize_x*a_y - prize_y*a_x) / (b_x*a_y - b_y*a_x)))
                # Check if b_num is not negative
                if [[ "${b_num::1}" = "-" ]]; then   
                    b_found="false"
                else 
                    b_found="true"
                fi
            else
                b_found="false"
            fi
        fi
        if [[ "$b_found" = "true" ]]; then
            # Check if a_num is not negative and is an integer
            if [[ $(((prize_x - b_x * b_num) % a_x)) = "0" ]]; then
                ((a_num=((prize_x - b_x * b_num) / a_x)))
                if [[ "${a_num::1}" = "-" ]]; then   
                    a_found="false"
                else 
                    a_found="true"
                fi
            else
                a_found="false"
            fi
        fi


        if [[ "$a_found" = "true" && "$b_found" = "true" ]]; then
            ((price=A_TOKEN_COST*a_num + B_TOKEN_COST*b_num))
            echo "Solution Found - A: $a_num | B: $b_num | Price: $price"
            ((answer+=price))
        else
            echo "No Solution Found!"
        fi
        
    done < $1

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
