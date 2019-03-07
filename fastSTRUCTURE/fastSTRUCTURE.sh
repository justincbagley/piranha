#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: fastSTRUCTURE.sh                                                                 #
  VERSION="v1.1"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Wed, 27 Jul 2016 00:48:14 -0300.                     #
# Last update: September 7, 2016                                                         #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# INTERACTIVE SHELL SCRIPT FOR RUNNING fastSTRUCTURE (Raj et al. 2014) ON BIALLELIC SNP  #
# DATASETS                                                                               #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

echo "
##########################################################################################
#                         fastSTRUCTURE.sh v1.1, September 2016                          #
##########################################################################################
"

######################################## START ###########################################
echo "INFO      | $(date) | STEP 1. SETUP: READ USER INPUT, SET VARIABLES. "
	MY_FASTSTRUCTURE_WKDIR="$(pwd)" ;

	read -p "INPUT     | $(date) |         Enter the path to a working copy of fast structure on your machine, \
e.g. '/Applications/STRUCTURE-fastStructure-e47212f/structure.py' : " fsPATH 

	read -p "INPUT     | $(date) |         Enter the name of your input file (remember it should have no extension, e.g. hypostomus_str): " fsInput

	read -p "INPUT     | $(date) |         Enter the lowest value of K to be modeled (e.g. 1) : " lK

	read -p "INPUT     | $(date) |         Enter the upper value of K to be modeled (e.g. 10) : " uK

	read -p "INPUT     | $(date) |         Specify a name (e.g. hypostomus_noout_simple) for the output: " fsOutput 

	MY_FASTSTRUCTURE_PATH="$(echo $fsPATH)" ;


echo "INFO      | $(date) | STEP 2. RUN fastSTRUCTURE ON RANGE OF K SPECIFIED BY USER. "
echo "INFO      | $(date) |         Modeling K = $lK to $uK clusters in fastSTRUCTURE. "

(
	for (( i=$lK; i<=$uK; i++ )); do
		echo "$i";
		python "$MY_FASTSTRUCTURE_PATH" -K "$i" --input="$MY_FASTSTRUCTURE_WKDIR/$fsInput" --output="$fsOutput" --format=str --full --seed=100 ;
	done
)

echo "INFO      | $(date) |         fastSTRUCTURE runs completed. "


echo "INFO      | $(date) | STEP 3. MODEL COMPLEXITY. "
###### Obtain an estimate of the model complexity for each set of runs (per species):
	MY_CHOOSEK_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/chooseK.py/g')" ;

	python "$MY_CHOOSEK_PATH" --input="$fsOutput" > chooseK.out.txt ;

echo "INFO      | $(date) |         Finished estimating model complexity. "
	cat chooseK.out.txt ;


echo "INFO      | $(date) | STEP 4. VISUALIZE RESULTS. "
###### Use DISTRUCT to create graphical output of results corresponding to the best K value modeled.
	read -p "INPUT     | $(date) |         Enter the value of K that you want to visualize : " bestK ;

	MY_DISTRUCT_PATH="$(echo $fsPATH | sed 's/structure.py//g' | sed 's/$/distruct.py/g')" ;

	python "$MY_DISTRUCT_PATH" -K "$bestK" --input="$MY_FASTSTRUCTURE_WKDIR/$fsOutput" --output="$fsOutput_distruct.svg" ;


echo "INFO      | $(date) | Done!!! fastSTRUCTURE analysis complete."
echo "Bye.
"
#
#
#
######################################### END ############################################

exit 0
