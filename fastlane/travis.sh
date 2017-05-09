#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  git status
  ls -al certificates/
  security find-identity -v -p codesigning
  bundle exec fastlane travis_deploy
  exit $?
# fi
