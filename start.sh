#!/bin/sh

GIT_USER=''
GIT_MAIL=''
GIT_PROTOCOL='https'
GIT_EDITOR='vim'

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
  Templates
  Wallpaper
  #firefoutre
  Spicetify
  Vim
  VSC
}

firefoutre()
{
  cp src/Firefox_ext.txt $HOME/
  cp src/Firefox_book.txt $HOME/
  git clone https://github.com/alecromski/start-pages $HOME/.local/
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
  spicetify
  git clone https://github.com/morpheusthewhite/spicetify-themes/ "$HOME/.config/spicetify/Themes"
  sudo chmod 777 /opt/spotify -R
  spicetify backup apply enable-devtool
  spicetify config current_theme Night
  spicetify apply
  printf "You have now spice up your spotify\n"
  )
}

Vim()
{
  if [ $HOME/.vim -f ]
  then 
  printf "you have already a vim conf"
  else
  cp -r Dotfile/vim $HOME/.vim
  ln -sf $HOME/.vim/vimrc $HOME/.vimrc
  printf "You have now configurate vim\n"
  fi
}

VSC()
{
  mv Dotfile/VSsettings.json $HOME/.config/VSCodium/User/settings.json
  vscodium --install-extension jeff-hykin.better-shellscript-syntax
  sleep 2
  vscodium --install-extension coenraads.bracket-pair-colorizer
  sleep 2
  vscodium --install-extension naumovs.color-highlight
  sleep 2
  vscodium --install-extension platformio.platformio-ide
  sleep 2
  vscodium --install-extension shyykoserhiy.vscode-spotify
  sleep 2
  vscodium --install-extension daylerees.rainglow
  sleep 2
  vscodium --install-extension royaction.color-manager
  sleep 2
  printf "You have install and setup Vscodium"
}

sysD()
{
  sudo systemctl enable ly
  sudo systemctl enable cronie
  sudo systemctl enable org.cups.cupsd
  sudo usermod -aG input $USER
  sudo usermod -aG tty $USER
  sudo groupadd dialout
  sudo usermod -aG dialout $USER
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
echo "alias git="hub"" >> $HOME/.zshrc
}

main()
{
  PacConf
  PacInstall
  SleepClear
  AUR
  AURInstall
  SleepClear
  GIT
  SleepClear
  Config
  SleepClear
  sysD
  OhMyZsh
}

main