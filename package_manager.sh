#!/bin/bash

AUR=0
AUR_MANAGER=""

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
    select_aur
    ask "Do you want to install AUR wrapper"
    if [[ $? == 0 ]]; then
        sudo pacman -S base-devel
        select_aur
        tmp_folder=$(mktemp -d)
        (git clone https://aur.archlinux.org/$AUR_MANAGER $tmp_folder --depth 1 && cd $tmp_folder && makepkg -si)
        AUR=1
    fi
}

pipx_install(){
    ask "Do you want some pipx packages"
    if [[ $? == 0 ]]; then
        for pip in $(cat ./src/pipx.txt); do
            pipx install $pip
        done
    fi
}

blackarch_install(){
    ask "Do you want to add blackarch repos"
    if [[ $? == 0 ]]; then
        (curl https://blackarch.org/strap.sh | sed 's/pacman -S --no.*//' | sudo sh)
        ask "Do you want to install some pwn tools"
        [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "./src/black")
    fi
}

refresh_pacman(){
    ask "Do you want to automaticaly regenerate pacman depots"
    if [[ $? == 0 ]]; then
        sudo pacman -S --noconfirm reflector && sudo reflector -c PL -c DE -n 50 --protocol http,https --save /etc/pacman.d/mirrorlist
        sudo pacman -Syy --noconfirm
    fi
}

aur_install_package(){
    if [[ $AUR == 1 ]]; then
        ask "Do you want to install some games stations"
        [[ $yn == [Yy] ]] && $AUR_MANAGER -S --noconfirm $(cat "./src/game")

        ask "Do you want to install software for multimedia"
        [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "./src/multi")
        echo "[\!] Install some fonts"
        $AUR_MANAGER -S --noconfirm $(cat "./src/font")
    fi
}

pacman_install(){ # generate pacman mirrorlist blackarch and install all software i need
    echo "[!] Reload pacman.conf"
    sudo cp ./src/pacman.conf /etc/pacman.conf
    echo "[!] Update package list"
    sudo pacman -Syy --noconfirm

    refresh_pacman

    blackarch_install

    ask "Do you want to install some developpement tools and IDE"
    [[ $? == 0 ]] && sudo pacman -S --noconfirm $(cat "./src/dev")

    pipx_install

    # ask "Do you want to install android studio"
    # [[ $? == 0 ]] && get_android_studio

    aur_install_package

    echo "[\!] Install basic need on arch"
    sudo pacman -S --noconfirm $(cat "./src/arch-base")
}

install_DE(){ # setup DesktopEnvironement
    if [[ $AUR == 1 ]]; then
        $AUR_MANAGER -S --noconfirm $(cat "./src/DE") && cargo install xremap --features hypr
    fi
}

