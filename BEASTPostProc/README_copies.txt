##--------------------------------------- README ---------------------------------------##
##--THIS SCRIPT aids post-processing of BEAST output files resulting from runs using the 
##--standard BEAST divergence time approach (Drummond et al. 2006), or the multispecies
##--coalescent as implemented in the *BEAST model (Heled & Drummond 2010). Specifically,
##--this code 1) summarizes the length and posterior distributions of parameters in the
##--run using LogAnalyser, and then 2) obtains 5000 random post-burnin trees and uses them 
##--to infer a maximum clade credibility (MCC) tree annotated with posterior probabilities 
##--and node divergence time estimates in TreeAnnotator. The code is written in a way to  
##--automate these common procedures by taking advantage of available utilities for post-
##--processing that come with the BEAST (v1.8.3) distribution. 
#
##--BEAST v1.8.3 (and probably other versions) must be installed locally for this code to
##--work. In addition, it is assumed that you know the absolute path to these programs, or
##--that you have already placed the bin folder holding "loganalyser" and "treeannotator" 
##--executables in your path, so that they are available from the command line.
#
##--If you have run BEAST, this code processes the posterior distributions of gene trees
##--only. However, if you are processing results of a *BEAST run, this code processes the
##--gene tree and species tree results in the run directory. 
#
##--For interpreting files output by this script, please refer to the BEAST websites
##--(.uk and http://beast2.org), published papers on the software (e.g. Drummond et al., 
##--2012), manuals and other docs included in the BEAST distributions, and also tutorials 
##--and comments on using BEAST on my website (http://www.justinbagley.org).
#
##--References:
##--Drummond et al. 2006, 2012.
##--Heled and Drummond 2010.
##--------------------------------------------------------------------------------------##
#
#
#






##--------------------------------------- README ---------------------------------------##
##--THIS SCRIPT aids post-processing of *BEAST (Heled & Drummond 2010) output files by
##--1) summarizing run and posterior distributions of parameters in LogAnalyser, then 2) 
##--obtaining 5000 random post-burnin species trees and using them to create a maximum 
##--clade credibility (MCC) tree annotated with posterior probabilities and divergence
##--time estimates in TreeAnnotator. Thus, this code automates several common procedures
##--and takes advantage of available utilities for post-processing that come with the
##--BEAST (v1.8.3) distribution.
#
##--Of course, it is assumed the BEAST v1.8.3 (and probably other versions) is installed
##--locally and that you have already placed the bin folder containing "loganalyser" and
##--"treeannotator" executables in your path, or know the absolute path to these programs.
#
##--For interpreting files output by this script, please refer to the BEAST websites
##--(.uk and http://beast2.org), published papers on the software (e.g. Drummond et al., 
##--2012), manuals and other docs included in the BEAST distributions, and also tutorials 
##--and comments on using BEAST on my website (http://www.justinbagley.org).
#
##--References:
##--Heled and Drummond 2010.
##--Drummond et al. 2012.
##--------------------------------------------------------------------------------------##
