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
    $Id: fragsort.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <climits>

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  Constructor that takes no arguments
FragSort::FragSort ()
  : debug_flag (false),
    verbose_flag (false),
    random_flag (false),
    reverse_flag (false),
    std_flag (false),
    radixsort_flag (false),
    qsort_flag (false),
    percent_flag (false),
    threshold_k (UINT_MAX),
    threshold_frags (UINT_MAX),
    input_fn (""),
    output_fn (""),
    ordering_fn (""),
    max_alphabet (MAX_ASCII),
    max_k (0),
    num_frags (0),
    qsort_assigned_count (0)
{
}
