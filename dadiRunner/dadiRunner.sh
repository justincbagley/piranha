#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: dadiRunner.sh                                                                    #
  version="v0.1.1"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley on Thu, 20 Apr 2017 17:14:32 -0400                      #
# Last update: May 16, 2017                                                              #
# Copyright (c) 2017-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>                                               #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR AUTOMATING RUNNING ∂a∂i ON A REMOTE SUPERCOMPUTING CLUSTER            #
#                                                                                        #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_SNP_DATA_FILE=dadiIn
MY_NUM_INDEP_RUNS=10
MY_SC_WALLTIME=48:00:00
MY_DADI_VERSION_SWITCH=0

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -i n w] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -i   SNPInput (def: $MY_SNP_DATA_FILE) SNP data input file
  -n   nRuns (def: $MY_NUM_INDEP_RUNS) number of independent ∂a∂i runs per model (.py file)
  -w   walltime (def: $MY_SC_WALLTIME) wall time (run time; hours:minutes:seconds) passed to 
       supercomputer 
  -v   dadiVersion (def: 0, ∂a∂i v1.7++; 1, ∂a∂i-mod v1.6.3 from Tine et al. 2014) version of 
       ∂a∂i for which to prepare and run shell scripts/files for runs
  
 OVERVIEW
 Automates organizing and running one or more demographic models in ∂a∂i (Gutenkunst et 
 al. 2009) using data from a SNP input file, in ∂a∂i format, on a remote supercomputing 
 cluster. The script is called and gathers information on the current working dir and files
 on the local machine; it is also passed the path to the destination folder, and other details 
 needed for running on the supercomputer, as given in a configuration file, "./dadi_runner.cfg." 
 To take full advantage of the script's capacity, user must have installed recently updated 
 ∂a∂i from the developers (v1.7++), as well as the "∂a∂i-mod", or modified v1.6.3 version of
 ∂a∂i from Tine et al. (2014) (available from: https://popgensealab.wordpress.com/dadi-inference/). 
 Requires proper ∂a∂i install (e.g. several dependencies, including Python and 
 several Python packages), as well as paswordless ssh access (see PIrANHA README for 
 additional details). I have generated a guide to installing and using the ∂a∂i-mod version,
 which is available as a Gist from my GitHub account available at the following URL:
 https://gist.github.com/justincbagley/ecab6c39b62f89458b8ed3fab98fbeb2.
 
 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<http://github.com/justincbagley/RAPFX>.

 REFERENCES
 Gutenkunst RN, Hernandez RD, Williamson SH, Bustamante CD (2009) Inferring the joint 
 	demographic history of multiple populations from multidimensional SNP frequency data. 
 	PLOS Genetics 5(10): e1000695.

Created by Justin Bagley on Thu, 20 Apr 2017 17:14:32 -0400
Copyright (c) 2017-2019 Justin C. Bagley. All rights reserved.
"

verboseHelp="Usage: $(basename "$0") [Help: -h help H Help] [Options: -i n w] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -i   SNPInput (def: $MY_SNP_DATA_FILE) SNP data input file
  -n   nRuns (def: $MY_NUM_INDEP_RUNS) number of independent ∂a∂i runs per model (.py file)
  -w   walltime (def: $MY_SC_WALLTIME) wall time (run time in hours:minutes:seconds) passed to supercomputer 
  -v   dadiVersion (def: 0, ∂a∂i v1.7++; 1, ∂a∂i-mod v1.6.3 from Tine et al. 2014) version of 
       ∂a∂i for which to prepare and run shell scripts/files for runs

 OVERVIEW
 Automates organizing and running one or more demographic models in ∂a∂i (Gutenkunst et 
 al. 2009) using data from a SNP input file, in ∂a∂i format, on a remote supercomputing 
 cluster. The script is called and gathers information on the current working dir and files
 on the local machine; it is also passed the path to the destination folder, and other details 
 needed for running on the supercomputer, as given in a configuration file, "./dadi_runner.cfg." 
 To take full advantage of the script's capacity, user must have installed recently updated 
 ∂a∂i from the developers (v1.7++), as well as the "∂a∂i-mod", or modified v1.6.3 version of
 ∂a∂i from Tine et al. (2014) (available from: https://popgensealab.wordpress.com/dadi-inference/). 
 Requires proper ∂a∂i install (e.g. several dependencies, including Python and 
 several Python packages), as well as paswordless ssh access (see PIrANHA README for 
 additional details). I have generated a guide to installing and using the ∂a∂i-mod version,
 which is available as a Gist from my GitHub account available at the following URL:
 https://gist.github.com/justincbagley/ecab6c39b62f89458b8ed3fab98fbeb2.

 DETAILS
 The -i flag sets the name of the SNP data input file copied into each run folder and 
 later passed to ∂a∂i by a shell script. The default name is 'dadiIn', with no extension.

 The -n flag sets the number of independent ∂a∂i runs to be submitted to the supercomputer
 for each model specified in a .py file in the current working directory. The default is 10
 runs.

 The -w flag passes the expected amount of time for each ∂a∂i run to the supercomputer
 management software, in hours:minutes:seconds (00:00:00) format. If your supercomputer does 
 not use this format, or does not have a walltime requirement, then you will need to modify 
 the shell scripts for each run and re-run them without specifying a walltime.
 
 The -v flag allows users to specify using one of two different versions of ∂a∂i. The default
 value of 0 runs ∂a∂i input .py files normally, in the regular environment, and thus will draw
 on the most recent ∂a∂i version installed on the supercomputer. However, a 1 option allows 
 running ∂a∂i v1.6.3 as modified by Tine et al. (2014); as per my Gist linked in the Overview
 section above, this mod version can be installed in a Python virtual environment that you 
 must set up on the supercomputer. I recommend following my instructions and creating a 
 virtualenv named "∂a∂i-mod" for this version. To use ∂a∂i-mod, you must supply a separate 
 "virtualenv.txt" file containing a block of code that loads the corresponding virtual environment 
 on your supercomputer account. Code from this file will be added to each shell script (for each 
 independent run), in order tell the supercomputer to enter the ∂a∂i-mod virtual environment 
 prior to passing each .py file to Python. An example virtualenv.txt block is provided.
 
		## Usage examples: 
		"$0" .
		"$0" -n 5 .
		"$0" -i <SNPInput filename> .
		"$0" -i <SNPInput filename> -n 20 .			## Ex.: changing no. independent runs.
		"$0" -i <SNPInput filename> -v 1 .			## Ex.: changing to ∂a∂i-mod version (requires virtualenv.txt file).
		"$0" -i <SNPInput filename> -n 20 -w 24:00:00 .	## Ex.: changing run walltime.
	
 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<http://github.com/justincbagley/RAPFX>.

 REFERENCES
 Gutenkunst RN, Hernandez RD, Williamson SH, Bustamante CD (2009) Inferring the joint 
 	demographic history of multiple populations from multidimensional SNP frequency data. 
 	PLOS Genetics 5(10): e1000695.

Created by Justin Bagley on Thu, 20 Apr 2017 17:14:32 -0400
Copyright (c) 2017-2019 Justin C. Bagley. All rights reserved.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

if [[ "$1" == "-H" ]] || [[ "$1" == "-Help" ]]; then
	echo "$verboseHelp"
	exit
fi

if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) ${version}";
	exit
fi

############ PARSE THE OPTIONS
while getopts 'i:n:w:v:' opt ; do
  case $opt in

## ∂a∂i options:
    i) MY_SNP_DATA_FILE=$OPTARG ;;
    n) MY_NUM_INDEP_RUNS=$OPTARG ;;
    w) MY_SC_WALLTIME=$OPTARG ;;
    v) MY_DADI_VERSION_SWITCH=$OPTARG ;;

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
USER_SPEC_PATH="$1"

echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$USER_SPEC_PATH "	

echo "
##########################################################################################
#                             dadiRunner v0.1.1, April 2017                              #
##########################################################################################"

######################################## START ###########################################
echo "INFO      | $(date) | Starting dadiRunner pipeline... "
echo "INFO      | $(date) | STEP #1: SETUP. "
echo "INFO      | $(date) |          Setting up variables, including those specified in the cfg file..."
###### Set new path/dir environmental variable to user specified path, then create useful
##--shell functions and variables:
if [[ "$USER_SPEC_PATH" = "$(echo $(pwd))" ]]; then
	MY_WD_PATH=`pwd -P`
	echo "INFO      | $(date) |          Setting working directory to: $MY_WD_PATH "
elif [[ "$USER_SPEC_PATH" != "$(echo $(pwd))" ]]; then
	MY_WD_PATH=$USER_SPEC_PATH
	echo "INFO      | $(date) |          Setting working directory to: $MY_WD_PATH "	
else
	echo "WARNING!  | $(date) |          Null working directory path. Quitting... "
	exit
fi
	calc () { 
		bc -l <<< "$@" 
}
	MY_INPUT_PY_FILES=./*.py
	MY_NUM_PY_FILES="$(ls . | grep "\.py$" | wc -l)"
echo "INFO      | $(date) |          Number of .py ∂a∂i input files read: $MY_NUM_PY_FILES"	## Check number of input files read into program.
	MY_SSH_ACCOUNT="$(grep -n "ssh_account" ./dadi_runner.cfg | \
	awk -F"=" '{print $NF}')"
	MY_SC_DESTINATION="$(grep -n "destination_path" ./dadi_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"
	MY_SC_BIN="$(grep -n "bin_path" ./dadi_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"
	MY_EMAIL_ACCOUNT="$(grep -n "email_account" ./dadi_runner.cfg | \
	awk -F"=" '{print $NF}')"
	MY_SC_PBS_WKDIR_CODE="$(grep -n "pbs_wkdir_code" ./dadi_runner.cfg | \
	awk -F"=" '{print $NF}')"
	## MY_NUM_INDEP_RUNS="$(grep -n "n_runs" ./dadi_runner.cfg | awk -F"=" '{print $NF}')"


echo "INFO      | $(date) | STEP #2: MAKE 9 COPIES PER INPUT .PY FILE FOR A TOTAL OF $MY_NUM_INDEP_RUNS RUNS OF EACH MODEL or "
echo "INFO      | $(date) |          .PY USING DIFFERENT RANDOM SEEDS. "
echo "INFO      | $(date) |          Looping through original .py's and making 9 copies per file, renaming \
each copy with an extension of '_#.py'"
echo "INFO      | $(date) |          where # ranges from 2 - $MY_NUM_INDEP_RUNS. *** IMPORTANT ***: The starting .py files MUST \
end in 'run.py'."
	(
		for (( i=2; i<="$MY_NUM_INDEP_RUNS"; i++ )); do
		    find . -type f -name '*run.py' | while read FILE ; do
		        newfile="$(echo ${FILE} | sed -e 's/\.py/\_'$i'\.py/')" ;
		        cp "${FILE}" "${newfile}" ;
		    done
		done
	)

	(
		find . -type f -name '*run.py' | while read FILE ; do
			newfile="$(echo ${FILE} |sed -e 's/run\.py/run_1\.py/')" ;
			cp "${FILE}" "${newfile}" ;
		done
	)

	rm ./*run.py		## Remove the original "run.py" input files so that only .py files
	            		## annotated with their run numbers 1 - $MY_NUM_INDEP_RUNS remain.


echo "INFO      | $(date) | STEP #3: MAKE DIRECTORIES FOR RUNS AND GENERATE SHELL SCRIPTS UNIQUE TO EACH \
INPUT FILE FOR DIRECTING EACH RUN; MAKE SCRIPTS SPECIFIC TO ∂a∂i VERSION INDICATED BY USER. "
##--Loop through the input .py files and do the following for each file: (A) generate one 
##--folder per .py file with the same name as the file, only minus the extension; (B) 
##--create a shell script with the name "dadi_pbs.sh" that is specific to the input 
##--and can be used to submit job to supercomputer; (C) move the PBS shell script into 
##--the folder whose name corresponds to the particular input .py file being manipulated
##--at the same pass in the loop.
#
##--Conditionally use one of two versions of the loop through input files, one making scripts
##--for regular ∂a∂i runs, the other making scripts including the Python virtual environment
##--code for ∂a∂i-mod runs.
if [[ "$MY_DADI_VERSION_SWITCH" -eq "0" ]]; then
	(
		for i in $MY_INPUT_PY_FILES; do
			mkdir "$(ls ${i} | sed 's/\.py$//g')"
			MY_INPUT_BASENAME="$(ls ${i} | sed 's/^.\///g; s/.py$//g')"
	
echo "#!/bin/bash

#PBS -l nodes=1:ppn=1,pmem=2gb,walltime=${MY_SC_WALLTIME}
#PBS -N ${MY_INPUT_BASENAME}
#PBS -m abe
#PBS -M ${MY_EMAIL_ACCOUNT}

#---Change **HRS** to be the expected number of hours for the run--------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change **NAME** to be a name to identify this job--------------------------#
#---Change **EMAIL** to be your email address for notifications----------------#

python ${i} > ${MY_INPUT_BASENAME}.out.txt


$MY_SC_PBS_WKDIR_CODE

exit 0" > dadi_pbs.sh

			chmod +x dadi_pbs.sh
			mv ./dadi_pbs.sh ./"$(ls ${i} | sed 's/.py$//g')"
			cp $MY_SNP_DATA_FILE ./"$(ls ${i} | sed 's/\.py$//g')"
			cp $i ./"$(ls ${i} | sed 's/\.py$//g')"
		done
	)

elif [[ "$MY_DADI_VERSION_SWITCH" -eq "1" ]]; then

	(
		for i in $MY_INPUT_PY_FILES; do
			mkdir "$(ls ${i} | sed 's/\.py$//g')"
			MY_INPUT_BASENAME="$(ls ${i} | sed 's/^.\///g; s/.py$//g')"
	
echo "#!/bin/bash

#PBS -l nodes=1:ppn=1,pmem=2gb,walltime=${MY_SC_WALLTIME}
#PBS -N ${MY_INPUT_BASENAME}
#PBS -m abe
#PBS -M ${MY_EMAIL_ACCOUNT}

#---Change **HRS** to be the expected number of hours for the run--------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change **NAME** to be a name to identify this job--------------------------#
#---Change **EMAIL** to be your email address for notifications----------------#

$(cat ./virtualenv.txt)
python ${i} > ${MY_INPUT_BASENAME}.out.txt


$MY_SC_PBS_WKDIR_CODE

exit 0" > dadi_pbs.sh

			chmod +x dadi_pbs.sh
			mv ./dadi_pbs.sh ./"$(ls ${i} | sed 's/.py$//g')"
			cp $MY_SNP_DATA_FILE ./"$(ls ${i} | sed 's/\.py$//g')"
			cp $i ./"$(ls ${i} | sed 's/\.py$//g')"
		done
	)
fi


echo "INFO      | $(date) |          Setup and run check on the number of run folders created by the program..."
	MY_FILECOUNT="$(find . -type f | wc -l)"
	MY_DIRCOUNT="$(find . -type d | wc -l)"
	MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"
	echo "INFO      | $(date) |          Number of run folders created: $MY_NUM_RUN_FOLDERS"


echo "INFO      | $(date) | STEP #4: CREATE BATCH SUBMISSION FILE, MOVE ALL RUN FOLDERS CREATED IN PREVIOUS STEP \
AND SUBMISSION FILE TO SUPERCOMPUTER. "
##--This step assumes that you have set up passowordless access to your supercomputer
##--account (e.g. passwordless ssh access), by creating and organizing appropriate and
##--secure public and private ssh keys on your machine and the remote supercomputer (by 
##--secure, I mean you closed write privledges to authorized keys by typing "chmod u-w 
##--authorized keys" after setting things up using ssh-keygen). This is VERY IMPORTANT
##--as the following will not work without completing this process first. The following
##--links provide a list of useful tutorials/discussions related to doing this:
#	* https://www.msi.umn.edu/support/faq/how-do-i-setup-ssh-keys
#	* https://coolestguidesontheplanet.com/make-passwordless-ssh-connection-osx-10-9-mavericks-linux/ 
#	* https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/
echo "INFO      | $(date) |          Copying run folders to working dir on supercomputer..."

echo "#!/bin/bash

$(cat ./virtualenv.txt)
" > batch_qsub_top.txt

	(
		for j in ./*/; do
			FOLDERNAME="$(echo $j | sed 's/\.\///g')"
			scp -r $j $MY_SSH_ACCOUNT:$MY_SC_DESTINATION	## Safe copy to remote machine.

