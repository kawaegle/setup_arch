 #!/bin/bash

GIT_USER=''
GIT_MAIL=''
GIT_EDITOR='vim'
GIT_BRANCH='master'
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
	read -p "do you want to install trizen ? [Y/n]" yn; [[ $yn == y ]] && (git clone https://aur.archlinux.org/trizen /tmp/trizen && cd /tmp/trizen && makepkg -si)
	read -p "do you want install all AUR package ? [Y/n]" yn ; [ $yn == y ] && trizen -S $(cat "src/aur") && printf "You have install all software from AUR repositories\n"
}

PacInstall(){ # generate pacman mirrorlist blackarch and install all software i need
    sudo rm -rf /etc/pacman.conf
    sudo cp src/pacman.conf /etc/pacman.conf

    read -p "do you want to automaticaly regenerate pacman depots ? [Y/n]" depots ;	[[ $depots = y ]] && (sudo pacman -S reflector && sudo reflector -c FR -c US -c GB -c PL -n 100 --info --protocol http,https --save /etc/pacman.d/mirrorlist)

	read -p "Do you want to add Blackarch repo ? [Y/n]" black && [[ $black = y ]] && (wget -O /tmp/strap.sh https://blackarch.org/strap.sh && chmod +x /tmp/strap.sh && sudo sh /tmp/strap.sh) 

	read -p "Do you want to install BlackArch software ? [Y/n]" blackarch && [[ $blackarch = y ]] && sudo pacman -S $(cat "src/black")

	read -p "Do you want to install some games stations ? [Y/n]" game ; [[ $game = y ]] && trizen -S $(cat src/game)

	read -p "Do you want to install some multimedia softare maker ? [y/n]" multi ; [[ $multi = y ]] && sudo pacman -S $(cat src/multi) 

	read -p "Do you want to install all Python usefull software by pip ? [y/n]" yn ; [[ $yn == y ]] && sudo pacman -S python-pip && pip3 install -r install src/pip_requiere.txt
	
	sudo pacman -Syy 
	
	print "Install Archlinux base software" ; sudo pacman -S $(cat "src/arch-base")
}

GIT(){ # generate .gitconfig
    [[ ! -e $HOME/.gitconfig ]] && read -p "What is your username on GIT server : " GIT_USER && git config --global user.name $GIT_USER && printf "Your username is $GIT_USER\n" &&	read -p "What is your email on GIT server : " GIT_MAIL && git config --global user.email $GIT_MAIL && printf "Your email is $GIT_MAIL\n" && read -p "What is your editor for GIT commit and merge : " GIT_EDITOR &&	git config --global core.editor $GIT_EDITOR && printf "Your editor is $GIT_EDITOR\n" && read -p "How do you want to name your default git branch :" && git config --global init.defaultBranch $GIT_BRANCH && printf "Your default branch is $GIT_BRANCH\n"
}

##
DE() # setup DesktopEnvironement
{
	#trizen -S $(cat src/DE)
	printf "Work in progress N00B"
	sleep 5
}
##

epitech(){
	print "Work in progress n00b"
	sleep 5
	# sudo pacman -S $(cat src/epitech)
	
}

user_manage(){
	sudo usermod -aG input $USER
	sudo usermod -aG uucp $USER
	sudo usermod -aG tty $USER
	sudo groupadd dialout && sudo usermod -aG dialout $USER
}

sysD(){ # enable system dep
	sudo systemctl enable cups NetworkManager bluetooth 
	read -p "What is the Name of your computer ?" STATION && echo $STATION | sudo tee -a /etc/hostname && echo '127.0.0.1\t\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t\t'$STATION | sudo tee -a /etc/hosts
	sudo hwclock --systohc
	sudo timedatectl set-ntp true
	sudo localectl set-keymap fr
	sudo localectl set-x11-keymap fr
	sudo chmod +s /sbin/shutdown
	sudo chmod +s /sbin/reboot
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
	epitech
	SleepClear
	sysD
}

config(){
	(git clone https://github.com/kawaegle/Dotfile/ /tmp/dotfile && cd /tmp/dotfile && ./dotfile restore)  2>&1
}

finish(){
	printf "You 'll need to restart soon...\nBut no problem just wait we'll restart it for you.\n"; sleep 2
	printf "Reboot in 5...\n"; sleep 1
	printf "Reboot in 4...\n"; sleep 1
	printf "Reboot in 3...\n"; sleep 1
	printf "Reboot in 2...\nsearxh"; sleep 1
	printf "Reboot in 1...\n"; sleep 1
	printf "Reboot now..."
	sudo reboot
}

main(){
	first
	read -p "Do you want to continue the configuration ? [Y/n] " yn
	[[ $yn != 'n' ]] && exit || second && config;
	finish
}

main
