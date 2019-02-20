#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                            NEXUS2PHYLIP v1.1, November 2018                            #
#  SHELL SCRIPT CONVERTING SEQUENTIAL NEXUS FILE INTO PHYLIP (AND OPTIONALLY ALSO FASTA) #
#  DNA SEQUENCE ALIGNMENT FORMAT                                                         #
#  Copyright ©2018 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: November 14, 2018. For questions, please email bagleyj@umsl.edu.              #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_NAME_NCHARS_SWITCH=0
MY_VERBOSE_OUT_SWITCH=0
MY_KEEP_FASTA_SWITCH=0
MY_OVERWRITE_SWITCH=1

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -c v k o] inputNexus 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -c   nameChars (def: 10-character names) number of characters to which tip taxon names
       should be shortened, allowing integer values ranging 1-9
  -v   verbose (def: 0, off; 1, on) specify verbose filename conversion and step output to
       screen (stdout)
  -k   keepFasta (def: 0, off; 1, on, keep fasta intermediate) whether or not to keep 
       intermediate fasta files generated during the run
  -o   fastaOverwrite (def: 1, on; 0, off) whether or not to force overwrite of fasta 
       files in current working directory (e.g. from previous steps of pipeline)

 OVERVIEW
 Reads in a single NEXUS datafile and converts it to PHYLIP ('.phy') format (Felsenstein 
 2002). Sequence names may include alphanumeric, hyphen, and underscore characters but no
 spaces (or else there will be issues). By default, program runs quietly with no ouput to
 screen or stderr or stdout files; however, -v option causes verbose run information to be
 output to screen (stdout).
	Dependencies: Perl and Naoki Takebayashi 'fasta2phylip.pl' Perl script in working 
 directory or available from command line (in your path). Tested with Perl v5.1+ on macOS
 High Sierra (v10.13+).

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Felsenstein, J. 2002. PHYLIP (Phylogeny Inference Package) Version 3.6 a3. 
	Available at: <http://evolution.genetics.washington.edu/phylip.html>.
"

verboseHelp="Usage: $(basename "$0") [Help: -h help H Help] [Options: -c v k o] inputNexus 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -c   nameChars (def: 10-character names) number of characters to which tip taxon names
       should be shortened, allowing integer values ranging 1-9
  -v   verbose (def: 0, off; 1, on) specify verbose filename conversion and step output to
       screen (stdout)
  -k   keepFasta (def: 0, off; 1, on, keep fasta intermediate) whether or not to keep 
       intermediate fasta files generated during the run
  -o   fastaOverwrite (def: 1, on; 0, off) whether or not to force overwrite of fasta 
       files in current working directory (e.g. from previous steps of pipeline)

 OVERVIEW
 Reads in a single NEXUS datafile and converts it to PHYLIP ('.phy') format (Felsenstein 
 2002). Sequence names may include alphanumeric, hyphen, and underscore characters but no
 spaces (or else there will be issues). By default, program runs quietly with no ouput to
 screen or stderr or stdout files; however, -v option causes verbose run information to be
 output to screen (stdout).

 DETAILS
 The -c flag specifies an integer number of character to shorten tip taxon names to, for 
 example, such that a value of 9 will reduce all tip taxon names to 9 alphanumeric 
 characters followed by a space by taking the first 9 characters of the names (for a 10-
 character total at the start of each sequence-containing line of the alignment file. This 
 takes advantage of -c flag capabilities in a dependency Perl script. By default, 10-character
 names will be kept, and single spaces will be placed between tip taxon names and corresponding
 sequences.

 The -v flag allows users to choose verbose output that prints name conversions, as well as
 step information (what the program is doing), to stdout. Off by default.

 The -k flag specifies whether to keep intermediate fasta files, one per <inputNexus>, 
 generated during a run of the script. Fasta files are deleted by default, but if set to 
 keep (1), fastas will be moved to a sub-folder named 'fasta' at the end of the run.

 The -o flag allows the user to specify whether or not to force output file overwrite of
 fasta files in current working directory and is set to on as the default; set to 0 to skip 
 overwrite and always preserve existing fasta files, if present (not recommended).

 Dependencies: Perl and Naoki Takebayashi 'fasta2phylip.pl' Perl script in working 
 directory or available from command line (in your path). Tested with Perl v5.1+ on macOS
 High Sierra (v10.13+).

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Felsenstein, J. 2002. PHYLIP (Phylogeny Inference Package) Version 3.6 a3. 
	Available at: <http://evolution.genetics.washington.edu/phylip.html>.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

if [[ "$1" == "-H" ]] || [[ "$1" == "-Help" ]]; then
	echo "$verboseHelp"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'c:v:k:o:' opt ; do
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
    o) MY_OVERWRITE_SWITCH=$OPTARG ;;

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


if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then

echo "
##########################################################################################
#                            NEXUS2PHYLIP v1.0, November 2018                            #
##########################################################################################
"
fi

######################################## START ###########################################

if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) |          STEP #1: SETUP ENVIRONMENT. "
fi
############ STEP #1: SETUP FUNCTIONS AND ENVIRONMENTAL VARIABLES
###### Set filetypes as different variables:
#echo "INFO      | $(date) | Examining current directory, setting variables... "
	MY_WORKING_DIR="$(pwd)"
	CR=$(printf '\r')			## Best way to facilitate adding carriage returns using sed...
	calc () {
	   	bc -l <<< "$@"
	}


