#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          BEASTRunner v1.0, November 2016                               #
#   SHELL SCRIPT FOR AUTOMATING RUNNING BEAST ON A REMOTE SUPERCOMPUTER AND EXTRACTING   #
#   THE RESULTS                                                                          #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: November 11, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                          BEASTRunner v1.0, November 2016                               #
##########################################################################################"

######################################## START ###########################################
echo "INFO      | $(date) | Starting BEASTRunner pipeline... "
echo "INFO      | $(date) | STEP #1: SETUP VARIABLES, MAKE 4 COPIES PER INPUT XML FILE \
FOR A TOTAL OF FIVE RUNS OF EACH MODEL/XML USING"
echo "INFO      | $(date) |          DIFFERENT RANDOM SEEDS. "
echo "INFO      | $(date) |          Setting up variables, including those specified in the cfg file..."
	MY_XML_FILES=./*.xml
	MY_NUM_XML="$(ls . | grep "\.xml$" | wc -l)"
echo "INFO      | $(date) |          Number of xml files read: $MY_NUM_XML"	## Check number of input files read into program.

	MY_SC_PBS_WKDIR_CODE="$(grep -n "pbs_wkdir_code" ./beast_runner.cfg | \
	awk -F"=" '{print $NF}')"

	MY_SSH_ACCOUNT="$(grep -n "ssh_account" ./beast_runner.cfg | \
	awk -F"=" '{print $NF}')"

	MY_EMAIL_ACCOUNT="$(grep -n "email_account" ./beast_runner.cfg | \
	awk -F"=" '{print $NF}')"

##### Pull out the correct path to user's bin folder on the supercomputer from the "beast_runner.cfg" configuration file.
	MY_SC_BIN="$(grep -n "bin_path" ./beast_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"

	MY_SC_DESTINATION="$(grep -n "destination_path" ./beast_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"					## This pulls out the correct destination path on the supercomputer from the "beast_runner.cfg" configuration file in the working directory (generated/modified by user prior to running BEASTRunner).


echo "INFO      | $(date) |          Looping through original xmls and making four copies per file, renaming \
each copy with an extension of '_#.xml'"
echo "INFO      | $(date) |          where # ranges from 2-5. *** IMPORTANT ***: The starting xml files MUST \
end in 'run.xml'."
(
	for (( i=2; i<=5; i++ ))
	    do
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
	                    ## annotated with their run numbers 1-5 remain.


echo "INFO      | $(date) | STEP #2: MAKE DIRECTORIES FOR RUNS AND GENERATE SHELL SCRIPTS UNIQUE TO EACH \
INPUT FILE FOR DIRECTING EACH RUN. "
##--Loop through the input xml files and do the following for each file: (A) generate one 
##--folder per xml file with the same name as the file, only minus the extension; (B) 
##--create a shell script with the name "beast_pbs.sh" that is specific to the input 
##--and can be used to submit job to supercomputer; (C) move the PBS shell script into 
##--the folder whose name corresponds to the particular input xml file being manipulated
##--at the same pass in the loop.
(
	for i in $MY_XML_FILES
		do
		mkdir "$(ls ${i} | sed 's/\.xml$//g')"
	
echo "#!/bin/bash

#PBS -l nodes=1:ppn=1,pmem=1024mb,walltime=72:00:00
#PBS -N "$(ls ${i} | sed 's/^.\///g; s/.xml$//g')"
#PBS -m abe
#PBS -M justin.bagley@byu.edu

#---Change walltime to be the expected number of hours for the run-------------#
#---NOTE: The run will be killed if this time is exceeded----------------------#
#---Change the -M flag to point to your email address.-------------------------#


##--Uncomment next four lines if you are running your xml in BEAST v2.4.2:
module purge
module load beagle/2.1.2
module load jdk/1.8.0-60

java -Xmx5120M -jar /fslhome/bagle004/compute/BEAST_v2.4.2_linux/lib/beast.jar -beagle_sse -seed $(python -c "import random; print random.randint(10000,100000000000)") -beagle_GPU ${i} > ${i}.out
## __PATH NEEDED__: User must change the fourth element of the above line to indicate the absolute path to the working version of beast.jar that the user has access to on the supercomputer.

##--Uncomment next five lines if you are running your xml in BEAST v2.3.1:
#module purge
#module load beagle/2.1.2
#module load beast/2.3.1
#
#beast -beagle_sse -seed $(python -c "import random; print random.randint(10000,100000000000)") -beagle_GPU ${i} > ${i}.out

##--Uncomment next lines if you are running your xml in BEAST v1.8.3:
#module load beagle/2.1.2
#java -Xmx5120M -jar /fslhome/bagle004/compute/BEASTv1.8.3_linux/lib/beast.jar -beagle_sse -seed $(python -c "import random; print random.randint(10000,100000000000)") -beagle_GPU ${i} > ${i}.out
## __PATH NEEDED__: User must change the fourth element of the above line to indicate the absolute path to the working version of beast.jar that the user has access to on the supercomputer.

##--Uncomment next five lines if you want to run your xml in BEAST v1.8.0:
#module purge
#module load beast/1.8
#module load beagle/2.1.2

#beast -beagle_sse -seed $(python -c "import random; print random.randint(10000,100000000000)") -beagle_GPU ${i} > ${i}.out


$MY_SC_PBS_WKDIR_CODE

exit 0" > beast_pbs.sh

	chmod +x beast_pbs.sh
	mv ./beast_pbs.sh ./"$(ls ${i} | sed 's/.xml$//g')"
	cp $i ./"$(ls ${i} | sed 's/\.xml$//g')"

	done
)

echo "INFO      | $(date) |          Setup and run check on the number of run folders created by the program..."
	MY_FILECOUNT="$(find . -type f | wc -l)"
	MY_DIRCOUNT="$(find . -type d | wc -l)"
	calc () {								## Make the "handy bash function 'calc'" for subsequent use.
	   	bc -l <<< "$@"
	}
	MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"
	#"$(ls . | grep "./*/" | wc -l)"
