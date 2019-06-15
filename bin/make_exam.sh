#!/bin/bash
#######################################################################
#
# Exam questions generator - By Pablo S.R. NIKLAS
# Under MIT License.
#
#######################################################################
#
# ChangeLog: 
#
# 05/06/2019 - PSRN - Initial version.
# 11/06/2019 - PSRN - Migrating to memory model.
# 13/06/2019 - PSRN - First working model.
# 14/06/2019 - PSRN - Removing dependencies from external scripts.
#              PSRN - Config file.
# 15/06/2019 - PSRN - Fix checkdb.
# 

#######################################################################
#######################################################################
# BE CAREFUL BEYOND THIS POINT                                        #
#######################################################################
#######################################################################

shopt -s extglob

# Variables
declare -a LABEL
declare -a TEXFILE
declare -a QCREM
declare -a STATS
declare -a FDA
declare -a LS
declare -a LI

declare -a DBTABLES
declare -a CHOOSEN_QUESTIONS

#######################################################################
# Functions area
#######################################################################

#######################################################################
### Other author's functions
#######################################################################

# The following function prints a text using custom color
# -c or --color define the color for the print. See the array colors for the available options.
# -n or --noline directs the system not to print a new line after the content.
# Last argument is the message to be printed.
# https://bytefreaks.net/gnulinux/bash/cecho-a-function-to-print-using-different-colors-in-bash
cecho () {
 
    declare -A colors;
    colors=(\
        ['black']='\E[0;47m'\
        ['red']='\E[0;31m'\
        ['green']='\E[0;32m'\
        ['yellow']='\E[0;33m'\
        ['blue']='\E[0;34m'\
        ['magenta']='\E[0;35m'\
        ['cyan']='\E[0;36m'\
        ['white']='\E[0;37m'\
    );
 
    local defaultMSG="No message passed.";
    local defaultColor="black";
    local defaultNewLine=true;
 
    while [[ $# -gt 1 ]];
    do
    key="$1";
 
    case $key in
        -c|--color)
            color="$2";
            shift;
        ;;
        -n|--noline)
            newLine=false;
        ;;
        *)
            # unknown option
        ;;
    esac
    shift;
    done
 
    message=${1:-$defaultMSG};   # Defaults to default message.
    color=${color:-$defaultColor};   # Defaults to default color, if not specified.
    newLine=${newLine:-$defaultNewLine};
 
    echo -en "${colors[$color]}";
    echo -en "$message";
    if [ "$newLine" = true ] ; then
        echo;
    fi
    tput sgr0; #  Reset text attributes to normal without clearing screen.
 
    return;
}

##################################################################
### myFunctions
##################################################################

### myRandom () 
function myRandom () {

    MIN=$1
    MAX=$2

    echo $(( RANDOM % ($MAX - $MIN + 1 ) + $MIN ))

}

### showError
function showError {
    cecho -c 'red' ":: `date '+%x - %X'` - ERROR: $@"
}

### showOK
function showOK {
    cecho -c 'green' ":: `date '+%x - %X'` - OK: $@"
}

### showInfo
function showInfo {
    cecho -c 'blue' ":: `date '+%x - %X'` - INFO: $@"
}

### showWarning
function showWarning {
    cecho -c 'yellow' ":: `date '+%x - %X'` - WARNING: $@"
}

### showHeader
function showHeader {

    echo
    showInfo "##########################################################"
    showInfo "                Exam generator. By PN."
    showInfo "##########################################################"
    echo

}

### loadDB
function loadDB {

    showInfo "Loading DB file from disk into memory."

    QFILE=/tmp/$STATSFILE.$$
    grep -v \# $STATSFILE > $QFILE 

    POINTER=0

    while IFS=":" read -r LABEL[$POINTER] TEXFILE[$POINTER] QCREM[$POINTER] \
                        STATS[$POINTER] FDA[$POINTER] LI[$POINTER] LS[$POINTER] ; do
        POINTER=$(($POINTER+1))
    done < $QFILE

    rm -f $QFILE

    # Remove the last (empty) element.
    unset LABEL[$POINTER] TEXFILE[$POINTER] QCREM[$POINTER] \
                        STATS[$POINTER] FDA[$POINTER] LI[$POINTER] LS[$POINTER]; 

    showOK "File loaded OK."

}

