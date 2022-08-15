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
    \file quicksort.cpp
    Quicksort for class FragSort .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: quicksort.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <iomanip>  //  setw
#include <time.h>  //  srand

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Perform quicksort
/*!
     Main function call for randomized quicksort with early termination
*/
void FragSort::quicksort () {
  unsigned int tmp_num_frags = getNumFrags ();
  unsigned int seed = time (NULL);
  int p = 0;
  int r = tmp_num_frags - 1;

  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tk:" << getThresholdK () << endl;
  }

  if (getThresholdK () == 0) {
    return;
  }

  //  Use the time to set the random seed
  srand (seed);
  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tRandom seed:" << seed << endl;
  }

  qsortHelper (p, r);

  return;
}


//!  Helper function for quicksort used for recursive calling.
/*!
     \param p Left boundary of area to sort
     \param r Right boundary of area to sort
*/
void FragSort::qsortHelper (int p, int r) {

  if (p < r) {
    int q = qsortPartition (p, r);

    if (getDebug ()) {
      cerr << "\tFinalizing pivot at position " << q << " (" << frags[start_ptrs[q]] << ")" << endl;
    }
      
    qsort_assigned_count++;
    if (qsort_assigned_count >= getThresholdFrags ()) {
      return;
    }
    
    qsortHelper (p, q - 1);
    qsortHelper (q + 1, r);
  }
  else {
    if (getDebug ()) {
      cerr << "\tAlready finalized pivot at position " << p << " (" << frags[start_ptrs[p]] << ")" << endl;
    }
    qsort_assigned_count++;
    if (qsort_assigned_count >= getThresholdFrags ()) {
      return;
    }
  }
}


//!  Main partitioning function quicksort.
/*!
     \param p Left boundary of area to sort
     \param r Right boundary of area to sort
*/
int FragSort::qsortPartition (int p, int r) {
  int pivot = 0;
  int i = p - 1;  //  Starts off before the array, so needs to be a signed int
  int rand_pos = -1;

  //  Select a random position between p and r to use as the pivot
  int diff = r - p;
  if (diff > 3) {
    rand_pos = (rand () % diff) + p; 
    swap (start_ptrs[r], start_ptrs[rand_pos]);
  }
  pivot = start_ptrs[r];
  if (getDebug ()) {
    cerr << "Selected " << rand_pos << " between " << p << " and " << r << "." << endl;
  }
  
//   cerr << "Pivot is:  " << seqs[pivot] << " at position " << r << " or " << start_ptrs[r] << endl;
  for (int j = p; j <= (r - 1); j++) {
    if (frags[start_ptrs[j]] <= frags[pivot]) {
      i++;
//       cerr << "\tSwapping " << seqs[start_ptrs[i]] << " with " << seqs[start_ptrs[j]] << endl;
      swap (start_ptrs[i], start_ptrs[j]);
    }
  }
//   cerr << "\tFinal swapping " << seqs[start_ptrs[i + 1]] << " with " << seqs[start_ptrs[r]] << endl;
  swap (start_ptrs[i + 1], start_ptrs[r]);

  return (i + 1);
}

