#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#
#  Subversion date:  $Id: bitcoding_binary.pm 48 2011-01-13 04:55:33Z rwan $
#
package bitcoding_binary;
require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw (runBitCodingBinary);

use FindBin qw ($Bin);
use lib "$Bin";

use strict;
use warnings;
use diagnostics;

use help_fragsort;

sub runBitCodingBinary {
  my ($input, $fastq_size, $bpc_results_fn, $time_results_fn, $method, $fn, $k, $iter, $OUTDIR) = @_;

  if (!defined $iter) {
    printf STDERR "==\tFatal error:  Last argument not defined in runBitCodingBinary ().\n";
    exit (1);
  }

  ##  Report the file size as-is (since it is binary coding)
  my $binary_size = (-s $OUTDIR."/".$input);

  ################################################################################
  ##  Output results to file
  open (FP, ">>", $bpc_results_fn) or die "Could not open $bpc_results_fn for appending.\n";
  printf FP "%s", $fn;
  printf FP "\t%s", $input;
  printf FP "\t%s", $method;
  printf FP "\t%u", $k;
  printf FP "\t%u", $iter;
  printf FP "\t%u\t%u\t%u\t%u", $binary_size, $binary_size, $binary_size, $fastq_size;
  printf FP "\n";
  close (FP);

  return;
}

1;

