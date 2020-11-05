#!/bin/bash

GIT_USER=''
GIT_MAIL=''
GIT_PROTOCOL='https'
GIT_EDITOR='vim'
CONFIG="$HOME/.config"
DOTFILE="$HOME/GIT/Dotfile"

Dotfile()
{
  mkdir -p $HOME/GIT
  if [[ -d $HOME/GIT/start-page ]]
  then 
    git clone https://github.com/alecromski/start-page $HOME/GIT/start-page
  elif [[ -d $HOME/Wallpaper ]]
  then
    git clone https://github.com/alecromski/Wallpaper $HOME/Wallpaper
  elif [[ -d $HOME/Templates ]]
  then
    git clone https://github.com/alecromski/Dotfile $HOME/GIT/Templates
  elif [[ -d $HOME/GIT/Dotfile ]]
  then
    git clone https://github.com/alecromski/Dotfile $HOME/GIT/Dotfile
  fi
}

AUR()
{
  read -p "do you want to install trizen ? [Y/n]" yn
  if [[ $yn == y ]]
  then
  (
  git clone https://aur.archlinux.org/trizen
  cd trizen
  makepkg -si
  cd ..
  rm -rf trizen
  )
  fi
}

PacInstall()
{
  sudo rm -rf /etc/pacman.conf
  sudo cp src/pacman.conf /etc/pacman.conf
  read -p "Do you want to add Blackarch repo ? [Y/n]" black
  if [[ $black == y ]]
  then
    mv strap.sh* 2>/dev/null
    (wget https://blackarch.org/strap.sh ; chmod +x strap.sh ; sudo sh strap.sh)
    read -p "Do you want to install BlackArch software ? [Y/n]" blackarch
    if [[ $blackarch == y ]]
    then
      sudo pacman -S $(cat "src/BlackarchInstall")
    fi
  fi
  sudo pacman -Syy
  sudo pacman -S $(cat "src/Archlinux")
}

AURInstall()
{
  read -p "do you want install all AUR package ? [Y/n]" yn
  if [[ $yn == y ]]
  then
    trizen -S $(cat "src/AURInstall") 
    printf "You have install all software from AUR repositories\n"
  fi
}

GIT()
{
  rm -rf .gitconfig
  read -p "What is your username on GIT server : " GIT_USER
  git config --global user.name $GIT_USER; printf "Your username is $GIT_USER\n"
  read -p "What is your email on GIT server : " GIT_MAIL
  git config --global user.email $GIT_MAIL; printf "Your email is $GIT_MAIL\n"
  read -p "What is your editor for GIT commit and merge : " GIT_EDITOR
  git config --global core.editor $GIT_EDITOR; printf "Your editor is $GIT_EDITOR\n"
  read -p "What is your protocol (ssh/https) for GIT server : " GIT_PROTOCOL
  git config --global hub.protocol $GIT_PROTOCOL ;printf "Your protocol is $GIT_PROTOCOL\n"
 }

##
I3()
{
  trizen -Syy $(cat "src/I3")
}
##

Zsh()
{
  cp -r $DOTFILE/zsh $HOME/.zsh
  ln -sf $HOME/.zsh/zshrc $HOME/.zshrc
  (
    zplug instal
  )
}

Vim()
{
  if [[ -d $HOME/.vim ]] || [[ -f $HOME/.vim ]]
  then 
    printf "you have already a vim conf"
  else
	  cp -r $DOTFILE/vim $HOME/.vim
	  ln -sf $HOME/.vim/vimrc $HOME/.vimrc
  fi
}

VSC()
{
  mkdir -p $CONFIG/Code\ -\ OSS/
  cp -r $DOTFILE/Code\ -\ OSS/ $CONFIG/Code\ -\ OSS/
  code --install-extension platformio.platformio-ide;sleep 2 #Arduino maker
  code --install-extension jeff-hykin.better-shellscript-syntax;sleep 2 #Shell syntax
  code --install-extension anseki.vscode-color;sleep 2 #Color picker
  code --install-extension vscode.vscode-theme-seti;sleep 2 #Icons theme
  code --install-extension dcasella.i3;sleep 2 #I3 syntax
  code --install-extension coenraads.bracket-pair-colorizer-2;sleep 2 #Bracket pairing
  code --install-extension ajshortt.tokyo-hack;sleep 2 #Color theme
  printf "You have install and setup Visual Studio Code"
}

Config()
{
  I3
  Zsh
  Vim
  VSC
}

sysD()
{
  sudo systemctl enable ly
  sudo systemctl enable cronie
  sudo systemctl enable org.cups.cupsd
  sudo localectl set-keymap fr
  sudo localectl set-x11-keymap fr
  (curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules)
  sudo usermod -aG input $USER
  sudo usermod -aG uucp $USER
  sudo usermod -aG tty $USER
  sudo groupadd dialout && sudo usermod -aG dialout $USER
  chsh -s /bin/zsh
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
  AURInstall
  SleepClear
  GIT
  SleepClear
  Config
  SleepClear
  sysD
}

main
