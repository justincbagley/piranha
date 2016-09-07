#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                         RAxMLRunner v1.1, September 2016                               #
#   SHELL SCRIPT FOR AUTOMATING MOVING AND RUNNING RAxML RUNS ON A REMOTE SUPERCOMPUTER  #
#   (AND EXTRACTING THE RESULTS...coming soon)                                           #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: September 7, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                         RAxMLRunner v1.1, September 2016                               #
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
echo "INFO      | $(date) |         Found $MY_NUM_RUN_FOLDERS run folders present in the current working directory. "


echo "INFO      | $(date) | STEP #2: MAKE BASH SUBMSSION FILE; MOVE ALL RUN FOLDERS TO SUPERCOMPUTER; AND \
THEN CHECK THAT BASH SUBMISSION FILE WAS CREATED. "
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
echo "#!/bin/sh
" > batch_qsub_top.txt

echo "INFO      | $(date) |         Starting copying run folders to supercomputer... note: this may display folder contents transferred rather than folder names. "
(
	for i in ./*/; do
		FOLDERNAME="$(echo $i | sed 's/\.\///g')"
		scp -r $i $MY_SSH_ACCOUNT:$MY_SC_DESTINATION			## Safe copy to remote machine.

echo "cd $MY_SC_DESTINATION$FOLDERNAME
sbatch RAxML_sbatch.sh
#" >> cd_and_sbatch_commands.txt

	done
)

##--Finish making batch queue submission file and name it "batch_qsub.sh".
echo "
$MY_SC_PBS_WKDIR_CODE
exit 0
" > batch_qsub_bottom.txt

cat batch_qsub_top.txt cd_and_sbatch_commands.txt batch_qsub_bottom.txt > raxmlrunner_batch_qsub.sh


##--More flow control. Check to make sure batch_qsub.sh file was successfully created.
if [ -f ./raxmlrunner_batch_qsub.sh ]; then
    echo "INFO      | $(date) |         Batch queue submission file ("raxmlrunner_batch_qsub.sh") successfully created. "
else
    echo "INFO      | $(date) |         Something went wrong. Batch queue submission file ("raxmlrunner_batch_qsub.sh") not created. "
fi

echo "INFO      | $(date) | STEP #3: MOVE BASH SUBMISSION FILE TO SUPERCOMPUTER AND EXECTUE IT! "
echo "INFO      | $(date) |         Moving batch file to supercomputer and executing it... "

##### Pull out the correct path to user's bin folder on the supercomputer from the "raxml_runner.cfg" configuration file.
	MY_SC_BIN="$(grep -n "bin_path" ./raxml_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"

##--This is the key: moving the bash submission file to supercomputer and executing it.
##--Hopefully, after this, all jobs will be submitted to run on the supercomputer. User
##--should verify this by checking run folder for correct log files on supercomputer.
scp ./raxmlrunner_batch_qsub.sh $MY_SSH_ACCOUNT:$MY_SC_BIN
ssh $MY_SSH_ACCOUNT bash -c "'
cd $MY_SC_BIN
chmod +x raxmlrunner_batch_qsub.sh
source raxmlrunner_batch_qsub.sh
exit;
'"

MY_QSUB_COMMANDS=cat cd_and_sbatch_commands.txt
ssh -t $MY_SSH_ACCOUNT bash -c "'
$MY_QSUB_COMMANDS
exit
'"

	##--Cleanup: remove temporary files on local machine.
	rm batch_qsub_top.txt
	rm batch_qsub_bottom.txt
	#rm cd_and_sbatch_commands.txt

	##--Optional cleanup: remove batch submission script from bin folder on supercomputer account.
	##--ssh $MY_SSH_ACCOUNT 'rm ~/bin/raxmlrunner_batch_qsub.sh;' (path/to/bin may be different
	##--on another user's account.


echo "INFO      | $(date) | Finished copying run folders to supercomputer and submitting RAxML jobs to queue!! "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
