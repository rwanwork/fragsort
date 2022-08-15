#!/usr/bin/perl
#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#  Creation Date:  2010/10/05
#  Subversion date:  $Id: parse-stdout.pl 31 2010-10-08 08:40:26Z rwan $
#
#  Description:  See Pod below.
#
use FindBin qw ($Bin);
use lib "$Bin";
use lib "/home/rwan/perl/lib/perl5/site_perl/5.8.8";  ##  For chimera

use File::Copy;  ##  copy
use Sys::Hostname;  ##  hostname

use runexpts;

use warnings;
use diagnostics;
use strict;

opendir (my $dh1, "./") || die "Can't opendir current directory: $!";
my @fns1 = sort grep { /sge-run-expt\.sh/ && -f "./$_" } readdir ($dh1);
closedir $dh1;

foreach my $fn (@fns1) {
  processStdoutFile ($fn);
}

printf "%s\n", "=" x 50;

opendir (my $dh2, "./") || die "Can't opendir current directory: $!";
my @fns2 = sort grep { /sge-run-index-expt\.sh/ && -f "./$_" } readdir ($dh2);
closedir $dh2;

foreach my $fn (@fns2) {
  processStdoutFile ($fn);
}

