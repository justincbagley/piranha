#!/bin/sh

###### (c) 2016 Justin C. Bagley, November 9, 2016, at The University of Alabama, 
###### Tuscaloosa, AL.

###### Starting from a folder containing multiple PHYLIP alignment files (e.g. as generated
## by MAGNET.sh for indiv. SNP loci), this script uses a for loop to echo all alignment
## names (containing locus or taxon information) to file, and then echo the number of 
## characters (Nchar) recursively to a file named "nchar.txt" in the working directory.

(
	for i in ./*.phy; do 
		echo $i >> phyalign_names.txt; 
		echo "$(head -n1 $i | awk -F"[0-9]*\ " '{print $NF}')" >> nchar.txt; 
	done;
)

## I would like to build on this by calculating statistics from the nchar list from within
## the shell.

exit 0
