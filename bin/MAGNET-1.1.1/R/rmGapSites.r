#!/usr/bin/env Rscript

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: rmGapSites Rscript                                                               #
# VERSION="v1.1"                                                                         #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on/before Aug 29 13:12:45 2016 -0700.                   #
# Last update: March 6, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <jbagley@jsu.edu>.                                              #
#                                                                                        #
# Description:                                                                           #
# RSCRIPT THAT REMOVES GAP SITES FROM AN INPUT DNA SEQUENCE ALIGNMENT IN PHYLIP FORMAT   #
# NAMED 'sites.phy' (SPECIFIC TO THE MAGNET PIPELINE)                                    #
#                                                                                        #
##########################################################################################

######################################## START ###########################################

##--Load needed library, R code, or package stuff. Install package if not present.
##--source("rmGapSites.R", chdir = TRUE)
packages <- c("ape", "readr", "seqinr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))
}

library(ape)
library(readr)
library(seqinr)

##--Read in the data, output from first part of NEXUS2gphocs loop:
	sites <- read.dna("sites.phy", format="sequential")
	gap_thresh <- read_file("gap_threshold.txt")

##--Fix the gap threshold and then delete columns with the threshold level of gaps
##--equivalent to at least 1 gap (i.e. any gaps at all):
	gap_thresh <- sub(pattern = "\\n", replacement = "", x = gap_thresh)
	sites_nogaps <- del.colgapsonly(sites, threshold = gap_thresh, freq.only = FALSE)

##--Write new alignment, with sites with gaps removed, to file:
##--(writing to present working directory)...
	write.dna(sites_nogaps, file="sites_nogaps.phy", format="sequential", nbcol=-1, colw=500000)

	##--write.nexus(sites_nogaps, file="sites_nogaps.nex")


######################################### END ############################################
