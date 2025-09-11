#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    # Read the input
    declare -a results
    declare -a equations
    i=0
    while read -r line; do
        # echo -n "Line: $line | "
        IFS=":"
        read -r result equation <<< "$line"
        unset IFS
        results+=("$result")
        equations+=("$equation")
        # echo -n ">${results[*]}< | >${equations[*]}<"
        # echo
        ((i++))
    done < "$1"
    number_of_equations=$i


    # Attempt to solve each equation
    IFS=" "
    allowed_operations=("+" "*")
    for ((i = 0 ; i < "$number_of_equations" ; i++ )); do
        # [[ "$i" -gt "1" ]] && break

        # Set some vars
        result="${results[$i]}"
        echo -n "  ($i/$number_of_equations) Attempting to solve | $result : "
        read -ra numbers <<< "${equations[$i]}"
        echo "${numbers[*]}"

        # Create a list of all combinations of operations
        declare -a operations_options=()
        number_of_operations_to_try=$(( "${#allowed_operations[*]}" ** ("${#numbers[*]}" - 1) ))
        echo "    There will be ${number_of_operations_to_try} different combinations to try"
        for ((j = 0 ; j < ( "${number_of_operations_to_try}" ) ; j++ )); do
            based_string=$(echo "obase=${#allowed_operations[*]};${j}" | bc)
            based_string_length="${#based_string}"
            # add 0 to the left to make sure based_string is the right length
            for ((k = 0 ; k < ( "${#numbers[*]}" - 1 - "$based_string_length" ) ; k++ )); do
                based_string="0${based_string}"
            done
            # echo -n "      Based String: $based_string"
            operation=""
            while read -n 1 char; do
                [[ ! "$char" =~ [0-9] ]] && continue
                # echo "      Char: <$char> -> ${allowed_operations[$char]}"
                operation="${operation}${allowed_operations[$char]}"
            done <<< "$based_string "
            # echo "      $operation"
            operations_options+=("$operation")
        done
        # echo "      Operation Options: ${operations_options[*]}"

        # For each operation combination calcualte the value of it and check if it equals the result.
        for ((j = 0 ; j < "${#operations_options[*]}" ; j++ )); do
            operation="${operations_options[$j]}"
            string_to_calculate="${numbers[0]}"
            tmp_calculation="${numbers[0]}"
            for ((k = 1 ; k < "${#numbers[*]}" ; k++ )); do
                string_to_calculate="${string_to_calculate} ${operation:(($k-1)):1} ${numbers[$k]}"
                tmp_calculation="${tmp_calculation} ${operation:(($k-1)):1} ${numbers[$k]}"
                tmp_result=$(( $tmp_calculation ))
                tmp_calculation="$tmp_result"
            done
            # echo "      Trying $string_to_calculate = ${tmp_result}"
            if [[ "$tmp_result" -eq "$result" ]]; then
                echo "      $string_to_calculate = $result | Success!"
                answer=$((answer + $result))
                break
            fi
        done
    done
    unset IFS

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}





solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0

    # Read the input
    declare -a results
    declare -a equations
    i=0
    while read -r line; do
        # echo -n "Line: $line | "
        IFS=":"
        read -r result equation <<< "$line"
        unset IFS
        results+=("$result")
        equations+=("$equation")
        # echo -n ">${results[*]}< | >${equations[*]}<"
        # echo
        ((i++))
    done < "$1"
    number_of_equations=$i


    # Attempt to solve each equation
    IFS=" "
    allowed_operations=("+" "*" "|")
    for ((i = 6 ; i < "$number_of_equations" ; i++ )); do
        [[ "$i" -gt "6" ]] && break

        # Set some vars
        result="${results[$i]}"
        echo -n "  ($i/$number_of_equations) Attempting to solve | $result : "
        read -ra numbers <<< "${equations[$i]}"
        echo "${numbers[*]}"

        # Create a list of all combinations of operations
        declare -a operations_options=()
        number_of_operations_to_try=$(( "${#allowed_operations[*]}" ** ("${#numbers[*]}" - 1) ))
        echo "    There will be ${number_of_operations_to_try} different combinations to try"
        for ((j = 0 ; j < ( "${number_of_operations_to_try}" ) ; j++ )); do
            based_string=$(echo "obase=${#allowed_operations[*]};${j}" | bc)
            based_string_length="${#based_string}"
            # add 0 to the left to make sure based_string is the right length
            for ((k = 0 ; k < ( "${#numbers[*]}" - 1 - "$based_string_length" ) ; k++ )); do
                based_string="0${based_string}"
            done
            # echo -n "      Based String: $based_string"
            operation=""
            while read -rn 1 char; do
                [[ ! "$char" =~ [0-9] ]] && continue
                # echo "      Char: <$char> -> ${allowed_operations[$char]}"
                operation="${operation}${allowed_operations[$char]}"
            done <<< "$based_string "
            # echo "      $operation"
            operations_options+=("$operation")
        done
        # echo "      Operation Options: ${operations_options[*]}"

        # For each operation combination calcualte the value of it and check if it equals the result.
        for ((j = 0 ; j < "${#operations_options[*]}" ; j++ )); do
            operation="${operations_options[$j]}"
            string_to_calculate="${numbers[0]}"
            tmp_calculation="${numbers[0]}"
            for ((k = 1 ; k < "${#numbers[*]}" ; k++ )); do
                string_to_calculate="${string_to_calculate} ${operation:(($k-1)):1} ${numbers[$k]}"
                # tmp_calculation="${tmp_calculation} ${operation:(($k-1)):1} ${numbers[$k]}"

                case ${operation:(($k-1)):1} in
                    "+")
                        tmp_calculation=$(( tmp_calculation + ${numbers[$k]} ))
                        ;;
                    "*")
                        tmp_calculation=$(( tmp_calculation * ${numbers[$k]} ))
                        ;;
                    "|")
                        tmp_calculation="${tmp_calculation}${numbers[$k]}"
                        ;;
                esac
                tmp_result=$(( $tmp_calculation ))
                tmp_calculation="$tmp_result"
            done
            # echo "      Trying - $string_to_calculate = ${tmp_result}"
            if [[ "$tmp_result" -eq "$result" ]]; then
                echo "      $string_to_calculate = $result | Success!"
                answer=$((answer + $result))
                break
            fi
        done
    done
    unset IFS

    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}


# solution_1 example_input.txt # 3749
# echo
# solution_1 input.txt # 3312271365652 | Took 670 seconds

# solution_2 example_input.txt
# echo
# solution_2 input.txt


# Took 531 seconds just to calculate number 6

seconds_start=$SECONDS

for ((j = 0 ; j < 2048 ; j++ )); do
    based_string=$(echo "obase=2;${j}" | bc)
    based_string_length="${#based_string}"
    # add 0 to the left to make sure based_string is the right length
    for ((k = 0 ; k < ( 12 - 1 - "$based_string_length" ) ; k++ )); do
        based_string="0${based_string}"
    done
    operation=""
    while read -n 1 char; do
        [[ ! "$char" =~ [0-9] ]] && continue
        operation="${operation}${allowed_operations[$char]}"
    done <<< "$based_string "
done



seconds_end=$SECONDS
seconds_diff=$((seconds_end - seconds_start))
echo "Answer took $seconds_diff seconds to calculate"


seconds_start=$SECONDS
operation_string_length="2"
for ((j = 0 ; j < 2048 ; j++ )); do
    echo
done



seconds_end=$SECONDS
seconds_diff=$((seconds_end - seconds_start))
echo "Answer took $seconds_diff seconds to calculate"