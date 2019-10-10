#!/bin/bash
#######################################################################
#
# Letter Soup Plugin
# By Pablo S.R. NIKLAS <pablo.niklas@gmail.com>
# Under MIT License.
#
#######################################################################
#
# Requirement
#
# https://gitlab.com/simers/soup.git
#
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
declare -a COORDS

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

    local S

    showInfo "Printing SOUP"

    for ((I=0;I<$SIZE;I++)) {
        S=""
        for ((J=0;J<$SIZE;J++)) {
            S="$S ${SOUP[$I,$J]} "
        }
        showInfo "SOUP[`printf '%0.2d' $I`] => $S"
    }
}

### print_solution
function print_solution () {

    local S

    for ((I=0;I<$SIZE;I++)) {
        S=""
        for ((J=0;J<$SIZE;J++)) {
            S="$S ${SOLUTION[$I,$J]} "
        }
        showInfo "SOLUTION[`printf '%0.2d' $I`] => $S"
    }
}

### soup2latex
function soup2latex() {

    local ORIENT
    local A
    local TEX_OUTPUT

    TEX_OUTPUT="soup.tex"

    echo "" > $TEX_OUTPUT
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" >> $TEX_OUTPUT
    echo "% By lettersoup.sh (for AEGS)"  >> $TEX_OUTPUT
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" >> $TEX_OUTPUT
    echo "" >> $TEX_OUTPUT
    echo '\section{Sopa de Letras}' >> $TEX_OUTPUT
    echo '\question[30] Resolver la sopa de letras.' >> $TEX_OUTPUT

    echo "\\begin{Alphabetsoup}[$SIZE][$SIZE]" >> $TEX_OUTPUT

    for ((N=0;N<${#COORDS[@]};N++)) {

        # Parsing fields
        W="`echo ${COORDS[$N]}|cut -d: -f1`"
        X="`echo ${COORDS[$N]}|cut -d: -f2`"
        X=$(($X+1))
        Y="`echo ${COORDS[$N]}|cut -d: -f3`"
        Y=$(($Y+1))
        O="`echo ${COORDS[$N]}|cut -d: -f4`"

        # Orientation
        case $O in
            "H") ORIENT="right" ;;
            "V") ORIENT="down" ;;
            "NE") ORIENT="upright" ;;
            "SO") ORIENT="upleft" ;;
        esac

        # Each letter separated by comma.
        A="${W:0:1}"; for((i=1;i<${#W}-1;i++)); do 
            A="$A,${W:i:1}"
        done
        A="$A,${W: -1}"

        echo "\\hideinsoup*{$Y}{$X}{$ORIENT}" >> $TEX_OUTPUT
        echo "{$A}" >> $TEX_OUTPUT
        #echo "[]" >> $TEX_OUTPUT
        echo ""  >> $TEX_OUTPUT
    }
    
    echo "\\end{Alphabetsoup}"  >> $TEX_OUTPUT

    showOK "Written LaTeX output to: $TEX_OUTPUT"
}

### For DEV: dev_print_detection_matrix
function dev_print_detection_matrix () {

    echo "========================================"
    for ((X=0;X<$SIZE;X++)) {
        for ((Y=0;Y<$SIZE;Y++)) {
            echo -n "${CHOOSEN_CELLS[$X,$Y]} "
        }
        echo ""
    }
}

### coords2file
function coords2file () {

    local CFILE

    CFILE=$1

    for ((N=0;N<${#COORDS[@]};N++)) {
        echo ${COORDS[$N]} >> $CFILE
    }

    showOK "Written to file $CFILE."

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
                    showWarning "WORD $WORD: Colision in ($ROW,$VCOL) (${WORD:$J:1} => ${SOUP[$ROW,$VCOL]}). Relocating."
                    eval "$5=1"
                    return 
                fi
            }
            ;;

        1)  #Vertical
            for ((J=0;J<${#WORD};J++)) {
                VROW=$(($J+$ROW))
                if [ "${CHOOSEN_CELLS[$VROW,$COL]}" == "1" ] && [ "${WORD:$J:1}" != ${SOUP[$VROW,$COL]} ]; then
                    showWarning "WORD $WORD: Colision in ($VROW,$COL) (${WORD:$J:1} => ${SOUP[$VROW,$COL]}). Relocating."
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
                    showWarning "WORD $WORD: Colision in ($VROW,$VCOL) (${WORD:$J:1} => ${SOUP[$VROW,$VCOL]}). Relocating."
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
                    showWarning "WORD $WORD: Colision in ($VROW,$VCOL) (${WORD:$J:1} => ${SOUP[$VROW,$VCOL]}). Relocating."
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

        showInfo "$WORD"

        ORIENTATION=$(($RANDOM%4))
        REVERSE=$(($RANDOM%2))

        # Reversed (or not)
        if [ $REVERSE -eq 1 ]; then 
            WORD=`echo $WORD| rev`
            showInfo "    Reversed"
        fi

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

        # Switch orientation
        case $ORIENTATION in
            0)  #Horizontal
                showInfo "    Orientation: [-] (H) - row: $ROW - col: $COL"

                COORDS+=("$WORD:$ROW:$COL:H")
                
                for ((J=0;J<${#WORD};J++)) {
                    CCOL=$(($J+$COL))
                    SOUP[$ROW,$CCOL]=${WORD:$J:1}
                    SOLUTION[$ROW,$CCOL]=${WORD:$J:1}
                    CHOOSEN_CELLS[$ROW,$CCOL]=1
                }
                ;;

            1)  #Vertical
                showInfo "    Orientation: [|] (V) - row: $ROW - col: $COL"

                COORDS+=("$WORD:$ROW:$COL:V")

                for ((J=0;J<${#WORD};J++)) {
                    CROW=$(($J+$ROW))
                    SOUP[$CROW,$COL]=${WORD:$J:1}
                    SOLUTION[$CROW,$COL]=${WORD:$J:1}
                    CHOOSEN_CELLS[$CROW,$COL]=1
                }   
                ;;

            2)  #Diagonal NE
                showInfo "    Orientation: [/] (NE) - row: $ROW - col: $COL"

                COORDS+=("$WORD:$ROW:$COL:NE")

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
                showInfo "    Orientation: [\] (SO) - row: $ROW - col: $COL"

                COORDS+=("$WORD:$ROW:$COL:SO")

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

lettersoup.sh  -help:           This help.
               -create-soup:    Create the letter soup.
                   -size:             Size (nxn).
                   -words:            List of words, separated by comma (,).
                  [-file <filename>]: Write the solution to a given file.
                  [-print-soup]:      Print the generated soup.

EOF

    exit 0
}

#######################################################
# ENTRY POINT
#######################################################

[ $# -eq 0 ] && showHelp && exit 1

# ARG processing
FLAG_PS=0; FLAG_PT=0; FLAG_LA=0
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

                                "x-file")
                                            shift
                                            FILENAME="$1"
                                            ;;

                                "x-print-soup")
                                            FLAG_PS=1
                                            ;;

                                "x-print-solution")
                                                    FLAG_PT=1
                                                    ;;

                                "x-to-latex")   FLAG_LA=1
                                                ;;
                            esac
                            shift
                        done
                        generate_soup
                        put_words $WORDS
                        [ $FLAG_PS -eq 1 ] && print_soup 
                        [ $FLAG_PT -eq 1 ] && print_solution
                        [ $FLAG_LA -eq 1 ] && soup2latex
                        [ ! -z "$FILENAME" ] && coords2file "$FILENAME"
                        ;;

        "x-help")       showHelp ;;

        *)              showHelp ;;
    esac
    shift
done 

exit 0

