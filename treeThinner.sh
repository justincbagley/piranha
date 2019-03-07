#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: treeThinner.sh                                                                   #
  VERSION="v1.1"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Thu, 17 Nov 2016 00:24:53 -0600.                     #
# Last update: March 3, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR DOWNSAMPLING ("THINNING") TREES IN MRBAYES .T FILES SO THAT THEY      #
# CONTAIN EVERY NTH TREE                                                                 #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

echo "
##########################################################################################
#                             treeThinner v1.1, March 2019                               #
##########################################################################################
"

######################################## START ###########################################
## NOTE: try to expand to multiple treefile formats in future versions.

###### A method specific to MrBayes .t trees files: 1) count the number of lines in the
## header (NEXUS top and beginning of TREES block with translated taxon names) by 
## subtracting 1 from the line on which the first ampersand occurs; 2) cut the header 
## section out of the .t file and save it; 3) working only with lines containing trees 
## (thus with ampersands or "&U"; get these lines by using grep), get every nth line of 
## the trees; and 4) paste the header, the trees, and an appropriate final 1-2 lines 
## back together as a final output .t file that has been "thinned".

### STEP #1:
read -p "Please enter the name of your MrBayes .t trees file : " MY_TFILE ;
read -p "Please enter the frequency (n) of nth lines that you would like to keep : " NTH_LINES ;

calc () {
	bc -l <<< "$@"
}
   MY_FIRST_TREELINE=$(awk '/&U/{ print NR}' $MY_TFILE | head -n1) ;
   MY_NUM_HEADER_LINES="$(calc $MY_FIRST_TREELINE - 1)" ;

### STEP #2:
   head -n$MY_NUM_HEADER_LINES $MY_TFILE > header.txt ;
   ## alternatively, extracting only interior lines: ~$ sed -n <first_line>,<second_line>p filename > newfile

### STEP #3:
   grep "&U" $MY_TFILE > trees.txt ;
   awk 'NR == 1 || NR % '$NTH_LINES' == 0' ./trees.txt | sed '1d' > thinned_trees.txt ;

### STEP #4:
   echo "END;
" > ./end.txt

   cat ./header.txt ./thinned_trees.txt ./end.txt > ./nth_line_trees.t ;

### CLEANUP.
   rm ./header.txt ;
   rm ./trees.txt ;
   rm ./thinned_trees.txt ;
   rm ./end.txt ;

#
#
#
######################################### END ############################################

exit 0
