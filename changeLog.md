# PIrANHA Change Log

## PIrANHA v0.1.7 (official minor version release) - February 19, 2019
- **February 19 2019:** Improved ```phylipSubsampler.sh``` to check and account for differences in machine type. Now correctly accommodations UNIX (Mac) and LINUX systems.
- **February 19 2019:** Updated MAGNET script by adding a getBipartTrees function to the MAGNET pipeline, which organizes RAxML bipartitions trees for each locus (= best ML trees with bootstrap proportions along nodes the corresponding bootstrap searches search; resulting from ```-f a -x```options, which are included in all MAGNET calls to RAxML). Edited header and script banner to be prepped for future official release of MAGNET with versioning 0.1.9.
- **December 2018:** Added new MAGNET script updated to include --resume option, and to set raxml executable name one of two ways after detecting machine type (```raxml``` on Mac, ```raxmlHPC-SS3``` on Linux/supercomputer).
- **November 25 2018:** Added to MAGNET/shell folder a new 'RAxMLRunChecker.sh' script v1.0, which counts the number of completed RAxML runs during the course of, or after, a MAGNET pipeline run, and also collates information on the dataset (e.g. number of patterns) and run (e.g. run time, optimum likelihood) for each locus/partition.
- **November 20 2018 bug fix:** Updated MAGNET with edited 'MAGNET.sh' (now v0.1.7+) and 'NEXUS2gphocs.sh' (now v1.3+) scripts containing an important bug fix and some new code checking for whether the NEXUS to fasta file conversion succeeded.
- **November 2018:** Rewrote 'pyRAD2PartitionFinder.sh' script, adding several options including options for choosing the PartitionFinder path and version, model set, model selection parameter (BIC, AIC, or AICc default), and whether or not to run PartitionFinder (or just create the input files). This new pyRAD2PartitionFinder script supersedes the old 'Super-pyRAD2PartitionFinder.sh' script that was previously included for use on HPC supercomputer clusters, which has now been removed from the repo. The new script has been tested on mac/UNIX and Linux (CentOS 6).
- **June 2018:** Created 'snapp_runner.cfg' example configuration file for SNAPPRunner.
- **August 2018:** Created 'runSpeciesIdentifier.sh' script for running SpeciesIdentifier DNA barcoding software on supercomputer.
- **May 2018:** Updated 'BEASTReset.sh' and 'fastSTRUCTURE.sh' scripts.
- **October 2017:** Added 'dadiUncertainty.sh', a pipeline program and ∂a∂i wrapper that automates running uncertainty analysis on a ∂a∂i demographic model, using either the Godambe Information Matrix (GIM) or Fisher Information Matrix (FIM), to estimate standard deviations for calculating 95% CIs for model parameter estimates.
- **September 2017:** Added 'vcfSubsampler.sh', a utility script that uses a list file to subsample a .vcf file so that it only contains SNPs in the list.
- **September 2017:** Added 'phylipSubsampler.sh', a utility script that automates subsampling one or multiple Phylip alignments down to one sequence per population/species (assuming no missing data).
- **September 2017:** Updated README. A specific fix to the README is giving an updated DOI in the Zenodo badge (DOI section). Another fix was switching the DOI in example citations to a Zenodo DOI that applies to all versions; the new DOI will always resolve to the latest release tracked by Zenodo.
- **bug fix:** - phylipSubsampler.sh (fixes bug causing incorrect number of characters on first line of input files) 


## PIrANHA v0.1.6.1 (official minor version release) - September 13, 2017
- **August 2017:** Made several updates to README and documentation for the repository.


## PIrANHA v0.1.6 (official minor version release) - September 13, 2017
- **August 2017:** + updated all README files in the repository (for PIrANHA, BEASTPostProc, BEASTRunner, ExaBayesPostProc, MLEResultsProc, and fastSTRUCTURE scripts).
- **August 2017:** + added new 'BEASTReset.sh' script, and corresponding README, into BEASTReset sub-folder. This script automates re-setting random starting number seeds in BEAST run submission scripts for supercomputer runs. This is a time-saving script when many failed runs need to be restarted from a different seed!
- **bug fix:** - MLEResultsProc.sh (expands capability of detecting and accounting for PS/SS runs conducted in different versions of BEAST, i.e. v1 vs. v2) 
- **bug fix:** - PFSubsetSum.sh (fixes incorrect ordering of summary statistics) 
- **bug fix:** - PFSubsetSum.sh (fixed script so that it works with PartitionFinder v1 and v2; last testing: v2.1.1) 


