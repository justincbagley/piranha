##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                          BEASTPostProc v1.0, August 2016                               #
#   SHELL SCRIPT FOR POST-PROCESSING BEAST GENE & SPECIES TREES OUTPUT FILES ON A        #
#   SUPERCOMPUTING CLUSTER                                                               #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil.  #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information. Last update: August 3, 2016. For questions, please email        #
#   jcbagley@unb.br.                                                                     #
##########################################################################################

echo "
##########################################################################################
#                          BEASTPostProc v1.0, August 2016                               #
##########################################################################################
"

echo "INFO      | $(date) | STEP #1: SETUP VARIABLES & SUMMARIZE RUN LOG FILE. "
###### Set filetypes as different variables:
MY_STARBEAST_SPECIESTREE_FILE=./*.species.trees		## Assign *BEAST species tree file in run directory to variable.

MY_BEAST_GENETREE_FILES="$(ls | grep -n ".trees" \
| sed 's/[0-9]*://g' | sed '/.species.trees/ d')"		## Assign BEAST gene tree file in run directory to variable.

MY_STARBEAST_LOGFILE="$(ls | grep -n ".log" \
| sed 's/[0-9]*://g' | sed '/.mle.log/ d')"				## Assign *BEAST log file containing all logged reg run parameters in run directory to variable.

MY_MARGLIKE_LOGFILE=./*.mle.log					## Assign MLE log file in run directory to variable.

###### Summarize parameters from reg .log file in LogAnalyser (from BEAST v1.8.3):
###### LOGANALYSER v1.8.3 help menu (-help):
## Usage: loganalyser [-burnin <i>] [-short] [-hpd] [-ess] [-stdErr] [-marginal <trace_name>] [-help] [-burnin <burnin>] [-short][-hpd] [-std] [<input-file-name> [<output-file-name>]]
##  -burnin the number of states to be considered as 'burn-in'
##  -short use this option to produce a short report
##  -hpd use this option to produce hpds for each trace
##  -ess use this option to produce ESSs for each trace
##  -stdErr use this option to produce standard Error
##  -marginal specify the trace to use to calculate the marginal likelihood
##  -help option to print this message
## 
##  Example: loganalyser test.log
##  Example: loganalyser -burnin 10000 trees.log out.txt
#
##--LogAnalyser outputs the mean, standard error (stdErr), median, lower 95% highest 
##--posterior density bound (hpdLower), upper 95% HPD bound (hpdUpper), effective sample 
##--size (ESS), lower 50% HPD (50hpdLower), and upper 50% HPD (50hpdUpperfor) for all 
##--logged parameters present in a log file fed into the program, after discarding the 
##--amount of burnin specified by the user.
#
##--NOTE: As this step requires a burnin, users should look at their parameter traces in  
##--Tracer and identify a suitable burnin before proceeding. I often run BEAST/*BEAST for
##-->=10^7 or 10^8 generations per run; thus, suitable burnin values for me are around
##--25 to 50 million generations, or more. However, I usually log parameters every 4000 
##--steps, so when represented as the actual number of logged steps my burnin would 
##--normally take values between 6250 and 12500.

if [[ $MY_STARBEAST_LOGFILE ]]; then
	echo "INFO      | $(date) |         BEAST log file present. Analyzing log file in LogAnalyser..."
	/fslhome/bagle004/compute/BEASTv1.8.3_linux/bin/loganalyser -burnin 12500 $MY_STARBEAST_LOGFILE LogAnalyzer.out.txt
	## __PATH NEEDED__: If necessary, change start of the line above to include the absolute path to the "loganalyser" executable on your machine, or to just specify the executable name if it is already in your path. 
else
	echo "WARNING!  | $(date) |         Something went wrong. Found no BEAST log files. "
fi


###### Also summarize parameters from ".mle.log" (marginal likelihood estimation) log file, if present, in LogAnalyser (from BEAST v1.8.3):
if [[ $MY_MARGLIKE_LOGFILE ]]; then
	echo "INFO      | $(date) |         Marginal likelihood estimation analysis log file present. Analyzing mle log file in LogAnalyser..."
	/fslhome/bagle004/compute/BEASTv1.8.3_linux/bin/loganalyser -burnin 10000 $MY_MARGLIKE_LOGFILE MLE.LogAnalyzer.out.txt
else
	echo "WARNING!  | $(date) |         Found no marginal likelihood estimation analysis log files. Moving on... "
fi


echo "INFO      | $(date) | STEP #2: SPECIES TREE ANALYSIS. "
###### First step is to get 5000 random post-burnin species trees from the posterior distribution of trees:
if [[ $MY_STARBEAST_SPECIESTREE_FILE ]]; then
	echo "INFO      | $(date) |         BEAST species trees present. Analyzing species trees in TreeAnnotator..."

(
for i in $MY_STARBEAST_SPECIESTREE_FILE; do 
	echo $i
	tail -n 5000 ${i} > ${i}_5k_postburn.trees		## OPTION #1 (preferred)
								## OPTION #2 - use AWK (This is for getting lines of the .species.trees file corresponding to a specific range of trees starting at MCMC generation ~55 million and going for the next 5000 logged trees, assuming trees were logged every 4000):
								## awk 'FNR>=13750 && FNR<=18751' $MY_STARBEAST_SPECIESTREE_FILE >  5k_postburn.species.trees
								## NOTE: The above works like this: 55 million as the starting generation, do 55x10^6/4000=13750, gets you the starting point; stop point (# on right) is calculated by simply adding 5000 to the first number.

###### Convert your 5000 post-burnin species trees into NEXUS tree file format:
	MY_NTAX="$(grep -n "Dimensions" \
	$i | \
	awk -F"=" '{print $NF}' | sed 's/\;//g')"		## Pull the number of taxa from the species trees file.
#
## Make the "handy bash function 'calc'" for subsequent use.
calc () {
    	bc -l <<< "$@"
	}
#
	MY_HEADER_LENGTH="$(calc 2*$MY_NTAX + 11)"		## Use calc to get appropriate NEXUS header length and store it in variable.
	head -n $MY_HEADER_LENGTH $i > nexusHeader.txt
	cat nexusHeader.txt ${i}_5k_postburn.trees > ${i}_5k_postburn.trees.txt

###### Cleanup by removing any line starting with "==> " (preferred), OR remove line 1 and line $(calc $MY_HEADER_LENGTH + 1) (not preferred)
	sed '/^==>\ / d' ${i}_5k_postburn.trees.txt > ${i}_final_5k.trees
	rm ${i}_5k_postburn.trees 
	rm nexusHeader.txt 
	rm ${i}_5k_postburn.trees.txt


###### SUMMARIZE POSTERIOR DISTRIBUTION OF SPECIES TREES USING TREEANNOTATOR
###### TREEANNOTATOR v1.8.3 HELP:
## Usage: treeannotator [-heights <keep|median|mean|ca>] [-burnin <i>] [-burninTrees <i>] [-limit <r>] [-target <target_file_name>] [-help] [-forceDiscrete] [-hpd2D <the HPD interval to be used for the bivariate traits>] <input-file-name> [<output-file-name>]
##  -heights an option of 'keep' (default), 'median', 'mean' or 'ca'
##  -burnin the number of states to be considered as 'burn-in'
##  -burninTrees the number of trees to be considered as 'burn-in'
##  -limit the minimum posterior probability for a node to be annotated
##  -target specifies a user target tree to be annotated
##  -help option to print this message
##  -forceDiscrete forces integer traits to be treated as discrete traits.
##  -hpd2D specifies a (vector of comma seperated) HPD proportion(s)
## 
## Example: treeannotator test.trees out.txt
## Example: treeannotator -burnin 100 -heights mean test.trees out.txt
## Example: treeannotator -burnin 100 -target map.tree test.trees out.txt

/fslhome/bagle004/compute/BEASTv1.8.3_linux/bin/treeannotator -burnin 0 -heights mean ${i}_final_5k.trees ${i}.treeannotator.out
## __PATH NEEDED__: If necessary, change start of this line to include the absolute path to the "treeannotator" executable on your machine, or to just specify the executable name if it is already in your path. 

## NOTE: If you are pointing to a treeannotator executable from BEAST2 (any version), you may get a Java error here saying you need to update to the latest version of Java (e.g. from v6 to v8).

mkdir ${i}.treeannotator
mv ${i}.treeannotator.out ./${i}.treeannotator

done
)

###### Rename species tree files:
(
	shopt -s nullglob
	files=(./*_final_5k.trees)
	if [[ "${#files[@]}" -gt 0 ]] ; then
		echo "INFO      | $(date) |         Renaming final 5k post-burnin species tree files."
#+
        for j in ./*.species.trees_final_5k.trees
            do
            mv $j ${j/*/final_5k.species.trees}
        done
