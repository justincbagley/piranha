# PIrANHA Change Log

### PIrANHA v1.0 (official major version release #1) - TBA - _Coming soon! Join in on development and help us get there sooner!!_

...

<!-- ### Updates since last pre-release (for PIrANHA v0.4a3 draft): -->

-  **December 11, 2020:** Made various minor fixes to code, READMEs, Quick Guide, etc. fixing Codacy issues.
-  **December 7, 2020:** Another update to `piranha` script (now v1.1.6) to make sure that function name tab completions are automatically sourced when running `piranha`. Also updates to installer scripts and documentation, plus the change log.
-  **December 3, 2020:** Added _important_ updates to PIrANHA, including edits to main `piranha` script (now v1.1.5) and a new `completions/` subfolder, allowing bash tab completion of function names (expected usage: `piranha -f <TAB>`). Updated Homebrew tap and 'changelog.md' accordingly.
-  **November 23 and December 1, 2020:** Bug fixes and updates for `assembleReads` and `phaseAlleles` functions of `piranha`, fixing errors that caused the program to stop due to issues with among other things `ls`, plus minor change to `alignAlleles` (not worth a mention).
-  **November 13, 2020:** Bug fix for `PHYLIP2NEXUS` because failing regex test for hexadecimal characters, if produced, in the resulting (output) NEXUS files. Problem solved by posix solution.
-  **October 20, 2020** Bug fixes for `FASTA2PHYLIP` function, which in aggregate fix problems completely for the single-FASTA, `-f 1 option.
-  **August 12, 2020:** Updated `trimSeqs` function to improve performance after bug/issue discussion with Juan Moreira. This updated fixed posix space bug, because `[:space:]` should be `[[:space:]]`.
-  **August 3, 2020:** Updated README, as well as Quick Guide for [wiki](https://github.com/justincbagley/piranha/wiki).

### PIrANHA 0.4a3 (official minor pre-release version v0.4-alpha-3), July 31, 2020

-  **July 31, 2020:** Added new `trimSeqs` function and prepped 0.4a3 release by updating versioning of main `piranha` script and function scipts, and also updating Wiki and READMEs. The `trimSeqs` function automates trimming one or multiple DNA sequence alignments in PHYLIP format, with options for custom gap handling parameters for trimAl, and with trimmed alignments output to FASTA, PHYLIP, or NEXUS formats.
-  **May 27, 2020:** Updated repo with new citation file ('CITATION.md'), code of conduct for developers ('CODE_OF_CONDUCT.md'), and license ('LICENSE').
-  **May 3-5, 2020:** Added new functions. The new `geneCounter` function counts and summarizes number of gene copies per tip taxon label in a set of input gene trees in Newick format, given a taxon-species assignment file (this function written to handle output from HybPiper pipeline; see Usage text). Also added a new `batchRunFolders` function to help setting up input files for batch analyses in several popular software programs for phylogenetics.
-  **April 18-20, 2020:** This update builds on the previous pre-release, v0.4a2, by adding minor bug fixes and improvements to several functions. With the addition of the new function `alignAlleles`, a companion script meant to be run directly after `phaseAlleles`, this release establishes a new workflow for phasing and aligning consensus sequences from HTS (e.g. targeted sequence capture data) based on reads (re)mapped to a reference assembly FASTA file (i.e. following reference-based assembly). This combination of programs was designed to be run on target capture data after first conducting cleaning, assembly, locus selection, and reference-based assembly (specifically, with SECAPR (Andermann et al. 2018) in mind, and with testing based on output from SECAPR).
-  **April 17, 2020:** Added "Quick Guide" to wiki, entitled "Quick Guide for the Impatient," with install instructions and example code.

### PIrANHA 0.4a2 (official minor pre-release version v0.4-alpha-2), April 17, 2020

-  **April 13-17, 2020:** This update builds on the previous pre-release, v0.4a, by updating the main `prianha` script (including improvements to messaging and help text); addition of a new `phaseAlleles` function that automates phasing of consensus sequences from HTS (e.g. targeted sequence capture) based on a (re)mapped assembly reference FASTA; as well as minor updates to all functions (improved messaging and minor bug fixes).

### PIrANHA v0.4a (official minor pre-release version 0.4-alpha), April 13, 2020

-  **April 12, 2020:** Various minor updates to piranha bin/ functions, and important update to options in main `piranha` script now allows arguments to be passed to the program directly after the function call (after -f flag), without -a|--args flag. This fixes a problem where the previous implementation's reliance on `--args='<args>'` format (arguments passed in quotes) meant that Bash completion would not work while writing out the arguments. 
-  **April 6-7, 2020:** Major `piranha` package update, including edits to main script, all functions, dir structure, and other files (e.g. test files). Bug fixes for errors when no arguments and failed `rm` calls, check and update debug code, plus updates to READMEs and help texts.
-  **April 2-3, 2020:** Multiple updates. Added new `FASTAsummary` function that automates summarizing characteristics of one or multiple FASTA files in current working directory, and I also modified `calcAlignmentPIS` to integrate with this new function, and now both functions work well when run separately or together (the function to calculate PIS is now called within `FASTAsummary`. Also updated `PHYLIPsummary` function. Also added new `splitFASTA` function that splits each tip taxon (individual sequence) in a FASTA file into a separate FASTA file. This set of updates also includes a new `piranha` script with updated `-f list` function accommodating new functions, and with an attempt at adding debugging code (but this needs additional testing and fixing (How to best implement debugging?)). 
-  **March 30, 2020:** Multiple updates. Added new `nQuireRunner` function that automates running `nQuire` to estimate ploidy levels for samples based on mapped NGS reads (BAM files); updated `FASTA2PHYLIP` function to have new options (-f and -i) allowing analysis of a single input FASTA or multiple FASTAs (prev. only did multiple FASTAs in cwd); updated `MAGNET` with minor fixes to v1.1.1 (updated versioning in README as well); and updated `piranha` function to have complete `list` function output. Also added test FASTA file 'test.fasta' to test/ subfolder of repository containing test input files.
-  **December 12, 2019:** Added new `BEAST_logThinner` function script that downsizes, or 'thins', BEAST2 .log files to every nth line. Tested and working interactively. Outputs new log file in current working directory, without replacement.
-  **October 23, 2019:** Added new `PHYLIPsummary` function script that summarizes no. taxa and no. characters for one or multiple PHYLIP DNA sequence alignments in current directory.
-  **October 22, 2019:** Made minor edits (e.g. fixing versioning) and bug fixes (fixing `sed` code that caused failures when user had GNU SED installed instead of BSD SED) to all of the following function scripts: `PhyloMapperNullProc`, `PHYLIPsubsampler`, `PHYLIPcleaner`, `PHYLIP2PFSubsets`, `MLEResultsProc`, `getBootTrees`, `fastSTRUCTURE`, `dropRandomHap`, `dadiUncertainty`, `dadiRunner`, `dadiPostProc`, `calcAlignmentPIS`, `BEASTRunner`, `BEAST_PSPrepper`, `RAxMLRunChecker`, `RAxMLRunner`, `SNAPPRunner`, `SpeciesIdentifier`, `AnouraNEXUSPrepper`, `concatenateSeqs`, `concatSeqsPartitions`, `FASTA2VCF`, `getTaxonNames`, `makePartitions`, `MrBayesPostProc`, `phyNcharSumm`, `pyRAD2PartitionFinder`, `pyRADLocusVarSites`, `renameForStarBeast2`, `renameTaxa`, `renameTaxa_v1`, `splitPHYLIP`, `taxonCompFilter`, `treeThinner`, `vcfSubsampler`, `completeSeqs`, `RYcoder`, `RogueNaRokRunner`, `PHYLIP2NEXUS`, `PHYLIP2Mega`, `NEXUS2PHYLIP`, `NEXUS2MultiPHYLIP`, `Mega2PHYLIP`, `BEASTReset`, `FASTA2PHYLIP`, `completeConcatSeqs`

### PIrANHA v0.3a2 (official minor pre-release version 0.3-alpha.2), July 26, 2019

-  **July 25, 2019:** Added new `RogueNaRokRunner` function that reads in a Newick tree file and runs it through RogueNaRok to identify rogue taxa. Additionally, I conducted a comlete rewrite of the `NEXUS2PHYLIP` function that removes its dependence on N. Takebayashi's Perl script (see previous version), and I made minor edits to `piranha` and edits and bug fixes for other functions including `RYcoder`.
-  **July 24, 2019:** Minor updates and bug fixes for `PHYLIP2NEXUS` function.
-  **July 11, 2019:** Minor updates and fixes for `PHYLIP2Mega` function.
-  **June 11, 2019:** Added new `RYcoder` function that reads in a PHYLIP or NEXUS DNA sequence alignment and converts it into 'RY'-coded, binary format, with purines (A, G) coded as 0's and pyrimidines (C, T) coded as 1's. 

### PIrANHA v0.3a1 (official minor pre-release version 0.3-alpha.1), May 7, 2019

-  **May 7, 2019:** Fixed main `piranha` function so that it correctly reads in all arguments passed with the --args='' flag (should also work with -a), which previously caused several functions to fail and invoke `trapExit`.
-  **April 30 – May 7, 2019:** Added bug fixes and updates to `dropRandomHap`, `PHYLIP2NEXUS`, `PHYLIP2FASTA`, `PHYLIP2Mega`, and `splitPHYLIP` functions.
-  **April 10, 2019:** Added new `renameTaxa` function that renames taxon (sample) names in genetic data files of type FASTA, NEXUS, PHYLIP, and VCF according to user specifications.
-  **April 9, 2019:** Added updated scripts to fix bugs in `FASTA2PHYLIP` and `getTaxonNames` functions.

### PIrANHA v0.2-alpha.2 (official minor pre-release version), April 9, 2019

This is a minor update to the pre-release version that adds a new `FASTA2VCF` function which acts as a wrapper for the software program `snp-sites` ([link](https://github.com/sanger-pathogens/snp-sites)) and converts a sequential FASTA multiple sequence alignment into a variant call format (VCF) v4.1 file, with or without subsampling 1 SNP per partition/locus. This update also includes edits to the README, index.html, changeLog.md, and travis.yml files. Importantly, I have also now created a successful [homebrew](https://brew.sh) tap for PIrANHA [here](https://github.com/justincbagley/homebrew-piranha) with a formula that is working with v0.2-alpha, and that is now described in the documentation [wiki](https://github.com/justincbagley/piranha/wiki). 

### PIrANHA v0.2-alpha.1c (official minor pre-release version), March 15, 2019

This is a minor update to the pre-release version that includes edits to the README and index.html files, and that adds this slightly updated changeLog.md file back into the repository. Other changes include removing `bin/trash` function due to conflicts with `/usr/local/bin/trash` symlink belonging to trash on macOS, which caused homebrew install to fail. After fixing this, I have also now created a successful homebrew tap for PIrANHA that is working with this release (more info soon, to be added to the README). 

### PIrANHA v0.2-alpha.1b (official minor pre-release version), March 15, 2019

This is a very minor update to the pre-release version removing some PHYLIP and FASTA DNA sequence alignments that I had previously included in the repo for my own testing purposes, and updating README and index.html files.

### PIrANHA v0.2-alpha.1 (official minor pre-release version), March 15, 2019

Since v0.2-alpha, the pre-release version of **PIrANHA v0.2-alpha.1** added several updates including redos for the PIrANHA etc/ dir, a README for bin/, and new scripts for the `MLEResultsProc`, `getTaxonNames`, `taxonCompFilter`, and `SNAPPRunner` functions.

### PIrANHA v0.2-alpha (official minor pre-release version), March 15, 2019

Pre-release version, **PIrANHA v0.2-alpha**, involved a virtually complete rewrite and reorganization of PIrANHA (with >1,200 additions and >400 deletions). All scripts were converted to 'function' programs in bin/ or bin/MAGNET-1.0.0/ of the repo, and I have written a new program, ```piranha```, that is now the main program and runs all functions. I am _still_ in the process of updating the README and all function scripts, but I did a pre-release ratcheted up to v0.2 due to the great improvements in modularization and efficiency that this update allowed (selecting a function and passing all arguments, all from ```piranha```), and because I wanted a new release to use as a starting point to create Debian and Homebrew distribution releases (i.e. brew tap(s) to update as new versions roll out during development). The current organization of **PIrANHA** is much better suited for general use, and for adding other collaborators or developers.

The [changeLog.md](https://github.com/justincbagley/PIrANHA/blob/master/changeLog.md) is not yet up to date (not even for v0.2-alpha) and the repository is close but still not ready for a v1.0 major release, but we're getting there!!

- **March 2019:** Changed license to 3-Clause BSD license. Need to delete old versions still available on GitHub or Zenodo with GPLv2+ license, so that only this release, with current license, is available.
- **March 2019:** Updated script headers, dates, and copyright information, most scripts.
- **February – March 2019:** Added -V and --version flag options, to echo version to screen, to most scripts in the repo.


### PIrANHA v0.1.7 (official minor version release), February 19, 2019

-  **February 19, 2019:** Improved ```phylipSubsampler.sh``` to check and account for differences in machine type. Now correctly accommodations UNIX (Mac) and LINUX systems.
-  **February 19, 2019:** Updated MAGNET script by adding a getBipartTrees function to the MAGNET pipeline, which organizes RAxML bipartitions trees for each locus (= best ML trees with bootstrap proportions along nodes the corresponding bootstrap searches search; resulting from ```-f a -x```options, which are included in all MAGNET calls to RAxML). Edited header and script banner to be prepped for future official release of MAGNET with versioning 0.1.9.
-  **December 2018:** Added new MAGNET script updated to include --resume option, and to set raxml executable name one of two ways after detecting machine type (```raxml``` on Mac, ```raxmlHPC-SS3``` on Linux/supercomputer).
-  **November 25, 2018:** Added to MAGNET/shell folder a new 'RAxMLRunChecker.sh' script v1.0, which counts the number of completed RAxML runs during the course of, or after, a MAGNET pipeline run, and also collates information on the dataset (e.g. number of patterns) and run (e.g. run time, optimum likelihood) for each locus/partition.
-  **November 20, 2018 bug fix:** Updated MAGNET with edited 'MAGNET.sh' (now v0.1.7+) and 'NEXUS2gphocs.sh' (now v1.3+) scripts containing an important bug fix and some new code checking for whether the NEXUS to fasta file conversion succeeded.
-  **November 2018:** Rewrote 'pyRAD2PartitionFinder.sh' script, adding several options including options for choosing the PartitionFinder path and version, model set, model selection parameter (BIC, AIC, or AICc default), and whether or not to run PartitionFinder (or just create the input files). This new pyRAD2PartitionFinder script supersedes the old 'Super-pyRAD2PartitionFinder.sh' script that was previously included for use on HPC supercomputer clusters, which has now been removed from the repo. The new script has been tested on mac/UNIX and Linux (CentOS 6).
-  **June 2018:** Created 'snapp_runner.cfg' example configuration file for SNAPPRunner.
-  **August 2018:** Created 'runSpeciesIdentifier.sh' script for running SpeciesIdentifier DNA barcoding software on supercomputer.
-  **May 2018:** Updated 'BEASTReset.sh' and 'fastSTRUCTURE.sh' scripts.
-  **October 2017:** Added 'dadiUncertainty.sh', a pipeline program and ∂a∂i wrapper that automates running uncertainty analysis on a ∂a∂i demographic model, using either the Godambe Information Matrix (GIM) or Fisher Information Matrix (FIM), to estimate standard deviations for calculating 95% CIs for model parameter estimates.
-  **September 2017:** Added 'vcfSubsampler.sh', a utility script that uses a list file to subsample a .vcf file so that it only contains SNPs in the list.
-  **September 2017:** Added 'phylipSubsampler.sh', a utility script that automates subsampling one or multiple Phylip alignments down to one sequence per population/species (assuming no missing data).
-  **September 2017:** Updated README. A specific fix to the README is giving an updated DOI in the Zenodo badge (DOI section). Another fix was switching the DOI in example citations to a Zenodo DOI that applies to all versions; the new DOI will always resolve to the latest release tracked by Zenodo.
-  **bug fix:** - phylipSubsampler.sh (fixes bug causing incorrect number of characters on first line of input files) 


### PIrANHA v0.1.6.1 (official minor version release), September 13, 2017

-  **August 2017:** Made several updates to README and documentation for the repository.


### PIrANHA v0.1.6 (official minor version release), September 13, 2017

-  **August 2017:** Updated all README files in the repository (for PIrANHA, BEASTPostProc, BEASTRunner, ExaBayesPostProc, MLEResultsProc, and fastSTRUCTURE scripts).
-  **August 2017:** Added new 'BEASTReset.sh' script, and corresponding README, into BEASTReset sub-folder. This script automates re-setting random starting number seeds in BEAST run submission scripts for supercomputer runs. This is a time-saving script when many failed runs need to be restarted from a different seed!
-  **bug fix:** MLEResultsProc.sh (expands capability of detecting and accounting for PS/SS runs conducted in different versions of BEAST, i.e. v1 vs. v2) 
-  **bug fix:** PFSubsetSum.sh (fixes incorrect ordering of summary statistics) 
-  **bug fix:** PFSubsetSum.sh (fixed script so that it works with PartitionFinder v1 and v2; last testing: v2.1.1) 


### PIrANHA v0.1.5 (official minor version release), August 21, 2017

The current release, PIrANHA v0.1.5, contains the following updates, in addition to minor improvements in the code:

-  **August 2017:** Added a Change Log file ('changeLog.md') to supplement releases page and provide log file within master.
-  **August 2017:** Updated MAGNET pipeline by editing 'MAGNET.sh' by adding three new command line options ("\-e", "\-m", and "\-o" flags), as follows:
  \-e   executable (def: raxmlHPC-SSE3) name of RAxML executable, accessible from command line
       on user's machine
  \-m   indivMissingData (def: 1=allowed; 0=removed)
  \-o   outgroup (def: NULL) outgroup given as single taxon name (tip label) or comma-
       separted list   
-  **August 2017:** Updated MAGNET pipeline by adding getBootTrees.sh script, which collates and organizes bootstrap trees from all RAxML runs in sub-folders of a working directory, especially results of a MAGNET run. This is the standalone version of the script.  
-  **August 2017:** Updated 'BEASTPostProc.sh'
-  **August 2017:** Updated 'BEASTRunner.sh'
-  **August 2017:** Updated 'BEAST\_PSPrepper.sh' script automating editing existing BEAST v2+ (e.g. v2.4.5) input XML files for path sampling analysis, so that users don't have to do this by hand!
-  **bug fix:** - MAGNET.sh (unused code)
-  **bug fix:** - getGeneTrees.sh (unused code)
-  **bug fix:** - BEASTRunner.sh


### PIrANHA v0.1.4 (modified minor version release - several changes after official v0.1.4 release)

The current, modified PIrANHA v0.1.4 release contains several goodies listed below, in addition to minor improvements in the code!!

-  **August 2017:** Updated 'BEAST\_PSPrepper.sh' script automating editing existing BEAST v2+ (e.g. v2.4.5) input XML files for path sampling analysis, so that users don't have to do this by hand!
-  **May 2017:** Added 'SNAPPRunner.sh' script for conducting multiple runs of SNAPP ("SNP and AFLP Phylogenies") model in BEAST.
-  **May 2017:** Added options to 'MrBayesPostProc.sh' script for specifying relative burnin fraction (during sump and sumt), as well as calling stepping-stone sampling estimation of the log-marginal likelihood of the model.
-  **May 2017:** Added new 'MrBayesPostProc.sh' script that summarizes the posterior distribution of trees and parameters from a single MrBayes run. Script picks up filenames from contents of run dir, and uses default burnin fraction of 0.25 during analyses.
-  **May 2017:** Build now contains new 'BEASTRunner.sh' script and 'beast\_runner.cfg' configuration file. BEASTRunner now has options to allow specifying 1) number of runs, 2) walltime, and 3) Java memory allocation per run, as well as calling reg or verbose help documentation from the command line.
-  **April 2017:** Build now contains new 'pyRADLocusVarSites.sh' script (with example run folder) that calculates numbers of variable sites (i.e. segregating sites, S) and parsimony-informative sites (PIS; i.e. hence with utility for phylogenetic analysis) in each SNP locus contained in .loci file from a pyRAD assembly run.
-  **April 2017:** I added new 'dadiRunner.sh' script that automates transferring and queuing multiple runs of dadi input files on a remote supercomputer (similar to BEASTRunner and RAxMLRunner scripts already in the repo).

I have also added a new `MrBayesPostProc.sh` script and corresponding 'mrbayes_post_proc.cfg' configuration file, which together automate summarizing the posterior distribution of trees and parameters from a single MrBayes run. I intend to extend these scripts to provide options for several other anlayses of individual MrBayes runs/input files, as well as extend them to pulling down results from multiple MrBayes runs.


### PIrANHA v0.1.4 (official minor version release), May 3, 2017

#### What's new?

-  **May 2017:** Build now contains new **BEASTRunner.sh** script and 'beast_runner.cfg' configuration file. BEASTRunner now has options to allow specifying 1) number of runs, 2) walltime, and 3) Java memory allocation per run, as well as calling reg or verbose help documentation from the command line.
-  **April 2017:** Build now contains new **pyRADLocusVarSites.sh** script (with example run folder) that calculates numbers of variable sites (i.e. segregating sites, S) and parsimony-informative sites (PIS; i.e. hence with utility for phylogenetic analysis) in each SNP locus contained in .loci file from a pyRAD assembly run.
-  **April 2017:** I added new **dadiRunner.sh** script that automates transferring and queuing multiple runs of dadi input files on a remote supercomputer (similar to BEASTRunner and RAxMLRunner scripts already in the repo). *n.b.: A dadiPostProc.sh script is also in the works (but unreleased) that conducts post-processing and graphical plotting of results from multiple dadi runs*
-  **January 2017:** I added a new script called **BEAST_PSPrepper.sh** that, while not quite polished, automates editing any existing BEAST v2+ (e.g. v2.4.4) input XML files for path sampling analysis, so that users don't have to do this by hand!


### PIrANHA v0.1.3 (official minor version release), November 11, 2016

#### What's new?

This version of PIrANHA introduces the BEASTRunner.sh script for automating independent runs of BEAST1 or BEAST2 on a remote supercomputing cluster. See README for details.


### PIrANHA v0.1.2 (official minor version release), November 10, 2016


### PIrANHA v0.1.1 (official minor version, patch release), November 10, 2016


### PIrANHA v0.1.0 (pre-release version zero), September 6, 2016
