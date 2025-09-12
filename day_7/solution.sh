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

    # Create output file
    output_file="${1/.txt/}_output.txt"
    if test -f $output_file ; then
        echo "Output file exists! Exiting..."
        exit 1
    fi

    # Read file with pre calculated inputs
    echo "Reading Pre Calculated file: $2"
    declare -a pre_calculated_results
    declare -a pre_calculated_equations
    i=0
    while read -r line; do
        IFS=":"
        read -r result equation <<< "$line"
        unset IFS
        pre_calculated_results+=("$result")
        pre_calculated_equations+=("$equation")
        ((i++))
    done < "$2"

    # Get the equation with the most numbers
    declare -a numbers_of_equation_with_most_numbers=()
    IFS=" "
    for ((i = 0 ; i < ${#equations[*]} ; i++ )); do
        read -ra numbers <<< "${equations[$i]}"
        if [[ ${#numbers[*]} -gt ${#numbers_of_equation_with_most_numbers[*]} ]]; then
            numbers_of_equation_with_most_numbers=(${numbers[*]})
        fi
    done
    unset IFS
    echo "  Equation with the most numbers is ${numbers_of_equation_with_most_numbers[*]} with ${#numbers_of_equation_with_most_numbers[*]} numbers"

    # Generate a list of all operations of operations
    declare -a operations_options=()
    allowed_operations=("+" "*" "|")
    number_of_operations_to_try=$(( "${#allowed_operations[*]}" ** ("${#numbers_of_equation_with_most_numbers[*]}" - 1) ))
    echo "    There will be ${number_of_operations_to_try} different combinations to calculate"

    for ((j = 0 ; j < number_of_operations_to_try ; j++ )); do
        operation=""
        for ((k = 0 ; k < (${#numbers[*]} - 1) ; k++ )); do
            operation_index=$(( (j / ( ${#allowed_operations[*]} ** k )) % ${#allowed_operations[*]} ))
            operation="${allowed_operations[$operation_index]}${operation}"
        done
        # echo "Operation ${j}: ${operation}"
        operations_options+=("$operation")
    done
    # echo "  Operation Options: ${operations_options[*]}"


    # Attempt to solve each equation
    IFS=" "
    for ((i = 0 ; i < "$number_of_equations" ; i++ )); do
        # [[ "$i" -gt "6" ]] && break

        # Set some vars
        result="${results[$i]}"
        count=$((i+1))
        echo -n "  ($count/$number_of_equations) Attempting to solve | $result : "
        read -ra numbers <<< "${equations[$i]}"
        echo "${numbers[*]}"

        # Check if the number is in the pre calculated list. 
        found_in_pre_calculated_list=false
        for ((j = 0 ; j < "${#pre_calculated_results[*]}" ; j++ )); do
            if [[ "$result" -eq "${pre_calculated_results[$j]}" ]]; then
                echo "    Found $result in the pre calculated list. $result = ${pre_calculated_equations[$j]}"
                found_in_pre_calculated_list=true
                answer=$(( answer + result ))
                break
            fi
        done
        [[ "$found_in_pre_calculated_list" == "true" ]] && continue

        # Find out how many different combinations we need to try
        number_of_operations_to_try=$(( "${#allowed_operations[*]}" ** ("${#numbers[*]}" - 1) ))
        echo "    There will be ${number_of_operations_to_try} different combinations to try"

        # For each operation combination calcualte the value of it and check if it equals the result.
        for ((j = 0 ; j < number_of_operations_to_try ; j++ )); do
            operation="${operations_options[$j]}"
            operation="${operation:(( ${#operation} - ${#numbers[*]} + 1  )):((${#numbers[*]} - 1))}"
            # echo "      Trying ${operation}"
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
                echo "$result : $string_to_calculate"  >> "$output_file"
                answer=$(( answer + result ))
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

solution_2 example_input.txt # example_input_pre_calculated.txt
echo
solution_2 input.txt input_pre_calculated.txt # 451970149727469 | Took 2901 seconds