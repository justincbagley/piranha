#!/bin/sh

NL='
'

bashProfile=$(cat ~/.bash_profile | sed '/piranha/d' | sed '/PIrANHA/d' | sed '/PIRANHA/d')
echo "${bashProfile}${NL}${NL}# Leave this line sourcing piranha completions as a single line, so that Homebrew upgrades are smooth${NL}if [ -f /usr/local/Cellar/piranha/*/completions/init.sh ]; then source /usr/local/Cellar/piranha/*/completions/init.sh; fi${NL}" > ~/.bash_profile

echo "INFO      | $(date) | *** Did the above fail with permissions errors? *** "
echo "INFO      | $(date) | If yes, you will need to try this after Homebrew finishes: "
echo "INFO      | $(date) |   \$ source /usr/local/Cellar/piranha/*/completions/init.sh "
