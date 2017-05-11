#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                               SNAPPRunner v1.0, May 2017                               #
#  SHELL SCRIPT FOR AUTOMATING RUNNING SNAPP ON A REMOTE SUPERCOMPUTING CLUSTER          #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: May 10, 2017. #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_NUM_INDEP_RUNS=5
MY_SC_WALLTIME=71:30:00
JAVA_MEM_ALLOC=5120M
MY_SC_PARTITION=NULL
MY_STARTING_SEED=NULL

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -n w m p s] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -n   nRuns (def: $MY_NUM_INDEP_RUNS) number of independent SNAPP runs per model (.xml file)
  -w   walltime (def: $MY_SC_WALLTIME) wall time (run time; hours:minutes:seconds) passed to 
       supercomputer 
  -m   javaMem (def: $JAVA_MEM_ALLOC) memory, i.e. RAM, allocation for Java. Must be an
       appropriate value for the node, with units in M=megabytes or G=gigabytes.  
  -p   partition (def: NULL) name of supercomputer partition (i.e. group of nodes, or job
       queue controlling a specific group of nodes) to use
  -s   seed (def: NULL) value of random number seed to start BEAST with
  
 OVERVIEW
 THIS SCRIPT automates conducting multiple runs of SNAPP (Bryant et al. 2012; part of BEAST2, 
 Drummond et al. 2012; Bouckaert et al. 2014) XML input files on a remote supercomputing cluster 
 that uses SLURM resource management with PBS wrappers, or a PBS resource management system.
 
 The code starts from a single working directory on the user's local machine, which contains
 one or multiple XML input files with extension '*run.xml' (where * is any set of 
 alphanumeric characters separated possibly by underscores but no spaces). These files are 
 identified and run through the SNAPPRunner pipeline, which involves five steps, as follows: 
 1) set up the workspace; 2) copy each XML file n times to create n+1 separate run XML files; 
 3) make directories for 1 run per XML (nRuns) and create a shell script with the name 
 "snapp_sbatch.sh" that is specific to the input and can be used to submit job to supercomputer 
 and move this PBS shell script into the corresponding folder; 4) create a batch submission 
 file (PBS format) and move it and all run folders to the desired working directory on the 
 supercomputer; 5) execute the batch submission file on the supercomputer so that all jobs 
 are submitted to the supercomputer queue.

 Like other software programs such as BPP, G-PhoCS, and GARLI, some information that is used
 by SNAPPRunner.sh is fed to the program by culling the data from an external configuration 
 file, named "snapp_runner.cfg". There are six entries that users can supply in this file. 
 However, three of these are essential for running SNAPP using the SNAPPRunner script, 
 including: ssh user account info, the path to the parent directory for SNAPP runs on the 
 supercomputer, the user's email address, and the absolute path to the beast.jar file on 
 the supercomputer that you wish to use. Users must fill this information in and save 
 a new version of the .cfg file in the working directory on their local machine prior to 
 calling the program. Only then can the user call the program by opening a terminal window, 
 typing "./SNAPPRunner.sh", and pressing return.
 
 It is assumed that BEAST2 (e.g. 2.4.2++) is installed on the supercomputer, and that the user 
 can provide absolute paths to the BEAST jar file in the cfg file. Last testing was conducted
 using BEAST v2.4.5. Check for BEAST2 updates at BEAST2.org.

 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Bouckaert R, Heled J, Künert D, Vaughan TG, Wu CH, Xie D, Suchard MA, Rambaut A, Drummond 
 	AJ (2014) BEAST2: a software platform for Bayesian evolutionary analysis. PLoS 
 	Computational Biology, 10, e1003537.
 Bryant D, Bouckaert R, Felsenstein J, Rosenberg NA, RoyChoudhury A (2012) Inferring species 
	trees directly from biallelic genetic markers: bypassing gene trees in a full coalescent 
	analysis. Molecular Biology and Evolution, 29, 1917–1932.
 Drummond AJ, Suchard MA, Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and 
 	the BEAST 1.7. Molecular Biology and Evolution, 29, 1969-1973.
