#!/bin/bash

GIT_USER=''
GIT_MAIL=''
GIT_PROTOCOL='https'
GIT_EDITOR='vim'
CONFIG=$HOME/.config

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

AURInstall()
{
  read -p "do you want install all AUR package ? [Y/n]" yn
  if [[ $yn == y ]]
  then
    trizen -S $(cat "src/AURInstall") 
    printf "You have install all software from AUR repositories\n"
  fi
}

PacInstall()
{
  sudo rm -rf /etc/pacman.conf
  sudo cp src/pacman.conf /etc/pacman.conf
  mkdir -p $CONFIG/trizen 
  cp src/trizen.conf $CONFIG/trizen/
  read -p "Do you want to add Blackarch repo ? [Y/n]" black
  if [[ $black == y ]]
  then
    mv strap.sh 2>/dev/null
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
X11()
{
  printf "Do you want to use \n\t(1)XFCE\n\t(2)I3\n ?"
  read DE
  if [[ $DE == '1' ]]
  then
    print "XFCE"
    XFCE
  else
    print "i3"
    I3
  fi
}

XFCE()
{
  trizen -Syy $(cat "src/XFCE")
  gestures
}

I3()
{
  trizen -Syy $(cat "src/I3")
}
##

gestures()
{
  cp $DOTFILE/libinput-gestures.conf $CONFIG/libinput-gestures.conf 
  libinput-gestures-setup autostart
}

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

spice()
{
  mkdir -p $CONFIG/spicetify
  sudo chmod a+wr /opt/spotify
  sudo chmod a+wr /opt/spotify/Apps-R 
  git clone https://github.com/morpheusthewhite/spicetify-themes $CONFIG/spicetify/Themes
  spicetify
  spicetify curent_theme Pop-Dark
  SleepClear
  read -p "Do you want to apply spotify theme change ? [Y/n]\n" yn
  printf "[!]Only if spotify was already launch[!]"
  if [[ $yn == y ]]
  then
    spicetify backup apply 
  fi
}

VSC()
{
  mkdir -p $CONFIG/Code\ -\ OSS/
  cp -r $DOTFILE/Code\ -\ OSS/ $CONFIG/Code\ -\ OSS/
  code --install-extension jeff-hykin.better-shellscript-syntax;sleep 2
  code --install-extension coenraads.bracket-pair-colorizer;sleep 2
  code --install-extension dlasagno.wal-theme;sleep 2
  code --install-extension naumovs.color-highlight;sleep 2
  code --install-extension platformio.platformio-ide;sleep 2
  code --install-extension shyykoserhiy.vscode-spotify;sleep 2
  code --install-extension royaction.color-manager;sleep 2
  code --install-extension juanmnl.vscode-theme-1984;sleep 2
  code --install-extension pkief.material-icon-theme;sleep 2
  code --install-extension dcasella.i3;sleep 2
  printf "You have install and setup Visual Studio Code"
}

Config()
{
  X11
  Zsh
  Vim
  spice
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
  sudo groupadd dialout
  sudo usermod -aG dialout $USER
}

SleepClear()
{
  sleep 2
  clear
}

main()
{
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
