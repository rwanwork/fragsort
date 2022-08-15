#!/bin/bash
##  Distribute files to the main chimera node

SITE=chimera1.cbrc.jp

HOME=/home/rwan
SRC1=$HOME/working/compression/seqsort
SRC2=$HOME/working/compression/dna-repair
DEST=/export3/mp01/grpC/rwan

rsync -artuzv $SRC1 rwan@$SITE:$DEST
rsync -artuzv $SRC2 rwan@$SITE:$DEST