"

verboseHelp="Usage: $(basename "$0") [Help: -h help H Help] [Options: -n w m p s] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -n   nRuns (def: $MY_NUM_INDEP_RUNS) number of independent SNAPP runs per model (.xml file)
  -w   walltime (def: $MY_SC_WALLTIME) wall time (run time in hours:minutes:seconds) passed to 
       supercomputer 
  -m   javaMem (def: $JAVA_MEM_ALLOC) memory, i.e. RAM, allocation for Java. Must be an
       appropriate value for the node, with units in M=megabytes or G=gigabytes.  
  -p   partition (def: NULL) name of supercomputer partition (i.e. group of nodes, or job
       queue controlling a specific group of nodes) to use
  -s   seed (def: NULL) value of random number seed to start BEAST with

 OVERVIEW
 THIS SCRIPT automates conducting multiple runs of SNAPP (Bryant et al. 2012; part of BEAST2, 
 Drummond et al. 2012; Bouckaert et al. 2014) XML input files on a remote supercomputing cluster 
 that uses SLURM resource management with PBS wrappers, or a PBS resource management system.
 
 The code starts from a single working directory on the user's local machine, which contains
 one or multiple XML input files with extension '*run.xml' (where * is any set of 
 alphanumeric characters separated possibly by underscores but no spaces). These files are 
 identified and run through the SNAPPRunner pipeline, which involves five steps, as follows: 
 1) set up the workspace; 2) copy each XML file n times to create n+1 separate run XML files; 
 3) make directories for 1 run per XML (nRuns) and create a shell script with the name 
 "snapp_sbatch.sh" that is specific to the input and can be used to submit job to supercomputer 
 and move this PBS shell script into the corresponding folder; 4) create a batch submission 
 file (PBS format) and move it and all run folders to the desired working directory on the 
 supercomputer; 5) execute the batch submission file on the supercomputer so that all jobs 
 are submitted to the supercomputer queue.

 Like other software programs such as BPP, G-PhoCS, and GARLI, some information that is used
 by SNAPPRunner.sh is fed to the program by culling the data from an external configuration 
 file, named "snapp_runner.cfg". There are six entries that users can supply in this file. 
 However, three of these are essential for running SNAPP using the SNAPPRunner script, 
 including: ssh user account info, the path to the parent directory for SNAPP runs on the 
 supercomputer, the user's email address, and the absolute path to the beast.jar file on 
 the supercomputer that you wish to use. Users must fill this information in and save 
 a new version of the .cfg file in the working directory on their local machine prior to 
 calling the program. Only then can the user call the program by opening a terminal window, 
 typing "./SNAPPRunner.sh", and pressing return.
 
 It is assumed that BEAST2 (e.g. 2.4.2++) is installed on the supercomputer, and that the user 
 can provide absolute paths to the BEAST jar file in the cfg file. Last testing was conducted
 using BEAST v2.4.5. Check for BEAST2 updates at <http://BEAST2.org>.

 DETAILS
 The -n flag sets the number of independent SNAPP runs to be submitted to the supercomputer
 for each model specified in a .xml file in the current working directory. The default is 5
 runs.

 The -w flag passes the expected amount of time for each SNAPP run to the supercomputer
 management software, in hours:minutes:seconds (00:00:00) format. If your supercomputer does 
 not use this format, or does not have a walltime requirement, then you will need to modify 
 the shell scripts for each run and re-run them without specifying a walltime.

 The -m flag passes the amount of RAM memory to be allocated to beast.jar/Java during each
 SNAPP run. The default (5120 megabytes, or ~5 gigabytes) is around five times the typical
 default value of 1024M (~1 GB). Suggested values in MB units: 1024M, 2048M, 3072M, 4096M, 
 or 5120M, or in terms of GB units: 1G, 2G, 3G, 4G, 5G.
 
		## Usage examples: 
		"$0" .
		"$0" -n 5 .
		"$0" -n 20 .				## Ex.: changing number of runs.
		"$0" -n 20 -w 24:00:00 .		## Ex.: changing run walltime.
		"$0" -n 20 -w 24:00:00 -m 2048M .	## Ex.: changing memory (RAM) allocation.
	
 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Bouckaert R, Heled J, Künert D, Vaughan TG, Wu CH, Xie D, Suchard MA, Rambaut A, Drummond 
 	AJ (2014) BEAST2: a software platform for Bayesian evolutionary analysis. PLoS 
 	Computational Biology, 10, e1003537.
 Bryant D, Bouckaert R, Felsenstein J, Rosenberg NA, RoyChoudhury A (2012) Inferring species 
	trees directly from biallelic genetic markers: bypassing gene trees in a full coalescent 
	analysis. Molecular Biology and Evolution, 29, 1917–1932.
 Drummond AJ, Suchard MA, Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and 
 	the BEAST 1.7. Molecular Biology and Evolution, 29, 1969-1973.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

