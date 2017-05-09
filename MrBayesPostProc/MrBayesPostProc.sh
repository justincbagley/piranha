#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                             MrBayesPostProc v1.3, May 2017                             #
#  SHELL SCRIPT FOR POST-PROCESSING OF MrBayes OUTPUT FILES ON A SUPERCOMPUTING CLUSTER  #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: May 8, 2017.  #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_RELBURNIN_FRAC=0.25
MY_SS_ANALYSIS_SWITCH=0
MY_SS_NGEN=250000
MY_SS_DIAGNFREQ=2500

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h help H] [Options: -b s g d] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -b   relBurninFrac (def: $MY_RELBURNIN_FRAC) fraction of trees to discard as 'burn-in'
  -s   SS (def: 0, no stepping-stone (SS) analysis conducted; 1, run SS analysis) allows
       calling stepping-stone analysis starting from NEXUS in current working dir.
  -g   SSnGen (def: $MY_SS_NGEN) if 1 for SS above, allows specifying the number of total 
       SS sampling iterations (uses default number of steps, 50; total iterations will 
       be split over 50 steps) 
  -d   SSDiagFreq (def: $MY_SS_DIAGNFREQ) if 1 for SS above, this specifies the diagnosis 
       (logging) frequency for parameters during SS analysis, in number of generations

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
 Baele
 Ronquist 
 Xie
"

############ PARSE THE OPTIONS
while getopts 'h:H:b:s:g:d:' opt ; do
  case $opt in
## Help texts:
	h) echo "$Usage"
       exit ;;
	H) echo "$verboseHelp"
       exit ;;

## MrBayesPostProc options:
    b) MY_RELBURNIN_FRAC=$OPTARG ;;
    s) MY_SS_ANALYSIS_SWITCH=$OPTARG ;;
    g) MY_SS_NGEN=$OPTARG ;;
    d) MY_SS_DIAGNFREQ=$OPTARG ;;

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
#                             MrBayesPostProc v1.3, May 2017                             #
##########################################################################################"

###### Prep files and then Summarize trees, their posterior probabilities, and their errors using MrBayes.

echo "INFO      | $(date) | STEP #1: SETUP VARIABLES. "
##--Make the "handy bash function 'calc'" for subsequent use.
	calc () {
	   	bc -l <<< "$@"
	}
    if [[ -f ./*.NEX ]]; then
        echo "INFO      | $(date) |          Fixing NEXUS filename... "
    (
        for file in *.NEX; do
            mv "$file" "`basename "$file" .NEX`.nex"
        done
    )
    fi

	MY_NEXUS=./*.nex
	MY_MRBAYES_FILENAME="$(ls | grep -n ".mcmc" | sed -n 's/.://p' | sed 's/\.mcmc$//g')"
	MY_SC_MB_PATH="$(grep -n "mb_path" ./mrbayes_post_proc.cfg | awk -F"=" '{print $NF}')"


echo "INFO      | $(date) | STEP #2: REMOVE MRBAYES BLOCK FROM NEXUS FILE. "
	MY_MRBAYES_BLOCK_START="$(grep -n "BEGIN mrbayes;" ./*.nex | sed 's/:.*$//g')"
	MY_HEADSTOP="$(calc $MY_MRBAYES_BLOCK_START-1)"

	head -n$MY_HEADSTOP $MY_NEXUS > ./simple.nex


echo "INFO      | $(date) | STEP #3: CREATE BATCH FILE TO RUN IN MRBAYES. "
echo "INFO      | $(date) |          Making batch file... "
echo "set autoclose=yes nowarn=yes
execute ./simple.nex
sumt Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac=${MY_RELBURNIN_FRAC}
sump Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac=${MY_RELBURNIN_FRAC}
quit" > ./batch.txt

##--Flow control. Check to make sure MrBayes batch file was successfully created.
    if [[ -f ./batch.txt ]]; then
        echo "INFO      | $(date) |          MrBayes batch file ("batch.txt") successfully created. "
    else
        echo "WARNING!  | $(date) |          Something went wrong. MrBayes batch file ("batch.txt") not created. Exiting... "
        exit
    fi


echo "INFO      | $(date) | STEP #4: SUMMARIZE RUN AND COMPUTE CONSENSUS TREE IN MRBAYES. "
##--This calls the commands in the batch.txt file to run within MrBayes, opening the 
##--simplified nexus file and creating summaries of the tree and run parameters as wellas
##--computing a majority-rule consensus tree with Bayesian posterior probabilities 
##--annotated along each node.

    $MY_SC_MB_PATH  < ./batch.txt > Mrbayes_sumtp_log.txt &		## Use batch to run MrBayes.


echo "INFO      | $(date) | STEP #5: CLEANUP FILES. "
	rm ./batch.txt							## Remove temporary files created above.
	rm ./simple.nex


if [[ "$MY_SS_ANALYSIS_SWITCH" -eq "1" ]]; then
echo "INFO      | $(date) | STEP #5: CONDUCT STEPPING-STONE ANALYSIS TO ESTIMATE LOG MARGINAL LIKELIHOOD OF THE MODEL. "

echo "set autoclose=yes nowarn=yes
execute ./simple.nex
ss ngen=${MY_SS_NGEN} diagnfreq=${MY_SS_DIAGNFREQ}
quit" > ./SS_batch.txt

	$MY_SC_MB_PATH  < ./SS_batch.txt > Mrbayes_SS_log.txt &		## Use SS_batch to run SS analysis in MrBayes.

fi

rm ./SS_batch.txt

echo "INFO      | $(date) | Done with post-processing of MrBayes results using MrBayesPostProc. "
echo "INFO      | $(date) | Bye. 
"
#
#
#
######################################### END ############################################

exit 0
