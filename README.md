
# react-native-ios-release-build-script

This is a basic script to build a standalone react-native project into the apple app store.

The build script will ask for the project name, app store credentials, version number, and build number. It will then begin to clean & analyze & release & archive & upload your project to the app store credentials provided.

The projects build `.ipa` will be exported to `/builds` with naming convention as follows `PROJECT_NAME-VERSION_NUMBER-(BUILD_NUMBER)-DATE`

## Getting started

`$ npm install react-native-ios-release-build-script --save`

## instructions

Copy `ios.sh` to the root of your react-native project
Give execute permissions to `ios.sh` -> `chmod +x ios.sh`
Copy `Builds`to the root of your react-native project

## Usage
```
$ ./ios.sh
```
