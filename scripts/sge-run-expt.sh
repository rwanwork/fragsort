#!/bin/bash
export LANG=C;

##============================================================================
##  Handle arguments
if [ $# -eq 0 ]; then
  printf "Command:  $0 <filename> <method>\n" >&2
  printf "\t<filename>     Filename without the .fastq suffix.\n" >&2
  printf "\t<methods>      Choose from radixsort, quicksort, or random.\n" >&2
  exit 1
elif (( $# < 1 )); then
  printf "%b" "Error:  Not enough arguments -- 1 to 3 are required.\n" >&2
  exit 2
elif (( $# > 3 )); then
  printf "%b" "Error:  Too many arguments -- 1 to 3 are required.\n" >&2
  exit 3
fi

FILENAME_ARG=$1
METHOD_ARG=$2

if [ $METHOD_ARG = "radixsort" ]; then
  METHOD_STR="--radixsort"
elif [ $METHOD_ARG = "quicksort" ]; then
  METHOD_STR="--quicksort"
elif [ $METHOD_ARG = "random" ]; then
  METHOD_STR="--random"
else
  printf "%b" "Error:  Unknown value for method [radixsort, quicksort, or random only].\n" >&2
  exit 1
fi

############################################################
##  Set up global variables

HOST=`hostname -s`
printf "Hostname:        %s\n" $HOST
printf "Job ID:          %s\n" $JOB_ID
printf "Job name:        %s\n" $JOB_NAME
printf "Work directory:  %s\n\n" $WORK

printf "Arguments\n"
printf "  Input file:       %s\n" $FILENAME_ARG
printf "  Method:           %s\n" $METHOD_ARG

SRC="/export3/mp01/grpC/rwan/seqsort"

############################################################
##  Determine the WORK directory based on the hostname

WORK="/data/rwan/"

# if [ $HOST = "c001" ]; then
#   WORK="/export4/data01/rwan/"
# elif [ $HOST = "c002" ]; then
#   WORK="/export4/data02/rwan/"
# elif [ $HOST = "c003" ]; then
#   WORK="/export4/data03/rwan/"
# elif [ $HOST = "c004" ]; then
#   WORK="/export4/data04/rwan/"
# elif [ $HOST = "c005" ]; then
#   WORK="/export4/data05/rwan/"
# elif [ $HOST = "c006" ]; then
#   WORK="/export3/mp06/grpC/rwan/"
# #   WORK="/export4/data06/rwan/"
# elif [ $HOST = "c007" ]; then
#   WORK="/export4/data07/rwan/"
# elif [ $HOST = "c008" ]; then
#   WORK="/export4/data08/rwan/"
# elif [ $HOST = "c009" ]; then
#   WORK="/export4/data09/rwan/"
# elif [ $HOST = "c010" ]; then
#   WORK="/export4/data10/rwan/"
# elif [ $HOST = "c011" ]; then
#   WORK="/export4/data11/rwan/"
# elif [ $HOST = "c012" ]; then
#   WORK="/export4/data12/rwan/"
# elif [ $HOST = "c013" ]; then
#   WORK="/export4/data13/rwan/"
# elif [ $HOST = "c014" ]; then
#   WORK="/export4/data14/rwan/"
# elif [ $HOST = "c015" ]; then
#   WORK="/export4/data15/rwan/"
# elif [ $HOST = "c016" ]; then
#   WORK="/export4/data16/rwan/"
# else
#   printf "%b" "Error:  Unexpected host value.\n" >&2
#   exit 1
# fi

############################################################
##  Set up the $WORK directory on local disk
if [ ! -d "$WORK" ]
then
  mkdir $WORK
fi

if [ -d "$WORK/$JOB_ID" ]
then
  printf "Error!  The directory $WORK/$JOB_ID already exists!"
  exit
fi
mkdir $WORK/$JOB_ID

############################################################
##  Begin main work!
date
printf "\n"

##  Go to work directory
cd $WORK/$JOB_ID

$SRC/scripts/run-expt.pl --file $FILENAME_ARG --jobid $JOB_ID $METHOD_STR

############################################################
##  End

printf "Finished!!\n"

date

