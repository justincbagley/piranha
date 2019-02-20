#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                       pyRAD2PartitionFinder v1.2, November 2018                        #
#  SHELL SCRIPT FOR RUNNING PartitionFinder ON SNP DNA PARTITIONS OUTPUT FROM pyRAD      #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: November 12, 2018. For questions, please email bagleyj@umsl.edu.              #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_INPUT_PHYLIP_SWITCH=0
MY_PF_RUN_SWITCH=1
MY_PF_VERSION=1
MY_PF_PATH=SEARCH
MY_PF_EVOMODELS=beast
MY_PF_MODSEL=BIC
MY_SEARCH_ALGORITHM=rcluster

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Options: -i r v p e m s] workingDir 
 ## Options:
  -i   inputPhylip (def: 0, .phy file in pwd; also takes name of .phy file in pwd, or absolute 
       path to .phy file in another dir) input Phylip sequence alignment file 
  -r   runPF (def: 1; opt out: 0) whether or not to run PartitionFinder after prepping 
       input files
  -v   PFversion (def: 1 = v1.1.1; other: 2 = v2.1.1) specify PartitionFinder version
  -p   PFpath (def: searches for PFversion locally) absolute path to PartitionFinder.py 
       Python script to execute
  -e   evoModels (def: beast; other: all, raxml, mrbayes)
  -m   modSel (def: BIC; other: AIC, AICc) model selection metric
  -s   search (def: $MY_SEARCH_ALGORITHM; other: greedy, hcluster) desired PartitionFinder
       search algorithm

 OVERVIEW
 THIS SCRIPT automates running PartitionFinder (Lanfear et al. 2012, 2014) "out-of-the-box"
 starting from the Phylip DNA sequence alignment file ('.phy') and partitions ('.partitions') 
 file output by pyRAD (Eaton 2014) or ipyrad (Eaton and Overcast 2016). Script expects to be 
 run from a working directory containing minimally one each of the two file types mentioned 
 above, plus the script. The only dependencies are Python 2.7/3++ and PartitionFinder. 
 
 For the -s flag, options are are greedy, rcluster, and hcluster. For less than 100 loci, 
 use the greedy algorithm. The rcluster and hcluster algorithms were developed in Lanfear et al. 
 (2014) for use with genome-scale datasets (reduced-genome, ddRADseq, GBS, and multilocus seq 
 matrices with 100s to 1000s of loci), where the greedy algorithm is very time consuming; however, 
 rcluster has been shown to greatly outperform hcluster, and is recommended for finding the 
 optimal partitioning scheme with such data (although hcluster is computationally more efficient). 
 Because this script was developed for use with ddRADseq assemblies/loci output by pyRAD, the 
 -s setting is set to rcluster by default.
 
 CITATION
 Bagley, J.C. 2019. PIrANHA v0.1.7. GitHub repository, Available at: 
	<https://github.com/justincbagley/PIrANHA>.

 REFERENCES
 Eaton DA (2014) PyRAD: assembly of de novo RADseq loci for phylogenetic analyses. 
 	Bioinformatics, 30, 1844-1849.
 Eaton DAR, Overcast I (2016) ipyrad: interactive assembly and analysis of RADseq data sets. 
 	Available at: <http://ipyrad.readthedocs.io/>.
 Lanfear R, Calcott B, Ho SYW, Guindon S (2012) Partitionfinder: combined selection of 
	partitioning schemes and substitution models for phylogenetic analyses. Molecular Biology 
	and Evolution, 29, 1695–1701. 
 Lanfear R, Calcott B, Kainer D, Mayer C, Stamatakis A (2014) Selecting optimal partitioning 
 	schemes for phylogenomic datasets. BMC Evolutionary Biology, 14, 82.
"

############ PARSE THE OPTIONS
while getopts 'i:r:v:p:e:m:s:' opt ; do
  case $opt in
## pyRAD2PartitionFinder options:
    i) MY_INPUT_PHYLIP_SWITCH=$OPTARG ;;
    r) MY_PF_RUN_SWITCH=$OPTARG ;;
    v) MY_PF_VERSION=$OPTARG ;;
    p) MY_PF_PATH=$OPTARG ;;
    e) MY_PF_EVOMODELS=$OPTARG ;;
    m) MY_PF_MODSEL=$OPTARG ;;
    s) MY_SEARCH_ALGORITHM=$OPTARG ;;

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
#                       pyRAD2PartitionFinder v1.2, November 2018                        #
##########################################################################################"

