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
    \file stdsort.cpp
    Standard sort for the class FragSort .

    Note that standard sort has been disabled indefinitely because it assumes
    the length of every sequence is the same.  This is a problem when
    we add numbers to the sequences to keep the sorting stable.  This source
    file is NOT linked into the final executable!
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: stdsort.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <iostream>
#include <iomanip>
#include <sstream>
#include <vector>
#include <string>
#include <algorithm>
#include <boost/lexical_cast.hpp>

using namespace std;
using boost::lexical_cast;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"


//!  Pad an integer with zeroes.
/*!
     Given an integer, pad it to the left with zeroes.  Implemented using a stringstream.
*/
string zeroPadNumber (unsigned int width, unsigned int num) {
  ostringstream ss;
  ss << setw (width) << setfill ('0') << num;

  return ss.str ();
}


//!  Determine the width of an integer
/*!
     Given an integer, count how many digits there are.
*/
unsigned int getWidth (unsigned int n) {
  unsigned int count = 0;

  while (n != 0) {
    n = n / 10;
    count++;
  }

  return count;
}


//!  Apply the C++ standard comparison sort
/*!
     Call to the standard C++ comparison sort.  Tags are modified prior
     to sorting by adding two string representations of its original position:
       1)  a padded integer and
       2)  a non-padded integer.

     The first value is used to keep the sort stable.  Left-padding the
     number ensures this.  The second value is extracted afterwards and added
     to start_ptrs.
*/
void FragSort::stdSort () {
  unsigned int max_k = getMaxK ();
  unsigned int tmp_num_frags = getNumFrags ();
  unsigned int width = getWidth (tmp_num_frags);

  //  Determine padding

  for (unsigned int i = 0; i < tmp_num_frags; i++) {
    frags[i] = frags[i] + zeroPadNumber (width, i) + lexical_cast<string> (i);
  }

  sort (frags.begin (), frags.end ());

  cerr << "Width is " << width << endl;
  cerr << "max_k is " << max_k << endl;

  //  Extract the numbers and put them in start_ptr
  for (unsigned int i = 0; i < tmp_num_frags; i++) {
//     cerr << "==\t" << tags[i].substr (max_k + width, width) << "\t" << tags[i] << endl;
    start_ptrs[i] = lexical_cast<unsigned int> (frags[i].substr (max_k + width, width));
    frags[i] = frags[i].substr (0, max_k);
  }

  return;
}

