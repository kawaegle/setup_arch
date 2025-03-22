#!/bin/bash

rootless() {
    [[ $SHELL != "/bin/zsh" ]] && chsh -s /bin/zsh
    systemctl --user enable podman.service
    systemctl --user enable podman.socket
    echo "unqualified-search-registries = [ \"docker.io\" ]" | sudo tee -a /etc/containers/registries.conf
    sudo cp ./src/sudoers /etc/sudoers
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
    sudo timedatectl set-ntp true
    sudo localectl set-keymap fr
    sudo cp ./src/journald.conf /etc/systemd/journald.conf
}

