#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                     MAGNET ~ MAny GeNE Trees v0.1.2, September 2016                    #
#   SHELL SCRIPT RUNNING THE MAGNET PIPELINE, WHICH AUTOMATES ESTIMATING ONE MAXIMUM-    #
#   LIKELIHOOD (ML) GENE TREE IN RAxML FOR EACH OF MANY SNP LOCI (OR MULTILOCUS DATA)    #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: September 7, 2016. For questions, please email     #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_NUM_BOOTREPS=100
MY_RAXML_MODEL=GTRGAMMA
MY_GAP_THRESHOLD=0.001
MY_INDIV_MISSING_DATA=1

## PARSE THE OPTIONS ##
while getopts 'b:r:g:m:' opt ; do
  case $opt in
    b) MY_NUM_BOOTREPS=$OPTARG ;;
    r) MY_RAXML_MODEL=$OPTARG ;;
    g) MY_GAP_THRESHOLD=$OPTARG ;;
    m) MY_INDIV_MISSING_DATA=$OPTARG ;;
  esac
done

## SKIP OVER THE PROCESSED OPTIONS ##
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
  echo "
Usage: $0 [options] inputNexus
  "
  echo "Options: -b numBootstraps (def: $MY_NUM_BOOTREPS) | -r raxmlModel \
(def: $MY_RAXML_MODEL; other: GTRGAMMAI, GTRCAT, GTRCATI) | -g gapThreshold (def: \
$MY_GAP_THRESHOLD=essentially zero gaps allowed unless >1000 individuals; takes float \
proportion value) | -m indivMissingData (def: $MY_INDIV_MISSING_DATA=allowed; 0=removed)

Reads in a single G-PhoCS ('*.gphocs') or NEXUS ('*.nex') datafile, splits each locus into 
a separate phylip-formatted alignment file, and sets up and runs RAxML to infer gene trees 
for each locus. If a NEXUS datafile is supplied, it is converted into G-PhoCS format (Gronau 
et al. 2011). Sequence names may not include hyphen characters, or there will be issues. 
For info on various dependencies, see 'README.md' file in the distribution folder; however,
it is key that the dependencies are available from the command line interface. 

The -b flag sets the number of boostrap pseudoreplicates for RAxML to perform while estimating 
the gene tree for each locus. The default is 100; remove bootstrapping by setting to 0.

The -r flag sets the RAxML model for each locus. This uses the full default GTRGAMMA model,
and at present it is not possible to vary the model across loci. If you want to use HKY
or K80, you will need to manually change the 'RAxMLRunner.sh' section of this script.

The following options are available ONLY if you are starting from a NEXUS input file:

	The -g flag supplies a 'gap threshold' to an R script, which deletes all column sites in 
	the DNA alignment with a proportion of gap characters '-' at or above the threshold value. 
	If no gap threshold is specified, all sites with gaps are removed by default. If end goal
	is to produce a file for G-PhoCS, you  will want to leave gapThreshold at the default. 
	However, if the next step in your pipeline involves converting from .gphocs to other data 
	formats, you will likely want to set gapThreshold=1 (e.g. before converting to phylip 
	format for RAxML). 

	The -m flag allows users to choose their level of tolerance for individuals with missing
	data. The default is indivMissingData=1, allowing individuals with runs of 10 or more 
	missing nucleotide characters ('N') to be kept in the alignment. Alternatively, setting
	indivMissingData=0 removes all such individuals from each locus; thus, while the input
	file would have had the same number of individuals across loci, the resulting file could
	have varying numbers of individuals for different loci.
"

  exit 1
fi
MY_NEXUS="$1"




echo "
##########################################################################################
#                     MAGNET ~ MAny GeNE Trees v0.1.2, September 2016                    #
##########################################################################################"

######################################## START ###########################################
echo "INFO      | $(date) | Starting MAGNET pipeline... "
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set paths and filetypes as different variables:
	MY_WORKING_DIR="$(pwd)"
	echo "INFO      | $(date) |          Setting working directory to: $MY_WORKING_DIR "
	CR=$(printf '\r')
	calc () {
	   	bc -l <<< "$@"
	}


