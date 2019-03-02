#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: PFSubsetSum.sh                                                                   #
  version="v1.3"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley in September 2017                                       #
# Last update: September 8, 2017                                                         #
# Copyright (c) 2017-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>                                               #
#                                                                                        #
# Description:                                                                           #
# SHELL SCRIPT FOR CALCULATING SUMMARY STATISTICS FOR DNA SUBSETS WITHIN THE OPTIMUM     #
# PARTITIONING SCHEME IDENTIFIED FOR THE DATA BY PartitionFinder v1 or v2                #
#                                                                                        #
##########################################################################################

if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) ${version}";
	exit
fi

echo "
##########################################################################################
#                            PFSubsetSum v1.3, September 2017                            #
##########################################################################################
"

######################################## START ###########################################
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set paths and filetypes as different variables:
	MY_WORKING_DIR="$(pwd)"
	echo "INFO      | $(date) |          Setting working directory to: $MY_WORKING_DIR "


###### Detect and read in PartitionFinder best scheme file from current working directory:
echo "INFO      | $(date) | STEP #2: DETECT AND READ PartitionFinder INPUT FILE. "
shopt -s nullglob
if [[ -n $(echo ./best_scheme.txt) ]]; then
	echo "INFO      | $(date) |          Found PartitionFinder 'best_scheme.txt' input file... "
    MY_BEST_SCHEME_FILE=./best_scheme.txt
else
    echo "WARNING!  | $(date) | No PartitionFinder 'best_scheme.txt' input file in current working directory. Quitting... "
	exit
fi


###### Extract charsets and calculate summary statistics for each PF subset in the best
###### scheme:
echo "INFO      | $(date) | STEP #3: COMPUTE SUMMARY STATISTICS FOR EACH SUBSET. "
echo "INFO      | $(date) |          Extracting and organizing subsets...  "

	##--Extract subsets from PartitionFinder output file:
	MY_NUM_SUBSETS=$(grep -n "^DNA," $MY_BEST_SCHEME_FILE | wc -l)
	MY_START_LINE_NUM="$(cat $MY_BEST_SCHEME_FILE | grep -n '^DNA,' | head -n1 | sed 's/\:.*//')"
	MY_END_LINE_NUM="$(cat $MY_BEST_SCHEME_FILE | grep -n '^DNA,' | tail -n1 | sed 's/\:.*//')"
	sed -n "$MY_START_LINE_NUM","$MY_END_LINE_NUM"p $MY_BEST_SCHEME_FILE > ./subsets.txt
	MY_SUBSETS_FILE=./subsets.txt

echo "INFO      | $(date) |          The best scheme from PartitionFinder contains "$MY_NUM_SUBSETS" subsets.  "

	##--Move each subset to its own file, with the same subset's name... The subsets
	##--(a.k.a. "partitions", though this is not technically correct) are always named
	##--"px" where x is a number from 1 to the total number of subsets in the best
	##--scheme identified by PartitionFinder. So, we can do this with a simple for loop
	##--across different p's:
(
	for (( i=1; i<=$MY_NUM_SUBSETS; i++ )); do
		subsetname="$(echo p$i)"
		sed -n "$i"p $MY_SUBSETS_FILE | sed 's/DNA\,//g; s/p[0-9]*//g; s/^[\ =]*//g' > $subsetname.txt		##--This cleans up the subset data by removing everything except the charsets (e.g. deleting "DNA, "...

		echo "$subsetname" >> ./subset_names.txt

	done			
)	


echo "INFO      | $(date) |          1. Calculating numCharsets (number of character sets) within each subset in the scheme...  "
	##--Prep work: make output directory...
	mkdir "$MY_WORKING_DIR"/numCharsets/

(
    for (( i=1; i<=$MY_NUM_SUBSETS; i++ )); do
        subsetname="$(echo p$i)"
        subsetfile="$(echo ./$subsetname.txt)"
        number_of_occurrences=$(grep -o "\-" <<< cat $subsetfile | wc -l)
        echo "$number_of_occurrences" > "$subsetname"_numCharsets.out
		
		cat ./"$subsetname"_numCharsets.out >> ./numCharsets/ALL_numCharsets.txt

    done
)
mv ./*_numCharsets.out ./numCharsets/


echo "INFO      | $(date) |          2. Calculating subsetLengths (alignment lengths in bp) for each subset in the scheme...  "
	##--Now, we need a loop that will go into each subset file output from the preceding
	##--loops ("p1.txt", "p2.txt", etc.), split the charsets in each subset (file)
	##--onto separate lines, calculate the length of each charset (=locus), then sum
	##--all the charset lengths (locus bp) to get the total length in bp for the whole
	##--subset.

	##--One solution is to do the above easily by making and calling on an R script:
	
	##--Prep work: make output directory...
	mkdir "$MY_WORKING_DIR"/subsetLengths/

(
    for (( i=1; i<=$MY_NUM_SUBSETS; i++ )); do
        subsetname="$(echo p$i)"
        subsetfile="$(echo ./$subsetname.txt)"
		cat "$subsetfile" > ./Rinput.txt
		CHARSET_DUMP="$(cat ./Rinput.txt)"

		##--Make R script and give it data from each subset file within the loop...
echo "#!/usr/bin/env Rscript

charsets_as_numbers <- c("$CHARSET_DUMP")
out <- sum(abs(charsets_as_numbers)) + length(charsets_as_numbers)

write.table(out, '"$MY_WORKING_DIR"/subsetLengths/"$subsetname"_subsetLength.out', sep='\t', quote=F, row.names=F, col.names=F)

" > ./GetSubsetLength.r

		##--Call the 'GetSubsetLength.r' R script to run just on the subset at the current
		##--point in the loop:
		chmod u+x ./GetSubsetLength.r
		R CMD BATCH GetSubsetLength.R

        rm ./Rinput.txt ./GetSubsetLength.r

		cat ./subsetLengths/"$subsetname"_subsetLength.out >> ./subsetLengths/ALL_subsetLengths.txt

	done
)

rm subsets.txt ./p*.txt   ##--Remove subset lists and individual subset files
mv ./*.Rout ./subsetLengths/


echo "INFO      | $(date) |          3. Extracting subsetModels (selected models of DNA sequence evolution) for each subset in the scheme...  "
	grep -n "^[0-9]" ./best_scheme.txt > ./subset_mods_prep.txt
	MY_SUBSET_MODELS_PREPPER=./subset_mods_prep.txt
	sed 's/^[0-9:\ |]*//g; s/\ \ \ \ |\ p.*$//g' $MY_SUBSET_MODELS_PREPPER > ./subsetModels.txt
	rm ./subset_mods_prep.txt


echo "INFO      | $(date) |          4. Making file 'sumstats.txt' with subset summary statistics table...  "
echo "###################### PartitionFinder Subsets Summary Statistics ########################
Subset	numCharsets	subsetLength	subsetModel" > table_header.txt
paste ./subset_names.txt **/ALL_numCharsets.txt **/ALL_subsetLengths.txt ./subsetModels.txt | column -s $'\t' -t > ./table.txt
cat ./table_header.txt ./table.txt > ./sumstats.txt
rm ./table_header.txt ./table.txt ./subset_names.txt ./subsetModels.txt


echo "INFO      | $(date) | Done calculating summary statistics for subsets in your best PartitionFinder scheme using PFSubsetSum. "
echo "INFO      | $(date) | Bye. 
"
#
#
#
######################################### END ############################################

exit 0
