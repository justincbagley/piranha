#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by PIrANHA bash scripts.
#
# VERSION 1.0.0
#
# HISTORY
# * 2019-03-08 - v1.0.0 - First Creation (edited from sharedVariables.sh script
#                         by Nate Landau, from a forked version of his shell-scripts repository,
#                         which he last had as v1.0.3, last updated 2016-01-13 (see below))
#
# Pre-PIrANHA / Phylos, version updates by Nate Landau:
# * 2015-01-02 - v1.0.0 - First Creation
# * 2015-08-05 - v1.0.1 - Now has $hourstamp (10:34:40 PM)
# * 2016-01-10 - v1.0.2 - Now has $longdate and set LC_ALL=C to all dates
# * 2016-01-13 - v1.0.3 - now has $gmtdate
# ##################################################

# SCRIPTNAME
# ------------------------------------------------------
# Will return the name of the script being run
# ------------------------------------------------------
SCRIPT_NAME="$(basename $0)" #Set Script Name variable
SCRIPT_BASENAME="$(basename ${SCRIPT_NAME} .sh)" # Strips '.sh' from scriptName

# COMMON FUNCTIONS
# ------------------------------------------------------
# Several scripts used in setup / start up for all PIrANHA bash scripts:
# ------------------------------------------------------
CR=$(printf '\r')
TAB=$(printf '\t')
calc () {
	bc -l <<< "$@"
}

# TIMESTAMPS
# ------------------------------------------------------
# Prints the current date and time in a variety of formats:
#
# ------------------------------------------------------
now=$(LC_ALL=C date +"%m-%d-%Y %r")        # Returns: 06-14-2015 10:34:40 PM
datestamp=$(LC_ALL=C date +%Y-%m-%d)       # Returns: 2015-06-14
hourstamp=$(LC_ALL=C date +%r)             # Returns: 10:34:40 PM
timestamp=$(LC_ALL=C date +%Y%m%d_%H%M%S)  # Returns: 20150614_223440
today=$(LC_ALL=C date +"%m-%d-%Y")         # Returns: 06-14-2015
longdate=$(LC_ALL=C date +"%a, %d %b %Y %H:%M:%S %z")  # Returns: Sun, 10 Jan 2016 20:47:53 -0500
gmtdate=$(LC_ALL=C date -u -R | sed 's/\+0000/GMT/') # Returns: Wed, 13 Jan 2016 15:55:29 GMT

# CURRENTHOST
# ------------------------------------------------------
# Will print the current hostname of the computer the script
# is being run on.
# ------------------------------------------------------
CURRENT_HOST="$(hostname)"
