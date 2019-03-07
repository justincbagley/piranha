#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: PHYLIP2NEXUS.sh                                                                  #
  VERSION="v1.1.1"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Thu, Mar 15 15:27:49 2018 -0400.                     #
# Last update: March 6, 2019                                                             #
# Copyright (c) 2018-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR CONVERTING A PHYLIP-FORMATTED DNA SEQUENCE ALIGNMENT TO NEXUS FORMAT  #
#                                                                                        #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_PARTITIONS_FILE=NULL
MY_PARTFILE_FORMAT=raxml

############ CREATE USAGE & HELP TEXTS
USAGE="Usage: $(basename $0) [Help: -h help] [Options: -p f V --version] <inputPHYLIP> 
 ## Help:
  -h   help text (also: --help) echo this help text and exit

 ## Options:
  -p   partitionsFile (def: NULL; other: filename) name of file containing RAxML- or NEXUS-
       formatted character set partitions file
  -f   fileType (def: raxml; nexus|NEX|nex) partitions file type, either with RAxML DNA 
       partitions or NEXUS character sets
  -V   version (also: --version) echo version and exit

 OVERVIEW
 THIS SCRIPT Reads in a single PHYLIP DNA sequence alignment and converts it to NEXUS ('.nex') 
 format. Sequence names should include alphanumeric, hyphen, and underscore characters but no
 spaces. Optionally, the user may use the -p and -f flags to read in and process an external
 partitions file containing information on character set partitions for <inputPHYLIP>. This 
 partitions file may be in standard RAxML or NEXUS formats.

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

Created by Justin Bagley on Thu, Mar 15 15:27:49 2018 -0400.
Copyright (c) 2018-2019 Justin C. Bagley. All rights reserved.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

############ PARSE THE OPTIONS
while getopts 'p:f:' opt ; do
  case $opt in
## PHYLIP2NEXUS options:
    p) MY_PARTITIONS_FILE=$OPTARG ;;
    f) MY_PARTFILE_FORMAT=$OPTARG ;;
## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
	echo "$USAGE"
	exit 1
fi
MY_PHYLIP="$1"

echo "
##########################################################################################
#                            PHYLIP2NEXUS v1.1.1, March 2019                             #
##########################################################################################
"

############ STEP #1: SET UP VARIABLES AND SETUP FUNCTIONS
###### Set working directory and filetypes as different variables:
echo "INFO      | $(date) | STEP #1: SET UP ENVIRONMENTAL VARIABLES AND USEFUL FUNCTIONS. "
echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$PWD "	
echo "INFO      | $(date) |          Input PHYLIP file: $1 "
echo "INFO      | $(date) |          Examining current directory, setting variables... "
	MY_PHYLIP_LENGTH="$(cat $MY_PHYLIP | wc -l | sed 's/(\ )*//g')";

	calc () {					## Make the "handy bash function 'calc'" for subsequent use.
    		bc -l <<< "$@"
	}

	MY_BODY_LENGTH="$(calc $MY_PHYLIP_LENGTH - 1)";
	## This "MY_BODY_LENGTH" is number of lines comprised by sequence and eof lines; was going to call it "MY_SEQUENCE_AND_EOF_LINES" but thought that name was too long.

	tail -n$MY_BODY_LENGTH $MY_PHYLIP > sequences.tmp;

	MY_NTAX="$(head -n1 $MY_PHYLIP | sed 's/\ [0-9]*//g'| sed 's/[\]*//g')";
	MY_NCHAR="$(head -n1 $MY_PHYLIP | sed 's/^[0-9]*\ //g'| sed 's/[\]*//g')";

echo "INFO      | $(date) | STEP #2: MAKE NEXUS-FORMATTED ALIGNMENT FILE. "
###### Make NEXUS format file:
	echo "INFO      | $(date) |          Making NEXUS-formatted file... "

echo "#NEXUS

BEGIN DATA;
	DIMENSIONS NTAX="$MY_NTAX" NCHAR="$MY_NCHAR";
	FORMAT DATATYPE=DNA GAP=- MISSING=N;
	MATRIX" > NEXUS_top.tmp

echo ";
END;
" > NEXUS_bottom.tmp

	MY_PHYLIP_BASENAME="$(echo $MY_PHYLIP | sed 's/\.phy//g')" ;

echo "INFO      | $(date) |          If available, add partition information to NEXUS... "
if [[ "$MY_PARTITIONS_FILE" = "NULL" ]]; then
	echo "INFO      | $(date) |          No partitions file detected... "
	cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp > ./"$MY_PHYLIP_BASENAME".nex ;
	echo "INFO      | $(date) |          Final, simple NEXUS written to ${MY_PHYLIP_BASENAME}.nex "

elif [[ "$MY_PARTITIONS_FILE" != "NULL" ]] && [[ "$MY_PARTFILE_FORMAT" = "raxml" ]]; then
	echo "INFO      | $(date) |          Read RAxML-style partitions file. Adding partition information to final NEXUS file... "
	echo "begin sets;" > ./begin.tmp
	sed $'s/^DNA\,\ /\tcharset\ /g; s/$/\;/g' "$MY_PARTITIONS_FILE" > NEXUS_charsets.tmp ;
	echo "end;" > ./end.tmp
#	
		## OS detection using idea from URL: https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
		unamestr="$(uname)";
		if [[ "$unamestr" == "Darwin" ]]; then
			sed -i '' $'s/$/\\\n/' ./end.tmp ;
		elif [[ "$unamestr" == "Linux" ]]; then
			sed -i 's/$/\n/' ./end.tmp ;
		fi
#
	cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp ./begin.tmp ./NEXUS_charsets.tmp ./end.tmp > ./"$MY_PHYLIP_BASENAME".nex ;
	echo "INFO      | $(date) |          Final, partitioned NEXUS written to ${MY_PHYLIP_BASENAME}.nex "

elif [[ "$MY_PARTITIONS_FILE" != "NULL" ]] && [[ "$MY_PARTFILE_FORMAT" = "nexus" ]] || [[ "$MY_PARTFILE_FORMAT" = "nex" ]] || [[ "$MY_PARTFILE_FORMAT" = "NEX" ]]; then
	echo "INFO      | $(date) |          Read NEXUS-style charset file. Adding partition information to final NEXUS file... "
	cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp ./"$MY_PARTITIONS_FILE" > ./"$MY_PHYLIP_BASENAME".nex ;
	echo "INFO      | $(date) |          Final, partitioned NEXUS written to ${MY_PHYLIP_BASENAME}.nex "

fi

echo "INFO      | $(date) | STEP #3: CLEAN UP WORKSPACE BY REMOVING TEMPORARY FILES GENERATED DURING RUN. "
###### Remove temporary or unnecessary files created above:
	echo "INFO      | $(date) |          Removing temporary files... "
	rm ./*.tmp ;

echo "INFO      | $(date) | Done converting PHYLIP-formatted DNA sequence alignment to NEXUS format using PHYLIP2NEXUS.sh." 
echo "Bye.
"
#
#
#
######################################### END ############################################

exit 0
