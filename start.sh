#!/bin/sh

GIT_USER=''
GIT_MAIL=''
GIT_PROTOCOL='https'
GIT_EDITOR='vim'
DE=''

PacConf()
{
  sudo rm -rf /etc/pacman.conf
  sudo cp src/pacman.conf /etc/pacman.conf
  sudo pacman -Scc
}

PacInstall()
{
  sudo pacman -Syy $(cat "src/PacInstall")
  printf "you have install all needed package form official server\n"
}

AUR()
{
  (  
  git clone https://aur.archlinux.org/trizen
  cd trizen
  makepkg -si
  cd ..
  rm -rf trizen
  )
}

AURInstall()
{
  trizen -S $(cat "src/AURInstall")
  printf "You have install all software from AUR repositories\n"
}

GIT()
{
  if [ -e $HOME/.gitconfig ]
  then
    mv $HOME/.gitconfig $HOME/.gitconfig.back
    printf "What is your username on GIT server : "
    read -r GIT_USER
    git config --global user.name $GIT_USER
    printf "Your username is $GIT_USER\n"
    printf "What is your email on GIT server : "
    read -r GIT_MAIL
    git config --global user.email $GIT_MAIL
    printf "Your email is $GIT_MAIL\n"
    printf "What is your editor for GIT commit and merge : "
    read -r GIT_EDITOR
    git config --global core.editor $GIT_EDITOR
    printf "Your editor is $GIT_EDITOR\n"
    printf "What is your protocol (ssh/https) for GIT server : "
    read -r GIT_PROTOCOL
    git config --global hub.protocol $GIT_PROTOCOL
    printf "Your protocol is $GIT_PROTOCOL\n"
  else
    printf "What is your username on GIT server : "
    read -r GIT_USER
    git config --global user.name $GIT_USER
    printf "Your username is $GIT_USER\n"
    printf "What is your email on GIT server : "
    read -r GIT_MAIL
    git config --global user.email $GIT_MAIL
    printf "Your email is $GIT_MAIL\n"
    printf "What is your editor for GIT commit and merge : "
    read -r GIT_EDITOR
    git config --global core.editor $GIT_EDITOR
    printf "Your editor is $GIT_EDITOR\n"
    printf "What is your protocol (ssh/https) for GIT server : "
    read -r GIT_PROTOCOL
    git config --global hub.protocol $GIT_PROTOCOL
    printf "Your protocol is $GIT_PROTOCOL\n"
  fi
}

Config()
{
  git clone https://github.com/alecromski/dotfile
}

Templates()
{
  git clone https://github.com/alecromski/Templates $HOME/Templates
  printf "You have now some Templates file in $HOME/Templates\n"
}

Wallpaper()
{
  git clone https://github.com/alecromski/Wallpaper $HOME/Wallpaper
  printf "You have now some Wallpaper in $HOME/Wallpaper\n"
}

Spicetify()
{
  (
  sudo chmod 777 /opt/spotify -R
  spicetify
  spicetify backup apply enable-devtool
  cp -r dotfile/spicetify/Themes $HOME/.config/spicetify/
  spicetify config current_theme = Elementary
  spicetify update
  printf "You have now spice up your spotify\n"
  )
}

Vim()
{
  cp -r dotfile/vim $HOME/.vim
  ln -sf $HOME/.vim/vimrc $HOME/.vimrc
  printf "You have now configurate vim\n"
}

sysD()
{
  (
    sudo systemctl enable ly
  )
}

SleepClear()
{
  sleep 5
  clear
}

OhMyZsh()
{
  (
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  )
}

DE_WM()
{
  printf "Witch Desktop you want ?\n\t[1] I3wm\n\t[2] Sway\n\t[3] Xfce\n"
  read DE
  if [ $DE == '1' ] 
  then
  pacman -Sy $(cat src/i3install)
  trizen -S $(cat src/i3AUR)
  printf "You have install I3"
  elfi [ $DE == '2' ]
  then 
  pacman -Sy $(cat src/swayinstall)
  trizen -S $(cat src/swayAUR)
  printf "You have install sway"
  else
  pacman -Sy $(cat src/xfceinstall)
  trizen -S $(cat src/xfceAUR)
  printf "You have install xfce
}

main()
{
  PacConf
  PacInstall
  SleepClear
  AUR
  SleepClear
  AURInstall
  SleepClear
  GIT
  SleepClear
  Config
  Templates
  SleepClear
  Wallpaper
  #Spicetify
  SleepClear
  #Vim
  sysD
  OhMyZsh
  DE_WM
}

main