############ STEP #1: MODIFY pyRAD DATAFILE FOR PartitionFinder
MY_PYRAD_PARTITION=./*.partitions           				## Assign "partition" files in current directory to variable.

###### FORMAT pyRAD PARTITION FILE FOR PartitionFinder: 
(
	for i in $MY_PYRAD_PARTITION; do               			## Look in the current directory for partition scheme files output by pyRAD.
		echo "$i"
		sed 's/^DNA..//g' "${i}" > "${i}"_1.tmp					## Reformatting using nested for loops.
			for j in "${i}"_1.tmp; do 
				echo "$j"
				sed 's/$/;/' "${j}" > "${j}".PFparts.txt 
			done
		for k in *.partitions_1.tmp.PFparts.txt; do
			mv "$k" ${k/.partitions_1.tmp.PFparts.txt/.newPartitions.txt}
		done						## Line above renames the output.
	done
)

	rm *_1.tmp	## Remove unnecessary files.


############ STEP #2: PREPARE PartitionFinder CONFIGURATION FILE
if [[ "$MY_INPUT_PHYLIP_SWITCH" = "0" ]] || [[ "$MY_INPUT_PHYLIP_SWITCH" = "$(find . -name '*.phy' -type f | sed 's/\.\/\.\_.*//g')" ]]; then
	MY_PHYLIP_FILENAME="$(echo ./*.phy | sed 's/\.\/\.\_.*//g' | head -n1 | sed -n 's/.\///p')"	## Get name of PHYLIP datafile in current working directory. Usually there will only be one PHYLIP file in working directory corresponding to pyRAD output from SNP/RAD assembly in Phylip format.
else
	MY_PHYLIP_FILENAME="$MY_INPUT_PHYLIP_SWITCH"
fi


if [[ "$MY_SEARCH_ALGORITHM" = "rcluster" ]]; then

echo "## ALIGNMENT FILE ##
	alignment = $MY_PHYLIP_FILENAME;

	## BRANCHLENGTHS: linked | unlinked ##
	branchlengths = linked;

	## MODELS OF EVOLUTION for PartitionFinder: all | raxml | mrbayes | beast | <list> ##
	##              for PartitionFinderProtein: all_protein | <list> ##
	models = $MY_PF_EVOMODELS;

	# MODEL SELECCTION: AIC | AICc | BIC #
	model_selection = $MY_PF_MODSEL;

	## DATA BLOCKS: see manual for how to define ##
	[data_blocks]
	" > PF_top.tmp

echo "## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
	[schemes]
	search = rcluster;

	#user schemes go here if search=user. See manual for how to define.#
	" > PF_bottom.tmp

	cat ./PF_top.tmp ./*.newPartitions.txt ./PF_bottom.tmp > partition_finder.cfg  	## Make PartitionFinder configuration file.
	rm ./PF_top.tmp ./PF_bottom.tmp;  												## Remove unnecessary files.


if [[ "$MY_PF_RUN_SWITCH" -eq "1" ]]; then
############ STEP #3: RUN PartitionFinder ON THE DATA IN WORKING DIRECTORY
###### Find path to PartitionFinder version <PFversion> ($MY_PF_VERSION) and assign to variable:
#MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py' |  \
# sed -n 's/.://p')"
#MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py\|partitionfinder-1.1.1/PartitionFinder.py' | sed -n 's/.://p' |  sed 's/\ .*//g')"

	if [[ "$MY_PF_PATH" = "SEARCH" ]]; then 
		MY_PATH_TO_PARTITIONFINDER="$MY_PF_PATH"
	elif [[ "$MY_PF_PATH" != "SEARCH" ]] && [[ "$MY_PF_VERSION" -eq "1" ]]; then
		MY_PATH_TO_PARTITIONFINDER="$(locate *1.1.1*/PartitionFinder.py | head -n1)"
	elif [[ "$MY_PF_PATH" != "SEARCH" ]] && [[ "$MY_PF_VERSION" -eq "2" ]]; then
		MY_PATH_TO_PARTITIONFINDER="$(locate *2.1.1*/PartitionFinder.py | head -n1)"
	fi
	
python $MY_PATH_TO_PARTITIONFINDER . --raxml --rcluster-percent 0.1
fi


elif [[ "$MY_SEARCH_ALGORITHM" = "greedy" ]]; then

echo "## ALIGNMENT FILE ##
	alignment = $MY_PHYLIP_FILENAME;

	## BRANCHLENGTHS: linked | unlinked ##
	branchlengths = linked;

	## MODELS OF EVOLUTION for PartitionFinder: all | raxml | mrbayes | beast | <list> ##
	##              for PartitionFinderProtein: all_protein | <list> ##
	models = $MY_PF_EVOMODELS;

	# MODEL SELECCTION: AIC | AICc | BIC #
	model_selection = $MY_PF_MODSEL;

	## DATA BLOCKS: see manual for how to define ##
	[data_blocks]
	" > PF_top.tmp

