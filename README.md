FragSort
========

Introduction
------------

FragSort (Fragment Sorting) was developed for Next Generation Sequencing data to investigate the impact sorting has on compression effectiveness.  Sorting is performed using quicksort and radix sort.  Random permutations can also be performed to act as a baseline.  This document accompanies the archive, which includes:
    * source code in C++,
    * some Perl and bash scripts for testing the software, and
    * a very small data file for testing.

This archive does not include any binaries.


About the Source Code
---------------------

The source code was written in C++ and was originally compiled using v4.4.5 of the gcc compiler for Debian 6.0 (squeeze) or CentOS 5.4.

Additional software requirements of FragSort is listed in the table below and represent the software versions on which the experiments were run. They do not represent the minimum requirements; it is possible that lower versions can be used.

| Software                | Version | Required? | Web site                                    |
|:-----------------------:|:-------:|:---------:|:-------------------------------------------:|
|g++          | 4.4.5   |Yes        |http://gcc.gnu.org/              |
|CMake        | 2.8.2   |Yes        |http://www.cmake.org/            |
|Boost library| 1.42.0  |Yes        |http://www.boost.org/            |
|Perl         | 5.10.1  |No         |http://www.perl.org/             |
|bash         | 4.1.5   |No         |http://www.gnu.org/software/bash/|


The Boost Library must be both installed and compiled to make use of the program options library. Under some Linux distributions, Boost can be installed using its associated package manager (such as `apt` for Debian and Ubuntu). Consult your Linux distribution's documentation for further information.

Perl and bash are optional because of the testing scripts that are provided with the archive. Of course, they do not have to be used but are provided as a convenience for users. If they are used, other Perl modules will be required, such as File::Copy and AppConfig. All of these modules are available as part of your Linux distribution or in the Comprehensive Perl Archive Network (CPAN).


Files and Directories
---------------------

After having unarchived the file, the following directory structure should
result:

```
.
├── CMakeLists.txt
├── CPackConfig.cmake
├── ChangeLog
├── data -- Data directory
│   ├── generate-fastq.pl
│   ├── sample.fastq -- Sample data file
│   ├── short-test.fastq
│   └── test.fastq
├── LICENSE -- Copy of GNU GPL license v3
├── README.md -- This README.md
├── scripts -- Scripts for testing fragsort
└── src [*]
    └── FindBoost.cmake - Updated version of FindBoost.cmake to help with compiling. Will be part of Cmake from 2.8.3 RC1.
```

[*] Subdirectories not copied during the "make install" (see next section).


Compiling
---------

The FragSort software is written in C++ and has been compiled using v4.4.5 of g++. The system has been tested on a 64-bit system, but it does not make use of any features from 64-bit architectures.

CMake (at least version 2.8) is used to compile the software and it is recommended that an "out-of-source" build is performed so as not to clutter the original source directories. We give some brief instructions below on how to do this:
   1. Install Boost. Set the variable BOOST ROOT to the location of Boost if it has not already been set: `export BOOST ROOT=/usr/local/boost_1_42_0/`
   2. Expand the FragSort archive that accompanies this README file in a temporary directory.
   3. Within the expanded directory, create a build/ subdirectory and then enter it. Then run:  `cmake ..`.  By default, this will set up a Makefile to install the program into /usr/local. Without system administrator access, this would be impossible. To use another directory, type this:
      ```
           cmake .. -DCMAKE INSTALL PREFIX=~/tmp
      ```
      or whichever directory you prefer.
   4. Type "make" to compile the C++ source code of FragSort.
   5. If all goes well, type "make install" to install the software. This copies the important files from the archive (see Section III). The temporary directory with the expanded archive can now be deleted, unless you would like to see the source of the program.


Running FragSort
----------------

Running FragSort (as "bin/fragsort") with the --help option flag will print a list of options.

Alternatively, a set of scripts is provided in the scripts/ directory which will allow users to quickly use the software. See the next section for an example run.


Sample Run
----------

A sample data file "data/sample.data" is included in the archive. The reads in this data file is entirely synthetic with both the sequences and the quality scores being generated randomly using a uniform distribution. So the compression ratio achieved with this data file should not be taken seriously.

In the scripts/ directory, several Perl scripts and a single bash script is available for testing. The bash script is the main script and can be executed as follows:

```
     cd scripts
     ./process.sh sample
```

