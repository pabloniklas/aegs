#!/bin/bash
#######################################################################
#
# Letter Soup Plugin
# By Pablo S.R. NIKLAS <pablo.niklas@gmail.com>
# Under MIT License.
#
#######################################################################
#
# ChangeLog: 
#
# 09/10/2019 - PSRN - Initial version.
# 10/10/2019 - PSRN - Argument parsing & help.
#

#######################################################################
# PLUGIN DETAILS
# NAME: Letter Soup
# DESCRIPTION: Create a letter soup, giving a set of words.
# AUTHOR: Pablo Niklas <pablo.niklas@gmail.com>
# VERSION: 0.1
#######################################################################

declare -A SOUP
declare -A SOLUTION
declare -A CHOOSEN_CELLS
declare SIZE

#######################################################################
# Functions area
#######################################################################

LIBPATH=../`dirname $0`/lib

source $LIBPATH/cecho_lib.sh


##################################################################
### myFunctions
##################################################################

### print_soup
function print_soup () {

    for ((I=0;I<$SIZE;I++)) {
        for ((J=0;J<$SIZE;J++)) {
            echo -n "${SOUP[$I,$J]} "
        }
        echo ""
    }
}

### For DEV: dev_print_detection_matrix
function dev_print_detection_matrix {

    echo "========================================"
    for ((X=0;X<$SIZE;X++)) {
        for ((Y=0;Y<$SIZE;Y++)) {
            echo -n "${CHOOSEN_CELLS[$X,$Y]} "
        }
        echo ""
    }
}

### generate_soup
function generate_soup () {

    for ((I=0;I<$SIZE;I++)) {
        for ((J=0;J<$SIZE;J++)) {
            SOUP[$I,$J]=`cat /dev/urandom| tr -dc 'A-Z'|head -c 1`
            SOLUTION[$I,$J]="."
        }
    }
}

