# Example output to screen during a single run of SNAPPRunner 

This SNAPPRunner run created, moved, and queued 10 replicate runs of SNAPP from different
starting seeds, all starting from a single XML file and the SNAPPRunner files.

```
$ ./SNAPPRunner.sh -n 10 -p m8 .
INFO      | Wed May 10 22:28:35 EDT 2017 |          Setting user-specified path to: 
. 

##########################################################################################
#                               SNAPPRunner v1.0, May 2017                               #
##########################################################################################
INFO      | Wed May 10 22:28:35 EDT 2017 | Starting SNAPPRunner pipeline... 
INFO      | Wed May 10 22:28:35 EDT 2017 | STEP #1: SETUP VARIABLES, MAKE 9 COPIES PER INPUT XML FILE FOR A TOTAL OF FIVE RUNS OF EACH MODEL/XML USING
INFO      | Wed May 10 22:28:35 EDT 2017 |          DIFFERENT RANDOM SEEDS. 
INFO      | Wed May 10 22:28:35 EDT 2017 |          Setting up variables, including those specified in the cfg file...
INFO      | Wed May 10 22:28:35 EDT 2017 |          Number of XML files read:        1
INFO      | Wed May 10 22:28:35 EDT 2017 | STEP #2: MAKE 9 COPIES PER INPUT .XML FILE FOR A TOTAL OF 10 RUNS OF EACH MODEL or 
INFO      | Wed May 10 22:28:35 EDT 2017 |          .XML USING DIFFERENT RANDOM SEEDS. 
INFO      | Wed May 10 22:28:35 EDT 2017 |          Looping through original .xml's and making 9 copies per file, renaming each copy with an extension of '_#.xml'
INFO      | Wed May 10 22:28:35 EDT 2017 |          where # ranges from 2 - 10. *** IMPORTANT ***: The starting .xml files MUST end in 'run.xml'.
INFO      | Wed May 10 22:28:35 EDT 2017 | STEP #3: MAKE DIRECTORIES FOR RUNS AND GENERATE SHELL SCRIPTS UNIQUE TO EACH INPUT FILE FOR DIRECTING EACH RUN. 
INFO      | Wed May 10 22:28:36 EDT 2017 |          Setup and run check on the number of run folders created by the program...
INFO      | Wed May 10 22:28:36 EDT 2017 |          Number of run folders created: 10
INFO      | Wed May 10 22:28:36 EDT 2017 | STEP #4: CREATE BATCH SUBMISSION FILE, MOVE ALL RUN FOLDERS CREATED IN PREVIOUS STEP AND SUBMISSION FILE TO SUPERCOMPUTER. 
INFO      | Wed May 10 22:28:36 EDT 2017 |          Copying run folders to working dir on supercomputer...
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_1.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_10.xml                                                                                      100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  933     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_2.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_3.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_4.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_5.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_6.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_7.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_8.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
Hyp_DAPC_vSO_fixedUV_gamma_10mil_1000_run_9.xml                                                                                       100%   22KB  22.0KB/s   00:00    
snapp_sbatch.sh                                                                                                                          100%  931     0.9KB/s   00:00    
INFO      | Wed May 10 22:29:02 EDT 2017 |          Batch queue submission file (SNAPPRunner_batch_qsub.sh) successfully created. 
INFO      | Wed May 10 22:29:02 EDT 2017 |          Also copying configuration file to supercomputer...
snapp_runner.cfg                                                                                                                         100% 2844     2.8KB/s   00:00    
INFO      | Wed May 10 22:29:04 EDT 2017 |          Also copying sbatch_file to supercomputer...
SNAPPRunner_batch_qsub.sh                                                                                                                100% 1581     1.5KB/s   00:00    
INFO      | Wed May 10 22:29:06 EDT 2017 | STEP #5: SUBMIT ALL JOBS TO THE QUEUE. 
Pseudo-terminal will not be allocated because stdin is not a terminal.
FSL offers free workflow and code optimization, performance tuning, and more.

Notices:
 * Two-factor authentication [https://marylou.byu.edu/account/authenticate/enroll] now available.

../SNAPP/new_runs2
Submitted batch job 16280750
Submitted batch job 16280751
Submitted batch job 16280752
Submitted batch job 16280753
Submitted batch job 16280754
Submitted batch job 16280755
Submitted batch job 16280756
Submitted batch job 16280757
Submitted batch job 16280758
Submitted batch job 16280759
INFO      | Wed May 10 22:29:09 EDT 2017 |          Finished copying run folders to supercomputer and submitting SNAPP jobs to queue!!
INFO      | Wed May 10 22:29:09 EDT 2017 |          Cleaning up: removing temporary files from local machine...
INFO      | Wed May 10 22:29:09 EDT 2017 |          Bye.
```
