#  PIrANHA (*P*hylogenet*I*cs *AN*d p*H*ylogeogr*A*phy)
Scripts for file processing and analysis in phylogenomics &amp; phylogeography

## License

All code within the PIrANHA repository is available "AS IS" under a generous GNU license. See the [LICENSE](LICENSE) file for more information.

## Citation

If you use scripts from this repository as part of your published research, I require that you cite the repository as follows (I will put everything in Zenodo and get doi's in the near future): 
  
- Bagley, J.C. 2016. PIrANHA. GitHub repository, Available at: http://github.com/justincbagley/PIrANHA.

Alternatively, please provide the following link to this software repository in your manuscript:

- https://github.com/justincbagley/PIrANHA

## Introduction

*Taking steps towards automating boring stuff during analyses of genetic data in phylogenomics & phylogeography...*

PIrANHA is a repository of shell scripts and code (e.g. R, Perl, and Python) designed to help automate processing and analysis of multilocus or genome-scale DNA sequence data in phylogenetics and phylogeography projects. PIrANHA is fully command line-based and, rather than being structured as a single pipeline, it contains a series of scripts, some of which form pipelines, for aiding or completing tasks during evolutionary analyses of genetic data. Currently, PIrANHA scripts facilitate running or linking the software programs pyRAD (Eaton 2014), PartitionFinder (Lanfear et al. 2012), BEAST (Drummond et al. 2006, 2012), starBEAST (Heled & Drummond 2010), ExaBayes, and fastSTRUCTURE (Raj et al. 2014). I recently also added a draft script for processing PhyloMapper logfiles to extract information on the inferred ancestral geographic location. 

The current code in PIrANH has been written largely with a focus on 1) analyses of DNA sequence data and SNP loci generated from massively parallel sequencing runs on ddRAD-seq genomic libraries (e.g. Peterson et al. 2012), and 2) automating running these software programs on a remote supercomputer machine and retrieving and processing the results. Thus, whereas some PIrANHA scripts are written for use on the user's local machine (e.g. pyRAD2PartitionFinder.sh), others are written with sections allowing the script to be submitted to run on a supercomputing cluster using code suitable for SLURM or TORQUE resource management systems (e.g. Super-pyRAD2PartitionFinder.sh; and hence the "Super" in the filename). 

### Distribution Structure and Pipelines

*What is in PIrANHA?*

PIrANHA is a mixture of shell scripts and R scripts written by the author, as well as Perl or Python code from other workers. Here is a slide showing the main files in the repository to-date:
[ADD FIGURE HERE.]

*What is possible with PIrANHA?* *Who cares?*

PIrANHA facilitates analysis pipelines that could be of interest to nearly anyone conducting evolutionary analyses of DNA sequence data using recent maximum-likelihood and Bayesian methods. **Figure 1** and **Figure 2** below demonstrate flow and interactions of the current pipelines with **software** and **"file-types"** used to generate input for PIrANHA in the left column, and the way these are processed within/using PIrANHA illustrated in the right column. External software programs are shown in balloons with names in black italic font, while PIrANHA scripts are given in blue. Arrows show the flow of files through different pipelines, which terminate in results (shown right of final arrows at far right of each diagram).

![alt tag](https://cloud.githubusercontent.com/assets/10584087/19273172/e92c125a-8fa1-11e6-9985-89739f33d932.png)
**Figure 1**

![alt tag](https://cloud.githubusercontent.com/assets/10584087/19273268/419f0b0e-8fa2-11e6-9bfe-9f71670d16bb.png)
**Figure 2**


## Getting Started

### Dependencies

PIrANHA, and especially the MAGNET package within PIrANHA, relies on several software dependencies. These dependencies are described in some detail in README files for different scripts or packages; howere, here I provide a full list of them, with asterisk marks preceding those already included in the MAGNET distribution:

- PartitionFinder
- BEAST v1.8.3 and v2.4.2
	* default BEAST packages required
- ExaBayes
- RAxML, installed and running on remote supercomputer (available at: http://sco.h-its.org/exelixis/web/software/raxml/index.html).
- Perl (available at: https://www.perl.org/get.html).
- **\***Nayoki Takebayashi's file conversion Perl scripts (available at: http://raven.iab.alaska.edu/~ntakebay/teaching/programming/perl-scripts/perl-scripts.html).
- Python (available at: https://www.python.org/downloads/).
- bioscripts.convert v0.4 Python package (available at: https://pypi.python.org/pypi/bioscripts.convert/0.4; also see README for "NEXUS2gphocs.sh").

Users must install all software not included in PIrANHA, and ensure that it is available via the command line on their local machine. For more details, see the [MAGNET README](https://github.com/justincbagley/MAGNET).

### Installation

As PIrANHA is primarily composed of shell scripts, it is well suited for running on a variety of types of machines, especially UNIX/LINUX-like systems that are now commonplace in personal computing and dedicated supercomputer cluster facilities (the latter of which are typically Linux-based). As a result, there is no installation protocol for PIrANHA. It should run "out-of-the-box" from most any folder on your machine.

### Input and Output File Formats
[under development.]

### Phylogenetic Partitioning Scheme/Model Selection: pyRAD2PartitionFinder
[under development.]

### Estimating Gene Trees for Species Tree Inference: MAGNET (MAny GeNE Trees) Package
[under development.]

## Acknowledgments

\* Nayoki Takebayashi, who wrote and freely provided some Perl scripts I have used in PIrANHA.

## References

- Eaton DA (2014) PyRAD: assembly of de novo RADseq loci for phylogenetic analyses. Bioinformatics, 30, 1844-1849.
- Heled J, Drummond AJ (2010) Bayesian inference of species trees from multilocus data. Molecular Biology and Evolution, 27, 570–580.
- Lanfear R, Calcott B, Ho SYW, Guindon S (2012) PartitionFinder: combined selection of partitioning schemes and substitution models for phylogenetic analyses. Molecular Biology and Evolution, 29,1695-1701.
- Peterson BK, Weber JN, Kay EH, Fisher HS, Hoekstra HE (2012) Double digest RADseq: an inexpensive method for de novo SNP discovery and genotyping in model and non-model species. PLoS One, 7, e37135.
- Raj A, Stephens M, and Pritchard JK (2014) fastSTRUCTURE: Variational Inference of Population Structure in Large SNP Data Sets. Genetics, 197, 573-589.

October 11, 2016
Justin C. Bagley, Brasília, DF, Brazil
