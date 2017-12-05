#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          MrBayesPostProc v1.4, December 2017                           #
#  SHELL SCRIPT FOR POST-PROCESSING OF MrBayes OUTPUT FILES ON A SUPERCOMPUTING CLUSTER  #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: December 2,   #
#  2017.  For questions, please email jcbagley@vcu.edu.                                  #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_RELBURNIN_FRAC=0.25
MY_SS_ANALYSIS_SWITCH=0
MY_SS_NGEN=250000
MY_SS_DIAGNFREQ=2500
MY_TEMP_FILE_SWITCH=1

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help] [Options: -b s g d t] workingDir 
 ## Help:
  -h   help text (also: -help)

 ## Options:
  -b   relBurninFrac (def: $MY_RELBURNIN_FRAC) fraction of trees to discard as 'burn-in'
  -s   SS (def: 0, no stepping-stone (SS) analysis conducted; 1, run SS analysis) allows
       calling stepping-stone analysis starting from NEXUS in current working dir
  -g   SSnGen (def: $MY_SS_NGEN) if 1 for SS above, allows specifying the number of total 
       SS sampling iterations (uses default number of steps, 50; total iterations will 
       be split over 50 steps) 
  -d   SSDiagFreq (def: $MY_SS_DIAGNFREQ) if 1 for SS above, this specifies the diagnosis 
       (logging) frequency for parameters during SS analysis, in number of generations
  -t   deleteTemp (def: 1, delete temporary files; 0, do not delete temporary files) calling
       0 will keep temporary files created during the run for later inspection 

 OVERVIEW
 Runs a simple script for post-processing results of a MrBayes v3.2+ (Ronquist et al. 2012)
 run, whose output files are assumed to be in the current working directory. This script preps 
 the output files in pwd, and then summarizes trees and their posterior probabilities (sumt), 
 and parameters of the specified model (sump) using MrBayes. Options are provided for specifying 
 the burnin fraction, and for calling stepping-stone analysis (Xie et al. 2011; Baele et al.
 2012) to robustly estimate the log marginal likelihood of the model/analysis, whose details 
 must be provided in a MrBayes block at the end of the input NEXUS file in the current dir.

 CITATION
 Bagley, J.C. 2017. RAPFX v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/RAPFX>.

 REFERENCES
 Baele G, Lemey P, Bedford T, Rambaut A, Suchard MA, Alekseyenko AV (2012) Improving the 
    accuracy of demographic and molecular clock model comparison while accommodating 
    phylogenetic uncertainty. Molecular Biology and Evolution, 29, 2157-2167.
 Ronquist F, Teslenko M, van der Mark P, Ayres D, Darling A, et al. (2012) MrBayes v. 3.2: 
    efficient Bayesian phylogenetic inference and model choice across a large model space. 
    Systematic Biology, 61, 539-542. 
 Xie W, Lewis PO, Fan Y, Kuo L, Chen MH (2011) Improving marginal likelihood estimation for 
    Bayesian phylogenetic model selection. Systematic Biology, 60, 150-160.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'b:s:g:d:t:' opt ; do
  case $opt in

## MrBayesPostProc options:
    b) MY_RELBURNIN_FRAC=$OPTARG ;;
    s) MY_SS_ANALYSIS_SWITCH=$OPTARG ;;
    g) MY_SS_NGEN=$OPTARG ;;
    d) MY_SS_DIAGNFREQ=$OPTARG ;;
    t) MY_TEMP_FILE_SWITCH=$OPTARG ;;
    
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
#                          MrBayesPostProc v1.4, December 2017                           #
##########################################################################################"

###### Prep files and then Summarize trees, their posterior probabilities, and their errors using MrBayes.

echo "INFO      | $(date) | STEP #1: SETUP VARIABLES. "
##--Make the "handy bash function 'calc'" for subsequent use.
	calc () {
	   	bc -l <<< "$@"
	}
	if [[ -s "$(NEX_FILES=./*.NEX; echo $NEX_FILES | head -n1)" ]]; then 
        echo "INFO      | $(date) |          Fixing NEXUS filename... "
    (
        for file in *.NEX; do
            mv "$file" "`basename "$file" .NEX`.nex"
        done
    )
	fi


	## This script was written to expect only a single NEXUS file in pwd; however, users 
	## will probably from time to time mistakenly run the script on a directory with 
	## multiple NEXUS files. Here, we can account for this by taking the first .nex file
	## found in the directory, by using the following line instead of MY_NEXUS=./*.nex 
	## (which would only work with 1 file). $MY_MRBAYES_FILENAME is the name of the output
	## of the run, which will be the root/prefix of each output file. The mb path is self
	## explanatory.
	if [[ -s "$(nex_FILES=./*.nex; echo $nex_FILES | head -n1 | sed 's/\ .*//g')" ]]; then 
		MY_NEXUS="$(ls ./*.nex | head -n1 | sed 's/\ //g')"
	fi
	MY_MRBAYES_FILENAME="$(ls | grep -n ".mcmc" | sed -n 's/.*://p' | sed 's/\.mcmc$//g')"
	MY_SC_MB_PATH="$(grep -n "mb_path" ./mrbayes_post_proc.cfg | awk -F"=" '{print $NF}')"


