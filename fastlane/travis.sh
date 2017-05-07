#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  git status
  ls -al certificates/
  fastlane travis_deploy
  exit $?
# fi
