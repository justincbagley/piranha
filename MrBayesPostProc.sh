#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                             MrBayesPostProc v1.3, May 2017                             #
#  SHELL SCRIPT FOR POST-PROCESSING OF MrBayes OUTPUT FILES ON A SUPERCOMPUTING CLUSTER  #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: May 4, 2017.  #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

echo "
##########################################################################################
#                             MrBayesPostProc v1.3, May 2017                             #
##########################################################################################"

###### Prep files and then Summarize trees, their posterior probabilities, and their errors using MrBayes.

echo "INFO      | $(date) | STEP #1: SETUP VARIABLES. "
##--Make the "handy bash function 'calc'" for subsequent use.
	calc () {
	   	bc -l <<< "$@"
	}
    if [[ -f ./*.NEX ]]; then
        echo "INFO      | $(date) |          Fixing NEXUS filename... "
    (
        for file in *.NEX; do
            mv "$file" "`basename "$file" .NEX`.nex"
        done
    )
    fi

	MY_NEXUS=./*.nex
	MY_NEXUS_FILENAME="$(echo ./*.nex | sed -n 's/.\///p')"		## Assumes only one NEXUS file in working directory corresponding to MrBayes run input file.
	MY_MRBAYES_FILENAME="$(ls | grep -n ".mcmc" | sed -n 's/.://p' | sed 's/\.mcmc$//g')" 	##--Note: If you want to check these variables, do: ~$ echo $MY_NEXUS_FILENAME; echo $MY_MRBAYES_FILENAME;

    MY_SC_MB_PATH="$(grep -n "mb_path" ./mrbayes_post_proc.cfg | \
    awk -F"=" '{print $NF}')"


echo "INFO      | $(date) | STEP #2: REMOVE MRBAYES BLOCK FROM NEXUS FILE. "
	MY_MRBAYES_BLOCK_START="$(grep -n "BEGIN mrbayes;" ./*.nex | sed 's/:.*$//g')"
	MY_EOF_LINE="$(wc -l $MY_NEXUS)"
	MY_HEADSTOP="$(calc $MY_MRBAYES_BLOCK_START-1)"

	head -n$MY_HEADSTOP $MY_NEXUS > ./simple.nex


echo "INFO      | $(date) | STEP #3: CREATE BATCH FILE TO RUN IN MRBAYES. "
echo "INFO      | $(date) |          Making batch file... "
echo "set autoclose=yes nowarn=yes
execute ./simple.nex
sumt Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac=0.25
sump Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac=0.25
quit" > ./batch.txt

##--Flow control. Check to make sure MrBayes batch file was successfully created.
    if [[ -f ./batch.txt ]]; then
        echo "INFO      | $(date) |          MrBayes batch file ("batch.txt") successfully created. "
    else
        echo "WARNING!  | $(date) |          Something went wrong. MrBayes batch file ("batch.txt") not created. Exiting... "
        exit
    fi


echo "INFO      | $(date) | STEP #4: SUMMARIZE RUN AND COMPUTE CONSENSUS TREE IN MRBAYES. "
##--This calls the commands in the batch.txt file to run within MrBayes, opening the 
##--simplified nexus file and creating summaries of the tree and run parameters as wellas
##--computing a majority-rule consensus tree with Bayesian posterior probabilities 
##--annotated along each node.

    $MY_SC_MB_PATH  < ./batch.txt > Mrbayes_sumtp_log.txt &		## Use batch to run MrBayes.


echo "INFO      | $(date) | STEP #5: CLEANUP FILES. "
	rm ./batch.txt							## Remove temporary files created above.
	rm ./simple.nex

echo "INFO      | $(date) | Done with post-processing of MrBayes results. "
echo "INFO      | $(date) | Bye. 
"
#
#
#
######################################### END ############################################

exit 0
