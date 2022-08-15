#!/usr/bin/perl

use diagnostics;
use strict;
use warnings;

my $length = 48;

my @qscores;
for (my $i = 33; $i <= 126; $i++) {
  push (@qscores, chr ($i));
}
my $qscores_range = scalar (@qscores);

for (my $i = 0; $i < 2500; $i++) {
  printf "\@sample.%u\n", $i + 1;
  for (my $j = 0; $j < $length; $j++) {
    my $value = rand ();
    if ($value < 0.25) {
      print "A";
    }
    elsif ($value < 0.5) {
      print "C";
    }
    elsif ($value < 0.75) {
      print "G";
    }
    else {
      print "T";
    }
  }
  printf "\n";
  printf "+sample.%u\n", $i + 1;  

  for (my $j = 0; $j < $length; $j++) {
    my $pos = int (rand ($qscores_range));
    print $qscores[$pos];
  }
  printf "\n";
}

