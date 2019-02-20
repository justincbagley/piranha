##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                            dadiPostProc v0.1.0, April 2017                             #
#  SHELL SCRIPT FOR POST-PROCESSING OUTPUT FROM ONE OR MULTIPLE ∂a∂i RUNS (IDEALLY RUN   #
#  USING dadiRunner.sh), INCLUDING COLLATION OF BEST-FIT PARAMETER ESTIMATES, COMPOSITE  #
#  LIKELIHOODS, AND OPTIMAL THETA VALUES                                                 #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: April 25, 2017. For questions, please email bagleyj@umsl.edu.                 #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_NUM_INDEP_RUNS=10
MY_LOWER_MOD_NUM=1
MY_UPPER_MOD_NUM=10

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H Help] [Options: -n l u] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -n   nRuns (def: $MY_NUM_INDEP_RUNS) number of independent ∂a∂i runs per model (.py file)
  -l   lowerModNum (def: $MY_LOWER_MOD_NUM) lower number in model number range
  -u   upperModNum (def: $MY_UPPER_MOD_NUM) upper number in model number range
  
 OVERVIEW
 Automates post-processing and organizing results from multiple ∂a∂i (Gutenkunst et al. 2009)
 runs, ideally conducted using the dadiRunner script in PIrANHA (see PIrANHA README for  
 additional details), although this is not required. Expects run results organized into 
 separate sub-folders of current working directory, with sub-folder names containing model
 name. Model names should be of form 'M1' to 'Mx', where x is the number of models. Multiple
 runs (e.g. 10) would have been run on the .py file for each model. Results could be on
 remote supercomputer (i.e. following dadiRunner), or your local machine.

 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Gutenkunst RN, Hernandez RD, Williamson SH, Bustamante CD (2009) Inferring the joint 
 	demographic history of multiple populations from multidimensional SNP frequency data. 
 	PLOS Genetics 5(10): e1000695
"

verboseHelp="Usage: $(basename "$0") [Help: -h help H Help] [Options: -i n] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -n   nRuns (def: $MY_NUM_INDEP_RUNS) number of independent ∂a∂i runs per model (.py file)
  -l   lowerModNum (def: $MY_LOWER_MOD_NUM) lower number in model number range
  -u   upperModNum (def: $MY_UPPER_MOD_NUM) upper number in model number range

 OVERVIEW
 Automates post-processing and organizing results from multiple ∂a∂i (Gutenkunst et al. 2009)
 runs, ideally conducted using the dadiRunner script in PIrANHA (see PIrANHA README for  
 additional details), although this is not required. Expects run results organized into 
 separate sub-folders of current working directory, with sub-folder names containing model
 name. Model names should be of form 'M1' to 'Mx', where x is the number of models. Multiple
 runs (e.g. 10) would have been run on the .py file for each model. Results could be on
 remote supercomputer (i.e. following dadiRunner), or your local machine.

 DETAILS
 The -n flag sets the number of independent ∂a∂i runs to be submitted to the supercomputer
 for each model specified in a .py file in the current working directory. The default is 10
 runs.
 
 The -l flage sets the number for the lower value in the range of model numbers, e.g. a
 value of 1 being the default, used for a model set with ten models named M1 to M10.
 
 The -u flag sets the number for the upper value in the range of model numbers, e.g. a value
 of 10 being the default, used for a model set with ten models named M1 to M10.
 
		## Usage examples: 
		"$0" .				## Using the defaults.
		"$0" -n 10 -l 1 -u 10 .		## A case equal to the defaults.
		"$0" -n 5 -l 2 -u 7 .		## Illustrating that dadiPostProc accomodates model number
								## ranges starting from values other than 1.

 CITATION
 Bagley, J.C. 2017. PIrANHA v0.1.4. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Gutenkunst RN, Hernandez RD, Williamson SH, Bustamante CD (2009) Inferring the joint 
 	demographic history of multiple populations from multidimensional SNP frequency data. 
 	PLOS Genetics 5(10): e1000695
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
while getopts 'n:l:u:' opt ; do
  case $opt in

## ∂a∂i options:
    n) MY_NUM_INDEP_RUNS=$OPTARG ;;
    l) MY_LOWER_MOD_NUM=$OPTARG ;;
    u) MY_UPPER_MOD_NUM=$OPTARG ;;

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

echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$USER_SPEC_PATH "	

echo "
##########################################################################################
#                            dadiPostProc v0.1.0, April 2017                             #
##########################################################################################
"

