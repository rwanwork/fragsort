#!/usr/bin/perl
#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#
#  Subversion date:  $Id: run-fragsort.pl 42 2010-12-27 08:24:30Z rwan $
#
use FindBin qw ($Bin);
use lib "$Bin";

use File::Copy;  ##  copy
use Sys::Hostname;  ##  hostname

use help_fragsort;

use diagnostics;
use strict;
use warnings;

use AppConfig;
use AppConfig::Getopt;
use Pod::Usage;
use Switch;
use Cwd;

################################################################################
##  Constants
my $NORMAL_RATIO = 100;  ##  Normalization factor for compression effectiveness
my $REPEATS = 3;  ##  Repeat 3 times
my $INCR = 10;  ##  Increments of 10%
my $HOSTNAME = hostname;
my $GROUPSIZE = 4;  ##  Number of lines in a read

##  Main directory where the bin/, scripts/, and doc/ directories of FragSort exist
##  Since this script is presumed to be executed from the scripts/ directory, the
##  main directory is one directory up.  Change this if not the case.
my @MAINDIRS = ("..");
my $MAINDIR;
foreach my $tmp (@MAINDIRS) {
  if (-e $tmp) {
    $MAINDIR = $tmp;
  }
}
if (!defined $MAINDIR) {
  printf STDERR "==\t[run-fragsort.pl]  Main directory could not be found!.\n";
  exit (1);
}

##  Data path is relative to $MAINDIR
my $DATADIR = $MAINDIR."/data";
my $fn = "";

##  Program paths are relative to $MAINDIR
my $REORDER = $MAINDIR."/scripts/reorder.pl";
my $SEPARATE = $MAINDIR."/scripts/separate.pl";
my $FRAGSORT = $MAINDIR."/bin/fragsort";

################################################################################
##  Process arguments

##  Create AppConfig and AppConfig::Getopt objects
my $config = AppConfig -> new ({
        GLOBAL => {
            DEFAULT => undef,     ##  Default value for new variables
        }
    });

my $getopt = AppConfig::Getopt -> new ($config);

$config -> define ("file", {
            ARGCOUNT => AppConfig::ARGCOUNT_ONE,
            ARGS => "=s",
        });                            ##  The input file to process
$config -> define ("outdir", {
            ARGCOUNT => AppConfig::ARGCOUNT_ONE,
            ARGS => "=s",
        });                            ##  Output directory
$config -> define ("jobid", {
            ARGCOUNT => AppConfig::ARGCOUNT_ONE,
            ARGS => "=s",
        });                            ##  Job ID
$config -> define ("radixsort!", {
            DEFAULT => 0,
        });                            ##  Method:  radixsort
$config -> define ("quicksort!", {
            DEFAULT => 0,
        });                            ##  Method:  quicksort
$config -> define ("random!", {
            DEFAULT => 0,
        });                            ##  Method:  random
$config -> define ("help!", {
            DEFAULT => 0,
        });                            ##  Help screen

##  Process the command-line options
$config -> getopt ();

$fn = $config -> get ("file");
if (!defined $fn) {
  printf STDERR "==\tError:  File required with the --file option.\n";
  exit (-1);
}
if ($fn =~ /\//) {
  printf STDERR "==\tError:  Only provide the filename using the --file option; do not give the directory, which is assumed to be %s.\n", $DATADIR;
  exit (-1);
}
if ($fn =~ /(.+)\.fastq$/) {
  $fn = $1;  ##  Remove the .fastq from the input filename -- it is assumed
}

my $JOB_ID = $config -> get ("jobid");  ##  job ID
if (!defined $JOB_ID) {
  printf STDERR "==\tError:  Job ID required with the --jobid option.\n";
  exit (-1);
}

my @methods;
if ($config -> get ("radixsort")) {
  push (@methods, "radixsort");
}
if ($config -> get ("quicksort")) {
  push (@methods, "quicksort");
}
if ($config -> get ("random")) {
  push (@methods, "random");
}
if ((!@methods) || (scalar (@methods) != 1)) {
  printf STDERR "==\tError:  One and only one method is allowed!\n";
  exit (-1);
}

my $OUTDIR = $config -> get ("outdir");  ##  Output directory
if (!defined $OUTDIR) {
  ##  Defaults to current directory
  $OUTDIR = "./";
}
if ($OUTDIR !~ /\/$/) {
  ##  Ensure there is a trailing slash
  $OUTDIR = $OUTDIR."/";
}

################################################################################
##  Initialize and delete output files

##  A unique identifier to prefix filenames
my $PREFIX = $fn."-".$JOB_ID."-".$HOSTNAME;

