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
    \file parameters.cpp
    Member functions of FragSort for checking parameters .
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: parameters.cpp 52 2013-09-05 15:34:45Z rwan $

*/
/*******************************************************************/

#include <fstream>
#include <iostream>
#include <iomanip>  //  setw
#include <cmath>  //  floor
#include <climits>  //  UINT_MAX

#include <boost/program_options.hpp>

using namespace std;
using namespace boost;
namespace po = boost::program_options;

//  Pull the configuration file in
#include "FragSortConfig.hpp"

#include "fragsort-defn.hpp"
#include "fragsort.hpp"
#include "parameters.hpp"


//!  Function to perform rounding given a percent and a total
/*!
     A 0.5 is added to ensure that flooring rounds correctly.
     This function only used in this file.
*/
unsigned int round (unsigned int percent, unsigned int total) {
  return (static_cast<unsigned int>((floor ((static_cast<double>(percent) / static_cast<double>(100) * static_cast<double>(total)) + 0.5))));
}


//!  Process options from the command line and the configuration file CFG_FILENAME
/*!
     This function makes use of Boost's program_options for handling
     arguments on the command line and in options in a configuration
     file whose format resembles .ini files.

     Initially, boolean and enumerated values are given default values.
     Then, the available options are set up, with default values for
     string and numeric types.  The description of the options are
     recorded.

     Next, the command line options are read, followed by the configuration
     file options.  The command line options take priority over the
     configuration file ones.  Then, the options are processed, one-by-one.

     All of this is encapsulated within a try...catch block.
*/
bool FragSort::processOptions (int argc, char *argv[]) {
  try {
    //  Options that are allowed only on the command line
    po::options_description program_only ("Program options");
    program_only.add_options()
      ("version,v", "Print version")
      ("help,h", "This help message")
      ;

    //  Options that are allowed on the command line and in the configuration file
    po::options_description config ("Configuration");
    config.add_options()
      ("debug", "Turn debugging on.")
      ("verbose", "Turn verbose output on.")
      ("random", "Randomize the input.")
      ("reverse", "Sort the input in reverse.")
//       ("std", "Apply standard C++ sort.")
      ("radixsort", "Apply radixsort.")
      ("quicksort", "Apply quicksort.")
      ("percent", "The value specified with --k or --frags is a percent.")

      ("k", po::value<unsigned int>(), "Set the threshold for k.")
      ("frags", po::value<unsigned int>(), "Set the threshold for number of sequence fragments.")
      ("output", po::value<string>(), "Output filename.")
      ("ordering", po::value<string>(), "Output the final ordering as a binary file.")
      ;

    //  Hidden options that are allowed on both the command line and the configuration
    //  file, but will be hidden from the user
    po::options_description hidden ("Hidden options");
    hidden.add_options()
      ("input", po::value<string>(), "Input filename")
      ;

    po::options_description cmdline_options;
    cmdline_options.add (program_only).add (config).add (hidden);

    po::options_description config_file_options;
    config_file_options.add (config).add (hidden);

    po::options_description visible ("Allowed options");
    visible.add (program_only).add (config);

    po::positional_options_description p;
    p.add ("input", -1);

    po::variables_map vm;
    store (po::command_line_parser (argc, argv).options (cmdline_options).positional(p).run (), vm);

    if (vm.count ("version")) {
      cout << "FragSort version " << FragSort_VERSION_MAJOR << "." << FragSort_VERSION_MINOR << "." << SVN_REVISION << ":  " << __DATE__ <<  " (" << __TIME__ << ")" << endl;
      return false;
    }

    if (vm.count ("help")) {
      cout << visible << endl;
      cout << "Input file must be provided without any flags." << endl;
      cout << "* indicates default values." << endl;
      return false;
    }

    //  Handle the configuration file
    ifstream cfg_fp (CFG_FILENAME, ios::in);
    if (cfg_fp) {
      cerr << "==\tReading from configuration file " << CFG_FILENAME << "." << endl;
      store (parse_config_file (cfg_fp, config_file_options), vm);
      notify (vm);
    }

    //  Booleans
    if (vm.count ("debug")) {
      setDebug (true);
    }

    if (vm.count ("verbose")) {
      setVerbose (true);
    }

    if (vm.count ("random")) {
      setRandom (true);
    }

    if (vm.count ("reverse")) {
      setReverse (true);
    }

//     if (vm.count ("std")) {
//       setStd (true);
//     }

    if (vm.count ("radixsort")) {
      setRadixsort (true);
    }

    if (vm.count ("quicksort")) {
      setQuicksort (true);
    }

    if (vm.count ("percent")) {
      setPercent (true);
    }

//  Unsigned integers
    if (vm.count ("k")) {
      setThresholdK (vm["k"].as<unsigned int>());
    }

    if (vm.count ("frags")) {
      setThresholdFrags (vm["frags"].as<unsigned int>());
    }

//  Filenames
    if (vm.count ("input")) {
      setInputfn (vm["input"].as<string>());
    }

    if (vm.count ("output")) {
      setOutputfn (vm["output"].as<string>());
    }

    if (vm.count ("ordering")) {
      setOrderingfn (vm["ordering"].as<string>());
    }
  }
  catch (std::exception& e) {
    cout << e.what() << "\n";
    return false;
  }

  return true;
}


