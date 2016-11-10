#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                            NEXUS2gphocs v1.1, August 2016                              #
#   SHELL SCRIPT FOR CONVERTING PARTITIONED NEXUS FILE INTO G-PhoCS FORMAT FOR MAGNET    #
#   PIPELINE                                                                             #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: August 28, 2016. For questions, please email       #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_GAP_THRESHOLD=0.001
MY_INDIV_MISSING_DATA=1

## PARSE THE OPTIONS ##
while getopts 'g:m:' opt ; do
  case $opt in
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
  echo "Options: -g gapThreshold (def: $MY_GAP_THRESHOLD=essentially zero gaps allowed \
unless >1000 individuals; takes float proportion value) | -m indivMissingData (def: \
$MY_INDIV_MISSING_DATA=allowed; 0=removed)

Reads in a single NEXUS datafile and converts it to '.gphocs' format for G-PhoCS software
(Gronau et al. 2011). Sequence names may not include hyphen characters, or there will be 
issues. For best results, update to R v3.3.1 or higher.

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

Dependencies: Perl; R; and Naoki Takebayashi Perl scripts 'fasta2phylip.pl' and 
'selectSites.pl' in working directory or available from command line (in your path)."

  exit 1
fi
MY_NEXUS="$1"


echo "
##########################################################################################
#                           NEXUS2gphocs v1.1, August 2016                               #
##########################################################################################
"

############ STEP #1: SETUP VARIABLES
###### Set filetypes as different variables:
echo "INFO      | $(date) | Examining current directory, setting variables... "
MY_WORKING_DIR="$(pwd)"
CR=$(printf '\r')			## Best way to facilitate adding carriage returns using sed...
calc () {
   	bc -l <<< "$@"
}


############ STEP #2: GET NEXUS FILE & DATA CHARACTERISTICS, CONVERT NEXUS TO FASTA FORMAT
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


############ STEP #3: PUT COMPONENTS OF ORIGINAL NEXUS FILE AND THE FASTA FILE TOGETHER TO
############ MAKE A G-PhoCS-FORMATTED DATA FILE
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
			
			
        			 if [ $MY_INDIV_MISSING_DATA == 0 ]; then
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

cat ./gphocs_top.txt ./gphocs_body_fix.txt > $MY_NEXUS_BASENAME.gphocs


############ STEP #4: CLEANUP: REMOVE UNNECESSARY FILES
rm ./gphocs_top.txt
rm ./gap_threshold.txt
rm ./gphocs_body.txt

echo "INFO      | $(date) | Successfully created a '.gphocs' input file from the existing NEXUS file... "
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
