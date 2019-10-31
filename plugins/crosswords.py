#!/usr/bin/env python3
# encoding; utf-8
#######################################################################
#
# CrossWord Plugin
# By Pablo S.R. NIKLAS <pablo.niklas@gmail.com>
# Under MIT License.
#
#######################################################################
#
# Requirements:
# ~~~~~~~~~~~~
#
#    python3-termcolor
#
# ChangeLog:
# ~~~~~~~~~
#
# 14/10/2019 - PSRN - Initial version.
# 31/10/2019 - PSRN - First working version.
#
#######################################################################
# PLUGIN DETAILS
# NAME: Cross Word
# DESCRIPTION: Create a CrossWord, giving a set of words and definitions.
# AUTHOR: Pablo Niklas <pablo.niklas@gmail.com>
# VERSION: 0.1
#######################################################################

import sys
import os
import datetime
import inspect
from termcolor import colored, cprint

import locale
locale.setlocale(locale.LC_ALL, '')

# Dictionary
words = {}

#######################################################################
# Functions area
#######################################################################


def timelog():
    x = datetime.datetime.today()
    return x.strftime("%d/%m/%Y - %X")


def show_info(msg):
    msg = timelog() + " [i] " + msg
    cprint(msg, 'blue')


def show_warning(msg):
    msg = timelog() + " [!] " + msg
    cprint(msg, 'yellow')


def show_ok(msg):
    msg = timelog() + " [+] " + msg
    cprint(msg, 'green')


def show_error(msg):
    msg = timelog() + " [e] " + msg
    cprint(msg, 'red')

# logo


def logo():
    print('''
                        +---+
                        | W |
                        +---+
                        | O |
                    +---+---+---+---+---+
                    | C | R | O | S | S |
                    +---+---+---+---+---+
                        | D |
                        +---+

    :: CrossWord Plugin :: By Pablo Niklas <pablo.niklas@gmail.com>
    ''')


def load_file(file, words):
    import csv

    show_info("Loading definitions from '" + file + "'.")

    with open(file) as csvfile:
        readCSV = csv.reader(csvfile, delimiter=';')
        for row in readCSV:
            definition = row[1]
            keyword = row[0]
            words[keyword] = definition

            show_info("   '"+keyword+"' => "+definition)

    show_ok("Done.")


def find_longest_and_shortest_word(list_of_words):
    longest_word = next(iter(words.keys()))
    shortest_word = longest_word
    for word in list_of_words:
        if len(longest_word) < len(word):
            longest_word = word
        if len(shortest_word) > len(word):
            shortest_word = word

    show_info(f'The longest word is: {longest_word}')
    show_info(f'The shortest word is: {shortest_word}')

    return longest_word, shortest_word

# create matrix


def create_matrix(n):

    m = n   # squared

    show_info(f'Creating matrix {n}x{m}')
    
    Matrix = [[0 for x in range(m)] for y in range(n)]

    for x in range(m):
        for y in range(n):
            Matrix[x][y]="."

    show_ok('Done')

    return Matrix


def print_matrix(matrix):

    print("8<-----8<------8<------8<------8<------8<------8<------8<------8<------8<------")

    for x in matrix:
        print(' '.join([str(elem) for elem in x]))

    print("8<-----8<------8<------8<------8<------8<------8<------8<------8<------8<------")


# letter_frecuency
def letter_frecuency(test_str):

    all_freq = {}

    for i in test_str:
        if i in all_freq:
            all_freq[i] += 1
        else:
            all_freq[i] = 1

    # printing result
    show_info("Count of all characters in "+test_str+" is: " + str(all_freq))


def create_crossword(matrix, words):
    import random
    from collections import Counter


    choosen_randoms = []

    # The first (and longest) word
    longest, shortest = find_longest_and_shortest_word(words.keys())
    size = len(matrix)

    longest = longest.upper()

    if (len(longest) > size):
        show_error(inspect. currentframe().f_code.co_name +
                  "(): Word size is bigger than the matrix.")
        return (False)

    orientation = random.randint(0, 1)
    longest_orientation=orientation

    # Longest word first
    if (orientation == 0):
        show_info("Orientation: Horizontal.")
        y = int((size-len(longest))/2)
        x = int(((size-1)/2))
        for m in range(0,len(matrix[0])):
            aux = longest.center(size, '.')[m:m+1]
            matrix[x][m] = aux
            if aux != '.':
                choosen_randoms.append((x,m))
                
    else:
        show_info("Orientation: Vertical.")
        y = int((size-1)/2)
        x = int((size-len(longest))/2)

        for i in range(x, x+len(longest)):
            for m in range(0,len(matrix[0])):
                aux = longest[(i-x):(i-x+1)].center(size, '.')[m:m+1]
                matrix[i][m] = aux
                if aux != '.':
                    choosen_randoms.append((i,m))

    # The rest of the words
    for w in words:
        w = w.upper()
        if (w != longest):
            show_info(f"{w}: Processing...")

            # Do we have anything in common?
            # https://stackoverflow.com/questions/44269409/count-common-characters-in-strings-python
            s1 = longest
            s2 = w

            common_letters = Counter(s1) & Counter(s2)
            letters = sorted(common_letters.elements())
            if (sum(common_letters.values())) == 0:
                show_warning(f"{w}: No letters in common.")
            else:
                show_info(f"{w}: Letters in common: {letters}")
                orientation = 0 if (longest_orientation==0) else 1
                letter=letters.pop(random.randint(0,len(letters)-1)) 
                show_info(f"{w}: Choosen intersection: {letter}")

                # Position of letter
                show_info(f"{w}: Searching {letter} in {s1}")
                posL = s1.find(letter)
                if posL<0: show_error(f"{w}: Letter not found.")
                show_info(f"Searching {letter} in {s2}")
                posW = s2.find(letter)
                if posW<0: show_error(f"{w}: Letter not found.")

                # Horizontal, then vertical
                if (orientation == 0):
                    show_info(f"{w}: Orientation (|)")
                    Xi = x-posW
                    Yi = y+posL
                    show_info(f"{w}: Choosen column: {posL}")
                    for n in range(Xi,Xi+len(s2)):
                        c = n-Xi
                        p = x-posW+c
                        if next((x for x,y in choosen_randoms if x==p and y==Yi), 0)==0:
                            matrix[p][Yi]=s2[c:c+1]
                            choosen_randoms.append((p,Yi))
                            show_ok(f"{w}: Coors accepted: ({p},{Yi})")
                        else:
                            show_warning(f"{w}: Coors rejected: ({p},{Yi})")
                else:
                    show_info(f"{w}: Orientation (-)")
                    Xi = x+posL-1
                    Yi = y-posW
#                    show_info(f"Initial coors: Xi={Xi} (x={x}, posW={posW}), Yi={Yi} (y={y}, posL={posL})")
                    show_info(f"{w}: Choosen row: {posW}")
                    X = Xi+1
                    for n in range(Yi,Yi+len(s2)):
                        Y = n
                        if next((x for x,y in choosen_randoms if x==X and y==Y), 0)==0:
                            c=n-Yi
                            matrix[X][Y]=s2[c:c+1]
                            choosen_randoms.append((X,Y))
                            show_ok(f"{w}: Coors accepted: ({X},{Y})")
                        else:
                            show_warning(f"{w}: Coors rejected: ({X},{Y})")
                    
                            

        else:
            show_info(f"{w}: It won't be processed. It's the longest word.")

    print_matrix(matrix)

# MAIN

logo()
load_file("crossword.txt", words)
m = create_matrix(20)
create_crossword(m, words)
