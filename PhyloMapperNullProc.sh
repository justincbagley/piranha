#!/bin/sh

##########################################################################################
# File: PhyloMapperNullProc.sh, v1.0                                                     #
# Author: Justin C. Bagley                                                               #
#                                                                                        #
# Created by Justin Bagley in October 2016, email <bagleyj@umsl.edu>                     #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
#                                                                                        #
# Description:                                                                           #
##########################################################################################

echo "
##########################################################################################
#                          PhyloMapperNullProc v1, October 2016                          #
##########################################################################################"

MY_LOGFILE=$(echo ./*.log)
#echo $MY_LOGFILE
MY_LOGFILE_BASENAME="$(echo $MY_LOGFILE | sed 's/\.\///g; s/\.log//g')"


	read -p "INPUT     | $(date) |         Enter the name of the focal clade in your PhyloMapper analysis, \
e.g. 'ingroup' : " focalClade 


	##--Next two lines work, but I want to comment them out and use different output file names (below).
	##	grep '\t'$focalClade'' $(echo $MY_LOGFILE) > ./"$MY_LOGFILE_BASENAME"_ancest.tmp
	##	sed 's/.*'$focalClade'//g' ./"$MY_LOGFILE_BASENAME"_ancest.tmp > ./"$MY_LOGFILE_BASENAME"_ancestLocs.txt


	##--File processing steps coded w/new output file names:
	grep '\t'$focalClade'' $(echo $MY_LOGFILE) > ./pm_"$focalClade"_ancest.tmp
	sed 's/.*'$focalClade'//g; s/^	//g' ./pm_"$focalClade"_ancest.tmp > pm_"$focalClade"_ancest_2.tmp
	echo "LATITUDE   LONGITUDE" > header.tmp

	cat header.tmp pm_"$focalClade"_ancest_2.tmp > ./pm_"$focalClade"_ancestLocs.txt

	rm ./*.tmp


echo "INFO      | $(date) | Done processing results of PhyloMapper null (randomization) analysis."
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
