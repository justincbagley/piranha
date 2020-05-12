#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: indexBAM.sh                                                                      #
  VERSION="v1.0.0"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Wed, May 6 9:52 am CDT 2020.                         #
# Last update: May 12, 2020                                                              #
# Copyright (c) 2020 Justin C. Bagley. All rights reserved.                              #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# THIS SCRIPT INDEXES PHASED BAM FILES OUTPUT BY THE phaseAlleles FUNCTION OF PIrANHA,   #
# GIVEN A WORKING DIRECTORY CONTAINING phaseAlleles OUTPUT (i.e. PREV SET AS OUTPUT DIR  #
# DURING A phaseAlleles RUN)                                                             #
#                                                                                        #
##########################################################################################

# Provide a variable with the location of this script.
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source Scripting Utilities
# -----------------------------------
# These shared utilities provide many functions which are needed to provide
# the functionality in this boilerplate. This script will fail if they can
# not be found.
# -----------------------------------

UTILS_LOCATION="${SCRIPT_PATH}/../lib/utils.sh" # Update this path to find the utilities.

if [[ -f "${UTILS_LOCATION}" ]]; then
  source "${UTILS_LOCATION}"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting..."
  exit 1
fi

# Source shared functions and variables
# -----------------------------------

FUNCS_LOCATION="${SCRIPT_PATH}/../lib/sharedFunctions.sh" # Update this path to find the shared functions.
VARS_LOCATION="${SCRIPT_PATH}/../lib/sharedVariables.sh" # Update this path to find the shared variables.

if [[ -f "${FUNCS_LOCATION}" ]] && [[ -f "${VARS_LOCATION}" ]]; then
  source "${FUNCS_LOCATION}" ;
  source "${VARS_LOCATION}" ;
else
  echo "Please find the files sharedFunctions.sh and sharedVariables.sh and add references to them in this script. Exiting... "
  exit 1
fi

# trapCleanup Function
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

# safeExit
# -----------------------------------
# Non destructive exit for when script exits naturally.
# Usage: Add this function at the end of every script.
# -----------------------------------
safeExit () {
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  if [[ -s ./args.txt ]]; then rm ./args.txt ; fi
  trap - INT TERM EXIT
  exit
}

# Set Flags
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

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${SCRIPT_NAME}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${SCRIPT_BASENAME}.log
# Save to standard user log location use: $HOME/Library/Logs/${SCRIPT_BASENAME}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${SCRIPT_BASENAME}.log"

# Check for Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.  Mac applications will be installed using
# Homebrew Casks. Ruby and gems via RVM.
# -----------------------------------
homebrewDependencies=()
caskDependencies=()
gemDependencies=()




