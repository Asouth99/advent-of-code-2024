#!/usr/bin/env bash
check_towels() {
    local towel=$1
    local pattern regex_pattern sub_towel
    # echo "  Checking sub-towel <$towel>"
    if [[ "${impossible_patterns[$towel]}" = "false" ]]; then
        return 1
    fi

    for pattern in "${available_towel_patterns[@]}"; do
        # echo "    Trying pattern $pattern"
        regex_pattern="^$pattern(.*)"
        if [[ "$towel" =~ $regex_pattern ]]; then
            sub_towel="${BASH_REMATCH[1]}"
            # echo "      Pattern $pattern found in $towel. Left with <$sub_towel>"
            if [[ "$sub_towel" = "" ]]; then
                return 0
            else
                if check_towels "$sub_towel"; then
                    return 0
                fi
            fi
        else
            continue
        fi
    done
    impossible_patterns["$towel"]="false"
    return 1
}

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    declare -ga available_towel_patterns
    declare -ga towels_to_make

    # Read input
    i=0
    while read -r line; do
        case "$i" in
            0) IFS=", " read -ra available_towel_patterns <<< "$line" ;;
            1) ;;
            *) towels_to_make+=("$line") ;;
        esac
        ((i++))
    done < $1
    # echo "Available Towel Patterns: ${available_towel_patterns[*]}"
    # echo "Towels to Make: ${towels_to_make[*]}"

    # Recurive check_towels method. Takes too long for input.txt
    num_possible=0
    declare -A impossible_patterns=()
    for ((i = 0 ; i < "${#towels_to_make[*]}" ; i++ )); do
        towel="${towels_to_make[$i]}"

        echo "Checking Towel <$towel>"
        check_towels "$towel"
        possible_to_make=$?

        if [[ "$possible_to_make" = "0" ]]; then
            echo $'\033[0;32m'"  Found pattern for $towel"$'\033[0m'
            ((num_possible++))
        else 
            echo $'\033[0;31m'"  No patterns found"$'\033[0m'
        fi
    done
    answer=$num_possible

    echo "Impossible patterns cache contains ${#impossible_patterns[*]} values"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}


check_towels_2() {
    local towel=$1
    local pattern regex_pattern sub_towel
    local possible="false"
    local num_ways="0"
    # echo "  Checking sub-towel <$towel>"
    if [[ "${impossible_patterns[$towel]}" = "false" ]]; then
        # echo $'\033[0;33m'"  Found $towel in impossible_cache."$'\033[0m'
        return 1
    elif [[ "${possible_patterns[$towel]}" != "" ]]; then
        possible="true"
        num_ways="${possible_patterns[$towel]}"
        num_options=$((num_options + num_ways))
        # echo $'\033[0;33m'"  Found $towel in possible_cache. Has ${num_ways} ways"$'\033[0m'
        return 0
    fi

    for pattern in "${available_towel_patterns[@]}"; do
        # echo "    Trying pattern $pattern on sub-towel <$towel>"
        regex_pattern="^$pattern(.*)"
        if [[ "$towel" =~ $regex_pattern ]]; then
            sub_towel="${BASH_REMATCH[1]}"
            # echo "      Pattern $pattern found in $towel. Left with <$sub_towel>"
            if [[ "$sub_towel" = "" ]]; then
                num_options=$((num_options+1))
                num_ways=$((num_ways+1))
                possible="true"
            else
                if [[ "${possible_patterns[$sub_towel]}" != "" ]]; then
                    # echo $'\033[0;33m'"  Found $sub_towel=${possible_patterns[$sub_towel]} in possible_cache"$'\033[0m'
                    num_ways=$((num_ways + ${possible_patterns[$sub_towel]}))
                    num_options=$((num_options + ${possible_patterns[$sub_towel]}))
                    possible="true"
                elif check_towels_2 "$sub_towel"; then
                    num_ways=$((num_ways+1))
                    possible="true"
                fi
            fi
        else
            continue
        fi
    done

    if [[ $possible = "true" ]]; then
        # echo $'\033[0;33m'"  Writing $towel=$num_ways to possible_patterns cache"$'\033[0m'
        possible_patterns["$towel"]="$num_ways"
        return 0
    fi

    # echo $'\033[0;33m'"  Writing $towel=false to impossible_patterns cache"$'\033[0m'
    impossible_patterns["$towel"]="false"
    return 1
}

solution_2 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    echo
    answer=0

    declare -ga available_towel_patterns
    declare -ga towels_to_make

    # Read input
    i=0
    while read -r line; do
        case "$i" in
            0) IFS=", " read -ra available_towel_patterns <<< "$line" ;;
            1) ;;
            *) towels_to_make+=("$line") ;;
        esac
        ((i++))
    done < $1
    # echo "Available Towel Patterns: ${available_towel_patterns[*]}"
    # echo "Towels to Make: ${towels_to_make[*]}"

    # Recurive check_towels_2 method. Takes too long for input.txt
    declare -A impossible_patterns=()
    declare -A possible_patterns=()
    for ((i = 0 ; i < "${#towels_to_make[*]}" ; i++ )); do
        declare -g num_options="0"
        towel="${towels_to_make[$i]}"

        echo "Checking Towel <$towel>"

        if check_towels_2 "$towel"; then
            echo $'\033[0;32m'"  Found $num_options pattern(s) for $towel"$'\033[0m'
            ((answer+=num_options))
        else 
            echo $'\033[0;31m'"  No patterns found"$'\033[0m'
        fi
    done
    echo
    echo "Impossible patterns cache contains ${#impossible_patterns[*]} values"
    echo "Possible patterns cache contains ${#possible_patterns[*]} values"

    echo
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

# solution_1 example_input.txt
# echo
# solution_1 input.txt # 300 - took 38 seconds

# solution_2 example_input.txt
# echo
solution_2 input.txt # 1182868258 -> too LOW! - took 106 seconds