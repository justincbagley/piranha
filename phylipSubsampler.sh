#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                         phylipSubsampler v1.0, September 2017                          #
#  SHELL SCRIPT THAT AUTOMATES SUBSAMPLING EACH OF ONE TO MULTIPLE PHYLIP ALIGNMENT      #
#  FILES DOWN TO ONE (RANDOM) SEQUENCE PER SPECIES (FOR SPECIES TREE ANALYSIS)           #
#  Copyright ©2017 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: September 27, 2017. For questions, please email bagleyj@umsl.edu.             #
##########################################################################################

echo "
##########################################################################################
#                         phylipSubsampler v1.0, September 2017                          #
##########################################################################################
"

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_INPUT_FILE=NULL
MY_ASSIGNMENT_FILE=assignments.txt

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] [Options: -i a] workingDir 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -i   inputPhylip (def: NULL) Used in case of subsampling a single input Phylip file; 
       otherwise, left blank when analyzing multiple Phylip files (default)
  -a   assignmentFile (def: $MY_ASSIGNMENT_FILE) Name of assignment file containing four-letter
       population or taxon assignment codes, one per line

 OVERVIEW
 Takes as input the name of the current working directory (workingDir), where there exists
 a single sequential Phylip file (must use -i <filename.phy>) or multiple sequential Phylip 
 files that the user wishes to subsample, keeping one random (first) sequence per population 
 or species. This is very useful when you want to subsample one or more datasets in order
 to conduct single-tip phylogenetic analyses, for example when (1) estimating 1-tip-per-
 species gene trees for species tree reconstruction, or (2) when you will use the Phylip 
 files to directly estimate the species tree.
 
 The populations or species are contained in an assignment file, the filename of which is 
 assed to the program. Sequence names may not include space or underline characters, or 
 there will be issues. _Interleaved Phylip format is not supported._

 The -i flag supplies the name of a single input Phylip file in the current workingDir for
 analysis. If this flag is not used, then the program will assume that multiple Phylip files
 are present in workingDir and will attempt to subsample all of them. This is useful when
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
		./phylipSubsampler.sh -a species.txt .	## With user-specified assignment
							## file named 'species.txt'.

 CITATION
 Bagley, J.C. 2017. PIrANHA. GitHub package, Available at: 
	<http://github.com/justincbagley/PIrANHA>.
 or
 Bagley, J.C. 2017. PIrANHA. [Data set] Zenodo, Available at: 
	<http://doi.org/10.5281/zenodo.596766>.
 or
 Bagley, J.C. 2017. justincbagley/PIrANHA. GitHub package, Available at: 
	<http://doi.org/10.5281/zenodo.596766>.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
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
USER_SPEC_PATH="$1"

######################################## START ###########################################
echo "INFO      | $(date) | Starting phylipSubsampler analysis... "
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set new path/dir environmental variable to user specified path, then create useful
##--shell functions and variables:
if [ "$USER_SPEC_PATH" = "$(echo $(pwd))" ]; then
	MY_PATH=`pwd -P`
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "
elif [ "$USER_SPEC_PATH" != "$(echo $(pwd))" ]; then
	MY_PATH=$USER_SPEC_PATH
	echo "INFO      | $(date) |          Setting working directory to: $MY_PATH "	
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
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
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
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
			sed -i '' 's/\('$j'\)-[0-9\ ]*/\1\ \ \ \ \ \ /g' "$LOCUS_NAME".phy;
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
