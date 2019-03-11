#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          multiFASTA2PHYLIP v1.0, January 2019                          #
#  SHELL SCRIPT AUTOMATING CONVERSION OF MULTIPLE SEQUENTIAL FASTA DNA ALIGNMENT FILES   #
#  (WITH SEQUENCES UNWRAPPED OR HARD-WRAPPED ACROSS MULTIPLE LINES) TO PHYLIP FORMAT     #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: January 3, 2019. For questions, please email bagleyj@umsl.edu.                #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_KEEP_FASTA_SWITCH=0
MY_VERBOSE_OUT_SWITCH=0
MY_OUTPUT_FILE_SWITCH=NULL

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -k o v] workingDir 
 ## Help:
  -h   help text (also: -help -H -Help)

 ## Options:
  -k   keepFasta (def: 0, off; 1, on) indicate whether or not to keep original FASTA files,
       which are modified and replaced by default
  -o   outputFile (def: NULL) send screen output to file in workingDir with user-specified 
       name, for example 'output.txt'.
  -v   verbose (def: 0, off; 1, on) specify verbose filename conversion and step output to
       screen (stdout)

 OVERVIEW
 Reads in all FASTA DNA sequence alignment files in input working directory, <workingDir>, 
 and converts them to PHYLIP ('.phy') format (Felsenstein 2002). Each FASTA file must be 
 sequential in format (i.e. with each sequence on one or multiple contiguous lines) but 
 individual sequences may be hard wrapped across multiple lines (e.g. using line breaking 
 to limit sequence text to 60-90 nucleotide characters per line), or not (e.g. with one 
 sequence per line). Tip taxon names may include alphanumeric, hyphen, and underscore 
 characters but no spaces or pound signs (#), or else there will be issues. Whereas filename 
 extensions '.fasta', '.fas', or '.fa' are preferred, the program also accommodates uppercase 
 versions of these extensions. 
	The input working dir path, <workingDir>, is a mandatory positional parameter. An option
 (-k 1) is available that allows keeping the original FASTA files. By default, program runs  
 quietly with limited stdout or stderr output to screen (only filenames); however, -v option 
 causes verbose run information to be output to screen for each FASTA file (warning: highly 
 redundant), and by setting the -o flag users can send output to file with a user-specified
 filename.
	This program runs on UNIX-like and Linux systems using commonly distributed utility 
 software, with usage as obtained by running the script with the -h flag, and has been 
 tested with Perl v5.1+ on macOS High Sierra (v10.13+) but will work on many earlier versions 
 or Linux. 

 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Felsenstein, J. 2002. PHYLIP (Phylogeny Inference Package) Version 3.6 a3. 
	Available at: <http://evolution.genetics.washington.edu/phylip.html>.
"

verboseHelp="Usage: $(basename "$0") [Help: -h help H Help] [Options: -k o v] workingDir 
 ## Help:
  -h   help text (also: -help -H -Help)

 ## Options:
  -k   keepFasta (def: 0, off; 1, on) indicate whether or not to keep original FASTA file,
       which is modified and replaced by default
  -o   outputFile (def: NULL) send screen output to file in workingDir with user-specified 
       name, for example 'output.txt'.
  -v   verbose (def: 0, off; 1, on) specify verbose filename conversion and step output to
       screen (stdout)

 OVERVIEW
 Reads in all FASTA DNA sequence alignment files in input working directory, <workingDir>, 
 and converts them to PHYLIP ('.phy') format (Felsenstein 2002). Each FASTA file must be 
 a sequential FASTA (i.e. with each sequence on one or multiple contiguous lines) but 
 individual sequences may be hard wrapped across multiple lines (e.g. using line breaking 
 to limit sequence text to 60-90 nucleotide characters per line), or not (e.g. with one 
 sequence per line). Tip taxon names may include alphanumeric, hyphen, and underscore 
 characters but no spaces or pound signs (#), or else there will be issues. Whereas filename 
 extensions '.fasta', '.fas', or '.fa' are preferred, the program also accommodates uppercase 
 versions of these extensions. 
	The input working dir path, <workingDir>, is a mandatory positional parameter. An option
 (-k 1) is available that allows keeping the original FASTA files. By default, program runs  
 quietly with limited stdout or stderr output to screen (only filenames); however, -v option 
 causes verbose run information to be output to screen for each FASTA file (warning: highly 
 redundant), and by setting the -o flag users can send output to file with a user-specified
 filename.
	This program runs on UNIX-like and Linux systems using commonly distributed utility 
 software, with usage as obtained by running the script with the -h flag, and has been 
 tested with Perl v5.1+ on macOS High Sierra (v10.13+) but will work on many earlier versions 
 or Linux. 

 DETAILS
 The -k flag allows the user to choose whether or not the original FASTA files should be 
 replaced with the newly generated PHYLIP file (0; default), or kept unmodified (1). If the 
 latter, then 'orig_fasta_files/' and 'phylip_files/' subfolders are created, and the original 
 FASTA files are placed in orig_fasta_files/ while the converted PHYLIP alignments are placed 
 in phylip_files/ subfolder.
 
 When called, the -o flag causes all output (stdout and stderr) to be redirected to a file 
 in <workignDir> with name specified by the user. <outputFile> name is NULL by default; thus,
 if not called, then output will be written to screen.

 Setting the -v flag to 1 turns on verbose mode, causing verbose run information to be 
 output to screen (no -o flag) or file (-o flag); this is turned off (0) by default. Warning: 
 the verbose output is presently highly redundant across alignments, and thus is not preferred.
 
 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
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
while getopts 'k:o:v:' opt ; do
  case $opt in
## Datafile options:
    k) MY_KEEP_FASTA_SWITCH=$OPTARG ;;
    o) MY_OUTPUT_FILE_SWITCH=$OPTARG ;;
    v) MY_VERBOSE_OUT_SWITCH=$OPTARG ;;

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

