#!/bin/sh

GIT_USER=''
GIT_MAIL=''
GIT_PROTOCOL='https'
GIT_EDITOR='vim'
CONFIG='$HOME/.config'

PacConf()
{
  sudo rm -rf /etc/pacman.conf
  sudo cp src/pacman.conf /etc/pacman.conf
  (mkdir $HOME/.trizen; cp src/trizen.conf $CONFIGtrizen/)
  rm strap.sh 2>/dev/null
  (wget https://blackarch.org/strap.sh ; chmod +x strap.sh ; sudo sh strap.sh)
  sudo pacman -Scc
}

PacInstall()
{
  sudo pacman -Syy $(cat "src/PacInstall") 2>/dev/null
  printf "you have install all needed package form official server\n"
}

AUR()
{
  read -p "do you want to install trizen ? " yn
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
  read -p "do you want install all aur package ?" yn
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
    git config --global user.name $GIT_USER
    printf "Your username is $GIT_USER\n"
    read -p "What is your email on GIT server : " GIT_MAIL
    git config --global user.email $GIT_MAIL
    printf "Your email is $GIT_MAIL\n"
    read -p "What is your editor for GIT commit and merge : " GIT_EDITOR
    git config --global core.editor $GIT_EDITOR
    printf "Your editor is $GIT_EDITOR\n"
    read -p "What is your protocol (ssh/https) for GIT server : " GIT_PROTOCOL
    git config --global hub.protocol $GIT_PROTOCOL
    printf "Your protocol is $GIT_PROTOCOL\n"
 }

X11()
{
  print "Do you want use X11 server ?"
  read -q yn
  if [[ $yn == 'n' ]]
  then
    print "You will need to install it later"
  else
    print "Do you want to use \n\t(1)XFCE\n\t(2)I3 ?" 
    read I3XFCE
    if [[ $I3XFCE == '1']]
    then 
      git clone https://github.com/alecromski/Dotfile -b xfce
      XFCE
    else
      git clone https://github.com/alecromski/Dotfile -b i3
      I3
    fi
  fi
}

XFCE()
{

}

I3()
{

}

conf()
{
   git clone https://github.com/alecromski/Templates $HOME/
   git clone https://github.com/alecromski/Wallpaper $HOME/
}

Vim()
{
  if [[ -d $HOME/.vim ]] || [[ -f $HOME/.vim]]
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
    mkdir -p $CONFIGVSCodium/User/	
    cp  Dotfile/VSsettings.json $CONFIGVSCodium/User/settings.json
    code --install-extension jeff-hykin.better-shellscript-syntax;sleep 2
    code --install-extension coenraads.bracket-pair-colorizer;sleep 2
    code --install-extension dlasagno.wal-theme;sleep 2
    code --install-extension naumovs.color-highlight;sleep 2
    code --install-extension platformio.platformio-ide;sleep 2
    code --install-extension shyykoserhiy.vscode-spotify;sleep 2
    code --install-extension royaction.color-manager;sleep 2
    code --install-extension juanmnl.vscode-theme-1984;sleep 2
    code --install-extension pkief.material-icon-theme;sleep 2
    printf "You have install and setup Vscodium"
}

Zsh()
{
  cp -r Dotfile/zsh $HOME/.zsh
  ln -sf $HOME/.zsh/zshrc $HOME/.zshrc
}

freecad()
{
  wget -q --show-progress --progress=bar -O $HOME/.local/bin/freecad.AppImage https://github.com/FreeCAD/FreeCAD/releases/download/0.18.4/FreeCAD_0.18-16146-Linux-Conda_Py3Qt5_glibc2.12-x86_64.AppImage 
  sudo chmod +x $HOME/.local/bin/freecad.AppImage
  sudo ln -sf /usr/bin/freecad
  sudo chmod +x /usr/bin/freecad
}

Config()
{
  X11
  conf
  Zsh
  Vim
  #freecad
  VSC
}

sysD()
{
  sudo systemctl enable ly
  sudo systemctl enable cronie
  sudo systemctl enable org.cups.cupsd
  sudo localectl set-keymap fr
  sudo localectl set-x11-keymap fr
  libinput-gestures-setup autostart
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
}

main
