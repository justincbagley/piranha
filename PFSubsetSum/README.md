# README

THIS SCRIPT automates calculating basic summary statistics for each subset in the final 'best' partitioning scheme identified for a dataset by PartitionFinder (Lanfear et al. 2012, 2016). Within each run folder, PartitionFinder creates a sub-folder for the analysis, named 'analysis', in which a final 'best_scheme.txt' file is created that contains information on the optimized partitioning scheme and models of sequence evolution for the dataset. PFSubsetSum.sh is made to run within the analysis folder, where it will calculate (1) numCharsets (number of character sets) and (2) subsetLengths (alignment lengths in bp) for each subset in the scheme. These basic statistics are written in table format to a file named 'sumstats.txt', where they are saved alongside subset names, models, and other subset information from PartitionFinder. Testing has been conducted on PartitionFinder v1.1.1++.

```
$ chmod u+x ./*.sh
$ ./PFSubsetSum.sh 

##########################################################################################
#                           PFSubsetSum v1.0, September 2016                             #
##########################################################################################

INFO      | Tue Aug 22 18:11:29 EDT 2017 | STEP #1: SETUP. 
INFO      | Tue Aug 22 18:11:29 EDT 2017 |          Setting working directory to: ../strob_greedy_beast_run1_26subsets/analysis 
INFO      | Tue Aug 22 18:11:29 EDT 2017 | STEP #2: DETECT AND READ PartitionFinder INPUT FILE. 
INFO      | Tue Aug 22 18:11:29 EDT 2017 |          Found PartitionFinder 'best_scheme.txt' input file... 
INFO      | Tue Aug 22 18:11:29 EDT 2017 | STEP #3: COMPUTE SUMMARY STATISTICS FOR EACH SUBSET. 
INFO      | Tue Aug 22 18:11:29 EDT 2017 |          Extracting and organizing subsets...  
INFO      | Tue Aug 22 18:11:29 EDT 2017 |          The best scheme from PartitionFinder contains  26 subsets.  
INFO      | Tue Aug 22 18:11:29 EDT 2017 |          1. Calculating numCharsets (number of character sets) within each subset in the scheme...  
INFO      | Tue Aug 22 18:11:30 EDT 2017 |          2. Calculating subsetLengths (alignment lengths in bp) for each subset in the scheme...  
INFO      | Tue Aug 22 18:11:35 EDT 2017 |          3. Extracting subsetModels (selected models of DNA sequence evolution) for each subset in the scheme...  
INFO      | Tue Aug 22 18:11:35 EDT 2017 |          4. Making file 'sumstats.txt' with subset summary statistics table...  
INFO      | Tue Aug 22 18:11:35 EDT 2017 | Done calculating summary statistics for subsets in your best PartitionFinder scheme. 
INFO      | Tue Aug 22 18:11:35 EDT 2017 | Bye. 
```

## REFERENCES

- Lanfear R, Calcott B, Ho SYW, Guindon S (2012) PartitionFinder: combined selection of partitioning schemes and substitution models for phylogenetic analyses. Molecular Biology and Evolution, 29,1695-1701.
- Lanfear R, Frandsen PB, Wright AM, Senfeld T, Calcott B (2016) PartitionFinder 2: new methods for selecting partitioned models of evolution for molecular and morphological phylogenetic analyses. Molecular Biology and Evolution.