echo "INFO      | $(date) | STEP #2: INPUT FILE. "
echo "INFO      | $(date) |          If '.gphocs' input file present, continue; else convert NEXUS file to \
G-PhoCS format using NEXUS2gphocs code... "
shopt -s nullglob
if [[ -n $(echo *.gphocs) ]]; then
	echo "INFO      | $(date) |          Found '.gphocs' input file... "
    MY_GPHOCS_DATA_FILE=./*.gphocs		## Assign G-PhoCS-formatted genomic/SNP data file (originally produced/output by pyRAD) in run directory to variable.
else
    echo "WARNING!  | $(date) |          No '.gphocs' input file in current working directory... "
    echo "INFO      | $(date) |          Attempting to convert NEXUS file, if present, to GPho-CS format... "
fi


#################################### NEXUS2gphocs.sh #####################################

NEXUS2gphocs_function () {

	############ GET NEXUS FILE & DATA CHARACTERISTICS, CONVERT NEXUS TO FASTA FORMAT
	##--Extract charset info from sets block at end of NEXUS file: 
	MY_NEXUS_CHARSETS="$(egrep "charset|CHARSET" $MY_NEXUS | \
	awk -F"=" '{print $NF}' | sed 's/\;/\,/g' | \
	awk '{a[NR]=$0} END {for (i=1;i<NR;i++) print a[i];sub(/.$/,"",a[NR]);print a[NR]}' | \
	sed 's/\,/\,'$CR'/g' | sed 's/^\ //g')"
	
	##--Count number of loci present in the NEXUS file, based on number of charsets defined.
	##--Also get corrected count starting from 0 for numbering loci below...
	MY_NLOCI="$(echo "$MY_NEXUS_CHARSETS" | wc -l)"
	MY_CORR_NLOCI="$(calc $MY_NLOCI - 1)"
	
	##--This is the base name of the original nexus file, so you have it. This will not work if NEXUS file name is written in all caps, ".NEX", in the file name.
	MY_NEXUS_BASENAME="$(echo $MY_NEXUS | sed 's/\.\///g; s/\.nex//g')"
	
	##--Convert data file from NEXUS to fasta format using bioscripts.convert v0.4 Python package:
	convbioseq fasta $MY_NEXUS > "$MY_NEXUS_BASENAME".fasta
	MY_FASTA="$(echo "$MY_NEXUS_BASENAME".fasta | sed 's/\.\///g; s/\.nex//g')"
	
	##--The line above creates a file with the name basename.fasta, where basename is the base name of the original .nex file. For example, "hypostomus_str.nex" would be converted to "hypostomus_str.fasta".
	
	############ PUT COMPONENTS OF ORIGINAL NEXUS FILE AND THE FASTA FILE TOGETHER TO MAKE A
	############ A G-PhoCS-FORMATTED DATA FILE
	##--Make top (first line) of the G-Phocs format file, which should have the number of loci on the first line:
	echo "$MY_NLOCI" | sed 's/[\ ]*//g' > gphocs_top.txt
	
	echo "$MY_GAP_THRESHOLD" > ./gap_threshold.txt
	count=0
	(
		for j in ${MY_NEXUS_CHARSETS}; do
			echo $j
			charRange="$(echo ${j} | sed 's/\,//g')"
	        echo $charRange
	        setLower="$(echo ${j} | sed 's/\-.*$//g')"
			setUpper="$(echo ${j} | sed 's/[0-9]*\-//g' | sed 's/\,//g; s/\ //g')"
	
			**/selectSites.pl -s $charRange $MY_FASTA > ./sites.fasta
				
			**/fasta2phylip.pl ./sites.fasta > ./sites.phy


				##--If .phy file from NEXUS charset $j has gaps in alignment, then call 
				##--rmGapSites.R R script to remove all column positions with gaps from
				##--alignment and output new, gapless phylip file named "./sites_nogaps.phy". 
				##--If charset $j does not have gaps, go to next line of loop. We do the 
				##--above by first creating a temporary file containing all lines in
				##--sites.phy with the gap character:
				grep -n "-" ./sites.phy > ./gaptest.tmp
				
				##--Next, we test for nonzero testfile, indicating presence of gaps in $j, 
				##--using UNIX test operator "-s" (returns true if file size is not zero). 
				##--If fails, cat sites.phy into file with same name as nogaps file that
				##--is output by rmGapSites.R and move forward:
				if [ -s ./gaptest.tmp ]; then
					echo "Removing column sites in locus"$count" with gaps. "
					R CMD BATCH **/rmGapSites.R
				else
			   		echo ""
			   		cat ./sites.phy > ./sites_nogaps.phy
				fi
				
				
			phylip_header="$(head -n1 ./sites_nogaps.phy)"
	        	locus_ntax="$(head -n1 ./sites_nogaps.phy | sed 's/[\ ]*[.0-9]*$//g')"
			locus_nchar="$(head -n1 ./sites_nogaps.phy | sed 's/[0-9]*\ //g')"
			
			
				if [ $MY_INDIV_MISSING_DATA = "0" ]; then	
					sed '1d' ./sites_nogaps.phy | egrep -v 'NNNNNNNNNN|nnnnnnnnnn' > ./cleanLocus.tmp
					cleanLocus_ntax="$(cat ./cleanLocus.tmp | wc -l)"
					echo locus"$((count++))" $cleanLocus_ntax $locus_nchar > ./locus_top.tmp
					cat ./locus_top.tmp ./cleanLocus.tmp >> ./gphocs_body.txt
				else
					echo locus"$((count++))" $locus_ntax $locus_nchar > ./locus_top.tmp
					cat ./locus_top.tmp ./sites_nogaps.phy >> ./gphocs_body.txt
				fi


			rm ./sites.fasta ./sites.phy ./*.tmp
			rm ./sites_nogaps.phy
	
		done
	)

grep -v "^[0-9]*\ [0-9]*.*$" ./gphocs_body.txt > ./gphocs_body_fix.txt

sed 's/locus/'$CR'locus/g' ./gphocs_body_fix.txt > ./gphocs_body_fix2.txt

cat ./gphocs_top.txt ./gphocs_body_fix2.txt > $MY_NEXUS_BASENAME.gphocs


############ CLEANUP: REMOVE UNNECESSARY FILES
rm ./gphocs_top.txt
rm ./gap_threshold.txt
rm ./gphocs_body*


}

shopt -s nullglob
if [[ -n $(echo *.nex) ]]; then

NEXUS2gphocs_function

#echo -ne '\n'

else
	echo "INFO      | $(date) |          No NEXUS files in current working directory. Continuing... "
#    echo "WARNING!  | $(date) |          Found no suitable input files in current working directory... "
#    echo "INFO      | $(date) |          Quitting."
#	exit
fi

shopt -s nullglob
if [[ -n $(echo *.gphocs) ]]; then
	echo "INFO      | $(date) |          MAGNET successfully created a '.gphocs' input file from the existing NEXUS file... "
    MY_GPHOCS_DATA_FILE=./*.gphocs		## Assign G-PhoCS-formatted genomic/SNP data file (originally produced/output by pyRAD) in run directory to variable.
else
    echo "WARNING!  | $(date) |          Failed to convert NEXUS file into G-PhoCS format... "
    echo "INFO      | $(date) |          Quitting."
    exit
fi


################################# gphocs2multiPhylip.sh ##################################

MY_NLOCI="$(head -n1 $MY_GPHOCS_DATA_FILE)"

echo "INFO      | $(date) | STEP #3: MAKE ALIGNMENTS FOR EACH LOCUS. "
echo "INFO      | $(date) |          In a single loop, using info from '.gphocs' file to split each locus block \
into a separate phylip-formatted alignment file using gphocs2multiPhylip code... "
(
	for (( i=0; i<=$(calc $MY_NLOCI-1); i++ ))
		do
		echo $i
		MY_NTAX="$(grep -n "locus$i\ " $MY_GPHOCS_DATA_FILE | \
		awk -F"locus$i " '{print $NF}' | sed 's/\ [0-9]*//g')"			

		MY_NCHAR="$(grep -n "locus$i\ " $MY_GPHOCS_DATA_FILE | \
		awk -F"locus$i [0-9]*\ " '{print $NF}')"	
		
		awk "/locus"$i"\ / {for(j=1; j<="$MY_NTAX"; j++) {getline; print}}" $MY_GPHOCS_DATA_FILE > ./locus"$i".tmp

		echo "$MY_NTAX $MY_NCHAR" > ./locus"$i"_header.tmp
				
		cat ./locus"$i"_header.tmp ./locus"$i".tmp > ./locus"$i".phy

	done
)