echo "INFO      | $(date) | STEP #2: REMOVE MRBAYES BLOCK FROM NEXUS FILE. "
	MY_MRBAYES_BLOCK_START="$(grep -n "BEGIN MrBayes\|Begin MrBayes\|BEGIN mrbayes\|Begin mrbayes\|begin mrbayes" $MY_NEXUS | sed 's/\:.*//; s/\ //g')"
	if [[ "$MY_MRBAYES_BLOCK_START" -gt "0" ]] || [[ -s "$MY_MRBAYES_BLOCK_START" ]]; then
		MY_HEADSTOP="$(calc $MY_MRBAYES_BLOCK_START-1)"
		head -n"$MY_HEADSTOP" "$MY_NEXUS" > simple.nex
	elif [[ ! "$MY_MRBAYES_BLOCK_START" -gt "0" ]]; then
		echo "INFO      | $(date) |          NEXUS file contains no MrBayes block. Renaming NEXUS to 'simple.nex'... "
		mv "$MY_NEXUS" simple.nex
	fi	


echo "INFO      | $(date) | STEP #3: CREATE BATCH FILE TO RUN IN MRBAYES. "
echo "INFO      | $(date) |          Making batch file... "
echo "set autoclose=yes nowarn=yes
execute simple.nex
sumt Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac=${MY_RELBURNIN_FRAC}
sump Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac=${MY_RELBURNIN_FRAC}
quit" > ./batch.txt

##--Flow control. Check to make sure MrBayes batch file was successfully created.
    if [[ -f ./batch.txt ]]; then
        echo "INFO      | $(date) |          MrBayes batch file ('batch.txt') successfully created. "
    else
        echo "WARNING!  | $(date) |          Something went wrong. MrBayes batch file ('batch.txt') not created. Exiting... "
        exit
    fi


echo "INFO      | $(date) | STEP #4: SUMMARIZE RUN AND COMPUTE CONSENSUS TREE IN MRBAYES. "
##--This calls the commands in the batch.txt file to run within MrBayes, opening the 
##--simplified nexus file and creating summaries of the tree and run parameters as wellas
##--computing a majority-rule consensus tree with Bayesian posterior probabilities 
##--annotated along each node.

    $MY_SC_MB_PATH  < ./batch.txt > Mrbayes_sumtp_log.txt &		## Use batch to run MrBayes.



if [[ "$MY_SS_ANALYSIS_SWITCH" -eq "1" ]]; then
echo "INFO      | $(date) | STEP #5: CONDUCT STEPPING-STONE ANALYSIS TO ESTIMATE LOG MARGINAL LIKELIHOOD OF THE MODEL. "

echo "set autoclose=yes nowarn=yes
execute ./simple.nex
ss ngen=${MY_SS_NGEN} diagnfreq=${MY_SS_DIAGNFREQ}
quit" > ./SS_batch.txt

	$MY_SC_MB_PATH  < ./SS_batch.txt > Mrbayes_SS_log.txt &		## Use SS_batch to run SS analysis in MrBayes.


echo "INFO      | $(date) | STEP #6: CLEANUP FILES. "
## If user desires, remove temporary files created above.
	if [[ "$MY_TEMP_FILE_SWITCH" -eq "1" ]]; then
		if [[ -f ./batch.txt ]]; then rm ./batch.txt; fi
		if [[ -f ./simple.nex ]]; then rm ./simple.nex; fi
		if [[ -f ./SS_batch.txt ]]; then rm ./SS_batch.txt; fi
	fi

fi


echo "INFO      | $(date) | STEP #5: CLEANUP FILES. "
## If user desires, remove temporary files created above.
	if [[ "$MY_TEMP_FILE_SWITCH" -eq "1" ]]; then
		if [[ -f ./batch.txt ]]; then rm ./batch.txt; fi
		if [[ -f ./simple.nex ]]; then rm ./simple.nex; fi
		if [[ -f ./SS_batch.txt ]]; then rm ./SS_batch.txt; fi
	fi


echo "INFO      | $(date) | Done with post-processing of MrBayes results using MrBayesPostProc. "
echo "INFO      | $(date) | Bye. 
"
#
#
#
######################################### END ############################################

exit 0
