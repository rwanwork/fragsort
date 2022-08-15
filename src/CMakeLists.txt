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
##  $Id: CMakeLists.txt 47 2011-01-04 09:37:38Z rwan $
############################################################
CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

########################################
##  Set up the software

##  Project name
PROJECT (fragsort CXX)

##  List of files, excluding the main driver
SET (FRAGSORT_SRCS
  io.cpp
  main.cpp
  parameters.cpp
  quicksort.cpp
  radixsort.cpp
  random.cpp
  run.cpp
  accessors.cpp
  fragsort.cpp
  mutators.cpp
)


########################################
##  Get the Subversion revision
# FIND_PACKAGE (Subversion)
# if (Subversion_FOUND)
#   Subversion_WC_INFO (${CMAKE_CURRENT_SOURCE_DIR} ER)
#   SET (SUBVERSION_REVISION ${ER_WC_REVISION})
# endif (Subversion_FOUND)


########################################
##  Create configuration file

##  Configure a header file to pass some of the CMake settings
##  to the source code
CONFIGURE_FILE (
  "${PROJECT_SOURCE_DIR}/FragSortConfig.hpp.in"
  "${PROJECT_BINARY_DIR}/FragSortConfig.hpp"
  )

##  Add the binary tree to the search path so that
##  the configuration file can be found.
INCLUDE_DIRECTORIES ("${PROJECT_BINARY_DIR}")


########################################
##  Create the targets

##  Create the test executable
ADD_EXECUTABLE (fragsort ${FRAGSORT_SRCS})


########################################
##  Set initial compilation flags

##  Testing compilation flags, suggested by the Valgrind 3.3 book
# SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -fno-inline -O0 -Wall")
##  Release compilation flags, suggested by the Valgrind 3.3 book
SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

########################################
##  Set up for Boost

##  Set the module path to get the latest version of it
SET (CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src)

##  Set the root path for Boost from the environment variable
SET (BOOST_ROOT $ENV{BOOST_ROOT})
SET (Boost_NO_SYSTEM_PATHS true)
SET (Boost_USE_STATIC_LIBS   ON)
SET (Boost_USE_MULTITHREADED ON)
SET (Boost_USE_STATIC_RUNTIME OFF)
FIND_PACKAGE (Boost 1.42.0 REQUIRED COMPONENTS program_options)

if (Boost_FOUND)
  LINK_DIRECTORIES ( ${Boost_LIBRARY_DIRS} )
  INCLUDE_DIRECTORIES (${Boost_INCLUDE_DIRS})
  TARGET_LINK_LIBRARIES (fragsort ${Boost_LIBRARIES})
endif()


############################################################
##  Installation
############################################################

INSTALL (TARGETS fragsort DESTINATION fragsort/bin)


############################################################
##  CTest
############################################################

ENABLE_TESTING ()
ADD_TEST (NAME FragSort-ShowHelp COMMAND fragsort --help)


############################################################
##  CPack
############################################################

# INCLUDE (CPack)

