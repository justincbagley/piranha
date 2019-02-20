#!/bin/sh

##########################################################################################
#                     MAGNET ~ MAny GeNE Trees v0.1.9, February 2019                     #
#  SHELL PIPELINE FOR AUTOMATING ESTIMATION OF ONE MAXIMUM-LIKELIHOOD (ML) GENE TREE IN  #
#  RAxML FOR EACH OF MANY LOCI IN A RADseq OR MULTILOCUS SEQUENCE DATASET                #
#  Copyright ©2019 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: February 19, 2019. For questions, please email bagleyj@umsl.edu.              #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
STARTING_FILE_TYPE=1
MY_NUM_BOOTREPS=100
MY_RAXML_MODEL=GTRGAMMA
MY_SIMPLE_MODEL=NULL
MY_GAP_THRESHOLD=0.001
MY_INDIV_MISSING_DATA=1
MY_OUTGROUP=NULL
MY_OUTPUT_NAME=raxml_out
MY_RESUME_SWITCH=0

## Set raxml executable name depending on machine type:
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
if [[ "${machine}" = "Mac" ]]; then
	MY_RAXML_EXECUTABLE=raxml
fi
if [[ "${machine}" = "Linux" ]]; then
	MY_RAXML_EXECUTABLE=raxmlHPC-SSE3
fi

############ CREATE USAGE & HELP TEXTS
Usage="Usage: $(basename "$0") [Help: -h H] [Options: -f e b r s g m o] [Resume: --resume] [stdin:] inputFile OR workingDir
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -f   fileType (def: 1; 1 = single inputFile, 2 = multiple PHYLIP files) starting file
       type; if 1, script expects as stdin a single NEXUS or G-PhoCS inputFile in the
       current directory; if 2, then script expects workingDir with multiple PHYLIP files
  -e   executable (def: $MY_RAXML_EXECUTABLE) name of RAxML executable, accessible from command line
       on user's machine
  -b   numBootstraps (def: $MY_NUM_BOOTREPS) RAxML bootstrap pseudoreplicates
  -r   raxmlModel (def: $MY_RAXML_MODEL; other: GTRGAMMAI, GTRCAT, GTRCATI)
  -s   simpleModel (def: $MY_SIMPLE_MODEL; other: JC69, K80, HKY85) specifies simple substitution model
       that will override any other model and apply to all DNA partitions
  -g   gapThreshold (def: $MY_GAP_THRESHOLD=essentially zero gaps allowed unless >1000 
       individuals; takes float proportion value)
  -m   indivMissingData (def: $MY_INDIV_MISSING_DATA=allowed; 0=removed)
  -o   outgroup (def: NULL) outgroup given as single taxon name (tip label) or comma-
       separted list

 ## Resume: 
 --resume   long option allowing the user to resume a previous MAGNET run in the specified
       workingDir (usually current working directory)
 
 OVERVIEW
 The goal of MAGNET is to infer a maximum-likelihood (ML) gene tree in RAxML for each of 
 multiple loci, starting from one or multiple input files containing aligned DNA sequences.
 If supplied with a single G-PhoCS ('*.gphocs') or NEXUS ('*.nex') data file (using -f 1
 option), then this script splits each locus into a separate PHYLIP-formatted alignment file, 
 and sets up and runs RAxML (Stamatakis 2014) to infer gene trees for each locus. If a NEXUS 
 datafile is supplied, it is converted into G-PhoCS format (Gronau et al. 2011) while splitting
 loci into separate interleaved sequence blocks based on information provided in a sets
 block at the end of the NEXUS file (e.g. defined using 'charset' commands), which is mandatory. 
 However, if -f 2, then the program expects as standard input the name of a working directory 
 (e.g. the relative or absolute path) containing multiple PHYLIP-formatted alignment files. 
 Under this scenario, MAGNET will skip directly to running the PHYLIP files in RAxML using 
 user-specified options. Sequence names may not include hyphen characters, or there could be 
 issues. For detailed information on MAGNET and its various dependencies, see 'README.md' file 
 in the distribution folder; however, it is key that the dependencies are available from the 
 command line interface. Among the most important options is --resume (off by default), which 
 tells MAGNET to resume a previous run in <workingDir>, including detecting incomplete run 
 folders and running RAxML there without overwriting results from previously finished runs.

 CITATION
 Bagley, J.C. 2017. MAGNET v0.1.6. GitHub package, Available at: 
	<http://github.com/justincbagley/MAGNET>.
 or
 Bagley, J.C. 2017. MAGNET v0.1.6. GitHub package, Available at: 
	<http://doi.org/10.5281/zenodo.166024>.

 REFERENCES
 Gronau I, Hubisz MJ, Gulko B, Danko CG, Siepel A (2011) Bayesian inference of ancient human 
	demography from individual genome sequences. Nature Genetics, 43, 1031-1034.
 Stamatakis A (2014) RAxML version 8: a tool for phylogenetic analysis and post-analysis of 
	large phylogenies. Bioinformatics, 30, 1312-1313.
"