if [[ "$1" == "-H" ]] || [[ "$1" == "-Help" ]]; then
	echo "$verboseHelp"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'n:w:m:p:' opt ; do
  case $opt in

## SNAPPRunner options:
    n) MY_NUM_INDEP_RUNS=$OPTARG ;;
    w) MY_SC_WALLTIME=$OPTARG ;;
    m) JAVA_MEM_ALLOC=$OPTARG ;;
    p) MY_SC_PARTITION=$OPTARG ;;
    s) MY_STARTING_SEED=$OPTARG ;;

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
#                               SNAPPRunner v1.0, May 2017                               #
##########################################################################################"

######################################## START ###########################################
	calc () {
	   	bc -l <<< "$@"
}
echo "INFO      | $(date) | Starting SNAPPRunner pipeline... "
echo "INFO      | $(date) | STEP #1: SETUP VARIABLES, MAKE $(calc $MY_NUM_INDEP_RUNS - 1) COPIES PER INPUT XML FILE \
FOR A TOTAL OF FIVE RUNS OF EACH MODEL/XML USING"
echo "INFO      | $(date) |          DIFFERENT RANDOM SEEDS. "
echo "INFO      | $(date) |          Setting up variables, including those specified in the cfg file..."
	MY_XML_FILES=./*.xml
	MY_NUM_XML="$(ls . | grep "\.xml$" | wc -l)"
echo "INFO      | $(date) |          Number of XML files read: $MY_NUM_XML"	## Check number of input files read into program.

	MY_SSH_ACCOUNT="$(grep -n "ssh_account" ./snapp_runner.cfg | \
	awk -F"=" '{print $NF}')"
	MY_SC_BIN="$(grep -n "bin_path" ./snapp_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"
	MY_EMAIL_ACCOUNT="$(grep -n "email_account" ./snapp_runner.cfg | \
	awk -F"=" '{print $NF}')"
	MY_SC_DESTINATION="$(grep -n "destination_path" ./snapp_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"					## This pulls out the correct destination path on the supercomputer from the "snapp_runner.cfg" configuration file in the working directory (generated/modified by user prior to running SNAPPRunner).
	MY_BEAST_PATH="$(grep -n "beast_jar_path" ./snapp_runner.cfg | \
	awk -F"=" '{print $NF}')"
	MY_SC_PBS_WKDIR_CODE="$(grep -n "pbs_wkdir_code" ./snapp_runner.cfg | \
	awk -F"=" '{print $NF}')"


echo "INFO      | $(date) | STEP #2: MAKE $(calc $MY_NUM_INDEP_RUNS - 1) COPIES PER INPUT .XML FILE FOR A TOTAL OF $MY_NUM_INDEP_RUNS RUNS OF EACH MODEL or "
echo "INFO      | $(date) |          .XML USING DIFFERENT RANDOM SEEDS. "
echo "INFO      | $(date) |          Looping through original .xml's and making $(calc $MY_NUM_INDEP_RUNS - 1) copies per file, renaming \
each copy with an extension of '_#.xml'"
echo "INFO      | $(date) |          where # ranges from 2 - $MY_NUM_INDEP_RUNS. *** IMPORTANT ***: The starting .xml files MUST \
end in 'run.xml'."
(
	for (( i=2; i<="$MY_NUM_INDEP_RUNS"; i++ )); do
	    find . -type f -name '*run.xml' | while read FILE ; do
	        newfile="$(echo ${FILE} | sed -e 's/\.xml/\_'$i'\.xml/')" ;
	        cp "${FILE}" "${newfile}" ;
	    done
	done
)

(
	find . -type f -name '*run.xml' | while read FILE ; do
		newfile="$(echo ${FILE} |sed -e 's/run\.xml/run_1\.xml/')" ;
		cp "${FILE}" "${newfile}" ;
	done
)

	rm ./*run.xml       ## Remove the original "run.xml" input files so that only XML files
	            		## annotated with their run numbers 1 - $MY_NUM_INDEP_RUNS remain.


echo "INFO      | $(date) | STEP #3: MAKE DIRECTORIES FOR RUNS AND GENERATE SHELL SCRIPTS UNIQUE TO EACH \
INPUT FILE FOR DIRECTING EACH RUN. "
##--Loop through the input XML files and do the following for each file: (A) generate one 
##--folder per XML file with the same name as the file, only minus the extension; (B) 
##--create a shell script with the name "snapp_sbatch.sh" that is specific to the input 
##--and can be used to submit job to supercomputer; (C) move the PBS shell script into 
##--the folder whose name corresponds to the particular input XML file being manipulated
##--at the same pass in the loop.
#
##--Do two loops--one while giving no partition information to the shell scripts, the other
##--feeding user-specified supercomputer partition with the "--partition" flag of SBATCH.
if [[ "$MY_SC_PARTITION" = "NULL" ]] && [[ "$MY_STARTING_SEED" = "NULL"]]; then

(
	for i in $MY_XML_FILES; do
		mkdir "$(ls ${i} | sed 's/\.xml$//g')"
		MY_INPUT_BASENAME="$(ls ${i} | sed 's/^.\///g; s/.py$//g')"

echo "#!/bin/bash

#SBATCH --time=${MY_SC_WALLTIME}   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=${JAVA_MEM_ALLOC}   # memory per CPU core
#SBATCH --mail-user=${MY_EMAIL_ACCOUNT}   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#---Change walltime to be the expected number of hours for the run-------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change the -M flag to point to your email address.-------------------------#


module purge
module load beagle/2.1.2
module load jdk/1.8.0-60

java -Xmx${JAVA_MEM_ALLOC} -jar ${MY_BEAST_PATH} -beagle_sse -seed $(python -c "import random; print random.randint(10000,100000000000)") -beagle_GPU ${i} > ${i}.out


$MY_SC_PBS_WKDIR_CODE

exit 0" > snapp_sbatch.sh

	chmod +x snapp_sbatch.sh
	mv ./snapp_sbatch.sh ./"$(ls ${i} | sed 's/.xml$//g')"
	cp $i ./"$(ls ${i} | sed 's/\.xml$//g')"

	done
)

elif [[ "$MY_SC_PARTITION" = "NULL" ]] && [[ "$MY_STARTING_SEED" != "NULL"]]; then

(
	for i in $MY_XML_FILES; do
		mkdir "$(ls ${i} | sed 's/\.xml$//g')"
		MY_INPUT_BASENAME="$(ls ${i} | sed 's/^.\///g; s/.py$//g')"

echo "#!/bin/bash

#SBATCH --time=${MY_SC_WALLTIME}   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=${JAVA_MEM_ALLOC}   # memory per CPU core
#SBATCH --mail-user=${MY_EMAIL_ACCOUNT}   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#---Change walltime to be the expected number of hours for the run-------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change the -M flag to point to your email address.-------------------------#


module purge
module load beagle/2.1.2
module load jdk/1.8.0-60

java -Xmx${JAVA_MEM_ALLOC} -jar ${MY_BEAST_PATH} -beagle_sse -seed ${$MY_STARTING_SEED} -beagle_GPU ${i} > ${i}.out


$MY_SC_PBS_WKDIR_CODE

exit 0" > snapp_sbatch.sh

	chmod +x snapp_sbatch.sh
	mv ./snapp_sbatch.sh ./"$(ls ${i} | sed 's/.xml$//g')"
	cp $i ./"$(ls ${i} | sed 's/\.xml$//g')"

	done
)

elif [[ "$MY_SC_PARTITION" != "NULL" ]] && [[ "$MY_STARTING_SEED" = "NULL"]]; then

(
	for i in $MY_XML_FILES; do
		mkdir "$(ls ${i} | sed 's/\.xml$//g')"
		MY_INPUT_BASENAME="$(ls ${i} | sed 's/^.\///g; s/.py$//g')"

echo "#!/bin/bash

#SBATCH --time=${MY_SC_WALLTIME}   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=${JAVA_MEM_ALLOC}   # memory per CPU core
#SBATCH --partition=${MY_SC_PARTITION}
#SBATCH --mail-user=${MY_EMAIL_ACCOUNT}   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#---Change walltime to be the expected number of hours for the run-------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change the -M flag to point to your email address.-------------------------#


module purge
module load beagle/2.1.2
module load jdk/1.8.0-60

java -Xmx${JAVA_MEM_ALLOC} -jar ${MY_BEAST_PATH} -beagle_sse -seed $(python -c "import random; print random.randint(10000,100000000000)") -beagle_GPU ${i} > ${i}.out


$MY_SC_PBS_WKDIR_CODE

exit 0" > snapp_sbatch.sh

	chmod +x snapp_sbatch.sh
	mv ./snapp_sbatch.sh ./"$(ls ${i} | sed 's/.xml$//g')"
	cp $i ./"$(ls ${i} | sed 's/\.xml$//g')"

	done
)

elif [[ "$MY_SC_PARTITION" != "NULL" ]] && [[ "$MY_STARTING_SEED" != "NULL"]]; then

(
	for i in $MY_XML_FILES; do
		mkdir "$(ls ${i} | sed 's/\.xml$//g')"
		MY_INPUT_BASENAME="$(ls ${i} | sed 's/^.\///g; s/.py$//g')"

echo "#!/bin/bash

#SBATCH --time=${MY_SC_WALLTIME}   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=${JAVA_MEM_ALLOC}   # memory per CPU core
#SBATCH --partition=${MY_SC_PARTITION}
#SBATCH --mail-user=${MY_EMAIL_ACCOUNT}   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#---Change walltime to be the expected number of hours for the run-------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change the -M flag to point to your email address.-------------------------#


module purge
module load beagle/2.1.2
module load jdk/1.8.0-60

java -Xmx${JAVA_MEM_ALLOC} -jar ${MY_BEAST_PATH} -beagle_sse -seed ${MY_STARTING_SEED} -beagle_GPU ${i} > ${i}.out


$MY_SC_PBS_WKDIR_CODE

exit 0" > snapp_sbatch.sh

	chmod +x snapp_sbatch.sh
	mv ./snapp_sbatch.sh ./"$(ls ${i} | sed 's/.xml$//g')"
	cp $i ./"$(ls ${i} | sed 's/\.xml$//g')"

	done
)

fi

echo "INFO      | $(date) |          Setup and run check on the number of run folders created by the program..."
	MY_FILECOUNT="$(find . -type f | wc -l)"
	MY_DIRCOUNT="$(find . -type d | wc -l)"
	MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"
	#"$(ls . | grep "./*/" | wc -l)"
