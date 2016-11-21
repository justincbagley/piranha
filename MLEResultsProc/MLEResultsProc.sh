#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        #
# |                                                                                      #
#                         MLEResultsProc v1.1, September 2016                            #
#   SHELL SCRIPT FOR POST-PROCESSING OF MARGINAL LIKELIHOOD ESTIMATION RESULTS FROM      #
#   CONDUCTING PATH SAMPLING OR STEPPING-STONE SAMPLING IN BEAST                         #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: September 7, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                         MLEResultsProc v1.1, September 2016                            #
##########################################################################################
"

echo "INFO      | $(date) | STEP #1: EXTRACT MLE RESULTS FROM BEAST OUTPUT FILE. "
	MY_BEAST_OUTPUT_FILES=*.out

##--Get line from each file with path sampling (PS) MLE output, then add filename followed 
##--by next line with MLE estimate into a separate file "output.txt", doing this for all
##--.out files: 
(
	for i in $MY_BEAST_OUTPUT_FILES; do 
		echo $i
		echo `basename "$i"` > ${i}_filename.tmp
#
			grep -n "log marginal likelihood (using path sampling) from pathLikelihood.delta =" ${i} | \
			awk -F"= " '{print $NF}' > ${i}_PSMLEs.tmp
	
			grep -n "log marginal likelihood (using stepping stone sampling) from pathLikelihood.delta =" ${i} | \
			awk -F"= " '{print $NF}' > ${i}_SSMLEs.tmp
#
			MY_PS_RESULT="$(head -n1 ${i}_PSMLEs.tmp)"
			MY_SS_RESULT="$(head -n1 ${i}_SSMLEs.tmp)"
#
		echo ${i}_filename.tmp $MY_PS_RESULT $MY_SS_RESULT >> data.tmp
	done
)

rm ./*_filename.tmp
rm ./*_PSMLEs.tmp
rm ./*_SSMLEs.tmp


echo "INFO      | $(date) | STEP #2: ARRANGE MLE RESULTS IN TAB-DELIMITED FILE WITH HEADER. "
	echo "File	PS_MLE	SS_MLE" > header.txt	## Make header row. Change these codes as needed.
	cat header.txt data.tmp | sed 's/\_filename.tmp//g; s/\ /	/g' > MLE.output.txt

	rm header.txt
	rm data.tmp


echo "INFO      | $(date) | STEP #3: LOAD MLE RESULTS INTO R AND COMPUTE BAYES FACTOR TABLES. "
##--We do this in an R script that I wrote named "2logeB10.R" that we simply call here. 
##--Note this script needs to be either in the working directory or the user's path.

	R CMD BATCH 2logeB10.R

echo "Bye.
"
#
#
#
######################################### END ############################################

exit 0