verboseHelp="Usage: $(basename "$0") [Help: -h H] [Options: -f e b r s g m o] [Resume: --resume] [stdin:] inputFile or workingDir
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -f   fileType (def: 1; 1 = single inputFile, 2 = multiple PHYLIP files) starting file
       type; if 1, script expects as stdin a single NEXUS or G-PhoCS inputFile in the
       current directory; if 2, then script expects workingDir with multiple PHYLIP files
  -e   executable (def: $MY_RAXML_EXECUTABLE) name of RAxML executable, accessible from command line
       on user's machine
  -b   numBootstraps (def: $MY_NUM_BOOTREPS) RAxML bootstrap pseudoreplicates
  -r   raxmlModel (def: $MY_RAXML_MODEL; other: GTRGAMMAI, GTRCAT, GTRCATI)
  -s   simpleModel (def: $MY_SIMPLE_MODEL; other: JC69, K80) specifies simple substitution model
       that will override any other model and apply to all DNA partitions
  -g   gapThreshold (def: $MY_GAP_THRESHOLD=essentially zero gaps allowed unless >1000 
       individuals; takes float proportion value)
  -m   indivMissingData (def: $MY_INDIV_MISSING_DATA=allowed; 0=removed)
  -o   outgroup (def: NULL) outgroup given as single taxon name (tip label) or comma-
       separted list

 ## Resume: 
 --resume   long option allowing the user to resume a previous MAGNET run in the specified
       workingDir (usually current working directory)

 OVERVIEW
 The goal of MAGNET is to infer a maximum-likelihood (ML) gene tree in RAxML for each of 
 multiple loci, starting from one or multiple input files containing aligned DNA sequences.
 If supplied with a single G-PhoCS ('*.gphocs') or NEXUS ('*.nex') data file (using -f 1
 option), then this script splits each locus into a separate PHYLIP-formatted alignment file, 
 and sets up and runs RAxML (Stamatakis 2014) to infer gene trees for each locus. If a NEXUS 
 datafile is supplied, it is converted into G-PhoCS format (Gronau et al. 2011) while splitting
 loci into separate interleaved sequence blocks based on information provided in a sets
 block at the end of the NEXUS file (e.g. defined using 'charset' commands), which is mandatory. 
 However, if -f 2, then the program expects as standard input the name of a working directory 
 (e.g. the relative or absolute path) containing multiple PHYLIP-formatted alignment files. 
 Under this scenario, MAGNET will skip directly to running the PHYLIP files in RAxML using 
 user-specified options. Sequence names may not include hyphen characters, or there could be 
 issues. For detailed information on MAGNET and its various dependencies, see 'README.md' file 
 in the distribution folder; however, it is key that the dependencies are available from the 
 command line interface. Among the most important options is the --resume flag (see below).

 DETAILS
 The -f flag specifies the starting fileType. If -f 1, then the mandatory input is the name
 or path to the corresponding starting file, which will be run in the current working directory. 
 If -f 2, then mandatory input is the name or path to the working directory (type '.' for current 
 directory, or supply a relative or absolute path).
 
 The -e flag sets the name of the RAxML executable that will be called. The user may wish to
 change this to something specific to their install, or to something generic like 'raxml'.
 The default setting should work on local machine or supercomputing cluster installs.
 
 The -b flag sets the number of boostrap pseudoreplicates for RAxML to perform while estimating 
 the gene tree for each locus. The default is 100; remove bootstrapping by setting to 0.

 The -r flag sets the RAxML model for each locus. This uses the full default GTRGAMMA model,
 and at present it is not possible to vary the model across loci. If you want to use HKY
 or K80, you will need to use the -s flag (below).

 The -s flag sets a simple RAxML model for each locus/partition, which will override any
 model set using the -r flag above and apply to all partitions. In the current version of 
 RAxML, it is possible to specify the JC69, K80, and HKY85 models as overrides. By default,
 this option is turned off and the model set under the -r flag is used instead.

 The following two options are available **ONLY** if you are starting from a NEXUS input file:

	The -g flag supplies a 'gap threshold' to an R script, which deletes all column sites in 
	the DNA alignment with a proportion of gap characters '-' at or above the threshold value. 
	If no gap threshold is specified, all sites with gaps are removed by default. If end goal
	is to produce a file for G-PhoCS, you  will want to leave gapThreshold at the default. 
	However, if the next step in your pipeline involves converting from .gphocs to other data 
	formats, you will likely want to set gapThreshold=1 (e.g. before converting to PHYLIP 
	format for RAxML). 

	The -m flag allows users to choose their level of tolerance for individuals with missing
	data. The default is indivMissingData=1, allowing individuals with runs of 10 or more 
	missing nucleotide characters ('N') to be kept in the alignment. Alternatively, setting
	indivMissingData=0 removes all such individuals from each locus; thus, while the input
	file would have had the same number of individuals across loci, the resulting file could
	have varying numbers of individuals for different loci.

 The -o flag sets the outgroup exactly the same way as that described in the RAxML v8 user's
 manual, as a single name or as a comma-separated list with no spaces between taxon names. 
 The first name in the list is prioritized, e.g. when members of the list are not monophyletic.

 --resume is among the most important options available in MAGNET because it tells the program 
 to resume a previous run in <workingDir>, including to detect incomplete run folders
 and run RAxML there without overwriting results from run folders with finished runs. Only
 takes --resume, not resume or -resume. The default setting is to run without this option.
 
 CITATION
 Bagley, J.C. 2017. MAGNET v0.1.6. GitHub package, Available at: 
	<http://github.com/justincbagley/MAGNET>.
 or
 Bagley, J.C. 2017. MAGNET v0.1.6. GitHub package, Available at: 
	<http://doi.org/10.5281/zenodo.166024>.

 REFERENCES
 Gronau I, Hubisz MJ, Gulko B, Danko CG, Siepel A (2011) Bayesian inference of ancient human 
	demography from individual genome sequences. Nature Genetics, 43, 1031-1034.
 Stamatakis A (2014) RAxML version 8: a tool for phylogenetic analysis and post-analysis of 
	large phylogenies. Bioinformatics, 30, 1312-1313.
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
## Idea for long option hyphen in getopts came from suggestions at the following thread
## URL: https://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options
while getopts 'f:e:b:r:s:g:m:o:-:' opt ; do
  case $opt in

## MAGNET, input datafile, and RAxML options:
    f) STARTING_FILE_TYPE=$OPTARG ;;
    e) MY_RAXML_EXECUTABLE=$OPTARG ;;
    b) MY_NUM_BOOTREPS=$OPTARG ;;
    r) MY_RAXML_MODEL=$OPTARG ;;
    s) MY_SIMPLE_MODEL=$OPTARG ;;
    g) MY_GAP_THRESHOLD=$OPTARG ;;
    m) MY_INDIV_MISSING_DATA=$OPTARG ;;
    o) MY_OUTGROUP=$OPTARG ;;
	-) LONG_OPTARG="${OPTARG#*=}"
         case $OPTARG in
         resume) MY_RESUME_SWITCH=1 ;;
         esac ;;
## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
echo "$Usage"
  exit 1
fi
## MY_NEXUS="$1"


echo "
##########################################################################################
#                     MAGNET ~ MAny GeNE Trees v0.1.9, February 2019                     #
##########################################################################################
"

############################## IF -f 1: SINGLE FILE RUN ##################################
##########################################################################################

#######
if [[ "$STARTING_FILE_TYPE" = "1" ]]; then
MY_NEXUS="$1"

######################################## START ###########################################
echo "INFO      | $(date) | Starting MAGNET pipeline... "
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Set paths and filetypes as different variables:
	MY_WORKING_DIR="$(pwd)"
	echo "INFO      | $(date) |          Setting working directory to: "
	echo "$MY_WORKING_DIR "	
	CR=$(printf '\r')
	calc () {
	   	bc -l <<< "$@"
	}


echo "INFO      | $(date) | STEP #2: INPUT (SINGLE NEXUS/G-PhoCS FILE, OR MULTIPLE PHYLIP FILES). "
echo "INFO      | $(date) |          For -f 1 or -f 2f '.gphocs' input file present, continue; else convert NEXUS file to "
echo "INFO      | $(date) |          G-PhoCS format using NEXUS2gphocs code. If -f 3, then run multiple PHYLIP files in  "
echo "INFO      | $(date) |          RAxML."
shopt -s nullglob
if [[ -n $(find . -name "*.gphocs" -type f) ]]; then
	echo "INFO      | $(date) |          Found '.gphocs' input file... "
    MY_GPHOCS_DATA_FILE=./*.gphocs		## Assign G-PhoCS-formatted genomic/SNP data file (originally produced/output by pyRAD) in run directory to variable.
else
    echo "WARNING!  | $(date) |          No '.gphocs' input file in current working directory... "
    echo "INFO      | $(date) |          Attempting to convert NEXUS file, if present, to GPho-CS format... "
fi


	#################################### NEXUS2gphocs.sh #####################################

	NEXUS2gphocs_function () {

	############ GET NEXUS FILE & DATA CHARACTERISTICS, CONVERT NEXUS TO FASTA FORMAT
	##--Extract charset info from sets block at end of NEXUS file: 
	MY_NEXUS_CHARSETS="$(egrep "charset|CHARSET" $MY_NEXUS | \
	awk -F"=" '{print $NF}' | sed 's/\;/\,/g' | \
	awk '{a[NR]=$0} END {for (i=1;i<NR;i++) print a[i];sub(/.$/,"",a[NR]);print a[NR]}' | \
	sed 's/\,/\,'$CR'/g' | sed 's/^\ //g')"
	
	##--Count number of loci present in the NEXUS file, based on number of charsets defined.
	##--Also get corrected count starting from 0 for numbering loci below...
	MY_NLOCI="$(echo "$MY_NEXUS_CHARSETS" | wc -l)"
	MY_CORR_NLOCI="$(calc $MY_NLOCI - 1)"
	
	##--This is the base name of the original nexus file, so you have it. This will not work if NEXUS file name is written in all caps, ".NEX", in the file name.
	MY_NEXUS_BASENAME="$(echo $MY_NEXUS | sed 's/\.\///g; s/\.nex//g')"
	
	##--Convert data file from NEXUS to fasta format using bioscripts.convert v0.4 Python package:
	##--However, if alignment is too long (>100,000 bp), then need to convert to fasta using my 
	##--script and then wrap to 60 characters with fold function (as suggested at stackexchange
	##--post URL: https://unix.stackexchange.com/questions/25173/how-can-i-wrap-text-at-a-certain-column-size).
	##--If this conversion failes because the alignment is too long, then the code to follow 
	##--will have nothing to work with. So, I am here adding a conditional quit if the fasta
	##--file is not generated.

	#---------ADD IF/THEN CONDITIONAL AND MY OWN NEXUS2fasta SCRIPT HERE!!!!----------#
	convbioseq fasta $MY_NEXUS > "$MY_NEXUS_BASENAME".fasta
	MY_FASTA="$(echo "$MY_NEXUS_BASENAME".fasta | sed 's/\.\///g; s/\.nex//g')"
	
	##--The line above creates a file with the name basename.fasta, where basename is the base name of the original .nex file. For example, "hypostomus_str.nex" would be converted to "hypostomus_str.fasta".
	##--Check to make sure the fasta was created; if so, echo info, if not, echo warning and quit:
	if [[ -s "$MY_NEXUS_BASENAME".fasta ]]; then
		echo "INFO      | $(date) |          Input NEXUS was successfully converted to fasta format. Moving forward... "
	else
		echo "WARNING!  | $(date) |          NEXUS to fasta file conversion FAILED! Quitting... "
		exit 1
	fi
	
	############ PUT COMPONENTS OF ORIGINAL NEXUS FILE AND THE FASTA FILE TOGETHER TO MAKE A
	############ A G-PhoCS-FORMATTED DATA FILE
	##--Make top (first line) of the G-Phocs format file, which should have the number of loci on the first line:
	echo "$MY_NLOCI" | sed 's/[\ ]*//g' > gphocs_top.txt
	
	echo "$MY_GAP_THRESHOLD" > ./gap_threshold.txt
	count=0
	(
		for j in ${MY_NEXUS_CHARSETS}; do
			echo "$j"
			charRange="$(echo ${j} | sed 's/\,//g')"
	        echo "$charRange"
	        setLower="$(echo ${j} | sed 's/\-.*$//g')"
			setUpper="$(echo ${j} | sed 's/[0-9]*\-//g' | sed 's/\,//g; s/\ //g')"
	
			**/selectSites.pl -s $charRange $MY_FASTA > ./sites.fasta
				
			**/fasta2phylip.pl ./sites.fasta > ./sites.phy

			##--Need to make sure there is a space between the tip taxon name (10 characters as output
			##--by the fasta2phylip.pl Perl script) and the corresponding sequence, for all tips. Use
			##--a perl search and replace for this:

			perl -p -i -e 's/^([A-Za-z0-9\-\_\ ]{10})/$1\ /g' ./sites.phy

				##--If .phy file from NEXUS charset $j has gaps in alignment, then call 
				##--rmGapSites.R R script to remove all column positions with gaps from
				##--alignment and output new, gapless PHYLIP file named "./sites_nogaps.phy". 
				##--If charset $j does not have gaps, go to next line of loop. We do the 
				##--above by first creating a temporary file containing all lines in
				##--sites.phy with the gap character:
				grep -n "-" ./sites.phy > ./gaptest.tmp
				
				##--Next, we test for nonzero testfile, indicating presence of gaps in $j, 
				##--using UNIX test operator "-s" (returns true if file size is not zero). 
				##--If fails, cat sites.phy into file with same name as nogaps file that
				##--is output by rmGapSites.R and move forward:
				if [ -s ./gaptest.tmp ]; then
					echo "Removing column sites in locus"$count" with gaps. "
					R CMD BATCH **/rmGapSites.R
				else
			   		echo ""
			   		cat ./sites.phy > ./sites_nogaps.phy
				fi
				
				phylip_header="$(head -n1 ./sites_nogaps.phy)"
	        	locus_ntax="$(head -n1 ./sites_nogaps.phy | sed 's/[\ ]*[.0-9]*$//g')"
				locus_nchar="$(head -n1 ./sites_nogaps.phy | sed 's/[0-9]*\ //g')"
			
			
				if [ $MY_INDIV_MISSING_DATA = "0" ]; then	
					sed '1d' ./sites_nogaps.phy | egrep -v 'NNNNNNNNNN|nnnnnnnnnn' > ./cleanLocus.tmp
					cleanLocus_ntax="$(cat ./cleanLocus.tmp | wc -l)"
					echo locus"$((count++))" $cleanLocus_ntax $locus_nchar > ./locus_top.tmp
					cat ./locus_top.tmp ./cleanLocus.tmp >> ./gphocs_body.txt
				else
					echo locus"$((count++))" $locus_ntax $locus_nchar > ./locus_top.tmp
					cat ./locus_top.tmp ./sites_nogaps.phy >> ./gphocs_body.txt
				fi

			rm ./sites.fasta ./sites.phy ./*.tmp
			rm ./sites_nogaps.phy	
		done
	)

	grep -v "^[0-9]*\ [0-9]*.*$" ./gphocs_body.txt > ./gphocs_body_fix.txt
	sed 's/locus/'$CR'locus/g' ./gphocs_body_fix.txt > ./gphocs_body_fix2.txt
	cat ./gphocs_top.txt ./gphocs_body_fix2.txt > $MY_NEXUS_BASENAME.gphocs

	############ CLEANUP: REMOVE UNNECESSARY FILES
	rm ./gphocs_top.txt
	rm ./gap_threshold.txt
	rm ./gphocs_body*

}

shopt -s nullglob
if [[ -n $(find . -name "*.nex" -type f) ]]; then

NEXUS2gphocs_function

#echo -ne '\n'

else
	echo "INFO      | $(date) |          No NEXUS files in current working directory. Continuing... "
fi

shopt -s nullglob
if [[ -n $(find . -name "*.gphocs" -type f) ]]; then
	echo "INFO      | $(date) |          MAGNET successfully created a '.gphocs' input file from the existing NEXUS file... "
    MY_GPHOCS_DATA_FILE=./*.gphocs		## Assign G-PhoCS-formatted genomic/SNP data file (originally produced/output by pyRAD) in run directory to variable.
else
    echo "WARNING!  | $(date) |          Failed to convert NEXUS file into G-PhoCS format... "
    echo "INFO      | $(date) |          Quitting."
    exit
fi


	################################# gphocs2multiPhylip.sh ##################################

	MY_NLOCI="$(head -n1 $MY_GPHOCS_DATA_FILE)"

echo "INFO      | $(date) | STEP #3: MAKE ALIGNMENTS FOR EACH LOCUS. "
echo "INFO      | $(date) |          In a single loop, using info from '.gphocs' file to split each locus block \
into a separate PHYLIP-formatted alignment file using gphocs2multiPhylip code... "
	(
		for (( i=0; i<=$(calc $MY_NLOCI-1); i++ )); do
			echo "$i"
			MY_NTAX="$(grep -n "locus$i\ " $MY_GPHOCS_DATA_FILE | \
			awk -F"locus$i " '{print $NF}' | sed 's/\ [0-9]*//g')"			

			MY_NCHAR="$(grep -n "locus$i\ " $MY_GPHOCS_DATA_FILE | \
			awk -F"locus$i [0-9]*\ " '{print $NF}')"	
		
			awk "/locus"$i"\ / {for(j=1; j<="$MY_NTAX"; j++) {getline; print}}" $MY_GPHOCS_DATA_FILE > ./locus"$i".tmp

			echo "$MY_NTAX $MY_NCHAR" > ./locus"$i"_header.tmp
				
			cat ./locus"$i"_header.tmp ./locus"$i".tmp > ./locus"$i".phy
		done
	)

	############ CLEANUP: REMOVE UNNECESSARY OR TEMPORARY FILES
	rm ./*.tmp

	if [[ -n $(find . -name "*.phy" -type f) ]]; then
	    MY_PHYLIP_ALIGNMENTS=./*.phy		## Assign PHYLIP-formatted genomic/SNP data files (e.g. output by gphocs2multiPhylip.sh shell script) in run directory to variable.
	else
	    echo "..."
	fi



	################################# MultiRAxMLPrepper.sh ##################################

echo "INFO      | $(date) | STEP #4: MAKE AND CHECK RUN FOLDERS. "

if [[ "$MY_RESUME_SWITCH" = "0" ]]; then

	MY_N_PHYLIP_FILES="$(ls $MY_PHYLIP_ALIGNMENTS | wc -l | perl -pe 's/\t//g')"

	##--Loop through the input .phy files and do the following for each file: (A) generate one 
	##--folder per .phy file with the same name as the file, only minus the extension, then 
	##--(B) move input .phy file into corresponding folder.
	(
		for i in $MY_PHYLIP_ALIGNMENTS; do
			mkdir "$(ls ${i} | sed 's/\.phy$//g')"
			cp "$i" ./"$(ls ${i} | sed 's/\.phy$//g')"
		done
	)

	##### Setup and run check on the number of run folders created by the program:
	MY_FILECOUNT="$(find . -type f | wc -l)"
	MY_DIRCOUNT="$(find . -type d | wc -l)"
	#old: MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"
	MY_NUM_RUN_FOLDERS="$(ls ./*/*.phy | wc -l | perl -pe 's/\t//g; s/\ //g')"

	echo "INFO      | $(date) |          Number of run folders created: $MY_NUM_RUN_FOLDERS "

	if [[ "$MY_NUM_RUN_FOLDERS" = "$MY_N_PHYLIP_FILES" ]]; then
		echo "INFO      | $(date) |          Folder check passed: number of run folders matches number of PHYLIP alignments. "
	else
		echo "WARNING!  | $(date) |          Folder check FAILED: number of run folders does NOT match the number of PHYLIP alignments. This may cause errors. "
	fi

