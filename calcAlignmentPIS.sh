#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: calcAlignmentPIS.sh                                                              #
  VERSION="v1.3"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Wed, Mar 6 09:57:26 CST 2019.                        #
# Last update: March 7, 2019                                                             #
# Copyright (c) 2019 Justin C. Bagley. All rights reserved.                              #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# GENERATES AND RUNS CUSTOM RSCRIPT (PHYLOCH WRAPPER) TO CALCULATE NUMBER OF PARSIMONY-  #
# INFORMATIVE SITES (PIS) FOR ALL FASTA ALIGNMENT FILES IN WORKING DIR                   #
#                                                                                        #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_PIS_THRESHOLD_SWITCH=0

############ CREATE USAGE & HELP TEXTS
USAGE="Usage: $(basename $0) [Help: -h help] [Options: -t V --version]
 ## Help:
  -h   help text (also: --help) echo this help text and exit

 ## Options:
  -t   threshold (def: 0, off; other: N) '-t N' calls additional post-processing routine
       that subsets alignments to a threshold number, N, with the most parsimony-informative
       sites (PIS). Takes integer values of N > 0.
  -V   version (also: --version) echo version and exit

 OVERVIEW:
 THIS SCRIPT automates calculating the number of parsimony-informative sites (PIS) for each
 in a set of FASTA-formatted multiple sequence alignments (MSAs) in current working directory.
 To do this, calcAlignmentPIS.sh generates and runs a custom Rscript calling on functions in
 the R package phyloch (Heibl 2013). Thus parts of this script function as a wrapper for 
 phyloch, and R (v3.3+) and the phyloch package are important dependencies.
	Optionally, the user may specify for a threshold number of alignments, N, with the highest 
 PIS values to be saved using the -t flag. For example, '-t 150' sets N=150 and the program 
 will keep the 150 FASTA alignments with the most PIS. The N alignments will be copied to a 
 subfolder named 'pis_threshold_alignments/'.

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Heibl C. 2008 onwards. PHYLOCH: R language tree plotting tools and interfaces to diverse 
	phylogenetic software packages. Available at: <http://www.christophheibl.de/Rpackages.html.>

Created by Justin Bagley on Mon, Mar 4 22:00:01 CST 2019.
Copyright (c) 2019 Justin C. Bagley. All rights reserved.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

############ PARSE THE OPTIONS
while getopts 't:' opt ; do
  case $opt in
## Script options:
    t) MY_PIS_THRESHOLD_SWITCH=$OPTARG ;;
## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
  esac
done

echo "
calcAlignmentPIS, v1.3 March 2019  (part of PIrANHA v0.1.7+)  "
echo "Copyright (c) 2019 Justin C. Bagley. All rights reserved.  "
echo "------------------------------------------------------------------------------------------"
######################################## START ###########################################

echo "INFO      | $(date) | Step #1: Set up workspace and check machine type. "
############ I. SET UP WORKSPACE AND CHECK MACHINE TYPE.
## Nothing to do for working dir because script executes in current working dir (of execution/
## sourcing). Only echo cwd to screen:
MY_PATH="$(pwd -P | sed 's/$/\//g' | sed 's/.*\/\(.*\/\)\(.*\/\)/\.\.\.\/\1\2/g')"
echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "

echo "INFO      | $(date) |          Checking machine type... "
###### CHECK MACHINE TYPE:
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "INFO      | $(date) |          Found machine type ${machine}. "


echo "INFO      | $(date) | Step #2: Create custom Rscript. "
############ II. CREATE CUSTOM RSCRIPT FOR ESTIMATING PARSIMONY INFORMATIVE SITES.
echo "INFO      | $(date) |          Building custom calcAlignmentPIS R script for calculating parsimony-informative sites (PIS) from FASTA files... "

## NOTE: This Rscript is essentially an automation wrapper based on existing functions for
## reading FASTA alignments and calculating PIS in the R package phyloch, which is only 
## available from author Christoph Hiebl's website at URL: http://www.christophheibl.de/Rpackages.html.
## The package phyloch MUST be installed before running this script.

echo "
#!/usr/bin/env Rscript

################################### calcAlignmentPIS.R #####################################
## R code for looping through set of FASTA files in dir and calculating parsimony-informative
## sites for each alignment, then saving and outputting to file. Written for Anoura UCE
## data analysis, March 6, 2019

## Be sure to do the following OUTSIDE of R before running R on your machine (assuming
## you have set up the prepR function in your ~/.bashrc (Linux) or ~/.bash_profile (Mac)
## files on machine).
## $ prepR

############ I. SETUP
##--Load needed packages, R code, or other prelim stuff. Install packages if not present.
packages <- c('phyloch')
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
	install.packages(setdiff(packages, rownames(installed.packages())))
}
library(phyloch)
#setwd('$MY_PATH')	# With my current R setup, no need to set wd because this is done automatically at start up.
getwd()

