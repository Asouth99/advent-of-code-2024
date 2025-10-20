#!/usr/bin/env bash

mix () {
    secret=$1
    mixed_n=$2
    echo "$(( secret ^ mixed_n ))"
}

prune () {
    secret=$1
    echo "$(( secret % 16777216 ))"
}


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

            secret_n=$(mix "$secret_n" "$(( secret_n * 64 ))")
            secret_n=$(prune "$secret_n")

            secret_n=$(mix "$secret_n" "$(( secret_n / 32 ))")
            secret_n=$(prune "$secret_n")

            secret_n=$(mix "$secret_n" "$(( secret_n * 2048 ))")
            secret_n=$(prune "$secret_n")

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

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# Tests
# echo "$(mix 42 15)" # 42 is secret number and we are mixing in 15. Should return 37
# echo "$(prune 100000000)" # 100000000 is secret number. Should return 16113920




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

# solution_2 example_input.txt
# echo
# solution_2 input.txt
