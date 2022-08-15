#!/bin/bash
FN=$1

##  Output directories
OUT1=~/tmp/1
OUT2=~/tmp/2

##  Sample execution of fragsort to demonstrate options.

printf "%s\n" "------------------------------"
date
printf "%s\n" "------------------------------"

printf "\n"
if [ -e ../data/$FN.fastq ]; then
  ls -al ../data/$FN.fastq
else 
  printf "Error:  File does not exists\n"
  exit
fi 
printf "\n\n"

printf "%s\n" "------------------------------"
printf "%s\n" "Creating output directories"
printf "%s\n" "------------------------------"
if [ ! -e $OUT1 ]; then
  mkdir $OUT1
fi
if [ ! -e $OUT2 ]; then
  mkdir $OUT2
fi

printf "%s\n" "------------------------------"
printf "%s\n" "Executing collect-stats.pl"
printf "%s\n" "------------------------------"
cat ../data/$FN.fastq | ./collect-stats.pl
printf "\n\n"

printf "%s\n" "------------------------------"
printf "%s\n" "Executing run-fragsort.pl"
printf "%s\n" "------------------------------"
./run-fragsort.pl --file $FN --jobid 1 --quicksort --outdir $OUT1
printf "\n\n"

printf "%s\n" "------------------------------"
printf "%s\n" "Executing run-fragsort-index.pl"
printf "%s\n" "------------------------------"
./run-fragsort-index.pl --file $FN --jobid 2 --quicksort --outdir $OUT2
printf "\n\n"

printf "%s\n" "------------------------------"
date
printf "%s\n" "------------------------------"