#+
    else
        echo "WARNING!  | $(date) |         Failed to rename final 5k post-burnin species tree files."
    fi
)

###### Rename treeannotator output folders:
(
	shopt -s nullglob
	folders=(./*.treeannotator)
	if [[ "${#folders[@]}" -gt 0 ]] ; then
		echo "INFO      | $(date) |         Step #3 succeeded. Renaming folders with TreeAnnotator species tree results."
#+
		for k in ./*.species.trees.treeannotator
			do
			mv $k ${k/*/treeannotator.species.tree}
		done
#+
	else
		echo "WARNING!  | $(date) |         Step #3 failed. Found no folders with TreeAnnotator species tree results."
	fi
)

###### Rename treeannotator output species tree file:
    for l in ./treeannotator.species.tree/*.treeannotator.out
        do
        mv $l ${l/*/MCC.species.tree.out}
    done
        mv MCC.species.tree.out ./treeannotator.species.tree




else
	echo "INFO      | $(date) |         Found no BEAST species trees. Skipping species tree analysis... "
fi




###################### END OF STEP #2 / SPECIES TREE ANALYSIS ############################





echo "INFO      | $(date) |  STEP #3: GENE TREE ANALYSIS. "
###### First step is to get 5000 random post-burnin gene trees from the posterior distribution of trees:
if [[ $MY_BEAST_GENETREE_FILES ]]; then
	echo "INFO      | $(date) |         BEAST gene trees present for one or multiple partitions. Analyzing gene trees in TreeAnnotator..."

