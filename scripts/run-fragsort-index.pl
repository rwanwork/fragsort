#!/usr/bin/perl
#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#
#  Subversion date:  $Id: run-fragsort-index.pl 42 2010-12-27 08:24:30Z rwan $
#
use FindBin qw ($Bin);
use lib "$Bin";

use File::Copy;  ##  copy
use Sys::Hostname;  ##  hostname

use help_fragsort;
use bitcoding_binary;

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
  printf STDERR "==\t[run-fragsort-index.pl]  Main directory could not be found!.\n";
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
my $IDS_RESULTS = $OUTDIR."$PREFIX-ids-bpc.data";
my $FRAGS_RESULTS = $OUTDIR."$PREFIX-frags-bpc.data";
my $QSCORES_RESULTS = $OUTDIR."$PREFIX-qscores-bpc.data";
my $BIT_RESULTS = $OUTDIR."$PREFIX-bit-bpc.data";

##  Output filenames for time results
my $IDS_TIME = $OUTDIR."$PREFIX-ids-time.data";
my $FRAGS_TIME = $OUTDIR."$PREFIX-frags-time.data";
my $QSCORES_TIME = $OUTDIR."$PREFIX-qscores-time.data";
my $BIT_TIME = $OUTDIR."$PREFIX-bit-time.data";
my $FASTQ_TIME = $OUTDIR."$PREFIX-fastq-time.results";

##  Delete output files and results
unlink <$OUTDIR/*.data>;
unlink <$OUTDIR/*.results>;

################################################################################
##  Set up input and output files

##  Input files produced by separate.pl
my $ids_fn = $OUTDIR."$fn.ids";                        ##  IDs
my $frags_fn = $OUTDIR."$fn.frags";                    ##  Fragments
my $qscores_fn = $OUTDIR."$fn.qscores";                ##  Qscores
my $fastq_fn = "$DATADIR/$fn.fastq";             ##  Original input file

##  Temporary output files
my $out_ids_fn = $OUTDIR."out.ids";                    ##  Temporary IDs from fragsort
my $out_frags_fn = $OUTDIR."out.frags";                ##  Temporary fragments from fragsort
my $out_qscores_fn = $OUTDIR."out.qscores";            ##  Temporary qscores from fragsort
my $out_fastq_fn = $OUTDIR."out.fastq";                ##  Temporary output fastq file from reorder

##  Generate input files using separate.pl
`$SEPARATE --groupsize $GROUPSIZE --line 0 <$fastq_fn >$ids_fn`;

my $ids_size = getSize ($ids_fn);
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
      foreach my $tmp_time ($FRAGS_TIME, $QSCORES_TIME, $IDS_TIME, $BIT_TIME, $FASTQ_TIME) {
        open (FP, ">>", $tmp_time) or die "Could not open $tmp_time for writing.\n";
        printf FP "==\t%s\t%s\t%u\t%u\n", $fn, $method, $k, $iter;
        close (FP);
      }

      ##################################################
      ##  Run fragsort on the IDs
      $retval = callProgram ($FRAGSORT, "$fragsort_option --percent --ordering $OUTDIR/order-ids.txt", $ids_fn, $out_ids_fn, $IDS_TIME, $k);

      ##  Reorder the original data file by IDs
      $retval = callProgram ($REORDER, "--groupsize 4 --ordering $OUTDIR/order-ids.txt", $fastq_fn, $out_fastq_fn, $FASTQ_TIME, $k);

      ##  Extract the sequence fragments and quality scores from the newly reordered FASTQ file
      `$SEPARATE --groupsize $GROUPSIZE --line 1 <$out_fastq_fn >$frags_fn`;
      `$SEPARATE --groupsize $GROUPSIZE --line 3 <$out_fastq_fn >$qscores_fn`;
      my $frags_size = getSize ($frags_fn);
      my $qscores_size = getSize ($qscores_fn);

      $retval = callProgram ($FRAGSORT, "$fragsort_option --percent --ordering $OUTDIR/order-frags.txt", $frags_fn, $out_frags_fn, $FRAGS_TIME, $k);
      $retval = callProgram ($FRAGSORT, "$fragsort_option --percent --ordering $OUTDIR/order-qscores.txt", $qscores_fn, $out_qscores_fn, $QSCORES_TIME, $k);

      ##  Report the md5sum and ensure the sizes of the ordering files are the same
      my $md5sum_ids = calculateMD5 ($out_ids_fn);
      my $md5sum_frags = calculateMD5 ($out_frags_fn);
      my $md5sum_qscores = calculateMD5 ($out_qscores_fn);
      printf STDERR "--\t%s\t%s\t%u\t%u\t%s\t%s\t%s\n", $fn, $method, $k, $iter, $md5sum_ids, $md5sum_frags, $md5sum_qscores;

      if ($k != 0) {
        if (((-s $OUTDIR."order-ids.txt") != (-s $OUTDIR."order-frags.txt")) || 
            ((-s $OUTDIR."order-ids.txt") != (-s $OUTDIR."order-qscores.txt")) || 
            ((-s $OUTDIR."order-qscores.txt") != (-s $OUTDIR."order-frags.txt"))) {
          printf STDERR "==\tError -- unexpected difference in file sizes of ordering files in %s:  %u %u %u.\n", $OUTDIR, (-s "order-ids.txt"), (-s "order-frags.txt"), (-s "order-qscores.txt");
        }
      }

      ##################################################
      ##  Bit encode and decode the ordering files only if $k != 0 (since otherwise, no ordering
      ##  file is generated).  The index is in the order of the IDs, so no need to encode that.
      if ($k != 0) {
        runBitCodingBinary ("order-frags.txt", $fastq_size, $BIT_RESULTS, $BIT_TIME, $method, $fn, $k, $iter, $OUTDIR);
        runBitCodingBinary ("order-qscores.txt", $fastq_size, $BIT_RESULTS, $BIT_TIME, $method, $fn, $k, $iter, $OUTDIR);
      }

      ##################################################
      ##  Compress the IDs, fragments, and qscores
      runGzipBzip ($out_ids_fn, $ids_size, $fastq_size, $IDS_RESULTS, $IDS_TIME, $method, $fn, $k, $iter, $OUTDIR);
      runGzipBzip ($out_frags_fn, $frags_size, $fastq_size, $FRAGS_RESULTS, $FRAGS_TIME, $method, $fn, $k, $iter, $OUTDIR);
      runGzipBzip ($out_qscores_fn, $qscores_size, $fastq_size, $QSCORES_RESULTS, $QSCORES_TIME, $method, $fn, $k, $iter, $OUTDIR);

      sleep (1);  ##  Sleep so that random number generator will get a seed from at least
                  ##  one second away.

      ##  Delete temporary ordering files
      unlink ($OUTDIR."order-ids.txt", $OUTDIR."order-frags.txt", $OUTDIR."order-qscores.txt");

      ##  Delete temporary output files
      foreach my $tmp_fn ($out_ids_fn, $out_frags_fn, $out_qscores_fn, $out_fastq_fn) {
        unlink $tmp_fn;
      }
    }
  }
}

##  Delete temporary input files
foreach my $tmp_fn ($ids_fn, $frags_fn, $qscores_fn) {
  unlink $tmp_fn;
}


=pod

=head1 NAME

run-fragsort-index.pl -- Run index-based experiments

=head1 SYNOPSIS

B<run-fragsort-index.pl> --file sample --jobid 1 --quicksort

=head1 DESCRIPTION

Run index-based experiments (only) using quicksort, radix sort, or randomization.

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

