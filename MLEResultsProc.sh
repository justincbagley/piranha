#!/bin/sh

##--------------------------------------------------------------------------------------##
##--SHELL SCRIPT FOR POST-PROCESSING OF MARGINAL LIKELIHOOD ESTIMATION RESULTS FROM-----##
##--CONDUCTING PATH SAMPLING OR STEPPING-STONE SAMPLING IN BEAST -----------------------##
#---This code was written July 18, 2016 by:        -------------------------------------##
#---Justin C. Bagley, Ph.D.                        -------------------------------------##
#---Departamento de Zoologia                       -------------------------------------##
#---Universidade de Brasília, Brasília, DF, Brazil -------------------------------------##
#---For questions, please email jcbagley@unb.br    -------------------------------------##
##--------------------------------------------------------------------------------------##

##--For README: Starts from a folder containing BEAST STDOUT files with extension ".out"
##--from one run, or from multiple runs in the case of model comparison (e.g. output files 
##--from multiple *BEAST species tree runs that you want to compare using the Bayes factor
##--delimitation, BFD, procedure of Grummer et al. 2014). This code extracts path sampling
##--(PS) and stepping-stone sampling (SS) results from the final sections of the output
##--files and organizes them into a summary table file.

echo "
##########################################################################################
#                            MLEResultsProc v1.0, July 2016                              #
##########################################################################################
"
#
#
#
##--------------- STEP #1: EXTRACT MLE RESULTS FROM BEAST OUTPUT FILE ------------------##
MY_BEAST_OUTPUT_FILES=*.out
#
##--Get line from each file with path sampling (PS) MLE output, then add filename followed 
##--by next line with MLE estimate into a separate file "output.txt", doing this for all
##--.out files: 
(
for i in $MY_BEAST_OUTPUT_FILES
	do 
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
#	echo ">"${i}_filename.tmp "${i}_PSMLEs.tmp" "${i}_SSMLEs.tmp" >> data.tmp
	echo ${i}_filename.tmp $MY_PS_RESULT $MY_SS_RESULT >> data.tmp
done
)
#
rm ./*_filename.tmp
rm ./*_PSMLEs.tmp
rm ./*_SSMLEs.tmp
#
#
#
##---------- STEP #2: ARRANGE MLE RESULTS IN TAB-DELIMITED FILE WITH HEADER ------------##
echo "File	PS_MLE	SS_MLE" > header.txt	## Make header row. Change these codes as needed.
cat header.txt data.tmp | sed 's/\_filename.tmp//g; s/\ /	/g' > MLE.output.txt
#
rm header.txt
rm data.tmp
#
#
#
##--------- STEP #3: LOAD MLE RESULTS INTO R AND COMPUTE BAYES FACTOR TABLES -----------##
##--We do this in an R script that I wrote named "2log10BF.R" that we simply call here. 
##--Note this script needs to be either in the working directory or the user's path.
R CMD BATCH 2log10BF.R
#
#
#
##--------------------------------------------------------------------------------------##

exit 0
