#!/bin/sh

##########################################################################################
#                           estpostCompiler v0.1.0, July 2017                            #
#  SHELL SCRIPT THAT COMPILES THE estpost UTILITY WITHIN THE bgc (BAYESIAN GENOMIC CLINE #
#  SOFTWARE) DISTRIBUTION                                                                #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further information. Last update: July 5, 2017. #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

############ SCRIPT OPTIONS
## OPTION DEFAULTS ##
MY_SSH_ACCOUNT=NULL

############ CREATE USAGE & HELP TEXTS
Usage="estpostCompiler.sh [Help: -h help] [Options: -a sshAccount] workingDir 
 ## Help:
  -h   help text (also: -help)
 
 ## Options:
  -a   sshAccount (def: NULL) single line containing one ssh address to be used for 
       logging onto your supercomputer account, including username and hostname (e.g. 
       ssh USERNAME@HOSTADDRESS). If null, ssh account info is pulled from bgc_runner.cfg
       configuration file in current working directory.

 OVERVIEW
 THIS IS a shell script for compiling the estpost utility within the 'bgc' v1.0 software 
 distribution (Gompert & Buerkle 2012), for use on a remote, Linux-based supercomputing 
 cluster. bgc conducts MCMC estimation of parameters of the Bayesian genomic cline model 
 (Gompert & Buerkle 2011). estpost must be compiled before it can be used to summarize 
 posterior distributions of parameter estimates output by the bgc model.
 
 Users are REQUIRED to set up passwordless ssh access prior to running this script. This 
 will allow you to avoid the script being halted by a password prompt; I cannot guarantee
 that the script will work without passwordless ssh. If you have not set up passwordless
 ssh acces, or are unsure about this, then you should create and organize appropriate and
 secure public and private ssh keys on your machine and the remote supercomputer prior to 
 running. By "secure," I mean that, during this process, you should have closed write 
 privledges to authorized keys by typing 'chmod u-w authorized keys' after setting things 
 up using ssh-keygen. The following links provide useful tutorials/discussions that will
 help users set up passwordless SSH access:
      - http://www.linuxproblem.org/art_9.html
      - http://www.macworld.co.uk/how-to/mac-software/how-generate-ssh-keys-3521606/
      - https://coolestguidesontheplanet.com/make-passwordless-ssh-connection-osx-10-9-mavericks-linux/  (preferred tutorial)
      - https://coolestguidesontheplanet.com/make-an-alias-in-bash-shell-in-os-x-terminal/  (needed to complete preceding tutorial)
      - http://unix.stackexchange.com/questions/187339/spawn-command-not-found

 This script only applies to the remote supercomputer scenario discussed above, because
 installation of estpost on the user's local machine will be quite trivial.
 
      ##--Usage example:
      chmod u+x "$0"	## Modify permissions.
      "$0" .		## Execute in current directory.

 CITATION
 Bagley, J.C. 2017. bgc_tools v0.1.0. GitHub repository, Available at: 
	<http://github.com/justincbagley/bgc_tools>.

 REFERENCES
 Gompert Z, Buerkle CA (2011) Bayesian estimation of genomic clines. Molecular Ecology, 20,
	2111-2127.
 Gompert Z, Buerkle CA (2012) bgc: Software for Bayesian estimation of genomic clines. 
	Molecular Ecology Resources, 12, 1168-1176.
"

if [[ "$1" == "-h" ]] || [[ "$1" == "-help" ]]; then
	echo "$Usage"
	exit
fi

############ PARSE THE OPTIONS
while getopts 'a:' opt ; do
  case $opt in

    a) MY_SSH_ACCOUNT=$OPTARG ;;

## Missing and illegal options:
    :) printf "Missing argument for -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
   \?) printf "Illegal option: -%s\n" "$OPTARG" >&2
       echo "$Usage" >&2
       exit 1 ;;
  esac
done

############ SKIP OVER THE PROCESSED OPTIONS
shift $((OPTIND-1)) 
# Check for mandatory positional parameters
if [ $# -lt 1 ]; then
echo "$Usage"
  exit 1
fi
USER_SPEC_PATH="$1"


echo "INFO      | $(date) |          Setting user-specified path to: "
echo "$USER_SPEC_PATH "	

echo "
##########################################################################################
#                           estpostCompiler v0.1.0, July 2017                            #
##########################################################################################"

######################################## START ###########################################
echo "INFO      | $(date) | Starting estpost compiler script... "
echo "INFO      | $(date) | STEP #1: SETUP VARIABLES. "
echo "INFO      | $(date) |          Setting up variables, including those specified in the btcRunner.cfg configuration file..."
	MY_BGC_INPUT_FILES="$(echo ./p0in.txt ./p1in.txt ./admixedIn.txt)"

if [[ "$MY_SSH_ACCOUNT" == "NULL" ]]; then
	echo "INFO      | $(date) |          Pulling ssh account information from the bgc_runner configuration file..."
	MY_SSH_ACCOUNT="$(grep -n "ssh_account" ./bgc_runner.cfg | \
	awk -F"=" '{print $NF}')"
else
	echo "INFO      | $(date) |          Using ssh account information passed using the -a flag..."
fi

	MY_SC_DESTINATION="$(grep -n "destination_path" ./bgc_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"
	MY_SC_BIN="$(grep -n "bin_path" ./bgc_runner.cfg | \
	awk -F"=" '{print $NF}' | sed 's/\ //g')"


echo "INFO      | $(date) | STEP #2: COMPILE THE PROGRAM. "
###### COMPILE estpost.
##--Compile estpost by passing relevant commands to the supercomputer using bash HERE 
##--document syntax, as per examples on the following web page: 
##--https://www.cyberciti.biz/faq/linux-unix-osx-bsd-ssh-run-command-on-remote-machine-server/).

ssh $MY_SSH_ACCOUNT << HERE
## cd $MY_SC_DESTINATION
cd ~/compute/bgcdist
pwd  
h5cc -Wall -O3 -o estpost estpost_h5.c -lgsl -lgslcblas
## Check for exectuable:
if [[ -s "$(find . -name "estpost")" ]]; then
 	echo "INFO      | $(date) |          The estpost executable was successfully created."
	echo "INFO      | $(date) | STEP #3: ORGANIZE FILES. "
	###### MOVE estpost TO THE BIN FOLDER ON THE USER'S SUPERCOMPUTER ACCOUNT.
	cp ./estpost $MY_SC_BIN
else
	echo "WARNING!  | $(date) |          FAILED to create estpost executable. Quitting..."
fi
exit
HERE


echo "INFO      | $(date) |          Done compiling the estpost utility on your supercomputer account using estpostCompiler. "
echo "INFO      | $(date) |          You are now ready to summarize, analyze, and plot bgc results using the bgcPostProc.sh script in bgc_tools! "
echo "INFO      | $(date) |          Bye."

#
#
#
######################################### END ############################################

exit 0