############ II. CALCULATE PARSIMONY-INFORMATIVE SITES (PIS) FOR ALL FASTA FILES.
#files <- list.files(path='/Users/justinbagley/Documents/2\ -\ by\ Project/Anoura_Phylo/FINAL_DATA/alldata/STACEY/FASTA_subsets', pattern='*.fas', full.names=TRUE, recursive=FALSE)
files <- list.files(path=getwd(), pattern='*.fas', full.names=TRUE, recursive=FALSE)
iterations <- length(files)
variables <- 1
output <- matrix(ncol=variables, nrow=iterations)

## Use loop through FASTA files in files (above) to calculate PIS for each file and save
## to output matrix:
for(i in 1:iterations){
	# Read FASTA file
	fas <- read.fas(files[i])
	# Apply function to estimate parsimony-informative sites (PIS)
	pis_out <- pis(fas, abs = TRUE, use.ambiguities = FALSE)
	# Add PIS result to data matrix
	output[i,] <- pis_out
}

write.table(output, 'pis_output_table.txt', sep='\t', quote=FALSE, row.names=FALSE, col.names=TRUE)

output

write.table(files, 'input_file_order.txt', sep='\t')

######################################### END ############################################
" > calcAlignmentPIS.r


echo "INFO      | $(date) | Step #3: Run the Rscript (which also saves output and results to file). "
############ III. RUN RSCRIPT.
	R CMD BATCH ./calcAlignmentPIS.R ;


echo "INFO      | $(date) | Step #4: Conduct post-processing of R output. "
############ IV. CONDUCT POST-PROCESSING OF R OUTPUT USING A VARIETY OF OPERATIONS.
echo "INFO      | $(date) |          Editing PIS output table... "
	sed 's/\"//g' input_file_order.txt | sed '1d' | perl -p -e 's/^.*\t.*\///g' > input_file_order_filenames.txt ;

	if [[ "${machine}" = "Mac" ]]; then
		sed -i '' '1d' pis_output_table.txt ;
	fi
	if [[ "${machine}" = "Linux" ]]; then
		sed -i '1d' pis_output_table.txt ; 
	fi

	echo pis file | perl -pe $'s/\ /\t/g' > header.tmp ;
	paste pis_output_table.txt input_file_order_filenames.txt > pis_results_table_headless.txt ;
	sort -n -r pis_results_table_headless.txt > pis_results_table_headless_revsort.txt ;
	cat header.tmp pis_results_table_headless_revsort.txt > pis_results_table_revsort.txt ;


if [[ "$MY_PIS_THRESHOLD_SWITCH" != "0" ]]; then
	echo "INFO      | $(date) |          Editing PIS output table... "

		keepPISThresholdAlignments () {
			MY_N_ALIGN_CUTOFF="$MY_PIS_THRESHOLD_SWITCH"
		
			cp ./pis_results_table_revsort.txt ./pis.tmp ;
		
			if [[ "${machine}" = "Mac" ]]; then
				sed -i '' '1d' ./pis.tmp ;
			fi
			if [[ "${machine}" = "Linux" ]]; then
				sed -i '1d' ./pis.tmp ;
			fi

			perl -p -i -e $'s/^.*\t//g' ./pis.tmp ;
		
			head -n"$MY_N_ALIGN_CUTOFF" ./pis.tmp > ./pis_results_table_revsort_top"$MY_N_ALIGN_CUTOFF"_filenames.txt ;
		
			mkdir pis_threshold_alignments/;
		
			(
				while read line; do
					cp "$line" ./pis_threshold_alignments/ ;
				done < ./pis_results_table_revsort_top"$MY_N_ALIGN_CUTOFF"_filenames.txt ;
			)
		}
		
		## DON'T FORGET TO RUN THE FUNCTION!!!
		keepPISThresholdAlignments

fi


echo "INFO      | $(date) | Step #5: Clean up workspace. "
echo "INFO      | $(date) |          Cleaning up workspace by removing temporary files generated during run... "
############ V. CLEAN UP WORKSPACE BY REMOVING TEMPORARY FILES.
	rm ./*.tmp ;
	rm ./pis_results_table_headless_revsort.txt ./pis_results_table_headless.txt ./pis_output_table.txt ./input_file_order_filenames.txt ./input_file_order.txt ;

#echo "INFO      | $(date) | Successfully created PHYLIP ('.phy') input file from the existing NEXUS file... "
#echo "INFO      | $(date) | Done. Bye. "
echo "------------------------------------------------------------------------------------------"
if [[ "$MY_PIS_THRESHOLD_SWITCH" = "0" ]]; then
	echo "output file(s): ./pis_results_table_revsort.txt"
fi
if [[ "$MY_PIS_THRESHOLD_SWITCH" != "0" ]]; then
	echo "output file(s)/folder(s): ./pis_results_table_revsort.txt"
	echo "                          ./pis_results_table_revsort_top${MY_N_ALIGN_CUTOFF}_filenames.txt"
	echo "                          ./pis_threshold_alignments/"
fi
echo ""
#
#
#
######################################### END ############################################

exit 0

