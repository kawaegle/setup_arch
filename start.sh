#!/bin/bash

AUR=0

ANDROID_DONE=0
ANDROID_STUDIO_SHA_256="8919e8752979db73d8321e9babe2caedcc393750817c1a5f56c128ec442fb540"

ask(){
    echo "[?] $1 [Y|n] ?"
    read yn
    [[ $yn ==  [yY] || $yn == '' ]] && return 0 || return 1
}

AUR(){ # install AUR manager and aur software
    ask "Do you want to install YaY wrapper"
    if [[ $? == 0 ]]; then
        sudo pacman -S base-devel && \
        tmp_folder=$(mktemp -d)
       (git clone https://aur.archlinux.org/yay $tmp_folder --depth 1 && cd $tmp_folder && makepkg -si && AUR=1)
    fi
}

get_android_studio(){
    tools=$(mktemp)
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -o $tools
    echo "$ANDROID_STUDIO_SHA_256 $tools" | sha256sum -c
    if [[ $? == 0 ]]; then
        mkdir -p $HOME/.local/Android/
        unzip $tools -d $HOME/.local/Android
        mkdir $HOME/.local/Android/cmdline-tools/latest/ && mv $HOME/.local/Android/cmdline-tools/{NOTICE.txt,bin,lib,source.properties} $HOME/.local/Android/cmdline-tools/latest/
        (cd $HOME/.local/Android/cmdline-tools/latest/bin/
        yes | ./sdkmanager --licenses
        ./sdkmanager --install "build-tools;34.0.0"
        ./sdkmanager --install "emulator"
        ./sdkmanager --install "platform-tools"
        ./sdkmanager --install "platforms;android-34"
        ./sdkmanager --install "system-images;android-34;google_apis_playstore;x86_64"
        )
        ANDROID_DONE=1
    else
        echo "Error while getting android studiO"
    fi
    if [[ $ANDROID_DONE == 1 ]]; then
        read -p "[?] Do you want to create an avd devices ?[Y/n]" yn
        if [[ $yn == [yY] ]] || [[ $yn == "" ]]; then
            export ANDROID_HOME=$HOME/.local/Android
            export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/
            avdmanager create avd -f --name test --device "pixel_7" --package "system-images;android-34;google_apis_playstore;x86_64"
        fi
    fi
}

pacman_install(){ # generate pacman mirrorlist blackarch and install all software i need
    echo "[\!] Reload pacman.conf\n"
    sudo mv /etc/pacman.conf /etc/pacman.conf.bak
    sudo cp src/pacman.conf /etc/pacman.conf
    echo "[\!] Update package list\n"
    [[ $AUR == 1 ]] && yay -Syy
    ask "Do you want to automaticaly regenerate pacman depots"
    [[ $? == 0 && $(pacman -Qn reflector) == "" ]] && sudo pacman -S --noconfirm reflector && \
    sudo reflector -c FR -c US -c GB -c PL -n 100 --info --protocol http,https --save /etc/pacman.d/mirrorlist

    ask "Do you want to add blackarch repos"
    [[ $? == 0 ]] && (curl https://blackarch.org/strap.sh | sudo sh && BLACK_REPOS=1)

    if [[ $BLACK_REPOS == 1 ]]; then
        ask "Do you want to install some pwn tools"
        [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "src/black")
    fi

    ask "Do you want to install some developpement tools and IDE"
    [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat src/dev)

    ask "Do you want to install android studio"
    [[ $? == 0 ]] && get_android_studio

    if [[ $AUR == 1 ]]; then
        ask "Do you want to install some games stations"
        [[ $yn == [Yy] ]] && yay -S --noconfirm $(cat src/game)

        ask "Do you want to install software for multimedia"
        [[ $? == 0 ]] && yay -S --noconfirm $(cat src/multi)
        yay -S --noconfirm $(cat "src/font")
    fi

    echo "[\!] Install basic need on arch"
    sudo pacman -S --noconfirm $(cat "src/arch-base")
}

install_DE(){ # setup DesktopEnvironement
    [[ $AUR == 1 ]] && yay -S --noconfirm $(cat src/DE)
    cargo install xremap --features hypr
}

setup_system(){ # enable system dep
    sudo systemctl enable cups
    sudo systemctl enable bluetooth
    sudo systemctl enable ly
    sudo systemctl enable systemd-networkd
    sudo systemctl enable systemd-resolved
    sudo systemctl enable iwd
    sudo systemctl enable dhcpcd
    sudo hwclock --systohc
    sudo ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
    sudo timedatectl set-ntp true
    sudo localectl set-keymap fr
    (curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py && python3 ./get-platformio.py)
}

rootless() {
    sudo chmod +s /sbin/shutdown
    sudo chmod +s /sbin/reboot
    [[ $SHELL != "/bin/zsh" ]] && chsh -s /bin/zsh
    systemctl --user enable podman.service
    echo "unqualified-search-registries = [ "docker.io" ]" | sudo tee -a /etc/containers/registries.conf
    sudo cp src/sudoers /etc/sudoers
}

user_manager(){
    sudo groupadd dialout
    sudo usermod -aG input $USER
    sudo usermod -aG uucp $USER
    sudo usermod -aG wheel $USER
    sudo usermod -aG tty $USER
    user usermod -aG libvirt $USER
    sudo usermod -aG dialout $USER
}

install_package(){ ## install base software
    AUR
    pacman_install
}

config(){ ## setup
    install_DE
    dotfile
    setup_system
    user_manager
}

dotfile(){
    mkdir -p $HOME/.local/share/
    mkdir -p $HOME/.local/bin
    mkdir -p $HOME/.config
    if [[ ! -d $HOME/Wallpaper/ ]]; then
        git clone https://github.com/kawaegle/Wallpaper/ --depth 1 $HOME/Wallpaper
    fi
    if [[ ! -e $HOME/.local/bin/dotash ]]; then
        TMP=$(mktemp -d)
        git clone https://github.com/kawaegle/dotash --depth 1 "$TMP"
        (cd "$TMP" && pwd && ./install.sh)
    fi
    if [[ ! -d $HOME/.local/share/Dotfile ]]; then
        git clone https://github.com/kawaegle/dotfile/ --depth 1 "$HOME/.local/share/dotfile"
        (cd $HOME/.local/share/Dotfile && $HOME/.local/bin/dotash install)
    fi
    if [[ ! -d $HOME/Templates/ ]]; then
        git clone https://github.com/kawaegle/Templates $HOME/Templates --depth 1
    fi
}

finish(){
    echo "[\!] Clean useless file\n"
    sudo pacman -Scc
    echo "[\!] You 'll need to restart soon...\nBut no problem just wait we'll restart it for you.\n"; sleep 2
    for i in {5..1}; do
        echo -ne "\r[\!] Reboot in $i";
        sleep 1
    done
    echo -ne "\r[\!] Reboot now..."
    sudo reboot
}

install_package
ask "Do you want to continue the configuration"
[[ $? == 0 ]] && config
finish
