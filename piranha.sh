#!/usr/bin/env bash

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        #
# |                                                                                      #
#                                                                                        #
# File: piranha                                                                          #
  export PIRANHA_VERSION="v1.1.8"                                                        #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Fri, Mar 8 12:43:12 CST 2019.                        #
# Last update: December 26, 2020                                                         #
# Copyright (c) 2019-2020 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <jbagley@jsu.edu>.                                               #
#                                                                                        #
# Description: Main script for PIrANHA package, controls all other scripts. With no      #
# input, prints usage and exits.                                                         #
#                                                                                        #
##########################################################################################

## Provide a variable with the location of this script.
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## Source Scripting Utilities
# -----------------------------------
# These shared utilities provide many functions which are needed to provide
# the functionality in this boilerplate. This script will fail if they can
# not be found.
# -----------------------------------
UTILS_LOCATION="${SCRIPT_PATH}/lib/utils.sh" # Update this path to find the utilities.

if [[ -f "${UTILS_LOCATION}" ]]; then
  source "${UTILS_LOCATION}"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting..."
  exit 1 ;
fi

## Source Shared Functions and Variables
# -----------------------------------
FUNCS_LOCATION="${SCRIPT_PATH}/lib/sharedFunctions.sh" # Update this path to find the shared functions.
VARS_LOCATION="${SCRIPT_PATH}/lib/sharedVariables.sh" # Update this path to find the shared variables.

if [[ -f "${FUNCS_LOCATION}" ]] && [[ -f "${VARS_LOCATION}" ]]; then
  source "${FUNCS_LOCATION}" ;
  source "${VARS_LOCATION}" ;
else
  echo "Please find the files sharedFunctions.sh and sharedVariables.sh and add references to them in this script. Exiting... "
  exit 1 ;
fi

## Source Completions Functions
# -----------------------------------
COMPL_LOCATION="${SCRIPT_PATH}/completions/init.sh" # Update this path to find the init.sh script.

if [[ -f "${COMPL_LOCATION}" ]]; then
  source "${COMPL_LOCATION}" ;
else
  echo "Please find the file init.sh and add a reference to it in this script. Exiting..."
  exit 1 ;
fi

## Set bin/ Location
# -----------------------------------
BIN_LOCATION="${SCRIPT_PATH}/bin/" # Update this path to find the piranha bin folder.

## trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
trapCleanup () {
  echo ""
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped. In function: '${FUNCNAME[*]}'"
}

## safeExit
# -----------------------------------
# Non destructive exit for when script exits naturally.
# Usage: Add this function at the end of every script.
# -----------------------------------
safeExit () {
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  trap - INT TERM EXIT
  exit ;
}

## Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=false
printLog=false
verbose=false
force=false
strict=false
debug=false
args=()

## Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${SCRIPT_NAME}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

## Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${SCRIPT_BASENAME}.log
# Save to standard user log location use: $HOME/Library/Logs/${SCRIPT_BASENAME}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${SCRIPT_BASENAME}.log"

## Check for Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.  Mac applications will be installed using
# Homebrew Casks. Ruby and gems via RVM.
# -----------------------------------
export homebrewDependencies=()
export caskDependencies=()
export gemDependencies=()




piranha () {

######################################## START ###########################################
##########################################################################################

if [[ ! -z "$FUNCTION_TO_RUN" ]] && [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_ARGUMENTS" = "-V" ]] || [[ "$FUNCTION_ARGUMENTS" = "--version" ]]; then
	MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}${FUNCTION_TO_RUN})";
	"$MY_EXECUTION_PATH" -V ;
	safeExit ;
fi

echo "
piranha v1.1.7, December 2020  (main script for PIrANHA v0.4a4, update Dec 24 21:04:08 CST 2020)                "
echo "Copyright (c) 2019-2020 Justin C. Bagley. All rights reserved.                                            "
echo "----------------------------------------------------------------------------------------------------------"

if [[ -z "$FUNCTION_TO_RUN" ]] && [[ -z "$FUNCTION_ARGUMENTS" ]]; then
	usage ;
	safeExit ;
