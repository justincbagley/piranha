#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: fastSTRUCTURE.sh                                                                 #
  VERSION="v1.1.2"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Wed, 27 Jul 2016 00:48:14 -0300.                     #
# Last update: March 11, 2019                                                            #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# INTERACTIVE SHELL SCRIPT FOR RUNNING fastSTRUCTURE (Raj et al. 2014) ON BIALLELIC SNP  #
# DATASETS                                                                               #
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
function trapCleanup() {
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
function safeExit() {
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
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




function fastSTRUCTURE () {

######################################## START ###########################################
##########################################################################################

echo "INFO      | $(date) |----------------------------------------------------------------"
echo "INFO      | $(date) | fastSTRUCTURE, v1.1.2 March 2019  (part of PIrANHA v1.0.0)     "
echo "INFO      | $(date) | Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved. "
echo "INFO      | $(date) |----------------------------------------------------------------"

######################################## START ###########################################
echo "INFO      | $(date) | Step #1: Setup. Read user input, set environmental variables. "
	MY_FASTSTRUCTURE_WKDIR="$(pwd -P)" ;

	read -p "INPUT     | $(date) |          Enter the path to a working copy of fast structure on your machine, \
e.g. '/Applications/STRUCTURE-fastStructure-e47212f/structure.py' : " fsPATH 

	read -p "INPUT     | $(date) |          Enter the name of your input file (remember it should have no extension, e.g. hypostomus_str): " fsInput

	read -p "INPUT     | $(date) |          Enter the lowest value of K to be modeled (e.g. 1) : " lK

	read -p "INPUT     | $(date) |          Enter the upper value of K to be modeled (e.g. 10) : " uK

	read -p "INPUT     | $(date) |          Specify a name (e.g. hypostomus_noout_simple) for the output: " fsOutput 

	MY_FASTSTRUCTURE_PATH="$(echo $fsPATH)" ;


echo "INFO      | $(date) | Step #2: Run fastSTRUCTURE on range of K specified by user. "
echo "INFO      | $(date) |          Modeling K = $lK to $uK clusters in fastSTRUCTURE. "

(
	for (( i=$lK; i<=$uK; i++ )); do
		echo "$i";
		python "$MY_FASTSTRUCTURE_PATH" -K "$i" --input="$MY_FASTSTRUCTURE_WKDIR/$fsInput" --output="$fsOutput" --format=str --full --seed=100 ;
	done
)

echo "INFO      | $(date) |          fastSTRUCTURE runs completed. "


echo "INFO      | $(date) | Step #3: Estimate model complexity. "
###### Obtain an estimate of the model complexity for each set of runs (per species):
	MY_CHOOSEK_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/chooseK.py/g')" ;

	python "$MY_CHOOSEK_PATH" --input="$fsOutput" > chooseK.out.txt ;

echo "INFO      | $(date) |          Finished estimating model complexity. "
	cat chooseK.out.txt ;


echo "INFO      | $(date) | Step #4: Visualize results. "
###### Use DISTRUCT to create graphical output of results corresponding to the best K value modeled.
	read -p "INPUT     | $(date) |          Enter the value of K that you want to visualize : " bestK ;

	MY_DISTRUCT_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/distruct.py/g')" ;

	python "$MY_DISTRUCT_PATH" -K "$bestK" --input="$MY_FASTSTRUCTURE_WKDIR/$fsOutput" --output="$fsOutput_distruct.svg" ;


#echo "INFO      | $(date) | Done!!! fastSTRUCTURE analysis complete."
#echo "Bye.
#"


##########################################################################################
######################################### END ############################################

}



############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
# USER_SPEC_PATH=.
MY_PIS_THRESHOLD_SWITCH=0

############ CREATE USAGE & HELP TEXTS
USAGE="Usage: $(basename $0) [OPTION]...

 ${bold}Options:${reset}
  -t   threshold (def: 0, off; other: N) '-t N' calls additional post-processing routine
       that subsets alignments to a threshold number, N, with the most parsimony-informative
       sites (PIS). Takes integer values of N > 0.
  -h   help text (also: --help) echo this help text and exit
  -V   version (also: --version) echo version and exit

 ${bold}OVERVIEW${reset}
 THIS SCRIPT automates calculating the number of parsimony-informative sites (PIS) for each
 in a set of FASTA-formatted multiple sequence alignments (MSAs) in current working directory.
 To do this, calcAlignmentPIS.sh generates and runs a custom Rscript calling on functions in
 the R package phyloch (Heibl 2013). Thus parts of this script function as a wrapper for
 phyloch, and R (v3.3+) and the phyloch package are important dependencies.
	Optionally, the user may specify for a threshold number of alignments, N, with the highest
 PIS values to be saved using the -t flag. For example, '-t 150' sets N=150 and the program
 will keep the 150 FASTA alignments with the most PIS. The N alignments will be copied to a
 subfolder named 'pis_threshold_alignments/'.

 ${bold}CITATION${reset}
 Bagley, J.C. 2019. PIrANHA v1.0.0. GitHub repository, Available at:
	<https://github.com/justincbagley/PIrANHA>.

 ${bold}REFERENCES${reset}
 Heibl C. 2008 onwards. PHYLOCH: R language tree plotting tools and interfaces to diverse
	phylogenetic software packages. Available at: <http://www.christophheibl.de/Rpackages.html.>

 Created by Justin Bagley on Wed, Mar 6 09:57:26 CST 2019.
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
fastSTRUCTURE

# Exit cleanly
safeExit