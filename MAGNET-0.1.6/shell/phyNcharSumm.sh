#!/bin/sh

#  Copyright ©2016 Justinc C. Bagley. For further information, see README and license    #
#  available in the PIrANHA repository (https://github.com/justincbagley/PIrANHA/). Last #
#  update: November 9, 2016. For questions, please email jcbagley@vcu.edu.               #

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
