#!/bin/bash

GIT_USER=''
GIT_MAIL=''
GIT_PROTOCOL='https'
GIT_EDITOR='vim'
CONFIG="$HOME/.config"
DOTFILE="$HOME/GIT/Dotfile/"
DOTFILE_DIR="$HOME/GIT/DOTFILE/Dotfile"

Dotfile() # clone dotfile where they need to be cloned
{
    mkdir -p $HOME/GIT
    [ ! -e $HOME/GIT/start-page ] && git clone https://github.com/alecromski/start-page $HOME/GIT/start-page
    [ ! -e $HOME/Wallpaper ] && git clone https://github.com/alecromski/Wallpaper $HOME/Wallpaper
    [ ! -e $HOME/Templates ] && git clone https://github.com/alecromski/Templates $HOME/Templates
    [ ! -e $HOME/GIT/Dotfile ] && git clone https://github.com/alecromski/Dotfile $DOTFILE
}

AUR() # install AUR manager and aur software
{
	read -p "do you want to install trizen ? [Y/n]" yn
	[ $yn == y ] && (git clone https://aur.archlinux.org/trizen && cd trizen && makepkg -si && cd .. && rm -rf trizen); read -p "do you want install all AUR package ? [Y/n]" yn ; [ $yn == y ] && trizen -S $(cat "src/AURInstall") && printf "You have install all software from AUR repositories\n"
}

PacInstall() # generate pacman mirrorlist blackarch and install all software i need
{
    sudo rm -rf /etc/pacman.conf
    sudo cp src/pacman.conf /etc/pacman.conf
    read -p "do you want to automaticaly regenerate pacman depots ? [Y/n]" depots ;	[ $depots = y ] && (sudo pacman -S reflector && sudo reflector -c FR -c US -c GB -c PL -n 100 --info --protocol http,https --save /etc/pacman.d/mirrorlist) ; read -p "Do you want to add Blackarch repo ? [Y/n]" black && [ $black = y ] && (wget https://blackarch.org/strap.sh && chmod +x strap.sh && sudo sh strap.sh && sudo rm strap.sh ) ; read -p "Do you want to install BlackArch software ? [Y/n]" blackarch && [ $blackarch = y ] && sudo pacman -S $(cat "src/Blackarch"); read -p "Do you want to install some games stations ? [Y/n]" game ; [ $game = y ] && trizen -S $(cat src/game) ; read -p "Do you want to install some multimedia softare maker ? [y/n]" multi ; [ $multi = y ] && sudo pacman -S $(cat src/multi) ; sudo pacman -Syy && read -p "Do you want to install all other usefull software ? [Y/n]" arch && [ $arch = y  ] && sudo pacman -S $(cat "src/Archlinux") 
}

GIT()
{
    [ ! -e $HOME/.gitconfig ] && read -p "What is your username on GIT server : " GIT_USER && git config --global user.name $GIT_USER && printf "Your username is $GIT_USER\n" &&	read -p "What is your email on GIT server : " GIT_MAIL && git config --global user.email $GIT_MAIL && printf "Your email is $GIT_MAIL\n" && read -p "What is your editor for GIT commit and merge : " GIT_EDITOR &&	git config --global core.editor $GIT_EDITOR && printf "Your editor is $GIT_EDITOR\n" &&	read -p "What is your protocol (ssh/https) for GIT server : " GIT_PROTOCOL && git config --global hub.protocol $GIT_PROTOCOL &&	printf "Your protocol is $GIT_PROTOCOL\n" 
}

##
DE()
{
	printf "Work in progress N00B"
}
##

Zsh()
{
	[[ -e $HOME/.zsh && ! -e $HOME/.zsh/zplug ]] && git clone http://zplug/zplug $HOME/.zsh/zplug ; cp -r $DOTFILE_DIR/zsh $HOME/.zsh && ln -sf $HOME/.zsh/zshrc $HOME/.zshrc
}

Vim()
{
    [[ -e $HOME/.vim || -e $HOME/.vimrc ]] && printf "you have already a vim conf" || cp -r $DOTFILE/vim $HOME/.vim && ln -sf $HOME/.vim/vimrc $HOME/.vimrc
}

VSC()
{
	mkdir -p $CONFIG/Code\ -\ OSS/
	code --install-extension OppaiWeeb.OppaiPack
	printf "You have install and setup Visual Studio Code"
}

Config()
{
	DE
	Zsh
	Vim
	VSC
}

sysD()
{
	sudo systemctl enable org.cups.cupsd
	sudo localectl set-keymap fr
	sudo localectl set-x11-keymap fr
	(curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules)
	sudo usermod -aG input $USER
	sudo usermod -aG uucp $USER
	sudo usermod -aG tty $USER
	sudo groupadd dialout && sudo usermod -aG dialout $USER
	[! $SHELL '/bin/zsh' ] && chsh -s /bin/zsh
}

SleepClear()
{
	sleep 2
	clear
}

main()
{
	Dotfile 
	AUR
	PacInstall
	SleepClear
	GIT
	SleepClear
	Config
	SleepClear
	sysD
}

main
