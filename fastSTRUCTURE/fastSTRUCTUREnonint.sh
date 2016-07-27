#!/bin/sh

##--------------------------------------------------------------------------------------##
##--SHELL SCRIPT FOR RUNNING fastSTRUCTURE NON-INTERACTIVELY ON BIALLELIC SNP DATASETS -##
#---This code was written July 25, 2016 by:        -------------------------------------##
#---Justin C. Bagley, Ph.D.                        -------------------------------------##
#---Departamento de Zoologia                       -------------------------------------##
#---Universidade de Brasília, Brasília, DF, Brazil -------------------------------------##
#---For questions, please email jcbagley@unb.br    -------------------------------------##
##--------------------------------------------------------------------------------------##

echo "
##########################################################################################
#                           fastSTRUCTURE.sh v1.0, July 2016                             #
##########################################################################################
"
#
#
#
##------------ STEP 1. SETUP: ASSIGN DIRECTORIES & INFO AS LOCAL VARIABLES -------------##
MY_FASTSTRUCTURE_WKDIR="$(pwd)"
#
fsPATH="/Applications/STRUCTURE-fastStructure-e47212f/structure.py"
#
fsInput="hypostomus_str"			## Enter the name of your input file (e.g. hypostomus_str). *Remember* the file should have the extension ".str" but here you should _NOT_ enter the extension.
#
lK="1"								## Enter the lowest value of K to be modeled (e.g. 1) inside the quotes.
#
uK="10"								## Enter the upper value of K to be modeled (e.g. 10) inside the quotes.
#
fsOutput="hypostomus_noout_simple"  ## Specify a name (e.g. hypostomus_noout_simple) for the output inside the quotes.
#
MY_FASTSTRUCTURE_PATH="$(echo $fsPATH)"
#
#
#
##------------- STEP 2. RUN fastSTRUCTURE ON RANGE OF K SPECIFIED BY USER --------------##
echo "########## STATUS: Modeling K = $lK to $uK clusters in fastSTRUCTURE."
#
(
#	for i in {$lK..$uK}
	for (( i=$lK; i<=$uK; i++ ))
		do
		echo $i
		python $MY_FASTSTRUCTURE_PATH -K $i --input="$MY_FASTSTRUCTURE_WKDIR/$fsInput" --output="$fsOutput" --format=str --full --seed=100
	done
)

echo "########## STATUS: fastSTRUCTURE runs completed."
#
#
#
##----------------------------- STEP 3. MODEL COMPLEXITY -------------------------------##
##--Obtain an estimate of the model complexity for each set of runs (per species):
#
MY_CHOOSEK_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/chooseK.py/g')"
#
python $MY_CHOOSEK_PATH --input="$fsOutput" > chooseK.out.txt
#
echo "########## STATUS: Finished estimating model complexity."
cat chooseK.out.txt
#
#
#
##---------------------------- STEP 4. VISUALIZE RESULTS -------------------------------##
##--Use DISTRUCT to create graphical output of results corresponding to the best K value modeled.
MY_EXTRACTED_BESTK="$(grep -n "complexity" \
./chooseK.out.txt | \
awk -F"=" '{print $NF}')"			## This pulls out the correct bestK value from the "chooseK.out.txt" file output during Step 3 above.
#	
MY_DISTRUCT_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/distruct.py/g')"
#	
python $MY_DISTRUCT_PATH -K $MY_EXTRACTED_BESTK --input="$MY_FASTSTRUCTURE_WKDIR/$fsOutput" --output="$fsOutput"_distruct.svg
#	
echo "########## STATUS: Done!!! fastSTRUCTURE analysis complete."
echo "Bye."
#
#
#
##--------------------------------------------------------------------------------------##

exit 0