######################################## START ###########################################
echo "INFO      | $(date) | Starting dadiPostProc analysis... "
echo "INFO      | $(date) | STEP #1: SETUP, AND DETECT ONE OR MULTIPLE ∂a∂i RUN SUB-FOLDERS IN CURRENT DIR. "
###### Set paths and filetypes as different environmental variables:
	MY_PATH=`pwd -P`		## This script assumes it is being run in a working dir containing
							## multiple sub-folders corresponding to individual ∂a∂i runs
							## from which a single output file having extension ".out" or 
							## ".out.txt" was created, and to which best-fit parameters, composite
							## likelihood, and optimal theta values have been written out 
							## following standard out from the program. Ideally, file/dir structure
							## will have resulted from running multiple ∂a∂i input files using
							## the "dadiRunner.sh" script in PIrANHA.
	calc () { 
		bc -l <<< "$@" 
}

if [[ "$(find . -type d | wc -l)" = "1" ]]; then
	MY_MULTIRUN_DIR_SWITCH=FALSE
	## Inside folder corresponding to 1 single run.
elif [[ "$(find . -type d | wc -l)" -gt "1" ]]; then
	MY_MULTIRUN_DIR_SWITCH=TRUE
	## Inside working directory containing multiple sub-folders, assumed to correspond to ∂a∂i run folders (1 per run).
fi


echo "INFO      | $(date) | STEP #2: POST-PROCESSING OUTPUT FILE: EXTRACTING & SAVING BEST-FIT PARAMETERS, COMPOSITE LIKELIHOOD, AND "
echo "INFO      | $(date) |          OPTIMAL THETA ESTIMATE (IF PRESENT) TO A SINGLE FILE WITH THE SAME BASENAME AS THE RUN FOLDER. "


## if MY_MULTIRUN_DIR_SWITCH=FALSE, ...
## DO SINGLE RUN ANALYSIS HERE



## if MY_MULTIRUN_DIR_SWITCH=TRUE, ...
## DO BIG LOOP BELOW:


