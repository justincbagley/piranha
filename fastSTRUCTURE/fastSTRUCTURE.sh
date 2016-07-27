#!/bin/sh

##--------------------------------------------------------------------------------------##
##--SHELL SCRIPT FOR RUNNING fastSTRUCTURE ON BIALLELIC SNP DATASETS -------------------##
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
##------------------- STEP 1. SETUP: READ USER INPUT, SET VARIABLES --------------------##
MY_FASTSTRUCTURE_WKDIR="$(pwd)"
#
read -p "########## Enter the path to a working copy of fast structure on your machine, \
e.g. '/Applications/STRUCTURE-fastStructure-e47212f/structure.py' : " fsPATH 
#
read -p "########## Enter the name of your input file (remember it should have no extension, e.g. hypostomus_str): " fsInput
#
read -p "########## Enter the lowest value of K to be modeled (e.g. 1) : " lK
#
read -p "########## Enter the upper value of K to be modeled (e.g. 10) : " uK
#
read -p "########## Specify a name (e.g. hypostomus_noout_simple) for the output: " fsOutput 
#
MY_FASTSTRUCTURE_PATH="$(echo $fsPATH)"
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
#
read -p "########## Enter the value of K that you want to visualize: " bestK
#
MY_DISTRUCT_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/distruct.py/g')"
#
python $MY_DISTRUCT_PATH -K $bestK --input="$MY_FASTSTRUCTURE_WKDIR/$fsOutput" --output="$fsOutput_distruct.svg"
#
echo "########## STATUS: Done!!! fastSTRUCTURE analysis complete."
echo "Bye."
#
#
#
##--------------------------------------------------------------------------------------##

exit 0
