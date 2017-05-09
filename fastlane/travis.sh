#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  git status
  ls -al certificates/
  security find-identity -v -p codesigning
  fastlane travis_deploy
  security find-identity -v -p codesigning
  exit $?
# fi
