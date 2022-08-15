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
    \file fragsort.cpp
    Miscellaneous member functions for FragSort class definition .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: random.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <time.h>
#include <iomanip>  //  setw

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Randomly permute the sequences
/*!
     The current time is used to set the random seed.
*/
void FragSort::random () {
  unsigned int tmp_num_frags = getNumFrags ();
  unsigned int pos = 0;
  unsigned int seed = time (NULL);
  
  //  Use the time to set the random seed
  srand (seed);
  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tRandom seed:" << seed << endl;
  }
  
  for (unsigned int i = 0; i < tmp_num_frags; i++) {
    do {
      // Select a position from [0, num_seqs)
      pos = rand () % tmp_num_frags;
    } while (end_ptrs[pos] != 0);

    end_ptrs[pos] = 1;  //  Mark position in end_ptrs as used
    start_ptrs[i] = pos;
  }

  return;
}

