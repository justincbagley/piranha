#!/usr/bin/env bash

## init.sh
## Justin C. Bagley, Ph.D.
## Thu Dec 9 2:15:01 CST 2020

	####### SOURCE COMPLETION SCRIPT:
	# The completion scripts must exist in the same directory as this init script.

	if [ -n "$BASH_VERSION" ]; then
		
		COMPL_ROOT="$(dirname "${BASH_SOURCE[0]}")";
		source "$COMPL_ROOT/c.bash";
		export COMPL_ROOT;
		export PIRANHA_DIR="$(echo /usr/local/Cellar/piranha/*/)";
		export PIRANHA_PATH="$(echo "$PIRANHA_DIR"piranha)";
		
	elif [ -n "$ZSH_VERSION" ]; then
		
		COMPL_ROOT="$(dirname "$0")";
		source "$COMPL_ROOT/c.zsh";
		export COMPL_ROOT;
		export PIRANHA_DIR="$(echo /usr/local/Cellar/piranha/*/)";
		export PIRANHA_PATH="$(echo ${PIRANHA_DIR}piranha)";
		
	fi