##  Output filenames for compression results
my $FRAGS_RESULTS = $OUTDIR."$PREFIX-frags-bpc.results";
my $QSCORES_RESULTS = $OUTDIR."$PREFIX-qscores-bpc.results";
my $HALFFRAGS_RESULTS = $OUTDIR."$PREFIX-halffrags-bpc.results";
my $HALFQSCORES_RESULTS = $OUTDIR."$PREFIX-halfqscores-bpc.results";
my $ONEID_RESULTS = $OUTDIR."$PREFIX-oneid-bpc.results";
my $FASTQ_RESULTS = $OUTDIR."$PREFIX-fastq-bpc.results";

##  Output filenames for time results
my $FRAGS_TIME = $OUTDIR."$PREFIX-frags-time.results";
my $QSCORES_TIME = $OUTDIR."$PREFIX-qscores-time.results";
my $HALFFRAGS_TIME = $OUTDIR."$PREFIX-halffrags-time.results";
my $HALFQSCORES_TIME = $OUTDIR."$PREFIX-halfqscores-time.results";
my $ONEID_TIME = $OUTDIR."$PREFIX-oneid-time.results";
my $FASTQ_TIME = $OUTDIR."$PREFIX-fastq-time.results";

##  Delete output files
unlink <$OUTDIR/*.results>;

################################################################################
##  Set up input and output files

##  Input files produced by separate.pl
my $frags_fn = $OUTDIR."$fn.frags";                    ##  Fragments
my $qscores_fn = $OUTDIR."$fn.qscores";                ##  Qscores
my $half_frags_fn = $OUTDIR."$fn.half_frags";          ##  ID + fragments
my $half_qscores_fn = $OUTDIR."$fn.half_qscores";      ##  ID + qscores
my $oneid_fn = $OUTDIR."$fn.oneid";                    ##  One ID line + fragments + qscores (3/4 of fastq)
my $fastq_fn = "$DATADIR/$fn.fastq";                   ##  Original input file

##  Temporary output files
my $out_frags_fn = $OUTDIR."out.frags";                ##  Temporary fragments from fragsort
my $out_qscores_fn = $OUTDIR."out.qscores";            ##  Temporary qscores from fragsort
my $out_half_frags_fn = $OUTDIR."out.half_frags";      ##  Temporary ID + fragments from reorder
my $out_half_qscores_fn = $OUTDIR."out.half_qscores";  ##  Temporary ID + qscores from reorder
my $out_oneid_fn = $OUTDIR."out.oneid";                ##  Temporary one ID line + fragments + qscores (3/4 of fastq) from reorder
my $out_fastq_fn = $OUTDIR."out.fastq";                ##  Temporary output fastq file from reorder

##  Generate input files using separate.pl
`$SEPARATE --groupsize $GROUPSIZE --line 1 <$fastq_fn >$frags_fn`;
`$SEPARATE --groupsize $GROUPSIZE --line 3 <$fastq_fn >$qscores_fn`;
`$SEPARATE --groupsize $GROUPSIZE --line 0 --line 1 <$fastq_fn >$half_frags_fn`;
`$SEPARATE --groupsize $GROUPSIZE --line 2 --line 3 <$fastq_fn >$half_qscores_fn`;
`$SEPARATE --groupsize $GROUPSIZE --plusonly --line 0 --line 1 --line 2 --line 3 <$fastq_fn >$oneid_fn`;

my $frags_size = getSize ($frags_fn);
my $qscores_size = getSize ($qscores_fn);
my $half_frags_size = getSize ($half_frags_fn);
my $half_qscores_size = getSize ($half_qscores_fn);
my $oneid_size = getSize ($oneid_fn);
my $fastq_size = getSize ($fastq_fn);

my $retval = 0;  ##  Return value from callProgram ()

################################################################################
##  Main program body
##
##  Operate with radix sort, quicksort, and then random.

foreach my $method (@methods) {
  for (my $k = 0; $k <= 100; $k += $INCR) {
    for (my $iter = 0; $iter < $REPEATS; $iter++) {
      my $fragsort_option = "--".$method;
      if ($method eq "radixsort") {
        $fragsort_option = $fragsort_option." --k ".$k;
      }
      elsif ($method eq "quicksort") {
        $fragsort_option = $fragsort_option." --frags ".$k;
      }

      ##  Output information to all time files
      foreach my $tmp_time ($FRAGS_TIME, $QSCORES_TIME, $HALFFRAGS_TIME, $HALFQSCORES_TIME, $ONEID_TIME, $FASTQ_TIME) {
        open (FP, ">>", $tmp_time) or die "Could not open $tmp_time for writing.\n";
        printf FP "==\t%s\t%s\t%u\t%u\n", $fn, $method, $k, $iter;
        close (FP);
      }

      ##################################################
      ##  Run fragsort on each FASTQ component
      $retval = callProgram ($FRAGSORT, "$fragsort_option --percent --ordering $OUTDIR/order-frags.txt", $frags_fn, $out_frags_fn, $FRAGS_TIME, $k);
      $retval = callProgram ($FRAGSORT, "$fragsort_option --percent --ordering $OUTDIR/order-qscores.txt", $qscores_fn, $out_qscores_fn, $QSCORES_TIME, $k);

      my $md5sum_frags = calculateMD5 ($out_frags_fn);
      my $md5sum_qscores = calculateMD5 ($out_qscores_fn);
      printf STDERR "--\t%s\t%s\t%u\t%u\t%s\t%s\n", $fn, $method, $k, $iter, $md5sum_frags, $md5sum_qscores;

      ##################################################
      ##  Compress the fragments and qscores
      runGzipBzip ($out_frags_fn, $frags_size, $fastq_size, $FRAGS_RESULTS, $FRAGS_TIME, $method, $fn, $k, $iter, $OUTDIR);
      runGzipBzip ($out_qscores_fn, $qscores_size, $fastq_size, $QSCORES_RESULTS, $QSCORES_TIME, $method, $fn, $k, $iter, $OUTDIR);

      ##  Run re-order and then compress the identifier + fragments combination
      $retval = callProgram ($REORDER, "--groupsize 2 --ordering $OUTDIR/order-frags.txt", $half_frags_fn, $out_half_frags_fn, $HALFFRAGS_TIME, $k);
      runGzipBzip ($out_half_frags_fn, $half_frags_size, $fastq_size, $HALFFRAGS_RESULTS, $HALFFRAGS_TIME, $method, $fn, $k, $iter, $OUTDIR);

      ##  Run re-order and then compress the identifier + qscores combination
      $retval = callProgram ($REORDER, "--groupsize 2 --ordering $OUTDIR/order-qscores.txt", $half_qscores_fn, $out_half_qscores_fn, $HALFQSCORES_TIME, $k);
      runGzipBzip ($out_half_qscores_fn, $half_qscores_size, $fastq_size, $HALFQSCORES_RESULTS, $HALFQSCORES_TIME, $method, $fn, $k, $iter, $OUTDIR);

      ##  Run re-order and then compress the one-id data
      $retval = callProgram ($REORDER, "--groupsize 4 --ordering $OUTDIR/order-frags.txt", $oneid_fn, $out_oneid_fn , $ONEID_TIME, $k);
      runGzipBzip ($out_oneid_fn, $oneid_size, $fastq_size, $ONEID_RESULTS, $ONEID_TIME, $method, $fn, $k, $iter, $OUTDIR);

      ##  Run re-order and then compress all of the data
      $retval = callProgram ($REORDER, "--groupsize 4 --ordering $OUTDIR/order-frags.txt", $fastq_fn, $out_fastq_fn , $FASTQ_TIME, $k);
      runGzipBzip ($out_fastq_fn, $fastq_size, $fastq_size, $FASTQ_RESULTS, $FASTQ_TIME, $method, $fn, $k, $iter, $OUTDIR);

      sleep (1);  ##  Sleep so that random number generator will get a seed from at least
                  ##  one second away.

      ##  Delete temporary ordering files
      unlink ($OUTDIR."order-frags.txt", $OUTDIR."order-qscores.txt");

      ##  Delete temporary output files
      foreach my $tmp_fn ($out_frags_fn, $out_qscores_fn, $out_half_frags_fn, $out_half_qscores_fn, $out_oneid_fn, $out_fastq_fn) {
        unlink $tmp_fn;
      }
    }
  }
}

##  Delete temporary input files
foreach my $tmp_fn ($frags_fn, $qscores_fn, $half_frags_fn, $half_qscores_fn, $oneid_fn) {
  unlink $tmp_fn;
}


=pod

=head1 NAME

run-fragsort.pl -- Run non-index-based experiments

=head1 SYNOPSIS

B<run-fragsort.pl> --file sample --jobid 1 --quicksort

=head1 DESCRIPTION

Run non-index-based experiments using quicksort, radix sort, or randomization.

=head1 OPTIONS

=over 5

=item --file

Name of input file.

=item --outdir

Output directory.  Defaults to "./".

=item --jobid

Process ID of this job.  Used as part of the output filenames to ensure that output files from different processes are not overwritten.

=item --radixsort

Use radix sort.  Only one of --radixsort, --quicksort, and --random can be selected.

=item --quicksort

Use Quicksort.  Only one of --radixsort, --quicksort, and --random can be selected.

=item --random

Use random ordering using a uniform distribution.  Only one of --radixsort, --quicksort, and --random can be selected.

=item --help

Display this help message.

=back

=head1 AUTHOR

Raymond Wan <r-wan@cb.k.u-tokyo.ac.jp>

=head1 COPYRIGHT

Copyright (C) 2010, Raymond Wan, All rights reserved.

