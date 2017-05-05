# Example dadiRunner Run - Screen Output

Here is a copy of output to screen during a recent run of dadiRunner, in which 10 indpendent
runs were conducted on a starting/model file named 'M12_run.py', containing instructions for
'M12' (model 12 in a set). Non-default settings include the input file name and walltime
passed to the shell script, and subsequently the supercomputer, for each run, which was 
changed from the default value of 48 hrs (2 day) to a value of 168 hrs (7 days) since it 
was unclear how long the runs would take (but previous runs suggested that they could take
more than 24 hrs).

```
$ ./dadiRunner.sh -i core-periphery-LP.sfs -n 10 -w 168:00:00 .
INFO      | Fri May  5 15:24:55 EDT 2017 |          Setting user-specified path to: 
. 

##########################################################################################
#                             dadiRunner v0.1.0, April 2017                              #
##########################################################################################
INFO      | Fri May  5 15:24:55 EDT 2017 | Starting dadiRunner pipeline... 
INFO      | Fri May  5 15:24:55 EDT 2017 | STEP #1: SETUP. 
INFO      | Fri May  5 15:24:55 EDT 2017 |          Setting up variables, including those specified in the cfg file...
INFO      | Fri May  5 15:24:55 EDT 2017 |          Setting working directory to: . 
INFO      | Fri May  5 15:24:55 EDT 2017 |          Number of .py ∂a∂i input files read:        1
INFO      | Fri May  5 15:24:55 EDT 2017 | STEP #2: MAKE 9 COPIES PER INPUT .PY FILE FOR A TOTAL OF 10 RUNS OF EACH MODEL or 
INFO      | Fri May  5 15:24:55 EDT 2017 |          .PY USING DIFFERENT RANDOM SEEDS. 
INFO      | Fri May  5 15:24:55 EDT 2017 |          Looping through original .py's and making 9 copies per file, renaming each copy with an extension of '_#.py'
INFO      | Fri May  5 15:24:55 EDT 2017 |          where # ranges from 2 - 10. *** IMPORTANT ***: The starting .py files MUST end in 'run.py'.
INFO      | Fri May  5 15:24:55 EDT 2017 | STEP #3: MAKE DIRECTORIES FOR RUNS AND GENERATE SHELL SCRIPTS UNIQUE TO EACH INPUT FILE FOR DIRECTING EACH RUN. 
INFO      | Fri May  5 15:24:56 EDT 2017 |          Setup and run check on the number of run folders created by the program...
INFO      | Fri May  5 15:24:56 EDT 2017 |          Number of run folders created: 10
INFO      | Fri May  5 15:24:56 EDT 2017 | STEP #4: CREATE BATCH SUBMISSION FILE, MOVE ALL RUN FOLDERS CREATED IN PREVIOUS STEP AND SUBMISSION FILE TO SUPERCOMPUTER. 
INFO      | Fri May  5 15:24:56 EDT 2017 |          Copying run folders to working dir on supercomputer...
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_1.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  650     0.6KB/s   00:00    
M12_run_10.py                                                                                                                            100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_2.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_3.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_4.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_5.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_6.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_7.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_8.py                                                                                                                             100% 4079     4.0KB/s   00:00    
core-periphery-LP.sfs                                                                                                             100% 5661KB   5.5MB/s   00:01    
dadi_pbs.sh                                                                                                                              100%  647     0.6KB/s   00:00    
M12_run_9.py                                                                                                                             100% 4079     4.0KB/s   00:00    
INFO      | Fri May  5 15:25:32 EDT 2017 |          Batch queue submission file ('dadirunner_batch_qsub.sh') successfully created. 
INFO      | Fri May  5 15:25:32 EDT 2017 |          Also copying configuration file to supercomputer...
dadi_runner.cfg                                                                                                                          100% 2449     2.4KB/s   00:00    
INFO      | Fri May  5 15:25:34 EDT 2017 |          Also copying batch_qsub_file to supercomputer...
dadirunner_batch_qsub.sh                                                                                                                 100% 1010     1.0KB/s   00:00    
INFO      | Fri May  5 15:25:36 EDT 2017 | STEP #5: SUBMIT ALL JOBS TO THE QUEUE. 
Pseudo-terminal will not be allocated because stdin is not a terminal.
Try the Julia language: easy to use, designed for scientists, almost fast as C

Notices:
 * Two-factor authentication [https://$PATH] now available.

Alerts:
 * Slurm will be upgraded this morning.  sacct, sreport, and a few other tools that query the Slurm database will be unavailable for a few hours.  Jobs will keep running and other commands should still work.

$PATH/dadi-mod_runs
Error: deactivate must be sourced. Run 'source deactivate'
instead of 'deactivate'.

16176260

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176261

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176262

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176263

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176264

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176265

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176267

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176268

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
16176269

qsub is no longer officially supported. There are no plans to remove the qsub wrapper but staff will no longer support users in its usage.  Please use sbatch.
INFO      | Fri May  5 15:26:11 EDT 2017 |          Finished copying run folders to supercomputer and submitting ∂a∂i jobs to queue!!
INFO      | Fri May  5 15:26:11 EDT 2017 | STEP #6: CLEANUP: REMOVE UNNECESSARY FILES. 
INFO      | Fri May  5 15:26:11 EDT 2017 |          Cleaning up: removing temporary files from local machine...
INFO      | Fri May  5 15:26:11 EDT 2017 | Done organizing and copying SNP data and model files to supercomputer and submitting ∂a∂i 
INFO      | Fri May  5 15:26:11 EDT 2017 | jobs to the queue, using the dadiRunner pipeline. 
INFO      | Fri May  5 15:26:11 EDT 2017 | Bye.

```

