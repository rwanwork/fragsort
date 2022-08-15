#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#
#  Subversion date:  $Id: analyze_fragsort.pm 48 2011-01-13 04:55:33Z rwan $
#
package analyze_fragsort;
require Exporter;
our @ISA = qw (Exporter);
our @EXPORT = qw (processStdoutFile processTimeFile);

use FindBin qw ($Bin);
use lib "$Bin";

use strict;
use warnings;
use diagnostics;


##  Used by the parse-stdout.pl script
sub processStdoutFile {
  my $fn = shift;

  my $hostname = "";
  my $jobid = "";
  my $workdir = "";
  my $input_fn = "";
  my $qscores = "";
  my $method = "";

  open (FP, "<", $fn) or die "Could not open $fn for reading: $!";
  while (<FP>) {
    my $line = $_;
    chomp $line;

    if ($line =~ /^Hostname:\s+(.+)$/) {
      $hostname = $1;
    }
    elsif ($line =~ /^Job ID:\s+(.+)$/) {
      $jobid = $1;
    }
    elsif ($line =~ /^Work directory:\s+\/export3\/(.+)\/grpC\/rwan\/$/) {
      $workdir = $1;
    }
    elsif ($line =~ /Input file:\s+(.+)$/) {
      $input_fn = $1;
    }
    elsif ($line =~ /Method:\s+(.+)$/) {
      $method = $1;
    }
    elsif ($line =~ /Finished/) {
      printf STDOUT "%s\t%s\t%s\t%s\t%s\n", $input_fn, $method, $hostname, $jobid, $workdir;

      $input_fn = "";
    }
  }
  close (FP);

  if (length ($input_fn) != 0) {
    ##  Experiment still running
    printf STDOUT "%s *\t%s\t%s\t%s\t%s\t%s\n", $input_fn, $qscores, $method, $hostname, $jobid, $workdir;
  }

  return;
}

##  Used by the fix-timefiles.pl script
sub processTimeFile {
  my $fn = shift;
  my $backup_fn = "./backup/".$fn;
  my $tmp_fn = "tmp.data";

  copy ($fn, $backup_fn);
  rename ($fn, $tmp_fn);

  open (FP1, "<", $tmp_fn) or die "Could not open $tmp_fn for reading: $!";
  open (FP2, ">", $fn) or die "Could not open $fn for writing: $!";

  while (<FP1>) {
    my $line = $_;
    chomp $line;

    if ($line =~ /^==\t(.+)$/) {
      $line = $1;
      if ($. != 1) {
        print FP2 "\n";
      }
      print FP2 $line;
    }
    elsif ($line =~ /^(\S+)\t(\S+)$/) {
      print FP2 "\t", $1, "\t", $2
    }
  }

  print FP2 "\n";

  close FP1;
  close FP2;

  unlink $tmp_fn;

  return;
}

1;

