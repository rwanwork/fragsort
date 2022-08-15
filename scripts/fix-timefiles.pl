#!/usr/bin/perl
#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#  Creation Date:  2010/10/08
#  Subversion date:  $Id: fix-timefiles.pl 32 2010-10-12 16:01:02Z rwan $
#
#  Description:  Change the timing files into a tabular format for easier processing.
#
use FindBin qw ($Bin);
use lib "$Bin";
use lib "/home/rwan/perl/lib/perl5/site_perl/5.8.8";  ##  For chimera

use Sys::Hostname;  ##  hostname

use runexpts;

use warnings;
use diagnostics;
use strict;

opendir (my $dh1, "./") || die "Can't opendir current directory: $!";
my @fns1 = grep { /time\.results/ && -f "./$_" } readdir ($dh1);
closedir $dh1;

foreach my $fn (@fns1) {
  printf STDERR "%s\n", $fn;
  processTimeFile ($fn);
}

printf STDERR "%s\n", "=" x 50;

opendir (my $dh2, "./") || die "Can't opendir current directory: $!";
my @fns2 = grep { /time\.data/ && -f "./$_" } readdir ($dh2);
closedir $dh2;

foreach my $fn (@fns2) {
  printf STDERR "%s\n", $fn;
  processTimeFile ($fn);
}

