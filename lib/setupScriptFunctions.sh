#!/usr/bin/env bash

# ##################################################
# Shared bash functions used by my mac setup scripts.
#
# VERSION 1.0.0
#
# HISTORY
#
# * 2015-01-02 - v1.0.0  - First Creation
#
# ##################################################


# hasHomebrew
# ------------------------------------------------------
# This function checks for Homebrew being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasHomebrew () {
  # Check for Homebrew
  #verbose "Checking homebrew install"
  if type_not_exists 'brew'; then
    warning "No Homebrew. Gots to install it..."
    seek_confirmation "Install Homebrew?"
    if is_confirmed; then
      #   Ensure that we can actually, like, compile anything.
      if [[ ! "$(type -P gcc)" && "$OSTYPE" =~ ^darwin ]]; then
        notice "XCode or the Command Line Tools for XCode must be installed first."
        seek_confirmation "Install Command Line Tools from here?"
        if is_confirmed; then
          xcode-select --install
        else
          die "Please come back after Command Line Tools are installed."
        fi
      fi
      # Check for Git
      if type_not_exists 'git'; then
        die "Git should be installed. It isn't."
      fi
      # Install Homebrew
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      brew tap homebrew/dupes
      brew tap homebrew/versions
      brew tap argon/mas
    else
      die "Without Homebrew installed we won't get very far."
    fi
  fi
}

# brewMaintenance
# ------------------------------------------------------
# Will run the recommended Homebrew maintenance scripts
# ------------------------------------------------------
brewMaintenance () {
  seek_confirmation "Run Homebrew maintenance?"
  if is_confirmed; then
    brew doctor
    brew update
    brew upgrade --all
  fi
}

# hasCasks
# ------------------------------------------------------
# This function checks for Homebrew Casks and Fonts being installed.
# If it is not found, we install it and its prerequisites
# ------------------------------------------------------
hasCasks () {
  if ! $(brew cask > /dev/null); then
    brew install caskroom/cask/brew-cask
    brew tap caskroom/fonts
    brew tap caskroom/versions
  fi
}