############ OPTIONAL OUTPUT TO FILE
if [[ "$MY_OUTPUT_FILE_SWITCH" != "NULL" ]]; then
	mkdir output/;
	exec >> ./output/"$MY_OUTPUT_FILE_SWITCH"
	exec 2>&1
fi

############ SET workingDir
if [[ "$USER_SPEC_PATH" = "$(printf '%q\n' "$(pwd)")" ]] || [[ "$USER_SPEC_PATH" = "." ]]; then
	#MY_CWD=`pwd -P`
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


if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "
##########################################################################################
#                            FASTA2PHYLIP v1.0, January 2019                             #
##########################################################################################
"
fi

######################################## START ###########################################

if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) |          STEP #1: STEP #1: SET UP FUNCTIONS AND ENVIRONMENTAL VARIABLES, AND CHECK MACHINE TYPE. "
fi
############ STEP #1: SET UP FUNCTIONS AND ENVIRONMENTAL VARIABLES, AND CHECK MACHINE TYPE.
###### Set filetypes as different variables:
#echo "INFO      | $(date) | Examining current directory, setting variables... "
	MY_WORKING_DIR="$(pwd)"
	CR=$(printf '\r')
	calc () {
	   	bc -l <<< "$@"
	}

	## Organize working directory structure:
	if [[ ! -s ./output/ ]]; then
		mkdir output/;
	fi
	if [[ "$MY_KEEP_FASTA_SWITCH" = "1" ]]; then
		mkdir orig_fasta_files/;
		mkdir phylip_files/;
	fi

	## Check machine type. Results are used below.
	unameOut="$(uname -s)"
	case "${unameOut}" in
	    Linux*)     machine=Linux;;
	    Darwin*)    machine=Mac;;
	    CYGWIN*)    machine=Cygwin;;
	    MINGW*)     machine=MinGw;;
	    *)          machine="UNKNOWN:${unameOut}"
	esac
	# echo "INFO      | $(date) |          System: ${machine}"



############ STEP #2: CONVERT ALL FASTA FILES IN CWD TO PHYLIP AND SAVE FASTA ORDER AND CHARACTERISTICS.
###### Loop through fastas in current working directory, allowing for multiple file extensions,
###### and perform operations. However, extension '.fasta' is preferred.
if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) |          STEP #2: CONVERT ALL FASTA FILES IN CWD TO PHYLIP FORMAT, & SAVE ORIG FASTA ORDER AND CHARACTERISTICS. "
fi