echo "## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
	[schemes]
	search = greedy;

	#user schemes go here if search=user. See manual for how to define.#
	" > PF_bottom.tmp

	cat ./PF_top.tmp ./*.newPartitions.txt ./PF_bottom.tmp > partition_finder.cfg  	## Make PartitionFinder configuration file.
	rm ./PF_top.tmp ./PF_bottom.tmp;  												## Remove unnecessary files.


if [[ "$MY_PF_RUN_SWITCH" -eq "1" ]]; then
############ STEP #3: RUN PartitionFinder ON THE DATA IN WORKING DIRECTORY
###### Find path to PartitionFinder version <PFversion> ($MY_PF_VERSION) and assign to variable:
#MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py' |  \
# sed -n 's/.://p')"
#MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py\|partitionfinder-1.1.1/PartitionFinder.py' | sed -n 's/.://p' |  sed 's/\ .*//g')"

	if [[ "$MY_PF_PATH" = "SEARCH" ]]; then 
		MY_PATH_TO_PARTITIONFINDER="$MY_PF_PATH"
	elif [[ "$MY_PF_PATH" != "SEARCH" ]] && [[ "$MY_PF_VERSION" -eq "1" ]]; then
		MY_PATH_TO_PARTITIONFINDER="$(locate *1.1.1*/PartitionFinder.py | head -n1)"
	elif [[ "$MY_PF_PATH" != "SEARCH" ]] && [[ "$MY_PF_VERSION" -eq "2" ]]; then
		MY_PATH_TO_PARTITIONFINDER="$(locate *2.1.1*/PartitionFinder.py | head -n1)"
	fi

python $MY_PATH_TO_PARTITIONFINDER .
fi


elif [[ "$MY_SEARCH_ALGORITHM" = "hcluster" ]]; then

echo "## ALIGNMENT FILE ##
	alignment = $MY_PHYLIP_FILENAME;

	## BRANCHLENGTHS: linked | unlinked ##
	branchlengths = linked;

	## MODELS OF EVOLUTION for PartitionFinder: all | raxml | mrbayes | beast | <list> ##
	##              for PartitionFinderProtein: all_protein | <list> ##
	models = $MY_PF_EVOMODELS;

	# MODEL SELECCTION: AIC | AICc | BIC #
	model_selection = $MY_PF_MODSEL;

	## DATA BLOCKS: see manual for how to define ##
	[data_blocks]
	" > PF_top.tmp

echo "## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
	[schemes]
	search = hcluster;

	#user schemes go here if search=user. See manual for how to define.#
	" > PF_bottom.tmp

	cat ./PF_top.tmp ./*.newPartitions.txt ./PF_bottom.tmp > partition_finder.cfg  	## Make PartitionFinder configuration file.
	rm ./PF_top.tmp ./PF_bottom.tmp;  												## Remove unnecessary files.

if [[ "$MY_PF_RUN_SWITCH" -eq "1" ]]; then
############ STEP #3: RUN PartitionFinder ON THE DATA IN WORKING DIRECTORY
###### Find path to PartitionFinder version <PFversion> ($MY_PF_VERSION) and assign to variable:
#MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py' |  \
# sed -n 's/.://p')"
#MY_PATH_TO_PARTITIONFINDER="$(locate PartitionFinder.py | grep -n 'PartitionFinderV1.1.1_Mac/PartitionFinder.py\|partitionfinder-1.1.1/PartitionFinder.py' | sed -n 's/.://p' |  sed 's/\ .*//g')"

	if [[ "$MY_PF_PATH" = "SEARCH" ]]; then 
		MY_PATH_TO_PARTITIONFINDER="$MY_PF_PATH"
	elif [[ "$MY_PF_PATH" != "SEARCH" ]] && [[ "$MY_PF_VERSION" -eq "1" ]]; then
		MY_PATH_TO_PARTITIONFINDER="$(locate *1.1.1*/PartitionFinder.py | head -n1)"
	elif [[ "$MY_PF_PATH" != "SEARCH" ]] && [[ "$MY_PF_VERSION" -eq "2" ]]; then
		MY_PATH_TO_PARTITIONFINDER="$(locate *2.1.1*/PartitionFinder.py | head -n1)"
	fi

python $MY_PATH_TO_PARTITIONFINDER . --raxml

fi

fi


#
#
#
######################################### END ############################################

exit 0
