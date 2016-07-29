#!/bin/sh

##########################################################################################
# <><PIrANHA              ExaBayesPostProc v1.0, July 2016                               #
#   SHELL SCRIPT FOR POST-PROCESSING OF ExaBayes OUTPUT FILES                            #
#   SUPERCOMPUTING CLUSTER                                                               #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: July 15, 2016. For questions, please email         #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

############ STEP #1: CALL PROGRAMS TO DO ExaBayes POST-PROCESSING
MY_EXABAYES_TREEFILES=./ExaBayes_topologies.*	## Assign "topologies" files in current directory to variable.
MY_EXABAYES_PARAMFILES=./ExaBayes_parameters.*	## Assign "parameters" files in current directory to variable.

###### RUN SUMMARY: coming soon...

###### TREE SUMMARY: 
###### Get 50% percentile credible set of trees from ExaBayes analysis:
for i in $MY_EXABAYES_TREEFILES #This looks in the current directory for tree files output by ExaBayes to use as input files for the following operations.
	do 
	echo $i
	credibleSet -n 50cred.out.txt -f ${i} -c 50	## __PATH NEEDED__: Add path to credibleSet at start of this line, if not in your path already.
done

###### Get bipartitions, plus branch lengths & ESS scores for all bipartitions, of ExaBayes trees:
for i in $MY_EXABAYES_TREEFILES
	do 
	echo $i
	extractBips -n out.txt -f ${i} -b 0.25		## __PATH NEEDED__: Add path to extractBips at start of this line, if not in your path already.
done

###### PARAMETERS SUMMARY: 
###### Summarize parameters of each run using postProcParam utility:
for j in $MY_EXABAYES_PARAMFILES #This looks in the current directory for tree files output by ExaBayes to use as input files for the following operations.
	do 
	echo $j
	postProcParam -n out.txt -f ${j} -b 0.25	## __PATH NEEDED__: Add path to postProcParam at start of this line, if not in your path already.
done


############ STEP #2: REFORMAT (FOR) & PROCESS ExaBayes OUTPUT FILES IN MrBayes
for k in ./ExaBayes_topologies.*
	do 
	echo $k
	sed 's/.{.}//g' ${k} > ${k}_1.tmp
		sed 's/:0.0;/;/g' ${k}_1.tmp > ${k}.t
done

for l in *.t
	do
	mv $l ${l/.0.t/.run1.t}
	mv $l ${l/.1.t/.run2.t}
#	mv $l ${l/.2.t/.run2.t}						## __UNCOMMENT THESE NEXT LINES AS NEEDED__, according to number of tree files you are starting with, by uncommenting 1 line for each subsequent tree file beyond two runs.
#	mv $l ${l/.3.t/.run2.t}
#	mv $l ${l/.4.t/.run2.t}
done

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


############ STEP #3: CLEANUP FILES
rm *_1.tmp batch.txt							## Remove temporary files created above.
#
#
#
######################################### END ############################################

exit 0
