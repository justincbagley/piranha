# BEASTRerun

THI SCRIPT expects to start from a set of BEAST run sub-folders in the current working directory. Each sub-folder will correspond to a run that has been (or will be) submitted to a remote supercomputing cluster with a Linux operating system, and either a TORQUE/PBS or SLURM scheudling and resource management system. As a consequence, each run sub-folder will contain a run submission shell script for queuing on the supercomputer. BEASTReset saves the user time by automating the resetting of the random starting number seeds in each submission shell script. 

This is **very useful** when the set of run folders has been transferred and queued on the supercomputer, and the user suspects that the XML files are fine, but some runs failed because BEAST failed to find a good initialization state (e.g. prior likelihood). This problem could be overcome by using a different random number seed. Under such cases, which are quite common, BEAST will print all the parameters contributing to a poor starting point and then issue an error message including a line saying 'Fatal exception: Could not find a proper state to initialise. Perhaps try another seed.' Here is an example of this type of error, which BEAST will kick out to screen (when run interactively) or to STDOUT:
 
```
     P(posterior) = -Infinity (was -Infinity)
	P(speciescoalescent) = -Infinity (was -Infinity)
		P(SpeciesTreePopSize.Species1) = -7.0 (was -7.0)
		P(treePrior.t:balf_tree) = -Infinity (was -Infinity)
	P(prior) = NaN (was NaN)  **
		P(BirthDeath.t:Species) = NaN (was NaN)  **
		P(GammaShapePrior.s:p10_site) = -1.0 (was -1.0)
		P(GammaShapePrior.s:p11_site) = -1.0 (was -1.0)
		P(GammaShapePrior.s:p12_site) = -1.0 (was -1.0)
		P(GammaShapePrior.s:p13_site) = -1.0 (was -1.0)
		P(GammaShapePrior.s:p14_site) = -1.0 (was -1.0)
		P(GammaShapePrior.s:p15_site) = -1.0 (was -1.0)
		.
		.
		.
java.lang.RuntimeException: Could not find a proper state to initialise. Perhaps try another seed.
	at beast.core.MCMC.run(Unknown Source)
	at beast.app.BeastMCMC.run(Unknown Source)
	at beast.app.beastapp.BeastMain.<init>(Unknown Source)
	at beast.app.beastapp.BeastMain.main(Unknown Source)
Fatal exception: Could not find a proper state to initialise. Perhaps try another seed.
java.lang.RuntimeException: An error was encounted. Terminating BEAST
	at beast.app.util.ErrorLogHandler.publish(Unknown Source)
	at java.util.logging.Logger.log(Logger.java:738)
	at java.util.logging.Logger.doLog(Logger.java:765)
	at java.util.logging.Logger.log(Logger.java:788)
	at java.util.logging.Logger.severe(Logger.java:1463)
	at beast.app.beastapp.BeastMain.<init>(Unknown Source)
	at beast.app.beastapp.BeastMain.main(Unknown Source)   '
```
 
## DEPENDENCIES

Currently, the only dependency for BEASTReset is [Python](https://www.python.org/downloads/) v2.7++ or v3++. BEASTReset is part of the [PIrANHA](https://github.com/justincbagley/PIrANHA) software repository (Bagley 2017). See the BEASTReset and PIrANHA README files for additional information.

## USAGE

This script accepts as mandatory input the name of the workingDir where the program should be run. Options are as follows (first part of Usage text):

```
Usage: $(basename "$0") [Help: -h help] [Options: -i s m] workingDir 
 ## Help:
  -h   help text (also: -help)
  -H   verbose help text (also: -Help)

 ## Options:
  -i   rerunList (def: $MY_RERUN_DIR_LIST) name of BEAST run sub-folders that need to be reset/rerun
  -s   scriptName (def: $MY_RUN_SCRIPT) name of shell/bash run submission script (must be the
       same for all runs, or entered with wildcards to accommodate all names used, e.g. 'beast*.sh')
  -m   manager (def: $MY_SC_MANAGEMENT_SYS) name of scheduling and resource manager system on the supercomputer

```

The main options determining the form of a run is the -i flag, which takes the name of a list file (e.g. 'list.txt' by default) containing names of sub-folders to be analyzed, one per line; and the -s flag, which specifies the name of the submission shell scripts (which must all be the same, or be entered with wildcards to accomodate all names used, e.g. 'beast*.sh'). These options are critical for customizing the run. The -m flag is currently experimental, so _do not_ use it. 

After detecting the local computing environment with the <uname> utility, BEASTReset.sh will perform one of two general operations, with two sub-options (a or b). (1a) If the environment is Mac OS X and no list of sub-folders is provided, then the script assumes the environment is the user's local Mac machine, and it goes through all sub-folders, looks for the submission script (-s flag), and then resets the seed in each script. In a similar case, the script (1b) accepts the list of sub-folders that failed (specified using the -i flag) and only modifies shell scripts in this list file. Alternatively, (2a) if the environment is Linux and no list file is specified, then the script assumes the environment is the remote supercomputer, and it will go through all sub-folders and reset the seed in each submission script (-s flag). Again, the script will also (2b) accept a list of sub-folders that failed (-i flag), which must contain paths to run sub-folders on the supercomputer, with on path per line). 


## REFERENCES

- Bagley, J.C. 2017. PIrANHA v0.1.5. GitHub repository, Available at: <http://github.com/justincbagley/PIrANHA>.

August 24, 2017
Justin C. Bagley, Richmond, VA
