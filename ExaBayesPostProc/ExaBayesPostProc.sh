#!/bin/sh

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        #
# |                                                                                      #
#                      ExaBayesPostProc v1.1, September 2017                             #
#  SHELL SCRIPT THAT AUTOMATES POST-PROCESSING OF ExaBayes OUTPUT FILES                  #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: September 7, 2017. For questions, please email bagleyj@umsl.edu.              #
##########################################################################################

echo "
##########################################################################################
#                      ExaBayesPostProc v1.1, September 2017                             #
##########################################################################################
"

echo "INFO      | $(date) | STEP #1: CALL PROGRAMS TO DO ExaBayes POST-PROCESSING. "
	MY_EXABAYES_TREEFILES=./ExaBayes_topologies.*	## Assign "topologies" files in current directory to variable.
	MY_EXABAYES_PARAMFILES=./ExaBayes_parameters.*	## Assign "parameters" files in current directory to variable.

###### RUN SUMMARY: coming soon...

echo "INFO      | $(date) |         TREE SUMMARY: "
echo "INFO      | $(date) |         Getting 50% percentile credible set of trees from ExaBayes analysis... "
(
	for i in $MY_EXABAYES_TREEFILES; do 			## This looks in the current directory for tree files output by ExaBayes to use as input files for the following operations.
		echo $i
		credibleSet -n 50cred.out.txt -f ${i} -c 50	## __PATH NEEDED__: Add path to credibleSet at start of this line, if not in your path already.
	done
)

###### Get bipartitions, plus branch lengths & ESS scores for all bipartitions, of ExaBayes trees:
(
	for i in $MY_EXABAYES_TREEFILES; do 
		echo $i
		extractBips -n out.txt -f ${i} -b 0.25		## __PATH NEEDED__: Add path to extractBips at start of this line, if not in your path already.
	done
)

###### PARAMETERS SUMMARY: 
###### Summarize parameters of each run using postProcParam utility:
(
	for j in $MY_EXABAYES_PARAMFILES; do 				## This looks in the current directory for tree files output by ExaBayes to use as input files for the following operations.
		echo $j
		postProcParam -n out.txt -f ${j} -b 0.25	## __PATH NEEDED__: Add path to postProcParam at start of this line, if not in your path already.
	done
)

echo "INFO      | $(date) | STEP #2: REFORMAT (FOR) & PROCESS ExaBayes OUTPUT FILES IN MrBayes. "
(
	for k in ./ExaBayes_topologies.*; do 
		echo $k
		sed 's/.{.}//g' ${k} > ${k}_1.tmp
			sed 's/:0.0;/;/g' ${k}_1.tmp > ${k}.t
	done
)

(
	for l in *.t
		do
		mv $l ${l/.0.t/.run1.t}
		mv $l ${l/.1.t/.run2.t}
	#	mv $l ${l/.2.t/.run2.t}						## __UNCOMMENT THESE NEXT LINES AS NEEDED__, according to number of tree files you are starting with, by uncommenting 1 line for each subsequent tree file beyond two runs.
	#	mv $l ${l/.3.t/.run2.t}
	#	mv $l ${l/.4.t/.run2.t}
	done
)

###### Prep files and then Summarize trees, their posterior probabilities, and their errors using MrBayes.
	MY_NEXUS=./*.nex
	MY_NEXUS_FILENAME="$(echo ./*.nex | sed -n 's/.\///p')"		## Assumes only one NEXUS file in working directory corresponding to ExaBayes run input file.
	MY_MRBAYES_FILENAME="$(ls | sed -n 's/\.0$//p' | grep -n "topologies" | sed -n 's/.://p')"
	##--Note: If you want to check the above variables, do: echo $MY_NEXUS_FILENAME; echo $MY_MRBAYES_FILENAME;

###### Create batch file:
echo "set autoclose=yes nowarn=yes
execute ${MY_NEXUS_FILENAME}
sumt Filename=${MY_MRBAYES_FILENAME} relburnin=yes burninfrac= 0.25
quit" > ./batch.txt

	
	mb <./batch.txt > Mrbayes_sumt_log.txt &		## Use batch to run MrBayes.


echo "INFO      | $(date) | STEP #3: CLEANUP FILES. "
	rm *_1.tmp batch.txt							## Remove temporary files created above.


echo "INFO      | $(date) | Done post-processing ExaBayes results. "
echo "INFO      | $(date) | Bye. 
"
#
#
#
######################################### END ############################################

exit 0
