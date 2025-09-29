#!/usr/bin/env bash

solution_1 () {
    seconds_start=$SECONDS
    echo "Reading file: $1"
    answer=0
    
    read -r number < "$1"


    # Step 1 (format)    : 2333133121414131402 --> 00...111...2...333.44.5555.6666.777.888899
    # Step 2 (rearrange) : 00...111...2...333.44.5555.6666.777.888899 --> 0099811188827773336446555566..............
    # Step 3 (checksum)  : 0099811188827773336446555566.............. --> 0*0 + 1*0 + 2*9 + 3*9... = 1928
    # echo "Input number is: $number"

    # echo "step 1 - formatting <$number>"
    echo "step 1 - formatting <${number::100}>"

    number_formatted=""
    for ((i = 0 ; i < ${#number} ; i++ )); do
        digit="${number:$i:1}"
        string_to_add=""
        if [[ $(("$i" % 2)) -eq "0" ]]; then
            even_id=$(( i/2 ))
            string_to_add=$(for ((j = 0 ; j < digit ; j++ )); do echo -n "$even_id"; done)
        else
            string_to_add=$(for ((j = 0 ; j < digit ; j++ )); do echo -n "."; done)
        fi
        number_formatted="$number_formatted$string_to_add"
    done
    # echo "  Formatted number: $number_formatted"
    if [[ -n $2 ]]; then
        echo "Formatted number: $number_formatted" >> $2
    fi

    # echo "step 2 - rearranging <$number_formatted>"
    echo "step 2 - rearranging <${number_formatted::100}>"
    
    number_rearranged=$number_formatted
    rearranged=false

    # count how many digits there are in the number_formatted
    dot_count=0
    for ((i = 0 ; i < ${#number_rearranged} ; i++ )); do
        if [[ "${number_rearranged:$i:1}" = "." ]]; then
            ((dot_count++))
        fi
    done
    digit_count=$((${#number_rearranged} - dot_count))
    echo "  There are $digit_count digits in " #$number_rearranged"

    # do the rearranging
    # for (( i = ${#number_rearranged}-1 ; i > 0 ; i-- )); do
    #     if [[ "$rearranged" = "true" ]]; then
    #         break
    #     fi
    #     digit="${number_rearranged:$i:1}"
    #     for ((j = 0 ; j < ${#number_rearranged} ; j++ )); do
    #         if [[ "${number_rearranged:$j:1}" = "." ]]; then
    #             if [[ $j -ge $digit_count ]]; then
    #                 rearranged=true
    #                 break 2
    #             fi
    #             # Change the . to the digit
    #             before=${number_rearranged::$j}
    #             after=${number_rearranged:($j+1)}
    #             number_rearranged="$before$digit$after"

    #             # Change the digit to a .
    #             before=${number_rearranged::$i}
    #             after=${number_rearranged:($i+1)}
    #             number_rearranged="$before.$after"

    #             # echo "    Moved $digit at pos $i to pos $j: <$number_rearranged>"
    #             break
    #         fi
    #     done
    # done

    # do the rearranging - second method
    reverse_index=$((${#number_rearranged} - 1))
    for (( i = 0 ; i < ${#number_rearranged} ; i++ )); do
        # echo "i=$i , reverse_index=$reverse_index"
        if [[ $i -gt $reverse_index ]]; then
            break
        fi

        if [[ "${number_rearranged:$i:1}" = "." ]]; then
            # echo "Before: ${number_rearranged::$i} | ${number_rearranged:$reverse_index:1} | After: ${number_rearranged:($i+1)}"
            number_rearranged="${number_rearranged::$i}${number_rearranged:$reverse_index:1}${number_rearranged:($i+1)}"
            ((reverse_index--))
            while [[ ${number_rearranged:$reverse_index:1} = "." ]]; do
                ((reverse_index--))
                if [[ $reverse_index -lt 0 ]]; then
                    break 2
                fi
            done
        fi
    done

    # remove trailing .
    number_rearranged=${number_rearranged::$digit_count}

    # echo "  Rearranged number: $number_rearranged"
    if [[ -n $2 ]]; then
        echo "Rearranged number: $number_rearranged" >> $2
    fi



    echo "step 3 - checksumming <${number_rearranged::100}>"
    # echo "step 3 - checksumming <$number_rearranged>"

    number_checksum=0
    for ((i = 0 ; i < ${#number_rearranged} ; i++ )); do
        digit="${number_rearranged:$i:1}"
        number_checksum=$((number_checksum + digit * i))
    done

    echo "  Checksum number: $number_checksum"  
    if [[ -n $2 ]]; then
        echo "Checksum number: $number_checksum" >> $2
    fi

    answer=$number_checksum
    echo "Answer is: $answer"
    seconds_end=$SECONDS
    seconds_diff=$((seconds_end - seconds_start))
    echo "Answer took $seconds_diff seconds to calculate"
}

checksum () {
    local number=$1
    local checksum=0
    for ((i = 0 ; i < ${#number} ; i++ )); do
        local digit="${number:$i:1}"
        checksum=$((checksum + digit * i))
    done

    echo "$checksum"  
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
# echo
solution_1 input.txt
# solution_1 input.txt output.txt # 90119246415 took 6537 seconds -> incorrect

# checksum $(cat input_rearranged.txt)


# solution_2 example_input.txt
# echo
# solution_2 input.txt 
