# PFSubsetSum

THIS SCRIPT automates calculating basic summary statistics for each subset in the final 'best' partitioning scheme identified for a dataset by PartitionFinder (Lanfear et al. 2012, 2016). Within each run folder, PartitionFinder creates a sub-folder for the analysis, named 'analysis', in which a final 'best_scheme.txt' file is created that contains information on the optimized partitioning scheme and models of sequence evolution for the dataset. **PFSubsetSum.sh** is made to run within the analysis folder, where it will calculate (1) numCharsets (number of character sets) and (2) subsetLengths (alignment lengths in bp) for each subset in the scheme. 

Subset lengths are calculated by creating (and subsequently removing) an Rscript named GetSubsetLength.r to perform the corresponding calculation; thus, as with several other [PIrANHA](http://github.com/justincbagley/PIrANHA) scripts/utilities, [R](https://cran.r-project.org/) is an important dependency of this software. These basic statistics are written in table format to a file named 'sumstats.txt', where they are saved alongside subset names, models, and other subset information from PartitionFinder. Testing has been conducted on PartitionFinder v1.1.1++.

## USAGE
```
$ cp PFSubsetSum.sh /path/to/PartitionFinder/analysis/folder
$ cd /path/to/PartitionFinder/analysis/folder
$ chmod u+x ./*.sh
$ ./PFSubsetSum.sh 
```

## OUTPUT

Below, I provide an example of output to screen during a recent PFSubsetSum run on a phylogenomic dataset. The analysis took 6 seconds.

```
$ ./PFSubsetSum.sh 

##########################################################################################
#                             PFSubsetSum v1.1, August 2017                              #
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

The 'sumstats.txt' file output by the program is easy to interpret and looks like something like this (i.e. like the best_scheme.txt schemes block, but with new columns containing the summary statistics calculated by PFSubsetSum):
```
###################### PartitionFinder Subsets Summary Statistics ########################
Subset	numCharsets	subsetLength	subsetModel
p1   16  7579   HKY+G      | 0_10054_01WHISP, 0_10267_01WHISP, 0_11508_01WHISP, 0_14221_01WHISP, 0_1949_01WHISP, 0_6448_02WHISP, 0_6659_01WHISP, 2_2501_01WHISP, 2_2960_02WHISP, 2_3591_03WHISP, 2_3852_01WHISP, 2_6491_01WHISP, 2_8627_01WHISP, 2_8852_01WHISP, 2_9665_01WHISP, CL1077Contig1_02WHISP | 1-437, 438-848, 3646-4111, 14072-14681, 23627-23917, 30328-30922, 31352-31587, 42763-43200, 44122-44689, 45015-45519, 45973-46439, 52533-53048, 55938-56404, 56405-56818, 57723-58164, 58165-58880 | ./analysis/phylofiles/a0677dd7f36fc5c3139676cb0e5cb235.phy
p2   26  11791  HKY+G      | 0_10307_01WHISP, 0_10706_01WHISP, 0_11270_01WHISP, 0_12190_02WHISP, 0_12329_02WHISP, 0_12745_01WHISP, 0_1347_01WHISP, 0_14122_02WHISP, 0_16889_02WHISP, 0_2433_01_final, 0_8737_01WHISP, 1_1609_01WHISP, 2_2799_03WHISP, 2_3319_01WHISP, 2_3867_02WHISP, 2_4183_01WHISP, 2_5483_02WHISP, 2_9466_01WHISP, CL1524Contig1_03WHISP, CL1634Contig1_03WHISP, CL1659Contig1_02WHISP, CL1692Contig1_05WHISP, CL1694Contig1_02WHISP, CL180Contig1_03WHISP, CL1905Contig1_03WHISP, CL3321Contig1_03WHISP | 849-1197, 1646-2085, 2557-2966, 6108-6517, 7224-7755, 8179-8624, 11664-12065, 13701-14071, 19597-20262, 24426-24855, 35813-36261, 40658-41140, 43201-43657, 44690-45014, 46440-47122, 47621-48059, 48730-49232, 56819-57253, 60288-60736, 61377-61611, 61828-62281, 62584-62976, 62977-63492, 64229-64857, 65764-66240, 69648-70055 | ./analysis/phylofiles/7457b7590e06cbb49b85ba16d16150b4.phy
p3   4   1724   GTR+I+G    | 0_10602_01WHISP, 0_10754_01WHISP, 0_18439_02WHISP, 0_9457_02WHISP | 1198-1645, 2086-2556, 23370-23626, 38673-39220 | ./analysis/phylofiles/d44d9722ea5ed86e661961ebde89b679.phy
p4   21  9077   TrN+G      | 0_11324_01WHISP, 0_12190_01WHISP, 0_12929_02WHISP, 0_12978_02WHISP, 0_13240_01WHISP, 0_15075_01WHISP, 0_15867_01WHISP, 0_3128_02WHISP, 0_3192_01WHISP, 0_4541_02WHISP, 0_6259_01WHISP, 0_7009_01WHISP, 0_7793_01WHISP, 0_9389_01WHISP, 0_9462_01WHISP, 2_2952_01WHISP, 2_5967_01WHISP, CL149Contig3_04WHISP, CL1879Contig1_02WHISP, CL1966Contig1_05WHISP, CL2332Contig1_01WHISP | 2967-3245, 5642-6107, 8625-9430, 9431-9946, 11204-11663, 16093-16499, 18049-18521, 25722-26180, 26181-26776, 27836-28168, 29916-30327, 32902-33310, 33311-33552, 37696-38217, 39221-39686, 43658-44121, 50398-50654, 59745-60058, 65507-65763, 66241-66744, 67221-67655 | ./analysis/phylofiles/6210f87df73f377d6d3535a802691931.phy
p5   9   3263   K80+G      | 0_11504_01WHISP, 0_11649_03WHISP, 0_18267_01WHISP, 0_8187_02WHISP, 2_6731_01WHISP, 2_7182_01WHISP, CL1521Contig1_01WHISP, CL1806Contig1_01WHISP, CL3271Contig1_02WHISP | 3246-3645, 4112-4455, 22476-22927, 33953-34275, 53049-53484, 54478-54941, 60059-60287, 63899-64228, 69363-69647 | ./analysis/phylofiles/d73b20551946c5c58942ae08f02a94bb.phy
p6   7   3395   HKY+G      | 0_11980_01WHISP, 0_12730_01WHISP, 0_16619_01WHISP, 0_4032_02WHISP, 0_4756_01WHISP, 2_6355_02WHISP, CL3097Contig1_01WHISP | 4456-5167, 7756-8178, 18522-19285, 26984-27376, 28169-28599, 51730-52040, 69002-69362 | ./analysis/phylofiles/09d75a8e74ab1f31a3b60a53516beec3.phy
p7   23  10129  HKY+G      | 0_12156_02WHISP, 0_13913_02WHISP, 0_14837_01WHISP, 0_15329_01WHISP, 0_17206_01WHISP, 0_17215_01WHISP, 0_17247_02WHISP, 0_4105_01WHISP, 0_6878_01WHISP, 0_7844_01WHISP, 0_846_01WHISP, 0_8844_01WHISP, 0_9408_01WHISP, 0_9922_01WHISP, 2_3726_02WHISP, 2_5064_01WHISP, 2_5668_01WHISP, 2_6906_01WHISP, CL1343Contig1_05WHISP, CL1367Contig1_03WHISP, CL1646Contig1_01WHISP, CL2475Contig1_02WHISP, CL3036Contig1_01WHISP | 5168-5641, 12446-12835, 15167-15611, 16966-17418, 20673-21098, 21099-21575, 21576-21997, 27377-27835, 32047-32485, 33553-33952, 34276-34854, 36262-36803, 38218-38672, 40127-40657, 45520-45972, 48060-48729, 49233-49942, 53975-54477, 59190-59418, 59419-59744, 61612-61827, 67656-67905, 68415-68694 | ./analysis/phylofiles/40ada7493a15523abe0a7f8ffb3d6b4f.phy
p8   13  6810   HKY+G      | 0_12216_02WHISP, 0_13058_01WHISP, 0_17017_01WHISP, 0_18296_01WHISP, 0_5601_01WHISP, 0_6116_01WHISP, 0_7001_01WHISP, 0_9383_01WHISP, 2_10212_01WHISP, 2_5724_02WHISP, 2_6313_01WHISP, 2_9542_01WHISP, CL3795Contig1_01WHISP | 6518-7223, 9947-10588, 20263-20672, 22928-23369, 29060-29424, 29425-29915, 32486-32901, 37215-37695, 41547-42267, 49943-50397, 51083-51729, 57254-57722, 70867-71431 | ./analysis/phylofiles/0c52856c4073539400854f18489db02c.phy
p9   2   499    SYM+I+G    | 0_13152_03WHISP, CL1213Contig1_01WHISP | 10589-10778, 58881-59189       | ./analysis/phylofiles/2d06cb5c753bf000a663fca948ca2d0d.phy
p10  6   2237   SYM+G      | 0_13237_01WHISP, 0_14976_01WHISP, 2_4107_01WHISP, CL1669Contig1_04WHISP, CL1848Contig1_01WHISP, CL363Contig1_04WHISP | 10779-11203, 15612-16092, 47123-47620, 62282-62583, 64858-65177, 70372-70582 | ./analysis/phylofiles/da2ad9cbb18ff2a16249b863b2fe0469.phy
p11  8   3015   HKY+I+G    | 0_13680_01WHISP, 0_13957_02WHISP, 0_13978_01WHISP, 0_15762_01WHISP, 2_7189_01WHISP, CL1767Contig1_02WHISP, CL2565Contig1_03WHISP, CL2637Contig1_04WHISP | 12066-12445, 12836-13295, 13296-13700, 17680-18048, 54942-55427, 63493-63898, 67906-68173, 68174-68414 | ./analysis/phylofiles/d0fb53f382d811e5cfcbaaf00f35d250.phy
p12  2   914    TrN+G      | 0_1439_01WHISP, 0_6465_01WHISP | 14682-15166, 30923-31351       | ./analysis/phylofiles/331a6f383620cd7ab827aec5c9337670.phy
p13  10  3688   K80+I+G    | 0_15187_01WHISP, 0_15361_01WHISP, 0_18261_01WHISP, 0_3073_01WHISP, 1_5675_01WHISP, 2_684_01WHISP, CL1588Contig1_04WHISP, CL1852Contig1_01WHISP, CL305Contig1_05WHISP, CL3770Contig1_01WHISP | 16500-16965, 17419-17679, 21998-22475, 25282-25721, 41141-41546, 53485-53974, 60947-61173, 65178-65506, 68695-69001, 70583-70866 | ./analysis/phylofiles/d7817c6e7d92a5ab1b507b1b383b59b3.phy
p14  13  4872   K80+G      | 0_1688_02WHISP, 0_2354_01WHISP, 0_3969_01WHISP, 0_6683_01WHISP, 0_8531_01WHISP, 0_9749_01WHISP, 2_6052_01WHISP, 2_6457_01WHISP, 2_8011_02WHISP, CL1536Contig1_03WHISP, CL206Contig1_03WHISP, CL2123Contig1_03WHISP, CL357Contig1_09WHISP | 19286-19596, 23918-24425, 26777-26983, 31588-32046, 34855-35369, 39687-40126, 50655-51082, 52041-52532, 55428-55937, 60737-60946, 66745-66952, 66953-67220, 70056-70371 | ./analysis/phylofiles/60f79d2e10985329d220285d5c099101.phy
p15  5   1995   HKY+G      | 0_2456_01WHISP, 0_5364_02WHISP, 0_9063_01WHISP, 2_1030_01WHISP, CL1614Contig1_04WHISP | 24856-25281, 28600-29059, 36804-37214, 42268-42762, 61174-61376 | ./analysis/phylofiles/fd6e58f0cdedd9a865608edbb4b7033d.phy
p16  1   443    K80+I+G    | 0_8683_01WHISP                 | 35370-35812                    | ./analysis/phylofiles/0940cc0d1e5407a4ffe4257a5c084c0b.phy
```

This output can easily be placed into a summary table in the main text of a manuscript, or in an Appendix or other Supporting Information file for your manuscript.

## REFERENCES

- Lanfear R, Calcott B, Ho SYW, Guindon S (2012) PartitionFinder: combined selection of partitioning schemes and substitution models for phylogenetic analyses. Molecular Biology and Evolution, 29,1695-1701.
- Lanfear R, Frandsen PB, Wright AM, Senfeld T, Calcott B (2016) PartitionFinder 2: new methods for selecting partitioned models of evolution for molecular and morphological phylogenetic analyses. Molecular Biology and Evolution.

August 26, 2017
Justin C. Bagley, Richmond, VA, USA
