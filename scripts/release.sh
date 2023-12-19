#!/usr/bin/env bash

function notify {
  BLUE='\033[1;34m'
  NC='\033[0m'
  echo -e "${BLUE}$1${NC}"
}

set -e
set -o pipefail

notify "Setting up node to match the correct version"
# export NVM_DIR=~/.nvm
# source ~/.nvm/nvm.sh
# nvm use

notify "Queuing all PRs"
# GITHUB_REPO=pluto ./packages/release-bot/release-bot.js --queue

notify "Getting latest master"
git fetch --all
git checkout master
git reset --hard origin/master

notify "Creating a clean install"
# git clean -dfX
yarn install

notify "Building the monorepo"
yarn build

notify "Running lint"
yarn lint

notify "Running tests"
# yarn test

echo "The next stages of the release are irreversible, so please make sure you have checked everything locally."
read -p "Do you want to continue? Press ENTER to continue or CTRL+C to exit" -n 1 -r

if [[ $REPLY = "" ]]; then
  notify "Removing .npmrc"
  # mv .npmrc .ignore.npmrc

  function finish {
    notify "Cleaning up project"
    # mv .ignore.npmrc .npmrc

    notify "Un-blocking PRS"
    # GITHUB_REPO=pluto ./packages/release-bot/release-bot.js --success
  }

  trap finish EXIT

  notify "Starting and publishing with lerna"
  npx lerna publish --yes
fi
