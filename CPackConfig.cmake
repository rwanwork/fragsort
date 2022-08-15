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
##  CPack file
##
##  Raymond Wan
##  Organizations
##    - Department of Computational Biology, Graduate School of
##      Frontier Science, University of Tokyo
##    - Computational Biology Research Center, AIST, Japan
##
##  $Id: CPackConfig.cmake 45 2010-12-27 09:08:06Z rwan $
############################################################
CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

########################################
##  Set up the software

##  Project name
PROJECT (fragsort CXX)


########################################
##  Set the type of packages to generate

SET (CPACK_SOURCE_GENERATOR "TGZ")
SET (CPACK_GENERATOR "DEB")

########################################
##  Set the description about the software

SET (CPACK_PACKAGE_CONTACT "Raymond Wan")
SET (CPACK_PACKAGE_VENDOR "University of Tokyo / CBRC, AIST, Japan")
SET (CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/doc/gpl.txt)
SET (CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/doc/README)
SET (CPACK_PACKAGE_DESCRIPTION "FragSort system for sorting next generation sequencing data.")
SET (CPACK_PACKAGE_DESCRIPTION_SUMMARY "FragSort system for sorting next generation sequencing data.  The FragSort system allows users to sort the sequences in next generation sequencing data to improve compression effectiveness for standard systems like gzip and bzip2.")


########################################
##  Set the revision of the software

##  Get the Subversion revision
FIND_PACKAGE (Subversion)
if (Subversion_FOUND)
  Subversion_WC_INFO (${CMAKE_CURRENT_SOURCE_DIR} ER)
  SET (SUBVERSION_REVISION ${ER_WC_REVISION})
endif (Subversion_FOUND)

SET (CPACK_PACKAGE_NAME ${CMAKE_PROJECT_NAME})
SET (CPACK_PACKAGE_VERSION_MAJOR ${FragSort_VERSION_MAJOR})
SET (CPACK_PACKAGE_VERSION_MINOR ${FragSort_VERSION_MINOR})
# SET (CPACK_PACKAGE_VERSION_PATCH "${SUBVERSION_REVISION}")
SET (CPACK_PACKAGE_VERSION_PATCH "0")

SET (CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})

SET (CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-Source")
SET (CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")

########################################
##  Files to ignore

SET (CPACK_SOURCE_IGNORE_FILES
"/\\\\.svn/"
"/SRR.*\\\\.fastq$"
"/build/"
"~$"
".nobackup$"
"test.fastq"
"short-test.fastq"
"call-sge.sh"
"dist.sh"
"fix-timefiles.pl"
"make-xml.pl"
"parse-stdout.pl"
"readme.html"
"run-expt.pl"
"run-index-expt.pl"
"sge-run-expt.sh"
"sge-run-index-expt.sh"
"cmd.sh"
"analyze_fragsort.pm"
"CPackConfig.cmake"
"generate-fastq.pl"
"sample.old.fastq"
"/doc/CMakeLists.txt"
"UPDATE.info"
)
MESSAGE ("CPACK_SOURCE_IGNORE_FILES = ${CPACK_SOURCE_IGNORE_FILES}")


########################################
##  Debian-specific variables


# SET (CPACK_DEBIAN_PACKAGE_MAINTAINER "Raymond Wan")
SET (CPACK_DEBIAN_PACKAGE_SECTION "Science")
SET (CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}+squeeze1")
SET (CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i686")
SET (CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
SET (CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.3.6), libgcc1 (>= 1:4.1)")

