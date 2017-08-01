#!/bin/bash

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                       Super-pyRAD2PartitionFinder v1.0, May 2016                       #
#   SHELL SCRIPT FOR RUNNING SNP DATA IN PartitionFinder ON BYU FSL CLUSTER MARYLOU      #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: May 3, 2017.  #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

#PBS -l nodes=1:ppn=1,pmem=1gb,walltime=168:00:00           ## Not all supercomputing clusters allow a walltime this large; check with your IT/supercomputer website or personnel to get the maximum walltime allowed on your cluster.
#PBS -N <OUTPUT_NAME>
#PBS -m abe
#PBS -M <USER_EMAIL_ADDRESS>

OUTFILE="Hasemania_RAD_PartitionFinder_run1.out.txt"

cd $PBS_O_WORKDIR

  > "$OUTFILE"


echo "
##########################################################################################
#                      Super-pyRAD2PartitionFinder v1.0, July 2016                       #
##########################################################################################"

############ STEP #1: MODIFY pyRAD DATAFILE FOR PartitionFinder
MY_PYRAD_PARTITION=./*.partitions           				## Assign "partition" files in current directory to variable.
MY_PHYLIP_FILE=./*.phy                      				## Assign PHYLIP SNP datafiles in current directory to variable.

###### FORMAT pyRAD PARTITION FILE FOR PartitionFinder: 
(
	for i in $MY_PYRAD_PARTITION; do                					## Look in the current directory for partition scheme files output by pyRAD.
		echo "$i"
		sed 's/^DNA..//g' ${i} > ${i}_1.tmp						## Reformatting using nested for loops.
			for j in ${i}_1.tmp; do
				echo "$j"
				sed 's/$/;/' ${j} > ${j}.PFparts.txt 
			done
		for k in *.partitions_1.tmp.PFparts.txt; do
			mv $k ${k/.partitions_1.tmp.PFparts.txt/.newPartitions.txt}
		done							## Line above renames the output.
	done
)
	rm *_1.tmp	## Remove unnecessary files.


############ STEP #2: PREPARE PartitionFinder CONFIGURATION FILE
MY_PHYLIP_FILENAME="$(echo ./*.phy | sed -n 's/.\///p')"				## Get name of PHYLIP file with our data. Assumes only one PHYLIP file in working directory corresponding to pyRAD output of SNP/RAD assembly in phylip format.

echo "## ALIGNMENT FILE ##
	alignment = $MY_PHYLIP_FILENAME;

	## BRANCHLENGTHS: linked | unlinked ##
	branchlengths = linked;

	## MODELS OF EVOLUTION for PartitionFinder: all | raxml | mrbayes | beast | <list> ##
	##              for PartitionFinderProtein: all_protein | <list> ##
	models = all;

	# MODEL SELECCTION: AIC | AICc | BIC #
	model_selection = BIC;

	## DATA BLOCKS: see manual for how to define ##
	[data_blocks]" > PF_top.tmp

echo "## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
	[schemes]
	search = greedy;

	#user schemes go here if search=user. See manual for how to define.#
	" > PF_bottom.tmp

	cat ./PF_top.tmp ./*.newPartitions.txt ./PF_bottom.tmp > partition_finder.cfg  		## Make PartitionFinder configuration file.
	rm ./PF_top.tmp ./PF_bottom.tmp;  							## Remove unnecessary files.


############ STEP #3: RUN PartitionFinder ON THE DATA IN WORKING DIRECTORY
###### Setup modules on supercomputer:
	module purge										## Clear any previously loaded modules.
	module load python/2/7									## Load Python 2.7, which is compatible with most recent version of PartitionFinder.

###### For Linux supercomputer clusters, use the following code to assign PartitionFinder path to variable and run:
##--a (not preferred): MY_PATH_TO_PARTITIONFINDER_ON_LINUX="$(which PartitionFinder.py)"
##--b (preferred): 
	MY_WORKING_DIRECTORY=$(pwd)
	MY_PATH_TO_PARTITIONFINDER_ON_LINUX=/fslhome/bagle004/bin/PartitionFinderV1.1.1_Mac/PartitionFinder.py
	## __PATH NEEDED__: Change the path to PartitionFinder.py listed above to the appropriate path on your machine or supercomputer cluster, if necessary.

	python $MY_PATH_TO_PARTITIONFINDER_ON_LINUX $MY_WORKING_DIRECTORY			## Previously, for my local machine, this line was as follows: "python /Applications/PartitionFinderV1.1.1_Mac/PartitionFinder.py ."
#
#
#
######################################### END ############################################

$PROG $ARGS

exit 0 
