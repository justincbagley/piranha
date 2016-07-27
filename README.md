# RAD-phylo-geo
shell scripts for processing and analyzing RAD (or other SNP/GBS) data for phylogenomics &amp; next-gen phylogeography

INTRODUCTION
-------

RAD-phylo-geo is a repository for shell scripts and code I am developing and using in pipelines to analyze ddRAD-seq data for on-going projects in the lab. Currently, the repository contains code related to, or linking, the following software:
- pyRAD
- PartitionFinder
- fastSTRUCTURE

Currently, I have uploaded my pyRAD2PartitionFinder.sh, Super-pyRAD2PartitionFinder.sh, fastSTRUCTURE.sh, and fastSTRUCTUREnonint.sh scripts and some related files. However, I have other code for working with SNP data in BEAST, *BEAST, ExaBayes, RAxML, and G-PhoCS, and I am also currently developing parts of this pipeline to help conduct analyses of SNP loci in SNAPP and Migrate-N. So, stay tuned... as new code will be coming out in the coming weeks and months, alongside refinements to the existing code (which is the first draft of the set).

One of the main distinctions between different scripts herein is that some scripts are written for use on your local machine (e.g. pyRAD2PartitionFinder.sh), whereas others are written with sections for submitting the script to run on a supercomputing cluster using SBATCH or PBS resource management code and rules (e.g. Super-pyRAD2PartitionFinder.sh; and hence the "Super" in the filename). Another difference between scripts is that some of these scripts are written to be interactive, prompting the user for paths, filenames, or other information that will be fed into the processing of the input files or running the software programs; however, additional versions are available that manipulate files or run software programs in non-interactive mode, i.e. "in the background." One example of this is that the fastSTRUCTURE.sh script is interactive, whereas the fastSTRUCTUREnonint.sh script is non-interactive. 

LICENSE
-------

The code within this repository is available under a GNU license. See the License.txt file for more information.

CITATION
-------

If you use scripts from this repository for your own research, please provide the link to this software repository in your manuscript:

  https://github.com/justincbagley/RAD-phylo-geo

~J
