# etc

As is typical of UNIX/Linux distributions and software, this etc/ directory contains the configuration files needed for the main script and all functions within this repository.

## snapp_runner.cfg

This is the default configuration file for the `SNAPPRunner` function, with six variables.

## beast_runner_default.cfg

This is the default configuration file for the `BEASTRunner` function, with seven variables.

## dadi_runner_default.cfg

This is the default configuration file for the `dadiRunner` function, with six variables.

## raxml_runner.cfg

This is the default configuration file for the `RAxMLRunner` function, with four variables.

## pushover.cfg.sample

To use the [Pushover][1] notification function in your scripts take the following steps.

1. If you haven't done so already, create a [Pushover][1] account and create a Pushover application.
2. Rename `pushover.cfg.sample` to `pushover.cfg`
3. Add your user API key and your application API key to this file.

If you don't want to pay for the Pushover service, then consider using the [Pullover][2] client for Linux or Mac.

[1]: https://pushover.net
[2]: https://github.com/cgrossde/Pullover
