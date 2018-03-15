# PHYLIP2NEXUS

THIS SHELL script, ```PHYLIP2NEXUS.sh```, converts a single PHYLIP-formatted DNA sequence alignment file present in the current working directory into NEXUS format. The starting file must have the extension ".phy", and the first line of this file must contain the  number of taxa, followed by one space, followed by the number of characters in the  alignment. Some actions are echoed to screen. The output is a single NEXUS file with the name, "BASENAME.nex", where "BASENAME" is the base or root name of the original PHYLIP file. For example, in a starting file named "Smerianae_ND4.phy," BASENAME would  be "Smerianae_ND4" and the resulting output file would be named "Smerianae_ND4.nex". 

I have not had time to add help texts yet, but I recently added two new options--one for specifying a partitions file (-p), and another related option for specifying the format of the partitions file (-f). If the partitions file is given, then the script expects partitions file format to be of either RAxML format  (specified with 'raxml') or NEXUS format ('NEX' or 'nex'). The RAxML format is the same format used in RAxML (e.g. v8+, Stamatakis 2014) and output by PartitionFinder 1 and 2 (Lanfear et al. 2012, 2014), and both this format and the more traditional NEXUS charset format (i.e. ```begin sets; ... charset 1 = 1-xxx;```) will be  familiar to most users.

## References:

- Drummond AJ, Suchard MA, Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and the BEAST 1.7. Mol. Biol. Evol. 29, 1969-1973.
- Heled J, Drummond AJ (2010) Bayesian inference of species trees from multilocus data. Mol Biol Evol. 27(3):570–580.

March 15, 2018
Justin C. Bagley, Richmond, VA
