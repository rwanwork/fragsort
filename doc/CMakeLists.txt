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
##  $Id: CMakeLists.txt 42 2010-12-27 08:24:30Z rwan $
############################################################
CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

########################################
##  Set up the software

##  Project name
PROJECT (fragsort CXX)


########################################
##  Create text version of README from README.html

ADD_CUSTOM_COMMAND(
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/README
  COMMAND /usr/bin/html2text -rcfile ${CMAKE_CURRENT_SOURCE_DIR}/html2textrc ${CMAKE_CURRENT_SOURCE_DIR}/README.html >${CMAKE_CURRENT_SOURCE_DIR}/README
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/README.html
  COMMENT "Creating README from README.html..." 
)

ADD_CUSTOM_TARGET (README ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/README)

