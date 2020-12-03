#/usr/bin/env bash

## Modded from Eduardo Cuomo answer at URL: https://unix.stackexchange.com/questions/1800/how-to-specify-a-custom-autocomplete-for-specific-commands
_piranha_complete()
{
  #_script_commands=$(/path/to/your/script.sh shortlist)
  _script_commands=$("${PIRANHA_PATH}" -s)
  
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${_script_commands}" -- ${cur}) )

  return 0
}

complete -o nospace -F _piranha_complete piranha
# Including -f flag would also match files in current directory.
