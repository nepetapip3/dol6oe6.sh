#!/bin/bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

VERSION="1.0"
ANIM="space"

usage() {
cat << EOF
╔══════════════════════════════════════════════════════╗
║           ${RED}dol6oe6 animations v${VERSION}                    ║
║         ${GREEN}simple ASCII animations for your terminal    ║
╚══════════════════════════════════════════════════════╝

USAGE:
  ./space.sh [flag]

ANIMATIONS:
  -space      Parallax star field with shooting stars (default)
  -fire       Burning ASCII fire
  -rain       Rainfall with splashes
  -aurora     Northern lights
  -warp       Warp speed jump through stars

UTILITY:
  -help       Show this help message

EXAMPLES:
  ./dol6oe6.sh
  ./dol6oe6.sh -fire
  ./dol6oe6.sh -aurora
  ./dol6oe6.sh -warp

CONTROLS:
  Ctrl+C      Exit animation

EOF
exit 0
}

case "$1" in
    -help|--help|-h) usage ;;
    -space|"")       ANIM="space" ;;
    -fire)           ANIM="fire" ;;
    -rain)           ANIM="rain" ;;
    -aurora)         ANIM="aurora" ;;
    -warp)           ANIM="warp" ;;
    *)
        echo "Unknown flag: $1"
        echo "Use ./space.sh -help for usage info"
        exit 1
        ;;
esac

tput civis
tput smcup
clear
trap 'tput rmcup; tput cnorm; exit' INT TERM

COLS=$(tput cols)
ROWS=$(tput lines)

