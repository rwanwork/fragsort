#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#
#  Subversion date:  $Id: bitcoding_deltagamma.pm 48 2011-01-13 04:55:33Z rwan $
#
package bitcoding_deltagamma;
require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw (runBitCodingDeltaGamma);

use FindBin qw ($Bin);
use lib "$Bin";

use strict;
use warnings;
use diagnostics;


sub runBitCodingDeltaGamma {
  my ($input, $fastq_size, $bpc_results_fn, $time_results_fn, $method, $fn, $k, $iter, $OUTDIR) = @_;

  if ((!defined $OUTDIR) || (length ($OUTDIR) == 0)) {
    printf STDERR "==\tFatal error:  Last argument not defined in runBitCodingDeltaGamma ().\n";
    exit (1);
  }

  my $out_fn = "./tmp.dat";                   ##  Temporary file 1 from encoding
  my $out2_fn = "./tmp2.dat";                 ##  Temporary file 2 from decoding
  my $input_size = (-s $input);

  ##  Alternative main directory for bit encoding
  my @ALT_MAINDIRS = ("/home/rwan/working/compression/dna-repair/src/bitio", "/export3/mp01/grpC/rwan/dna-repair/src/bitio");
  my $ALT_MAINDIR;
  foreach my $tmp (@ALT_MAINDIRS) {
    if (-e $tmp) {
      $ALT_MAINDIR = $tmp;
    }
  }
  if (!defined $ALT_MAINDIR) {
    printf STDERR "==\t[bitcoding_deltagamma.pm]  Alternative main directory for bit coding programs could not be found!.\n";
    exit (1);
  }

  my $GAMMA = $ALT_MAINDIR."/gamma-file";
  my $DELTA = $ALT_MAINDIR."/delta-file";

  if ((!-e $GAMMA) || (!-e $DELTA)) {
    printf STDERR "==\tFatal error:  Bit coding programs cannot be found in runBitCodingDeltaGamma ().\n";
    exit (1);
  }

  ##  Run gamma encoding and decoding
  my $retval = callProgram ($GAMMA, "encode", $input, $out_fn, $time_results_fn, $k);
  my $gamma_size = getSize ($out_fn);

  $retval = callProgram ($GAMMA, "decode", $out_fn, $out2_fn, $time_results_fn, 1);
  if (compareMD5 ($input, $out2_fn)) {
    exit (-1);
  }
  unlink ($out_fn, $out2_fn);

  ##  Run gamma encoding and decoding
  $retval = callProgram ($DELTA, "encode", $input, $out_fn, $time_results_fn, $k);
  my $delta_size = getSize ($out_fn);

  $retval = callProgram ($DELTA, "decode", $out_fn, $out2_fn, $time_results_fn, 1);
  if (compareMD5 ($input, $out2_fn)) {
    exit (-1);
  }
  unlink ($out_fn, $out2_fn);

  ################################################################################
  ##  Output results to file
  open (FP, ">>", $bpc_results_fn) or die "Could not open $bpc_results_fn for appending.\n";
  printf FP "%s", $fn;
  printf FP "\t%s", $input;
  printf FP "\t%s", $method;
  printf FP "\t%u", $k;
  printf FP "\t%u", $iter;
  printf FP "\t%u\t%u\t%u\t%u", $gamma_size, $delta_size, $input_size, $fastq_size;
  printf FP "\n";
  close (FP);

  return;
}

1;


