#/usr/bin/env zsh

## Modded from notes github repo (URL: https://github.com/kylebebak/notes/tree/master/completions/c.zsh):
_piranha_complete() {
  local function completions
  function="$1"
  # list of completions generated in piranha executable, as opposed to within this script, which would require an additional cd operation
  #completions="$(piranha -s)"
  completions="$(/usr/local/bin/piranha -s)"
  reply=( "${(ps:\n:)completions}" )
}

compctl -K _piranha_complete piranha
# Including -f flag would also match files in current directory.