# ══════════════════════════════════════════
#  SPACE
# ══════════════════════════════════════════
anim_space() {
    N1=40; N2=25; N3=15; NS=4
    declare -a S1_X S1_Y S2_X S2_Y S3_X S3_Y
    declare -a SH_X SH_Y SH_LEN SH_DIR

    for ((i=0; i<N1; i++)); do S1_X[$i]=$((RANDOM%COLS)); S1_Y[$i]=$((RANDOM%ROWS+1)); done
    for ((i=0; i<N2; i++)); do S2_X[$i]=$((RANDOM%COLS)); S2_Y[$i]=$((RANDOM%ROWS+1)); done
    for ((i=0; i<N3; i++)); do S3_X[$i]=$((RANDOM%COLS)); S3_Y[$i]=$((RANDOM%ROWS+1)); done
    for ((i=0; i<NS; i++)); do
        SH_X[$i]=$((RANDOM%COLS))
        SH_Y[$i]=$((RANDOM%(ROWS/2)+1))
        SH_LEN[$i]=$((RANDOM%6+3))
        SH_DIR[$i]=$((RANDOM%2))
    done

    FRAME=0
    while true; do
        buf="\033[2J"
        for ((i=0; i<N1; i++)); do
            x=${S1_X[$i]}; y=${S1_Y[$i]}
            buf+="\033[${y};${x}H\033[2;34m.\033[0m"
            if (( FRAME % 4 == 0 )); then S1_X[$i]=$(( (x+1)%COLS )); fi
        done
        for ((i=0; i<N2; i++)); do
            x=${S2_X[$i]}; y=${S2_Y[$i]}
            buf+="\033[${y};${x}H\033[0;36m+\033[0m"
            if (( FRAME % 2 == 0 )); then S2_X[$i]=$(( (x+1)%COLS )); fi
        done
        for ((i=0; i<N3; i++)); do
            x=${S3_X[$i]}; y=${S3_Y[$i]}
            buf+="\033[${y};${x}H\033[1;37m*\033[0m"
            S3_X[$i]=$(( (x+1)%COLS ))
        done
        for ((i=0; i<NS; i++)); do
            x=${SH_X[$i]}; y=${SH_Y[$i]}; len=${SH_LEN[$i]}
            for ((j=0; j<len; j++)); do
                tx=$(( x - j ))
                if (( tx >= 1 )); then
                    if   (( j == 0 )); then buf+="\033[${y};${tx}H\033[1;33m*\033[0m"
                    elif (( j <  3 )); then buf+="\033[${y};${tx}H\033[0;33m-\033[0m"
                    else                    buf+="\033[${y};${tx}H\033[2;37m.\033[0m"
                    fi
                fi
            done
            SH_X[$i]=$(( x+2 ))
            if (( SH_DIR[$i]==1 )); then SH_Y[$i]=$(( y+1 )); fi
            if (( SH_X[$i] > COLS+10 || SH_Y[$i] >= ROWS )); then
                SH_X[$i]=$((RANDOM%20+1))
                SH_Y[$i]=$((RANDOM%(ROWS/2)+1))
                SH_LEN[$i]=$((RANDOM%6+3))
                SH_DIR[$i]=$((RANDOM%2))
            fi
        done
        msg="[ space travel ]"
        mx=$(( (COLS-${#msg})/2 ))
        buf+="\033[${ROWS};${mx}H\033[2;35m${msg}\033[0m"
        printf "%b" "$buf"
        FRAME=$((FRAME+1))
        sleep 0.06
    done
}

# ══════════════════════════════════════════
#  FIRE
# ══════════════════════════════════════════
anim_fire() {
    W=$COLS
    H=$ROWS
    SIZE=$(( W * (H+3) ))
    declare -a HEAT
    for ((i=0; i<SIZE; i++)); do HEAT[$i]=0; done

    CHARS=' .,;:!|\*#@'
    NCH=${#CHARS}

    while true; do
        for ((x=0; x<W; x++)); do
            idx=$(( (H+1)*W + x ))
            HEAT[$idx]=$(( RANDOM % 200 + 55 ))
            if (( RANDOM % 3 == 0 )); then HEAT[$idx]=0; fi
        done

        for ((y=0; y<H; y++)); do
            for ((x=0; x<W; x++)); do
                x1=$(( x-1 < 0 ? 0 : x-1 ))
                x2=$(( x+1 >= W ? W-1 : x+1 ))
                i1=$(( (y+1)*W + x1 ))
                i2=$(( (y+1)*W + x ))
                i3=$(( (y+1)*W + x2 ))
                i4=$(( (y+2)*W + x ))
                val=$(( (HEAT[$i1] + HEAT[$i2] + HEAT[$i3] + HEAT[$i4]) / 4 ))
                val=$(( val > 2 ? val - 2 : 0 ))
                HEAT[$((y*W+x))]=$val
            done
        done

        buf="\033[H"
        for ((y=0; y<H; y++)); do
            for ((x=0; x<W; x++)); do
                v=${HEAT[$((y*W+x))]}
                chi=$(( v * NCH / 255 ))
                (( chi >= NCH )) && chi=$(( NCH-1 ))
                ch="${CHARS:$chi:1}"
                if   (( v > 200 )); then buf+="\033[1;37m${ch}\033[0m"
                elif (( v > 150 )); then buf+="\033[1;33m${ch}\033[0m"
                elif (( v > 100 )); then buf+="\033[0;33m${ch}\033[0m"
                elif (( v >  50 )); then buf+="\033[0;31m${ch}\033[0m"
                elif (( v >  10 )); then buf+="\033[2;31m${ch}\033[0m"
                else                     buf+=" "
                fi
            done
            (( y < H-1 )) && buf+="\n"
        done
        msg="[ fire ]"
        mx=$(( (COLS-${#msg})/2 ))
        buf+="\033[${ROWS};${mx}H\033[2;33m${msg}\033[0m"
        printf "%b" "$buf"
        sleep 0.05
    done
}

# ══════════════════════════════════════════
#  RAIN
# ══════════════════════════════════════════
anim_rain() {
    ND=60
    declare -a DX DY DSPD DLEN
    declare -a SP_X SP_T
    NSP=25

    for ((i=0; i<ND; i++)); do
        DX[$i]=$((RANDOM%COLS+1))
        DY[$i]=$((RANDOM%ROWS+1))
        DSPD[$i]=$((RANDOM%3+1))
        DLEN[$i]=$((RANDOM%4+2))
    done
    for ((i=0; i<NSP; i++)); do SP_X[$i]=0; SP_T[$i]=-1; done

    FRAME=0
    while true; do
        buf="\033[2J"
        for ((i=0; i<ND; i++)); do
            x=${DX[$i]}; y=${DY[$i]}; len=${DLEN[$i]}
            for ((j=0; j<len; j++)); do
                ty=$(( y - j ))
                if (( ty >= 1 && ty < ROWS )); then
                    if   (( j == 0 )); then buf+="\033[${ty};${x}H\033[1;36m|\033[0m"
                    elif (( j == 1 )); then buf+="\033[${ty};${x}H\033[0;36m|\033[0m"
                    else                    buf+="\033[${ty};${x}H\033[2;34m'\033[0m"
                    fi
                fi
            done
            DY[$i]=$(( y + DSPD[$i] ))
            if (( DY[$i] >= ROWS )); then
                DY[$i]=1
                DX[$i]=$((RANDOM%COLS+1))
                for ((s=0; s<NSP; s++)); do
                    if (( SP_T[$s] < 0 )); then
                        SP_X[$s]=$x
                        SP_T[$s]=0
                        break
                    fi
                done
            fi
        done
        for ((s=0; s<NSP; s++)); do
            t=${SP_T[$s]}
            if (( t < 0 )); then continue; fi
            sx=${SP_X[$s]}
            ry=$(( ROWS - 1 ))
            case $t in
                0) buf+="\033[${ry};${sx}H\033[0;36m.\033[0m" ;;
                1)
                    lx=$(( sx-1 > 0 ? sx-1 : 1 ))
                    rx=$(( sx+1 <= COLS ? sx+1 : COLS ))
                    buf+="\033[${ry};${lx}H\033[0;36m(\033[0m"
                    buf+="\033[${ry};${rx}H\033[0;36m)\033[0m"
                    ;;
                2)
                    ry2=$(( ROWS - 2 ))
                    lx=$(( sx-2 > 0 ? sx-2 : 1 ))
                    rx=$(( sx+2 <= COLS ? sx+2 : COLS ))
                    if (( ry2 >= 1 )); then
                        buf+="\033[${ry2};${lx}H\033[2;34m(\033[0m"
                        buf+="\033[${ry2};${rx}H\033[2;34m)\033[0m"
                    fi
                    ;;
                3) buf+="\033[${ry};${sx}H \033[0m" ;;
            esac
            SP_T[$s]=$(( t + 1 ))
            if (( SP_T[$s] > 4 )); then SP_T[$s]=-1; fi
        done
        msg="[ rain ]"
        mx=$(( (COLS-${#msg})/2 ))
        buf+="\033[${ROWS};${mx}H\033[2;34m${msg}\033[0m"
        printf "%b" "$buf"
        FRAME=$((FRAME+1))
        sleep 0.05
    done
}

# ══════════════════════════════════════════
#  AURORA
# ══════════════════════════════════════════
anim_aurora() {
    NB=6
    declare -a PH SPD AMP BASE_Y

    for ((i=0; i<NB; i++)); do
        PH[$i]=$((RANDOM%628))
        SPD[$i]=$((RANDOM%4+2))
        AMP[$i]=$((ROWS/7 + RANDOM%(ROWS/7)))
        BASE_Y[$i]=$((ROWS/4 + i*(ROWS/6)))
    done

    NS=60
    declare -a ST_X ST_Y
    for ((i=0; i<NS; i++)); do
        ST_X[$i]=$((RANDOM%COLS+1))
        ST_Y[$i]=$((RANDOM%ROWS+1))
    done

    BAND_COLORS=('\033[2;32m' '\033[0;32m' '\033[1;32m' '\033[0;36m' '\033[1;36m' '\033[0;35m')
    T=0

    while true; do
        buf="\033[2J"
        for ((i=0; i<NS; i++)); do
            buf+="\033[${ST_Y[$i]};${ST_X[$i]}H\033[2;37m.\033[0m"
        done
        for ((b=0; b<NB; b++)); do
            color="${BAND_COLORS[$b]}"
            for ((x=1; x<=COLS; x++)); do
                angle=$(( (x * 5 + PH[$b] + T * SPD[$b]) % 628 ))
                if   (( angle < 157 )); then sv=$(( angle * 100 / 157 ))
                elif (( angle < 314 )); then sv=$(( (314-angle) * 100 / 157 ))
                elif (( angle < 471 )); then sv=$(( -((angle-314) * 100 / 157) ))
                else                        sv=$(( -((628-angle) * 100 / 157) ))
                fi
                y=$(( BASE_Y[$b] + AMP[$b] * sv / 100 ))
                if (( y >= 1 && y < ROWS )); then
                    WCHARS='~-=^~'
                    ch="${WCHARS:$((RANDOM%${#WCHARS})):1}"
                    buf+="\033[${y};${x}H${color}${ch}\033[0m"
                    for ((td=1; td<=2; td++)); do
                        ty=$(( y + td ))
                        if (( ty >= 1 && ty < ROWS )); then
                            buf+="\033[${ty};${x}H\033[2;32m.\033[0m"
                        fi
                    done
                fi
            done
            PH[$b]=$(( (PH[$b] + SPD[$b]) % 628 ))
        done
        msg="[ aurora borealis ]"
        mx=$(( (COLS-${#msg})/2 ))
        buf+="\033[${ROWS};${mx}H\033[2;36m${msg}\033[0m"
        printf "%b" "$buf"
        T=$((T+1))
        sleep 0.07
    done
}

# ══════════════════════════════════════════
#  WARP
# ══════════════════════════════════════════
anim_warp() {
    NW=80
    declare -a WX WY WBRIGHT

    CX=$(( COLS/2 ))
    CY=$(( ROWS/2 ))

    for ((i=0; i<NW; i++)); do
        WX[$i]=$(( RANDOM%COLS+1 - CX ))
        WY[$i]=$(( RANDOM%ROWS+1 - CY ))
        WBRIGHT[$i]=$((RANDOM%3))
        if (( WX[$i]==0 && WY[$i]==0 )); then WX[$i]=1; fi
    done

    FRAME=0
    while true; do
        buf="\033[2J"

        SW=$(( 1 + FRAME/25 ))
        if (( SW > 9 )); then SW=1; FRAME=0; fi

        for ((i=0; i<NW; i++)); do
            vx=${WX[$i]}; vy=${WY[$i]}

            if   (( vx > 0 )); then dvx=$SW
            elif (( vx < 0 )); then dvx=$(( -SW ))
            else dvx=0; fi

            if   (( vy > 0 )); then dvy=$SW
            elif (( vy < 0 )); then dvy=$(( -SW ))
            else dvy=0; fi

            # Хвост
            for ((t=1; t<=SW; t++)); do
                tx=$(( CX + vx - dvx*t ))
                ty=$(( CY + vy - dvy*t ))
                if (( tx>=1 && tx<=COLS && ty>=1 && ty<ROWS )); then
                    buf+="\033[${ty};${tx}H\033[2;34m.\033[0m"
                fi
            done

            WX[$i]=$(( vx + dvx ))
            WY[$i]=$(( vy + dvy ))

            sx=$(( CX + WX[$i] ))
            sy=$(( CY + WY[$i] ))

            if (( sx>=1 && sx<=COLS && sy>=1 && sy<ROWS )); then
                case ${WBRIGHT[$i]} in
                    0) buf+="\033[${sy};${sx}H\033[2;36m*\033[0m" ;;
                    1) buf+="\033[${sy};${sx}H\033[0;37m*\033[0m" ;;
                    2) buf+="\033[${sy};${sx}H\033[1;37m*\033[0m" ;;
                esac
            fi

            if (( sx < 1 || sx > COLS || sy < 1 || sy >= ROWS )); then
                WX[$i]=$(( RANDOM%7 - 3 ))
                WY[$i]=$(( RANDOM%5 - 2 ))
                if (( WX[$i]==0 && WY[$i]==0 )); then WX[$i]=1; fi
                WBRIGHT[$i]=$((RANDOM%3))
            fi
        done

        msg="[ warp drive ]"
        mx=$(( (COLS-${#msg})/2 ))
        buf+="\033[${ROWS};${mx}H\033[2;34m${msg}\033[0m"
        printf "%b" "$buf"
        FRAME=$((FRAME+1))
        sleep 0.04
    done
}

# ══════════════════════════════════════════
#  Запуск
# ══════════════════════════════════════════
case "$ANIM" in
    space)  anim_space ;;
    fire)   anim_fire ;;
    rain)   anim_rain ;;
    aurora) anim_aurora ;;
    warp)   anim_warp ;;
esac
