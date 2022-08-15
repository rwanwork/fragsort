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
    \file accessors.cpp
    Accessing member functions for FragSort class definition .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: accessors.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Get the debug setting
bool FragSort::getDebug () const {
  return debug_flag;
}

//!  Get the verbose setting
bool FragSort::getVerbose () const {
  return verbose_flag;
}

//!  Get the random setting
bool FragSort::getRandom () const {
  return random_flag;
}

//!  Get the reverse setting
bool FragSort::getReverse () const {
  return reverse_flag;
}

//!  Get the standard sort setting
// bool FragSort::getStd () const {
//   return std_flag;
// }

//!  Get the radixsort setting
bool FragSort::getRadixsort () const {
  return radixsort_flag;
}

//!  Get the quicksort setting
bool FragSort::getQuicksort () const {
  return qsort_flag;
}

//!  Get the percent setting
bool FragSort::getPercent () const {
  return percent_flag;
}

//!  Get the threshold k value
unsigned int FragSort::getThresholdK () const {
  return threshold_k;
}

//!  Get the threshold seqs value
unsigned int FragSort::getThresholdFrags () const {
  return threshold_frags;
}

//!  Get the input filename
string FragSort::getInputfn () const {
  return input_fn;
}

//!  Get the output filename
string FragSort::getOutputfn () const {
  return output_fn;
}

//!  Get the filename for printing the ordering; an empty filename means such output is not needed
string FragSort::getOrderingfn () const {
  return ordering_fn;
}

//!  Get value of the maximum symbol
unsigned int FragSort::getMaxAlphabet () const {
  return max_alphabet;
}

//!  Get the maximum k value
unsigned int FragSort::getMaxK () const {
  return max_k;
}

//!  Get the number of sequence fragments
unsigned int FragSort::getNumFrags () const {
  return num_frags;
}


