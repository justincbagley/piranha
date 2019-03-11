This directory contains the configuration files needed for the scripts and functions within this repository.

# pushover.cfg
Configuration file to use the [Pushover][1] notification function in Phylos scripts

Steps to create:
1. Got etc/ from Nate Landau shell-scripts repository fork.
2. Had to create a [Pushover][1] account and create a Pushover application, to get token / API.
3. Renamed `pushover.cfg.sample` to `pushover.cfg`
4. Added my user API key and my Phylos application API token / key to this file.

When Phylos is ready to ship to any/all public users, don't forget to make install or startup script that will query user for their Pushover API key and replace a dummy var here with their key. 

*Don't make repo public containing your personal Pushover user API key!!!*


[1]: https://pushover.net