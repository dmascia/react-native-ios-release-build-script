#!/bin/bash

##############################################################################################################
### XCode Command Line Tools
if ! xcode-select --print-path &> /dev/null; then

    # Prompt user to install the XCode Command Line Tools
    xcode-select --install &> /dev/null

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait until the XCode Command Line Tools are installed
    until xcode-select --print-path &> /dev/null; do
        sleep 5
    done

    print_result $? 'Install XCode Command Line Tools'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Point the `xcode-select` developer directory to
    # the appropriate directory from within `Xcode.app`
    # https://github.com/alrra/dotfiles/issues/13

    sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
    print_result $? 'Make "xcode-select" developer directory point to Xcode'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Prompt user to agree to the terms of the Xcode license
    # https://github.com/alrra/dotfiles/issues/10

    sudo xcodebuild -license
    print_result $? 'Agree with the XCode Command Line Tools licence'

fi
###
##############################################################################################################

echo "========= START BUILD"

read -p 'Project Name: ' PROJECT_NAME
read -p 'Apple Store Username: ' USERNAME
read -sp 'Apple Store Password: ' PASSWORD
read -p 'Version Number ex. (1.0): ' VERSION_NUMBER
read -p 'Version Build Number ex. (1): ' BUILD_NUMBER

if [[ -z  PROJECT_NAME  ]] ;  then
    printf '%s\n' "Project Name is Required" >&2
    exit 1;
fi

if [[ -z  USERNAME  ]] ;  then
    printf '%s\n' "Apple Store Username is Required" >&2
    exit 1;
fi

if [[ -z  PASSWORD  ]] ;  then
    printf '%s\n' "Apple Store Password is Required" >&2
    exit 1;
fi

if [[ -z  VERSION_NUMBER  ]] ;  then
    printf '%s\n' "Version Number is Required" >&2
    exit 1;xf
fi

if [[ -z  BUILD_NUMBER  ]] ;  then
    printf '%s\n' "Version Build Number is Required" >&2
    exit 1;
fi

PROJECT_DIR=${PWD}
IOS_DIR="${PROJECT_DIR}/ios"
TARGET_SDK=iphoneos
PROJECT_BUILDDIR="${IOS_DIR}/build/Build/Products/Release-iphonesimulator/"
IPA_OUTDIR="${PROJECT_DIR}/builds"
DATE=$(date -u +%Y-%m-%d-%H-%M)
OUTPUT_FOLDER_NAME="${PROJECT_NAME}-${VERSION_NUMBER}-(${BUILD_NUMBER})-${DATE}"
PLIST=${IOS_DIR}/${PROJECT_NAME}/Info.plist
PLB=/usr/libexec/PlistBuddy

echo "========= CHANGE DIR TO ${IOS_DIR}"

cd "${IOS_DIR}"

echo "========= READ CURRENT CFBundleShortVersionString & CFBundleVersion VALUES"

echo $(${PLB} -c "Print CFBundleShortVersionString" "$PLIST")
echo $(${PLB} -c "Print CFBundleVersion" "$PLIST")

echo "========= WRITE NEW CFBundleShortVersionString & CFBundleVersion VALUE"

${PLB} -c "Set :CFBundleVersion $BUILD_NUMBER" "$PLIST"
${PLB} -c "Set :CFBundleShortVersionString $VERSION_NUMBER" "$PLIST"

echo "========= READ CURRENT CFBundleShortVersionString & CFBundleVersion VALUES AFTER CHANGE"

echo $(${PLB} -c "Print CFBundleShortVersionString" "$PLIST")
echo $(${PLB} -c "Print CFBundleVersion" "$PLIST")

echo "========= START CLEAN & ANALYZE & RELEASE & ARCHIVE PROJECT"

xcodebuild -project="${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}" clean archive -configuration release -sdk "${TARGET_SDK}" -archivePath "${PROJECT_NAME}".xcarchive

xcodebuild -exportArchive -archivePath "${PROJECT_NAME}".xcarchive -exportPath "${IPA_OUTDIR}/${OUTPUT_FOLDER_NAME}" -exportOptionsPlist ExportOptions.plist

echo "========= REMOVE ARCHIVE PATH FROM PROJECT"

rm -rf "${PROJECT_NAME}".xcarchive

echo "========= UPLOAD ARCHIVE TO APP STORE"

/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool --upload-app -f "${IPA_OUTDIR}/${OUTPUT_FOLDER_NAME}/${PROJECT_NAME}.ipa" -u $USERNAME -p $PASSWORD

echo "========= FINISHED BUILD"

if [ $? != 0 ]
then
  exit 1
fi