############ CLEANUP: REMOVE UNNECESSARY OR TEMPORARY FILES
rm ./*.tmp


if [[ -n $(echo *.phy) ]]; then
    MY_PHYLIP_ALIGNMENTS=./*.phy		## Assign Phylip-formatted genomic/SNP data files (e.g. output by gphocs2multiPhylip.sh shell script) in run directory to variable.
else
    echo "..."
fi



################################# MultiRAxMLPrepper.sh ##################################

echo "INFO      | $(date) | STEP #4: MAKE RUN FOLDERS. "
##--Loop through the input .phy files and do the following for each file: (A) generate one 
##--folder per .phy file with the same name as the file, only minus the extension, then 
##--(B) move input .phy file into corresponding folder.
(
	for i in $MY_PHYLIP_ALIGNMENTS
		do
		mkdir "$(ls ${i} | sed 's/\.phy$//g')"
	    cp $i ./"$(ls ${i} | sed 's/\.phy$//g')"
	done
)

##### Setup and run check on the number of run folders created by the program:
MY_FILECOUNT="$(find . -type f | wc -l)"

MY_DIRCOUNT="$(find . -type d | wc -l)"

MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"
echo "INFO      | $(date) |          Number of run folders created: $MY_NUM_RUN_FOLDERS "


################################### RAxMLRunner.sh #######################################

echo "INFO      | $(date) | STEP #5: ESTIMATE GENE TREES. "
echo "INFO      | $(date) |          Looping through and analyzing contents of each run folder in RAxML... "
##--Each folder is set with the locus name corresponding to the locus' position in the
##--original .gphocs alignment (which, if output by pyRAD, is simply in the order in which
##--the loci were logged to file by pyRAD, no special order). Also, each folder contains
##--one .phy file carrying the same basename as the folder name, e.g. "locus0.phy". So,
##--all we need to do here is loop through each folder and call RAxML to run using its
##--contents as the input file, as follows:
(
for i in ./*/
    do
    echo $i
    cd $i
    LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\/$//g')"
    raxmlHPC-SSE3 -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -n raxml_out
	cd ..