fi

if [[ ! -z "$FUNCTION_TO_RUN" ]]; then

############ I. READ INPUT, SET UP WORKSPACE, AND CHECK / ECHO MACHINE TYPE.
	echo "INFO      | $(date) | Script path: $SCRIPT_PATH/piranha"
	echo "INFO      | $(date) | Function: $FUNCTION_TO_RUN "
	echo "INFO      | $(date) | Function arguments: $FUNCTION_ARGUMENTS "
#	echo "INFO      | $(date) | Remaining arguments: $args+ "
	echoCDWorkingDir
	echo "INFO      | $(date) | Checking machine type... "
	checkMachineType
	echo "INFO      | $(date) | Found machine type ${machine}. "

	# Linux ulimits:
	if [[ "${machine}" = "Linux" ]]; then
		echo "INFO      | $(date) | Checking core and file limits on Linux..."
		CORE_LIMIT=$(ulimit -c)
		export CORE_LIMIT
		FILE_LIMIT=$(ulimit -n)
		export FILE_LIMIT
		echo "INFO      | $(date) |    core limit: ${CORE_LIMIT}"
		echo "INFO      | $(date) |    open file limit: ${FILE_LIMIT}"
		## Attempt to set core limit to unlimited:
		ulimit -c unlimited 2>/dev/null ;
		## Attempt to increase to 1GB, or set as unlimited, the file limit:
		if [[ "$FILE_LIMIT" != "unlimited" ]] && [[ "$FILE_LIMIT" = "256" ]]; then
			ulimit -n 1024 ;
		elif [[ "$FILE_LIMIT" != "unlimited" ]] && [[ "$FILE_LIMIT" -gt "1000" ]] && [[ "$FILE_LIMIT" != "1024" ]]; then	
		#	NEW_LIMIT="$( calc $FILE_LIMIT*10 )";
		#	ulimit -n $NEW_LIMIT ;
			ulimit -n unlimited 2>/dev/null ;
		fi
	fi

############ II. CALL USER-SPECIFIED FUNCTION / SCRIPT IN BIN LOCATION, WITH OR WITHOUT ARGUMENTS.