(Note that the .fastq extension is not included.) New FASTQ data files can be placed in the data/ subdirectory and executed in the same manner. The process.sh script runs the following commands:
   1. Show the size of the input file.
   2. Run scripts/collect-stats.pl to show the size of each component of the file.
   3. Run scripts/run-fragsort.pl command to execute Quicksort (only) and outputing to the ~/tmp/1 subdirectory, similar to the non-indexed-based experiments from the paper.
   4. Run scripts/run-fragsort-index.pl command to execute Quicksort (only) and outputing to the ~/tmp/2 subdirectory, similar to the indexed-based experiments from the paper.

See scripts/process.sh or the Perl scripts themselves if you wish to change the selected parameters. If the command is issued on sample.fastq, then the output will be similar to the output in doc/sample.fastq.out .


Understanding the Output
------------------------

In the output directory (specified using the --outdir option to fragsort), a set of files is created. When the scripts complete, the temporary files are removed. The remaining files for both run-fragsort.pl and run-fragsort-index.pl are given in the following tables:

Output from `run-fragsort.pl`:

| Filename | Description |
|:--------:|:-----------:|
|sample-[unique ID]-[machine name]-fastq-{bpc,time}.results|Original FASTQ file compression    |
|sample-[unique ID]-[machine name]-frags-{bpc,time}.results|Sequence compression               |
|sample-[unique ID]-[machine name]-halffrags-{bpc,time}.results      |Identifier and sequence compression|
|sample-[unique ID]-[machine name]-halfqscores-{bpc,time}.results      |Identifier and quality scores compression     |
|sample-[unique ID]-[machine name]-oneid-{bpc,time}.results|Second identifier removed          |
|sample-[unique ID]-[machine name]-qscores-{bpc,time}.results      |Quality scores compression         |


Output from `run-fragsort-index.pl`:

| Filename | Description |
|:--------:|:-----------:|
|sample-[unique ID]-[machine name]-bit-{bpc,time}.data    | Index (bit-based) compression  |
|sample-[unique ID]-[machine name]-fastq-time.results  | Original FASTQ file compression|
|sample-[unique ID]-[machine name]-frags-{bpc,time}.data  | Sequence compression           |
|sample-[unique ID]-[machine name]-ids-{bpc,time}.data    | Identifiers compression        |
|sample-[unique ID]-[machine name]-qscores-{bpc,time}.data | Quality scores compression     |

There are minor differences between the formats of each file, which are all tab-separated. Basically, for the files reporting on compression effectiveness (bpc = bits per character), the fields are:
   1. filename
   2. method (quicksort, radix sort, or random)
   3. Quicksort or radix sort parameter, as a percentage
   4. Replicate number
   5. gzip size
   6. bzip2 size
   7. Size of the input data
   8. Size of the original FASTQ data file

To get the compression ratio of gzip, divide the value in the 5th column by the value in either the 7th or 8th column (depending which is the reference point you desire). For the time files, the user and elapsed times are reported once per line. See `scripts/help_fragsort.pm` for more information about the format of the output files.


Missing Files
-------------


In the paper, we employ delta coding to encode the generated index. Delta
coding is not included in this archive as the source is being cleaned up.
Hopefully, it will be released in a few months.

Instead, binary coding using a fixed-length of 32 bits is used (i.e., no
coding). As our experiments showed that delta coding was only slightly better
than binary coding, this change does not impact our results significantly.


Contact
-------

This software was implemented by Raymond Wan while at the University of Tokyo, under the supervision of Prof. Kiyoshi Asai.

The software was initially hosted on my homepage and then "lost" in my computer for almost 10 years.  It was found in 2022 and uploaded to GitHub.  My current contact details:

     E-mail:  rwan.work@gmail.com

My homepage is [here](http://www.rwanwork.info/).

The latest version of Re-Pair can be downloaded from [GitHub](https://github.com/rwanwork/fragsort).

If you have any information about bugs, suggestions for the documentation or just have some general comments, feel free to contact me via e-mail or GitHub.


Citing
------

This software was originally described in:

```
     R. Wan and K. Asai. Sorting next generation sequencing data improves
     compression effectiveness. In Proc. 2010 IEEE International
     Conference on Bioinformatics and Biomedicine (BIBM) - Workshops and
     Posters, pages 567-572, 2010.
```

which we refer to as "the paper" throughout this document. In the paper, the
name of the software is never mentioned on purpose. Instead, the paper directly
references the algorithms used (radix sort or quicksort).


Copyright and License
---------------------

     FragSort (Fragment Sorting)
     Copyright (C) 2010-2022 by Raymond Wan (rwan.work@gmail.com)

FragSort is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.  Please see the accompanying file, LICENSE for further details.


Raymond Wan<br />
August 16, 2022
