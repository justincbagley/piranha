# README

THIS SCRIPT aids post-processing of multiple BEAST1 or BEAST2 (Drummond et al. 2012; Bouckaert et al. 2014) runs for marginal-likelihood or Bayes factor model comparison, for example as in the Bayes factor delimitation (BFD) procedure of Grummer et al. (2014). The script expects that the user has conducted multiple BEAST runs that each included a marginal-likelihood estimation step, using either path sampling (PS) and stepping-stone sampling (SS) (Xie et al. 2011; Baele et al. 2012). The user must then copy the ".out" files from each run (making sure they have unique names, e.g. matching name of the corresponding model) into a working directory for MLEResultsProc analysis. 

Under this scenario, 'MLEResultsProc.sh' automates extracting the path sampling (PS) and/or stepping-stone sampling (SS) results from the final sections of the output file for each model, and then organizing them into a summary table file in the current working dir.

## REFERENCES

- Baele G, Lemey P, Bedford T, Rambaut A, Suchard MA, Alekseyenko AV (2012) Improving the accuracy of demographic and molecular clock model comparison while accommodating phylogenetic uncertainty. Molecular Biology and Evolution, 29, 2157-2167.
- Bouckaert R, Heled J, Künert D, Vaughan TG, Wu CH, Xie D, Suchard MA, Rambaut A, Drummond AJ 
(2014) BEAST2: a software platform for Bayesian evolutionary analysis. PLoS Computational 
Biology, 10, e1003537.
- Drummond AJ, Suchard MA, Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and the 
BEAST 1.7. Molecular Biology and Evolution, 29, 1969-1973.
- Grummer JA, Bryson RW Jr, Reeder TW. 2014. Species delimitation using Bayes factors: simulations and application to the _Sceloporus scalaris_ species group (Squamata: Phrynosomatidae). Systematic Biology 63: 119–133.
- Xie W, Lewis PO, Fan Y, Kuo L, Chen MH (2011) Improving marginal likelihood estimation for Bayesian phylogenetic model selection. Systematic Biology, 60, 150-160.
