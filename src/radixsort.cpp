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
    \file radixsort.cpp
    Radix sort for class FragSort .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: radixsort.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <iomanip>

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Perform radix sort
/*!
     Radix sort using counting sort as a basis.
*/
void FragSort::radixSort () {
  unsigned int num_seqs = getNumFrags ();
  vector<unsigned int> acc;
  unsigned int k_count = 0;
  
  acc.resize (MAX_ASCII);

  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tk:" << getThresholdK () << endl;
  }

  //  Operate on position k of the sequences
  for (int k = getMaxK () - 1; k >= 0; k--) {
    k_count++;
    if (k_count > getThresholdK ()) {
      if (getDebug ()) {
        cerr << "--\tBreaking here!  " << k_count << "\t" << getThresholdK () << endl;
      }
      break;
    }

    if (getDebug ()) {
      cerr << "=====  " << k << "  =====" << endl;
//       cerr << "==  "  << k_count << " ==  " << getThresholdK () << "  ==" << endl;
    }
    //  Initialize the accumulator array
    for (unsigned int i = 0; i < MAX_ASCII; i++) {
      acc[i] = 0;
    }

    //  acc contains the frequency of each symbol; we can count sequences directly and
    //  skip the extra start_ptrs since there will be no difference in the order
    //  in which we count
    for (unsigned int i = 0; i < num_seqs; i++) {
      if (k >= static_cast<int> (frags[i].length ())) {
        acc[END_OF_STR]++;
      }
      else {
        acc[frags[i][k]]++;
      }
    }

    //  acc[i] contains the frequency of symbols <= i
    for (unsigned int i = 1; i < MAX_ASCII; i++) {
      acc[i] += acc[i - 1];
    }

    //  Must start from the end and move backwards or else counting sort does not work.
    for (int i = (num_seqs - 1); i >= 0; i--) {
      unsigned int orig_pos = start_ptrs[i];
      unsigned int tmp;
      if (k >= static_cast<int> (frags[start_ptrs[i]].length ())) {
        tmp = END_OF_STR;
      }
      else {
        tmp = frags[start_ptrs[i]][k];
      }
      unsigned int new_pos = acc[tmp] - 1;

//        cerr << "(" << tmp << ")" << endl;
//        cerr << "Put [" << seqs[start_ptrs[i]] << "] in position " << new_pos << endl;
      end_ptrs[new_pos] = orig_pos;
      acc[tmp]--;
    }

//     for (unsigned int i = 0; i < num_seqs; i++) {
//       cerr << start_ptrs[i] << "\t" << end_ptrs[i] << endl;
//     }

    //  Swap start_ptrs and end_ptrs
    start_ptrs.swap (end_ptrs);
  }

  return;
}
