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
    \file fragsort.hpp
    Class definition of FragSort
    \author Raymond Wan (r-wan@cb.k.u-tokyo.ac.jp)
    \par Organizations
          - Department of Computational Biology, Graduate School of
            Frontier Science, University of Tokyo
          - Computational Biology Research Center, AIST, Japan
    $Id: fragsort.hpp 38 2010-12-17 09:30:46Z rwan $

*/
/*******************************************************************/
#ifndef FRAGSORT_HPP
#define FRAGSORT_HPP

class FragSort {
  public:
    FragSort ();

    //  Functions related to parameters  [parameters.cpp]
    bool processOptions (int argc, char *argv[]);
    void initSettings ();
    bool checkSettings ();
    void finalizeThresholds ();

    //  Main function  [run.cpp]
    void run ();

    //  Accessors  [fragsort-accessors.cpp]
    bool getDebug () const;
    bool getVerbose () const;
    bool getRandom () const;
    bool getReverse () const;
//     bool getStd () const;
    bool getRadixsort () const;
    bool getQuicksort () const;
    bool getPercent () const;
    
    unsigned int getThresholdK () const;
    unsigned int getThresholdFrags () const;
    string getInputfn () const;
    string getOutputfn () const;
    string getOrderingfn () const;

    unsigned int getMaxAlphabet () const;
    unsigned int getMaxK () const;
    unsigned int getNumFrags () const;

    //  Mutators  [fragsort-mutators.cpp]
    void setDebug (bool arg);
    void setVerbose (bool arg);
    void setRandom (bool arg);
    void setReverse (bool arg);
//     void setStd (bool arg);
    void setRadixsort (bool arg);
    void setQuicksort (bool arg);
    void setPercent (bool arg);

    void setThresholdK (unsigned int arg);
    void setThresholdFrags (unsigned int arg);
    void setInputfn (string arg);
    void setOutputfn (string arg);
    void setOrderingfn (string arg);

    void setMaxAlphabet (unsigned int arg);
    void setMaxK (unsigned int arg);
    void setNumFrags (unsigned int arg);

    //  I/O  [io.cpp]
    void readInFile ();
    void readInStd ();
    void writeOutFile ();
    void writeOutStd ();
    void writeOrdering ();

    //  Randomization  [random.cpp]
    void random ();

    //  Radix Sort  [radixsort.cpp]
    void radixSort ();

    //  Quicksort  [quicksort.cpp]
    void quicksort ();
    void qsortHelper (int p, int r);
    int qsortPartition (int p, int r);

    //  Standard Sort  [stdsort.cpp]
//     void stdSort ();

  private:
    //!  Set to true if debug output is required; false otherwise
    bool debug_flag;
    //!  Set to true if verbose output is required; false otherwise
    bool verbose_flag;
    //!  Set to true to output sequences in random order
    bool random_flag;
    //!  Set to true to output sequences in reverse order
    bool reverse_flag;
    //!  Set to true if standard sort is used
    bool std_flag;
    //!  Set to true if radixsort is used
    bool radixsort_flag;
    //!  Set to true if quicksort is used
    bool qsort_flag;
    //!  Set to true if the values with --k or --frags is a percent
    bool percent_flag;
    
    //!  Threshold k value (radixsort only)
    unsigned int threshold_k;
    //!  Threshold on the number of sequence fragments (quicksort only)
    unsigned int threshold_frags;
    //!  Input filename
    string input_fn;
    //!  Output filename
    string output_fn;
    //!  Filename for printing the order of the entries
    string ordering_fn;

    //!  Alphabet size (value of the maximum symbol)
    unsigned int max_alphabet;
    //!  Maximum k value
    unsigned int max_k;
    //!  Number of sequence fragments
    unsigned int num_frags;
    //!  Number of positions assigned by quicksort; used for early termination
    unsigned int qsort_assigned_count;

    vector<unsigned int> start_ptrs;
    vector<unsigned int> end_ptrs;
    vector<string> frags;
};

#endif
