#!/usr/bin/env Rscript

##########################################################################################
#  __  o  __   __   __  |__   __                                                         #
# |__) | |  ' (__( |  ) |  ) (__(                                                        # 
# |                                                                                      #
#                                                                                        #
# File: 2logeB10.r (Rscript)                                                             #
#  VERSION="v1.2"                                                                        #
# Author: Justin C. Bagley                                                               #
# Date: Created by Justin Bagley on Fri, 19 Aug 2016 00:23:07 -0300.                     #
# Last update: March 6, 2019                                                             #
# Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved.                         #
# Please report bugs to <jbagley@jsu.edu>.                                               #
#                                                                                        #
# Description:                                                                           #
#                                                                                        #
##########################################################################################

######################################## START ###########################################

cat('INFO      | $(date) |----------------------------------------------------------------\n')
cat('INFO      | $(date) | 2logeB10.r, v1.2 March 2019  (part of PIrANHA v0.3a2)   \n')
cat('INFO      | $(date) | Copyright (c) 2016-2019 Justin C. Bagley. All rights reserved. \n')
cat('INFO      | $(date) |----------------------------------------------------------------\n')

##--Load needed library, R code, or package stuff. Install package if not present.
#source("2logeB10.R", chdir = TRUE)
packages <- c("psych")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))
}

library(psych)

############ Read data and output to file
##--Read in the data, output from STEP #1 of MLEResultsProc.sh script.
data <- read.table(file="MLE.output.txt", header=TRUE, sep="\t")

sink("2logeB10.output.txt")
cat("############################# MARGINAL-LIKELIHOOD ESTIMATES ##############################\n")
data
cat("\n \n")
sink()


############ Get marginal likelihood values and calculate 2loge B10 Bayes factors (2loge(B10))
#--Raw path-sampling (PS) log-marginal likelihood estimates:
PS_vec <- data[,2]
PS_vec

##--Raw stepping-stone (SS) sampling log-marginal likelihood estimates:
SS_vec <- data[,3]
SS_vec

##--Make matrix of zeros for correcting signs of each BF below:
if(length(PS_vec) > 0){
	zeros <- c()
	for(i in 1:length(PS_vec)){
		zeros[i] <- 0
	}
}
if(length(SS_vec) > 0){
	zeros <- c()
	for(i in 1:length(SS_vec)){
		zeros[i] <- 0
	}
}
zeros
zeros_mat <- 2*(outer(zeros, zeros, '-'))
zeros_mat

##--Matrix of 2loge BFs calculated from PS log-marginal likelihood estimates:
PS_2logeB10 = 2*(outer(PS_vec, PS_vec, '-'))
PS_2logeB10 <- zeros_mat - PS_2logeB10

##--Matrix of 2loge BFs calculated from SS log-marginal likelihood estimates:
SS_2logeB10 = 2*(outer(SS_vec, SS_vec, '-'))
SS_2logeB10 <- zeros_mat - SS_2logeB10


############ Summarize results and output to file
##--Use psych package function to combine the resulting matrices into a single, nice
##--output table with Bayes factors (BF) from PS MLEs below the diagonal and BFs from SS 
##--MLEs above the diagonal:
sink("2logeB10.output.txt", append=TRUE)
cat("##################################### BAYES FACTORS ######################################
Below diagonal: 2loge(B10) values based on path sampling (PS) log-marginal likelihood estimates
Above diagonal: 2loge(B10) values based on stepping-stone (SS) log-marginal likelihood estimates\n")
if(sum(PS_vec) == '0'){    
	BF_mat <- lowerUpper(PS_2logeB10, SS_2logeB10, diff=FALSE)
	BF_mat[lower.tri(BF_mat)] <- NA
	rownames(BF_mat) <- 1:length(PS_vec)
	colnames(BF_mat) <- 1:length(PS_vec)
	BF_mat
}
if(sum(SS_vec) == '0'){    
	BF_mat <- lowerUpper(PS_2logeB10, SS_2logeB10, diff=FALSE)
	BF_mat[upper.tri(BF_mat)] <- NA
	rownames(BF_mat) <- 1:length(PS_vec)
	colnames(BF_mat) <- 1:length(PS_vec)
	BF_mat
}
if( (sum(PS_vec) != '0') & (sum(SS_vec) != '0') ){    
	BF_mat <- lowerUpper(PS_2logeB10, SS_2logeB10, diff=FALSE)
	rownames(BF_mat) <- 1:length(PS_vec)
	colnames(BF_mat) <- 1:length(PS_vec)
	BF_mat
}
cat("\n \n")
sink()

##--Next, report PS MLE BFs below the diagonal and report the difference between PS- and 
##--SS-based BF matrices, placing the results in the above-the-diagonal entries. However, 
##--we only report the differences if both PS- and SS-based BFs could be calculated; otherwise,
##--we do not report the differences at all! If PS MLEs or SS MLEs were missing in the input 
##--(as is usually the case for BEAST2 MLE runs), then either PS_vec or SS_vec would be filled 
##--with zeros. If we computed differences in such a case, then we would be left with a square 
##--matrix in which the above-diagonal elements were the same as the below-diagonal elements, 
##--only with the opposite sign. Such a table would be equivalent to the Bayes factors table 
##--already written to file in the step above, and thus would be unnecessary.

sink("2logeB10.output.txt", append=TRUE)
if( (sum(PS_vec) != '0') & (sum(SS_vec) != '0') ){    
cat("################################ BAYES FACTOR DIFFERENCES ################################
Below diagonal: 2loge(B10) values based on path sampling (PS) log-marginal likelihood estimates
Above diagonal: differences between PS- and SS-based BF values\n")
	BF_diff_mat <- lowerUpper(PS_2logeB10, SS_2logeB10, diff=TRUE)
	rownames(BF_diff_mat) <- 1:length(PS_vec)
	colnames(BF_diff_mat) <- 1:length(PS_vec)
	BF_diff_mat
}
cat("\n \n")
sink()


######################################### END ############################################
