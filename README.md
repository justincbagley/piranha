#  PIrANHA (*P*hylogenet*I*cs *AN*d p*H*ylogeogr*A*phy)
Scripts for file processing and analysis in phylogenomics &amp; phylogeography

INTRODUCTION
-------

PIrANHA is a repository for shell scripts and code (e.g. R, python) I am developing and pipelining to process and analyze DNA sequence and genomics data in my phylogenetics and phylogeography research. Currently, the repository contains code related to, or linking, the software programs pyRAD, PartitionFinder, BEAST, *BEAST, ExaBayes, and fastSTRUCTURE in the analysis of DNA sequence data and SNP loci generated from ddRAD-seq genomic libraries. Thus, the current code spans phylogenetic partition and model selection, Bayesian phylogenetic gene tree and species tree analysis, and inference of population genetic structure. However, I am also writing code for analyzing SNP data in other software, including RAxML and G-PhoCS. Hopefully, this new code will be added in the coming weeks alongside refinements to the existing code base, which is the first draft (PIrANHA v1.0).

Whereas some PIrANHA scripts are written for use on the user's local machine (e.g. pyRAD2PartitionFinder.sh), others are written with sections allowing the script to be submitted to run on a supercomputing cluster using SBATCH or PBS resource management code (e.g. Super-pyRAD2PartitionFinder.sh; and hence the "Super" in the filename). One of my goals for PIrANHA is to compile a database of shell scripts I use for all software programs that I run on a supercomputing cluster. Another distinction between PIrANHA scripts is that some them are written to be interactive, prompting the user for paths, filenames, or other information that will be fed into file processing or software runs; these scripts do everything within an open command line interface, and often print status updates to screen. However, additional versions of scripts are available that manipulate files or run software programs in non-interactive mode, i.e. "in the background"; for example, the regular fastSTRUCTURE.sh script is interactive, whereas the fastSTRUCTUREnonint.sh script is not.

CURRENT PIPELINE/CONTENTS
-------
Here are some text schetches of the current pipelines with **software** and **"file-types"** used to generate input for PIrANHA in the left column, and the way these are processed within/using PIrANHA illustrated in the right column. Other software programs are marked using double **asterisks** while PIrANHA scripts are marked by pairs of **underscores** on either side. [Work this up as a figure.]

````
OUTSIDE PIrANHA              WITHIN/USING PIrANHA
---------------------------------------------------------------------------------------
**pyRAD**                   
".partitions" file(s)\
                      ------>__pyRAD2PartitionFinder.sh__-->**PartitionFinder**-->output 
".phy" file(s)-------/


**pyRAD**                   
".str" file(s)------>__fastSTRUCTURE.sh__-->**fastSTRUCTURE**-->output 
                (or __fastSTRUCTUREnonint.sh__)

**BEAST**             
".trees" file(s)-------\
".species.trees" file(s)\
                         ------->__BEASTPostProc.sh__----->**LogAnalyser**-->output
".mle.log" file(s)------/                \----------->**TreeAnnotator**-->output
".out" file(s)---------/-------->__MLEResultsProc__
                                         \-->output----->__2log10BF.r__----->R-->output

**ExaBayes**
"ExaBayes_topologies.*" file(s)\
                                ------->__ExaBayesPostProc.sh__----->**MrBayes**-->output
"ExaBayes_parameters.*" file(s)/
````

DOCUMENTATION
-------

I am writing up README files for all of the main scripts.

EXAMPLES
-------

I am also beginning to make an effort to move beyond the initial stages of code and documentation development to provide examples of the input and output of PIrANHA scripts. The scripts and README files will contain all information necessary to understand the workflow of each script or pipeline, and run it. However, succinct examples of file format and usage need to be developed. Also, example datasets will be added to directories for each set of scripts, arranged by software or type of analysis.

DOWNLOAD
-------

Scripts, README files, and examples are all available for download directly from this site. Also, no special download or installation procedures are required, except that users will need to properly install all software called in the scripts and their dependencies (which is no small chore in some cases, e.g. for software distributions that have several dependencies themselves). 

LICENSE
-------

The code within this repository is available under a GNU license. See the License.txt file for more information.

CITATION
-------

If you use scripts from this repository for your own research, please provide the link to this software repository in your manuscript:

  https://github.com/justincbagley/PIrANHA
