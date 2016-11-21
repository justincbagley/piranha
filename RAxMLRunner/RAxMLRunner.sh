#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          RAxMLRunner v1.2, November 2016                               #
#   SHELL SCRIPT FOR AUTOMATING MOVING AND RUNNING RAxML RUNS ON A REMOTE SUPERCOMPUTER  #
#   (AND EXTRACTING THE RESULTS...coming soon)                                           #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: November 21, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                          RAxMLRunner v1.2, November 2016                               #
##########################################################################################"

echo "INFO      | $(date) | STEP #1: SETUP VARIABLES AND CHECK CONTENTS. "
##### Setup and run check on the number of run folders in present working directory:
	MY_WORKING_DIR="$(pwd)"
	MY_DIRCOUNT="$(find . -type d | wc -l)"					## Note: not needed/used yet: MY_FILECOUNT="$(find . -type f | wc -l)"
	calc () {								## Make the "handy bash function 'calc'" for subsequent use.
	   	bc -l <<< "$@"
	}
	MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"				## We need to subtract one from this count because "find" counts the current directory as well, but we want only the daughter directories within this working directory.
										## **IMPORTANT**: NOTE we also assume here that every folder in the current directory is a RAxML run folder!!!
echo "INFO      | $(date) |          Found $MY_NUM_RUN_FOLDERS run folders present in the current working directory. "


echo "INFO      | $(date) | STEP #2: MAKE BATCH SUBMSSION FILE; MOVE ALL RUN FOLDERS TO SUPERCOMPUTER; AND \
THEN CHECK THAT BATCH SUBMISSION FILE WAS CREATED. "
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

	MY_SC_DESTINATION="$(grep -n "destination_path" ./raxml_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"				## This pulls out the correct destination path on the supercomputer from the "raxml_runner.cfg" configuration file in the working directory (generated/modified by user prior to running RAxMLRunner).

	MY_SSH_ACCOUNT="$(grep -n "ssh_account" ./raxml_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"

	##--Start making batch queue submission file by making just the top with correct shebang:
echo "#!/bin/bash
" > sbatch_sub_top.txt

echo "INFO      | $(date) |          Starting copying run folders to supercomputer... note: this may display folder contents transferred rather than folder names. "
(
	for i in ./*/; do
		FOLDERNAME="$(echo $i | sed 's/\.\///g')"
		scp -r $i $MY_SSH_ACCOUNT:$MY_SC_DESTINATION			## Safe copy to remote machine.

echo "cd $MY_SC_DESTINATION$FOLDERNAME
sbatch RAxML_sbatch.sh
#" >> cd_and_sbatch_commands.txt

	done
)

##--Finish making batch queue submission file and name it "sbatch_sub.sh".
echo "
$MY_SC_PBS_WKDIR_CODE
exit 0
" > sbatch_sub_bottom.txt

cat sbatch_sub_top.txt cd_and_sbatch_commands.txt sbatch_sub_bottom.txt > raxmlrunner_sbatch_sub.sh

##--More flow control. Check to make sure sbatch_sub.sh file was successfully created.
if [ -f ./raxmlrunner_sbatch_sub.sh ]; then
    echo "INFO      | $(date) |          Batch queue submission file ("raxmlrunner_sbatch_sub.sh") successfully created. "
else
    echo "INFO      | $(date) |          Something went wrong. Batch queue submission file ("raxmlrunner_sbatch_sub.sh") not created. "
fi

echo "INFO      | $(date) | STEP #3: MOVE BATCH SUBMISSION FILE TO SUPERCOMPUTER. "
echo "INFO      | $(date) |          Moving batch file to supercomputer... "

##### Pull out the correct path to user's bin folder on the supercomputer from the "raxml_runner.cfg" configuration file.
	MY_SC_BIN="$(grep -n "bin_path" ./raxml_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"

echo "INFO      | $(date) |          Also copying sbatch_sub_file to supercomputer..."
scp ./raxmlrunner_sbatch_sub.sh $MY_SSH_ACCOUNT:$MY_SC_DESTINATION


echo "INFO      | $(date) | STEP #4: SUBMIT ALL JOBS TO THE QUEUE. "
##--This is the key: using ssh to connect to supercomputer, loop through all run folders, 
##--and submit all jobs/runs (sh scripts in each folder) to the queue. We do this while  
##--using the ssh "-c" flag to make variable expansion work, so that we can refer to our
##--destination path and email which we placed into environmental variables above.

ssh $MY_SSH_ACCOUNT '
cd ADD_PATH_TO_SC_DESTINATION_HERE
## __PATH NEEDED__: User must change the above line to indicate the absolute path to the same folder that the $MY_SC_DESTINATION environmental variable points to (pulled from 'destination_path' in the cfg file during STEP #1 above).
chmod u+x raxmlrunner_sbatch_sub.sh
./raxmlrunner_sbatch_sub.sh
exit
'

echo "INFO      | $(date) |          Finished copying run folders to supercomputer and submitting RAxML jobs to queue!!"

echo "INFO      | $(date) |          Cleaning up: removing temporary files from local machine..."
	rm sbatch_sub_top.txt
	rm sbatch_sub_bottom.txt
	#rm cd_and_sbatch_commands.txt

	##--Optional cleanup: remove batch submission script from bin folder on supercomputer account.
	##--ssh $MY_SSH_ACCOUNT 'rm ~/bin/raxmlrunner_sbatch_sub.sh;' NOTE: path/to/bin may be different
	##--on another user's account.

echo "INFO      | $(date) |          Bye.
"
#
#
#
######################################### END ############################################

exit 0
