#!/usr/bin/perl
#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#  Creation Date:  2010/07/29
#
#  Description:  See Pod below.
#
use FindBin qw ($Bin);
use lib "$Bin";
use lib "/home/rwan/perl/lib/perl5/site_perl/5.8.8";  ##  For chimera

use diagnostics;
use strict;
use warnings;

use Switch;

################################################################################
##  Constants

################################################################################
##  Process arguments

################################################################################
##  Initialize and delete output files

################################################################################
##  Set up input files

################################################################################
##  Main program body

printf "<xml>\n";
while (<STDIN>) {
  my $line0 = $_;
  chomp $line0;

  my $line1 = <STDIN>;
  chomp $line1;
  my $line2 = <STDIN>;
  chomp $line2;
  my $line3 = <STDIN>;
  $line3 =~ s/</&lt;/gs;
  $line3 =~ s/>/&gt;/gs;
  chomp $line3;
  
  printf " <read>\n";
  printf "  <id>%s</id>\n", $line0;
  printf "  <seq>%s</seq>\n", $line1;
  printf "  <qs>%s</qs>\n", $line3;
  printf " </read>\n";
}
printf "</xml>\n";



