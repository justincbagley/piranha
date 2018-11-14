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
MY_KEEP_FASTA_SWITCH=0

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -c v -k] inputNexus 
 ## Help:
  -h   help text (also: -help -H -Help)

 ## Options:
  -c   nameChars (def: turned off, full tip names kept) number of characters to shorten tip 
       taxon names to (integer value between 1-10 recommended)
  -v   verbose (def: turned off) specify verbose file name conversion output
  -k   keepFasta (def: 0, off; 1, on, keep fasta intermediate) whether or not to keep 
       intermediate fasta files generated during the run

 OVERVIEW
 Reads in a single NEXUS datafile and converts it to PHYLIP ('.phy') format (Felsenstein 
 REF). Sequence names may not include hyphen characters, or there will be 
 issues.

 The -c flag specifies an integer number of character to shorten tip taxon names to, for 
 example, such that a value of 9 will reduce all tip taxon names to 9 alphanumeric 
 characters followed by a space by taking the first 9 characters of the names (for a 10 
 character total at the start of each sequence-containing line of the alignment file. This 
 takes advantage of -c flag capabilities in a dependency Perl script.

 The -v flag allows users to choose verbose output that prints name conversions to stderr.

 The -k flag specifies whether to keep intermediate fasta files, one per <inputNexus>, 
 generated during a run of the script. Fasta files are deleted by default, but if set to 
 keep (1), fastas will be moved to a sub-folder named 'fasta' at the end of the run.

 Dependencies: Perl and Naoki Takebayashi Perl scripts 'fasta2phylip.pl' in working 
 directory or available from command line (in your path). Tested with Perl v5.

 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.
"

############ PARSE THE OPTIONS
while getopts 'h:H:c:v:k:' opt ; do
  case $opt in
## Help texts:
	h) echo "$Usage"
       exit ;;
	H) echo "$Usage"
       exit ;;

## Datafile options:
    c) MY_NAME_NCHARS_SWITCH=$OPTARG ;;
    v) MY_VERBOSE_OUT_SWITCH=$OPTARG ;;
    k) MY_KEEP_FASTA_SWITCH=$OPTARG ;;

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
	if [[ "$MY_NAME_NCHARS_SWITCH" = "0" ]] && [[ "$MY_VERBOSE_OUT_SWITCH" = "0" ]]; then

		fasta2phylip.pl "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy

	elif [[ "$MY_NAME_NCHARS_SWITCH" ! = "0" ]] && [[ "$MY_VERBOSE_OUT_SWITCH" = "0" ]]; then

		fasta2phylip.pl -c "$MY_NAME_NCHARS_SWITCH" "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy

	elif [[ "$MY_NAME_NCHARS_SWITCH" ! = "0" ]] && [[ "$MY_VERBOSE_OUT_SWITCH" ! = "0" ]]; then

		fasta2phylip.pl -c "$" -v "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy		

	fi

############ STEP #3: CHECK PHYLIP ALIGNMENT CHARACTERISTICS.
##--CODE IN PREP.

############ STEP #4: CLEANUP.
	if [[ "$MY_KEEP_FASTA_SWITCH" = "0" ]]; then
		rm ./"$MY_NEXUS_BASENAME".fasta
	else
	    mkdir fasta/;
		mv ./*.fasta ./fasta/;
	fi


#echo "INFO      | $(date) | Successfully created PHYLIP ('.phy') input file from the existing NEXUS file... "
#echo "INFO      | $(date) | Bye.
#"
#
#
#
######################################### END ############################################


exit 0