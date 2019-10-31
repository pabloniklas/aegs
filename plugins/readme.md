# Plugins directory


## Lettersoup

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

### Introduction

This plugin creates a letter soup for the AEGS. It supports different arguments.

### Usage

```
lettersoup.sh  -help:           This help.
               -create-soup:    Create the letter soup.
                 -size:                  Size (nxn).
                 -words:                 List of words, separated by comma (,).
                [-to-latex <filename>]:  Output in latex format.
                [-file <filename>]:      Write the solution to a given file.
                [-print-soup]:           Print the generated soup.
```

### Example

```
./lettersoup.sh -create-soup -size 15 -words WORD1,WORD2,WORD3,...WORDN -print-soup -print-solution
```

## Crossword

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

### Important
This plugin is not a fully functional working version.... yet :o)

### Introduction

This plugin creates a basic crossword using the largest word as the word to be "crossed" and the rest crossing it. It has meant to be used for the AEGS.