if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) |          STEP #2: GET NEXUS FILE & DATA CHARACTERISTICS, CONVERT NEXUS TO FASTA FORMAT. "
fi
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
	if [[ -s "$MY_NEXUS_BASENAME".fasta ]]; then
		rm ./"$MY_NEXUS_BASENAME".fasta
	fi
	convbioseq fasta $MY_NEXUS > "$MY_NEXUS_BASENAME".fasta
	MY_FASTA="$(echo "$MY_NEXUS_BASENAME".fasta | sed 's/\.\///g; s/\.nex//g')"

##--Convert data file from fasta to PHYLIP format using Nayoki Takebayashi fasta2phylip.pl 
##--Perl script (must be available from CLI):
	if [[ "$MY_NAME_NCHARS_SWITCH" = "0" ]] && [[ "$MY_VERBOSE_OUT_SWITCH" = "0" ]]; then

		if [[ -s "$MY_NEXUS_BASENAME".phy ]]; then
			rm ./"$MY_NEXUS_BASENAME".phy
		fi
		fasta2phylip.pl "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy

	elif [[ "$MY_NAME_NCHARS_SWITCH" != "0" ]] && [[ "$MY_VERBOSE_OUT_SWITCH" = "0" ]]; then

		if [[ -s "$MY_NEXUS_BASENAME".phy ]]; then
			rm ./"$MY_NEXUS_BASENAME".phy
		fi
		fasta2phylip.pl -c "$MY_NAME_NCHARS_SWITCH" "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy

	elif [[ "$MY_NAME_NCHARS_SWITCH" != "0" ]] && [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then

		if [[ -s "$MY_NEXUS_BASENAME".phy ]]; then
			rm ./"$MY_NEXUS_BASENAME".phy
		fi
		fasta2phylip.pl -c "$MY_NAME_NCHARS_SWITCH" -v "$MY_FASTA" > "$MY_NEXUS_BASENAME".phy		

	fi


if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) |          STEP #3: FIX PHYLIP TIP TAXON NAMES. "
fi
############ STEP #3: FIX SPACE BETWEEN TIP TAXON NAME AND SEQUENCE, AND CHECK OUTPUT PHYLIP ALIGNMENT CHARACTERISTICS AGAINST NEXUS INFO.
##--Tip taxon name fixes are implemented, but code for checking PHYLIP file against NEXUS 
##--characteristics is _in prep_.

	if [[ "$MY_NAME_NCHARS_SWITCH" = "0" ]]; then

		perl -p -i -e 's/^([A-Za-z0-9\-\_\ ]{10})(.*)/$1\ $2/g' "$MY_NEXUS_BASENAME".phy

	elif [[ "$MY_NAME_NCHARS_SWITCH" != "0" ]] && [[ "$MY_NAME_NCHARS_SWITCH" -le "9" ]]; then

		if [[ "$MY_NAME_NCHARS_SWITCH" = "9" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{9})[A-Za-z\_0-9\-\ ]{1}(.*)/$1\ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "8" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{8})[A-Za-z\_0-9\-\ ]{2}(.*)/$1\ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "7" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{7})[A-Za-z\_0-9\-\ ]{3}(.*)/$1\ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "6" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{6})[A-Za-z\_0-9\-\ ]{4}(.*)/$1\ \ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "5" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{5})[A-Za-z\_0-9\-\ ]{5}(.*)/$1\ \ \ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "4" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{4})[A-Za-z\_0-9\-\ ]{6}(.*)/$1\ \ \ \ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "3" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{3})[A-Za-z\_0-9\-\ ]{7}(.*)/$1\ \ \ \ \ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "2" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{2})[A-Za-z\_0-9\-\ ]{8}(.*)/$1\ \ \ \ \ \ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		if [[ "$MY_NAME_NCHARS_SWITCH" = "1" ]]; then
			perl -p -i -e 's/^([A-Za-z\_0-9\-\ ]{1})[A-Za-z\_0-9\-\ ]{9}(.*)/$1\ \ \ \ \ \ \ \ \ $2/g' "$MY_NEXUS_BASENAME".phy
		fi
		
	elif [[ "$MY_NAME_NCHARS_SWITCH" != "0" ]] && [[ "$MY_NAME_NCHARS_SWITCH" -gt "9" ]]; then

		echo "WARNING!  | $(date) |          ERROR: Illegal tip taxon name size (only accepts integer values from 1-9). Quitting... "
		exit 1

	fi


if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) |          STEP #3: CLEAN UP INTERMEDIATE FASTA FILES IN WORKING DIRECTORY. "
fi
############ STEP #4: CLEAN UP (REMOVE, OR KEEP & ORGANIZE) INTERMEDIATE FASTA FILES IN WORKING DIRECTORY.
##--Clean up intermediate fasta files:
	if [[ "$MY_KEEP_FASTA_SWITCH" = "0" ]]; then

		rm ./"$MY_NEXUS_BASENAME".fasta

	elif [[ "$MY_KEEP_FASTA_SWITCH" != "0" ]] && [[ "$MY_OVERWRITE_SWITCH" = "0" ]]; then

	    if [[ -s fasta/ ]]; then 
		    rm -r fasta/;
		    mkdir fasta/
	    else
		    mkdir fasta/;
		fi
		mv ./*.fasta ./fasta/;

	elif [[ "$MY_KEEP_FASTA_SWITCH" != "0" ]] && [[ "$MY_OVERWRITE_SWITCH" = "1" ]]; then

	    if [[ -s fasta/ ]]; then 
		    rm -r fasta/;
		    mkdir fasta/
	    else
		    mkdir fasta/;
		fi
		mv -f ./*.fasta ./fasta/;

	fi

	
if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) | Successfully created PHYLIP ('.phy') input file from the existing NEXUS file... "
echo "INFO      | $(date) | Bye.
"
fi

#
#
#
######################################### END ############################################

exit 0