//!  Check the settings to ensure they are valid.
/*!
*/
bool FragSort::checkSettings () {
  //  Check settings
  if ((getRandom ()) && (getReverse ())) {
    cerr << "==\tError:  Both --random and --reverse given." << endl;
    return false;
  }

  unsigned int opt_count = 0;
  if (getRadixsort ()) {
    opt_count++;
  }
  if (getQuicksort ()) {
    opt_count++;
  }
  if (getRandom ()) {
    opt_count++;
  }
  if (opt_count != 1) {
    cerr << "==\tError:  Only one of --radixsort, --quicksort, and --random is acceptable." << endl;
    return false;
  }

  //  Summarize the settings that were selected
  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tDebug mode:" << (getDebug () == 1 ? "Yes" : "No") << endl;
    cerr << left << setw (VERBOSE_WIDTH) << "==\tReverse mode:" << (getReverse () == 1 ? "Yes" : "No") << endl;
//     cerr << left << setw (VERBOSE_WIDTH) << "==\tStandard sort:" << (getStd () == 1 ? "Yes" : "No") << endl;
    cerr << left << setw (VERBOSE_WIDTH) << "==\tRadix sort:" << (getRadixsort () == 1 ? "Yes" : "No") << endl;
    cerr << left << setw (VERBOSE_WIDTH) << "==\tQuicksort:" << (getQuicksort () == 1 ? "Yes" : "No") << endl;
    cerr << left << setw (VERBOSE_WIDTH) << "==\tRandom mode:" << (getRandom () == 1 ? "Yes" : "No") << endl;

    cerr << left << setw (VERBOSE_WIDTH) << "==\tPercent:" << (getPercent () == 1 ? "Yes" : "No") << endl;

    cerr << left << setw (VERBOSE_WIDTH) << "==\tk threshold:";
    if (getThresholdK () != UINT_MAX) {
      cerr << getThresholdK () << endl;
    }
    else {
      cerr << "N/A" << endl;
    }

    cerr << left << setw (VERBOSE_WIDTH) << "==\tsequence fragments threshold:";
    if (getThresholdFrags () != UINT_MAX) {
      cerr << getThresholdFrags () << endl;
    }
    else {
      cerr << "N/A" << endl;
    }

    cerr << left << setw (VERBOSE_WIDTH) << "==\tInput filename:";
    if (getInputfn ().length () != 0) {
      cerr << getInputfn () << endl;
    }
    else {
      cerr << "STDIN" << endl;
    }

    cerr << left << setw (VERBOSE_WIDTH) << "==\tOutput filename:";
    if (getOutputfn ().length () != 0) {
      cerr << getOutputfn () << endl;
    }
    else {
      cerr << "STDOUT" << endl;
    }

    cerr << left << setw (VERBOSE_WIDTH) << "==\tOrdering output filename:";
    if (getOrderingfn ().length () != 0) {
      cerr << getOrderingfn () << endl;
    }
    else {
      cerr << "N/A" << endl;
    }
  }

  return true;
}


//!  Finalize the thresholds.
/*!
     Check if the thresholds are percents or are out of bounds.
*/
void FragSort::finalizeThresholds () {
  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tWidth of sequences:" << getMaxK () << endl;
    cerr << left << setw (VERBOSE_WIDTH) << "==\tNumber of sequence fragments:" << getNumFrags () << endl;
  }

  //  If the value to --k or --frags is a percent
  if (getPercent ()) {
    if (getThresholdK () != UINT_MAX) {
      if ((getThresholdK () > 0) && (getThresholdK () < 100)) {
        setThresholdK (round (getThresholdK (), getMaxK ()));
      }
      else if (getThresholdK () >= 100) {
        setThresholdK (UINT_MAX);
      }
      else {
        cerr << "==\tThe k threshold provided is an invalid percentage!" << endl;
        exit (1);
      }
    }

    if (getThresholdFrags () != UINT_MAX) {
      if ((getThresholdFrags () > 0) && (getThresholdFrags () < 100)) {
        setThresholdFrags (round (getThresholdFrags (), getNumFrags ()));
      }
      else if (getThresholdFrags () >= 100) {
        setThresholdFrags (UINT_MAX);
      }
      else {
        cerr << "EE\tThe sequence fragments threshold provided is an invalid percentage!" << endl;
        exit (1);
      }
    }
  }
  else {
    if (getThresholdK () > getMaxK ()) {
      setThresholdK (UINT_MAX);
    }

    if (getThresholdFrags () > getNumFrags ()) {
      setThresholdFrags (UINT_MAX);
    }
  }

  if (getVerbose ()) {
    cerr << left << setw (VERBOSE_WIDTH) << "==\tFinal k threshold:";
    if (getThresholdK () != UINT_MAX) {
      cerr << getThresholdK () << endl;
    }
    else {
      cerr << "N/A" << endl;
    }

    cerr << left << setw (VERBOSE_WIDTH) << "==\tFinal sequence fragments threshold:";
    if (getThresholdFrags () != UINT_MAX) {
      cerr << getThresholdFrags () << endl;
    }
    else {
      cerr << "N/A" << endl;
    }
  }

  return;
}

