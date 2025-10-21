#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    declare -a secret_numbers=()
    while read -r line; do
        secret_numbers+=("$line")
    done < $1
    # echo "secret_numbers: ${secret_numbers[*]}"

    
    for num in "${secret_numbers[@]}"; do
        secret_n=$num
        echo "Starting with secret number $secret_n"
        for (( i = 0 ; i < "$GENERATIONS" ; i++ )); do

            secret_n=$(( secret_n ^ ( secret_n * 64 ) ))
            secret_n=$(( secret_n % 16777216 ))

            secret_n=$(( secret_n ^ ( secret_n / 32 ) ))
            secret_n=$(( secret_n % 16777216 ))

            secret_n=$(( secret_n ^ ( secret_n * 2048 ) ))
            secret_n=$(( secret_n % 16777216 ))

            # echo "  ($((i+1))/$GENERATIONS) secret number is $secret_n"
        done
        echo "After $GENERATIONS generations secret number = $secret_n"
        answer=$((answer + secret_n))
    done


    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# With secret number = 123 the next 10 numbers would be:
# 15887950
# 16495136
# 527345
# 704524
# 1553684
# 12683156
# 11100544
# 12249484
# 7753432
# 5908254
# declare -g GENERATIONS="10"
# solution_1 example_input_2.txt

# 2000th Secret number for each buyer. 1 (start) 8685429 (2000th)
# 1:    8685429
# 10:   4700978
# 100:  15273692
# 2024: 8667524
# declare -g GENERATIONS="2000"
# solution_1 example_input.txt # Answer should be 37327623

# declare -g GENERATIONS="2000"
# solution_1 input.txt # 17612566393 took 15630 seconds


all_same() {
    local -n array=$1
    local i
    for (( i = 1 ; i < "${#array[@]}" ; i++ )); do
        if [[ "${array[$i]}" != "${array[$((i-1))]}" ]]; then
            return 1
        fi
    done
    return 0
}


solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    declare -a secret_numbers=()
    while read -r line; do
        secret_numbers+=("$line")
    done < $1
    # echo "secret_numbers: ${secret_numbers[*]}"

    declare -A all_secret_numbers=()   # [ initial_secret_num , generation_index ] = secret_num_at_generation_index
    declare -A all_prices=()           # [ initial_secret_num , generation_index ] = price_at_generation_index
    declare -A all_changes=()          # [ initial_secret_num , generation_index ] = change_at_generation_index
    declare -A all_change_sequences=() # [ initial_secret_num;change_1,change_2,change_3,change_4 ] = smallest_index_change_sequence_occurs
    declare -A all_change_sequence_keys=() # [ change_1,change_2,change_3,change_4 ] = true/false

    # Generate all secret numbers
    echo
    echo "Generating all secret numbers for $GENERATIONS generations..."
    ii="0"
    for num in "${secret_numbers[@]}"; do
        ((ii++))
        secret_n=$num
        echo "  ($ii/${#secret_numbers[@]}) Starting Number: $secret_n"
        for (( i = 0 ; i <= "$GENERATIONS" ; i++ )); do
            prev_price="$price"
            price="${secret_n: -1}"
            if [[ "$secret_n" = "$num" ]]; then
                change=""
            else
                change=$((price - prev_price))
            fi
            
            all_secret_numbers["$num,$i"]=$secret_n
            all_prices["$num,$i"]="$price"
            all_changes["$num,$i"]="$change"

            if [[ "$i" -ge "4" ]]; then
                change_1="${all_changes[$num,$((i-3))]}"
                change_2="${all_changes[$num,$((i-2))]}"
                change_3="${all_changes[$num,$((i-1))]}"
                change_4="${all_changes[$num,$i]}"
                all_change_sequence_keys["$change_1,$change_2,$change_3,$change_4"]="true"
                if [[ "${all_change_sequences[$num;$change_1,$change_2,$change_3,$change_4]}" = "" ]]; then
                    all_change_sequences["$num;$change_1,$change_2,$change_3,$change_4"]="$i"
                else
                    if [[ "$i" -lt "${all_change_sequences[$num;$change_1,$change_2,$change_3,$change_4]}" ]]; then
                        all_change_sequences["$num;$change_1,$change_2,$change_3,$change_4"]="$i"
                    fi
                fi
            fi

            # echo "  ($i/$GENERATIONS) secret number: ${all_secret_numbers[$num,$i]} | price: ${all_prices[$num,$i]} | change: ${all_changes[$num,$i]}"

            secret_n=$(( secret_n ^ ( secret_n * 64 ) ))
            secret_n=$(( secret_n % 16777216 ))

            secret_n=$(( secret_n ^ ( secret_n / 32 ) ))
            secret_n=$(( secret_n % 16777216 ))

            secret_n=$(( secret_n ^ ( secret_n * 2048 ) ))
            secret_n=$(( secret_n % 16777216 ))

        done
        echo "    After $GENERATIONS generations ${all_secret_numbers[$num,$GENERATIONS]}"
        # echo "    Change sequence prices ${all_change_sequences[*]}"
    done
    # echo "    Change Sequences ${!all_change_sequences[*]}"
    # echo "    Change Sequences ${!all_change_sequence_keys[*]}"


    # Go through all_change_sequence_keys and find the one that gives the maximum total price
    echo
    echo "Finding change sequence to maximise price..."
    maxTotalPrice="0"
    maxTotalPriceSequence=""
    for sequence in "${!all_change_sequence_keys[@]}"; do # Start at 4 cos we need at least 4 changes and first number has no change
        totalPrice="0"
        for num in "${secret_numbers[@]}"; do
            index="${all_change_sequences[$num;$sequence]}"
            price="${all_prices[$num,$index]}"
            ((totalPrice+=price))
        done
        if [[ "$totalPrice" -gt "$maxTotalPrice" ]]; then
            maxTotalPrice="$totalPrice"
            maxTotalPriceSequence="$sequence"
        fi
    done

    echo "Maximum Total Price: $maxTotalPrice using sequence $maxTotalPriceSequence"
    answer="$maxTotalPrice"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# Tests
# test_array_fail=(1 2 3 4 5)
# if all_same test_array_fail ; then
#     echo "test_array_fail failed"
#     exit 1
# else
#     echo "test_array_fail passed"
# fi
# test_array_succeed=(1 1 1 1 1)
# if all_same test_array_succeed ; then
#     echo "test_array_succeed passed"
# else
#     echo "test_array_succeed failed"
#     exit 1
# fi

# Starting with secret number 123
# The prices = the units digit. Change from previous is the third column.
#      123: 3 
# 15887950: 0 (-3)
# 16495136: 6 (6)
#   527345: 5 (-1)
#   704524: 4 (-1)
#  1553684: 4 (0)
# 12683156: 6 (2)
# 11100544: 4 (-2)
# 12249484: 4 (0)
#  7753432: 2 (-2)
# declare -g GENERATIONS="9"
# solution_2 example_input_2.txt

# declare -g GENERATIONS="2000"
# solution_2 example_input_3.txt
# echo
declare -g GENERATIONS="2000"
solution_2 input.txt # 1968 using sequence 2,0,-2,3 . Took 1102 seconds
