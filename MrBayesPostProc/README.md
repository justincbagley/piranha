# MrBayesPostProc

THIS SCRIPT runs a simple program for post-processing results of a MrBayes v3.2+ (Ronquist et al. 2012) run, whose output files are present in the current working directory (pwd). This script prepares the output files in pwd, and then summarizes trees and their posterior probabilities (using the 'sumt' command), and parameters of the specified model (using the 'sump' command) using MrBayes. Options are provided for specifying the burnin fraction, and for calling stepping-stone (SS) analysis (Xie et al. 2011; Baele et al. 2012) to robustly estimate the log marginal likelihood of the model/analysis, whose details must be provided in a MrBayes block at the end of the input NEXUS file in the current working directory.

## USAGE

Use the -h flag to access the help text for the program, which defines and describes each of the options. The current help text reads as follows:

```
Usage: MrBayesPostProc.sh [Help: -h help] [Options: -b s g d t] workingDir 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -b   relBurninFrac (def: 0.25) fraction of trees to discard as 'burn-in'
  -s   SS (def: 0, no stepping-stone (SS) analysis conducted; 1, run SS analysis) allows
       calling stepping-stone analysis starting from NEXUS in current working dir
  -g   SSnGen (def: 250000) if 1 for SS above, allows specifying the number of total 
       SS sampling iterations (uses default number of steps, 50; total iterations will 
       be split over 50 steps) 
  -d   SSDiagFreq (def: 2500) if 1 for SS above, this specifies the diagnosis 
       (logging) frequency for parameters during SS analysis, in number of generations
  -t   deleteTemp (def: 1, delete temporary files; 0, do not delete temporary files) calling
       0 will keep temporary files created during the run for later inspection 

 OVERVIEW
 Runs a simple script for post-processing results of a MrBayes v3.2+ (Ronquist et al. 2012)
 run, whose output files are assumed to be in the current working directory. This script preps 
 the output files in pwd, and then summarizes trees and their posterior probabilities (sumt), 
 and parameters of the specified model (sump) using MrBayes. Options are provided for specifying 
 the burnin fraction, and for calling stepping-stone analysis (Xie et al. 2011; Baele et al.
 2012) to robustly estimate the log marginal likelihood of the model/analysis, whose details 
 must be provided in a MrBayes block at the end of the input NEXUS file in the current dir.

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<http://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Baele G, Lemey P, Bedford T, Rambaut A, Suchard MA, Alekseyenko AV (2012) Improving the 
    accuracy of demographic and molecular clock model comparison while accommodating 
    phylogenetic uncertainty. Molecular Biology and Evolution, 29, 2157-2167.
 Ronquist F, Teslenko M, van der Mark P, Ayres D, Darling A, et al. (2012) MrBayes v. 3.2: 
    efficient Bayesian phylogenetic inference and model choice across a large model space. 
    Systematic Biology, 61, 539-542. 
 Xie W, Lewis PO, Fan Y, Kuo L, Chen MH (2011) Improving marginal likelihood estimation for 
    Bayesian phylogenetic model selection. Systematic Biology, 60, 150-160.

```

A 'basic' MrBayesPostProc run summarizes output of a given MrBayes run (folder) using default burnin fractions and other settings, and is called as follows:

```
$ cp ./MrBayesPostProc.sh /path/to/MrBayes/analysis/folder
$ cd /path/to/MrBayes/analysis/folder
$ chmod u+x ./*.sh
$ ./MrBayesPostProc.sh .
```

Stepping-stone sampling can be specified by passing the -s, -g, and -d flags to MrBayesPostProc. As an example, you might call an SS analysis with half a million SS iterations, while logging parameters to file every 5000 steps, like this:

```
$ cp ./MrBayesPostProc.sh /path/to/MrBayes/analysis/folder
$ cd /path/to/MrBayes/analysis/folder
$ chmod u+x ./*.sh
$ ./MrBayesPostProc.sh -s1 -g500000 -d5000 .
```


## OUTPUT

Below is an example of output to screen during a recent basic MrBayesPostProc run on a supercomputing cluster, which called no option flags. The analysis took 1 second.

```
$ ./MrBayesPostProc.sh

##########################################################################################
#                          MrBayesPostProc v1.4, December 2017                           #
##########################################################################################
INFO      | Sat Dec  2 11:52:28 MST 2017 | STEP #1: SETUP VARIABLES. 
INFO      | Sat Dec  2 11:52:28 MST 2017 |          Fixing NEXUS filename... 
INFO      | Sat Dec  2 11:52:28 MST 2017 | STEP #2: REMOVE MRBAYES BLOCK FROM NEXUS FILE. 
INFO      | Sat Dec  2 11:52:28 MST 2017 | STEP #3: CREATE BATCH FILE TO RUN IN MRBAYES. 
INFO      | Sat Dec  2 11:52:28 MST 2017 |          Making batch file... 
INFO      | Sat Dec  2 11:52:28 MST 2017 |          MrBayes batch file (batch.txt) successfully created. 
INFO      | Sat Dec  2 11:52:28 MST 2017 | STEP #4: SUMMARIZE RUN AND COMPUTE CONSENSUS TREE IN MRBAYES. 
INFO      | Sat Dec  2 11:52:28 MST 2017 | STEP #5: CLEANUP FILES. 
INFO      | Sat Dec  2 11:52:28 MST 2017 | Done with post-processing of MrBayes results using MrBayesPostProc. 
INFO      | Sat Dec  2 11:52:28 MST 2017 | Bye. 
```


## REFERENCES

- Baele G, Lemey P, Bedford T, Rambaut A, Suchard MA, Alekseyenko AV (2012) Improving the accuracy of demographic and molecular clock model comparison while accommodating phylogenetic uncertainty. Molecular Biology and Evolution, 29, 2157-2167.
- Ronquist F, Teslenko M, van der Mark P, Ayres D, Darling A, et al. (2012) MrBayes v. 3.2: efficient Bayesian phylogenetic inference and model choice across a large model space. Systematic Biology, 61, 539-542. 
- Xie W, Lewis PO, Fan Y, Kuo L, Chen MH (2011) Improving marginal likelihood estimation for Bayesian phylogenetic model selection. Systematic Biology, 60, 150-160.

December 2, 2017
Justin C. Bagley, Richmond, VA, USA
