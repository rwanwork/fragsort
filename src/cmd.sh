#!/bin/bash
DATA=../data
# ./tagrsort tags.txt --verbose --output outtags.txt --ordering order.txt
# ./tagrsort tags.txt --verbose --output outtags.txt --random --ordering order.txt

./tagrsort --verbose --ordering order.txt <$DATA/tags.txt >outtags.txt

####
# ./tagrsort words.txt --verbose --output outtags.txt --ordering order.txt

# ./tagrsort --verbose --ordering order.txt <$DATA/words.txt >outtags.txt
