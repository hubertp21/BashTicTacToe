#!/bin/bash

game=('-' '-' '-' '-' '-' '-' '-' '-' '-')

run() {
    local missed_character_counter=0
    while [ 1 ]; do
        echo "Welcome to tic tac toe game, Choose your side or load game: 'x', 'o' or 'l':"
        read -r option
        if [[ $option != 'x' && $option != 'o' && $option != 'l' ]]; then
            echo "Enter side again or load the game. Choose 'x', 'o' or 'l'"
            (( missed_character_counter++ ))
        elif [[ $option == 'l' ]]; then
            input=$(head -c 18 saved_game.txt)
            game=($(echo -n ${input%?}))
            if [ ${#game[@]} -lt 9 ]; then
                echo "The file does not contain enough characters."
                exit 1
            fi
            option=${input:17:1}
            play "$option"
        else
            missed_character_counter=0
            play "$option"
        fi
        if (( missed_character_counter > 3 )); then
            echo "You picked the wrong side 3 times... Go away"
            exit 1
        fi
    done
}

play() {
    local symbol="$1"
    print_board
    echo "Choose place where to strike! Or if you want to save the game type: 's'. Player: '$symbol' turn:"
    read -r option
    if [[ "$option" == 's' ]]; then
        echo "${game[@]}${symbol}" > saved_game.txt
        echo "Game array and symbol saved to saved_game.txt"
        exit
    fi
    local field_number=$option
    if [[ "$field_number" -gt 9 || "$field_number" -lt 1 ]]; then
        echo "Wrong field number: '$field_number', choose number from 1 to 9 :)"
        play "$symbol"
    fi
    if field_is_already_occupied "$field_number"; then
        echo "Strike again! The field is already occupied :("
        play "$symbol"
    else
        game[$((field_number - 1))]="$symbol"
        if game_ended; then
            echo "Game ended!"
            print_board
            reset_board
            return
        fi
    fi
    if [ "$symbol" == 'x' ]; then
        play 'o'
    else
        play 'x'
    fi
}

print_board() {
    echo "# # #"
    for i in "${!game[@]}"; do
        if (( i == 2 || i == 5 || i == 8 )); then
            echo "${game[$i]}"
        else
            echo -n "${game[$i]} "
        fi
    done
    echo "# # #"
}

reset_board() {
    for i in "${!game[@]}"; do
        game[$i]='-'
    done
}

field_is_already_occupied() {
    local field_number=$1
    if [[ ${game[$((field_number - 1))]} == 'o' || ${game[$((field_number - 1))]} == 'x' ]]; then
        return 0
    else
        return 1
    fi
}

game_ended() {
    if check_rows; then
        return 0
    elif check_columns; then
        return 0
    elif check_diagonals; then
        return 0
    elif check_draw; then
        return 0
    fi
    return 1
}

check_rows() {
    if [[ ${game[0]} != '-' && ${game[0]} == ${game[1]} && ${game[1]} == ${game[2]} ]]; then
        return 0
    elif [[ ${game[3]} != '-' && ${game[3]} == ${game[4]} && ${game[4]} == ${game[5]} ]]; then
        return 0
    elif [[ ${game[6]} != '-' && ${game[6]} == ${game[7]} && ${game[7]} == ${game[8]} ]]; then
        return 0
    fi
    return 1
}

check_columns() {
    if [[ ${game[0]} != '-' && ${game[0]} == ${game[3]} && ${game[3]} == ${game[6]} ]]; then
        return 0
    elif [[ ${game[1]} != '-' && ${game[1]} == ${game[4]} && ${game[4]} == ${game[7]} ]]; then
        return 0
    elif [[ ${game[2]} != '-' && ${game[2]} == ${game[5]} && ${game[5]} == ${game[8]} ]]; then
        return 0
    fi
    return 1
}

check_diagonals() {
    if [[ ${game[0]} != '-' && ${game[0]} == ${game[4]} && ${game[4]} == ${game[8]} ]]; then
        return 0
    elif [[ ${game[2]} != '-' && ${game[2]} == ${game[4]} && ${game[4]} == ${game[6]} ]]; then
        return 0
    fi
    return 1
}

check_draw() {
    for cell in "${game[@]}"; do
        if [[ "$cell" == '-' ]]; then
            return 1
        fi
    done
    return 0
}

run