echo "INFO      | $(date) |          Number of run folders created: $MY_NUM_RUN_FOLDERS"


echo "INFO      | $(date) | STEP #4: CREATE BATCH SUBMISSION FILE, MOVE ALL RUN FOLDERS CREATED IN PREVIOUS STEP \
AND SUBMISSION FILE TO SUPERCOMPUTER. "
##--This step assumes that you have set up passowordless access to your supercomputer
##--account (e.g. passwordless ssh access), by creating and organizing appropriate and
##--secure public and private ssh keys on your machine and the remote supercomputer (by 
##--secure, I mean you closed write privledges to authorized keys by typing "chmod u-w 
##--authorized keys" after setting things up using ssh-keygen). This is VERY IMPORTANT
##--as the following will not work without completing this process first. The following
##--are links to useful tutorials/discussions related to doing this:
#	* http://www.macworld.co.uk/how-to/mac-software/how-generate-ssh-keys-3521606/
#	* https://coolestguidesontheplanet.com/make-passwordless-ssh-connection-osx-10-9-mavericks-linux/  (preferred)
#	* https://coolestguidesontheplanet.com/make-an-alias-in-bash-shell-in-os-x-terminal/  (needed to complete tutorial above)
#	* http://unix.stackexchange.com/questions/187339/spawn-command-not-found
echo "INFO      | $(date) |          Copying run folders to working dir on supercomputer..."