elif [[ "$MY_RESUME_SWITCH" = "1" ]]; then
	if [[ "$MY_NUM_RUN_FOLDERS" = "$MY_N_PHYLIP_FILES" ]]; then
		echo "IMPORTANT!| $(date) |          Resuming a previous/existing run in current working dir. Skipping MultiRAxMLPrepper, using available run folders... "
		echo "INFO      | $(date) |          Folder check passed: number of run folders matches number of PHYLIP alignments. "
	else
		echo "WARNING!  | $(date) |          Folder check FAILED: number of run folders does NOT match the number of PHYLIP alignments. There may be errors. "
	fi

fi


	################################### RAxMLRunner.sh #######################################

if [[ "$MY_RESUME_SWITCH" = "0" ]]; then

echo "INFO      | $(date) | STEP #5: ESTIMATE GENE TREES. "
echo "INFO      | $(date) |          Looping through and analyzing contents of each run folder in RAxML... "
	##--Each folder is set with the locus name corresponding to the locus' position in the
	##--original .gphocs alignment (which, if output by pyRAD, is simply in the order in which
	##--the loci were logged to file by pyRAD, no special order). Also, each folder contains
	##--one .phy file carrying the same basename as the folder name, e.g. "locus0.phy". So,
	##--all we need to do here is loop through each folder and call RAxML to run using its
	##--contents as the input file, as follows:
	(
		for i in ./*/; do
			echo "$i"
			cd "$i"
			LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\/$//g')"

			if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -n $MY_OUTPUT_NAME
			fi

			if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
			fi

			if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -n $MY_OUTPUT_NAME
			fi

			if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
			fi

			cd ..;
		done
	)
	##--NOTE: not currently using $LOCUS_NAME here, but leave for now, bc may need to use it later...


	##--Here: adding loop code to move all .phy files remaining in the current working 
	##--directory, after STEP #3 of the pipeline, to a new folder called "phylip_files". This
	##--is done here because if the phylip_files folder is present at the end of STEP #3,
	##--then RAxML will also try to estimate a gene tree for .phy file(s) in this folder during
	##--STEP #5 of the pipeline above.
	mkdir ./phylip_files
	(
		for i in $MY_PHYLIP_ALIGNMENTS; do
			echo "$i"
			mv "$i" ./phylip_files/
		done
	)

elif [[ "$MY_RESUME_SWITCH" = "1" ]]; then

echo "INFO      | $(date) | STEP #3: RESUMING GENE TREE ESTIMATION. RUN ON REMAINING/INCOMPLETE RUN FOLDERS, SKIP THOSE WITH COMPLETED RAXML RUNS. "

	(
		for i in ./*/; do
			cd "$i"
			LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\/$//g')"

			if [[ ! -s ./RAxML_info.raxml_out ]]; then
			echo "$i"

				if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -n $MY_OUTPUT_NAME
				fi

				if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
				fi

				if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -n $MY_OUTPUT_NAME
				fi

				if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
				fi
			fi
			cd ..;
		done
	)

	if [[ ! -s ./phylip_files/ ]]; then
		mkdir ./phylip_files/;
	fi
	(
		for i in $MY_PHYLIP_ALIGNMENTS; do
			echo "$i"
			mv "$i" ./phylip_files/
		done
	)
