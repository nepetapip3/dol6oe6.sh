#!/bin/bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

tput civis
tput smcup
clear

trap 'tput rmcup; tput cnorm; exit' INT TERM

COLS=$(tput cols)
ROWS=$(tput lines)

N1=40
N2=25
N3=15
NS=4

declare -a S1_X S1_Y S2_X S2_Y S3_X S3_Y
declare -a SH_X SH_Y SH_LEN SH_DIR

for ((i=0; i<N1; i++)); do
    S1_X[$i]=$((RANDOM % COLS))
    S1_Y[$i]=$((RANDOM % ROWS + 1))
done

for ((i=0; i<N2; i++)); do
    S2_X[$i]=$((RANDOM % COLS))
    S2_Y[$i]=$((RANDOM % ROWS + 1))
done

for ((i=0; i<N3; i++)); do
    S3_X[$i]=$((RANDOM % COLS))
    S3_Y[$i]=$((RANDOM % ROWS + 1))
done

for ((i=0; i<NS; i++)); do
    SH_X[$i]=$((RANDOM % COLS))
    SH_Y[$i]=$((RANDOM % (ROWS/2) + 1))
    SH_LEN[$i]=$((RANDOM % 6 + 3))
    SH_DIR[$i]=$((RANDOM % 2))
done

FRAME=0

while true; do
    buf=""
    buf+="\033[2J"

    # Слой 1: дальние звёзды
    for ((i=0; i<N1; i++)); do
        x=${S1_X[$i]}
        y=${S1_Y[$i]}
        buf+="\033[${y};${x}H\033[2;34m.\033[0m"
        if (( FRAME % 4 == 0 )); then
            S1_X[$i]=$(( (x + 1) % COLS ))
        fi
    done

    # Слой 2: средние звёзды
    for ((i=0; i<N2; i++)); do
        x=${S2_X[$i]}
        y=${S2_Y[$i]}
        buf+="\033[${y};${x}H\033[0;36m+\033[0m"
        if (( FRAME % 2 == 0 )); then
            S2_X[$i]=$(( (x + 1) % COLS ))
        fi
    done

    # Слой 3: ближние звёзды
    for ((i=0; i<N3; i++)); do
        x=${S3_X[$i]}
        y=${S3_Y[$i]}
        buf+="\033[${y};${x}H\033[1;37m*\033[0m"
        S3_X[$i]=$(( (x + 1) % COLS ))
    done

    # Метеориты
    for ((i=0; i<NS; i++)); do
        x=${SH_X[$i]}
        y=${SH_Y[$i]}
        len=${SH_LEN[$i]}

        for ((j=0; j<len; j++)); do
            tx=$(( x - j ))
            if (( tx >= 1 )); then
                if (( j == 0 )); then
                    buf+="\033[${y};${tx}H\033[1;33m*\033[0m"
                elif (( j < 3 )); then
                    buf+="\033[${y};${tx}H\033[0;33m-\033[0m"
                else
                    buf+="\033[${y};${tx}H\033[2;37m.\033[0m"
                fi
            fi
        done

        SH_X[$i]=$(( x + 2 ))
        if (( SH_DIR[$i] == 1 )); then
            SH_Y[$i]=$(( y + 1 ))
        fi

        if (( SH_X[$i] > COLS + 10 || SH_Y[$i] >= ROWS )); then
            SH_X[$i]=$((RANDOM % 20 + 1))
            SH_Y[$i]=$((RANDOM % (ROWS/2) + 1))
            SH_LEN[$i]=$((RANDOM % 6 + 3))
            SH_DIR[$i]=$((RANDOM % 2))
        fi
    done

    msg="[ space travel ]"
    mx=$(( (COLS - ${#msg}) / 2 ))
    buf+="\033[${ROWS};${mx}H\033[2;35m${msg}\033[0m"

    printf "%b" "$buf"
    FRAME=$((FRAME + 1))
    sleep 0.06
done
