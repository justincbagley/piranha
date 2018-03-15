#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                             PHYLIP2NEXUS v1.1, March 2018                              #
#  SHELL SCRIPT FOR CONVERTING A PHYLIP-FORMAT DNA SEQUENCE ALIGNMENT FILE TO NEXUS      #
#  FORMATTED FILE                                                                        #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: March 15, 2018. For questions, please email jcbagley@vcu.edu.                 #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_PARTITIONS_FILE=NULL
MY_PARTFILE_FORMAT=raxml

############ PARSE THE OPTIONS
while getopts 'p:f:' opt ; do
  case $opt in

## ∂a∂i options:
    p) MY_PARTITIONS_FILE=$OPTARG ;;
    f) MY_PARTFILE_FORMAT=$OPTARG ;;

## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
echo "$Usage"
  exit 1
fi
MY_PHYLIP="$1"

echo "
##########################################################################################
#                             PHYLIP2NEXUS v1.1, March 2018                              #
##########################################################################################
"

############ STEP #1: SETUP VARIABLES AND SETUP FUNCTIONS
###### Set working directory and filetypes as different variables:
echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$PWD "	
echo "INFO      | $(date) |          Input PHYLIP file: $1 "
echo "INFO      | $(date) |          Examining current directory, setting variables... "
	MY_WORKING_DIR="$(pwd)"
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
	echo "INFO      | $(date) |          Making NEXUS-formatted file... "

echo "#NEXUS

BEGIN DATA;
	DIMENSIONS NTAX="$MY_NTAX" NCHAR="$MY_NCHAR";
	FORMAT DATATYPE=DNA GAP=- MISSING=N;
	MATRIX" > NEXUS_top.tmp

echo ";
END;
" > NEXUS_bottom.tmp


	MY_PHYLIP_BASENAME="$(echo $MY_PHYLIP | sed 's/\.phy//g')"

if [[ "$MY_PARTITIONS_FILE" = "NULL" ]]; then
	echo "INFO      | $(date) |          No partitions file detected... "
	cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp > ./"$MY_PHYLIP_BASENAME".nex

elif [[ "$MY_PARTITIONS_FILE" != "NULL" ]] && [[ "$MY_PARTFILE_FORMAT" = "raxml" ]]; then
	echo "INFO      | $(date) |          Read RAxML-style partitions file. Adding partition information to final NEXUS file... "
	echo "begin sets;" > ./begin.tmp
	sed $'s/^DNA\,\ /\tcharset\ /g; s/$/\;/g' "$MY_PARTITIONS_FILE" > NEXUS_charsets.tmp
	echo "end;" > ./end.tmp
#	
		## OS detection using idea from URL: https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
		unamestr="$(uname)"
		if [[ "$unamestr" == "Darwin" ]]; then
			sed -i '' $'s/$/\\\n/' ./end.tmp
		elif [[ "$unamestr" == "Linux" ]]; then
			sed -i 's/$/\n/' ./end.tmp
		fi
#
	cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp ./begin.tmp ./NEXUS_charsets.tmp ./end.tmp > ./"$MY_PHYLIP_BASENAME".nex

elif [[ "$MY_PARTITIONS_FILE" != "NULL" ]] && [[ "$MY_PARTFILE_FORMAT" = "NEX" ]] || [[ "$MY_PARTFILE_FORMAT" = "nex" ]]; then
	echo "INFO      | $(date) |          Read NEXUS-style charset file. Adding partition information to final NEXUS file... "
	cat ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp ./"$MY_PARTITIONS_FILE" > ./"$MY_PHYLIP_BASENAME".nex

fi

###### Remove temporary or unnecessary files created above:
	echo "INFO      | $(date) |          Removing temporary files... "
	## rm ./NEXUS_top.tmp ./sequences.tmp ./NEXUS_bottom.tmp
	rm ./*.tmp

echo "INFO      | $(date) |          Done converting PHYLIP-formatted DNA sequence alignment to NEXUS format using PHYLIP2NEXUS.sh." 
echo "Bye.
"
#
#
#
######################################### END ############################################

exit 0