### analyze_collision
function analyze_collision () {

    local VCOL
    local VROW

    WORD="$1"
    ORIENTATION=$2
    ROW=$3
    COL=$4

    case $ORIENTATION in
        0)  #Horizontal
            for ((J=0;J<${#WORD};J++)) {
                VCOL=$(($J+$COL))
                if [ "${CHOOSEN_CELLS[$ROW,$VCOL]}" == "1" ] && [ "${WORD:$J:1}" != ${SOUP[$ROW,$VCOL]} ]; then
                    echo "WORD $WORD: Colision in ($ROW,$VCOL) (${WORD:$J:1} => ${SOUP[$ROW,$VCOL]}). Relocating."
                    eval "$5=1"
                    return 
                fi
            }
            ;;

        1)  #Vertical
            for ((J=0;J<${#WORD};J++)) {
                VROW=$(($J+$ROW))
                if [ "${CHOOSEN_CELLS[$VROW,$COL]}" == "1" ] && [ "${WORD:$J:1}" != ${SOUP[$VROW,$COL]} ]; then
                    echo "WORD $WORD: Colision in ($VROW,$COL) (${WORD:$J:1} => ${SOUP[$VROW,$COL]}). Relocating."
                    eval "$5=1"
                    return
                fi
            }

            ;;

        2)  #Diagonal NE (/)
            for ((J=0;J<${#WORD};J++)) {
                VCOL=$(($COL+$J))
                VROW=$(($ROW-$J))

                while [ $VROW -lt 0 ]; do
                        ROW=$(($ROW+1))
                        VROW=$(($ROW-$J))
                        [ $COL -lt $(($SIZE-1)) ] && COL=$(($COL+1))
                done

                if [ "${CHOOSEN_CELLS[$VROW,$VCOL]}" == "1" ] && [ "${WORD:$J:1}" != ${SOUP[$VROW,$VCOL]} ]; then
                    echo "WORD $WORD: Colision in ($VROW,$VCOL) (${WORD:$J:1} => ${SOUP[$VROW,$VCOL]}). Relocating."
                    eval "$5=1"
                    return
                fi
            }
            ;;

        3)  #Diagonal SO (\)
            for ((J=0;J<${#WORD};J++)) {
                VCOL=$(($COL-$J))
                VROW=$(($ROW-$J))

                while [ $VROW -lt 0 ]; do
                        ROW=$(($ROW+1))
                        VROW=$(($ROW-$J))
                        [ $COL -lt $(($SIZE-1)) ] && COL=$(($COL+1))
                done

                if [ "${CHOOSEN_CELLS[$VROW,$VCOL]}" == "1" ] && [ "${WORD:$J:1}" != ${SOUP[$VROW,$VCOL]} ]; then
                    echo "WORD $WORD: Colision in ($VROW,$VCOL) (${WORD:$J:1} => ${SOUP[$VROW,$VCOL]}). Relocating."
                    eval "$5=1"
                    return
                fi
            }
            ;;

    esac

    eval "$5=0"
    return
}

### put_words
function put_words () {

    local WORDS
    local ROW
    local COL
    local CCOL
    local CROW

    WORDS="$1"

    for WORD in ${WORDS//,/ }; do 

        ORIENTATION=$(($RANDOM%4))
        REVERSE=$(($RANDOM%2))

        case $ORIENTATION in
            0)  ROW=$(($RANDOM%$SIZE))
                COL=$(($RANDOM%($SIZE-${#WORD}) ))
                ;;

            1)  COL=$(($RANDOM%$SIZE))
                ROW=$(($RANDOM%($SIZE-${#WORD}) ))
                ;;

            2)  COL=$(($RANDOM%($SIZE-${#WORD}) ))
                ROW=$(( ($RANDOM%($SIZE-${#WORD}))+${#WORD} ))
                ;;

            3)  COL=$(( ($RANDOM%($SIZE-${#WORD}))+${#WORD} ))
                ROW=$(($RANDOM%($SIZE-${#WORD}) ))
                ;;

        esac

        analyze_collision $WORD $ORIENTATION $ROW $COL RETURN_VAR
        while [ $RETURN_VAR -eq 1 ]; do

            ORIENTATION=$(($RANDOM%4))
            REVERSE=$(($RANDOM%2))

            case $ORIENTATION in
                0)  ROW=$(($RANDOM%$SIZE))
                    COL=$(($RANDOM%($SIZE-${#WORD}) ))
                    ;;

                1)  COL=$(($RANDOM%$SIZE))
                    ROW=$(($RANDOM%($SIZE-${#WORD}) ))
                    ;;

                2)  COL=$(($RANDOM%($SIZE-${#WORD}) ))
                    ROW=$(( ($RANDOM%($SIZE-${#WORD}))+${#WORD} ))
                    ;;

                3)  COL=$(( ($RANDOM%($SIZE-${#WORD}))+${#WORD} ))
                    ROW=$(( $RANDOM%($SIZE-${#WORD}) ))
                    ;;
            esac

            analyze_collision $WORD $ORIENTATION $ROW $COL RETURN_VAR
        done

        echo -n "WORD: $WORD - "

        # Reversed or not
        if [ $REVERSE -eq 1 ]; then 
            WORD=`echo $WORD| rev`
            echo -n "(rev) - "
        fi

        # Switch orientation
        case $ORIENTATION in
            0)  #Horizontal

                echo -n "ORIENTATION: [-]  "
                echo -n "ROW: $ROW - "
                echo "COL: $COL"
                for ((J=0;J<${#WORD};J++)) {
                    CCOL=$(($J+$COL))
                    SOUP[$ROW,$CCOL]=${WORD:$J:1}
                    SOLUTION[$ROW,$CCOL]=${WORD:$J:1}
                    CHOOSEN_CELLS[$ROW,$CCOL]=1
                }
                ;;

            1)  #Vertical
                echo -n "ORIENTATION: [|]. - "
                echo -n "ROW: $ROW - "
                echo "COL: $COL"

                for ((J=0;J<${#WORD};J++)) {
                    CROW=$(($J+$ROW))
                    SOUP[$CROW,$COL]=${WORD:$J:1}
                    SOLUTION[$CROW,$COL]=${WORD:$J:1}
                    CHOOSEN_CELLS[$CROW,$COL]=1
                }   
                ;;

            2)  #Diagonal NE
                echo -n "ORIENTATION: [/] (NE). - "
                echo -n "ROW: $ROW - "
                echo "COL: $COL"

                for ((J=0;J<${#WORD};J++)) {
                    CROW=$(($ROW-$J))
                    CCOL=$(($COL+$J))

                    while [ $CROW -lt 0 ]; do
                        ROW=$(($ROW+1))
                        CROW=$(($ROW-$J))
                        COL=$(($COL-1))
                    done

                    SOUP[$CROW,$CCOL]=${WORD:$J:1}
                    SOLUTION[$CROW,$CCOL]=${WORD:$J:1}
                    CHOOSEN_CELLS[$CROW,$CCOL]=1
                }   
                ;;

            3)  #Diagonal SO
                echo -n 'ORIENTATION: [\] (SO). - '
                echo -n "ROW: $ROW - "
                echo "COL: $COL"

                for ((J=0;J<${#WORD};J++)) {
                    CROW=$(($ROW-$J))
                    CCOL=$(($COL-$J))

                    while [ $CROW -lt 0 ]; do
                        ROW=$(($ROW+1))
                        CROW=$(($ROW-$J))
                        COL=$(($COL+1))
                    done

                    SOUP[$CROW,$CCOL]=${WORD:$J:1}
                    SOLUTION[$CROW,$CCOL]=${WORD:$J:1}
                    CHOOSEN_CELLS[$CROW,$CCOL]=1
                }   
                ;;

        esac
    done
}

### showHelp
function showHelp() {

cat <<'EOF'

                  /--                 --\
                  | G P Q Z I Y S J R B |
                  | O A V V N U K U G L |
                  | C U V V X M I I L M |
                  | E P V Z D O M E U Y |
                  | Z Y V E H I T T V B |
                  | D E E C H T P Y H B |
                  | H H D K E F D A F H |
                  | E K T R U W F Z R S |
                  | U O D I S O U P G B |
                  | F D J V F E I Z P N |
                  \--                 --/

     :: Letter Soup Plugin for AEGS :: By pablo.niklas@gmail.com ::

USAGE:
~~~~~~

aegs.sh     -help:             This help.
            -create-soup       Create the letter soup.
                -size: size (nxn)
                -words: list of words, separated by comma (,).

EOF

    exit 0


}

#######################################################
# ENTRY POINT
#######################################################

[ $# -eq 0 ] && showHelp && exit 1

# ARG processing
while [ ! -z "$1" ]; do
    case "x$1" in 
        "x-create-soup")   shift
                        while [ ! -z "$1" ]; do
                            case "x$1" in 
                                "x-size")
                                            shift
                                            SIZE=$1
                                            ;;

                                "x-words")
                                            shift
                                            WORDS="$1"
                                            ;;
                            esac
                            shift
                        done
                        generate_soup
                        put_words $WORDS
                        print_soup 
                        ;;

        "x-help")       showHelp ;;

        *)              showHelp ;;
    esac
    shift
done 

