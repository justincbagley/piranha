#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: PHYLIPsubsampler.sh                                                              #
  VERSION="v1.1"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley on Tue, 19 Feb 2019 22:36:23 -0600                      #
# Last update: February 19, 2019                                                         #
# Copyright (c) 2019 Justin C. Bagley. All rights reserved.                              #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT THAT AUTOMATES SUBSAMPLING EACH OF ONE TO MULTIPLE PHYLIP ALIGNMENT       #
# FILES DOWN TO ONE (RANDOM) SEQUENCE PER SPECIES (FOR SPECIES TREE ANALYSIS)            #
#                                                                                        #
##########################################################################################

echo "
##########################################################################################
#                          PHYLIPsubsampler v1.1, February 2019                          #
##########################################################################################
"

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_INPUT_FILE=NULL
MY_ASSIGNMENT_FILE=assignments.txt

############ CREATE USAGE & HELP TEXTS
USAGE="Usage: $(basename "$0") [Help: -h help] [Options: -i a] [stdin:] <workingDir> 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -i   inputPhylip (def: NULL) Used in case of subsampling a single input Phylip file; 
       otherwise, left blank when analyzing multiple Phylip files (default)
  -a   assignmentFile (def: $MY_ASSIGNMENT_FILE) Name of assignment file containing four-letter
       population or taxon assignment codes, one per line

 OVERVIEW
 Takes as input the name of the current working directory, <workingDir>, where there exists
 a single sequential Phylip file (must use -i <filename.phy>) or multiple sequential Phylip 
 files that the user wishes to subsample, keeping one random (first) sequence per population 
 or species. This is very useful when you want to subsample one or more datasets in order
 to conduct single-tip phylogenetic analyses, for example when (1) estimating 1-tip-per-
 species gene trees for species tree reconstruction, or (2) when you will use the Phylip 
 files to directly estimate the species tree.
 
 The populations or species are contained in an assignment file, the filename of which is 
 assed to the program. Sequence names may not include space or underline characters, or 
 there will be issues. _Interleaved Phylip format is not supported._

 The -i flag supplies the name of a single input Phylip file in the current <workingDir> for
 analysis. If this flag is not used, then the program will assume that multiple Phylip files
 are present in <workingDir> and will attempt to subsample all of them. This is useful when
 you want to subsample a single Phylip file for single-tip phylogenetic analyses, for example
 during species tree reconstruction.

 The -a flag allows users to specify an assignment file. This file must contain a single,
 four-letter population or taxon assignment code on each line, which corresponds to the 
 first four letters of each taxon/sequence label in (each of) the Phylip file(s). In each
 Phylip file, the four-letter code must be followed by a dash (text en dash) character,
 which can be followed by any numeric string. The specificity of this format limits the
 generality of the script, necessitating that the user ensure that all individual sequence/
 taxon names fit the required format. However, the required format is in and of itself very
 simple; an example of a 'legal' taxon/sequence label would be 'Pibf-15', where 'Pibf' is a
 four-letter code representing the species in question and '15' refers to the 15th sequenced
 individual. The default name for the assignment file is 'assignments.txt', which will be 
 expected if no assignment file is specified using the -a flag.

		## EXAMPLE 
		./PHYLIPsubsampler.sh -a species.txt .	## With user-specified assignment
							## file named 'species.txt'.

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub package, Available at: 
	<http://github.com/justincbagley/PIrANHA>.
 or
 Bagley, J.C. 2019. PIrANHA. [Data set] Zenodo, Available at: 
	<http://doi.org/10.5281/zenodo.596766>.
 or
 Bagley, J.C. 2019. justincbagley/PIrANHA. GitHub package, Available at: 
	<http://doi.org/10.5281/zenodo.596766>.

Created by Justin Bagley on Tue, 19 Feb 2019 22:36:23 -0600
Copyright (c) 2019 Justin C. Bagley. All rights reserved.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

############ PARSE THE OPTIONS
while getopts 'i:a:' opt ; do
  case $opt in
## Datafile options:
    i) MY_INPUT_FILE=$OPTARG ;;
    a) MY_ASSIGNMENT_FILE=$OPTARG ;;

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
USER_SPEC_PATH="$1"

######################################## START ###########################################
echo "INFO      | $(date) | Starting phylipSubsampler analysis... "
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set new path/dir environmental variable to user specified path, then create useful
###### CHECK MACHINE TYPE:
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

##--shell functions and variables:
if [[ "$USER_SPEC_PATH" = "$(printf '%q\n' "$(pwd)")" ]] || [[ "$USER_SPEC_PATH" = "." ]]; then
	MY_CWD="$(printf '%q\n' "$(pwd)" | sed 's/\\//g')"
	echo "INFO      | $(date) |          Setting working directory to:  "
	echo "$MY_CWD "
