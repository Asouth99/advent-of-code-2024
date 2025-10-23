#!/usr/bin/env bash

declare -gA OPERATION_VALUES=(
    ["0,AND,0"]="0"
    ["0,AND,1"]="0"
    ["1,AND,0"]="0"
    ["1,AND,1"]="1"
    ["0,OR,0"]="0"
    ["0,OR,1"]="1"
    ["1,OR,0"]="1"
    ["1,OR,1"]="1"
    ["0,XOR,0"]="0"
    ["0,XOR,1"]="1"
    ["1,XOR,0"]="1"
    ["1,XOR,1"]="0"
)


none_unknown () {
    local -n array=$1
    local -n all_array=$2
    for obj in "${!array[@]}"; do
        val="${all_array[$obj]}"
        if [[ "$val" = "" ]]; then
            # echo "<$obj=$val>"
            return 1
        fi
    done
    return 0
}

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0


    # READ INPUT
    declare -A input_wires=()
    declare -A output_wires=()
    declare -A all_wires=()
    declare -A connections=()

    INPUT_WIRE_REGEX="^([xy][0-9]+): ([0-1])$"
    WIRE_CONNECTION_REGEX="^([a-z0-9]+) (XOR|OR|AND) ([a-z0-9]+) -> ([a-z0-9]+)$"
    newLinePassed="false"
    while read -r line; do
        if [[ "$line" = "" ]]; then
            newLinePassed="true"
            continue
        fi
        if [[ "$newLinePassed" = "false" ]]; then
            if [[ "$line" =~ $INPUT_WIRE_REGEX ]]; then
                # echo "Input wires: $line"
                input_wires["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
                all_wires["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
            else
                echo "Something has gone wrong reading the input" >&2
                exit 1
            fi
        else 
            if [[ "$line" =~ $WIRE_CONNECTION_REGEX ]]; then
                # echo "Wire connections: $line"
                w1="${BASH_REMATCH[1]}"
                operation="${BASH_REMATCH[2]}"
                w2="${BASH_REMATCH[3]}"
                w3="${BASH_REMATCH[4]}"
                
                connections["$w1,$operation,$w2,$w3"]="$w3"
                # all_wires["${BASH_REMATCH[2]}"]=""
                if [[ "${w1::1}" == "z" ]]; then
                    output_wires["$w1"]="unknown"
                fi
                if [[ "${w2::1}" == "z" ]]; then
                    output_wires["$w2"]="unknown"
                fi
                if [[ "${w3::1}" == "z" ]]; then
                    output_wires["$w3"]="unknown"
                fi
            else
                echo "Something has gone wrong reading the input" >&2
                exit 1
            fi
        fi
    done < "$1"

    # Display data read from file to ensure we have read it correctly
    echo "-- Input Wires --"
    for wire in "${!input_wires[@]}"; do
        echo "$wire = ${input_wires[$wire]}"
    done
    echo "-- Connections --"
    for connection in "${!connections[@]}"; do
        echo "$connection = ${connections[$connection]}"
    done
    echo "-- Output Wires --"
    for wire in "${!output_wires[@]}"; do
        echo "$wire = ${output_wires[$wire]}"
    done


    # Keep looping until all the output wires have known values
    echo
    echo "Calculating connections..."
    # if none_unknown output_wires; then
    #     echo "All output wires are known"
    # else
    #     echo "Some output wires are unknown"
    # fi
    ii=0
    while ! none_unknown output_wires all_wires; do
        ((ii++))
        echo "Attempt $ii"
        # if [[ "$ii" = "2" ]]; then break; fi
        if [[ "${#connections[@]}" = "0" ]]; then
            echo "No more connections to calculate, but output values are still unknown" >&2
            for wire in "${!output_wires[@]}"; do
                echo "$wire = ${all_wires[$wire]}"
            done
            exit 1
        fi

        for connection in "${!connections[@]}"; do
            IFS="," read -r w1 op w2 w3 <<< "$connection"
            
            echo -n "  $connection=$w3"
            
            # check if we know the values of w1 and w2 currently
            v1="${all_wires[$w1]}"
            v2="${all_wires[$w2]}"
            if [[ "$v1" = "" || "$v2" = "" ]]; then
                echo $'\033[0;33m'"    Skipping... $connection values unknown"$'\033[0;0m'
                continue
            fi

            # Caluclate the operation
            v3="${OPERATION_VALUES[$v1,$op,$v2]}"
            echo $'\033[0;32m'" --> $v1,$op,$v2=$v3"$'\033[0;0m'
            all_wires["$w3"]="$v3"
            unset "connections[$connection]"
        done
    done
    echo "Output Wires Calculated!"
    for wire in "${!output_wires[@]}"; do
        echo "$wire = ${all_wires[$wire]}"
    done

    # Read output values to get output number as a binary string
    binary_string=""
    number_of_output_wires="${#output_wires[@]}"
    for ((i = ("$number_of_output_wires"-1) ; i >= 0 ; i-- )); do
        num=$i
        while [[ "${#num}" -lt "${#number_of_output_wires}" ]]; do
            num="0$num"
        done
        wire="z$num"
        val="${all_wires[$wire]}"
        # echo "$wire=$val"
        binary_string="$binary_string$val"
    done
    echo "Binary String = $binary_string"
    output=$((2#$binary_string))
    echo "Output = $output"

    answer=$output

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

simulate () {
    local x=$1 # number in base10
    local y=$2 # number in base10
    local debug=$3
    # local z=$3 # number in base10
    local wire connection IFS v1 v2 v3 op w1 w2 w3

    # Function will return 0 if x+y=z. Will return 1 if x+y!=z
    # Requires the following to be set globally
    # x_wires     # Associative Arr [x00]="starting value"
    # y_wires     # Associative Arr [y00]="starting value"
    # z_wires     # Associative Arr [y00]="unknown"
    # all_wires   # Associative Arr [wire]="value"
    # connections # Associative Arr [w1,op,w2,w3]="w3"

    # Initialise values in x_wires and y_wires
    local number_of_x_wires number_of_y_wires num
    if [[ -n $debug ]]; then echo "------ Initialising x and y ------"; fi
    binary_string=$(bc <<< "obase=2;$x")
    number_of_x_wires="${#x_wires[@]}"
    while [[ "${#binary_string}" -lt "${number_of_x_wires}" ]]; do
        binary_string="0$binary_string"
    done
    for ((i = 0 ; i < number_of_x_wires ; i++ )); do
        num=$i
        while [[ "${#num}" -lt "2" ]]; do # ${#number_of_x_wires}
            num="0$num"
        done
        wire="x$num"
        val="${binary_string:$((number_of_x_wires-i-1)):1}"
        all_wires["$wire"]="$val"
        if [[ -n $debug ]]; then echo "[$wire] = $val"; fi
    done
    if [[ -n $debug ]]; then echo "x: $x -> $binary_string"; fi
    
    binary_string=$(bc <<< "obase=2;$y")
    number_of_y_wires="${#y_wires[@]}"
    while [[ "${#binary_string}" -lt "${number_of_y_wires}" ]]; do
        binary_string="0$binary_string"
    done
    for ((i = 0 ; i < number_of_y_wires ; i++ )); do
        num=$i
        while [[ "${#num}" -lt "2" ]]; do #${#number_of_y_wires} 
            num="0$num"
        done
        wire="y$num"
        val="${binary_string:$((number_of_y_wires-i-1)):1}"
        all_wires["$wire"]="$val"
        if [[ -n $debug ]]; then echo "[$wire] = $val"; fi
    done
    if [[ -n $debug ]]; then echo "y: $y -> $binary_string"; fi

    # for wire in "${!all_wires[@]}"; do
    #     echo "$wire = ${all_wires[$wire]}"
    # done

    if [[ -n $debug ]]; then echo "------ Calculating z ------"; fi
    local ii=0
    while ! none_unknown z_wires all_wires; do
        ((ii++))
        # echo "Attempt $ii"
        # if [[ "$ii" = "2" ]]; then break; fi
        if [[ "${#connections[@]}" = "0" ]]; then
            echo "No more connections to calculate, but output values are still unknown" >&2
            for wire in "${!z_wires[@]}"; do
                echo "$wire = ${all_wires[$wire]}"
            done
            exit 1
        fi

        for connection in "${!connections[@]}"; do
            IFS="," read -r w1 op w2 w3 <<< "$connection"
            
            if [[ -n $debug ]]; then echo -n "  $connection=$w3"; fi
            
            # check if we know the values of w1 and w2 currently
            v1="${all_wires[$w1]}"
            v2="${all_wires[$w2]}"
            if [[ "$v1" = "" || "$v2" = "" ]]; then
                if [[ -n $debug ]]; then echo $'\033[0;33m'"    Skipping... $connection values unknown <$v1> <$v2> "$'\033[0;0m'; fi
                continue
            fi

            # Caluclate the operation
            v3="${OPERATION_VALUES[$v1,$op,$v2]}"
            if [[ -n $debug ]]; then echo $'\033[0;32m'" --> $v1,$op,$v2=$v3"$'\033[0;0m'; fi
            all_wires["$w3"]="$v3"
            unset "connections[$connection]"
        done
    done
    if [[ -n $debug ]]; then echo "Output Wires Calculated!"; fi
    for wire in "${!z_wires[@]}"; do
        if [[ -n $debug ]]; then echo "$wire = ${all_wires[$wire]}"; fi
    done

    # Read output values to get output number as a binary string
    if [[ -n $debug ]]; then echo "----- Converting z from binary to decimal -----"; fi
    local number_of_z_wires binary_string output
    binary_string=""
    number_of_z_wires="${#z_wires[@]}"
    for ((i = ("$number_of_z_wires"-1) ; i >= 0 ; i-- )); do
        num=$i
        while [[ "${#num}" -lt "2" ]]; do
            num="0$num"
        done
        wire="z$num"
        val="${all_wires[$wire]}"
        if [[ -n $debug ]]; then echo "[$wire] = $val"; fi
        binary_string="$binary_string$val"
    done
    if [[ -n $debug ]]; then echo "Binary String = $binary_string"; fi
    z=$((2#$binary_string))
    if [[ -n $debug ]]; then echo "z: $binary_string -> $z"; fi

    if [[ $(( x & y)) != "$z" ]]; then
        echo $'\033[0;31m'"$x + $y != $z"$'\033[0;0m'
        return 1
    else
        echo $'\033[0;32m'"$x + $y = $z"$'\033[0;0m'
        return 0
    fi

}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    # READ INPUT
    declare -A x_wires=()
    declare -A y_wires=()
    declare -A z_wires=()
    declare -A all_wires=()
    declare -A connections_start=()

    INPUT_WIRE_REGEX="^([xy][0-9]+): ([0-1])$"
    WIRE_CONNECTION_REGEX="^([a-z0-9]+) (XOR|OR|AND) ([a-z0-9]+) -> ([a-z0-9]+)$"
    newLinePassed="false"
    while read -r line; do
        if [[ "$line" = "" ]]; then
            newLinePassed="true"
            continue
        fi
        if [[ "$newLinePassed" = "false" ]]; then
            if [[ "$line" =~ $INPUT_WIRE_REGEX ]]; then
                w1="${BASH_REMATCH[1]}"
                v1="${BASH_REMATCH[2]}"
                # echo "Input wires: $line"
                if [[ "${w1::1}" == "x" ]]; then
                    x_wires["$w1"]="$v1"
                elif [[ "${w1::1}" == "y" ]]; then
                    y_wires["$w1"]="$v1"
                else
                    echo "Something has gone wrong reading the input" >&2
                    exit 1
                fi
                all_wires["$w1"]="$v1"
            else
                echo "Something has gone wrong reading the input" >&2
                exit 1
            fi
        else 
            if [[ "$line" =~ $WIRE_CONNECTION_REGEX ]]; then
                # echo "Wire connections: $line"
                w1="${BASH_REMATCH[1]}"
                operation="${BASH_REMATCH[2]}"
                w2="${BASH_REMATCH[3]}"
                w3="${BASH_REMATCH[4]}"
                
                connections_start["$w1,$operation,$w2,$w3"]="$w3"
                # all_wires["${BASH_REMATCH[2]}"]=""
                if [[ "${w1::1}" == "z" ]]; then
                    z_wires["$w1"]="unknown"
                fi
                if [[ "${w2::1}" == "z" ]]; then
                    z_wires["$w2"]="unknown"
                fi
                if [[ "${w3::1}" == "z" ]]; then
                    z_wires["$w3"]="unknown"
                fi
            else
                echo "Something has gone wrong reading the input" >&2
                exit 1
            fi
        fi
    done < "$1"
    
    # Set connections array
    declare -A connections=()
    for connection in "${!connections_start[@]}"; do
        connections["$connection"]="${connections_start[$connection]}"
    done

    # Used for testing with example_input_3.txt
    # unset "connections[x00,AND,y00,z05]"
    # connections["x00,AND,y00,z00"]="z00"
    # unset "connections[x05,AND,y05,z00]"
    # connections["x05,AND,y05,z05"]="z05"
    # unset "connections[x01,AND,y01,z02]"
    # connections["x01,AND,y01,z01"]="z01"
    # unset "connections[x02,AND,y02,z01]"
    # connections["x02,AND,y02,z02"]="z02"

    # Swap each set of connections until the simulation works
    echo "There are ${#connections[@]} connections in total"
    simulate "10" "12"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# Answer:
# z00 = 0
# z01 = 0
# z02 = 1
# 100 --> 4
# solution_1 example_input.txt
# echo

# Answer:
# bfw: 1
# bqk: 1
# djm: 1
# ffh: 0
# fgs: 1
# frj: 1
# fst: 1
# gnj: 1
# hwm: 1
# kjc: 0
# kpj: 1
# kwq: 0
# mjb: 1
# nrd: 1
# ntg: 0
# pbm: 1
# psh: 1
# qhw: 1
# rvg: 0
# tgd: 0
# tnw: 1
# vdt: 1
# wpb: 0
# z00: 0
# z01: 0
# z02: 0
# z03: 1
# z04: 0
# z05: 1
# z06: 1
# z07: 1
# z08: 1
# z09: 1
# z10: 1
# z11: 0
# z12: 0
# 0011111101000 --> 2024
# solution_1 example_input_2.txt

# solution_1 input.txt

solution_2 example_input_3.txt
# echo
# solution_2 input.txt