echo "cd $MY_SC_DESTINATION$FOLDERNAME
qsub dadi_pbs.sh
" >> cd_and_qsub_commands.txt

		done
	)
## NOT RUN:	sed -i '' 1,3d ./cd_and_qsub_commands.txt		## First line of file attempts to cd to "./*/", but this will break the submission script. Here, we use sed to remove the first three lines, which contain the problematic cd line, a qsub line, and a blank line afterwards.

echo "
$MY_SC_PBS_WKDIR_CODE
exit 0
" > batch_qsub_bottom.txt

cat batch_qsub_top.txt cd_and_qsub_commands.txt batch_qsub_bottom.txt > dadirunner_batch_qsub.sh


##--More flow control. Check to make sure batch_qsub.sh file was successfully created.
if [ -f ./dadirunner_batch_qsub.sh ]; then
    echo "INFO      | $(date) |          Batch queue submission file ('dadirunner_batch_qsub.sh') successfully created. "
else
    echo "WARNING!  | $(date) |          Something went wrong. Batch queue submission file ('dadirunner_batch_qsub.sh') not created. Exiting... "
    exit
fi

echo "INFO      | $(date) |          Also copying configuration file to supercomputer..."
scp ./dadi_runner.cfg $MY_SSH_ACCOUNT:$MY_SC_DESTINATION

