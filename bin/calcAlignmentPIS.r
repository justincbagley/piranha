#!/usr/bin/env Rscript

#########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: calcAlignmentPIS.r (Rscript)                                                     #
#  VERSION="v1.2"                                                                        #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Fri, 19 Aug 2016 00:23:07 -0300.                     #
# Last update: March 6, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <jbagley@jsu.edu>.                                               #
#                                                                                        #
# Description:                                                                           #
#                                                                                        #
#########################################################################################

####################################### START ###########################################

cat('INFO      | $(date) |----------------------------------------------------------------\n')
cat('INFO      | $(date) | calcAlignmentPIS.r, v1 March 2019                              \n')
cat('INFO      | $(date) | Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved. \n')
cat('INFO      | $(date) |----------------------------------------------------------------\n')

# R code for looping through set of FASTA files in dir and calculating parsimony-informative
# sites for each alignment, then saving and outputting to file. Written for Anoura UCE
# data analysis, March 6, 2019

# Be sure to do the following OUTSIDE of R before running R on your machine (assuming
# you have set up the prepR function in your ~/.bashrc (Linux) or ~/.bash_profile (Mac)
# files on machine).
# $ prepR

############ I. SETUP
# Load needed packages, R code, or other prelim stuff. Install packages if not present.
packages <- c('phyloch')
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
	install.packages(setdiff(packages, rownames(installed.packages())))
}
library(phyloch)
#setwd('')	# With my current R setup, no need to set wd because this is done automatically at start up.
getwd()

############ II. CALCULATE PARSIMONY-INFORMATIVE SITES (PIS) FOR ALL FASTA FILES.
files <- list.files(path=getwd(), pattern='*.fas', full.names=TRUE, recursive=FALSE)
iterations <- length(files)
variables <- 1
output <- matrix(ncol=variables, nrow=iterations)

# Use loop through FASTA files in files (above) to calculate PIS for each file and save
# to output matrix:
for(i in 1:iterations){
	# Read FASTA file
	fas <- read.fas(files[i])
	# Apply function to estimate parsimony-informative sites (PIS)
	pis_out <- pis(fas, abs = TRUE, use.ambiguities = FALSE)
	# Add PIS result to data matrix
	output[i,] <- pis_out
}

write.table(output, 'pis_output_table.txt', sep='	', quote=FALSE, row.names=FALSE, col.names=TRUE)

output

write.table(files, 'input_file_order.txt', sep='	')

######################################### END ############################################

