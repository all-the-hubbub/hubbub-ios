#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  git status
  fastlane beta
  exit $?
# fi
