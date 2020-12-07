## #!/usr/bin/env bash

## init.sh
## Justin C. Bagley, Ph.D.
## Thu Dec 3 12:31:58 CST 2020

## Completions initialization script. Coded with new ideas, including $PIRANHA_DIR and 
## $PIRANHA_PATH, by modifying code from Kyle Bebak's notes github repository, specifically
## his completions init script at URL: https://github.com/kylebebak/notes/tree/master/completions/init.sh.	
	
	####### SOURCE COMPLETION SCRIPT:
	# the completion scripts must exist in the same directory as this init script

	if [ -n "$BASH_VERSION" ]; then
		
		COMPL_ROOT="$(dirname "${BASH_SOURCE[0]}")";
		source "$COMPL_ROOT/c.bash";
		export PIRANHA_DIR="$(dirname "$COMPL_ROOT")";
		export PIRANHA_PATH="$(echo "$PIRANHA_DIR"/piranha)";
		
	elif [ -n "$ZSH_VERSION" ]; then
		
		COMPL_ROOT="$(dirname "$0")";
		source "$COMPL_ROOT/c.zsh";
		export PIRANHA_DIR="$(dirname ${COMPL_ROOT})";
		export PIRANHA_PATH="$(echo ${PIRANHA_DIR}/piranha)";
		
	fi


