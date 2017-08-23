# README

<<<<<<< Updated upstream
THIS SCRIPT aids post-processing of multiple BEAST1 or BEAST2 (Drummond et al. 2012; Bouckaert et al. 2014) runs for marginal-likelihood or Bayes factor model comparison, for example as in the Bayes factor delimitation (BFD) procedure of Grummer et al. (2014). The script expects that the user has conducted multiple BEAST runs that each included a marginal-likelihood estimation step, using either path sampling (PS) and stepping-stone sampling (SS) (Xie et al. 2011; Baele et al. 2012). Marginal-likelihood estimation should be performed on all models using the same software program, because while MLEResultsProc can accommodate output files from either BEAST v1++ or BEAST v2++, _but not a mixture of output files from both programs_. The user must then copy the ".out" files from each run (making sure they have unique names, e.g. matching the corresponding model) into a working directory for MLEResultsProc analysis. 
=======
THIS SCRIPT aids post-processing of multiple BEAST1 or BEAST2 (Drummond et al. 2012; Bouckaert et al. 2014) runs for marginal-likelihood or Bayes factor model comparison, for example as in the Bayes factor delimitation (BFD) procedure of Grummer et al. (2014). The script expects that the user has conducted multiple BEAST runs that each included a marginal-likelihood estimation step, using either path sampling (PS) and stepping-stone sampling (SS) (Xie et al. 2011; Baele et al. 2012). The user must then copy the ".out" files from each run (making sure they have unique names, e.g. matching name of the corresponding model) into a working directory for MLEResultsProc analysis. **IMPORTANT: MLEResultsProc can accommodate output files from either BEAST v1++ or BEAST v2++, but _not a mixture of output files from both programs_.** 
>>>>>>> Stashed changes

Under this scenario, 'MLEResultsProc.sh' automates extracting the path sampling (PS) and/or stepping-stone sampling (SS) marginal-likelihood estimates from the final sections of the output file for each model, arranging the MLE estimates into a summary table file in the current working dir, and then loading the results file into R and computing Bayes factor tables comparing the models. 

## Bayes factors

<<<<<<< Updated upstream
The Bayes factors output by this procedure are 2loge(B10) Bayes factors (Kass and Raftery 1995). The scale for interpreting these Bayes factors is shown at the bottom left of p. 777 in Kass and Raftery (1995), which I reproduce here for convenience:
=======
The Bayes factors output by this procedure are 2loge(B10) Bayes factors (Kass and Raftery 1995). The scale for interpreting these Bayes factors is shown at the bottom right of p. 777 in Kass and Raftery (1995), which I reproduce here for convenience:
>>>>>>> Stashed changes

| 2loge(B10)             | \*Evidence against null hypothesis (H0)    |
| :--------------------- |:------------------------------------------|
| 0 to 2                 | Not worth more than a bare mention        |
| 2 to 6                 | Positive                                  |
| 6 to 10                | Strong                                    |
| >10                    | Very strong ["decisive"]                  |

<<<<<<< Updated upstream
**\*Bayes factors provide "weight of evidence" for or against a hypothesis; and during a MLEResultsProc analysis, Bayes factors are output as pairwise, "row-by-column" comparisons. Thus, a positive 2loge(B10) Bayes factor value for the model in a given row is indicative that that model has greater weight of evidence than the model in the corresponding column of the comparison.**
=======
\*Bayes factors provide "weight of evidence" for or against a hypothesis; and during a MLEResultsProc analysis, Bayes factors are output as pairwise, "row-by-column" comparisons. Thus, a positive 2loge(B10) Bayes factor value for the model in a given row is indicative that that model has greater weight of evidence than the model in the corresponding column of the comparison.
>>>>>>> Stashed changes

To conduct the R analysis, the '2logeB10.r' R script present in the MLEResultsProc folder is simply called from within the MLEResultsProc.sh script. If PS- and SS-based marginal-likelihood estimates are available in the output files being analyzed, then, in addition to a Bayes factor table, a second table will be output by R showing differences in the Bayes factors from the different methods, for all pairwise comparisons. This allows the user to easily see how the magnitude of Bayes factor support changes with a change in method.

## REFERENCES

- Baele G, Lemey P, Bedford T, Rambaut A, Suchard MA, Alekseyenko AV (2012) Improving the accuracy of demographic and molecular clock model comparison while accommodating phylogenetic uncertainty. Molecular Biology and Evolution, 29, 2157-2167.
- Bouckaert R, Heled J, Künert D, Vaughan TG, Wu CH, Xie D, Suchard MA, Rambaut A, Drummond AJ (2014) BEAST2: a software platform for Bayesian evolutionary analysis. PLoS Computational Biology, 10, e1003537.
- Drummond AJ, Suchard MA, Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and the BEAST 1.7. Molecular Biology and Evolution, 29, 1969-1973.
- Grummer JA, Bryson RW Jr, Reeder TW. 2014. Species delimitation using Bayes factors: simulations and application to the _Sceloporus scalaris_ species group (Squamata: Phrynosomatidae). Systematic Biology, 63, 119–133.
- Kass RE, Raftery AE (1995) Bayes factors. Journal of the American Statistical Association, 90, 773–795.
- Xie W, Lewis PO, Fan Y, Kuo L, Chen MH (2011) Improving marginal likelihood estimation for Bayesian phylogenetic model selection. Systematic Biology, 60, 150-160.

<<<<<<< Updated upstream
August 22, 2017 Justin C. Bagley, Richmond, VA, USA
=======
August 22, 2017 Justin C. Bagley, Richmond, VA, USA
>>>>>>> Stashed changes