#### SET / ECHO EXECUTION PATH
	if [[ "$FUNCTION_TO_RUN" != "MAGNET" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}${FUNCTION_TO_RUN})"
		echo "INFO      | $(date) | Execution path: $MY_EXECUTION_PATH"
	elif [[ "$FUNCTION_TO_RUN" = "MAGNET" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "INFO      | $(date) | Execution path: $MY_EXECUTION_PATH"
	fi

#### EXECUTING WITH ARGUMENTS? LIST OR REGULAR FUNCTION?
	## First sets of conditionals below: cases where function run is not MAGNET.
	if [[ -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$FUNCTION_TO_RUN" != "list" ]]; then
		echo "INFO      | $(date) | Executing function without additional arguments..."
		"$MY_EXECUTION_PATH" ;
	elif [[ -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$FUNCTION_TO_RUN" = "list" ]]; then
		echo "
FUNCTION			   DESCRIPTION
----------------------------------------------------------------------------------------------------------------
2logeB10.r             Rscript extracting marginal likelihood estimates and calculate 2loge B10 Bayes factors 
                       (2loge(B10)) from BEAST marginal likelihood estimation (ps / ss) runs.
alignAlleles           Aligns and cleans allele sequences (phased DNA sequences) output by the PIrANHA function
                       phaseAlleles (or in similar format; see phaseAlleles and alignAlleles usage texts for 
                       additional details).
AnouraNEXUSPrepper     In-house function for preparing NEXUS files for Anoura UCE project analyses (Calderon, 
                       Bagley, and Muchhala, in prep.).
assembleReads          Function that automates assembling cleaned sequence reads (short reads in FASTQ format)
                       from targeted sequence capture (e.g. Hyb-Seq) HTS experiments de novo using the ABySS
                       assembler.
batchRunFolders        Automates splitting a set of input files into different batches (to be run in parallel on
                       a remote supercomputing cluster, or a local machine), starting from file type or list of
                       input files.
BEAST_logThinner       Function that conducts downsampling ('thinning') of BEAST2 .log files to every nth line.
BEAST_PSPrepper        Function that automates prepping BEAST XML input files for path sampling (marginal 
                       likelihood estimation) analyses using BEAST v2+ PathSampler.
BEASTPostProc          Conducts post-processing of gene trees and species trees output by BEAST (e.g. Drummond
                       et al. 2012; Bouckaert et al. 2014; usually on a remote supercomputer).
BEASTReset             Function that resets the random seeds for n shell queue scripts corresponding to n BEAST 
                       runs/subfolders (destined for supercomputer).
BEASTRunner            Automates running BEAST XML input files on a remote supercomputing cluster, assuming 
                       passwordless ssh access.
calcAlignmentPIS       Generates and runs custom Rscript (phyloch wrapper) to calculate number of parsimony-
                       informative sites (pis) for all FASTA files in working dir.
completeConcatSeqs     Function converting series of PHYLIP (Felsenstein 2002) DNA sequence alignments (with or 
                       without varying nos. of taxa) into a single concatenated PHYLIP alignment with complete 
                       taxon sampling; also makes character subset/partition files in RAxML, PartitionFinder, 
                       and NEXUS formats for the resulting alignment.
completeSeqs           Function converting series of PHYLIP DNA sequence alignments (with or without varying nos. 
                       of taxa) into complete PHYLIP alignments (with complete taxon sampling), with missing taxa
                       filled with dummy sequences (N's), starting from a 'taxon names and spaces' file.
concatenateSeqs        Function that converts series of PHYLIP DNA sequence alignments with equal taxon sampling 
                       (same tip taxa, preferably in same order) into a single concatenated PHYLIP alignment.
concatSeqsPartitions   Function similar to concatenateSeqs, but which, in addition to concatenating the set of 
                       PHYLIP alignments, also outputs character subset/partitions files in RAxML, PartitionFinder,
                       and NEXUS formats. This function differs from completeConcatSeqs in only taking alignments 
                       with equal taxon sampling and in being slightly faster in this usage case.
dadiPostProc           Function for post-processing output from one or multiple ∂a∂i runs (ideally run with 
                       PIrANHA's dadiRunner function), including collation of best-fit parameter estimates, 
                       composite likelihoods, and optimal theta values.
dadiRunner             Automates running ∂a∂i on a remote supercomputing cluster. See help text (-h) and function 
                       (bin/ dir) for details.
dadiUncertainty        Automates uncertainty analysis in ∂a∂i, including generation of bootstrapped SNP files for 
                       parameter std. dev. estimation using the GIM method, as well as std. dev. estimation using 
                       the FIM method (orig. data only).
dropRandomHap          This function randomly drops one phased haplotype (allele) per individual in each of n 
                       PHYLIP gene alignments in current working directory, starting from a 'taxon names' file.
dropTaxa               Shell script automating removal of taxa from sequential, multi-individual FASTA or PHYLIP
                       DNA sequence alignments, starting from a list of taxa to remove.
ExaBayesPostProc       Function automating reading and conducting post-processing analyses on phylogenetic results 
                       output from ExaBayes.
FASTA2PHYLIP           Function that automates converting one or multiple sequential FASTA DNA sequence alignment 
                       files (with sequences either unwrapped or hard-wrapped across multiple lines) to PHYLIP 
                       format (Felsenstein 2002).
FASTA2VCF              Shell script function automating conversion of single multiple sequence FASTA alignment to 
                       variant call format (VCF) v4.1, with or without subsampling SNPs per partition/locus.
FASTAsummary           Summarizes characteristics (numbers of characters and tip taxa) in one or multiple FASTA 
                       DNA sequence alignment files in current working directory, and saves to file.
fastSTRUCTURE          Interactive function that automates running fastSTRUCTURE (Raj et al. 2014) on biallelic 
                       SNP datasets.
geneCounter            Shell script function that counts and summarizes the number of gene copies per tip species
                       in a set of gene trees in Newick format (concatenated into a single trees file), given a 
                       taxon-species assignment file.
getBootTrees           Function that automates organizing bootstrap trees output by RAxML runs conducted in 
                       current working directory using the MAGNET program within PIrANHA.
getDropTaxa            Function to create drop taxon list given lists of a) all taxa and b) a subset of taxa to
                       keep.
getTaxonNames          Utility function that extracts tip taxon names from sequences present in one or multiple 
                       PHYLIP DNA sequence alignments in current directory, using information on maximum taxon 
                       sampling level from user.
indexBAM               [In prep.]
iqtreePostProc         Function that automates post-processing of gene tree files and log files output during 
                       phylogenetic analyses in IQ-TREE v1 or v2 (Nguyen et al. 2015; Minh et al. 2020).
list                   Function that prints a tabulated list of PIrANHA functions and their descriptions.
MAGNET                 Shell pipeline for automating estimation of a maximum-likelihood (ML) gene tree in RAxML 
                       for each of many loci in a RAD-seq, UCE, or other multilocus dataset. Also contains other 
                       tools.
makePartitions         Function using PHYLIP DNA sequence alignments in current directory to make partitions/
                       charsets files in RAxML, PartitionFinder, and NEXUS formats, which are output to separate 
                       files.
Mega2PHYLIP            Automates converting one or more multiple sequence alignment files in Mega format (Mega v7+ 
                       or X; Kumar et al. 2016, 2018) to PHYLIP format (Felsenstein 2002), while saving (-k 1) or 
                       writing over (-k 0) the original Mega files.
mergeBAM               [In prep.]
MLEResultsProc         Automates post-processing of marginal likelihood estimation (MLE) results from running path 
                       sampling (ps) or stepping-stone (ss) sampling analyses on different models in BEAST.
MrBayesPostProc        Simple script for post-processing results of a MrBayes v3.2+ (Ronquist et al. 2012) run, 
                       whose output files are assumed to be in the current working directory.
NEXUS2MultiPHYLIP      Function that splits a sequential NEXUS alignment with charaset information into multiple 
                       PHYLIP-formatted alignments, one per gene/charset, and removes individuals with all missing 
                       data.
NEXUS2PHYLIP           Function that reads in a single NEXUS datafile and converts it to PHYLIP ('.phy') format 
                       (Felsenstein 2002). 
nQuireRunner           Function that automates running nQuire software (Weiß et al. 2018) to determine sample 
                       ploidy level from next-generation sequencing (NGS) reads for one or multiple samples,
                       starting from BAM file(s) for the sample(s)
PFSubsetSum            Calculates summary statistics for DNA subsets within the optimum partitioning scheme 
                       identified for the data by PartitionFinder v1 or v2 (Lanfear et al. 2012, 2014).
phaseAlleles           Automates phasing alleles of HTS data from targeted sequence capture experiments (or similar), 
                       including optionally transferring indel gaps from reference to the final phased FASTAs of 
                       consensus sequences, by masking
PHYLIP2FASTA           Automates converting each of one or multiple PHYLIP DNA sequence alignments into FASTA 
                       format.
phylip2fasta.pl        Nayoki Takebayashi utility Perl script for converting from PHYLIP to FASTA format.
PHYLIP2Mega            Utility script for converting one or multiple PHYLIP DNA sequence alignments into Mega 
                       format.
PHYLIP2NEXUS           Converts one or multiple PHYLIP-formatted multiple sequence alignments into NEXUS format, 
                       with or without pasting in a user-specified set of partitions (various formats).
PHYLIP2PFSubsets       Automates construction of Y multiple sequence alignments corresponding to PartitionFinder-
                       inferred subsets, starting from n PHYLIP, per-locus sequence alignments and a PartitionFinder 
                       results file (usually 'best_scheme.txt').
PHYLIPcleaner          Function that cleans one or more PHYLIP alignments in current dir by removing individuals 
                       with all (or mostly) undetermined sites.
PHYLIPsubsampler       Automates subsampling each of one to multiple PHYLIP DNA sequence alignment files down to 
                       one (random) sequence per species, e.g. for species tree analyses.
PHYLIPsummary          Summarizes characteristics (numbers of characters and tip taxa) in one or multiple PHYLIP 
                       DNA sequence alignment files in current working directory, and saves to file.
PhyloMapperNullProc    Script for post-processing results of a PhyloMapper null model randomization analysis.
phyNcharSumm           Utility function that summarizes the number of characters in each PHYLIP DNA sequence 
                       alignment in current working directory.
pyRAD2PartitionFinder  Automates running PartitionFinder (Lanfear et al. 2012, 2014) 'out-of-the-box' starting 
                       from the PHYLIP DNA sequence alignment file ('.phy') and partitions ('.partitions') file 
                       output by pyRAD (Eaton 2014) or ipyrad (Eaton and Overcast 2016).
pyRADLocusVarSites     Automates summarizing the numbers of variable sites and parsimony-informative sites (PIS) 
                       within RAD/GBS loci output by the programs pyRAD or ipyrad (Eaton 2014; Eaton and Overcast 
                       2016).
RAxMLRunChecker        Utility function that counts number of loci/partitions with completed RAxML runs, during 
                       or after a run of the MAGNET pipeline within PIrANHA, and summarizes run information.
RAxMLRunner            Script that automates moving and running RAxML input files on a remote supercomputing 
                       cluster (with passwordless ssh access; code for extraction of results coming in 2019??...).
renameForStarBeast2    Function that renames tip taxa (i.e. sequence names) in all PHYLIP or FASTA DNA sequence 
                       alignments in the current working directory, so that the taxon names are suitable for 
                       assigning species in BEAUti before running *BEAST or StarBEAST2 in BEAST.
renameTaxa             Automates renaming all tip taxa (samples) in genetic data files of type FASTA, PHYLIP, 
                       NEXUS, or VCF (variant call format) in current working directory.
RogueNaRokRunner       Function that automates reading in a Newick-formatted tree file (-i flag) and analyzing it
                       in RogueNaRok (Aberer et al. 2013).
RYcoder                New (June 2019) function that converts a PHYLIP or NEXUS DNA sequence alignment into 'RY' 
                       coding, a binary format with purines (A, G) coded as 0's and pyrimidines (C, T) recoded
                       as 1's.
SNAPPRunner            Function that automates running SNAPP (Bryant et al. 2012) on a remote supercomputing 
                       cluster (with passwordless ssh access set up by user).
SpeciesIdentifier      Runs the Taxon DNA software program SpeciesIdentifier, which implements methods in the well-
                       known Meier et al. (2006) DNA barcoding paper.
splitFASTA             Automates splitting a multi-individual FASTA DNA sequence alignment into one FASTA file per
                       sequence (tip taxon). Works with sequential FASTAs with no text wrapping across lines.
splitFile              Function that splits an input file into n parts (horizontally, by row) and optionally allows 
                       the user to specify the output basename for the resulting split files.
splitPHYLIP            Splits a sequential PHYLIP DNA sequence alignment into separate PHYLIP sequence alignments,
                       one per partition (read from a user-specified partition file).
taxonCompFilter        Function that loops through the multiple sequence alignments and keeps only those alignments 
                       meeting the user-specified taxonomic completeness threshold <taxCompThresh>; alignments that 
                       pass this filter are saved to an output subfolder of the current directory.
treeThinner            Function that conducts downsampling ('thinning') of trees in MrBayes .t files so that they 
                       contain every nth tree.
trimSeqs               Function that automates trimming one or multiple PHYLIP DNA sequence alignments using the 
                       program trimAl (Capella-Gutiérrez et al. 2009), with custom trimming options, and output to 
                       FASTA, PHYLIP, or NEXUS formats.
vcfSubsampler          Utility function that uses a list file to subsample a variant call format (VCF) file so that 
                       it only contains SNPs included in the list.

${bold}REFERENCES${reset}
Aberer, A., Krompass, D., Stamatakis, A. 2013. Pruning rogue taxa improves phylogenetic 
	accuracy: an efficient algorithm and webservice. Systematic Biology 62(1), 162–166.
Bouckaert, R., Heled, J., Künert, D., Vaughan, T.G., Wu, C.H., Xie, D., Suchard, M.A., 
	Rambaut, A., Drummond, A.J. 2014. BEAST2: a software platform for Bayesian evolutionary 
	analysis. PLoS Computational Biology 10, e1003537.
Bryant, D., Bouckaert, R., Felsenstein, J., Rosenberg, N.A., RoyChoudhury, A. 2012. Inferring 
	species trees directly from biallelic genetic markers: bypassing gene trees in a full 
	coalescent analysis. Molecular Biology and Evolution 29, 1917–1932.
Capella-Gutiérrez, S., Silla-Martínez, J.M., Gabaldon, T., 2009. TRIMAL: a tool for automated
	alignment trimming in large-scale phylogenetic analyses. Bioinformatics 25(15), 1972–1973.
Drummond, A.J., Suchard, M.A., Xie, D., Rambaut, A. 2012. Bayesian phylogenetics with BEAUti 
 	and the BEAST 1.7. Molecular Biology and Evolution 29, 1969-1973.
Eaton, D.A. 2014. PyRAD: assembly of de novo RADseq loci for phylogenetic analyses. 
 	Bioinformatics 30, 1844-1849.
Eaton, D.A.R., Overcast, I. 2016. ipyrad: interactive assembly and analysis of RADseq data sets. 
 	Available at: <http://ipyrad.readthedocs.io/>.
Felsenstein, J. 2002. PHYLIP (Phylogeny Inference Package) Version 3.6 a3.
	Available at: <http://evolution.genetics.washington.edu/phylip.html>.
Lanfear, R., Calcott, B., Ho, S.Y.W., Guindon, S. 2012. Partitionfinder: combined selection of 
	partitioning schemes and substitution models for phylogenetic analyses. Molecular Biology 
	and Evolution 29, 1695–1701. 
Lanfear, R., Calcott, B., Kainer, D., Mayer, C., Stamatakis, A. 2014. Selecting optimal 
	partitioning schemes for phylogenomic datasets. BMC Evolutionary Biology 14, 82.
Meier, R., Shiyang, K., Vaidya, G., Ng, P.K. 2006. DNA barcoding and taxonomy in Diptera: 
	a tale of high intraspecific variability and low identification success. Systematic 
	Biology 55(5), 715-728.
Minh, B.Q., Schmidt, H.A., Chernomor, O., Schrempf, D., Woodhams, M.D., Von Haeseler, A., 
	Lanfear, R., 2020. IQ-TREE 2: New models and efficient methods for phylogenetic inference 
	in the genomic era. Molecular Biology and Evolution 37(5), 1530-1534.
Nguyen, L.T., Schmidt, H.A., Von Haeseler, A., Minh, B.Q., 2015. IQ-TREE: a fast and effective
	stochastic algorithm for estimating maximum-likelihood phylogenies. Molecular Biology and 
	Evolution 32(1), 268-274.
Weiß, C.L., Pais, M., Cano, L.M., Kamoun, S., Burbano, H.A. 2018. nQuire: a statistical 
	framework for ploidy estimation using next generation sequencing. BMC Bioinformatics 
	19(1), 122.

----------------------------------------------------------------------------------------------------------------
" ;
  safeExit ;
	fi

	if [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$quiet" != "true" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" != "true" ]]; then
		echo "INFO      | $(date) | Executing function with -a flag arguments..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$quiet" = "true" ]] && [[ "$printLog" = "true" ]] && [[ "$debug" != "true" ]]; then
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" &> piranha.out.log.txt ;
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$quiet" = "true" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" != "true" ]]; then
		# Redirect stderr and stdout to /dev/null to make the run quiet
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" >/dev/null 2>&1 ;
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$quiet" != "true" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" = "true" ]]; then
		# Warn/acknowledge that user is running function script in DEBUG MODE (for developers) by setting debug=true
		echo "WARNING!  | $(date) | Executing function with -a flag arguments in DEBUG MODE..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS";
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" != "MAGNET" ]] && [[ "$quiet" != "true" ]] && [[ "$printLog" = "true" ]] && [[ "$debug" = "true" ]]; then
		# Warn/acknowledge that user is running function script in DEBUG MODE (for developers) by setting debug=true
		echo "WARNING!  | $(date) | Executing function with -a flag arguments in DEBUG MODE..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" &> piranha.out.log.txt ;
	fi

	## Next set of conditionals below: cases where function run _is_ MAGNET. Need these cases
	## because MAGNET comes with PIrANHA in its own subfolder with its own file structure,
	## so we need to add the subfolder name (which will vary as MAGNET is updated in the 
	## future) to the execution path, $MY_EXECUTION_PATH.
	if [[ -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" != "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "INFO      | $(date) | Executing function without additional arguments..."
		"$MY_EXECUTION_PATH" ;
	elif [[ -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" = "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "WARNING!  | $(date) | DEBUG MODE (attempted) is not available when calling MAGNET! Running script in regular release mode... "
		echo "INFO      | $(date) | Executing function without additional arguments..."
		"$MY_EXECUTION_PATH" ;
	elif [[ -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" = "true" ]] && [[ "$debug" != "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "INFO      | $(date) | Executing function without additional arguments..."
		"$MY_EXECUTION_PATH" &> piranha_MAGNET.out.log.txt ;
	elif [[ -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" = "true" ]] && [[ "$debug" = "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "WARNING!  | $(date) | DEBUG MODE (attempted) is not available when calling MAGNET! Running script in regular release mode... "
		echo "INFO      | $(date) | Executing function without additional arguments..."
		"$MY_EXECUTION_PATH" &> piranha_MAGNET.out.log.txt ;
	fi

	if [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" != "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "INFO      | $(date) | Executing function with -a flag arguments..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" != "true" ]] && [[ "$debug" = "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "WARNING!  | $(date) | DEBUG MODE (attempted) is not available when calling MAGNET! Running script in regular release mode... "
		echo "INFO      | $(date) | Executing function with -a flag arguments..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" = "true" ]] && [[ "$debug" != "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "INFO      | $(date) | Executing function with -a flag arguments..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" &> piranha_MAGNET.out.log.txt ;
	elif [[ ! -z "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_TO_RUN" = "MAGNET" ]] && [[ "$printLog" = "true" ]] && [[ "$debug" = "true" ]]; then
		MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}MAGNET-1.2.0/${FUNCTION_TO_RUN})"
		echo "WARNING!  | $(date) | DEBUG MODE (attempted) is not available when calling MAGNET! Running script in regular release mode... "
		echo "INFO      | $(date) | Executing function with -a flag arguments..."
		"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" &> piranha_MAGNET.out.log.txt ;
	fi

fi

##########################################################################################
######################################### END ############################################

}


############## Begin Options and Usage ###################

## Print usage
usage() {
  echo -n "${SCRIPT_NAME} [OPTION]... [FILE]...

 This is the main script for PIrANHA v0.4a4 (update Dec 26 22:53:10 CST 2020).

 ${bold}Options:${reset}
  -s, --shortlist   Short list of available functions
  -f, --func        Function, <function>
  -a, --args        Function arguments passed to <function>
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -v, --verbose     Output more information (items echoed to 'verbose')
  -d, --debug       Runs script in Bash debug mode (set -x)
  -h, --help        Display this help and exit
  -V, --version     Output version information and exit

 ${bold}OVERVIEW${reset}
 THIS SCRIPT is the 'master' script that runs the PIrANHA software package by specifying 
 the <function> to be run (-f flag) and passing user-specified arguments to that function. 
 If no function or arguments are given, then the program prints the help text and exits.
	Functions are located in the bin/ folder of the PIrANHA distribution. For detailed 
 information on the capabilities of PIrANHA, please refer to documentation posted on the 
 PIrANHA Wiki (https://github.com/justincbagley/piranha/wiki) or the PIrANHA website
 (https://justinbagley.org/piranha/). Developers can test prianha and its functions by 
 activating Bash debug mode (-d, --debug flags).

 ${bold}Usage examples:${reset}
    piranha -h                                   Show piranha help text and exit
    piranha -f <TAB>                             Get short list of available functions by dynamic completion
    piranha -f list                              Get detailed list of available functions by function
    piranha -f <function> -h                     Show help text for <function> and exit
    piranha -f <function> <args>                 Run <function> script with arguments (e.g. options flags)
    piranha -f <function> <args> -d              Run <function> script in Bash debug mode

 ${bold}CITATION${reset}
 Bagley, J.C. 2020. PIrANHA v0.4a4. GitHub repository, Available at:
	<https://github.com/justincbagley/piranha>.

 Created by Justin Bagley on Fri, Mar 8 12:43:12 CST 2019.
 Copyright (c) 2019-2020 Justin C. Bagley. All rights reserved.
"
}

############ SCRIPT OPTIONS
# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?[b-zB-Z]*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    -[!-]a) options+=("${1%%=*}" "${1#*=}") ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ ${1} = -?* ]]; do
  case ${1} in
    -i|--init) shift; source "${SCRIPT_PATH}/completions/init.sh"; exit 0 ;;
    -s|--shortlist) echo "2logeB10.r alignAlleles AnouraNEXUSPrepper assembleReads batchRunFolders BEAST_logThinner BEAST_PSPrepper BEASTPostProc BEASTReset BEASTRunner calcAlignmentPIS completeConcatSeqs completeSeqs concatenateSeqs concatSeqsPartitions dadiPostProc dadiRunner dadiUncertainty dropRandomHap dropTaxa ExaBayesPostProc FASTA2PHYLIP FASTA2VCF FASTAsummary fastSTRUCTURE geneCounter getBootTrees getDropTaxa getTaxonNames indexBAM iqtreePostProc list MAGNET makePartitions Mega2PHYLIP mergeBAM MLEResultsProc MrBayesPostProc NEXUS2MultiPHYLIP NEXUS2PHYLIP nQuireRunner PFSubsetSum phaseAlleles PHYLIP2FASTA phylip2fasta.pl PHYLIP2Mega PHYLIP2NEXUS PHYLIP2PFSubsets PHYLIPcleaner PHYLIPsubsampler PHYLIPsummary PhyloMapperNullProc phyNcharSumm pyRAD2PartitionFinder pyRADLocusVarSites RAxMLRunChecker RAxMLRunner renameForStarBeast2 renameTaxa RogueNaRokRunner RYcoder SNAPPRunner SpeciesIdentifier splitFASTA splitFile splitPHYLIP taxonCompFilter treeThinner trimSeqs vcfSubsampler shortlist"; exit 0 ;;
    -f|--func) shift; FUNCTION_TO_RUN="$1" ;;
    -a|--args) shift; FUNCTION_ARGUMENTS="$*" ;;
    -o|--output) shift; USER_OUTPUT_DIR="$1" ;;
    --delete) deleteOriginal=true ;;
    --saveDir) shift; saveDir="$1" ;;
    -h|--help) usage >&2; safeExit ;;
    --force) force=true ;;
    -V|--version) echo "${SCRIPT_BASENAME} $PIRANHA_VERSION"; safeExit ;;
    -v|--verbose) verbose=true ;;
    -l|--log) printLog=true ;;
    -q|--quiet) quiet=true ;;
    -d|--debug) debug=true ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
done

# Store the remaining part as arguments.
args+=("$@")
shift; FUNCTION_ARGUMENTS="$*" ;

############## End Options and Usage ###################


# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$'\n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Invoke the checkDependenices function to test for Bash packages.  Uncomment if needed.
# checkDependencies

# Run the script
piranha

# Exit cleanly
safeExit