MY_FASTA_FILES="$(find . -type f \( -iname \*.fasta -o -iname \*.fas  -o -iname \*.fa -o -iname \*.FASTA -o -iname \*.FAS -o -iname \*.FA \))"
(
	for MY_FASTA in $MY_FASTA_FILES; do 

	echo "$MY_FASTA" >> ./output/fileOrder.list.txt

	echo "###------    $MY_FASTA    ------### "


	if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
	echo "INFO      | $(date) |               A. CLEAN FILE, GET FASTA FILE AND DATA CHARACTERISTICS. "
	fi
	
	if [[ "$MY_KEEP_FASTA_SWITCH" = "0" ]]; then
		############ STEP #2A: CLEAN FILE, GET FASTA FILE AND DATA CHARACTERISTICS (USED TO CHECK FOR UN-
		############ WRAPPED VERSUS HARD-WRAPPED FORMAT).
		##--If present, remove empty lines / newlines from input FASTA file, $MY_FASTA.
			if [[ "$(grep -n '^[\s]*$' $MY_FASTA | wc -l | sed 's/\ //g' | perl -pe 's/\t//g')" -gt "0" ]]; then 
				if [[ "${machine}" = "Mac" ]]; then
					sed -i '' '/^[[:space:]]*$/d' "$MY_FASTA"
				fi
				if [[ "${machine}" = "Linux" ]]; then
					sed -i '/^[[:space:]]*$/d' "$MY_FASTA"
				fi
			fi
		
		##--If present, remove lines that have been commented out from input FASTA file, $MY_FASTA. 
		##--Unlike sequence lines, these lines will all contain '#' characters.
			if [[ "$(grep -n '\#' $MY_FASTA | wc -l | sed 's/\ //g' | perl -pe 's/\t//g')" -gt "0" ]]; then 
				if [[ "${machine}" = "Mac" ]]; then
					sed -i '' '/\#/d' "$MY_FASTA"
				fi
				if [[ "${machine}" = "Linux" ]]; then
					sed -i '/\#/d' "$MY_FASTA"
				fi
			fi
		
		##--Generate metric used below to test FASTA file format and identify whether file contains 
		##--unwrapped (single line) or hard-wrapped (multiple line) DNA sequences.
		
			## Get first ID delimiter line number:
			MY_FIRST_ID_LINE="$(grep -n '>' $MY_FASTA | head -n2 | sed 's/\:.*//g' | head -n1)"
			
			## Get second ID delimiter line number:
			MY_SECOND_ID_LINE="$(grep -n '>' $MY_FASTA | head -n2 | sed 's/\:.*//g' | tail -n+2)"
		
			## Difference between first two ID lines is metric for unwrapped vs. hard-wrapped test.
			## If 2, unwrapped; if greater than 2, hard-wrapped.
			MY_FORMAT_METRIC="$(calc $MY_SECOND_ID_LINE - $MY_FIRST_ID_LINE)"
		
		
		if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
		echo "INFO      | $(date) |               B. CONVERT FASTA TO PHYLIP FORMAT CONDITIONAL ON SEQUENCE LINE BREAK FORMAT. "
		fi
		#####  SEQUENTIAL, HARD-WRAPPED FASTA2PHYLIP CONVERSION CODE  #####
		
		if [[ "$MY_FORMAT_METRIC" -gt "2" ]]; then
		
			## The FASTA file has hard-wrapped sequences. Convert it to sequential, unwrapped FASTA format.
		
			if [[ "${machine}" = "Mac" ]]; then
				sed -i '' 's/^\(\>.*\)/\1MARK\_EOL/g' "$MY_FASTA"
			fi
			if [[ "${machine}" = "Linux" ]]; then
				sed -i 's/^\(\>.*\)/\1MARK\_EOL/g' "$MY_FASTA"
			fi
			perl -pi -e 's/\n//g' "$MY_FASTA"
			perl -pi -e 's/MARK\_EOL/\n/g' "$MY_FASTA"
			perl -pi -e 's/\>/\n\>/g' "$MY_FASTA"
		
			## Need empty line check here again:
			if [[ "$(grep -n '^[\s]*$' $MY_FASTA | wc -l | sed 's/\ //g' | perl -pe 's/\t//g')" -gt "0" ]]; then 
				if [[ "${machine}" = "Mac" ]]; then
					sed -i '' '/^[[:space:]]*$/d' "$MY_FASTA"
				fi
				if [[ "${machine}" = "Linux" ]]; then
					sed -i '/^[[:space:]]*$/d' "$MY_FASTA"
				fi
			fi
		
			## May also need to make sure the last line has EOF line (i.e. a blank line with no 
			## carriage return).
			# ADD TEST HERE
			# MY_EOF_METRIC="$( some way to search for '\n$' or '$\n$' on UNIX)   grep -h $'$\n$'  "
		
			## Count number of taxa/tips present in FASTA file:
			MY_NTAXA="$(grep -n '^>' $MY_FASTA | wc -l | perl -pe 's/^\ +//g')"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of taxa: $MY_NTAXA "
			fi
		
			## This is the base name of the original FASTA file, so you have it. This will work regardless 
			## of whether the FASTA filename extension is written in lowercase or in all caps, as 
			## abbreviated (e.g. ".fa", ".fas", ".FAS") or in full (e.g. ".fasta", ".FASTA").
			MY_FASTA_BASENAME="$(echo $MY_FASTA | sed 's/\.\///g; s/\.[A-Za-z]\{2,\}$//g')"
		
			## Count corrected number of characters in DNA alignment
			MY_INITIAL_NCHAR="$(head -n2 "$MY_FASTA" | tail -n+2 | wc -c | sed 's/\ //g' | perl -pe 's/\t//g')"
			MY_CORRECTED_NCHAR="$(calc $MY_INITIAL_NCHAR - 1)"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of characters: $MY_CORRECTED_NCHAR bp "
			fi
		
			## Convert sequential, unwrapped FASTA file to PHYLIP format:
			echo "$MY_NTAXA  $MY_CORRECTED_NCHAR" > ./header.tmp	# Make tmp PHYLIP header.
		
			perl -pi -e 's/\>(.*)\n/$1\ /g' "$MY_FASTA"				# 1 line per sequence, no '>' delimiter.
		
			sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' "$MY_FASTA" > ./taxonLabels.tmp
			MY_TAX_LABELS="$(sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' $MY_FASTA | sed 's/$/\ /g' | perl -pe 's/\n//g')"
			sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' "$MY_FASTA" > ./fastaSeqs.tmp
			#MY_SEQUENCES="$(sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' $MY_FASTA  | sed 's/$/\ /g' | perl -pe 's/\n//g')"
		
			MY_NAMESPACE_LENGTH="$(calc $(cat ./taxonLabels.tmp | awk '{ print length }' | sort -n | tail -1) + 1)"
		
			for i in $MY_TAX_LABELS; do
			printf "%-"$MY_NAMESPACE_LENGTH"s \n" "$i" >> ./taxon_names_spaces.tmp
			done
		
			paste ./taxon_names_spaces.tmp ./fastaSeqs.tmp > ./new_fasta_body.tmp
			cat ./header.tmp ./new_fasta_body.tmp > "$MY_FASTA_BASENAME".phy 
		
			## Remove any tab characters (these are artifacts of paste operation above).
			perl -pi -e 's/\t//g' ./"$MY_FASTA_BASENAME".phy
	
			## Remove orig FASTA file and delete temporary files.
			rm "$MY_FASTA"
			rm ./*.tmp
		
		fi
		
		
		#####  SEQUENTIAL, UNWRAPPED FASTA2PHYLIP CONVERSION CODE  #####
		
		if [[ "$MY_FORMAT_METRIC" -eq "2" ]]; then
		
		##--The FASTA file has DNA sequences in sequential, unwrapped format already; no need to 
		##--convert it, so use file as is.
		
			## Count number of taxa/tips present in FASTA file:
			MY_NTAXA="$(grep -n '^>' $MY_FASTA | wc -l | perl -pe 's/^\ +//g')"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of taxa: $MY_NTAXA "
			fi
		
			## This is the base name of the original FASTA file, so you have it. This will work regardless 
			## of whether the FASTA filename extension is written in lowercase or in all caps, as 
			## abbreviated (".fas", ".FAS") or in full (".fasta", ".FASTA").
			MY_FASTA_BASENAME="$(echo $MY_FASTA | sed 's/\.\///g; s/\.[A-Za-z]\{3,\}$//g')"
		
			## Count corrected number of characters in DNA alignment
			MY_INITIAL_NCHAR="$(head -n2 "$MY_FASTA" | tail -n+2 | wc -c | sed 's/\ //g' | perl -pe 's/\t//g')"
			MY_CORRECTED_NCHAR="$(calc $MY_INITIAL_NCHAR - 1)"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of characters: $MY_CORRECTED_NCHAR bp "
			fi
		
			## Convert sequential, unwrapped FASTA file to PHYLIP format:
			echo "$MY_NTAXA  $MY_CORRECTED_NCHAR" > ./header.tmp
		
			perl -pi -e 's/\>(.*)\n/$1\ /g' "$MY_FASTA"				# 1 line per sequence, no '>' delimiter.
		
			sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' "$MY_FASTA" > ./taxonLabels.tmp
			MY_TAX_LABELS="$(sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' $MY_FASTA | sed 's/$/\ /g' | perl -pe 's/\n//g')"
			sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' "$MY_FASTA" > ./fastaSeqs.tmp
			#MY_SEQUENCES="$(sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' $MY_FASTA  | sed 's/$/\ /g' | perl -pe 's/\n//g')"
		
			MY_NAMESPACE_LENGTH="$(calc $(cat ./taxonLabels.tmp | awk '{ print length }' | sort -n | tail -1) + 1)"
		
			for i in $MY_TAX_LABELS; do
			printf "%-"$MY_NAMESPACE_LENGTH"s \n" "$i" >> ./taxon_names_spaces.tmp
			done
		
			paste ./taxon_names_spaces.tmp ./fastaSeqs.tmp > ./new_fasta_body.tmp
			cat ./header.tmp ./new_fasta_body.tmp > "$MY_FASTA_BASENAME".phy 
		
			## Remove any tab characters (these are artifacts of operation above).
			perl -pi -e 's/\t//g' ./"$MY_FASTA_BASENAME".phy
	
			## Remove orig FASTA file and delete temporary files.
			rm "$MY_FASTA"
			rm ./*.tmp
		
		fi
	
	fi
	
	
	
	if [[ "$MY_KEEP_FASTA_SWITCH" = "1" ]]; then
		############ STEP #2A: CLEAN FILE, GET FASTA FILE AND DATA CHARACTERISTICS (USED TO CHECK FOR UN-
		############ WRAPPED VERSUS HARD-WRAPPED FORMAT).
	
		cp "$MY_FASTA" ./fasta.tmp
	
		##--If present, remove empty lines / newlines from input FASTA file, $MY_FASTA.
			if [[ "$(grep -n '^[\s]*$' ./fasta.tmp | wc -l | sed 's/\ //g' | perl -pe 's/\t//g')" -gt "0" ]]; then 
				if [[ "${machine}" = "Mac" ]]; then
					sed -i '' '/^[[:space:]]*$/d' ./fasta.tmp
				fi
				if [[ "${machine}" = "Linux" ]]; then
					sed -i '/^[[:space:]]*$/d' ./fasta.tmp
				fi
			fi
		
		##--If present, remove lines that have been commented out from input FASTA file, $MY_FASTA. 
		##--Unlike sequence lines, these lines will all contain '#' characters.
			if [[ "$(grep -n '\#' ./fasta.tmp | wc -l | sed 's/\ //g' | perl -pe 's/\t//g')" -gt "0" ]]; then 
				if [[ "${machine}" = "Mac" ]]; then
					sed -i '' '/\#/d' ./fasta.tmp
				fi
				if [[ "${machine}" = "Linux" ]]; then
					sed -i '/\#/d' ./fasta.tmp
				fi
			fi
		
		##--Generate metric used below to test FASTA file format and identify whether file contains 
		##--unwrapped (single line) or hard-wrapped (multiple line) DNA sequences.
		
			## Get first ID delimiter line number:
			MY_FIRST_ID_LINE="$(grep -n '>' ./fasta.tmp | head -n2 | sed 's/\:.*//g' | head -n1)"
			
			## Get second ID delimiter line number:
			MY_SECOND_ID_LINE="$(grep -n '>' ./fasta.tmp | head -n2 | sed 's/\:.*//g' | tail -n+2)"
		
			## Difference between first two ID lines is metric for unwrapped vs. hard-wrapped test.
			## If 2, unwrapped; if greater than 2, hard-wrapped.
			MY_FORMAT_METRIC="$(calc $MY_SECOND_ID_LINE - $MY_FIRST_ID_LINE)"
		
		
		if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
		echo "INFO      | $(date) |               B. CONVERT FASTA TO PHYLIP FORMAT CONDITIONAL ON SEQUENCE LINE BREAK FORMAT. "
		fi
		#####  SEQUENTIAL, HARD-WRAPPED FASTA2PHYLIP CONVERSION CODE  #####
		
		if [[ "$MY_FORMAT_METRIC" -gt "2" ]]; then
		
			## The FASTA file has hard-wrapped sequences. Convert it to sequential, unwrapped FASTA format.
		
			if [[ "${machine}" = "Mac" ]]; then
				sed -i '' 's/^\(\>.*\)/\1MARK\_EOL/g' ./fasta.tmp
			fi
			if [[ "${machine}" = "Linux" ]]; then
				sed -i 's/^\(\>.*\)/\1MARK\_EOL/g' ./fasta.tmp
			fi
			perl -pi -e 's/\n//g' ./fasta.tmp
			perl -pi -e 's/MARK\_EOL/\n/g' ./fasta.tmp
			perl -pi -e 's/\>/\n\>/g' ./fasta.tmp
		
			## Need empty line check here again:
			if [[ "$(grep -n '^[\s]*$' ./fasta.tmp | wc -l | sed 's/\ //g' | perl -pe 's/\t//g')" -gt "0" ]]; then 
				if [[ "${machine}" = "Mac" ]]; then
					sed -i '' '/^[[:space:]]*$/d' ./fasta.tmp
				fi
				if [[ "${machine}" = "Linux" ]]; then
					sed -i '/^[[:space:]]*$/d' ./fasta.tmp
				fi
			fi
		
			## May also need to make sure the last line has EOF line (i.e. a blank line with no 
			## carriage return).
			# ADD TEST HERE
			# MY_EOF_METRIC="$( some way to search for '\n$' or '$\n$' on UNIX)   grep -h $'$\n$'  "
		
			## Count number of taxa/tips present in FASTA file:
			MY_NTAXA="$(grep -n '^>' ./fasta.tmp | wc -l | perl -pe 's/^\ +//g')"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of taxa: $MY_NTAXA "
			fi
		
			## This is the base name of the original FASTA file, so you have it. This will work regardless 
			## of whether the FASTA filename extension is written in lowercase or in all caps, as 
			## abbreviated (e.g. ".fa", ".fas", ".FAS") or in full (e.g. ".fasta", ".FASTA").
			MY_FASTA_BASENAME="$(echo $MY_FASTA | sed 's/\.\///g; s/\.[A-Za-z]\{2,\}$//g')"
		
			## Count corrected number of characters in DNA alignment
			MY_INITIAL_NCHAR="$(head -n2 ./fasta.tmp | tail -n+2 | wc -c | sed 's/\ //g' | perl -pe 's/\t//g')"
			MY_CORRECTED_NCHAR="$(calc $MY_INITIAL_NCHAR - 1)"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of characters: $MY_CORRECTED_NCHAR bp "
			fi
		
			## Convert sequential, unwrapped FASTA file to PHYLIP format:
			echo "$MY_NTAXA  $MY_CORRECTED_NCHAR" > ./header.tmp	# Make tmp PHYLIP header.
		
			perl -pi -e 's/\>(.*)\n/$1\ /g' ./fasta.tmp				# 1 line per sequence, no '>' delimiter.
		
			sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' ./fasta.tmp > ./taxonLabels.tmp
			MY_TAX_LABELS="$(sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' ./fasta.tmp | sed 's/$/\ /g' | perl -pe 's/\n//g')"
			sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' ./fasta.tmp > ./fastaSeqs.tmp
			#MY_SEQUENCES="$(sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' ./fasta.tmp  | sed 's/$/\ /g' | perl -pe 's/\n//g')"
		
			MY_NAMESPACE_LENGTH="$(calc $(cat ./taxonLabels.tmp | awk '{ print length }' | sort -n | tail -1) + 1)"
		
			for i in $MY_TAX_LABELS; do
			printf "%-"$MY_NAMESPACE_LENGTH"s \n" "$i" >> ./taxon_names_spaces.tmp
			done
		
			paste ./taxon_names_spaces.tmp ./fastaSeqs.tmp > ./new_fasta_body.tmp
			cat ./header.tmp ./new_fasta_body.tmp > "$MY_FASTA_BASENAME".phy 
		
			## Remove any tab characters (these are artifacts of paste operation above).
			perl -pi -e 's/\t//g' ./"$MY_FASTA_BASENAME".phy
			
			## Move orig FASTA and new PHYLIP files to their respective folders, and delete temporary
			## files.
			mv "$MY_FASTA" ./orig_fasta_files/
			mv "$MY_FASTA_BASENAME".phy ./phylip_files/
			rm ./*.tmp
		
		fi
		
		
		#####  SEQUENTIAL, UNWRAPPED FASTA2PHYLIP CONVERSION CODE  #####
		
		if [[ "$MY_FORMAT_METRIC" -eq "2" ]]; then
		
		##--The FASTA file has DNA sequences in sequential, unwrapped format already; no need to 
		##--convert it, so use file as is.
		
			## Count number of taxa/tips present in FASTA file:
			MY_NTAXA="$(grep -n '^>' ./fasta.tmp | wc -l | perl -pe 's/^\ +//g')"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of taxa: $MY_NTAXA "
			fi
		
			## This is the base name of the original FASTA file, so you have it. This will work regardless 
			## of whether the FASTA filename extension is written in lowercase or in all caps, as 
			## abbreviated (".fas", ".FAS") or in full (".fasta", ".FASTA").
			MY_FASTA_BASENAME="$(echo $MY_FASTA | sed 's/\.\///g; s/\.[A-Za-z]\{3,\}$//g')"
		
			## Count corrected number of characters in DNA alignment
			MY_INITIAL_NCHAR="$(head -n2 ./fasta.tmp | tail -n+2 | wc -c | sed 's/\ //g' | perl -pe 's/\t//g')"
			MY_CORRECTED_NCHAR="$(calc $MY_INITIAL_NCHAR - 1)"
			if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
			echo "INFO      | $(date) |               Number of characters: $MY_CORRECTED_NCHAR bp "
			fi
		
			## Convert sequential, unwrapped FASTA file to PHYLIP format:
			echo "$MY_NTAXA  $MY_CORRECTED_NCHAR" > ./header.tmp
		
			perl -pi -e 's/\>(.*)\n/$1\ /g' ./fasta.tmp				# 1 line per sequence, no '>' delimiter.
		
			sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' ./fasta.tmp > ./taxonLabels.tmp
			MY_TAX_LABELS="$(sed 's/^\([A-Z\_a-z0-9\-]*\)[\ ]*.*/\1/g' ./fasta.tmp | sed 's/$/\ /g' | perl -pe 's/\n//g')"
			sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' ./fasta.tmp > ./fastaSeqs.tmp
			#MY_SEQUENCES="$(sed 's/^[A-Z\_a-z0-9\-]*[\ ]*\(.*\)/\1/g' ./fasta.tmp  | sed 's/$/\ /g' | perl -pe 's/\n//g')"
		
			MY_NAMESPACE_LENGTH="$(calc $(cat ./taxonLabels.tmp | awk '{ print length }' | sort -n | tail -1) + 1)"
		
			for i in $MY_TAX_LABELS; do
			printf "%-"$MY_NAMESPACE_LENGTH"s \n" "$i" >> ./taxon_names_spaces.tmp
			done
		
			paste ./taxon_names_spaces.tmp ./fastaSeqs.tmp > ./new_fasta_body.tmp
			cat ./header.tmp ./new_fasta_body.tmp > "$MY_FASTA_BASENAME".phy 
		
			## Remove any tab characters (these are artifacts of paste operation above).
			perl -pi -e 's/\t//g' ./"$MY_FASTA_BASENAME".phy
			
			## Move orig FASTA and new PHYLIP files to their respective folders, and delete temporary
			## files.
			mv "$MY_FASTA" ./orig_fasta_files/
			mv "$MY_FASTA_BASENAME".phy ./phylip_files/
			rm ./*.tmp
		
		fi
	
	fi

	done
)



if [[ "$MY_VERBOSE_OUT_SWITCH" != "0" ]]; then
echo "INFO      | $(date) | Successfully created PHYLIP ('.phy') input file from input sequential FASTA file $MY_FASTA. "
echo "INFO      | $(date) | Bye.
"
fi

#
#
#
######################################### END ############################################

exit 0