elif [[ "$USER_SPEC_PATH" != "$(printf '%q\n' "$(pwd)")" ]]; then
	if [[ "$USER_SPEC_PATH" = ".." ]] || [[ "$USER_SPEC_PATH" = "../" ]] || [[ "$USER_SPEC_PATH" = "..;" ]] || [[ "$USER_SPEC_PATH" = "../;" ]]; then
		cd ..;
		MY_CWD="$(printf '%q\n' "$(pwd)" | sed 's/\\//g')"
	else
		MY_CWD=$USER_SPEC_PATH
		echo "INFO      | $(date) |          Setting working directory to user-specified dir:  "	
		echo "$MY_CWD "
		cd "$MY_CWD"
	fi
else
	echo "WARNING!  | $(date) |          Null working directory path. Quitting... "
	exit 1
fi


###### FILE PROCESSING
echo "INFO      | $(date) | STEP #2: CONDUCTING FILE PROCESSING. "

##--If MY_INPUT_FILE is 'NULL' (not given or changed by user), then use MY_ASSIGNMENT_FILE
##--that is read in and conduct subsampling as usual on all Phylip alignments (i.e. in
##--variable $MY_PHYLIP_ALIGNMENTS) within the current working dir.
if [[ "$MY_INPUT_FILE" = "NULL" ]]; then

MY_PHYLIP_ALIGNMENTS=./*.phy
(
	for i in $MY_PHYLIP_ALIGNMENTS; do 
		LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\.phy//g; s/\/$//g')"
		echo "$LOCUS_NAME"

			head -n+1 "$i" > ./head.tmp; 

			count=1
			while read j; do
			# echo "$j"
			grep "$(echo $j)" "$i" | head -n1 > ./ind"$count".tmp;
			COUNT_PLUS_ONE="$((count++))"
			done < "$MY_ASSIGNMENT_FILE"

			(
				for k in ./ind*.tmp; do  
					if [[ "$(wc -c $k | sed 's/\.\/.*//g')" -gt "0" ]]; then 
					echo OK >> check.tmp; 
					fi; 
				done
			)

			MY_NUMTAX="$(wc -l ./check.tmp | sed 's/\ \.\/.*//g; s/\ //g')"
			MY_NUMCHAR="$(cat head.tmp | sed 's/^[0-9]*\ //g')"
			echo "$MY_NUMTAX   $MY_NUMCHAR" > ./new_head.tmp

		rm "$i"
		cat ./new_head.tmp ./ind*.tmp > "$LOCUS_NAME".phy;
		rm ./*.tmp

		while read j; do
			if [[ "${machine}" = "Mac" ]]; then
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			fi

			if [[ "${machine}" = "Linux" ]]; then
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			fi
		done < "$MY_ASSIGNMENT_FILE"

	done
)

fi



##--If MY_INPUT_FILE is given or changed by user (not NULL), then use MY_ASSIGNMENT_FILE
##--that is read in and conduct subsampling only on the alignment in $MY_INPUT_FILE, 
##--which must be within the current working dir. This analysis will only subset one file.
if [[ "$MY_INPUT_FILE" != "NULL" ]]; then

(
	for i in $MY_INPUT_FILE; do 
		LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\.phy//g; s/\/$//g')"
		echo "$LOCUS_NAME"

			head -n+1 "$i" > ./head.tmp; 

			count=1
			while read j; do
			# echo "$j"
			grep "$(echo $j)" "$i" | head -n1 > ./ind"$count".tmp;
			COUNT_PLUS_ONE="$((count++))"
			done < "$MY_ASSIGNMENT_FILE"

			(
				for k in ./ind*.tmp; do  
					if [[ "$(wc -c $k | sed 's/\.\/.*//g')" -gt "0" ]]; then 
					echo OK >> check.tmp; 
					fi; 
				done
			)

			MY_NUMTAX="$(wc -l ./check.tmp | sed 's/\ \.\/.*//g; s/\ //g')"
			MY_NUMCHAR="$(cat head.tmp | sed 's/^[0-9]*\ //g')"
			echo "$MY_NUMTAX   $MY_NUMCHAR" > ./new_head.tmp

		rm "$i"
		cat ./new_head.tmp ./ind*.tmp > "$LOCUS_NAME".phy;
		rm ./*.tmp

		while read j; do
			if [[ "${machine}" = "Mac" ]]; then
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			fi

			if [[ "${machine}" = "Linux" ]]; then
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
				sed -i 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			fi
		done < "$MY_ASSIGNMENT_FILE"

	done
)

fi


echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