echo "INFO      | $(date) |          Number of run folders created: $MY_NUM_RUN_FOLDERS"


echo "INFO      | $(date) | STEP #3: CREATE BATCH SUBMISSION FILE, MOVE ALL RUN FOLDERS CREATED IN PREVIOUS STEP \
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
" > batch_qsub_top.txt

(
	for j in ./*/
		do
		FOLDERNAME="$(echo $j | sed 's/\.\///g')"
		scp -r $j $MY_SSH_ACCOUNT:$MY_SC_DESTINATION	## Safe copy to remote machine.

echo "cd $MY_SC_DESTINATION$FOLDERNAME
qsub beast_pbs.sh
#" >> cd_and_qsub_commands.txt

	done
)

echo "
$MY_SC_PBS_WKDIR_CODE
exit 0
" > batch_qsub_bottom.txt
cat batch_qsub_top.txt cd_and_qsub_commands.txt batch_qsub_bottom.txt > beastrunner_batch_qsub.sh

echo "INFO      | $(date) |          Also copying configuration file to supercomputer..."
scp ./beast_runner.cfg $MY_SSH_ACCOUNT:$MY_SC_DESTINATION

echo "INFO      | $(date) |          Also copying batch_qsub_file to supercomputer..."
scp ./beastrunner_batch_qsub.sh $MY_SSH_ACCOUNT:$MY_SC_DESTINATION



echo "INFO      | $(date) | STEP #4: SUBMIT ALL JOBS TO THE QUEUE. "
##--This is the key: using ssh to connect to supercomputer, loop through all run folders, 
##--and submit all jobs/runs (sh scripts in each folder) to the queue. We do this while  
##--using the ssh "-c" flag to make variable expansion work, so that we can refer to our
##--destination path and email which we placed into environmental variables above.

ssh $MY_SSH_ACCOUNT '
cd ADD_PATH_TO_SC_DESTINATION_HERE
## __PATH NEEDED__: User must change the above line to indicate the absolute path to the same folder that the $MY_SC_DESTINATION environmental variable points to (pulled from 'destination_path' in the cfg file during STEP #1 above). This path must also end with a forward slash.
chmod u+x beastrunner_batch_qsub.sh
./beastrunner_batch_qsub.sh
exit
'

echo "INFO      | $(date) |          Finished copying run folders to supercomputer and submitting BEAST jobs to queue!!"

echo "INFO      | $(date) |          Cleaning up: removing temporary files from local machine..."
	rm ./*_1.xml ./*_2.xml ./*_3.xml ./*_4.xml ./*_5.xml
	rm ./batch_qsub_top.txt
	rm ./cd_and_qsub_commands.txt
	rm ./batch_qsub_bottom.txt
	rm ./beastrunner_batch_qsub.sh

echo "INFO      | $(date) |          Bye."

#
#
#
######################################### END ############################################

exit 0
