#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        #
# |                                                                                      #
#                            MLEResultsProc v1.2, August 2017                            #
#  SHELL SCRIPT FOR POST-PROCESSING OF MARGINAL LIKELIHOOD ESTIMATION RESULTS FROM       #
#  CONDUCTING PATH SAMPLING OR STEPPING-STONE SAMPLING IN BEAST                          #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further info. Last update: August 22, 2017.     #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

echo "
##########################################################################################
#                            MLEResultsProc v1.2, August 2017                            #
##########################################################################################
"

echo "INFO      | $(date) | STEP #1: SETUP. "
	MY_BEAST_OUTPUT_FILES=*.out

echo "INFO      | $(date) | STEP #2: CHECK BEAST VERSION (DETECT AND ACCOMODATE RESULTS FILES FROM BEAST1 OR BEAST2). "
## CHECK BEAST VERSION. 
##--Conditional on the following check, we will run one of two different versions of 
##--MLEResultsProc on the current working dir--one specific to the format of output (.out)
##--files from BEAST v1, and one specific to the format of .out files from BEAST v2.
(	for i in $MY_BEAST_OUTPUT_FILES; do echo "$i" > file.tmp; break; done	)
	y="$(cat file.tmp)"
	MY_BEAST1_VER_CHECK="$(grep -h 'BEAST\ v1' $y | wc -l)"
	MY_BEAST2_VER_CHECK="$(grep -h 'BEAST\ v2' $y | wc -l)"
	rm ./file.tmp

echo "INFO      | $(date) | STEP #3: EXTRACT MLE RESULTS FROM OUTPUT FILES. "

################################## extractB1Results.sh ###################################

	extractB1Results () {


	##--Get lines from each file with path sampling (PS) and, if present, stepping stone (SS)
	##--sampling MLE output, then add filename followed by next line with MLE estimate into 
	##--a separate file "output.txt", doing this for all .out files: 
	(
		for i in $MY_BEAST_OUTPUT_FILES; do 
			echo "$i"
			echo `basename "$i"` > "${i}"_filename.tmp
#
				grep -n "log marginal likelihood (using path sampling) from pathLikelihood.delta =" ${i} | \
				awk -F"= " '{print $NF}' > "${i}"_PSMLEs.tmp
	
				grep -n "log marginal likelihood (using stepping stone sampling) from pathLikelihood.delta =" ${i} | \
				awk -F"= " '{print $NF}' > "${i}"_SSMLEs.tmp
#
				MY_PS_RESULT="$(head -n1 ${i}_PSMLEs.tmp)"
				MY_SS_RESULT="$(head -n1 ${i}_SSMLEs.tmp)"
#
			echo "${i}"_filename.tmp "$MY_PS_RESULT" "$MY_SS_RESULT" >> data.tmp
		done
	)

	rm ./*_filename.tmp
	rm ./*_PSMLEs.tmp
	rm ./*_SSMLEs.tmp

}

################################## extractB2Results.sh ###################################

	extractB2Results () {


	##--Get line from each file with path sampling (PS) MLE output, then add filename followed 
	##--by next line with MLE estimate into a separate file "output.txt", doing this for all
	##--.out files: 
	(
		for i in $MY_BEAST_OUTPUT_FILES; do 
			echo "$i"
			echo `basename "$i"` > "${i}"_filename.tmp
#
				grep -n "marginal L estimate =" ${i} | \
				awk -F"= " '{print $NF}' > "${i}"_PSMLEs.tmp
	
##				grep -n "log marginal likelihood (using stepping stone sampling) from pathLikelihood.delta =" ${i} | \
##				awk -F"= " '{print $NF}' > "${i}"_SSMLEs.tmp
#
				MY_PS_RESULT="$(head -n1 ${i}_PSMLEs.tmp)"
##				MY_SS_RESULT="$(head -n1 ${i}_SSMLEs.tmp)"
#
	
			##--The next step will be putting a final file of the MLE results together. Here,
			##--the issue is that BEAST2 runs usually output PS-based MLE values or SS-based
			##--MLE values, but not both. So, if we tried to insert a third column in each
			##--holding values from "$MY_SS_RESULT" (as in the extractB1Results function above),
			##--then we would be left with an empty third column. This would cause the final
			##--data file output in Step #4 below to be unreadble in R, so that the downstream
			##--step, Step #5, would also fail. 
			#
			##--In order to fix this, we simply will add zeros in place of the SS_MLE values 
			##--(in place of "$MY_SS_RESULT" on Line 60 above), effectively creating a "dummy"
			##--variable of the third column, as follows:
			echo "${i}"_filename.tmp "$MY_PS_RESULT" 0 >> data.tmp
		done
	)

	rm ./*_filename.tmp
	rm ./*_PSMLEs.tmp
##	rm ./*_SSMLEs.tmp

}



##--Don't forget to run the (single) appropriate function! If output files from BEAST1 *and*
##--BEAST2 runs are present in current working directory (=NOT ALLOWED!), then the BEAST1 
##--results will simply be overwritten. 
if [[ "$MY_BEAST1_VER_CHECK" -gt "0" ]]; then
	echo "INFO      | $(date) |          BEAST v1+ output files detected; conducting post-processing accordingly... "
	echo "INFO      | $(date) |          Extracting MLE results from the following output files: "
	extractB1Results
fi
if [[ "$MY_BEAST2_VER_CHECK" -gt "0" ]]; then
	echo "INFO      | $(date) |          BEAST v2+ output files detected; conducting post-processing accordingly... "
	echo "INFO      | $(date) |          Extracting MLE results from the following output files: "
	extractB2Results
fi



echo "INFO      | $(date) | STEP #4: ARRANGE MLE RESULTS IN TAB-DELIMITED FILE WITH HEADER. "
	echo "INFO      | $(date) |          Placing results into 'MLE.output.txt' in current working directory. "
	echo "File	PS_MLE	SS_MLE" > header.txt	## Make header row. Change these codes as needed.
	cat header.txt data.tmp | sed 's/\_filename.tmp//g; s/\ /	/g' > MLE.output.txt

	echo "INFO      | $(date) |          Cleaning up... "
	rm header.txt
	rm data.tmp


echo "INFO      | $(date) | STEP #5: LOAD MLE RESULTS INTO R AND COMPUTE BAYES FACTOR TABLES. "
##--We do this in an R script that I wrote named "2logeB10.R" that we simply call here. 
##--Note this script needs to be either in the working directory or the user's path.

	echo "INFO      | $(date) |          Calculating Bayes factors in R using '2logeB10.R' script... "
	R CMD BATCH 2logeB10.R

if [[ -s ./2logeB10.Rout  ]] && [[ "$(wc -c 2logeB10.Rout | perl -pe 's/\ +([0-9]{4}).*$/$1/g')" -gt "3960" ]]; then
	echo "INFO      | $(date) |          R calculations complete. "
fi

echo "INFO      | $(date) | Done summarizing marginal-likelihood estimation results in BEAST using MLEResultsProc. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
