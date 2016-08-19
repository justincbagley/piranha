#!/usr/bin/env Rscript

##########################################################################################
#                           2logeB10 Rscript v1.0, July 2016                             #
#   Copyright (c)2016 Justin C. Bagley, Universidade de Brasília, Brasília, DF, Brazil   #
#   See the README and license files on GitHub (http://github.com/justincbagley) for     #
#   further information.                                                                 #
##########################################################################################

##--Load needed library, R code, or package stuff.
#source("2logeB10.R", chdir = TRUE)
library(psych)

##--Read in the data, output from STEP #1 of MLEResultsProc.sh script.
data <- read.table(file="MLE.output.txt", header=TRUE, sep="\t")

############ Get marginal likelihood values and calculate 2loge B10 Bayes factors (2logeB10)
#--Raw path-sampling (PS) log-marginal likelihood estimates:
PS.vec <- data[,2]
PS.vec

##--Raw stepping-stone (SS) sampling log-marginal likelihood estimates:
SS.vec <- data[,3]
SS.vec

##--Matrix of 2loge BFs calculated PS log-marginal likelihood estimates:
PS.2logeB10 = 2*(outer(PS.vec, PS.vec, `-`))
PS.2logeB10

##--Matrix of 2loge BFs calculated PS log-marginal likelihood estimates:
SS.2logeB10 = 2*(outer(SS.vec, SS.vec, `-`))
SS.2logeB10

############ Summarize results and output to file
##--Use psych package function to combine the resulting matrices into a single, nice
##--output table with Bayes factors (BF) from PS MLEs below the diagonal and BFs from SS 
##--MLEs above the diagonal:
sink("BayesFactors.out.txt", append=TRUE)
cat("##################################### BAYES FACTORS ######################################
Below diagonal: 2logeB10 values based on path sampling (PS) log-marginal likelihood estimates
Above diagonal: 2logeB10 values based on stepping-stone (SS) log-marginal likelihood estimates\n")
lowerUpper(PS.2logeB10, SS.2logeB10, diff=FALSE)
cat("\n \n")
sink()

##--Next, report PS MLE BFs below the diagonal and report the difference between PS- and 
##--SS-based BF matrices, placing the results in the above-the-diagonal entries:
sink("BayesFactors.out.txt", append=TRUE)
cat("################################ BAYES FACTOR DIFFERENCES ################################
Below diagonal: 2logeB10 values based on path sampling (PS) log-marginal likelihood estimates
Above diagonal: differences between PS- and SS-based BF values\n")
lowerUpper(PS.2logeB10, SS.2logeB10, diff=TRUE)
cat("\n \n")
sink()

######################################### END ############################################
