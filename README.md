#  PIrANHA (*P*hylogenet*I*cs *AN*d p*H*ylogeogr*A*phy)
Scripts for file processing and analysis in phylogenomics &amp; phylogeography

LICENSE
-------

All code within the PIrANHA repository is available "AS IS" under a generous GNU license. See the License.txt file for more information.

CITATION
-------

If you use scripts from this repository as part of your published research, I require that you cite the repository as follows (I will put everything in Zenodo and get doi's in the near future): 
  
- Bagley, J.C. 2016. PIrANHA. GitHub repository, Available at: http://github.com/justincbagley/PIrANHA.

Alternatively, please provide the following link to this software repository in your manuscript:

- https://github.com/justincbagley/PIrANHA

INTRODUCTION
-------

PIrANHA is a repository of shell scripts and code (e.g. R, Perl, and Python) that I am developing and pipelining to help quickly process and analyze multilocus and genomic data as part of research projects in phylogenetics and phylogeography. PIrANHA is not structured as a single pipeline; rather, it contains a series of scripts, some of which form pipelines, for aiding or completing different tasks during evolutionary analyses of genetic datasets. Currently, PIrANHA scripts facilitate running or linking the software programs pyRAD, PartitionFinder, BEAST, *BEAST, ExaBayes, and fastSTRUCTURE. The current code also has been written largely with a focus on 1) analyses of DNA sequence data and SNP loci generated from massively parallel sequencing runs on ddRAD-seq genomic libraries, and 2) automating running these software programs on a remote supercomputer machine and retrieving and processing the results. Thus, whereas some PIrANHA scripts are written for use on the user's local machine (e.g. pyRAD2PartitionFinder.sh), others are written with sections allowing the script to be submitted to run on a supercomputing cluster using code suitable for SLURM or TORQUE resource management systems (e.g. Super-pyRAD2PartitionFinder.sh; and hence the "Super" in the filename). 

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

I am writing up README files for all of the main scripts. However, this README file serves as a rough manual for the overall repository.

EXAMPLES
-------

Once I move beyond the initial stages developing the code and documentation for PIrANHA, and also publish some of my results (!), I plan to provide more examples of the input and output of PIrANHA scripts. The scripts and README files will contain all information necessary to understand the workflow of each script or pipeline, and run it. However, succinct examples of file format and usage need to be developed. Also, example datasets will be added to directories for each set of scripts, arranged by software or type of analysis. For now, users can feel free to email me with questions or to request examples.

DOWNLOAD AND INSTALLATION
-------

PIrANHA scripts, README files, and examples are all available for download directly from this site. PIrANHA does not require any special download or installation procedures, except properly installing all software called in the scripts and their dependencies (which is no small chore in some cases, e.g. for software distributions with several dependencies themselves). Also, PIrANHA scripts should run from any folder on UNIX/LINUX-like operating systems.

[UNDER CONSTRUCTION.]

Justin Bagley
August 18, 2016