### saveDB
function saveDB {

    showInfo "Saving DB from memory to disk..."

    rm -f sedfile

    for ((A=0; A<${#LABEL[@]}; A++)); do
        UPD_LINE="${LABEL[$A]}:${TEXFILE[$A]}:${QCREM[$A]}:${STATS[$A]}:${FDA[$A]}:${LI[$A]}:${LS[$A]}"
        UPD_LINE="`echo $UPD_LINE|sed 's/\./\\\./g;s/\//\\\\\//g;'`"
        #ORD=$(($A+1))
        #echo "s/`printf %.6d $ORD`:.*/$UPD_LINE/" >> sedfile
        echo "s/`printf %.6d $A`:.*/$UPD_LINE/" >> sedfile
    done

    sed -i -f sedfile $STATSFILE
    showOK "Done."
    rm -f sedfile
}


### showDB
function showDB {

    MY_PATH="`dirname $0`"

    cecho -c 'yellow' "+----------------------------------------------------------------+"
    cecho -c 'yellow' "|                        DB STATISTICS                           |"
    cecho -c 'yellow' "+----------------------------------------------------------------+"
    TOTAL=0
    for P in ${DB_PATH[@]}; do
        cecho -c 'yellow' "| TABLE: `printf %-55s $P| tr a-z A-Z` |"
        cecho -c 'yellow' "+----------------------------------------------------------------+"
        for (( U=1 ; U <= $QUNITS ; U++)); do

            QUANT=`ls $MY_PATH/$P/\`printf %.2d $U\`*.tex 2>/dev/null | wc -l`
            TOTAL=$(($TOTAL+$QUANT))

            if [ $(( $U % 5 )) -eq 0 ]; then
                echo "| Un.`printf %.2d $U`: `printf %.2d $QUANT`q |"
            else
                echo -n "| Un.`printf %.2d $U`: `printf %.2d $QUANT`q "
            fi
        done
        echo
        cecho -c 'yellow' "+----------------------------------------------------------------+"
    done
    cecho -c 'yellow' "| TOTAL OF QUESTIONS IN DB: `printf %.3d $TOTAL`                                  |"


    cecho -c 'yellow' "+----------------------------------------------------------------+"
    echo
}

### initStatFile
function initStatFile() {

    if [ ! -f $STATSFILE ]; then

        showWarning "Stats File is being created."

        echo "#######################################" >> $STATSFILE
        echo "# STATSFILE: DO NOT EDIT              #" >> $STATSFILE
        echo "#                                     #" >> $STATSFILE
        echo "# (Unless you know what you're doing) #" >> $STATSFILE
        echo "#######################################" >> $STATSFILE

        REGNUM=0
        for P in ${DB_PATH[@]}; do
            for F in $(find $P -type f|sort); do
                echo `printf %.6d $REGNUM`:$F:1000000 >> $STATSFILE
                REGNUM=$(($REGNUM+1))
            done
        done

        loadDB
        calculateFrecuencies
        saveDB
    else
        loadDB
    fi
}


function updateStats () {

    local QUESTION_ID

    QUESTION_ID=${1//0/}

    if [ -z "$QUESTION_ID" ]; then 
        showWarning "QUESTION_ID is empty."
        showError "Stats NOT updated."
    else
        showInfo "About to update register $QUESTION_ID."

        QCREM[$QUESTION_ID]=$((${QCREM[$QUESTION_ID]}-1))       # One less.

        showOK "Stats updated successfully."
    fi  
}

function pickQ () {

    MY_PATH="`dirname $0`"

    QTB=${#DB_PATH[@]}
    CTB=`myRandom 1 $QTB`
    CUN=`myRandom 1 $QUNITS`
    QQ=`ls $MY_PATH/${DB_PATH[$CTB]}/*.tex 2>/dev/null | wc -l`
    QU=`ls $MY_PATH/${DB_PATH[$CTB]}/\`printf %.2d $CUN\`??.tex 2>/dev/null | wc -l`

    showInfo "Tables in DB: $QTB."
    showInfo "Choosen Table: #$CTB (${DB_PATH[$CTB]})"
    showInfo "Questions in Table #$CTB (${DB_PATH[$CTB]}): $QQ"
    showInfo "Choosen Unit: #$CUN"
    showInfo "Questions in Unit #$CUN: $QU"

    if [ $QU -gt 0 ]; then
        CQ=`myRandom 1 $QU`
        showInfo "Choosen question: $CQ"
    else   
        showError "The Table '${DB_PATH[$CTB]}' with in Unit #$CUN doesn't have any question to choose from."
        exit 2
    fi

    showInfo "Content of question #$CQ of table #$CTB (${DB_PATH[$CTB]}):"
    QFILE="${DB_PATH[$CTB]}/`printf %.2d%.2d $CUN $CQ`.tex"

    cat $QFILE

    echo
    updateStats $CQ
}

# function createAuxLatex () {

#     for T in ${DB_PATH[@]}; do

#         NAME=`basename $T`
#         showInfo "Creating file $NAME.tex"

#         echo "%% Here comes the chosen questions of $NAME table %%" > $NAME.tex

#     done

# }

### createMainLatex
function createMainLatex () {

(cat <<'LATEX1'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exam Template for University of Management and Technology Lahore
% Author: Abu Bakar Siddique
% The folder of this tex should also contains UMTLogo.jpg and exam.cls
%
% Adapted From:
% Exam Template for UMTYMP and Math Department courses
% Using Philip Hirschhorn's exam.cls: http://www-math.mit.edu/~psh/#ExamCls
%
% run pdflatex on a finished exam at least three times to do the grading table on front page.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% SIN RESPUESTAS
\documentclass[a4paper,10pt,oneside,addpoints]{exam}

% CON RESPUESTAS
%\documentclass[a4paper,10pt,oneside,addpoints,answers]{exam}

    \RequirePackage{amssymb, amsfonts, amsmath, latexsym, verbatim, xspace, setspace}
    \RequirePackage{tikz}
    \usetikzlibrary{shapes.geometric,arrows,fit,matrix,positioning,plotmarks}
    \tikzset
    {
        treenode/.style = {circle, draw=black, align=center,
                              minimum size=1cm, anchor=center},
    }
    %\usepackage[none]{hyphenat}

    \usepackage[margin=1in]{geometry}
    \usepackage{multirow}
    \usepackage[utf8]{inputenc}
    \usepackage[T1]{fontenc}
    \usepackage[spanish]{babel}
    
    \usepackage{mdframed}

    \usepackage{lmodern}
    \usepackage{inconsolata}
    \usepackage{wrapfig}
    \usepackage{listings}
    \usepackage[most]{tcolorbox}


    \pointpoints{Punto}{Puntos}
    \hpword{Puntos:}
    \htword{Total}
    \htword{Total:}
    \hsword{Resultado:}
    \hqword{Problema:}

    \vpword{Puntos}
    \vtword{Total}
    \vtword{Total}
    \vsword{Resultado}
    \vqword{Problema}

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            E X A M   I N F O R M A T I O N
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %\newcommand{\courseCode}{EE210}
    \newcommand{\courseTitle}{%%COURSE_TITLE%%}
    \newcommand{\examDate}{%%EXAM_DATE%%}
    \newcommand{\examType}{%%EXAM_TYPE%%}
    \newcommand{\teacher}{%%TEACHER_NAME%%}
    \newcommand{\logoPath}{%%LOGO_PATH%%}
    \newcommand{\university}{%%UNIVERSITY%%}
    \newcommand{\department}{%%DEPARTMENT%%}

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    \newcommand{\rowSpace}{1.2ex}

    \renewcommand{\shorthandsspanish}{}
    %\renewcommand{\familydefault}{\sfdefault}
    %\numberwithin{equation}{section}
    %\renewcommand{\theenumi}{\alph{enumi}}
    %\renewcommand\thesubsection{\alph{subsection}}
    \setlength{\parindent}{0pt}
    \parindent=20pt      % Sangria francesa - http://ocw.um.es/gat/contenidos/ldaniel/ipu_docs/latex/tema4.html

    \newcommand{\tf}[1][{}]{%
    \fillin[#1][0.25in]%
    }

    \checkboxchar{$\Box$}
    \checkedchar{$\blacksquare$}

    \newtcblisting[auto counter]{sexylisting}[2][]{sharp corners,
        fonttitle=\bfseries, colframe=gray, listing only,
        listing options={basicstyle=\ttfamily,language=bash,breaklines=true,keepspaces=true} %,
        %title=Listado \thetcbcounter: #2, #1
        }

    \singlespacing

    \title{\vspace{-7ex} \courseTitle\vspace{-1ex}}
    \author{\An Exam Generation System }
    \date{}

    \begin{document}

    \begin{tabular}{l l}
    \multirow{4}{*}{ \includegraphics[width=.75in]{\logoPath} }& \\
    & {\Large  \textbf{\university}}\\
    &\large \textbf{\department}\\
    &\large \textbf{\examType} - \textbf{\courseTitle}
    \end{tabular}

    %-----------------------------------------------
    %        Header
    %-----------------------------------------------
    \vspace{2em}
    \pagestyle{headandfoot}
    \firstpageheader{}{}{}
    \runningheader{ \textbf{Legajo:\\Apellido y Nombre:}}{}{\includegraphics[scale=.5]{\logoPath}}
    \runningheadrule
    \runningfooter{}{Pág. \thepage\ de \numpages}{}

    \begin{flushright}
    \begin{tabular}{p{1.5in} p{4in}}

    \textbf{Docente/s:}& \teacher \hrule \\ [\rowSpace]
    \textbf{Legajo:}&\hrule \\ [\rowSpace]
    \textbf{Apellido y Nombre:}&\hrule \\ [\rowSpace]
    \textbf{Materia:}& \courseTitle \hrule \\
    \textbf{Fecha:}& \examDate \hrule
    \end{tabular}\\
    \end{flushright}

    \begin{mdframed}[backgroundcolor=gray!20] 
    \small
    \textbf{INSTRUCCIONES/ACLARACIONES}
    \begin{itemize}
    \item \textbf{LEER los enunciados.}
    \item \textbf{El examen se aprueba con el 60\% del Total de Puntos.}
    \item \textbf{Usar birome a azul o negra}. No entregar el examen en lápiz.
    \item \textbf{Escribir la respuesta final} en el espacio provisto. 
    \item En las preguntas \textit{Multiplechoice}, \textbf{deben marcarse todas las respuestas correctas.}
    \item \textbf{Completar los Nombres y Apellido/s} en todas las hojas dadas.
    \end{itemize}
    \end{mdframed}

   %\begin{center}
   %\textbf{Certificate to be filled at the time of exam}
   %\end{center}

   %I have counted all \numpages\ pages in this exam and no page is missing. \hfill \textbf{Student Signature}

    \begin{center}
    \vspace{0pt}
    \cellwidth{1em}
    \gradetablestretch{1}
    \pointpoints{Punto}{Puntos}
    \hpword{Puntos:}
    \htword{Total}
    \htword{Total:}
    \hsword{Resultado:}
    \hqword{Pregunta:}

    \vpword{Puntos}
    \vtword{Total}
    \vtword{Total}
    \vsword{Resultado}
    \vqword{Pregunta}
    \addpoints % required here by exam.cls, even though questions haven't started yet.
    \gradetable[v][questions]%[pages]  % Use [pages] to have grading table by page instead of question

    %\pointtable[h][questions]
    %\end{minipage}
    \end{center}

    %\begin{center}
    %\textbf{Certificate to be filled during paper viewing}
    %\end{center}

    %I have reviewed my paper and all \numquestions\ questions have been marked with\\ no
    % part left unmarked. Counting is also correct. \hfill \textbf{Student Signature}

    %\newpage % End of cover page

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %            Q U E S T I O N S
    %
    % See http://www-math.mit.edu/~psh/#ExamCls for full documentation, but the questions
    % below give an idea of how to write questions [with parts] and have the points
    % tracked automatically on the cover page.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\boxedpoints

\begin{questions}


LATEX1
)  > exam_01_$$.tex

    # Replace values in template. I've splitted the sed sentences for a better readbility.
    LOGO_PATH="`echo $LOGO_PATH|sed 's/\./\\\./g;s/\//\\\\\//g'`"
    sed -i "s/%%TEACHER_NAME%%/$TEACHER_NAME/;s/%%EXAM_DATE%%/$EXAM_DATE/;s/%%COURSE_TITLE%%/$COURSE_TITLE/" exam_01_$$.tex
    sed -i "s/%%EXAM_TYPE%%/$EXAM_TYPE/;s/%%LOGO_PATH%%/$LOGO_PATH/;s/%%UNIVERSITY%%/$UNIVERSITY/" exam_01_$$.tex
    sed -i "s/%%DEPARTMENT%%/$DEPARTMENT/" exam_01_$$.tex

}

function createEndLatex {

(cat <<'LATEX1'

\end{questions}
\end{document}

LATEX1
)  > exam_03_$$.tex

}

### createTemplates
# function createTemplates {

#     showInfo "Creating empty Templates."

#     createMainLatex
#     createAuxLatex

#     showOK "Done."
# }

### createLatex
function createLatex() {

    FILE=$1
    TMP_LOG=/tmp/$RANDOM.latex.log

    # We have to run pdflatex twice to generate the point table.
    showInfo "Creating PDF (compiling $FILE)..."
    pdflatex -synctex=1 -interaction=nonstopmode $FILE > $TMP_LOG 2>&1
    pdflatex -synctex=1 -interaction=nonstopmode $FILE >> $TMP_LOG 2>&1

    if [ ! $? -eq 0 ]; then
         CMD=showWarning 
    else   
         CMD=showOK
    fi

    while IFS= read -r LINE ; do
        $CMD $LINE
    done < $TMP_LOG

    showInfo "Done."

}

### calculateFrecuencies
function calculateFrecuencies()  {

    # Total.
    SUM=0
    for ((A=0; A<${#QCREM[@]}; A++)); do
        SUM=$(($SUM+${QCREM[$A]}))
    done

    # Percentajes
    POINTER=0
    SUM_PORC=0
    showInfo "Calculating frecuencies."

    for ((A=0; A<${#QCREM[@]}; A++)); do
        NUM=${QCREM[$A]}
        [ -z "$NUM" ] && showWarning "En $A NUM es '$NUM'"
        AUX_PORC=`AUX=$(echo $NUM/$SUM|bc -l) ; LC_NUMERIC="en_US.UTF-8" printf "%0.6f\n" $AUX`
        STATS[$A]=`echo $AUX_PORC|bc -l`
        SUM_PORC=`echo $SUM_PORC+$AUX_PORC|bc -l`
    done 

    showInfo "Rounding error: `echo \($SUM_PORC-1\)|bc -l`."
    showInfo "Calculating probability table."

    SUM=0
    LIa=0
    LSa=0
    NUMREG=0

    #showInfo "---------------------------------------------------------------------"
    #showInfo "`printf '%-10s \t %-10s \t %-10s \t %5s \t %5s\n' \"ID\" \"PROB\" \"FDA\" \"LL\" \"UL\"`"
    #showInfo "---------------------------------------------------------------------"

    for(( I=0; I <${#STATS[@]} ; I++)); do

        SUM="`echo $SUM + ${STATS[$I]} | bc -l`"
        NUMREG=$(($NUMREG+1))
        FDA[$I]=$SUM

        LSa=`echo $SUM*10000/1|bc`
        LIa=`echo \($LIa + 1\)/1|bc`
        #showInfo "`printf '%-10s \t %-10s \t %-10s \t %5s \t %5s\n' ${LABEL[$I]} ${STATS[$I]} ${FDA[$I]} $LIa $LSa`"

        # Limits goes here.
        LS[$I]=$LSa
        LI[$I]=$LIa

        LIa=`echo $SUM*10000/1|bc`

    done
    
    #showInfo "---------------------------------------------------------------------"

    #showInfo
    showInfo "Register processed: $NUMREG"

    rm -f $QFILE

    showOK "Frecuencies calculated successfully."

}

function chooseQuestions() {

    TABLES=$1        # Types of questions.
    UNITS=$2        # List of units.
    QQ=$3           # Number of questions.

    #calculateFrecuencies

    declare -a LSC
    declare -a LIC
    declare -a QUESTIONS_POOL
    #declare -a TEMP_QUESTIONS

    local POINTER
    local A
    local U
    local T

    showInfo "Picking $QQ questions per UNIT per TABLE."

    # For each table, we loop.
    for TABLE in ${TABLES//,/ }; do


        # For each unit, we loop.
        for UNIT in ${UNITS//,/ }; do

            LIa=99999999; LSa=0     # Reseting limits.
            UNIT=`printf "%.2d" $UNIT`

            showInfo "------------------------------------------------------------"
            showInfo "Locating all the questions in Unit $UNIT for Table '$TABLE'."
            showInfo "------------------------------------------------------------"

            # Search pool of questions giving UNIT and TABLE.
            POINTER=0; unset QUESTIONS_POOL
            for ((A=0 ; A<${#TEXFILE[@]} ; A++)); do
                U="`echo ${TEXFILE[$A]}|cut -d/ -f3|cut -d. -f1`"
                U=${U:0:2}  # substring
                T="`echo ${TEXFILE[$A]}|cut -d/ -f2`"

                if [[ $U == $UNIT ]] && [[ $T == $TABLE ]]; then
                    QUESTIONS_POOL[$POINTER]=${LABEL[$A]} # Getting the ID.
                    POINTER=$(($POINTER+1))
                fi
            done

            if [ ${#QUESTIONS_POOL[@]} -lt $QQ ]; then
                showWarning "Amount required ($QQ) > available questions (${#QUESTIONS_POOL[@]}) in DB for Unit $UNIT in Table '$TABLE'."
            else
                # Getting the frequencies for the questions.
                showInfo "Locating limits."

                for ((I=0; I<${#QUESTIONS_POOL[@]}; I++)) ; do
                    
                    QC=${QUESTIONS_POOL[$I]}
                    QC=${QC##+(0)}    # Stripping '^0's
                    LSC[$I]=${LS[$QC]}
                    LIC[$I]=${LI[$QC]}
                    [ ${LI[$QC]} -lt $LIa ] && LIa=${LI[$QC]}     # Min
                    [ ${LS[$QC]} -gt $LSa ] && LSa=${LS[$QC]}     # Max
                    
                done

                showInfo "Limits: $LIa -- $LSa"     # <------------ OK

                showInfo "------------------------------------------------------------"

                CUCU=1
                while [ $CUCU -le $QQ ]; do
                    RAND=`myRandom $LIa $LSa`

                    # Locating the random in the correct range for the question.
                    A=0; while [ $A -lt $QQ ]; do
                        [ $RAND -ge ${LIC[$A]} ] && [ $RAND -le ${LSC[$A]} ] && break 
                        A=$(($A+1))
                    done

                    showInfo "Question #${#CHOOSEN_QUESTIONS[@]}, random $RAND, ID: ${QUESTIONS_POOL[$A]}"
                    updateStats ${QUESTIONS_POOL[$A]}

                    # Search
                    P=0; while [ $P -lt ${#CHOOSEN_QUESTIONS[@]} ] && [ "${QUESTIONS_POOL[$A]}" != "${CHOOSEN_QUESTIONS[$P]}" ]; do
                        P=$(($P+1))
                    done

                    # And if not found then added.
                    if [ "${QUESTIONS_POOL[$A]}" != "${CHOOSEN_QUESTIONS[$P]}" ]; then
                        CHOOSEN_QUESTIONS[$P]=${QUESTIONS_POOL[$A]}
                        CUCU=$(($CUCU+1))
                    else
                        showWarning "Question already choosen. Repeating."
                    fi

                done
                
            fi

        done

    done

    calculateFrecuencies

    S="CHOOSEN QUESTIONS ID ==> ${CHOOSEN_QUESTIONS[@]}"
    showInfo "$S"
}

function createMidLatex() {

    if [ ${#CHOOSEN_QUESTIONS[@]} -eq 0 ]; then
        showError "There aren't any question generated yet."
        exit 1
    fi

    showInfo "Creating exam files."

    for T in ${TABLES//,/ }; do

        case "$T" in

            "fillin") SECTION='\section{Completar}';;
            "truefalse") SECTION='\section{Verdadero / Falso}';;
            "towrite") SECTION='\section{A desarrollar}';;
            "multiplechoice") SECTION='\section{Multiplechoice}';;

            *) SECTION=$T;;

        esac

        echo >> exam_02_$$.tex
        echo $SECTION >> exam_02_$$.tex
        echo >> exam_02_$$.tex

        for ((F=0;F<${#CHOOSEN_QUESTIONS[@]};F++)); do

            ID=${CHOOSEN_QUESTIONS[$F]}
            ID=${ID##+(0)}

            FILE=${TEXFILE[$ID]}

            if [[ $T == "`echo $FILE|cut -d/ -f2`" ]]; then
                showInfo "   * $FILE"
                cat $FILE >> exam_02_$$.tex
                echo >> exam_02_$$.tex
            fi 
        done
    done

    showOK "Done."
}

### createINIfile
function checkINIfile {

if [ ! -f `dirname $0`/make_exam.ini ]; then

    showWarning "INI File doesn't exist. Creating."

(cat <<'CONFIG'
####################################################
#                                                  #
#             C O N F I G   F I L E                #
#                                                  #
####################################################

TEACHER_NAME="Pablo Niklas"
EXAM_DATE="January 4th, 1974"
COURSE_TITLE="Geography"
EXAM_TYPE="Elemental test"
UNIVERSITY="University of United Earth"
DEPARTMENT="Department of Advanced Weaponry"
LOGO_PATH="../pictures/shield.png"

STATSFILE="CQstats.db"
QUNITS=1   # Total of units/chapters

# Questions path !! CANNOT CHANGE THE FOLDERS NAME !!
DB_PATH[0]="../towrite"
DB_PATH[1]="../fillin"
DB_PATH[2]="../multiplechoice"
DB_PATH[3]="../truefalse"

CONFIG
) > `dirname $0`/make_exam.ini

fi

source `dirname $0`/make_exam.ini

}

function checkDIRs {

    for P in ${DB_PATH[@]}; do
        if [ ! -d `dirname $0`/$P ]; then
            showWarning "Creating dir $P"
            mkdir `dirname $0`/$P
        fi
    done
}

### showHelp
function showHelp {

cat <<EOF
##########################################################
                Exam generator. By PN.
##########################################################

USAGE:
make_exam.sh -help:             This help.
             -create-exam       Create the latex files, ready to print.
             -choose-questions  Choose questions WITHOUT creating the exam.
             -pick:             Pick one question. Just to test the random system.
             -showdb:           Show some minor statistics of the questions DB.
EOF

    exit 0
}
#######################################################################
#                          MAIN PROCESS                               #
#######################################################################

checkINIfile
checkDIRs

[ $# -eq 0 ] && showHelp && exit 1

for (( I=0; I <${#DB_PATH[@]} ; I++)); do
    DBTABLES[$I]="`echo ${DB_PATH[$I]}|cut -d/ -f2`"
done

# ARG processing
while [ ! -z "$1" ]; do
    case "x$1" in 

        "x-showdb") showHeader
                    showDB 
                    ;;

        "x-pick")   showHeader
                    initStatFile       # Create the stat file if it doesn't exist.
                    pickQ
                    ;;

        "x-create-exam")
                    FLAG=
                    shift
                    while [ ! -z "$1" ]; do
                        case "x$1" in
                            "x-u")  shift
                                    UNITS="$1"
                                    ;;

                            "x-t")  shift
                                    TABLES="$1"
                                    for TABLE in ${TABLES//,/ }; do
                                        if [[ ! " ${DBTABLES[@]} " =~ " ${TABLE} " ]]; then
                                            FLAG=false
                                            showError "The table '$TABLE' is not a valid table."
                                            showError "Available tables are:"
                                            for (( I=0; I <${#DB_PATH[@]} ; I++)); do
                                                showError "  *   ${DBTABLES[$I]} "
                                            done
                                        fi
                                    done
                                    ;;

                            "x-q")  shift
                                    QQ="$1"
                                    ;;

                        esac 
                        shift
                    done
                    if [ -z "$TABLES" ]; then
                        showError "Parameter table (-t) is needed."
                        FLAG=false
                    fi
                    if [ -z "$UNITS" ]; then
                        showError "Parameter unit (-u) is needed."
                        FLAG=false
                    fi
                    if [ -z "$QQ" ]; then
                        showError "Parameter quantity of questions (-q) is needed."
                        FLAG=false
                    fi
                    if [ $FLAG ]; then
                        showHelp
                    else
                        showHeader
                        initStatFile       # Create the stat file if it doesn't exist.
                        chooseQuestions $TABLES $UNITS $QQ
                        saveDB
                        createMainLatex
                        createMidLatex
                        createEndLatex
                        cat exam_*_$$.tex > exam_$$.tex
                        createLatex exam_$$.tex
                        mv exam_$$.tex exam_`date '+%F-%R:%S'`.tex.bkp
                        rm -f exam*.tex exam*.aux exam*.log exam*.synctex.gz *.listing
                    fi
                    ;;                    

        "x-choose-questions")
                    FLAG=
                    shift
                    while [ ! -z "$1" ]; do
                        case "x$1" in
                            "x-u")  shift
                                    UNITS="$1"
                                    ;;

                            "x-t")  shift
                                    TABLES="$1"
                                    for TABLE in ${TABLES//,/ }; do
                                        if [[ ! " ${DBTABLES[@]} " =~ " ${TABLE} " ]]; then
                                            FLAG=false
                                            showError "The table '$TABLE' is not a valid table."
                                            showError "Available tables are:"
                                            for (( I=0; I <${#DB_PATH[@]} ; I++)); do
                                                showError "  *   ${DBTABLES[$I]} "
                                            done
                                        fi
                                    done
                                    ;;

                            "x-q")  shift
                                    QQ="$1"
                                    ;;

                        esac 
                        shift
                    done
                    if [ -z "$TABLES" ]; then
                        showError "Parameter table (-t) is needed."
                        FLAG=false
                    fi
                    if [ -z "$UNITS" ]; then
                        showError "Parameter unit (-u) is needed."
                        FLAG=false
                    fi
                    if [ -z "$QQ" ]; then
                        showError "Parameter quantity of questions (-q) is needed."
                        FLAG=false
                    fi
                    if [ $FLAG ]; then
                        showHelp
                    else
                        showHeader
                        initStatFile       # Create the stat file if it doesn't exist.
                        chooseQuestions $TABLES $UNITS $QQ
                        saveDB
                        showInfo "# Generated questions: ${#CHOOSEN_QUESTIONS[@]} "
                    fi
                    ;;                    

        "x-help")   showHelp ;;

        *)          showHelp ;;
    esac

    shift
done 



exit 0