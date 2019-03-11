#!/usr/bin/env bash

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: piranha                                                                          #
  VERSION="v1.0.0"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Fri, Mar 8 12:43:12 CST 2019.                        #
# Last update: March 8, 2019                                                             #
# Copyright (c) 2019 Justin C. Bagley. All rights reserved.                              #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description: Main script for PIrANHA package, controls all other scripts.              #
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
  exit 1
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
  exit 1
fi

## Set bin/ Location
# -----------------------------------
#BIN_LOCATION="${SCRIPT_PATH}/bin/" # Update this path to find the piranha bin folder.
BIN_LOCATION=./bin/

## trapCleanup Function
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

## safeExit
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
homebrewDependencies=()
caskDependencies=()
gemDependencies=()




function piranha () {

######################################## START ###########################################
##########################################################################################

echo "
piranha v1.0.0, March 2019  (main script for PIrANHA v0.1.7+)  "
echo "Copyright (c) 2019 Justin C. Bagley. All rights reserved.  "
echo "----------------------------------------------------------------------------------------------------------"

############ I. READ INPUT, SET UP WORKSPACE, AND CHECK / ECHO MACHINE TYPE.
	echo "INFO      | $(date) |          Args: $args+ "
	echo "INFO      | $(date) |          Function: $FUNCTION_TO_RUN "
	echo "INFO      | $(date) |          Function arguments: $FUNCTION_ARGUMENTS "
	echoCDWorkingDir
	echo "INFO      | $(date) |          Checking machine type... "
	checkMachineType
	echo "INFO      | $(date) |          Found machine type ${machine}. "

	if [[ "${machine}" = "Linux" ]]; then
		## Test for file limits for current user and reset if necessary, only on Linux. Modified
		## from dDocent script (J. Puritz GitHub repository dDocent). Added here Mar 8, 2019.
		echo "INFO      | $(date) |          Checking file limits..."
		F_LIMIT=$(ulimit -n)
		export F_LIMIT
		if [[ "$F_LIMIT" != "unlimited" ]]; then
			N_LIMIT=$(( $NumInd * 10 ));
				if [[ "$F_LIMIT" -lt "$N_LIMIT" ]]; then
					ulimit -n $N_LIMIT;
			fi
		fi
	fi

############ II. CALL USER-SPECIFIED FUNCTION / SCRIPT IN BIN LOCATION. 

#	if [[ -s "$FUNCTION_TO_RUN" ]] && [[ "$FUNCTION_TO_RUN" != "NULL" ]]; then
#		echo "INFO      | $(date) |          Calling $FUNCTION_TO_RUN..."
#	fi

#	if [[ -s "$FUNCTION_TO_RUN" ]] && [[ "$FUNCTION_TO_RUN" != "NULL" ]] && [[ -s "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_ARGUMENTS" != "NULL" ]]; then
#		echo "INFO      | $(date) |          Calling $FUNCTION_TO_RUN ..."
#		echo "INFO      | $(date) |          Arguments: $FUNCTION_ARGUMENTS ..."
#	fi

	MY_EXECUTION_PATH="$(echo ${BIN_LOCATION}${FUNCTION_TO_RUN})"
	echo "INFO      | $(date) |          Execution path: $MY_EXECUTION_PATH"
	## $BIN_LOCATION
	## /Users/justinbagley/GitHub/PIrANHA-1.0/bin/
	## $MY_EXECUTION_PATH:
	## if test, then this $MY_EXECUTION_PATH should be: /Users/justinbagley/GitHub/PIrANHA-1.0/bin/test
	
	##	sh "$MY_EXECUTION_PATH" ;
	##	source ./test.sh a 'b c'
	if [[ "$FUNCTION_TO_RUN" = "NULL" ]] && [[ "$FUNCTION_ARGUMENTS" = "NULL" ]] || [[ ! -s "$FUNCTION_ARGUMENTS" ]] ; then
		echo "INFO      | $(date) |          No function specified. Echoing usage, then quitting... "

#		echo "$USAGE"
#		#exit 1

#		usage >&2; 
#		safeExit;
#		#exit 1

		usage;
		exit 1;

	elif [[ "$FUNCTION_TO_RUN" != "NULL" ]] && [[ ! -s "$FUNCTION_ARGUMENTS" ]] ; then

		source "$MY_EXECUTION_PATH" ;

	elif [[ "$FUNCTION_TO_RUN" != "NULL" ]] && [[ -s "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_ARGUMENTS" != "NULL" ]] ; then

		source "$MY_EXECUTION_PATH" '"$FUNCTION_ARGUMENTS"' ;

	fi

##########################################################################################
######################################### END ############################################

}


