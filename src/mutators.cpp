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
    \file mutators.cpp
    Mutating member functions for FragSort class definition .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: mutators.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Set whether or not debugging output is required
void FragSort::setDebug (bool arg) {
  debug_flag = arg;
}

//!  Set whether or not verbose output is required
void FragSort::setVerbose (bool arg) {
  verbose_flag = arg;
}

//!  Set if output should be randomized
void FragSort::setRandom (bool arg) {
  random_flag = arg;
}

//!  Set if output should be sorted in reverse order
void FragSort::setReverse (bool arg) {
  reverse_flag = arg;
}

//!  Set the standard sort setting
// void FragSort::setStd (bool arg) {
//   std_flag = arg;
// }

//!  Set the radixsort setting
void FragSort::setRadixsort (bool arg) {
  radixsort_flag = arg;
}

//!  Set the quicksort setting
void FragSort::setQuicksort (bool arg) {
  qsort_flag = arg;
}

//!  Set the percent setting
void FragSort::setPercent (bool arg) {
  percent_flag = arg;
}

//!  Set the threshold k value
void FragSort::setThresholdK (unsigned int arg) {
  threshold_k = arg;
}

//!  Set the threshold sequence fragments value
void FragSort::setThresholdFrags (unsigned int arg) {
  threshold_frags = arg;
}

//!  Set the input filename
void FragSort::setInputfn (string arg) {
  input_fn = arg;
}

//!  Set the output filename
void FragSort::setOutputfn (string arg) {
  output_fn = arg;
}

//!  Set the filename for the ordering of the entries
void FragSort::setOrderingfn (string arg) {
  ordering_fn = arg;
}

//!  Set the value of the maximum symbol
void FragSort::setMaxAlphabet (unsigned int arg) {
  max_alphabet = arg;
}

//!  Set the maximum k value
void FragSort::setMaxK (unsigned int arg) {
  max_k = arg;
}

//!  Set the number of sequence fragments
void FragSort::setNumFrags (unsigned int arg) {
  num_frags = arg;
}

