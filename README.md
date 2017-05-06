# Hubbub iOS
See https://github.com/all-the-hubbub/hubbub

## Setup
set up [prerequisites](https://firebase.google.com/docs/firestore/client/setup-ios)

```
cd hubbub/ios
pod repo update
pod install
open Hubbub.xcworkspace
```

## Build and export
We're using Fabric, Crashlytics Beta, and fastlane.

For fastlane to work, don't use your macOS system ruby. Use rbenv or rvm to install a version higher than 2.3.1. We're using rvm because travis-ci.org uses rvm.