(
for m in ${MY_BEAST_GENETREE_FILES}
	do 
	echo $m
	tail -n 5000 ${m} > ${m}_5k_postburn.trees		
													## OPTION #2 - use AWK (This is for getting lines of the .trees file corresponding to a specific range of trees starting at MCMC generation ~55 million and going for the next 5000 logged trees, assuming trees were logged every 4000):
													## awk 'FNR>=13750 && FNR<=18751' $MY_BEAST_GENETREE_FILE >  5k_postburn.$partitionname.gene.trees
													## NOTE: The above works like this: 55 million as the starting generation, do 55x10^6/4000=13750, gets you the starting point; stop point (# on right) is calculated by simply adding 5000 to the first number.

###### Convert your 5000 post-burnin gene trees into NEXUS tree file format:
	MY_NTAX="$(grep -n "Dimensions" \
	$m | \
	awk -F"=" '{print $NF}' | sed 's/\;//g')"		
#
	calc () {										
    	bc -l <<< "$@"
	}
#
	MY_HEADER_LENGTH="$(calc 2*$MY_NTAX + 11)"		
	head -n $MY_HEADER_LENGTH $m > nexusHeader.txt
	cat nexusHeader.txt ${m}_5k_postburn.trees > ${m}_5k_postburn.trees.txt

###### Cleanup: Next, remove any line starting with "==> " (preferred), OR remove line 1 and line $(calc $MY_HEADER_LENGTH + 1) (not preferred)
	sed '/^==>\ / d' ${m}_5k_postburn.trees.txt > ${m}_final_5k.trees
	rm ${m}_5k_postburn.trees 
	rm nexusHeader.txt 
	rm ${m}_5k_postburn.trees.txt


###### SUMMARIZE POSTERIOR DISTRIBUTION OF GENE TREES USING TREEANNOTATOR
/fslhome/bagle004/compute/BEASTv1.8.3_linux/bin/treeannotator -burnin 0 -heights mean ${m}_final_5k.trees ${m}.treeannotator.out
## __PATH NEEDED__: If necessary, change start of this line to include the absolute path to the "treeannotator" executable on your machine, or to just specify the executable name if it is already in your path. 

###### Change name of annotated tree file output by TreeAnnotator for this gene/partition:
partitionname="$(echo $m | sed 's/^[a-zA-Z0-9\_]*\.//g' | sed 's/\.trees//g')"
mv ./*.treeannotator.out ./MCC.${partitionname}.gene.tree.out

###### Make new directory for TreeAnnotator results for this gene/partition, with the
###### desired name, and then move the TreeAnnotator results into the new folder:
mkdir ./treeannotator.${partitionname}.gene.tree
mv ./MCC.${partitionname}.gene.tree.out ./treeannotator.${partitionname}.gene.tree

mv ${m}_final_5k.trees ./final_5k.${partitionname}.gene.trees

done
)

else
	echo "INFO      | $(date) |         Found no BEAST gene trees. Skipping gene tree analysis... "
fi



echo "INFO      | $(date) | Done processing BEAST results. "
echo "Bye.
"
#
#
#
######################################### END ############################################

exit 0
