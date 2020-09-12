#!/bin/sh
###
### DOTFILE MANAGER
### Kawaegle Only
### 

CONFIG="$HOME/.config"
DOTFILE="$HOME/GIT/Dotfile/"
I3DOTFILE="$HOME/GIT/Dotfile/i3"
XFCEDOTFILE="$HOME/GIT/Dotfile/xfce"
OBDOTFILE="$HOME/GIT/Dotfile/openbox"

Save_Restore()
{
    printf "Did you want to save or restore your curent dotfile ?\n\n 1: Save\n 2: Restore\n" 
    read SAVE_RESTORE
    if [[ $SAVE_RESTORE == 1 ]]
    then
        printf "save"
        Save
    elif [[ $SAVE_RESTORE == 2 ]]
    then
        printf "restore"
        Restore
    else
        printf "Hack your bitch's ass N00B!!!"
    fi
}

Save()
{
    if [[ -d $DOTFILE ]]
    then
        printf "what is you'r Desktop Environement / Windows Manager"
        read SAVE
        if [[ $SAVE == 'i3' ]]
        then
            rm -rf $I3DOTFILE*
            print 'I3'
            cp -r $CONFIG/i3/ $I3DOTFILE/
            cp -r $CONFIG/Code\ -\ OSS/ $I3DOTFILE/
            cp -r $CONFIG/compton.conf $I3DOTFILE/
            cp -r $CONFIG/htop/ $I3DOTFILE/
            cp -r $CONFIG/ranger/ $I3DOTFILE/
            cp -r $CONFIG/rtorrent/ $I3DOTFILE/
            cp -r $CONFIG/mpv/ $I3DOTFILE/
            cp -r $HOME/.Xresources $I3DOTFILE/Xresources
            cp -r $HOME/.local/bin/ $I3DOTFILE/bin
            cp -r $HOME/.vim/ $I3DOTFILE/vim
            cp -r $HOME/.zsh/ $I3DOTFILE/zsh

        elif [[ $SAVE == 'xfce' ]]
        then
            rm -rf $XFCEDOTFILE
            printf "xfce\n Work in progress"
        elif [[ $SAVE == 'openbox' ]]
        then
            rm -rf $OBDOTFILE
            printf "openbox\n Work in progress"
        fi 
    else
        git clone https://github.com/alecromski/Dotfile $DOTFILE
        Save
    fi
}

Restore()
{   
    if [[ -d $DOTFILE ]]
    then
        printf "what is you'r Desktop Environement / Windows Manager" 
        read RESTORE
        if [[ $RESTORE == 'i3' ]]
        then
            print "i3"
            cp -r $I3DOTFILE/i3 $CONFIG/
            cp -r $I3DOTFILE/ranger $CONFIG/
            cp -r $I3DOTFILE/htop $CONFIG/
            cp -r $I3DOTFILE/rtorrent $CONFIG/
            cp -r $I3DOTFILE/Code\ -\ OSS $CONFIG/
            cp -r $I3DOTFILE/compton.conf $CONFIG/
            cp -r $I3DOTFILE/mpv $CONFIG
            cp -r $I3DOTFILE/Xresources $HOME/.Xresources
            cp -r $I3DOTFILE/vim $HOME/.vim && ln -sf $HOME/.vim/vimrc $HOME/.vimrc
            cp -r $I3DOTFILE/zsh $HOME/.zsh && ln -sf $HOME/.zsh/zshrc $HOME/.zshrc
            mkdir -p $HOME/.local/ && cp -r $I3DOTFILE/bin $HOME/.local/bin/

        elif [[ $RESTORE == 'xfce' ]]
        then
            printf "xfce\n Work in progress"
        elif [[ $RESTORE == 'openbox' ]]
        then
            printf "openbox\n Work in progress"

        fi
    else
        git clone https://github.com/alecromski/Dotfile $DOTFILE
    fi
}

Save_Restore

### File to save in dotfile
# vim
# zsh
# Icons
# Themes
# rofi
# polybar
# i3
# xfce
# vscode
# htop
# qbittorent
# libinput
# desmume
# retroarch
# mpv
# local/bin
