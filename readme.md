# An Exam Generation System

## Introduction

This script creates an exam in PDF format, taken randomly questions classified by type of question (fillin, multiplechoice, towrite and truefalse) and unit of the subject to be evaluated.
All the questions are in a frequency table in order to minimize the posibility of a questions that has been taken a couple of times.

## Installation structure

```

<installation path> --- /bin: Main and binary files.
        |
        +-------------- /fillin: fillin questions.
        |
        +-------------- /multiplechoice: multiplechoice questions.
        |
        +-------------- /towrite: writing questions.
        |
        +-------------- /truefalse: truefalse questions.
```

## Files

*  __make_exam.sh__: Main binary.
*  __make_exam.ini__: INI config file. It will be created if it doesn't exists. 
*  __CQstats.db__: Statistic file. Here lies all the questions and it's probability to be taken. 

## Statfile structure

### Format
```
<ID>:<tex file with the question>:<number of free usage>:<probability>:<lower limit>:<upper limit>
```

### Example
```
000000:../towrite/0101.tex:1000000:.007246:.007246:1:72
```

## Usage

*  ```help```             Help.
*  ```create-exam```       Create the latex files, ready to print.
*  ```choose-questions```  Choose questions WITHOUT creating the exam.
*  ```pick```             Pick one question. Just to test the random system.
*  ```showdb```           Show some minor statistics of the DB.

### showdb

```
$ make_exam.sh -showdb
```

#### Example

```bash
$ make_exam.sh -showdb
```

### choose-questions

Choose the questions without creating the PDF.

```
make_exam.sh -choose-questions -t <type of question> -u <list of units> -q <number of questions>
```

#### Example

```
make_exam.sh -choose-questions -t fillin -u 3,10 -q 3
```

### create-exam

Creates the exam, the ouput is in PDF format.

```
make_exam.sh -create-exam  -t <type of question> -u <list of units> -q <number of questions>
```

#### Example

```
make_exam.sh -create-exam -t fillin,truefalse,multiplechoice -u 1,2,3,4,5,6 -q 3
```

### pick

```
make_exam.sh -pick
```

#### Example

```
make_exam.sh -pick
```