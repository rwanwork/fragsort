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
    \file io.cpp
    Input/output functions for class FragSort .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: io.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <cstdlib>

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Read in the sequences from file
/*!
     After reading in the sequences, the variables num_seqs and max_k are
     set.  The vectors start_ptrs and end_ptrs are also initialized.

     Since the value for max_k is known after reading in the file, the
     user parameter threshold_k can be finally validated here.
*/
void FragSort::readInFile () {
  unsigned int len = 0;  //  Length of the sequence
  unsigned int num_seqs = 0;
  string tmp;

  ifstream fp (getInputfn ().c_str (), ios::in);

  //  Read in the sequences, a line at a time
  while (getline (fp, tmp)) {
    if (tmp.length () > len) {
      len = tmp.length ();
    }
    frags.push_back (tmp);
    start_ptrs.push_back (num_seqs);
    num_seqs++;
  }
  fp.close ();

  //  Initialize the end_ptrs array
  for (unsigned int i = 0; i < num_seqs; i++) {
    end_ptrs.push_back (0);
  }

  setNumFrags (num_seqs);
  setMaxK (len);

  return;
}


//!  Read in the sequences from stdin
/*!
     After reading in the seqs, the variables num_seqs and max_k are
     set.  The vectors start_ptrs and end_ptrs are also initialized.

     Since the value for max_k is known after reading in the file, the
     user parameter threshold_k can be finally validated here.
*/
void FragSort::readInStd () {
  unsigned int len = 0;  //  Length of the sequence
  unsigned int tmp_num_frags = 0;
  string tmp;

  //  Read in the seqs
  while (cin >> tmp) {
    if (tmp.length () > len) {
      len = tmp.length ();
    }
    frags.push_back (tmp);
    start_ptrs.push_back (tmp_num_frags);
    tmp_num_frags++;
  }

  //  Initialize the end_ptrs array
  for (unsigned int i = 0; i < tmp_num_frags; i++) {
    end_ptrs.push_back (0);
  }

  setNumFrags (tmp_num_frags);
  setMaxK (len);

  return;
}


//!  Write out the sequences to file
/*!
     Need to handle two cases:
       1)  Reversal requested
       2)  Neither comparison used nor reversal requested (straight-forward radix sort)

     The reason is that reversal starts from the end of the array.  Comparison sort has
     changed the seqs array so that it should be printed as-is without the extra
     indirection to start_ptrs.
*/
void FragSort::writeOutFile () {
  int i = 0;

  ofstream fp (getOutputfn ().c_str (), ios::out);

//   if (getReverse () && getStd ()) {
//     for (i = getNumSeqs (); i >= 0; i--) {
//       fp << seqs[i] << endl;
//     }
//   }
//   else if (getStd ()) {
//     for (i = 0; i < (int) getNumSeqs (); i++) {
//       fp << seqs[i] << endl;
//     }
//   }
//   else
  if (getReverse ()) {
    for (i = getNumFrags (); i >= 0; i--) {
      fp << frags[start_ptrs[i]] << endl;
    }
  }
  else {
    for (i = 0; i < (int) getNumFrags (); i++) {
      fp << frags[start_ptrs[i]] << endl;
    }
  }

  fp.close ();

  return;
}


//!  Write out the sequences to stdout
/*!
     See note about two cases in the function FragSort::writeOutfile ()
*/
void FragSort::writeOutStd () {
  int i = 0;

//   if (getReverse () && getStd ()) {
//     for (i = getNumSeqs () - 1; i >= 0; i--) {
//       cout << seqs[i] << endl;
//     }
//   }
//   else if (getStd ()) {
//     for (i = 0; i < (int) getNumSeqs (); i++) {
//       cout << seqs[i] << endl;
//     }
//   }
//   else 
  if (getReverse ()) {
    for (i = getNumFrags () - 1; i >= 0; i--) {
      cout << frags[start_ptrs[i]] << endl;
    }
  }
  else {
    for (i = 0; i < (int) getNumFrags (); i++) {
      cout << frags[start_ptrs[i]] << endl;
    }
  }

  return;
}


//!  Write the ordering to file in binary
/*!
*/
void FragSort::writeOrdering () {
  vector<unsigned int> tmp;
  ofstream fp (getOrderingfn ().c_str (), ios::out | ios::binary);

  if (getReverse ()) {
    //  Reversed output was requested; we have to reverse start_ptrs
    //  Copying to tmp first and then perform an fp.write; alternative
    //    is to fp.write each value from the end...
    unsigned int i = 0;
    tmp.resize (getNumFrags ());
    vector<unsigned int>::reverse_iterator ptr;
    for (ptr = start_ptrs.rbegin (); ptr < start_ptrs.rend (); ptr++) {
      tmp[i] = *ptr;
      i++;
    }
    fp.write ((char*)&*(tmp.begin()), start_ptrs.size() * sizeof (unsigned int));
  }
  else {
    fp.write ((char*)&*(start_ptrs.begin()), start_ptrs.size() * sizeof (unsigned int));
  }

  fp.close ();

  return;
}
