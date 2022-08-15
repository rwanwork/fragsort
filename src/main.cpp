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
    \file main.cpp
    This file contains the main () function for the FragSort software.
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: main.cpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/

#include <vector>
#include <string>
#include <cstdlib>
#include <iostream>

using namespace std;

#include "fragsort-defn.hpp"
#include "fragsort.hpp"

//!  The main () function of the program
/*!
     Create a FragSort object and then uses it to read in the parameters from
     the file and the command line.  If all the settings check out, then run
     the main program.
*/
int main (int argc, char *argv[]) {
  FragSort fragsort;

  //  Read the configuration file and then the command line parameters
  if (!fragsort.processOptions (argc, argv)) {
    return (EXIT_SUCCESS);
  }

  //  If the parameters check out, run it
  if (fragsort.checkSettings ()) {
    fragsort.run ();
  }

  return (EXIT_SUCCESS);
}

