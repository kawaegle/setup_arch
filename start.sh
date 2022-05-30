#!/bin/bash

GIT_USER=''
GIT_MAIL=''
GIT_EDITOR='nvim'
GIT_BRANCH='main'
CONFIG="$HOME/.config"

banner(){
    cat << "EOF"

             _/|       |\_
            /  |       |  \
           |    \     /    |
           |  \ /     \ /  |
           | \  |     |  / |
           | \ _\_/^\_/_ / |
           |      \ /      |
            \_  \     /  _/
              \__  |  __/
                 \ _ /
                _/   \_
               /_  ^  _\
                / / \ \
                \/   \/

               K4W43GL3
EOF
}

AUR(){ # install AUR manager and aur software
    read -p "[?] Do you want to install trizen ?[Y/n]" yn ; [[ $yn == [yY] ]] || [[ $yn == "" ]] && sudo pacman -S base-devel && (git clone https://aur.archlinux.org/trizen /tmp/trizen && cd /tmp/trizen && makepkg -si) 2>&1
    SleepClear
    read -p "[?] Do you want install all AUR package ?[Y/n]" yn ; [[ $yn == [yY] ]] || [[ $yn == "" ]] && sudo umount -l /tmp && sudo mount -t tmpfs -o size=10G,mode=1777 tmpfs /tmp && gpg --recv-keys "5E3C45D7B312C643" && trizen -S --noconfirm $(cat "src/aur") && clear && printf "\n[!] You have install all software from AUR repositories"
    SleepClear
}

PacInstall(){ # generate pacman mirrorlist blackarch and install all software i need
    printf "[!] Reload pacman.conf\n"
    sudo rm -rf /etc/pacman.conf;sudo cp src/pacman.conf /etc/pacman.conf
    sleep 3
    printf "[!] Update package list\n"
    sudo pacman -Syy
    SleepClear
    read -p "[?] Do you want to automaticaly regenerate pacman depots ? [Y/n]" depots ; [[ $(pacman -Qn reflector) == "" ]] && sudo pacman -S --noconfirm reflector ; [[ $depots == [Yy] ]] || [[ $depots == "" ]] && sudo reflector -c FR -c US -c GB -c PL -n 100 --info --protocol http,https --save /etc/pacman.d/mirrorlist
    SleepClear
    read -p "[?] Do you want to add Blackarch repo ? [Y/n]" yn && [[ $yn == [Yy] || $yn == '' ]] && (curl -L https://blackarch.org/strap.sh -o /tmp/strap.sh && chmod +x /tmp/strap.sh && sudo sh /tmp/strap.sh && rm -rf /tmp/strap.sh)
    SleepClear
    read -p "[?] Do you want to install BlackArch software ? [Y/n]" yn && [[ $yn == [Yy] || $yn == '' ]] && sudo pacman -S --noconfirm $(cat "src/black")
    SleepClear
    read -p "[?] Do you want to install some games stations ? [y/n]" yn ; [[ $yn == [Yy] ]] && trizen -S --noconfirm $(cat src/game)
    SleepClear
    read -p "[?] Do you want to install some multimedia softare maker ? [y/n]" yn ; [[ $yn ==  [Yy] ]] && sudo pacman -S --noconfirm $(cat src/multi)
    SleepClear
    read -p "[?] Do you want to install all Python usefull software by pip ? [y/n]" yn ;     [[ $yn == [Yy] ]] && ([[ $(pacman -Qn python-pip) == "" ]] && sudo pacman -S --noconfirm python-pip || pip3 install -r src/pip_requiere.txt)
    SleepClear
    read -p "[?] Do you want to install some dev tool and lang ? [y/n]" yn ; [[ $yn == [Yy] ]] && sudo pacman -S --noconfirm $(cat src/dev)
    SleepClear
    printf "[!] Install Archlinux base software\n"
    sudo pacman -S --noconfirm $(cat "src/arch-base") && trizen -S --noconfirm $(cat "src/font")
    SleepClear
}

GIT(){ # generate .gitconfig
    if [[ ! -e $HOME/.gitconfig ]] ;then
        read -p "What is your username on GIT server : " GIT_USER && git config --global user.name $GIT_USER && printf "Your username is $GIT_USER\n"
        read -p "What is your email on GIT server : " GIT_MAIL && git config --global user.email $GIT_MAIL && printf "Your email is $GIT_MAIL\n"
        read -p "What is your editor for GIT commit and merge : " GIT_EDITOR && git config --global core.editor $GIT_EDITOR && printf "Your editor is $GIT_EDITOR\n"
        read -p "How do you want to name your default git branch :" && git config --global init.defaultBranch $GIT_BRANCH && printf "Your default branch is $GIT_BRANCH\n" *
        read -p "how do you want to rebase pull request [true/false]: " && git config --global pull.rebase $GIT_REBASE
    fi
}

DE() # setup DesktopEnvironement
{
    trizen -S --noconfirm $(cat src/DE)
}

asus(){ # donwload lib and soft for easy epitech workflow
    read -p "[?] Do you have a Asus with numpad on the trackpad ? [y/n]" yn && [[ $yn == [yY] ]] && trizen -S --noconfirm asus-touchpad-numpad-driver
}

user_manager(){
    sudo usermod -aG input $USER
    sudo usermod -aG uucp $USER
    sudo usermod -aG wheel $USER
    sudo usermod -aG tty $USER
    sudo groupadd dialout && sudo usermod -aG dialout $USER
}

sys(){ # enable system dep
    sudo systemctl enable cups NetworkManager bluetooth ly
    read -p "[?] What is the Name of your computer ?:" STATION && echo $STATION | sudo tee -a /etc/hostname && printf '127.0.0.1\t\tlocalhost\n::1\t\t\tlocalhost\n127.0.1.1\t\t'$STATION | sudo tee -a /etc/hosts 2&1>/dev/null
    echo '# /TMP\ntmpfs /tmp tmpfs rw,nodev,nosuid,size=7G 0 0' | sudo tee -a /etc/fstab
    sudo hwclock --systohc
    sudo ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
    sudo timedatectl set-ntp true
    sudo localectl set-keymap fr
    sudo chmod +s /sbin/shutdown
    sudo chmod +s /sbin/reboot
    [[ $SHELL != "/bin/zsh" ]] && chsh -s /bin/zsh
    (curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules)
    python3 -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/master/scripts/get-platformio.py)"
    user_manager
}

SleepClear(){
    sleep 2
    clear
}

first(){ ## install base software
    banner
    AUR
    PacInstall
}

second(){ ## setup
    SleepClear
    GIT
    SleepClear
    DE
    SleepClear
    asus
    SleepClear
    sys
    config
    SleepClear
}

config(){
    git clone https://github.com/kawaegle/Wallpaper/ --depth 1 ~/Wallpaper
    (git clone https://github.com/kawaegle/Dotfile/ --depth 1 ~/.local/share/Dotfile && ln -sf ~/.local/share/Dotfile/dotfile_manager.sh ~/.local/bin/dotfile_manager.sh && ./.local/bin/dotfile_manager.sh restore)  2>&1
    git clone https://github.com/kawaegle/Templates $HOME/Templates --depth 1 2>&1
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

main(){
    first
    read -p "[?] Do you want to continue the configuration ? [Y/n] " yn
    [[ $yn == [yY] ]] || [[ $yn == "" ]] && second && config;
    finish
}

main
