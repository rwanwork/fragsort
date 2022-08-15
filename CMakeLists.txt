#####################################################################
##  FragSort (Fragment Sorting for Next Generation Sequence Data)
##  Copyright (C) 2010  by Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#####################################################################

############################################################
##  CMake file
##
##  Raymond Wan
##  Organizations
##    - Department of Computational Biology, Graduate School of
##      Frontier Science, University of Tokyo
##    - Computational Biology Research Center, AIST, Japan
##
##  $Id: CMakeLists.txt 45 2010-12-27 09:08:06Z rwan $
############################################################
CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

########################################
##  Set up the software

##  Project name
PROJECT (fragsort CXX)

##  Define software version number
SET (FragSort_VERSION_MAJOR 1)
SET (FragSort_VERSION_MINOR 0)

########################################
##  Set up the subdirectories

ADD_SUBDIRECTORY (src)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/doc/CMakeLists.txt)
  ADD_SUBDIRECTORY (doc)
endif ()

############################################################
##  Installation
############################################################

INSTALL (FILES scripts/bitcoding_binary.pm DESTINATION fragsort/scripts)
INSTALL (PROGRAMS scripts/collect-stats.pl DESTINATION fragsort/scripts)
INSTALL (FILES scripts/help_fragsort.pm DESTINATION fragsort/scripts)
INSTALL (PROGRAMS scripts/process.sh DESTINATION fragsort/scripts)
INSTALL (PROGRAMS scripts/reorder.pl DESTINATION fragsort/scripts)
INSTALL (PROGRAMS scripts/run-fragsort.pl DESTINATION fragsort/scripts)
INSTALL (PROGRAMS scripts/run-fragsort-index.pl DESTINATION fragsort/scripts)
INSTALL (PROGRAMS scripts/separate.pl DESTINATION fragsort/scripts)
INSTALL (FILES doc/AUTHORS DESTINATION fragsort/doc)
INSTALL (FILES doc/fdl-1.3.txt DESTINATION fragsort/doc)
INSTALL (FILES doc/gpl.txt DESTINATION fragsort/doc)
INSTALL (FILES doc/ChangeLog DESTINATION fragsort/doc)
INSTALL (FILES doc/NEWS DESTINATION fragsort/doc)
INSTALL (FILES doc/README DESTINATION fragsort/doc)
INSTALL (FILES doc/README.html DESTINATION fragsort/doc)
INSTALL (FILES doc/VERSION DESTINATION fragsort/doc)
INSTALL (FILES doc/sample.fastq.out DESTINATION fragsort/doc)
INSTALL (FILES data/sample.fastq DESTINATION fragsort/data)

############################################################
##  CPack
############################################################

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/CPackConfig.cmake)
  Include (${CMAKE_CURRENT_SOURCE_DIR}/CPackConfig.cmake)
  Include (CPack)
endif ()

