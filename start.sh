#!/bin/bash

AUR=0
AUR_MANAGER=""

ANDROID_DONE=0
ANDROID_STUDIO_SHA_256="8919e8752979db73d8321e9babe2caedcc393750817c1a5f56c128ec442fb540"

ask(){
    echo -n "[?] $1 [Y|n] ?"
    read yn
    [[ $yn ==  [yY] || $yn == '' ]] && return 0 || return 1
}

select_aur(){
    while [[ $AUR_MANAGER == "" ]]; do
        select a in yay pikaur; do
            case $a in
                yay | pikaur)
                    AUR_MANAGER=$a
                    break
                    ;;
                *)
                    echo "Not in choices"
                    ;;
            esac
        done
    done
}

AUR(){ # install AUR manager and aur software
    # Check if AUR manager exist or install it
    if [[ $(where yay | grep "not found") != 0 ]]; then
        AUR_MANAGER="yay"
        AUR=1
        return
    fi
    if [[ $(where pikaur | grep "not found") != 0 ]]
        AUR_MANAGER="pikaur"
        AUR=1
        return
    fi
    ask "Do you want to install AUR wrapper"
    if [[ $? == 0 ]]; then
        sudo pacman -S base-devel
        select_aur
        tmp_folder=$(mktemp -d)
        (git clone https://aur.archlinux.org/$AUR_MANAGER $tmp_folder --depth 1 && cd $tmp_folder && makepkg -si)
        AUR=1
    fi
}

get_android_studio(){
    tools=$(mktemp)
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -o $tools
    echo "$ANDROID_STUDIO_SHA_256 $tools" | sha256sum -c
    if [[ $? == 0 ]]; then
        mkdir -p "$HOME/.local/Android/"
        unzip $tools -d "$HOME/.local/Android"
        mkdir "$HOME/.local/Android/cmdline-tools/latest/" && mv "$HOME/.local/Android/cmdline-tools/{NOTICE.txt,bin,lib,source.properties}" "$HOME/.local/Android/cmdline-tools/latest/"
        (cd "$HOME/.local/Android/cmdline-tools/latest/bin/"
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
            avdmanager create avd -f --name pixel_7 --device "pixel_7" --package "system-images;android-34;google_apis_playstore;x86_64"
        fi
    fi
}

pacman_install(){ # generate pacman mirrorlist blackarch and install all software i need
    echo "[!] Reload pacman.conf"
    sudo mv /etc/pacman.conf /etc/pacman.conf.bak
    sudo cp ./src/pacman.conf /etc/pacman.conf
    echo "[!] Update package list"
    sudo pacman -Syy --noconfirm
    ask "Do you want to automaticaly regenerate pacman depots"
    [[ $? == 0 ]] && sudo pacman -S --noconfirm reflector && \
    sudo reflector -c FR -c US -c GB -c PL -n 50 --protocol http,https --save /etc/pacman.d/mirrorlist
    sudo pacman -Syu --noconfirm
    ask "Do you want to add blackarch repos"
    [[ $? == 0 ]] && (curl https://blackarch.org/strap.sh | sudo sh && BLACK_REPOS=1)

    if [[ $BLACK_REPOS == 1 ]]; then
        ask "Do you want to install some pwn tools"
        [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "./src/black")
    fi

    ask "Do you want to install some developpement tools and IDE"
    [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "./src/dev")

    ask "Do you want some pipx packages"
    if [[ $? == 0 ]]; then
        for pip in $(./src/pipx.txt); do;
            pipx install $pip
        done
    fi

    ask "Do you want to install android studio"
    [[ $? == 0 ]] && get_android_studio

    if [[ $AUR == 1 ]]; then
        ask "Do you want to install some games stations"
        [[ $yn == [Yy] ]] && $AUR_MANAGER -S --noconfirm $(cat "./src/game")

        ask "Do you want to install software for multimedia"
        [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "./src/multi")
        $AUR_MANAGER -S --noconfirm $(cat "./src/font")
    fi

    echo "[\!] Install basic need on arch"
    sudo pacman -S --noconfirm $(cat "./src/arch-base")
}

install_DE(){ # setup DesktopEnvironement
    [[ $AUR == 1 ]] && $AUR_MANAGER -S --noconfirm $(cat "./src/DE") && \
    cargo install xremap --features hypr
}

fstab(){
    cat "/etc/fstab" | grep "/tmp"
    if [[ $? -eq 0 ]]; then
        return
    fi
    echo "# /TMP\ntmpfs\t\t/tmp\t\ttmpfs\t\trw,nodev,nosuid,size=10G\t\t0\t0\ntmpfs\t/home/$USER/Documents/tmp\t\ttmpfs\t\trw,nodev,nosuid,size=10G\t\t0\t0" | sudo tee -a /etc/fstab
}

setup_system(){ # enable system dep
    sudo systemctl enable cups
    sudo systemctl enable tlp
    sudo systemctl enable bluetooth
    sudo systemctl enable ly
    sudo systemctl enable systemd-networkd
    sudo systemctl enable systemd-resolved
    sudo systemctl enable acpid
    sudo systemctl enable iwd
    sudo systemctl enable dhcpcd
    sudo timedatectl set-ntp true
    sudo localectl set-keymap fr
    sudo cp ./src/journald.conf /etc/systemd/journald.conf
}

rootless() {
    [[ $SHELL != "/bin/zsh" ]] && chsh -s /bin/zsh
    systemctl --user enable podman.service
    systemctl --user enable podman.socket
    echo "unqualified-search-registries = [ \"docker.io\" ]" | sudo tee -a /etc/containers/registries.conf
    sudo cp ./src/sudoers /etc/sudoers
}

user_manager(){
    sudo groupadd dialout
    sudo usermod -aG dialout $USER
    sudo usermod -aG input $USER
    sudo usermod -aG uucp $USER
    sudo usermod -aG wheel $USER
    sudo usermod -aG tty $USER
    user usermod -aG libvirt $USER
}

install_package(){ ## install base software
    AUR
    pacman_install
}

config(){ ## setup
    install_DE
    dotfile
    fstab
    setup_system
    user_manager
}

dotfile(){
    mkdir -p $HOME/.local/share/
    mkdir -p $HOME/.local/bin
    mkdir -p $HOME/.config

    if [[ ! -d "$HOME/Wallpaper/" ]]; then
        git clone https://github.com/kawaegle/Wallpaper/ --depth 1 "$HOME/Wallpaper"
    fi
    if [[ ! -e "$HOME/.local/bin/dotash" ]]; then
        TMP=$(mktemp -d)
        git clone https://github.com/kawaegle/dotash --depth 1 "$TMP"
        (cd "$TMP" && ./install.sh)
    fi
    if [[ ! -d "$HOME/.local/share/dotfile" ]]; then
        git clone https://github.com/kawaegle/dotfile/ --depth 1 "$HOME/.local/share/dotfile"
        (cd "$HOME/.local/share/dotfile" && $HOME/.local/bin/dotash install)
    fi
    if [[ ! -d $HOME/Templates/ ]]; then
        git clone https://github.com/kawaegle/Templates --depth 1 "$HOME/Templates"
    fi
}

finish(){
    echo "[!] Clean useless file"
    sudo pacman -Scc --noconfirm
    echo "[!] You 'll need to restart soon..."
    echo "But no problem just wait we'll restart it for you."
    for i in {5..1}; do
        echo -ne "\r[!] Reboot in $i";
        sleep 1
    done
    echo -ne "\r[!] Reboot now..."
    sudo reboot
}

install_package
ask "Do you want to continue the configuration"
[[ $? == 0 ]] && config
finish
