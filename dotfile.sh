#!/bin/bash

dotfile(){
    mkdir -p $HOME/.local/share/
    mkdir -p $HOME/.local/bin
    mkdir -p $HOME/.config

    if [[ ! -d "$HOME/Wallpaper/" ]]; then
        git clone --filter=blob:none https://github.com/kawaegle/Wallpaper/ "$HOME/Wallpaper"
    fi
    if [[ ! -d "$HOME/.dotfile/" ]]; then
        git clone --recursive --filter=blob:none https://github.com/kawaegle/dotfile/ "$HOME/.dotfile/"
        (cd "$HOME/.dotfile/" && stow -S */)
    fi
    if [[ ! -d $HOME/Templates/ ]]; then
        git clone --filter=blob:none https://github.com/kawaegle/Templates "$HOME/Templates"
    fi
}

