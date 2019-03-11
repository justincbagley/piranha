# MLEResultsProc

THIS SCRIPT aids post-processing of multiple BEAST1 or BEAST2 (Drummond et al. 2012; Bouckaert et al. 2014) runs for marginal-likelihood or Bayes factor model comparison, for example as in the Bayes factor delimitation (BFD) procedure of Grummer et al. (2014). The script expects that the user has conducted multiple BEAST runs that each included a marginal-likelihood estimation step, using either path sampling (PS) and stepping-stone sampling (SS) (Xie et al. 2011; Baele et al. 2012). Marginal-likelihood estimation should be performed on all models using the same software program, because while MLEResultsProc can accommodate output files from either BEAST v1++ or BEAST v2++, _but not a mixture of output files from both programs_. The user must then copy the ".out" files from each run (making sure they have unique names, e.g. matching the corresponding model) into a working directory for MLEResultsProc analysis. 

Under this scenario, 'MLEResultsProc.sh' automates extracting the path sampling (PS) and/or stepping-stone sampling (SS) marginal-likelihood estimates from the final sections of the output file for each model, arranging the MLE estimates into a summary table file in the current working dir, and then loading the results file into R and computing Bayes factor tables comparing the models. 

## Screen output

Here, I provide an example of output to screen during a recent MLEResultsProc analysis:
```
$ ./MLEResultsProc.sh 

##########################################################################################
#                            MLEResultsProc v1.2, August 2017                            #
##########################################################################################

INFO      | Wed Aug 23 10:09:30 EDT 2017 | STEP #1: SETUP. 
INFO      | Wed Aug 23 10:09:30 EDT 2017 | STEP #2: CHECK BEAST VERSION (DETECT AND ACCOMODATE RESULTS FILES FROM BEAST1 OR BEAST2). 
INFO      | Wed Aug 23 10:09:31 EDT 2017 | STEP #3: EXTRACT MLE RESULTS FROM OUTPUT FILES. 
INFO      | Wed Aug 23 10:09:31 EDT 2017 |          BEAST v2+ output files detected; conducting post-processing accordingly... 
INFO      | Wed Aug 23 10:09:31 EDT 2017 |          Extracting MLE results from the following output files: 
balf_M1_ari-balf.out
balf_M2_long-balf.out
balf_M3_ari-long.out
strob_M1_aya-flex.out
strob_M2_strob-flex.out
strob_M3_aya-strob.out
INFO      | Wed Aug 23 10:09:32 EDT 2017 | STEP #4: ARRANGE MLE RESULTS IN TAB-DELIMITED FILE WITH HEADER. 
INFO      | Wed Aug 23 10:09:32 EDT 2017 |          Placing results into 'MLE.output.txt' in current working directory. 
INFO      | Wed Aug 23 10:09:32 EDT 2017 |          Cleaning up... 
INFO      | Wed Aug 23 10:09:32 EDT 2017 | STEP #5: LOAD MLE RESULTS INTO R AND COMPUTE BAYES FACTOR TABLES. 
INFO      | Wed Aug 23 10:09:32 EDT 2017 |          Calculating Bayes factors in R using '2logeB10.R' script... 
INFO      | Wed Aug 23 10:09:33 EDT 2017 |          R calculations complete. 
INFO      | Wed Aug 23 10:09:33 EDT 2017 | Done summarizing marginal-likelihood estimation results in BEAST using MLEResultsProc. 
INFO      | Wed Aug 23 10:09:33 EDT 2017 | Bye.

```

## Bayes factors

The Bayes factors output by this procedure are 2loge(B10) Bayes factors (Kass and Raftery 1995). The scale for interpreting these Bayes factors is shown at the bottom right of p. 777 in Kass and Raftery (1995), which I reproduce here for convenience:

| 2loge(B10)             | \*Evidence against null hypothesis (H0)    |
| :--------------------- |:------------------------------------------|
| 0 to 2                 | Not worth more than a bare mention        |
| 2 to 6                 | Positive                                  |
| 6 to 10                | Strong                                    |
| >10                    | Very strong ["decisive"]                  |

**\*Bayes factors provide "weight of evidence" for or against a hypothesis; and during a MLEResultsProc analysis, Bayes factors are output as pairwise, "row-by-column" comparisons. Thus, a positive 2loge(B10) Bayes factor value for the model in a given row is indicative that that model has greater weight of evidence than the model in the corresponding column of the comparison.**

To conduct the R analysis, the '2logeB10.r' R script present in the MLEResultsProc folder is simply called from within the MLEResultsProc.sh script. If PS- and SS-based marginal-likelihood estimates are available in the output files being analyzed, then, in addition to a Bayes factor table, a second table will be output by R showing differences in the Bayes factors from the different methods, for all pairwise comparisons. This allows the user to easily see how the magnitude of Bayes factor support changes with a change in method.

## REFERENCES

- Baele G, Lemey P, Bedford T, Rambaut A, Suchard MA, Alekseyenko AV (2012) Improving the accuracy of demographic and molecular clock model comparison while accommodating phylogenetic uncertainty. Molecular Biology and Evolution, 29, 2157-2167.
- Bouckaert R, Heled J, Künert D, Vaughan TG, Wu CH, Xie D, Suchard MA, Rambaut A, Drummond AJ (2014) BEAST2: a software platform for Bayesian evolutionary analysis. PLoS Computational Biology, 10, e1003537.
- Drummond AJ, Suchard MA, Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and the BEAST 1.7. Molecular Biology and Evolution, 29, 1969-1973.
- Grummer JA, Bryson RW Jr, Reeder TW. 2014. Species delimitation using Bayes factors: simulations and application to the _Sceloporus scalaris_ species group (Squamata: Phrynosomatidae). Systematic Biology, 63, 119–133.
- Kass RE, Raftery AE (1995) Bayes factors. Journal of the American Statistical Association, 90, 773–795.
- Xie W, Lewis PO, Fan Y, Kuo L, Chen MH (2011) Improving marginal likelihood estimation for Bayesian phylogenetic model selection. Systematic Biology, 60, 150-160.

August 22, 2017
Justin C. Bagley, Richmond, VA, USA
