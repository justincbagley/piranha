#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                             BEASTReset v0.1.0, August 2017                             #
#  SHELL SCRIPT AUTOMATING RESETTING THE RANDOM STARTING SEEDS FOR n SHELL SCRIPTS       #
#  CORRESPONDING TO n BEAST RUNS (SETUP IN A SERIES OF n RUN FOLDERS) DESTINED FOR A     #
#  REMOTE SUPERCOMPUTER, AND IF DESIRED ALSO RE-QUEUING THE RUNS ON THE SUPERCOMPUTER    #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further info. Last update: August 24, 2017.     #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

##################################### BEASTReset.sh ######################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_RERUN_DIR_LIST=list.txt
MY_RUN_SCRIPT=beast_pbs.sh
MY_SC_MANAGEMENT_SYS=PBS

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] [Options: -i s m] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -i   rerunList (def: $MY_RERUN_DIR_LIST) name of BEAST run sub-folders that need to be reset/rerun
  -s   scriptName (def: $MY_RUN_SCRIPT) name of shell/bash run submission script (must be the
       same for all runs, or entered with wildcards to accommodate all names used, e.g. 'beast*.sh')
  -m   manager (def: $MY_SC_MANAGEMENT_SYS; other: SLURM) name of scheduling and resource manager system on the 
       supercomputer

 OVERVIEW
 THI SCRIPT expects to start from a set of BEAST run sub-folders in the current working 
 directory. Each sub-folder will correspond to a run that has been (or will be) submitted 
 to a remote supercomputing cluster with a Linux operating system, and either a TORQUE/PBS 
 or SLURM scheudling and resource management system. As a consequence, each run sub-folder
 will contain a run submission shell script for queuing on the supercomputer. BEASTReset 
 saves the user time by automating the resetting of the random starting number seeds in 
 each submission shell script. 
 	This script accepts as mandatory input the name of the workingDir where the program 
 should be run. The main options determining the form of a run is the -i flag, which takes 
 the name of a list file (e.g. 'list.txt' by default) containing names of sub-folders to be 
 analyzed, one per line; and the -s flag, which specifies the name of the submission 
 shell scripts (which must all be the same, or be entered with wildcards to accomodate all 
 names used, e.g. 'beast*.sh'). These options are critical for customizing the run. The -m 
 flag tells the program whether the supercomputer uses a TORQUE/PBS or SLURM manager; if 
 '-mPBS', the shell scripts must have PBS format (be queable using qsub); if '-mSLURM', the 
 shell scripts must have SBATCH format.
	After detecting the local computing environment with the uname utility, BEASTReset.sh
 will perform one of two general operations, with two sub-options (a or b). (1a) If the 
 environment is Mac OS X and no list of sub-folders is provided, then the script assumes the 
 environment is the user's local Mac machine, and it goes through all sub-folders, looks for 
 the submission script (-s flag), and then resets the seed in each script. In a similar case, 
 the script (1b) accepts the list of sub-folders that failed (specified using the -i flag) 
 and only modifies shell scripts in this list file. Alternatively, (2a) if the environment 
 is Linux and no list file is specified, then the script assumes the environment is the remote 
 supercomputer, and it will go through all sub-folders and reset the seed in each submission 
 script (-s flag). Again, the script will also (2b) accept a list of sub-folders that failed 
 (-i flag), which must contain paths to run sub-folders on the supercomputer, with on path 
 per line). 
	Currently, the only dependency for BEASTReset is Python v2.7++ or v3.5++. BEASTReset is
 part of the PIrANHA software repository (Bagley 2017). See the BEASTReset and PIrANHA 
 README files for additional information.

 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.5. GitHub repository, Available at: 
	<http://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Bagley, J.C. 2017. PIrANHA v0.1.5. GitHub repository, Available at: 
	<http://github.com/justincbagley/PIrANHA>.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'i:s:m:' opt ; do
  case $opt in

## RAxML and datafile options:
    i) MY_RERUN_DIR_LIST=$OPTARG ;;
    s) MY_RUN_SCRIPT=$OPTARG ;;
    m) MY_SC_MANAGEMENT_SYS=$OPTARG ;;

## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
echo "$Usage"
  exit 1
fi
USER_SPEC_PATH="$1"		## Name of working dir for run is a mandatory positional parameter.

echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$USER_SPEC_PATH "	


echo "
##########################################################################################
#                             BEASTReset v0.1.0, August 2017                             #
##########################################################################################
"

######################################## START ###########################################
echo "INFO      | $(date) | Starting BEASTReset script... "
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set new path/dir environmental variable to user specified path, then create useful
##--shell functions and variables:
if [[ "$USER_SPEC_PATH" = "$(echo $(pwd))" ]]; then
	MY_PATH=`pwd -P`
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "
elif [[ "$USER_SPEC_PATH" != "$(echo $(pwd))" ]]; then
	MY_PATH=$USER_SPEC_PATH
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "	
else
	echo "WARNING!  | $(date) |          Null working directory path. Quitting... "
	exit 1
fi


####### CHECK MACHINE TYPE
##--This idea and code came from the following URL (Lines 87-95 code is reused here): 
##--https://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux 
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

if [[ "${machine}" = "Mac" ]]; then

####### CASE 1: LOCAL MACHINE - ONLY FIX SUBMISSION SCRIPTS BY CHANGING RANDOM SEEDS:

####### RUN LOCALLY:
(
	cat "$MY_RERUN_DIR_LIST" | while read i; do 
		cd "$i"; 
		echo "$i"; 
			j=./"$MY_RUN_SCRIPT"
			MY_RANDOM_SEED="$(python -c 'import random; print random.randint(10000,100000000000)')"; 
			echo $MY_RANDOM_SEED; 
			sed -i '' "s/\-seed\ [0-9]*\ /\-seed\ $MY_RANDOM_SEED\ /" "$j"; 
		cd ..; 
	done
)

fi

## Example of the line above, as bash one-liner, using a specific $MY_RERUN_DIR_LIST list file name:
## (
## cat newseed_redo_dir_list_mycompu.txt | while read i; do cd "$i";  echo "$i";  j=./beast_pbs.sh; MY_RANDOM_SEED="$(python -c 'import random; print random.randint(10000,100000000000)')";  echo $MY_RANDOM_SEED;  sed -i '' "s/\-seed\ [0-9]*\ /\-seed\ $MY_RANDOM_SEED\ /" "$j";  cd ..;  done
## )


####### CASE 2: SUPERCOMPUTER ENVIRONMENT - FIX SUBMISSION SCRIPTS AND RUN THEM ON THE SUPERCOMPUTER,
####### EXPECTING DIFFERENT INPUT FILENAMES/FORMATS VARYING BY MANAGEMENT SYSTEM (PBS or SLURM):

if [[ "${machine}" = "Linux" ]] && [[ "$MY_SC_MANAGEMENT_SYS" = "PBS" ]]; then

####### RUN ON LINUX SUPERCOMPUTER WITH TORQUE/PBS MANAGER:
(
	cat "$MY_RERUN_DIR_LIST" | while read i; do 
		cd "$i"; 
		echo "$i"; 
			j=./"$MY_RUN_SCRIPT"
			MY_RANDOM_SEED="$(python -c 'import random; print random.randint(10000,100000000000)')"; 
			echo $MY_RANDOM_SEED; 
			sed -i "s/\-seed\ [0-9]*\ /\-seed\ $MY_RANDOM_SEED\ /" "$j"; 

			qsub ./"$MY_RUN_SCRIPT"

		cd ..; 
	done
)

fi


if [[ "${machine}" = "Linux" ]] && [[ "$MY_SC_MANAGEMENT_SYS" = "SLURM" ]]; then

####### RUN ON LINUX SUPERCOMPUTER WITH SLURM MANAGER:
(
	cat "$MY_RERUN_DIR_LIST" | while read i; do 
		cd "$i"; 
		echo "$i"; 
			j=./"$MY_RUN_SCRIPT"
			MY_RANDOM_SEED="$(python -c 'import random; print random.randint(10000,100000000000)')"; 
			echo $MY_RANDOM_SEED; 
			sed -i "s/\-seed\ [0-9]*\ /\-seed\ $MY_RANDOM_SEED\ /" "$j"; 

			sbatch ./"$MY_RUN_SCRIPT"

		cd ..; 
	done
)

fi


#
#
#
######################################### END ############################################

exit 0
