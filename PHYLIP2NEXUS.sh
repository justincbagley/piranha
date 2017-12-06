#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          PHYLIP2NEXUS v1.0, August 2016                                #
#   SHELL SCRIPT FOR CONVERTING A PHYLIP-FORMAT DNA SEQUENCE ALIGNMENT FILE TO NEXUS     #
#   FORMATTED FILE                                                                       #
#  Copyright ©2016 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: August 11, 2016. For questions, please email jcbagley@vcu.edu.                #
##########################################################################################

##--README: This shell script converts a single PHYLIP-formatted DNA sequence alignment
##--file present in the current working directory into NEXUS format. The starting file
##--must have the extension ".phy", and the first line of this file must contain the 
##--number of taxa, followed by one space, followed by the number of characters in the 
##--alignment. Some actions are echoed to screen. The output is a single NEXUS file with
##--the name, "BASENAME_p2N.nex", where "BASENAME" is the base or root name of the 
##--original PHYLIP file. For example in a starting file named "Smerianae_ND4.phy," the
##--BASENAME would be "Smerianae_ND4" and the resulting output file would be named
##--"Smerianae_ND4_p2N.nex". 

echo "
##########################################################################################
#                          PHYLIP2NEXUS v1.0, August 2016                                #
##########################################################################################"

############ STEP #1: SETUP VARIABLES AND SETUP FUNCTIONS
###### Set working directory and filetypes as different variables:
echo "##########  STATUS: Examining current directory, setting variables... "
MY_WORKING_DIR="$(pwd)"
MY_PHYLIP="$(ls . | egrep '.phy$')"
MY_PHYLIP_LENGTH="$(cat $MY_PHYLIP | wc -l | sed 's/(\ )*//g')"

	calc () {					## Make the "handy bash function 'calc'" for subsequent use.
    	bc -l <<< "$@"
	}

MY_BODY_LENGTH="$(calc $MY_PHYLIP_LENGTH - 1)"
## This "MY_BODY_LENGTH" is number of lines comprised by sequence and eof lines; was going to call it "MY_SEQUENCE_AND_EOF_LINES" but thought that name was too long.

tail -n$MY_BODY_LENGTH $MY_PHYLIP > sequences.tmp

MY_NTAX="$(head -n1 $MY_PHYLIP | sed 's/\ [0-9]*//g'| sed 's/[\]*//g')"
MY_NCHAR="$(head -n1 $MY_PHYLIP | sed 's/^[0-9]*\ //g'| sed 's/[\]*//g')"

###### Make NEXUS format file:
echo "##########  STATUS: Making NEXUS formatted file... "

echo "#NEXUS

BEGIN DATA;
	DIMENSIONS NTAX="$MY_NTAX" NCHAR="$MY_NCHAR";
	FORMAT DATATYPE=DNA GAP=- MISSING=N;
	MATRIX" > NEXUS_top.tmp

echo ";
END;
" > NEXUS_bottom.tmp


MY_PHYLIP_BASENAME="$(echo $MY_PHYLIP | sed 's/\.phy//g')"

cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp > ./"$MY_PHYLIP_BASENAME"_p2N.nex


###### Remove temporary or unnecessary files created above:
echo "##########  Removing temporary files... "
rm ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp

echo "##########  Done converting PHYLIP-formatted DNA sequence alignment to NEXUS format." 
echo "Bye."
#
#
#
######################################### END ############################################

exit 0
