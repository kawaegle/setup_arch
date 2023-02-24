#!/bin/bash

GIT_USER=''
GIT_MAIL=''
GIT_EDITOR='nvim'
GIT_BRANCH='main'

AUR(){ # install AUR manager and aur software
    read -p "[?] Do you want to install YaY ?[Y/n]" yn ; [[ $yn == [yY] ]] || [[ $yn == "" ]] && \
        sudo pacman -S base-devel && (git clone https://aur.archlinux.org/yay /tmp/yay && cd /tmp/yay && makepkg -si) 2>&1
    read -p "[?] Do you want install all AUR package ?[Y/n]" yn ; [[ $yn == [yY] ]] || [[ $yn == "" ]] && \
        yay -S --noconfirm $(cat "src/aur")

}

pacman_install(){ # generate pacman mirrorlist blackarch and install all software i need
    printf "[!] Reload pacman.conf\n"
    sudo rm -rf /etc/pacman.conf
    sudo cp src/pacman.conf /etc/pacman.conf
    printf "[!] Update package list\n"
    yay -Syy
    read -p "[?] Do you want to automaticaly regenerate pacman depots ? [Y/n]" yn
        [[ $(pacman -Qn reflector) == "" ]] && sudo pacman -S --noconfirm reflector &&
        [[ $yn == [Yy] ]] || [[ $yn == "" ]] && sudo reflector -c FR -c US -c GB -c PL -n 100 --info --protocol http,https --save /etc/pacman.d/mirrorlist
    read -p "[?] Do you want to add Blackarch repo ? [Y/n]" yn
        [[ $yn == [Yy] || $yn == '' ]] && (curl https://blackarch.org/strap.sh | sudo sh)
    read -p "[?] Do you want to install BlackArch software ? [Y/n]" yn
        [[ $yn == [Yy] || $yn == '' ]] && sudo pacman -S --noconfirm $(cat "src/black")
    read -p "[?] Do you want to install some games stations ? [y/n]" yn
        [[ $yn == [Yy] ]] && yay -S --noconfirm $(cat src/game)
    read -p "[?] Do you want to install some multimedia softare maker ? [y/n]" yn
        [[ $yn ==  [Yy] ]] && yay -S --noconfirm $(cat src/multi)
    read -p "[?] Do you want to install all Python usefull software by pip ? [y/n]" yn
        [[ $yn == [Yy] ]] && ([[ $(pacman -Qn python-pip) == "" ]] && sudo pacman -S --noconfirm python-pip || pip3 install -r src/pip_requiere.txt)
    read -p "[?] Do you want to install some dev tool and lang ? [y/n]" yn
        [[ $yn == [Yy] ]] && yay -S --noconfirm $(cat src/dev)
    sudo pacman -S --noconfirm $(cat "src/arch-base")
    yay -S --noconfirm $(cat "src/font")

}

setup_git(){ # generate .gitconfig
    if [[ ! -e $HOME/.gitconfig ]] ;then
        read -p "What is your username on GIT server : " GIT_USER && git config --global user.name $GIT_USER && printf "Your username is $GIT_USER\n"
        read -p "What is your email on GIT server : " GIT_MAIL && git config --global user.email $GIT_MAIL && printf "Your email is $GIT_MAIL\n"
        read -p "What is your editor for GIT commit and merge : " GIT_EDITOR && git config --global core.editor $GIT_EDITOR && printf "Your editor is $GIT_EDITOR\n"
        read -p "How do you want to name your default git branch :" && git config --global init.defaultBranch $GIT_BRANCH && printf "Your default branch is $GIT_BRANCH\n" *
        read -p "how do you want to rebase pull request [true/false]: " && git config --global pull.rebase $GIT_REBASE
    fi
}

install_DE(){ # setup DesktopEnvironement
    yay -S --noconfirm $(cat src/DE)
}

setup_system(){ # enable system dep
    sudo systemctl enable cups
    sudo systemctl enable bluetooth
    sudo systemctl enable ly
    sudo systemctl enable systemd-networkd
    sudo systemctl enable systemd-resolved
    sudo systemctl enable iwd
    sudo systemctl enable dhcpcd
    sudo systemctl enable docker
    read -p "[?] What is the Name of your computer ?:" STATION && echo $STATION | sudo tee -a /etc/hostname
    printf '127.0.0.1\t\tlocalhost\n::1\t\t\tlocalhost\n127.0.1.1\t\t'$STATION | sudo tee -a /etc/hosts 2>/dev/null
    printf '# /TMP\ntmpfs\t\t\t/tmp\t\ttmpfs\t\trw,nodev,nosuid,size=7G\t\t\t0\t0\n' | sudo tee -a /etc/fstab
    sudo hwclock --systohc
    sudo ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
    sudo timedatectl set-ntp true
    sudo localectl set-keymap fr
    sudo chmod +s /sbin/shutdown
    sudo chmod +s /sbin/reboot
    [[ $SHELL != "/bin/zsh" ]] && chsh -s /bin/zsh
    (curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules)
}

    sudo modprobe
user_manager(){
    sudo usermod -aG input $USER
    sudo usermod -aG uucp $USER
    sudo usermod -aG wheel $USER
    sudo usermod -aG tty $USER
    sudo groupadd dialout
    sudo usermod -aG dialout $USER
}

install_package(){ ## install base software
    AUR
    pacman_install
}

config(){ ## setup
    setup_git
    install_DE
    dotfile
    setup_system
    user_manager
}

dotfile(){
    if [[ ! -d ~/Wallpaper/ ]]; then
        git clone https://github.com/kawaegle/Wallpaper/ --depth 1 ~/Wallpaper
    fi
    if [[ ! -d ~/.local/share/dotfile ]]; then
        git clone https://github.com/kawaegle/Dotfile/ --depth 1 ~/.local/share/Dotfile
        (cd ~/.local/share/dotfile && dotash install)
    fi
    if [[ ! -h ~/.local/bin/dotash ]]; then
        TMP=$(mkt -d)
        git clone https://github.com/kawaegle/dotash --depth 1 "/tmp/$TMP"
        (cd "/tmp/$TMP" && ./install)
    fi
    if [[ ! -d ~/Templates/ ]]; then
        git clone https://github.com/kawaegle/Templates ~/Templates --depth 1 2>&1
    fi
}

finish(){
    printf "[!] Clean useless file\n"
    sudo pacman -Scc
    printf "[!] You 'll need to restart soon...\nBut no problem just wait we'll restart it for you.\n"; sleep 2
    printf "[!] Reboot in 5...\n"; sleep 1
    printf "[!] Reboot in 4...\n"; sleep 1
    printf "[!] Reboot in 3...\n"; sleep 1
    printf "[!] Reboot in 2...\n"; sleep 1
    printf "[!] Reboot in 1...\n"; sleep 1
    printf "[!] Reboot now..."
    sudo reboot
}

install_package
read -p "[?] Do you want to continue the configuration ? [Y/n] " yn
[[ $yn == [yY] ]] || [[ $yn == "" ]] && config
finish
