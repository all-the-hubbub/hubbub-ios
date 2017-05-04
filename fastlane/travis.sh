#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  fastlane beta
  exit $?
# fi
