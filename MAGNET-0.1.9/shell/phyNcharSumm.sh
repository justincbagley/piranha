#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: phyNcharSumm.sh                                                                  #
  VERSION="v1.1"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on November 9, 2016.                                    #
# Last update: March 6, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT THAT SUMMARIZES THE NUMBER OF CHARACTERS IN EACH OF N PHYLIP DNA SEQUENCE #
# ALIGNMENTS IN CURRENT WORKING DIRECTORY AND SAVES THIS INFORMATION TO FILE             #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

###### Starting from a folder containing multiple PHYLIP alignment files (e.g. as generated
## by MAGNET.sh for indiv. SNP loci), this script uses a for loop to echo all alignment
## names (containing locus or taxon information) to file, and then echoes the number of 
## characters (Nchar) recursively to a file named "nchar.txt" in the working directory.

(
	for i in ./*.phy; do 
		echo "$i" >> phyalign_names.txt; 
		echo "$(head -n1 $i | awk -F"[0-9]*\ " '{print $NF}')" >> nchar.txt; 
	done;
)

## I would like to build on this by calculating statistics from the nchar list from within
## the shell.

exit 0
