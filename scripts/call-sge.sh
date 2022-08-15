#!/bin/bash

##############################
##  Indexing experiments
##############################

##############################
# METHODS="radixsort quicksort random"
# FNS="SRR005489 SRR014437 SRR014835_1 SRR034845 SRR020180 SRR033869"
# 
# for fn in $FNS; do
#   for meth in $METHODS; do
#     qsub -l excl=true -q q1c /export3/mp01/grpC/rwan/seqsort/scripts/sge-run-index-expt.sh $fn $meth
#   done
# done

##############################
##  Original experiments
##############################

##############################
# METHODS="radixsort quicksort random"
# FNS="SRR005489 SRR014835_1 SRR014437 SRR020180 SRR033869 SRR034845"
# 
# for fn in $FNS; do
#   for meth in $METHODS; do
#     qsub -l excl=true -q q1c /export3/mp01/grpC/rwan/seqsort/scripts/sge-run-expt.sh $fn $meth
#   done
# done

qsub -l excl=true -q q1c@c005 /export3/mp01/grpC/rwan/seqsort/scripts/sge-run-expt.sh SRR034845 radixsort
qsub -l excl=true -q q1c@c006 /export3/mp01/grpC/rwan/seqsort/scripts/sge-run-expt.sh SRR034845 quicksort
qsub -l excl=true -q q1c@c009 /export3/mp01/grpC/rwan/seqsort/scripts/sge-run-expt.sh SRR034845 random

##########################################################################################

