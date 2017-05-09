#!/bin/sh

git status
ls -al certificates/

# Create the keychain with a password
security create-keychain -p travis ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Add certificates to keychain and allow codesign to access them
security import ./certificates/AppleWWDRCA.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./certificates/dev.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./certificates/dev.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign

security set-key-partition-list -S apple-tool:,apple: -s -k travis ios-build.keychain

security find-identity -v -p codesigning

# Login keychain
security list-keychains -d user
# System keychain
security list-keychains -d system

bundle exec fastlane travis_deploy

exit $?
