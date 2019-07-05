# An Exam Generation System

## Introduction

This script creates an exam in PDF format, taken randomly questions classified by type of question (fillin, multiplechoice, towrite and truefalse) and unit of the subject to be evaluated.
All the questions are in a frequency table in order to minimize the posibility of a questions that has been taken a couple of times.

# Installation structure

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
        |
        +-------------- /examples: misc. examples.
```

## Files

*  __aegs__: Main script.
*  __aegs.ini__: INI config file. It will be created if it doesn't exists. 
*  __CQstats.db__: Statistic file. Here are all the questions and it's probability to be taken. It will be created if it doesn't exists, scanning all the questions files and calculating it's probability (that are the same when the file is created).

# Statfile structure

## Format
```
<ID>:<tex file with the question>:<number of free usage>:<probability>:<lower limit>:<upper limit>
```

## Example
```
000000:../towrite/0101.tex:1000000:.007246:.007246:1:72
```
# Field description of the .ini file

*  __TEACHER_NAME__: Name of the teacher.
*  __EXAM_DATE__: Date of the exam.
*  __COURSE_TITLE__: Name of the course.
*  __EXAM_TYPE__: Title of the exam.
*  __UNIVERSITY__: Name of the university.
*  __DEPARTMENT__: Department's name.
*  __LOGO_PATH__: Path of the University Logo.
*  __STATSFILE__: Name of the file who records the statistics of the questions and its frequency.
*  __QUNITS__: Quantity of units in the subject. 
*  __SHUFFLE__: If ```true```, shuffle the options in the multiplechoice questions.
*  __DB_PATH__: Vector of the different questions databases. Classified by type.

# Questions

The questions are in LaTex format. An example is provided for each type.
The filename structure is in the format ```UU99.tex```.

* U: Unit (academic module) that is related to the question.
* 9: Cardinal.

## Example

* 1st question of 1st unit: ```0101.tex```
* 2nd question of 1st unit: ```0102.tex```

# Usage

*  ```help```             Help.
*  ```create-exam```      Create the exam in pdf format, ready to print.
    *  ```-u <1,2,3,4,...>```  units.
    *  ```-i <title>```        override Exam Title.
    *  ```-d <date>```         override Exam Date.
    *  ```-t <db1,db2,..>```   list of db's to be used.
    *  ```-q <n>```            number of questions by db and unit.
*  ```choose-questions``` Choose questions WITHOUT creating the exam.
*  ```pick```             Pick one question. Just to test the random system.
*  ```showdb```           Show some minor statistics of the DB.

## showdb

```
$ aegs -showdb
```

### Example

```bash
$ aegs -showdb
```

## choose-questions

Choose the questions without creating the PDF.

```
aegs -choose-questions -t <type of question> -u <list of units> -q <number of questions>
```

### Example

```
aegs -choose-questions -t fillin -u 3,10 -q 3
```

## create-exam

Creates the exam, the ouput is in PDF format.

```
aegs -create-exam  -t <type of question> -u <list of units> -q <number of questions>
```

### Example

```
aegs -create-exam -t fillin,truefalse,multiplechoice -u 1,2,3,4,5,6 -q 3
```

## pick

```
aegs -pick
```

### Example

```
aegs -pick
```

# License

MIT