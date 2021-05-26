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
	read -p "[?] Do you want to install trizen ?[Y/n]" yn ; [[ $yn == [yY] ]] || [[ $yn == "" ]] && (git clone https://aur.archlinux.org/trizen /tmp/trizen && cd /tmp/trizen && makepkg -si)
	SleepClear
	read -p "[?] Do you want install all AUR package ?[Y/n]" yn ; [[ $yn == [yY] ]] || [[ $yn == "" ]] && trizen -S --noconfirm $(cat "src/aur") && clear && printf "\n[!] You have install all software from AUR repositories"
	SleepClear
}

PacInstall(){ # generate pacman mirrorlist blackarch and install all software i need
	printf "[!] Reload pacman.conf\n"
    sudo rm -rf /etc/pacman.conf;sudo cp src/pacman.conf /etc/pacman.conf
	sleep 3
	printf "[!] Update package list\n"
	sudo pacman -Syy
	SleepClear
    read -p "[?] Do you want to automaticaly regenerate pacman depots ? [Y/n]" depots ;	[[ $(pacman -Qn reflector) == "" ]] && sudo pacman -S --noconfirm reflector
	[[ $depots = [yY] ]] && sudo reflector -c FR -c US -c GB -c PL -n 100 --info --protocol http,https --save /etc/pacman.d/mirrorlist
	SleepClear
	read -p "[?] Do you want to add Blackarch repo ? [Y/n]" black && [[ $black = y ]] && (wget -O /tmp/strap.sh https://blackarch.org/strap.sh && chmod +x /tmp/strap.sh && sudo sh /tmp/strap.sh) 
	SleepClear
	read -p "[?] Do you want to install BlackArch software ? [Y/n]" blackarch && [[ $blackarch = y ]] && sudo pacman -S --noconfirm $(cat "src/black")
	SleepClear
	read -p "[?] Do you want to install some games stations ? [Y/n]" game ; [[ $game = y ]] && trizen -S --noconfirm $(cat src/game)
	SleepClear
	read -p "[?] Do you want to install some multimedia softare maker ? [y/n]" multi ; [[ $multi = y ]] && sudo pacman -S --noconfirm $(cat src/multi) 
	SleepClear
	read -p "[?] Do you want to install all Python usefull software by pip ? [y/n]" pip ; [[ $(pacman -Qn python-pip) == "" ]] && sudo pacman -S --noconfirm python-pip; 
	[[ $pip == y ]] && pip3 install -r src/pip_requiere.txt
	SleepClear

	printf "[!] Install Archlinux base software\n" ; sudo pacman -S --noconfirm $(cat "src/arch-base")
	SleepClear
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
	printf "Work in progress n00b"
	sleep 5
	# sudo pacman -S $(cat src/epitech)
	
}

user_manager(){
	sudo usermod -aG input $USER
	sudo usermod -aG uucp $USER
	sudo usermod -aG tty $USER
	sudo groupadd dialout && sudo usermod -aG dialout $USER
}

sysD(){ # enable system dep
	sudo systemctl enable cups NetworkManager bluetooth 
	read -p "[?] What is the Name of your computer ?:" STATION && echo $STATION | sudo tee -a /etc/hostname && printf '127.0.0.1\t\tlocalhost\n::1\t\t\tlocalhost\n127.0.1.1\t\t'$STATION | sudo tee -a /etc/hosts 2&1>/dev/null
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
	config
	SleepClear
}

config(){
	(git clone https://github.com/kawaegle/Dotfile/ /tmp/dotfile && cd /tmp/dotfile && ./dotfile restore)  2>&1
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
