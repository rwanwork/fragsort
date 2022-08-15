/*******************************************************************/
//  FragSort (Fragment Sorting for Next Generation Sequence Data)
//  Copyright (C) 2010  by Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////

/*******************************************************************/
/*!
    \file fragsort-defn.hpp
    Global definitions not part of any class.
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: fragsort-defn.hpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

//!  Spacing for aligning the verbose output (in characters).
#define VERBOSE_WIDTH 40

//!  Name of configuration file
#define CFG_FILENAME "fragsort.cfg"

//!  Null pointer, in the C++0x standard but not yet
#define nullptr 0

//!  Maximum size of the alphabet is ASCII
#define MAX_ASCII 256

//!  Special symbol to mark the end of string (i.e., if the string is shorter)
//!  NULL character (0) should be safe...
#define END_OF_STR 0

