#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: PhyloMapperNullProc.sh                                                           #
  VERSION="v1.1"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Tue, 11 Oct 2016 09:41:06 -0300.                     #
# Last update: March 3, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR POST-PROCESSING RESULTS OF A PHYLOMAPPER NULL MODEL (RANDOMIZATION)   #
# ANALYSIS                                                                               #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

echo "
##########################################################################################
#                          PhyloMapperNullProc v1.1, March 2019                          #
##########################################################################################
"

MY_LOGFILE=$(echo ./*.log)
echo "INPUT     | $(date) |         Read in the following PhyloMapper log file: $MY_LOGFILE "
MY_LOGFILE_BASENAME="$(echo $MY_LOGFILE | sed 's/\.\///g; s/\.log//g')"


	read -p "INPUT     | $(date) |         Enter the name of the focal clade in your PhyloMapper analysis, \
e.g. 'ingroup' : " focalClade 


	##--Next two lines work, but I want to comment them out and use different output file names (below).
	##	grep '\t'$focalClade'' $(echo $MY_LOGFILE) > ./"$MY_LOGFILE_BASENAME"_ancest.tmp
	##	sed 's/.*'$focalClade'//g' ./"$MY_LOGFILE_BASENAME"_ancest.tmp > ./"$MY_LOGFILE_BASENAME"_ancestLocs.txt


	##--File processing steps coded w/new output file names:
	grep '\t'$focalClade'' $(echo $MY_LOGFILE) > ./pm_"$focalClade"_ancest.tmp ;
	sed 's/.*'$focalClade'//g; s/^	//g' ./pm_"$focalClade"_ancest.tmp > pm_"$focalClade"_ancest_2.tmp ;
	echo "LATITUDE   LONGITUDE" > header.tmp ;

	cat header.tmp pm_"$focalClade"_ancest_2.tmp > ./pm_"$focalClade"_ancestLocs.txt ;

	rm ./*.tmp;


echo "INFO      | $(date) | Done processing results of PhyloMapper null (randomization) analysis. "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
