# Hubbub iOS
This repository contains the iOS implementation of [Hubbub](https://github.com/all-the-hubbub/hubbub).

## Development
**Important:** Before following the instructions below for setting up and running Hubbub iOS, you must first complete all of the steps listed on the main Hubbub README, specifically the [Setting up a dev environment](https://github.com/all-the-hubbub/hubbub#setting-up-a-dev-environment) section.

### Prerequisites
1. A Firebase project setup after following the [Hubbub README](https://github.com/all-the-hubbub/hubbub#setting-up-a-dev-environment)
1. Xcode 7.3 or later
1. Cocoapods 1.0.0 or later

### Get the code
1. Clone this repository:
    ```
    git clone https://github.com/all-the-hubbub/hubbub-ios.git
    ```
1. Install pods:
    ```
    cd hubbub-ios
    pod install
    ```
1. Open workspace:
    ```
    open Hubbub.xcworkspace
    ```

### Add Firebase iOS
1. Go to the Firebase console and navigate to your project called `hubbub-dev` (See prerequisites)
1. Click "Add Firebase to your iOS app"
1. Choose a bundle identifier and enter it in the `iOS bundle ID` field
1. Click "Register App"
1. Follow the instructions to download and add `GoogleService-Info.plist` to the Xcode project

### Set Bundle ID
1. In Xcode, navigate to the Build Settings for the `Hubbub` target (see image below)
1. In the `Packaging` section, locate `Product Bundle Identifier`
1. Edit the `Debug` entry: replace `<DEV_BUNDLE_IDENTIFIER>` with the bundle identifier you chose in step 3 above
    ![Xcode build settings and bundle identifier field][xcode-bundle-identifier]

### Update Config
1. Open `Config.swift` in Xcode
1. Update the config entries as indicated in the file

### Build & Run
1. Choose the `Hubbub-dev` scheme and select an iPhone simulator of your choosing (or an attached iPhone device)
1. Click the "play" button to build and run the app
    ![Xcode scheme dropdown and run button][xcode-scheme-and-run]

[xcode-bundle-identifier]: doc/images/xcode-bundle-identifier.png "Set dev bundle identifier"
[xcode-scheme-and-run]: doc/images/xcode-scheme-and-run.png "Build and run Hubbub-dev scheme"
