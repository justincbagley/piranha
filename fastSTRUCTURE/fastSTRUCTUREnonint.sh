#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: fastSTRUCTUREnonint.sh                                                           #
  VERSION="v1.1.2"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley on Wed, 27 Jul 2016 00:48:37 -0300                      #
# Last update: March 7, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR RUNNING fastSTRUCTURE (Raj et al. 2014) ON BIALLELIC SNP DATASETS     #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

echo "
fastSTRUCTUREnonint.sh v1.1.2, March 2019  (part of PIrANHA v0.1.7+)  "
echo "Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.  "
echo "------------------------------------------------------------------------------------------"
######################################## START ###########################################
echo "INFO      | $(date) | Step #1: Set up workspace by reading user input, setting environmental variables. "
	MY_FASTSTRUCTURE_WKDIR="$(pwd -P)" ;
	MY_PATH="$(pwd -P | sed 's/$/\//g' | sed 's/.*\/\(.*\/\)\(.*\/\)/\.\.\.\/\1\2/g')"
echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "

	fsPATH="/Applications/STRUCTURE-fastStructure-e47212f/structure.py" ;

	fsInput="hypostomus_str" ;			## Enter the name of your input file (e.g. hypostomus_str). *Remember* the file should have the extension ".str" but here you should _NOT_ enter the extension.

	lK="1"	 ;							## Enter the lowest value of K to be modeled (e.g. 1) inside the quotes.

	uK="10"	 ;							## Enter the upper value of K to be modeled (e.g. 10) inside the quotes.

	fsOutput="hypostomus_noout_simple"  ## Specify a name (e.g. hypostomus_noout_simple) for the output inside the quotes.

	MY_FASTSTRUCTURE_PATH="$(echo $fsPATH)" ;


echo "INFO      | $(date) | Step #2: Run fastSTRUCTURE on range of K values specified by user. "
echo "INFO      | $(date) |          Modeling K = $lK to $uK clusters in fastSTRUCTURE. "

(
	for (( i=$lK; i<=$uK; i++ )); do
		echo "$i";
		python $MY_FASTSTRUCTURE_PATH -K "$i" --input="$MY_FASTSTRUCTURE_WKDIR/$fsInput" --output="$fsOutput" --format=str --full --seed=100  ;
	done
)

echo "INFO      | $(date) |         fastSTRUCTURE runs completed. "


echo "INFO      | $(date) | Step #3: Estimate model complexity. "
###### Obtain an estimate of the model complexity for each set of runs (per species):
	MY_CHOOSEK_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/chooseK.py/g')" ;

	python "$MY_CHOOSEK_PATH" --input="$fsOutput" > chooseK.out.txt ;

echo "INFO      | $(date) |         Finished estimating model complexity. "
	cat chooseK.out.txt ;


echo "INFO      | $(date) | Step #4: Visualize results. "
###### Use DISTRUCT to create graphical output of results corresponding to the best K value modeled.
	MY_EXTRACTED_BESTK="$(grep -n "complexity" \
	./chooseK.out.txt | \
	awk -F"=" '{print $NF}')" ;			## This pulls out the correct bestK value from the "chooseK.out.txt" file output during Step 3 above.
	
	MY_DISTRUCT_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/distruct.py/g')" ;
	
	python "$MY_DISTRUCT_PATH" -K "$MY_EXTRACTED_BESTK" --input="$MY_FASTSTRUCTURE_WKDIR/$fsOutput" --output="$fsOutput"_distruct.svg ;
	

#echo "INFO      | $(date) | Done!!! fastSTRUCTURE analysis complete. "
#echo "Bye.
#"
echo "------------------------------------------------------------------------------------------
"
#
#
#
######################################### END ############################################

exit 0
