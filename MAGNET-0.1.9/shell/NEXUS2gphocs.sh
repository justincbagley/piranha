#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                            NEXUS2gphocs v1.3, November 2018                            #
#  SHELL SCRIPT FOR CONVERTING PARTITIONED NEXUS FILE INTO G-PhoCS FORMAT FOR MAGNET     #
#  PIPELINE                                                                              #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: November 20, 2018. For questions, please email bagleyj@umsl.edu.              #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_GAP_THRESHOLD=0.001
MY_INDIV_MISSING_DATA=1

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -g m] inputNexus 
 ## Help:
  -h   help text (also: -help -H -Help)

 ## Options:
  -g   gapThreshold (def: $MY_GAP_THRESHOLD=essentially zero gaps allowed unless >1000 
       individuals; takes float proportion value)
  -m   indivMissingData (def: $MY_INDIV_MISSING_DATA=allowed; 0=removed)

 OVERVIEW
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
 'selectSites.pl' in working directory or available from command line (in your path).

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub package, Available at: 
	<http://github.com/justincbagley/PIrANHA>.
 or
 Bagley, J.C. 2019. MAGNET v0.1.5. GitHub package, Available at: 
	<http://github.com/justincbagley/MAGNET>.
 or
 Bagley, J.C. 2019. MAGNET v0.1.5. GitHub package, Available at: 
	<https://doi.org/10.5281/zenodo.596774>.
"

############ PARSE THE OPTIONS
while getopts 'h:H:g:m:' opt ; do
  case $opt in
## Help texts:
	h) echo "$Usage"
       exit ;;
	H) echo "$Usage"
       exit ;;

## Datafile options:
    g) MY_GAP_THRESHOLD=$OPTARG ;;
    m) MY_INDIV_MISSING_DATA=$OPTARG ;;

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
MY_NEXUS="$1"


echo "
##########################################################################################
#                            NEXUS2gphocs v1.3, November 2018                            #
##########################################################################################
"

######################################## START ###########################################

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

##--This is the base name of the original nexus file, so you have it. This WILL work regardless of whether the NEXUS filename extension is written in lowercase or in all caps, ".NEX".
	MY_NEXUS_BASENAME="$(echo $MY_NEXUS | sed 's/\.\///g; s/\.[A-Za-z]\{3\}$//g')"

##--Convert data file from NEXUS to fasta format using bioscripts.convert v0.4 Python package:
##--However, if alignment is too long (>100,000 bp), then need to convert to fasta using my 
##--script and then wrap to 60 characters with fold function (as suggested at stackexchange
##--post URL: https://unix.stackexchange.com/questions/25173/how-can-i-wrap-text-at-a-certain-column-size).
##--If this conversion failes because the alignment is too long, then the code to follow 
##--will have nothing to work with. So, I am here adding a conditional quit if the fasta
##--file is not generated.

#---------ADD IF/THEN CONDITIONAL AND MY OWN NEXUS2fasta SCRIPT HERE!!!!----------#
	convbioseq fasta $MY_NEXUS > "$MY_NEXUS_BASENAME".fasta
	MY_FASTA="$(echo "$MY_NEXUS_BASENAME".fasta | sed 's/\.\///g; s/\.nex//g')"
	
	##--The line above creates a file with the name basename.fasta, where basename is the base name of the original .nex file. For example, "hypostomus_str.nex" would be converted to "hypostomus_str.fasta".
	##--Check to make sure the fasta was created; if so, echo info, if not, echo warning and quit:
	if [[ -s "$MY_NEXUS_BASENAME".fasta ]]; then
		echo "INFO      | $(date) |          Input NEXUS was successfully converted to fasta format. Moving forward... "
	else
		echo "WARNING!  | $(date) |          NEXUS to fasta file conversion FAILED! Quitting... "
		exit 1
	fi


############ STEP #3: PUT COMPONENTS OF ORIGINAL NEXUS FILE AND THE FASTA FILE TOGETHER TO
############ MAKE A G-PhoCS-FORMATTED DATA FILE
##--Make top (first line) of the G-Phocs format file, which should have the number of loci on the first line:
echo "$MY_NLOCI" | sed 's/[\ ]*//g' > gphocs_top.txt

echo "$MY_GAP_THRESHOLD" > ./gap_threshold.txt
	count=0
	(
		for j in ${MY_NEXUS_CHARSETS}; do
			echo "$j"
			charRange="$(echo ${j} | sed 's/\,//g')"
			echo "$charRange"
			setLower="$(echo ${j} | sed 's/\-.*$//g')"
			setUpper="$(echo ${j} | sed 's/[0-9]*\-//g' | sed 's/\,//g; s/\ //g')"

			**/selectSites.pl -s $charRange $MY_FASTA > ./sites.fasta
			
			**/fasta2phylip.pl ./sites.fasta > ./sites.phy

			##--Need to make sure there is a space between the tip taxon name (10 characters as output
			##--by the fasta2phylip.pl Perl script) and the corresponding sequence, for all tips. Use
			##--a perl search and replace for this:

			perl -p -i -e 's/^([A-Za-z0-9\-\_\ ]{10})/$1\ /g' ./sites.phy

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