echo "#!/bin/bash
" > qsub_top.txt

(
	for j in ./*/; do
		FOLDERNAME="$(echo $j | sed 's/\.\///g')"
		scp -r $j $MY_SSH_ACCOUNT:$MY_SC_DESTINATION	## Safe copy to remote machine.

echo "cd $MY_SC_DESTINATION$FOLDERNAME
sbatch snapp_sbatch.sh
#" >> cd_and_qsub_commands.txt

	done
)
### NOT RUN. sed -i '' 1,3d ./cd_and_qsub_commands.txt		## First line of file attempts to cd to "./*/", but this will break the submission script. Here, we use sed to remove the first three lines, which contain the problematic cd line, a sbatch line, and a blank line afterwards.

echo "
$MY_SC_PBS_WKDIR_CODE
exit 0
" > qsub_bottom.txt
cat qsub_top.txt cd_and_qsub_commands.txt qsub_bottom.txt > SNAPPRunner_batch_qsub.sh

##--More flow control. Check to make sure sbatch.sh file was successfully created.
if [ -f ./SNAPPRunner_batch_qsub.sh ]; then
    echo "INFO      | $(date) |          Batch queue submission file ("SNAPPRunner_batch_qsub.sh") successfully created. "
else
    echo "WARNING!  | $(date) |          Something went wrong. Batch queue submission file ("SNAPPRunner_batch_qsub.sh") not created. Exiting... "
    exit
fi

echo "INFO      | $(date) |          Also copying configuration file to supercomputer..."
scp ./snapp_runner.cfg $MY_SSH_ACCOUNT:$MY_SC_DESTINATION

echo "INFO      | $(date) |          Also copying sbatch_file to supercomputer..."
scp ./SNAPPRunner_batch_qsub.sh $MY_SSH_ACCOUNT:$MY_SC_DESTINATION



echo "INFO      | $(date) | STEP #5: SUBMIT ALL JOBS TO THE QUEUE. "
##--This is the key: using ssh to connect to supercomputer and execute the "SNAPPRunner_batch_qsub.sh"
##--submission file created and moved into sc destination folder above. The batch sbatch file
##--loops through all run folders and submits all jobs/runs (sh scripts in each folder) to the 
##--job queue. We do this (pass the commands to the supercomputer) using bash HERE document syntax 
##--(as per examples on the following web page, URL: 
##--https://www.cyberciti.biz/faq/linux-unix-osx-bsd-ssh-run-command-on-remote-machine-server/).

ssh $MY_SSH_ACCOUNT << HERE
cd $MY_SC_DESTINATION
pwd
chmod u+x ./SNAPPRunner_batch_qsub.sh
./SNAPPRunner_batch_qsub.sh
#
exit
HERE


echo "INFO      | $(date) |          Finished copying run folders to supercomputer and submitting SNAPP jobs to queue!!"

echo "INFO      | $(date) |          Cleaning up: removing temporary files from local machine..."
	for (( i=1; i<="$MY_NUM_INDEP_RUNS"; i++ )); do rm ./*_"$i".xml; done
	rm ./qsub_top.txt
	rm ./cd_and_qsub_commands.txt
	rm ./qsub_bottom.txt
	rm ./SNAPPRunner_batch_qsub.sh

echo "INFO      | $(date) |          Bye."

#
#
#
######################################### END ############################################

exit 0
