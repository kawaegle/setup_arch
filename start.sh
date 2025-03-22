#!/bin/bash

AUR=0
AUR_MANAGER=""

ask(){
    echo -n "[?] $1 [Y|n] ?"
    read yn
    [[ $yn ==  [yY] || $yn == '' ]] && return 0 || return 1
}


install_package(){ ## install base software
    source ./package_manager.sh

    AUR
    pacman_install
}

config(){ ## setup
    source ./dotfile.sh
    source ./fstab_edit.sh
    source ./systemd_setup.sh

    install_DE
    dotfile
    fstab
    setup_system
    rootless
    user_manager
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
