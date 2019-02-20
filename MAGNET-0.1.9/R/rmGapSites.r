#!/usr/bin/env Rscript

##########################################################################################
#                          rmGapSites Rscript v1.0, August 2016                          #
#   Copyright (c)2019 Justin C. Bagley. See the PIrANHA README and license files (at     #
#   http://github.com/justincbagley/PIrANHA) for further information. Last edit, August  #
#   2016.                                                                                #
##########################################################################################

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
