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

    m = n

    show_info(f'Creating matrix {n}x{m}')

    val = []

    for x in range(n):
        val.append('.' * m)

    show_ok('Done')

    return val


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

    # The first (and longest) word
    longest, shortest = find_longest_and_shortest_word(words.keys())
    size = len(matrix)

    longest = longest.upper()

    if (len(longest) > size):
        show_error(inspect. currentframe().f_code.co_name +
                  "(): Word size is bigger than the matrix.")
        return (False)

    orientation = random.randint(0, 1)

    if (orientation == 0):
        show_info("Orientation: Horizontal.")
        y = int((size-len(longest))/2)
        x = int(((size-1)/2))
        matrix[x] = longest.center(size, '.')
    else:
        show_info("Orientation: Vertical.")
        y = int((size-1)/2)
        x = int((size-len(longest))/2)

        for i in range(x, x+len(longest)):
            matrix[i] = longest[(i-x):(i-x+1)].center(size, '.')

    print_matrix(matrix)

# TODO: The rest ot the words.
    for w in words:
        w = w.upper()
        if (w != longest):
            show_info(f"Procesando {w}")
        else:
            show_info(f"No se procesa {w}")


# MAIN

logo()
load_file("crossword.txt", words)
m = create_matrix(20)
create_crossword(m, words)
