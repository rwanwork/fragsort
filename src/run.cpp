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
    \file run.cpp
    Primary function for class FragSort .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: run.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <iomanip>  //  setw

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"
#include "run.hpp"

void FragSort::run () {
  //  Read in the data
  if (getInputfn ().length () == 0) {
    readInStd ();
  }
  else {
    readInFile ();
  }
  finalizeThresholds ();

  //  Decide whether to generate a random sequence, use a comparison sort, or perform a radix sort
  if (getRandom ()) {
    random ();
  }
//   else if (getStd ()) {
//     stdSort ();
//   }
  else if (getQuicksort ()) {
    quicksort ();
  }
  else if (getRadixsort ()) {
    radixSort ();
  }
  else {
    cerr << "==\tError:  No method specified!\n";
    exit (1);
  }

  //  Write out the final order of the sequence fragments
  if (getOutputfn ().length () == 0) {
    writeOutStd ();
  }
  else {
    writeOutFile ();
  }

  //  Check if the ordering of the sequence fragments should also be written out
  if (getOrderingfn ().length () > 0) {
    writeOrdering ();
  }

  return;
}