############## Begin Options and Usage ###################

## Print usage
usage() {
  echo -n "${SCRIPT_NAME} [OPTION]... [FILE]... <workingDir>

 This is the main script for PIrANHA (Bagley 2019).
 
 ${bold}Options:${reset}
  -f, --func        Function, <function>
  -a, --args        Function arguments passed to <function>
  -u, --username    Username for script
  -p, --password    User password
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit

 ${bold}Usage examples:${reset}
    $0 -f calcAlignmentPIS -a -h .       ## get help text for calcAlignmentPIS
    $0 -f calcAlignmentPIS -a -t 150 .   ## run calcAlignmentPIS with threshold at 
                                              N=150 alignments

 ${bold}OVERVIEW${reset}
 THIS SCRIPT runs the PIrANHA software package by specifying the <workingDir> (-d flag), 
 the <function> to run (-f flag), and any arguments to pass to that function (-a flag). 
 [In prep. ... ]. Functions are located in PIrANHA repository's bin/ folder. For detailed 
 information on the capabilities of PIrANHA, please refer to documentation posted on the 
 PIrANHA Wiki (https://github.com/justincbagley/PIrANHA-1.0/wiki) or the PIrANHA website 
 (https://justinbagley.org/PIrANHA-1.0/) for further information.

 ${bold}CITATION${reset}
 Bagley, J.C. 2019. PIrANHA v1.0. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA-1.0>.

 Created by Justin Bagley on Fri, Mar 8 12:43:12 CST 2019.
 Copyright (c) 2019 Justin C. Bagley. All rights reserved.
"
}

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
USER_SPEC_PATH=.
FUNCTION_TO_RUN=NULL
FUNCTION_ARGUMENTS=NULL

############ PARSE THE OPTIONS
while getopts 'd:f:a:h:V:u:p:v:l:q:s:d:-:' opt ; do
  case $opt in
## Script options:
    d) USER_SPEC_PATH=$OPTARG ;;
    f) FUNCTION_TO_RUN=$OPTARG ;;
    a) FUNCTION_ARGUMENTS=$OPTARG ;;
    h) usage >&2; safeExit ;;
    V) echo "$(basename $0) $VERSION"; safeExit ;;
    u) shift; username="$1" ;;
    p) shift; echo "Enter Password: "; stty -echo; read PASS; stty echo;
echo ;;
    v) verbose=true ;;
    l) printLog=true ;;
    q) quiet=true ;;
    s) strict=true;;
    d) debug=true;;
	-) LONG_OPTARG="${OPTARG#*=}"
        case $OPTARG in
           dir) USER_SPEC_PATH=$OPTARG ;;
           func) FUNCTION_TO_RUN=$OPTARG ;;
           args) FUNCTION_ARGUMENTS=$OPTARG ;;
           help) usage >&2; safeExit ;;
           version) echo "$(basename $0) $VERSION"; safeExit ;;
           username) shift; username=$OPTARG ;;
           password) shift; echo "Enter Password: "; stty -echo; read PASS; stty echo;
              echo ;;
           verbose) verbose=true ;;
           log) printLog=true ;;
           quiet) quiet=true ;;
           strict) strict=true;;
           debug) debug=true;;
           force) force=true ;;
           endopts) shift; break ;;
        esac ;;
## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       usage >&2;
       exit 1 ;;
    \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       usage >&2;
       exit 1 ;;
    *) die "Illegal option: '$1'." ;;
  esac
#  shift
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
	 usage >&2; safeExit;
fi
USER_SPEC_PATH="$1"
# USER_SPEC_PATH="$2"
# USER_SPEC_PATH="$1"
# FUNCTION_TO_RUN=NULL="$2"
# FUNCTION_ARGUMENTS=NULL="$3"

# Store the remaining part as arguments.
args+=("$@")

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