## PIrANHA v0.1.5 (official minor version release) - August 21, 2017
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


## PIrANHA v0.1.4 (modified minor version release - several changes after official v0.1.4 release)
The current, modified PIrANHA v0.1.4 release contains several goodies listed below, in addition to minor improvements in the code!!
- **August 2017:** + updated 'BEAST\_PSPrepper.sh' script automating editing existing BEAST v2+ (e.g. v2.4.5) input XML files for path sampling analysis, so that users don't have to do this by hand!
- **May 2017:** + added 'SNAPPRunner.sh' script for conducting multiple runs of SNAPP ("SNP and AFLP Phylogenies") model in BEAST.
- **May 2017:** + added options to 'MrBayesPostProc.sh' script for specifying relative burnin fraction (during sump and sumt), as well as calling stepping-stone sampling estimation of the log-marginal likelihood of the model.
- **May 2017:** + added new 'MrBayesPostProc.sh' script that summarizes the posterior distribution of trees and parameters from a single MrBayes run. Script picks up filenames from contents of run dir, and uses default burnin fraction of 0.25 during analyses.
- **May 2017:** + build now contains new 'BEASTRunner.sh' script and 'beast\_runner.cfg' configuration file. BEASTRunner now has options to allow specifying 1) number of runs, 2) walltime, and 3) Java memory allocation per run, as well as calling reg or verbose help documentation from the command line.
- **April 2017:** + build now contains new 'pyRADLocusVarSites.sh' script (with example run folder) that calculates numbers of variable sites (i.e. segregating sites, S) and parsimony-informative sites (PIS; i.e. hence with utility for phylogenetic analysis) in each SNP locus contained in .loci file from a pyRAD assembly run.
- **April 2017:** + I added new 'dadiRunner.sh' script that automates transferring and queuing multiple runs of dadi input files on a remote supercomputer (similar to BEASTRunner and RAxMLRunner scripts already in the repo).

I have also added a new 'MrBayesPostProc.sh' script and corresponding 'mrbayes_post_proc.cfg' configuration file, which together automate summarizing the posterior distribution of trees and parameters from a single MrBayes run. I intend to extend these scripts to provide options for several other anlayses of individual MrBayes runs/input files, as well as extend them to pulling down results from multiple MrBayes runs.


## PIrANHA v0.1.4 (official minor version release) - May 3, 2017
### What's new?
- **May 2017:** + build now contains new **BEASTRunner.sh** script and 'beast_runner.cfg' configuration file. BEASTRunner now has options to allow specifying 1) number of runs, 2) walltime, and 3) Java memory allocation per run, as well as calling reg or verbose help documentation from the command line.
- **April 2017:** + build now contains new **pyRADLocusVarSites.sh** script (with example run folder) that calculates numbers of variable sites (i.e. segregating sites, S) and parsimony-informative sites (PIS; i.e. hence with utility for phylogenetic analysis) in each SNP locus contained in .loci file from a pyRAD assembly run.
- **April 2017:** + I added new **dadiRunner.sh** script that automates transferring and queuing multiple runs of dadi input files on a remote supercomputer (similar to BEASTRunner and RAxMLRunner scripts already in the repo). *n.b.: A dadiPostProc.sh script is also in the works (but unreleased) that conducts post-processing and graphical plotting of results from multiple dadi runs*
- **January 2017:** + I added a new script called **BEAST_PSPrepper.sh** that, while not quite polished, automates editing any existing BEAST v2+ (e.g. v2.4.4) input XML files for path sampling analysis, so that users don't have to do this by hand!


## PIrANHA v0.1.3 (official minor version release) - November 11, 2016
### What's new?
This version of PIrANHA introduces the BEASTRunner.sh script for automating independent runs of BEAST1 or BEAST2 on a remote supercomputing cluster. See README for details.


## PIrANHA v0.1.2 (official minor version release) - November 10, 2016


## PIrANHA v0.1.1 (official minor version, patch release) - November 10, 2016


## PIrANHA v0.1.0 (pre-release version zero) - September 6, 2016
