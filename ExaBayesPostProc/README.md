# ExaBayesPostProc

THIS SCRIPT aids post-processing of ExaBayes v1.4 (Aberer et al. 2014) output files by1) summarizing run, tree, and parameter characteristics, and 2) modifying ExaBayes tree files (i.e. with "topologies" in their filenames), summarizing the posterior distribution of trees, and computing a 50% majority-rule consensus tree with branch lengths and Bayesian posterior probabilities >=50% along the nodes, using MrBayes v3.2(Ronquist et al. 2011).

First, it is assumed that ExaBayes is installed locally and ExaBayes and the utility programs bundled with the ExaBayes distribution (in /.../exabayes-1.4.1/bin/bin/), including credibleSet, extractBips, and postProcParam, are in your path and thus areavailable from the command line interface. This code also assumes that MrBayes v3.2 is installed with the executable named "mb" and available from the command line. To ensure required software is available at the command line, either 1) add directories the executables are located in to your PATH environmental variable, or 2) copy them to an appropriate folder that is already located in your path, such as "/usr/local/bin" on macs. To do #1 on Mac/UNIX/LINUX systems, you can edit your .bash_profile file to include the ExaBayes and MrBayes bin folders. Alternatively, you could simply supply the absolute paths to all software programs listed in the script (not recommended).

For interpreting files output by this script, please refer to the ExaBayes and MrBayes manuals (PDFs) included in the manual or documentation folders of their distributions, as well as the papers cited below.

## REFERENCES

- Aberer AJ, Kobert K, Stamatakis A (2014) ExaBayes: Massively parallel Bayesian tree inference for the whole-genome era. Mol. Biol. Evol. 31(10): 2553-2556. doi: 10.1093/molbev/msu236.
- Ronquist F, Teslenko M, van der Mark P, Ayres D, Darling A, H¨ohna S, Larget B, Liu L, Suchard MA, Huelsenbeck JP (2011) MrBayes 3.2: Efficient Bayesian phylogenetic inference and model choice across a large model space. Systematic Biology.

August 23, 2017 Justin C. Bagley, Richmond, VA, USA
