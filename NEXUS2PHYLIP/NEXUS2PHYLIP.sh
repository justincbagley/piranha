#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                            NEXUS2PHYLIP v1.0, November 2018                            #
#   SHELL SCRIPT FOR CONVERTING SEQUENTIAL NEXUS FILE INTO PHYLIP FORMAT                 #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: November 14, 2018. For questions, please email bagleyj@umsl.edu.              #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_NAME_NCHARS_SWITCH=0
MY_VERBOSE_OUT_SWITCH=0

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -c v] inputNexus 
 ## Help:
  -h   help text (also: -help -H -Help)

 ## Options:
  -c   nameChars (def: turned off)
  -v   verbose (def: turned off)

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
 Bagley, J.C. 2017. MAGNET. GitHub package, Available at: 
	<http://github.com/justincbagley/MAGNET>.
 or
 Bagley, J.C. 2017. MAGNET. GitHub package, Available at: 
	<http://doi.org/10.5281/zenodo.166024>.
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
#                            NEXUS2PHYLIP v1.0, November 2018                            #
##########################################################################################
"

######################################## START ###########################################

############ STEP #1: SETUP VARIABLES
###### Set filetypes as different variables:
#echo "INFO      | $(date) | Examining current directory, setting variables... "
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

##--This is the base name of the original nexus file, so you have it. This WILL work regardless 
##--of whether the NEXUS filename extension is written in lowercase or in all caps, ".NEX".
	MY_NEXUS_BASENAME="$(echo $MY_NEXUS | sed 's/\.\///g; s/\.[A-Za-z]\{3\}$//g')"

##--Convert data file from NEXUS to fasta format using bioscripts.convert v0.4 Python package:
	convbioseq fasta $MY_NEXUS > "$MY_NEXUS_BASENAME".fasta
	MY_FASTA="$(echo "$MY_NEXUS_BASENAME".fasta | sed 's/\.\///g; s/\.nex//g')"

##--Convert data file from fasta to PHYLIP format using Nayoki Takebayashi fasta2phylip.pl 
##--Perl script (must be available from CLI):
	fasta2phylip.pl "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy
	

############ STEP #3: CHECK PHYLIP ALIGNMENT CHARACTERISTICS.
# [IN PREP.]

############ STEP #4: CLEANUP.
	rm ./"$MY_NEXUS_BASENAME".fasta

#echo "INFO      | $(date) | Successfully created a '.gphocs' input file from the existing NEXUS file... "
#echo "INFO      | $(date) | Bye.
#"
#
#
#
######################################### END ############################################


exit 0