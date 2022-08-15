#!/usr/bin/perl
#  Author:  Raymond Wan
#  Organizations:  Department of Computational Biology, Graduate School of
#                    Frontier Science, University of Tokyo
#                  Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2010, Raymond Wan, All rights reserved.
#  Creation Date:  2010/06/03
#
#  Description:  See Pod below.
#
use FindBin qw ($Bin);
use lib "/home/rwan/perl/lib/perl5/site_perl/5.8.8";  ##  For chimera

use diagnostics;
use strict;
use warnings;

use AppConfig;
use AppConfig::Getopt;
use Pod::Usage;
use Switch;

################################################################################
##  Constants
my $DEFAULT_CFGFILE = "reorder.cfg";  ##  Default configuration file
my $CFGFILE;  ##  User-defined configuration file

################################################################################
##  Important data structures
my @lines;

################################################################################
##  Process arguments

##  Search @ARGV to find alternative configuration file
for (my $i = 0; $i < scalar (@ARGV); $i++) {
  ##  Need to accept -config and --config; ignore if it is the last argument and let
  ##  AppConfig produce an error
  if (($ARGV[$i] =~ /-?-config/) && ($i != (scalar (@ARGV) - 1))) {
    $CFGFILE = $ARGV[$i + 1];
    last;
  }
}

##  Create AppConfig and AppConfig::Getopt objects
my $config = AppConfig -> new ({
        GLOBAL => {
            DEFAULT => undef,     ##  Default value for new variables
        }
    });

my $getopt = AppConfig::Getopt -> new ($config);

$config -> define ("config=s");        ##  Name of configuration file
$config -> define ("ordering", {
            ARGCOUNT => AppConfig::ARGCOUNT_LIST,
            ARGS => "=s",
        });                            ##  Filename of the binary file of orderings
$config -> define ("groupsize", {
            ARGCOUNT => AppConfig::ARGCOUNT_LIST,
            ARGS => "=i",
        });                            ##  Number of lines per groupsize
$config -> define ("debug!", {
            DEFAULT => 0,
        });                            ##  Debug mode
$config -> define ("help!", {
            DEFAULT => 0,
        });                            ##  Help screen

##  Process the two configuration files first, and then the command-lines next
if (!-e $DEFAULT_CFGFILE) {
}
else {
  printf STDERR "==\tNote:  Default configuration file [%s] found.\n", $DEFAULT_CFGFILE;
  $config -> file ($DEFAULT_CFGFILE);
}
if (defined $CFGFILE) {
  if (!-e $CFGFILE) {
    printf STDERR "==\tError:  Specified configuration file [%s] not found.\n", $CFGFILE;
    exit (1);
  }
  else {
    $config -> file ($CFGFILE);
  }
}
$config -> getopt ();

################################################################################
##  Check parameters
if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("ordering"))) {
  printf STDERR "==\tError:  Filename with the --ordering option is required.\n";
  exit (1);
}

if (!defined ($config -> get ("groupsize"))) {
  printf STDERR "==\tError:  Size of a group (in # of lines) required with the --groupsize option.\n";
  exit (1);
}

################################################################################
##  Read in the data from STDIN

my $k = 0;
my $groupsize = $config -> get ("groupsize");
while (<STDIN>) {
  my $str = $_;
  for (my $i = 1; $i < $groupsize; $i++) {
    $str = $str.<STDIN>;
  }
  if (($str !~ /^\@/) && ($str !~ /^\+/)) {
    printf STDERR "==\tError in input line %u:  [%s].\n", $., $str;
    exit (255);
  }
  $lines[$k] = $str;
  $k++;
}

if ($config -> get ("debug")) {
  printf STDERR "==\t[reorder.pl]\tRead in %u tags of %u lines each.\n", $k, $groupsize;
}

################################################################################
##  Read in the ordering file

my $fn_len = -s $config -> get ("ordering");

my $buffer;
open (FP, "<", $config -> get ("ordering")) or die "==\tError:  The ordering file could not be opened for reading.\n";
read (FP, $buffer, $fn_len);
close FP;

##  Convert the binary string to an array of integers
my @buffer_array = unpack ('I*', $buffer);
if (scalar (@buffer_array) == 0) {
  printf STDERR "==\tError:   Empty file!\n";
  exit (255);
}

for (my $i = 0; $i < scalar (@buffer_array); $i++) {
  print STDOUT $lines[$buffer_array[$i]];
  $lines[$buffer_array[$i]] = "";
}

##  Sanity check; make sure everything has been deleted
for (my $i = 0; $i < scalar (@lines); $i++) {
  if (length $lines[$i] > 0) {
    printf STDERR "==\tError:  Data remains in array at position %u [%s].\n", $i, $lines[$i];
    exit (255);
  }
}

if ($config -> get ("debug")) {
  printf STDERR "==\t[reorder.pl]\tProcessed %u lines.\n", scalar (@lines);
}

=pod

=head1 NAME

reorder.pl -- Script for re-ordering SRA data.

=head1 SYNOPSIS

B<reorder.pl> [I<OPTIONS>] <input-file >output-file

=head1 DESCRIPTION

Need one.

=over 5

=item --ordering

Something

=item --config

Something

=item --groupsize

Something

=item --debug

Produce verbose debugging information (future use).

=item --help

Display this help message.

=back

=head1 EXAMPLE COMMAND-LINE

=over 5

=item Need example...

./reorder.pl <input.txt >output.txt

=back

=head1 AUTHOR

Raymond Wan <r.wan@aist.go.jp>

=head1 COPYRIGHT

Copyright (C) 2010, Raymond Wan, All rights reserved.