###### Use a big loop through the run sub-folders in pwd to extract and organize output
##--from multiple ∂a∂i runs. Here, we do several things within each run sub-folder. 1) We 
##--first get details about the folder name & output filename, while accommodating 2 possible 
##--output filename extensions. 2) Second, we grep and sed out details from the output file.
##--In particular, we 3) test whether the best-fit model parameters are are contained on a
##--single line, and if so we sed out anything we don't want and save the best params to a
##--"_BFP.tmp" file; if not, count number/numbers of lines from start of best-fit params 
##--reporting/line til next closing bracket encountered and then organize those lines into
##--a single line and extract results. We also extract information about 4) the maximum 
##--composite likelihood and 5) the optimal value of theta for the run, for the given model 
##--(at that point in the loop). Data points under operations #4 and #5 above are always
##--on a single line, thus easy to extract with regex/sed.
	(
		for i in ./*/; do
			cd "$i"; 
				MY_FOLDER_BASENAME="$(echo ${i} | sed 's/^.\///g; s/\///g')"
				echo $MY_FOLDER_BASENAME
#			
				### CHECK FOR OUTPUT FILE.
				if [[ -s $(find . -name "*.out" -type f) ]]; then
					MY_OUTPUT_FILENAME="$(find . -name "*.out" -type f)"
					MY_OUTPUT_BASENAME="$(find . -name "*.out" -type f | sed 's/^\.\///g; s/\.out//g')"
				elif [[ -s $(find . -name "*.out.txt" -type f) ]]; then
					MY_OUTPUT_FILENAME="$(find . -name "*.out.txt" -type f)"
					MY_OUTPUT_BASENAME="$(find . -name "*.out.txt" -type f | sed 's/^\.\///g; s/\.out\.txt//g')"
				fi
#			
#
				### EXTRACT BEST-FIT MODEL PARAMETER ESTIMATES: 
				grep -n "Best\-fit\ parameters:" $MY_OUTPUT_FILENAME > "${MY_OUTPUT_BASENAME}"_BFP.tmp
				##--Get starting line no. for BFPs:
				MY_BFP_START_LN_NUM="$(sed 's/\:.*$//g' ${MY_OUTPUT_BASENAME}_BFP.tmp)"
				MY_BFP_CLOSEBRACK_TEST="$(grep -h "\]" ${MY_OUTPUT_BASENAME}_BFP.tmp | wc -l)"
#
					if [[ "$MY_BFP_CLOSEBRACK_TEST" = "0" ]]; then

						##--Clean up only to tab-separated BFP estimates:
						sed -i '' $'s/^[0-9]*\:.*\ \[//g; s/\]//g; s/\ /\t/g; s/\t\t\t/\t/g; s/\t\t/\t/g; s/^\t//g' ./"${MY_OUTPUT_BASENAME}"_BFP.tmp
						sed -i '' 's/^$//g' ./"${MY_OUTPUT_BASENAME}"_BFP.tmp

					elif [[ "$MY_BFP_CLOSEBRACK_TEST" != "0" ]]; then

						##--Get final line no. for multi-line BFPs:
						MY_BFP_FINISH_LN_NUM="$(grep -n '\ .*\]' $MY_OUTPUT_FILENAME | sed 's/\:.*$//g' | tail -n1)"

						##--Use sed to extract multi-line BFPs lines to tmp file using line nos:
						sed -n "$MY_BFP_START_LN_NUM","$MY_BFP_FINISH_LN_NUM"p "$MY_OUTPUT_FILENAME" > ./"${MY_OUTPUT_BASENAME}"_multiline_BFP.tmp

						##--Convert BFPs to single line with numbers in tab-separated format, and 
						##--remove "_BFP.tmp" and "_multiline_BFP.tmp" files created above:
						rm ./"${MY_OUTPUT_BASENAME}"_BFP.tmp
						perl -pe 's/\n/\ /g; s/^.*\:\ \[\ //g; s/\ /\t/g; s/\t\t\t/\t/g; s/\t\t/\t/g; s/^\t//g; s/\]//g' ./"${MY_OUTPUT_BASENAME}"_multiline_BFP.tmp | perl -pe 's/\t$//g' > ./"${MY_OUTPUT_BASENAME}"_BFP.tmp
						rm ./"${MY_OUTPUT_BASENAME}"_multiline_BFP.tmp
					fi
#
#
				### EXTRACT MAXIMUM COMPOSITE LIKELIHOOD ESTIMATE FOR THE RUN: 
				grep -h "likelihood\:\ " "$MY_OUTPUT_FILENAME" | sed 's/^.*\:\ //g; s/\ //g' > ./"${MY_OUTPUT_BASENAME}"_MLCL.tmp
###				perl -pi -e 'chomp if eof' ./"${MY_OUTPUT_BASENAME}"_MLCL.tmp
#
#
				### EXTRACT OPTIMAL VALUE OF THETA AS ESTIMATED BASED ON THE RUN: 
				grep -h "theta\:\ " "$MY_OUTPUT_FILENAME" |  sed 's/^.*\:\ //g; s/\ //g' > ./"${MY_OUTPUT_BASENAME}"_theta.tmp
###				perl -pi -e 'chomp if eof' ./"${MY_OUTPUT_BASENAME}"_theta.tmp
#
#
				### PASTE RESULTS IN TMP FILES TOGETHER INTO A SINGLE FILE, THEN COPY RESULTS SUMMARY FOR RUN TO WORKING DIR.
				paste ./"${MY_OUTPUT_BASENAME}"_MLCL.tmp ./"${MY_OUTPUT_BASENAME}"_BFP.tmp ./"${MY_OUTPUT_BASENAME}"_theta.tmp > ./"${MY_OUTPUT_BASENAME}"_results.txt
###				perl -pi -e 'chomp if eof' ./"${MY_OUTPUT_BASENAME}"_results.txt

				##--Check for "runs_output" output dir and make it if needed; then copy final 
				##--results summary file with run folder prefix to "runs_output" dir in working 
				##--dir (one dir up):
				if [ ! -d "../runs_output" ]; then
					mkdir ../runs_output/;
				fi
#				
				cp ./"${MY_OUTPUT_BASENAME}"_results.txt ../runs_output/;

				##--Clean up temporary files:
				rm ./*.tmp
			cd ..;
		done
	)


echo "INFO      | $(date) | STEP #3: FOR MULTIRUN CASE, COLLATE RESULTS FROM FILES (IN ./output/ DIR) FROM INDPENENDENT RUNS OF THE "
echo "INFO      | $(date) |          SAME MODEL, LOOKING FOR SEPARATE M1 (MODEL 1) RUN FILES CONTAINING FILENAMES PREFIXED WITH 'M1'. "
###### Here, recursively cat results from all files with the same model names in their prefixes 
##--(cycling through M1 to Mx, where x is the total number of models) into separate summaries 
##--for each model (e.g. one file for 10 M1 runs, a second file for 10 M2 runs, and so on).
	mkdir final_output
	(
		for (( j="MY_LOWER_MOD_NUM"; j<="MY_UPPER_MOD_NUM"; j++ )); do
			cat ./runs_output/*M"$j"*_results.txt >> ./final_output/M"$j"_resultsSummary.txt 
		done
	)

	cd ./final_output/;
		cat ./*Summary.txt > All_Models_M"$MY_LOWER_MOD_NUM"_M"$MY_UPPER_MOD_NUM"_resultsSummary.txt
	cd ..;
	
echo "INFO      | $(date) | Done post-processing results from one or multiple ∂a∂i runs using the dadiPostProc utility of PIrANHA. "
echo "Bye.
"
#
#
#
######################################### END ############################################

exit 0