echo "INFO      | $(date) |          Also copying batch_qsub_file to supercomputer..."
scp ./dadirunner_batch_qsub.sh $MY_SSH_ACCOUNT:$MY_SC_DESTINATION



echo "INFO      | $(date) | STEP #5: SUBMIT ALL JOBS TO THE QUEUE. "
##--This is the key: using ssh to connect to supercomputer and execute the "dadirunner_batch_qsub.sh"
##--submission file created and moved into sc destination folder above. The batch qsub file
##--loops through all run folders and submits all jobs/runs (sh scripts in each folder) to the 
##--job queue. We do this (pass the commands to the supercomputer) using bash here document syntax 
##--(as per examples on the following web page, URL: 
##--https://www.cyberciti.biz/faq/linux-unix-osx-bsd-ssh-run-command-on-remote-machine-server/).

ssh $MY_SSH_ACCOUNT << HERE
cd $MY_SC_DESTINATION
pwd
chmod u+x ./dadirunner_batch_qsub.sh
./dadirunner_batch_qsub.sh
#
exit
HERE
echo "INFO      | $(date) |          Finished copying run folders to supercomputer and submitting ∂a∂i jobs to queue!!"


echo "INFO      | $(date) | STEP #6: CLEANUP: REMOVE UNNECESSARY FILES. "
echo "INFO      | $(date) |          Cleaning up: removing temporary files from local machine..."
	for (( i=1; i<="$MY_NUM_INDEP_RUNS"; i++ )); do rm ./*_"$i".py; done
	rm ./batch_qsub_top.txt
	rm ./cd_and_qsub_commands.txt
	rm ./batch_qsub_bottom.txt
	rm ./dadirunner_batch_qsub.sh

echo "INFO      | $(date) | Done organizing and copying SNP data and model files to supercomputer and submitting ∂a∂i "
echo "INFO      | $(date) | jobs to the queue, using the dadiRunner pipeline. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