indexBAM () {

######################################## START ###########################################
##########################################################################################

echo "INFO      | $(date) |----------------------------------------------------------------"
echo "INFO      | $(date) | indexBAM, v1.0.0 May 2020                                      "
echo "INFO      | $(date) | Copyright (c) 2020 Justin C. Bagley. All rights reserved.      "
echo "INFO      | $(date) |----------------------------------------------------------------"

######################################## START ###########################################
echo "INFO      | $(date) | Starting indexBAM... "
echo "INFO      | $(date) | # Step #1: Set up workspace, check machine type, and determine output file settings. "

################################# 1. SETUP

	###### A. START DEBUG MODE IF SET:
	if [[ "$MY_DEBUG_MODE_SWITCH" != "0" ]]; then set -xv; fi

	###### B. HANDLE WORKING DIRECTORY, INPUT DIRECTORY, OUTPUT DIRECTORY, AND REFERENCE ABSOLUTE PATH:
	## Starting directory:
	MY_STARTING_DIR="$(printf '%q\n' "$(pwd)")";
	
	## cwd & input directory:
	if [[ -s "$MY_INPUT_DIR" ]] && [[ "$MY_INPUT_DIR" != "NULL" ]]; then 
		cd "$MY_INPUT_DIR" ;
		echo "INFO      | $(date) | User-specified input path is: "
		echo "INFO      | $(date) | $PWD"
		MY_INPUT_DIR="$(printf '%q\n' "$(pwd)")";  # get absolute path to input dir
		MY_INPUT_DIR="$(echo $(realpath "$MY_INPUT_DIR")/$f)";
	elif [[ "$MY_INPUT_DIR" = "NULL" ]] || [[ "$MY_INPUT_DIR" = "." ]] || [[ "$MY_INPUT_DIR" = "./" ]] || [[ "$MY_INPUT_DIR" = "$PWD" ]] ; then
		MY_INPUT_DIR="$(printf '%q\n' "$(pwd)")";  # set absolute path to default input dir (when none is specified)
		MY_INPUT_DIR="$(echo $(realpath "$MY_INPUT_DIR")/$f)";
		echo "INFO      | $(date) | Starting input directory (using current dir): "
		echo "INFO      | $(date) | $PWD"	
	fi

	####### C. CHECK MACHINE TYPE:
	checkMachineType


echo "INFO      | $(date) | # Step #2: Index BAM files. "

################################# 2. MAIN SCRIPT

	## Chage to dir with allele sequences, the directory where the output of phaseAlleles was 
	## saved, e.g.:
	## cd /Volumes/G-DRIVE_USB/08_Projects/Centropogonids_polyploidy/pe_secapr_run1/allele_sequences 

	## phaseAlleles run subfolders for each individual end in '_phased', so use that to loop 
	## through them and index the BAM files with SAMtools, as follows:
	(
		for i in ./*_phased/; do
			cd "$i";
				echo "$i" >> ../indexBAM_folderOrder.list.txt ; 
				echo "INFO      | $(date) | Indexing BAM files in ${i} "
				cd intermediate_files/ ;
					MY_ZERO_BAMFILE="$(ls ./*_sorted_allele.0.bam | sed 's/\.\///g')";
					MY_ONE_BAMFILE="$(ls ./*_sorted_allele.1.bam | sed 's/\.\///g')";
					samtools index "$MY_ZERO_BAMFILE"  ;
					samtools index "$MY_ONE_BAMFILE"  ;
				cd ..;
			cd ..;
		done
	)


echo "INFO      | Done."
echo "----------------------------------------------------------------------------------------------------------"
echo ""


if [[ "$MY_DEBUG_MODE_SWITCH" != "0" ]]; then set +xv; fi
###### END DEBUG MODE

##########################################################################################
######################################### END ############################################

}




# ############ SCRIPT OPTIONS
# ## OPTION DEFAULTS ##
# MY_INPUT_DIR=NULL                          # Input dir containing unaligned, phased FASTA consensus sequences for each sample (one _0.fasta file and one _1.fasta file (for 0 and 1 alleles, respectively) per sample)
# MY_DEBUG_MODE_SWITCH=0

############ CREATE USAGE & HELP TEXTS
USAGE="
Usage: piranha -f $(basename "$0") [Options]...

 ${bold}Options:${reset}
  -i, --input     input (def: NULL) Mandatory path to input directory where PIrANHA phaseAlleles 
                  function was previously run, hence containing phaseAlleles run subfolders for 
                  each individual (sample)
  -h, --help      echo this help text and exit
  -V, --version   echo version and exit
  -d, --debug     debug (def: 0, off; 1, on) run function in Bash debug mode

 ${bold}OVERVIEW${reset}
 THIS SCRIPT automates indexing phased BAM files output by the phaseAlleles function of 
 PIrANHA (Bagley 2020). The script takes as input the path to a directory containing phaseAlleles 
 output (passed with the -i, --input flag); if no path is given, then the script assumes that
 the current working directory is in fact a phaseAlleles output directory (and will fail with 
 trapCleanup if this is not the case). This script works with the expected phaseAlleles output 
 directory structure, which should consist mainly of phaseAlleles run subfolders for each 
 individual (sample), which are appended with '_phased', and which include intermediate files 
 and final phased BAM files and FASTA alignments for each individual.
	This program runs on UNIX-like and Linux systems using commonly distributed utility 
 software, with usage as obtained by running the script with the -h flag. It has been 
 tested with Perl v5.1+ on macOS High Sierra (v10.13+) and Centos 5/6/7 Linux, but should 
 work on many other versions of macOS or Linux. There are no other dependencies.

 ${bold}Usage examples:${reset}
 Call the program using PIrANHA, as follows:

    piranha -f indexBAM -i <input>           Run program with user <reference> assembly
    piranha -f indexBAM --input <input>      Same as above but using long option flags
    piranha -f indexBAM -h                   Show this help text and exit

 ${bold}CITATION${reset}
 Bagley, J.C. 2020. PIrANHA v0.4a2. GitHub repository, Available at:
	<https://github.com/justincbagley/piranha>.

 ${bold}REFERENCES${reset}
 Bagley, J.C. 2020. PIrANHA v0.4a2. GitHub repository, Available at:
	<https://github.com/justincbagley/piranha>.

 Created by Justin Bagley on Wed, May 6 9:52 am CDT 2020.
 Copyright (c) 2020 Justin C. Bagley. All rights reserved.
"

if [[ -z "$*" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename "$0") $VERSION";
	exit
fi

############ CHECK ARGUMENTS
	# echo "$@"; echo "$#"; echo "$1" 
	# for i in "$@"; do
	# 	echo "$i";
	# done
	# MY_ARGS="$(echo "$@" | perl -pe $'s/\ /\n/')"
	# echo "$MY_ARGS"


############ CLEAN WORKING DIR, CAPTURE ARGUMENTS, SEND TO FILE FOR PARSING
	if [[ -s ./args.tmp ]]; then rm ./args.tmp ; fi ;
	if [[ -s ./args.txt ]]; then rm ./args.txt ; fi ;
	ALL_MY_ARGUMENTS="$(echo "$@")"
	echo "$ALL_MY_ARGUMENTS" > ./args.txt
	perl -p -i -e $'s/\-/\n\-/g' ./args.txt
	perl -p -i -e $'s/\-input/\-\-input/g' ./args.txt
	perl -p -i -e $'s/\-debug/\-\-debug/g' ./args.txt


############ MANUALLY PARSE THE OPTIONS FROM ARGS

### SET OPTIONS TO DEFAULT VALUES, EXCEPT WHERE VALUES WERE READ IN FROM USER ARGS
	if [[  "$(grep -h '\-i' ./args.txt | wc -l | perl -pe 's/\ //g')" = "0" ]] && [[  "$(grep -h '\-\-input' ./args.txt | wc -l | perl -pe 's/\ //g')" = "0" ]]; then
		MY_INPUT_DIR=NULL ;
	elif [[  "$(grep -h '\-i' ./args.txt | wc -l | perl -pe 's/\ //g')" != "0" ]] && [[  "$(grep -h '\-\-input' ./args.txt | wc -l | perl -pe 's/\ //g')" = "0" ]]; then
		MY_ARG="$(grep -h '\-i' ./args.txt | perl -pe 's/\-i//g' | perl -pe 's/\ //g')";
		MY_INPUT_DIR="$MY_ARG" ;
	elif [[  "$(grep -h '\-i' ./args.txt | wc -l | perl -pe 's/\ //g')" != "0" ]] && [[  "$(grep -h '\-\-input' ./args.txt | wc -l | perl -pe 's/\ //g')" != "0" ]]; then
		MY_ARG="$(grep -h '\-\-input' ./args.txt | perl -pe 's/\-\-input//g' | perl -pe 's/\ //g')";
		MY_INPUT_DIR="$MY_ARG" ;
	fi
#
	if [[  "$(grep -h '\-d' ./args.txt | wc -l | perl -pe 's/\ //g')" = "0" ]] && [[  "$(grep -h '\-\-debug' ./args.txt | wc -l | perl -pe 's/\ //g')" = "0" ]]; then
		MY_DEBUG_MODE_SWITCH=0 ;
	elif [[  "$(grep -h '\-d' ./args.txt | wc -l | perl -pe 's/\ //g')" != "0" ]] && [[  "$(grep -h '\-\-debug' ./args.txt | wc -l | perl -pe 's/\ //g')" = "0" ]]; then
		MY_ARG="$(grep -h '\-d' ./args.txt | perl -pe 's/\-d//g' | perl -pe 's/\ //g')";
		MY_DEBUG_MODE_SWITCH="$MY_ARG" ;
	elif [[  "$(grep -h '\-d' ./args.txt | wc -l | perl -pe 's/\ //g')" != "0" ]] && [[  "$(grep -h '\-\-debug' ./args.txt | wc -l | perl -pe 's/\ //g')" != "0" ]]; then
		MY_ARG="$(grep -h '\-\-debug' ./args.txt | perl -pe 's/\-\-debug//g' | perl -pe 's/\ //g')";
		MY_DEBUG_MODE_SWITCH="$MY_ARG" ;
		if [[ -z "$MY_DEBUG_MODE_SWITCH" ]] && [[ "$MY_DEBUG_MODE_SWITCH" != "0" ]] && [[ "$MY_DEBUG_MODE_SWITCH" != "1" ]]; then MY_DEBUG_MODE_SWITCH=1 ; fi
	fi
#


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
indexBAM

# Exit cleanly
safeExit

