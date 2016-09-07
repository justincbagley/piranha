#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                           PFSubsetSum v1.0, September 2016                             #
#   SHELL SCRIPT FOR EXTRACTING SUMMARY STATISTICS FROM BEST PartitionFinder SCHEME      #
#   SUBSETS                                                                              #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: September 6, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                           PFSubsetSum v1.0, September 2016                             #
##########################################################################################
"

echo "######################################## START ###########################################"
echo "STEP #1: SETUP. "
###### Set paths and filetypes as different variables:
	MY_WORKING_DIR="$(pwd)"
	echo "         Setting working directory to: $MY_WORKING_DIR "
	CR=$(printf '\r')
	calc () {
	   	bc -l <<< "$@"
	}


###### Detect and read in PartitionFinder best scheme file from current working directory:
echo "STEP #2: DETECT AND READ PartitionFinder INPUT FILE. "
shopt -s nullglob
if [[ -n $(echo ./best_scheme.txt) ]]; then
	echo "         Found PartitionFinder 'best_scheme.txt' input file... "
    MY_BEST_SCHEME_FILE=./best_scheme.txt
else
    echo "         WARNING: No PartitionFinder 'best_scheme.txt' input file in current working directory. Quitting... "
	exit
fi


###### Extract charsets and calculate summary statistics for each PF subset in the best
###### scheme:
echo "STEP #3: COMPUTE SUMMARY STATISTICS FOR EACH SUBSET. "
	
	##--Extract subsets from PartitionFinder output file:
	MY_NUM_SUBSETS=$(grep -n "DNA," $MY_BEST_SCHEME_FILE | wc -l)
	tail -n $MY_NUM_SUBSETS $MY_BEST_SCHEME_FILE > ./subsets.txt
	MY_SUBSETS_FILE=./subsets.txt

	##--Move each subset to its own file, with the same subset's name... The subsets
	##--(a.k.a. "partitions", though this is not technically correct) are always named
	##--px where x is a number from 1 to the total number of subsets in the best
	##--scheme identified by PartitionFinder. So, we an do this with a simple for loop
	##--across different p's:
(
	for (( i=1; i<=$MY_NUM_SUBSETS; i++ )); do
		subsetname=$(echo p$i)
		sed -n "$i"p $MY_SUBSETS_FILE | sed 's/DNA\,//g; s/p[0-9]*//g; s/^[\ =]*//g' > $subsetname.txt		##--This cleans up the subset data by removing everything except the charsets (e.g. deleting "DNA, "...
	done			
)	
	
	##--Now, we need a loop that will go into each subset file output from the preceding
	##--loops ("p1.txt", "p2.txt", etc.) and split the charsets in each subset (file)
	##--onto separate lines, and calculate the length of each charset (=locus), then
	##--sum all the charset lengths (locus bp) to get the total length in bp for the
	##--whole subset.

	##--One solution is to do the above easily by making and calling on an R script:
	
	##--Prep work: make file list, make output directory...
	MY_SUBSET_FILE_LIST=$(echo ./p*.txt)
	echo $MY_SUBSET_FILE_LIST | sed 's/\ /'$CR'/g'> ./subset_list.txt
	mkdir "$MY_WORKING_DIR"/Routput/

(
	for i in $MY_SUBSET_FILE_LIST; do
		cat $i > ./Rinput.txt
		CHARSET_DUMP=$(cat ./Rinput.txt)
		subsetname=$(echo $i | sed 's/\.\///g; s/\.txt//g')

		##--Make R script and give it data from each subset file within the loop...
echo "#!/usr/bin/env Rscript

charsets_as_numbers <- c("$CHARSET_DUMP")
out <- sum(abs(charsets_as_numbers)) + length(charsets_as_numbers)

write.table(out, '"$MY_WORKING_DIR"/Routput/"$subsetname"_subsetLength.out', sep='\t', quote=F, row.names=F, col.names=F)

" > ./GetSubsetLength.r

		##--Call the 'GetSubsetLength.r' R script to run just on the subset at the current
		##--point in the loop:
		chmod u+x ./GetSubsetLength.r
		R CMD BATCH GetSubsetLength.R

	rm ./Rinput.txt ./GetSubsetLength.r

	done
)

echo "Done calculating bp lengths of all subsets in your best PartitionFinder scheme. "
echo "Bye."
#
#
#
echo "######################################### END ############################################"

exit 0
