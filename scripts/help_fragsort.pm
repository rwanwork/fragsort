#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#
#  Subversion date:  $Id: help_fragsort.pm 48 2011-01-13 04:55:33Z rwan $
#
package help_fragsort;
require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw (runGzipBzip callProgram getSize getFragLength getFragCount calculateMD5 compareMD5 processStdoutFile processTimeFile);

use FindBin qw ($Bin);
use lib "$Bin";
use File::Copy;  ##  copy
use File::Basename;
use Digest::MD5;

use strict;
use warnings;
use diagnostics;


##  Call another program
sub callProgram {
  my ($cmd, $options, $infile, $outfile, $timefile, $k) = @_;

  my $basename = basename ($infile);
  my $tmp_fn = "callProgram.tmp";
  my @args;

  if (!defined $k) {
    printf STDERR "==\tFatal error:  Last argument not defined in callProgram.\n";
    printf STDERR "==\tCall was:  %s %s %s %s\n", $cmd, $options, $infile, $outfile;
    exit (-1);
  }
#     printf STDERR "==\tCall is:  %s %s %s %s\n", $cmd, $options, $infile, $outfile;

  ##  Only run once, but don't time and log to disk; record the user time 
  ##  (seconds) and elapsed time (seconds)
  if ((($cmd =~ /fragsort$/) || ($cmd =~ /reorder\.pl$/)) && 
      ($k == 0)) {
    @args = ("/usr/bin/time -o $timefile -a -f \"%U\t%e\" cp $infile $outfile");
  }
  elsif ($cmd =~ /fragsort$/) {
    @args = ("/usr/bin/time -o $timefile -a -f \"%U\t%e\" $cmd $options $infile >$outfile");
  }
  elsif (($cmd =~ /gamma-file$/) || ($cmd =~ /delta-file$/)) {
    @args = ("/usr/bin/time -o $timefile -a -f \"%U\t%e\" $cmd $options $infile $outfile");
  }
  else {
    @args = ("/usr/bin/time -o $timefile -a -f \"%U\t%e\" $cmd $options <$infile >$outfile");
  }

  ##  Run the program once
  system (@args);
  if ($? != 0) {
    printf STDERR "==\tFatal Error:  Return value from executing %s invalid (options:  %s)!\n", $cmd, $options;
    exit (255);
  }

  return 0;
}


##  Get the size of a file
sub getSize {
  my $fn = shift;
  if (!-e $fn) {
    printf STDERR "==\tError:  File [%s] does not exist.  [help_fragsort.pm::getSize ()]\n", $fn;
    exit (-1);
  }

  return (-s $fn);
}


##  Returns the length of the longest fragment; somewhat wasteful if all
##  fragments are the same length...
sub getFragLength {
  my $fn = shift;
  my $tmp;
  my $len = 0;

  open (FP, "<", $fn) or die "Could not open $fn for input.\n";
  while (<FP>) {
    $tmp = $_;
    chomp $tmp;
    if (length ($tmp) > $len) {
      $len = length ($tmp);
    }
  }
  close (FP);

  return ($len);
}


##  Returns the total number of fragments (basically, number of lines)
sub getFragCount {
  my $fn = shift;
  my $count = 0;

  open (FP, "<", $fn) or die "Could not open $fn for input.\n";
  while (<FP>) {
    $count++;
  }
  close (FP);

  return ($count);
}


##  Calculate the md5sum of a file
sub calculateMD5 {
  my $fn = shift;

  open (FP, $fn) or die "Can't open $fn: $!";
  binmode (FP);
  my $result = Digest::MD5 -> new -> addfile (*FP) -> hexdigest;

  return $result;
}


##  Compare the md5sums of two files
sub compareMD5 {
  my ($fn1, $fn2) = @_;

  my $md1 = calculateMD5 ($fn1);
  my $md2 = calculateMD5 ($fn2);

  if ($md1 ne $md2) {
    printf STDERR "==\tMD5 between [%s] and [%s] do not match!\n", $md1, $md2;
    return 1;
  }

  return 0;
}


sub runGzipBzip {
  my ($input, $input_size, $fastq_size, $bpc_results_fn, $time_results_fn, $method, $fn, $k, $iter, $OUTDIR) = @_;

  my $out_fn = $OUTDIR."tmp.dat";                   ##  Temporary file 1 from gzip/bzip2
  my $out2_fn = $OUTDIR."tmp2.dat";                 ##  Temporary file 2 from gzip/bzip2

  my $gzip = "/bin/gzip";
  my $gunzip = "/bin/gunzip";
  my $bzip = "/bin/bzip2";
  my $bunzip = "/bin/bunzip2";

  if ((!defined $OUTDIR) || (length ($OUTDIR) == 0)) {
    printf STDERR "==\tFatal error:  Last argument not defined in runGzipBzip ().\n";
    exit (-1);
  }

  if (!-e $bzip) {
    $bzip = "/usr/bin/bzip2";
  }
  if (!-e $bunzip) {
    $bunzip = "/usr/bin/bunzip2";
  }

  ##  Run gzip and gunzip
  my $retval = callProgram ($gzip, "-9 -c", $input, $out_fn, $time_results_fn, 1);
  my $gzip_size = getSize ($out_fn);

  $retval = callProgram ($gunzip, "-c", $out_fn, $out2_fn, $time_results_fn, 1);
  if (compareMD5 ($input, $out2_fn)) {
    exit (-1);
  }
  unlink ($out_fn, $out2_fn);

  ##  Run bzip2 and bunzip2
  $retval = callProgram ($bzip, "-9 -c", $input, $out_fn, $time_results_fn, 1);
  my $bzip_size = getSize ($out_fn);

  $retval = callProgram ($bunzip, "-c", $out_fn, $out2_fn, $time_results_fn, 1);
  if (compareMD5 ($input, $out2_fn)) {
    exit (-1);
  }
  unlink ($out_fn, $out2_fn);

  ################################################################################
  ##  Output results to file
  open (FP, ">>", $bpc_results_fn) or die "Could not open $bpc_results_fn for appending.\n";
  printf FP "%s", $fn;
  printf FP "\t%s", $method;
  printf FP "\t%u", $k;
  printf FP "\t%u", $iter;
  printf FP "\t%u\t%u\t%u\t%u", $gzip_size, $bzip_size, $input_size, $fastq_size;
  printf FP "\n";
  close (FP);

  return;
}


1;


