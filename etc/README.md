# etc

As is typical of UNIX/Linux distributions and software, this etc/ directory contains the configuration files needed for the scripts and functions within this repository.

## snapp_runner.cfg
This is the default configuration file for the SNAPPRunner function, with six variables.

## beast_runner_default.cfg
This is the default configuration file for the BEASTRunner function, with seven variables.

## dadi_runner_default.cfg
This is the default configuration file for the dadiRunner function, with six variables.

## mrbayes_post_proc.cfg
This is the default configuration file for the MrBayesPostProc function, with two variables. It may not be necessary anymore (check).

## raxml_runner.cfg
This is the default configuration file for the RAxMLRunner function, with four variables.

## pushover.cfg.sample
To use the [Pushover][1] notification function in your scripts take the following steps.

1. If you haven't done so already, create a [Pushover][1] account and create a Pushover application.
2. Rename `pushover.cfg.sample` to `pushover.cfg`
3. Add your user API key and your application API key to this file.



[1]: https://pushover.net