fi




if [[ "$MY_RESUME_SWITCH" = "0" ]]; then
	echo "INFO      | $(date) | STEP #6: RAxML POST-PROCESSING. "
elif [[ "$MY_RESUME_SWITCH" = "1" ]]; then
	echo "INFO      | $(date) | STEP #4: RAxML POST-PROCESSING. "
fi

	################################## getGeneTrees.sh #######################################
	echo "INFO      | $(date) |          Organizing gene trees and making final output file containing all trees... "
	echo "INFO      | $(date) |          Making list of ML gene trees generated by RAxML... "

	ls **/RAxML_bestTree.raxml_out > geneTrees.list

	##--Assign gene tree list to variable
	MY_GENE_TREE_LIST="$(cat ./geneTrees.list)"

	############ ORGANIZE GENE TREES INTO ONE LOCATION
	##--Place all inferred gene trees into a single "gene_trees" folder in the current
	##--working directory. However, all the gene tree files have the same name. So, in order
	##--to do this, we have to give each gene tree a name that matches the corresponding run
	##--folder, i.e. locus. We can rename each file right after downloading it.
	mkdir ./gene_trees

	echo "INFO      | $(date) |          Copying *ALL* ML gene trees to 'gene_trees' folder in current directory for post-processing..."
	(
		for j in ${MY_GENE_TREE_LIST}; do
			echo "$j"
			cp "$j" ./gene_trees/
			MY_LOCUS_NAME="$(echo $j | sed 's/\/[A-Za-z.\_\-]*//g')"
			cp ./gene_trees/RAxML_bestTree.raxml_out ./gene_trees/"$MY_LOCUS_NAME"_RAxML_best.tre
			rm ./gene_trees/RAxML_bestTree.raxml_out
		done
	)

	echo "INFO      | $(date) |          Making final output file 'besttrees.tre' containing best ML trees from all runs/loci..."
	(
		for k in ./gene_trees/*; do
			echo "$k"
			cat "$k" >> ./besttrees.tre
		done
	)


	################################## getBootTrees.sh #######################################
	echo "INFO      | $(date) |          Organizing bootstrap trees and making final output file containing all trees... "
	echo "INFO      | $(date) |          Making list of ML bootstrap trees generated by RAxML... "

	ls **/RAxML_bootstrap.raxml_out > bootTrees.list

	##--Assign bootstrap tree list to variable
	MY_BOOT_TREE_LIST="$(cat ./bootTrees.list)"

	############ ORGANIZE BOOTSTRAP TREES INTO ONE LOCATION
	##--Place all inferred bootstrap tree files into a single "bootstrap_trees" folder in 
	##--working directory. However, all the boot tree files have the same name. So, in order
	##--to do this, we have to give each boot tree file a name that matches the corresponding
	##--run folder, i.e. locus. We can rename each file right after downloading it.
	mkdir ./bootstrap_trees

	echo "INFO      | $(date) |          Copying *ALL* ML bootstrap trees to 'bootstrap_trees' folder in current directory for post-processing..."
	(
		for l in ${MY_BOOT_TREE_LIST}; do
			echo "$l"
			cp "$l" ./bootstrap_trees/
			MY_LOCUS_NAME="$(echo $l | sed 's/\/[A-Za-z.\_\-]*//g')"
			cp ./bootstrap_trees/RAxML_bootstrap.raxml_out ./bootstrap_trees/"$MY_LOCUS_NAME"_RAxML_boot.tre
			rm ./bootstrap_trees/RAxML_bootstrap.raxml_out
		done
	)

	echo "INFO      | $(date) |          Making final output file 'boottrees.tre' containing best ML trees from all runs/loci..."
	(
		for m in ./bootstrap_trees/*; do
			echo "$m"
			cat "$m" >> ./boottrees.tre
		done
	)

	echo "INFO      | $(date) |          Making final list of ML bootstrap trees ('final_bootTrees.list') in bootstrap_trees directory..."
	ls ./bootstrap_trees/*.tre > final_bootTrees.list


	################################## getBipartTrees.sh #######################################
	echo "INFO      | $(date) |          Organizing bipartitions trees (with bootstrap proportion labels) and making final output file containing all bipartitions trees... "
	ls **/RAxML_bipartitions.raxml_out > bipartTrees.list

	##--Assign bootstrap tree list to variable
	MY_BIPART_TREE_LIST="$(cat ./bipartTrees.list)"

	############ ORGANIZE BIPARTITIONS TREES INTO ONE LOCATION
	mkdir ./bipartitions_trees

	echo "INFO      | $(date) |          Copying *ALL* RAxML bootstrap bipartitions trees to 'bipartitions_trees' folder in current directory for post-processing..."
	(
		for l in ${MY_BIPART_TREE_LIST}; do
			echo "$l"
			cp "$l" ./bipartitions_trees/
			MY_LOCUS_NAME="$(echo $l | sed 's/\/[A-Za-z.\_\-]*//g')"
			cp ./bipartitions_trees/RAxML_bipartitions.raxml_out ./bipartitions_trees/"$MY_LOCUS_NAME"_RAxML_bipartitions.tre
			rm ./bipartitions_trees/RAxML_bipartitions.raxml_out
		done
	)

	echo "INFO      | $(date) |          Making final output file 'biparttrees.tre' containing RAxML bipartitions trees from all runs/loci..."
	(
		for m in ./bipartitions_trees/*; do
			echo "$m"
			cat "$m" >> ./biparttrees.tre
		done
	)

	echo "INFO      | $(date) |          Making final list of RAxML bipartitions trees ('final_bipartTrees.list') in bipartitions_trees directory..."
	ls ./bipartitions_trees/*.tre > final_bipartTrees.list


fi
#######

############################### IF -f 2: MULTI PHYLIP RUN ################################
##########################################################################################

if [[ "$STARTING_FILE_TYPE" = "2" ]]; then
MY_WORKING_DIR="$1"

######################################## START ###########################################
echo "INFO      | $(date) | Starting MAGNET pipeline... "
echo "INFO      | $(date) | STEP #1: SETUP. "
###### Echo working dir read in as mandatory parameter above, then set some variables:
	echo "INFO      | $(date) |          Setting working directory to: "
	echo "$MY_WORKING_DIR "	
	CR=$(printf '\r')
	calc () {
	   	bc -l <<< "$@"
	}


echo "INFO      | $(date) | STEP #2: INPUT (SINGLE NEXUS/G-PhoCS FILE, OR MULTIPLE PHYLIP FILES). "
echo "INFO      | $(date) |          For -f 1 or -f 2f '.gphocs' input file present, continue; else convert NEXUS file to "
echo "INFO      | $(date) |          G-PhoCS format using NEXUS2gphocs code. If -f 3, then run multiple PHYLIP files in  "
echo "INFO      | $(date) |          RAxML."


	MY_PHYLIP_ALIGNMENTS=./*.phy		## Assign PHYLIP-formatted multilocus gene / genomic/SNP / RAD locus sequence alignment files (e.g. output by gphocs2multiPhylip.sh shell script) in run directory to variable.


	################################# MultiRAxMLPrepper.sh ##################################

if [[ "$MY_RESUME_SWITCH" = "0" ]]; then

echo "INFO      | $(date) | STEP #3: MAKE RUN FOLDERS. "

	MY_N_PHYLIP_FILES="$(ls $MY_PHYLIP_ALIGNMENTS | wc -l | perl -pe 's/\t//g')"

	##--Loop through the input .phy files and do the following for each file: (A) generate one 
	##--folder per .phy file with the same name as the file, only minus the extension, then 
	##--(B) move input .phy file into corresponding folder.
	(
		for i in $MY_PHYLIP_ALIGNMENTS; do
			mkdir "$(ls ${i} | sed 's/\.phy$//g')"
			cp "$i" ./"$(ls ${i} | sed 's/\.phy$//g')"
		done
	)

	##### Setup and run check on the number of run folders created by the program:
	MY_FILECOUNT="$(find . -type f | wc -l)"
	MY_DIRCOUNT="$(find . -type d | wc -l)"
	#old: MY_NUM_RUN_FOLDERS="$(calc $MY_DIRCOUNT - 1)"
	MY_NUM_RUN_FOLDERS="$(ls ./*/*.phy | wc -l | perl -pe 's/\t//g; s/\ //g')"

	echo "INFO      | $(date) |          Number of run folders created: $MY_NUM_RUN_FOLDERS "

	if [[ "$MY_NUM_RUN_FOLDERS" = "$MY_N_PHYLIP_FILES" ]]; then
		echo "INFO      | $(date) |          Folder check passed: number of run folders matches number of PHYLIP alignments. "
	else
		echo "WARNING!  | $(date) |          Folder check FAILED: number of run folders does NOT match the number of PHYLIP alignments. This may cause errors. "
	fi

elif [[ "$MY_RESUME_SWITCH" = "1" ]]; then
	if [[ "$MY_NUM_RUN_FOLDERS" = "$MY_N_PHYLIP_FILES" ]]; then
		echo "IMPORTANT!| $(date) |          Resuming a previous/existing run in current working dir. Skipping MultiRAxMLPrepper, using available run folders... "
		echo "INFO      | $(date) |          Folder check passed: number of run folders matches number of PHYLIP alignments. "
	else
		echo "WARNING!  | $(date) |          Folder check FAILED: number of run folders does NOT match the number of PHYLIP alignments. There may be errors. "
	fi

fi

	################################### RAxMLRunner.sh #######################################

if [[ "$MY_RESUME_SWITCH" = "0" ]]; then

echo "INFO      | $(date) | STEP #4: ESTIMATE GENE TREES. "
echo "INFO      | $(date) |          Looping through and analyzing contents of each run folder in RAxML... "
	##--Each folder is set with the locus name corresponding to the locus' position in the
	##--original .gphocs alignment (which, if output by pyRAD, is simply in the order in which
	##--the loci were logged to file by pyRAD, no special order). Also, each folder contains
	##--one .phy file carrying the same basename as the folder name, e.g. "locus0.phy". So,
	##--all we need to do here is loop through each folder and call RAxML to run using its
	##--contents as the input file, as follows:
	(
		for i in ./*/; do
			echo "$i"
			cd "$i"
			LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\/$//g')"

			if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -n $MY_OUTPUT_NAME
			fi

			if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
			fi

			if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -n $MY_OUTPUT_NAME
			fi

			if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
				"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
			fi

			cd ..;
		done
	)
	##--NOTE: not currently using $LOCUS_NAME here, but leave for now, bc may need to use it later...


	##--Here: adding loop code to move all .phy files remaining in the current working 
	##--directory, after STEP #3 of the pipeline, to a new folder called "phylip_files". This
	##--is done here because if the phylip_files folder is present at the end of STEP #3,
	##--then RAxML will also try to estimate a gene tree for .phy file(s) in this folder during
	##--STEP #5 of the pipeline above.
	mkdir ./phylip_files
	(
		for i in $MY_PHYLIP_ALIGNMENTS; do
			echo "$i"
			mv "$i" ./phylip_files/
		done
	)

elif [[ "$MY_RESUME_SWITCH" = "1" ]]; then

echo "INFO      | $(date) | STEP #3: RESUMING GENE TREE ESTIMATION. RUN ON REMAINING/INCOMPLETE RUN FOLDERS, SKIP THOSE WITH COMPLETED RAXML RUNS. "

	(
		for i in ./*/; do
			cd "$i"
			LOCUS_NAME="$(echo $i | sed 's/\.\///g; s/\/$//g')"

			if [[ ! -s ./RAxML_info.raxml_out ]]; then
			echo "$i"

				if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -n $MY_OUTPUT_NAME
				fi

				if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" = "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
				fi

				if [[ "$MY_OUTGROUP" = "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -n $MY_OUTPUT_NAME
				fi

				if [[ "$MY_OUTGROUP" != "NULL" ]] && [[ "$MY_SIMPLE_MODEL" != "NULL" ]]; then
					"$MY_RAXML_EXECUTABLE" -f a -x $(python -c "import random; print random.randint(10000,100000000000)") -p $(python -c "import random; print random.randint(10000,100000000000)") -# $MY_NUM_BOOTREPS -m $MY_RAXML_MODEL -s ./*.phy --$MY_SIMPLE_MODEL -o $MY_OUTGROUP -n $MY_OUTPUT_NAME
				fi
			fi
			cd ..;
		done
	)

	if [[ ! -s ./phylip_files/ ]]; then
		mkdir ./phylip_files/;
	fi
	(
		for i in $MY_PHYLIP_ALIGNMENTS; do
			echo "$i"
			mv "$i" ./phylip_files/
		done
	)
fi



if [[ "$MY_RESUME_SWITCH" = "0" ]]; then
	echo "INFO      | $(date) | STEP #5: RAxML POST-PROCESSING. "
elif [[ "$MY_RESUME_SWITCH" = "1" ]]; then
	echo "INFO      | $(date) | STEP #4: RAxML POST-PROCESSING. "
fi

	################################## getGeneTrees.sh #######################################
	echo "INFO      | $(date) |          Organizing gene trees and making final output file containing all trees... "
	echo "INFO      | $(date) |          Making list of ML gene trees generated by RAxML... "

	ls **/RAxML_bestTree.raxml_out > geneTrees.list

	##--Assign gene tree list to variable
	MY_GENE_TREE_LIST="$(cat ./geneTrees.list)"

	############ ORGANIZE GENE TREES INTO ONE LOCATION
	##--Place all inferred gene trees into a single "gene_trees" folder in the current
	##--working directory. However, all the gene tree files have the same name. So, in order
	##--to do this, we have to give each gene tree a name that matches the corresponding run
	##--folder, i.e. locus. We can rename each file right after downloading it.
	mkdir ./gene_trees

	echo "INFO      | $(date) |          Copying *ALL* ML gene trees to 'gene_trees' folder in current directory for post-processing..."
	(
		for j in ${MY_GENE_TREE_LIST}; do
			echo "$j"
			cp "$j" ./gene_trees/
			MY_LOCUS_NAME="$(echo $j | sed 's/\/[A-Za-z.\_\-]*//g')"
			cp ./gene_trees/RAxML_bestTree.raxml_out ./gene_trees/"$MY_LOCUS_NAME"_RAxML_best.tre
			rm ./gene_trees/RAxML_bestTree.raxml_out
		done
	)

	echo "INFO      | $(date) |          Making final output file 'besttrees.tre' containing best ML trees from all runs/loci..."
	(
		for k in ./gene_trees/*; do
			echo "$k"
			cat "$k" >> ./besttrees.tre
		done
	)


	################################## getBootTrees.sh #######################################
	echo "INFO      | $(date) |          Organizing bootstrap trees and making final output file containing all trees... "
	echo "INFO      | $(date) |          Making list of ML bootstrap trees generated by RAxML... "

	ls **/RAxML_bootstrap.raxml_out > bootTrees.list

	##--Assign bootstrap tree list to variable
	MY_BOOT_TREE_LIST="$(cat ./bootTrees.list)"

	############ ORGANIZE BOOTSTRAP TREES INTO ONE LOCATION
	##--Place all inferred bootstrap tree files into a single "bootstrap_trees" folder in 
	##--working directory. However, all the boot tree files have the same name. So, in order
	##--to do this, we have to give each boot tree file a name that matches the corresponding
	##--run folder, i.e. locus. We can rename each file right after downloading it.
	mkdir ./bootstrap_trees

	echo "INFO      | $(date) |          Copying *ALL* ML bootstrap trees to 'bootstrap_trees' folder in current directory for post-processing..."
	(
		for l in ${MY_BOOT_TREE_LIST}; do
			echo "$l"
			cp "$l" ./bootstrap_trees/
			MY_LOCUS_NAME="$(echo $l | sed 's/\/[A-Za-z.\_\-]*//g')"
			cp ./bootstrap_trees/RAxML_bootstrap.raxml_out ./bootstrap_trees/"$MY_LOCUS_NAME"_RAxML_boot.tre
			rm ./bootstrap_trees/RAxML_bootstrap.raxml_out
		done
	)

	echo "INFO      | $(date) |          Making final output file 'boottrees.tre' containing best ML trees from all runs/loci..."
	(
		for m in ./bootstrap_trees/*; do
			echo "$m"
			cat "$m" >> ./boottrees.tre
		done
	)

	echo "INFO      | $(date) |          Making final list of ML bootstrap trees ('final_bootTrees.list') in bootstrap_trees directory..."
	ls ./bootstrap_trees/*.tre > final_bootTrees.list


	################################## getBipartTrees.sh #######################################
	echo "INFO      | $(date) |          Organizing bipartitions trees (with bootstrap proportion labels) and making final output file containing all bipartitions trees... "
	ls **/RAxML_bipartitions.raxml_out > bipartTrees.list

	##--Assign bootstrap tree list to variable
	MY_BIPART_TREE_LIST="$(cat ./bipartTrees.list)"

	############ ORGANIZE BIPARTITIONS TREES INTO ONE LOCATION
	mkdir ./bipartitions_trees

	echo "INFO      | $(date) |          Copying *ALL* RAxML bootstrap bipartitions trees to 'bipartitions_trees' folder in current directory for post-processing..."
	(
		for l in ${MY_BIPART_TREE_LIST}; do
			echo "$l"
			cp "$l" ./bipartitions_trees/
			MY_LOCUS_NAME="$(echo $l | sed 's/\/[A-Za-z.\_\-]*//g')"
			cp ./bipartitions_trees/RAxML_bipartitions.raxml_out ./bipartitions_trees/"$MY_LOCUS_NAME"_RAxML_bipartitions.tre
			rm ./bipartitions_trees/RAxML_bipartitions.raxml_out
		done
	)

	echo "INFO      | $(date) |          Making final output file 'biparttrees.tre' containing RAxML bipartitions trees from all runs/loci..."
	(
		for m in ./bipartitions_trees/*; do
			echo "$m"
			cat "$m" >> ./biparttrees.tre
		done
	)

	echo "INFO      | $(date) |          Making final list of RAxML bipartitions trees ('final_bipartTrees.list') in bipartitions_trees directory..."
	ls ./bipartitions_trees/*.tre > final_bipartTrees.list

fi
#######

echo "INFO      | $(date) | Done estimating gene trees for many loci in RAxML using the MAGNET pipeline."
echo "INFO      | $(date) | Bye.
"
#
#
#
######################################### END ############################################

exit 0
