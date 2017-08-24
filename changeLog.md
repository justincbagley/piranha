# PIrANHA Change Log

## PIrANHA v0.1.5 (modified beta release - several changes after official 0.1.5 release)
- **August 2017:** + updated all README files in the repository (for PIrANHA, BEASTPostProc, BEASTRunner, ExaBayesPostProc, MLEResultsProc, and fastSTRUCTURE scripts).
- **August 2017:** + added new 'BEASTReset.sh' script, and corresponding README, into BEASTReset sub-folder. This script automates re-setting random starting number seeds in BEAST run submission scripts for supercomputer runs. This is a time-saving script when many failed runs need to be restarted from a different seed!

## PIrANHA v0.1.5 (official beta release) - August 21, 2017
The current release, PIrANHA v0.1.5, contains the following updates, in addition to minor improvements in the code:
- **August 2017:** + added a Change Log file ('changeLog.md') to supplement releases page and provide log file within master.
- **August 2017:** + updated MAGNET pipeline by editing 'MAGNET.sh' by adding three new command line options ("\-e", "\-m", and "\-o" flags), as follows:
  \-e   executable (def: raxmlHPC-SSE3) name of RAxML executable, accessible from command line
       on user's machine
  \-m   indivMissingData (def: 1=allowed; 0=removed)
  \-o   outgroup (def: NULL) outgroup given as single taxon name (tip label) or comma-
       separted list   
- **August 2017:** + updated MAGNET pipeline by adding getBootTrees.sh script, which collates and organizes bootstrap trees from all RAxML runs in sub-folders of a working directory, especially results of a MAGNET run. This is the standalone version of the script.  
- **August 2017:** + updated 'BEASTPostProc.sh'
- **August 2017:** + updated 'BEASTRunner.sh'
- **August 2017:** + updated 'BEAST\_PSPrepper.sh' script automating editing existing BEAST v2+ (e.g. v2.4.5) input XML files for path sampling analysis, so that users don't have to do this by hand!
- **bug fix:** - MAGNET.sh (unused code)
- **bug fix:** - getGeneTrees.sh (unused code)
- **bug fix:** - BEASTRunner.sh


## PIrANHA v0.1.4 (modified beta release - several changes after official 0.1.4 release)
The current, modified PIrANHA v0.1.4 release contains several goodies listed below, in addition to minor improvements in the code!!
- **August 2017:** + updated 'BEAST\_PSPrepper.sh' script automating editing existing BEAST v2+ (e.g. v2.4.5) input XML files for path sampling analysis, so that users don't have to do this by hand!
- **May 2017:** + added 'SNAPPRunner.sh' script for conducting multiple runs of SNAPP ("SNP and AFLP Phylogenies") model in BEAST.
- **May 2017:** + added options to 'MrBayesPostProc.sh' script for specifying relative burnin fraction (during sump and sumt), as well as calling stepping-stone sampling estimation of the log-marginal likelihood of the model.
- **May 2017:** + added new 'MrBayesPostProc.sh' script that summarizes the posterior distribution of trees and parameters from a single MrBayes run. Script picks up filenames from contents of run dir, and uses default burnin fraction of 0.25 during analyses.
- **May 2017:** + build now contains new 'BEASTRunner.sh' script and 'beast\_runner.cfg' configuration file. BEASTRunner now has options to allow specifying 1) number of runs, 2) walltime, and 3) Java memory allocation per run, as well as calling reg or verbose help documentation from the command line.
- **April 2017:** + build now contains new 'pyRADLocusVarSites.sh' script (with example run folder) that calculates numbers of variable sites (i.e. segregating sites, S) and parsimony-informative sites (PIS; i.e. hence with utility for phylogenetic analysis) in each SNP locus contained in .loci file from a pyRAD assembly run.
- **April 2017:** + I added new 'dadiRunner.sh' script that automates transferring and queuing multiple runs of dadi input files on a remote supercomputer (similar to BEASTRunner and RAxMLRunner scripts already in the repo).

I have also added a new 'MrBayesPostProc.sh' script and corresponding 'mrbayes_post_proc.cfg' configuration file, which together automate summarizing the posterior distribution of trees and parameters from a single MrBayes run. I intend to extend these scripts to provide options for several other anlayses of individual MrBayes runs/input files, as well as extend them to pulling down results from multiple MrBayes runs.


## PIrANHA v0.1.4 (official beta release) - May 3, 2017
### What's new?
- **May 2017:** + build now contains new **BEASTRunner.sh** script and 'beast_runner.cfg' configuration file. BEASTRunner now has options to allow specifying 1) number of runs, 2) walltime, and 3) Java memory allocation per run, as well as calling reg or verbose help documentation from the command line.
- **April 2017:** + build now contains new **pyRADLocusVarSites.sh** script (with example run folder) that calculates numbers of variable sites (i.e. segregating sites, S) and parsimony-informative sites (PIS; i.e. hence with utility for phylogenetic analysis) in each SNP locus contained in .loci file from a pyRAD assembly run.
- **April 2017:** + I added new **dadiRunner.sh** script that automates transferring and queuing multiple runs of dadi input files on a remote supercomputer (similar to BEASTRunner and RAxMLRunner scripts already in the repo). *n.b.: A dadiPostProc.sh script is also in the works (but unreleased) that conducts post-processing and graphical plotting of results from multiple dadi runs*
- **January 2017:** + I added a new script called **BEAST_PSPrepper.sh** that, while not quite polished, automates editing any existing BEAST v2+ (e.g. v2.4.4) input XML files for path sampling analysis, so that users don't have to do this by hand!


## PIrANHA v0.1.3 (official beta release) - November 11, 2016
### What's new?
This version of PIrANHA introduces the BEASTRunner.sh script for automating independent runs of BEAST1 or BEAST2 on a remote supercomputing cluster. See README for details.


## PIrANHA v0.1.2 (official beta release) - November 10, 2016


## PIrANHA v0.1.1 (official beta release) - November 10, 2016


## PIrANHA v0.1.0 (pre-release version zero) - September 6, 2016
