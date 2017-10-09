#!/bin/bash

# Homebrew
brew --version >/dev/null 2>&1 || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
BREW_INSTALLED=( $(brew list) )
ensure_installed(){
    (echo ${BREW_INSTALLED[@]} | grep -qw $1) || brew install $1
}

ensure_installed awscli

aws iam get-user || aws configure

ensure_installed nvm
mkdir ~/.nvm >/dev/null 2>&1
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

nvm install v8.4.0
nvm use v8.4.0

npm install -g serverless
