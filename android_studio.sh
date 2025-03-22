#!/bin/bash

ANDROID_DONE=0
ANDROID_STUDIO_SHA_256="2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258"

get_android_studio(){
    tools=$(mktemp)
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o $tools
    echo "$ANDROID_STUDIO_SHA_256 $tools" | sha256sum -c
    if [[ $? == 0 ]]; then
        mkdir -p "$HOME/.local/Android/"
        unzip $tools -d "$HOME/.local/Android/"
        (cd "$HOME/.local/Android/cmdline-tools/bin/"
        yes | ./sdkmanager --licenses --sdk_root="$HOME/.local/Android/sdk_latest"
        ./sdkmanager --sdk_root="$HOME/.local/Android/sdk_latest" --install "build-tools;34.0.0"
        ./sdkmanager --sdk_root="$HOME/.local/Android/sdk_latest" --install "emulator"
        ./sdkmanager --sdk_root="$HOME/.local/Android/sdk_latest" --install "platform-tools"
        ./sdkmanager --sdk_root="$HOME/.local/Android/sdk_latest" --install "platforms;android-34"
        ./sdkmanager --sdk_rot="$HOME/.local/Android/sdk_latest" --install "system-images;android-34;google_apis_playstore;x86_64"
        )
        ANDROID_DONE=1
    else
        echo "Error while getting android studio"
    fi
    if [[ $ANDROID_DONE == 1 ]]; then
        read -p "[?] Do you want to create an avd devices ?[Y/n]" yn
        if [[ $yn == [yY] ]] || [[ $yn == "" ]]; then
            export ANDROID_HOME=$HOME/.local/Android
            export PATH=$PATH:$ANDROID_HOME/cmdline-tools/bin/
            avdmanager create avd -f --name pixel_7 --device "pixel_7" --package "system-images;android-34;google_apis_playstore;x86_64"
        fi
    fi
}