done
)
##--NOTE: not currently using $LOCUS_NAME here, but leave for now, bc may need to use it later...


##--Here: adding loop code to move all .phy files remaining in the current working 
##--directory, after STEP #3 of the pipeline, to a new folder called "phylip_files". This
##--is done here because if the phylip_files folder is present at the end of STEP #3,
##--then RAxML will also try to estimate a gene tree for .phy file(s) in this folder during
##--STEP #5 of the pipeline above.
mkdir ./phylip_files
(
	for i in $MY_PHYLIP_ALIGNMENTS 
		do
		echo $i
		mv $i ./phylip_files/
	done
)


################################## getGeneTrees.sh #######################################

echo "INFO      | $(date) | STEP #6: RAxML POST-PROCESSING. "
echo "INFO      | $(date) |          Organizing gene trees and making final output file containing all trees... "
############ STEP #2: MAKE LIST OF RAxML GENE TREES IN WORKING DIRECTORY
echo "INFO      | $(date) |          Making list of ML gene trees generated by RAxML... "

ls **/RAxML_bestTree.raxml_out > geneTrees.list

##--Assign gene tree list to variable
MY_GENE_TREE_LIST="$(cat ./geneTrees.list)"

##--Make list of run folders that corresponds to order in geneTrees.list file:
MY_RUN_FOLDERS="$(echo $MY_GENE_TREE_LIST | sed 's/\/[A-Za-z.\_\-]*//g')"

############ ORGANIZE GENE TREES INTO ONE LOCATION
##--Place all inferred gene trees into a single "gene_trees" folder in the current
##--working directory. However, all the gene tree files have the same name. So, in order
##--to do this, we have to give each gene tree a name that matches the corresponding run
##--folder, i.e. locus. We can rename each file right after downloading it.
mkdir ./gene_trees

echo "INFO      | $(date) |          Copying *ALL* ML gene trees to 'gene_trees' folder in current directory for post-processing..."
(
	for j in ${MY_GENE_TREE_LIST}
		do
		echo $j
		cp $j ./gene_trees/
		MY_LOCUS_NAME="$(echo $j | sed 's/\/[A-Za-z.\_\-]*//g')"
		cp ./gene_trees/RAxML_bestTree.raxml_out ./gene_trees/"$MY_LOCUS_NAME"_RAxML_best.tre
		rm ./gene_trees/RAxML_bestTree.raxml_out
	done
)

echo "INFO      | $(date) |          Making final output file containing best ML trees from all runs/loci..."
(
	for k in ./gene_trees/*
	    do
	    echo $k
	    cat $k >> ./besttrees.tre
	done
)

echo "INFO      | $(date) | Done estimating gene trees for many loci in RAxML using MAGNET."
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
