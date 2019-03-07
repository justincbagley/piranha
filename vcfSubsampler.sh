#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: vcfSubsampler.sh                                                                 #
  VERSION="v0.1.0"                                                                       #
# Author: Justin C. Bagley                                                               #
# Date: created by Justin Bagley on Thu Sep 28 09:31:25 2017 -0400.                      #
# Last update: March 3, 2019                                                             #
# Copyright (c) 2017-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <bagleyj@umsl.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# SCRIPT THAT USES A LIST FILE TO SUBSAMPLE A VCF FILE SO THAT IT ONLY CONTAINS SNPs     #
# IN THE LIST                                                                            #
#                                                                                        #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_INPUT_VCF=input.vcf
MY_SNPS_FILE=snps.txt
MY_OUTPUT_VCF_FILE=subsample
DELETE_ORIG_VCF=0

############ CREATE USAGE & HELP TEXTS
USAGE="Usage: $(basename $0) [Help: -h help] [Options: -s o d V --version] [stdin:] <inputVCFFile>
 ## Help:
  -h   help text (also: --help) echo this help text and exit

 ## Options:
  -s snpsFile (def: $MY_SNPS_FILE) file listing, one per line, names of SNPs that the user 
     wishes to keep, corresponding to 'GENE' column of the input .vcf file
  -o output (def: $MY_OUTPUT_FILE) output vcf file basename (root; not including extension)
  -d deleteOrig (def: 0=no, 1=yes) specifies whether or not to delete the original input
     .vcf file
  -V   version (also: --version) echo version and exit

 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub package, Available at: 
	<http://github.com/justincbagley/PIrANHA>.
 or
 Bagley, J.C. 2019. PIrANHA v0.1.7. [Data set] Zenodo, Available at: 
	<http://doi.org/10.5281/zenodo.596766>.
 or
 Bagley, J.C. 2019. justincbagley/PIrANHA. GitHub package, Available at: 
	<http://doi.org/10.5281/zenodo.596766>.

Created by Justin Bagley on Thu Sep 28 09:31:25 2017 -0400.
Copyright (c) 2017-2019 Justin C. Bagley. All rights reserved.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$USAGE"
	exit
fi

if [[ "$1" == "-V" ]] || [[ "$1" == "--version" ]]; then
	echo "$(basename $0) $VERSION";
	exit
fi

############ PARSE THE OPTIONS
while getopts 's:o:d:' opt ; do
  case $opt in
## vcfSubsampler options:
    s) MY_SNPS_FILE=$OPTARG ;;
    o) MY_OUTPUT_FILE=$OPTARG ;;
    d) DELETE_ORIG_VCF=$OPTARG ;;
## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$USAGE" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
	echo "$USAGE"
	exit 1
fi
## Make input file a mandatory parameter:
MY_INPUT_VCF="$1"


######################################## START ###########################################

##--Subsample input .vcf file using snps list:
	while read j; do 
		grep -h "$(echo $j)" ./"$MY_INPUT_VCF" >> "$MY_OUTPUT_VCF_FILE".tmp ; 
	done < ./"$MY_SNPS_FILE"


##--Add header from original .vcf to the new, subsampled vcf file:
	grep -h "\#" ./"$MY_INPUT_VCF" > ./header.tmp ;

	cat ./header.tmp "$MY_OUTPUT_VCF_FILE".tmp > "$MY_OUTPUT_VCF_FILE".vcf ; 


##--Cleanup temporary files:
	rm ./*.tmp

##--Final cleanup:
##--Delete the original .vcf file if user has specified to do so:
	if [[ "$DELETE_ORIG_VCF" = 0 ]]; then
		echo "" ;
	elif [[ "$DELETE_ORIG_VCF" = 1 ]]; then
		rm ./"$MY_INPUT_VCF" ;
	fi

#
#
#
######################################### END ############################################

exit 0
