VERSION='1.1.Oppai'

GITUSER=''  #user use for github
EMAIL=''    #email use for github
HUB=''  #protocols for hub
YES_NO=''   #yes=1 no=0
DM=''   #dispaly manager
AUR=''   #AUR manager
DE_WM=''    #desktop environment or windows manager



vim_config()
{

    if [ -e $HOME/.vim* ]
    then 
        printf "take a backup of .vim and install .vim by alecromski"
        mkdir -p $HOME/Backup/ 
        mv .vim* $HOME/Backup/
        git clone https://github.com/alecromski/vim $HOME/.vim && ln -sf $HOME/.vim/vimrc $HOME/.vimrc
    else 
        printf "install .vim by alecromski"
        git clone https://github.com/alecromski/vim $HOME/.vim && ln -sf $HOME/.vim/vimrc $HOME/.vimrc
    fi
}

templates()
{
    if [ -e $HOME/Templates ]
    then 
        printf "take a backup of Templates and install Templates by alecromski"
        mkdir -p $HOME/Backup/ 
        mv Templates $HOME/Backup/
        git clone https://github.com/alecromski/Templates $HOME/Templates
    else 
        printf "install .vim by alecromski"
        git clone https://github.com/alecromski/Templates $HOME/Templates
    fi
}

GIT()
{
    if [ -e "$HOME/.gitconfig" ]
    then 
        mv $HOME/.gitconfig $HOME/.gitconfig.oppai ; printf ".gitconfig was present, so we move it to .gitconfig.oppai"
        printf "What is your github/Coder/Programmer username ? \n"
        read GITUSER
        git config --global user.name $GITUSER
        printf "What is your github/Coder/Programmer mail address? \n"
        read EMAIL
        git config --global user.email $EMAIL
        printf "What protocol you want for hub (github cli helper) ssh/https\n"
        read HUB
        git config --global hub.protocol HUB $HUB
    else
        printf "What is your github/Coder/Programmer username ? \n"
        read GITUSER
        git config --global user.name $USER
        printf "What is your github/Coder/Programmer mail address? \n"
        read EMAIL
        git config --global user.email $EMAIL
        printf "What protocol you want for hub (github cli helper) ssh/https\n"
        read HUB
        git config --global hub.protocol HUB $HUB
    fi 
}

YES_NO()
{
    while $YES_NO == ''
    do
    read YES_NO
    case $YES_NO in
    YES|Yes|yes|OUI|Oui|oui|y|Y|o|O)
        YES_NO = '1';;
    NO|No|no|NON|Non|non|n|N)
        YES_NO = '0';;
    *)
    break;;
    esac
    done
}

DM()
{
    printf "Do you want a Display Manager ? \n"
    YES_NO
    if [ $YES_NO == '1' ]
        then 
        git clone https://github.com/alecromski/DM /tmp/
        printf "chose your favorite DM"
        read DM
        printf "[1]lightdm\n[2]ly\n"
        if [ $DM == '1' ]
        then 
            sudo $PM lightdm 
            cp -r /tmp/DM/lightdm/ $HOME/
            sudo systemctl enable lightdm.service
        else
            trizen -S ly #verif
            cp -r /tmp/DM/ly/ $HOME/
            sudo systemctl enable ly.service
        fi
    else
        printf "what is your DesktopManager / Windows manager"
        printf "[1]fluxbox\n[2]I3\n[3]mate\n[4]Xfce\n"
        read $DE_WM
        if [ $DE_WM == '1' ]
        then 
            echo "#!/bin/sh\nexec i3" > $HOME/.xinitrc
        elif [ $DM == '2' ]
        then
            echo "#!/bin/sh\nexec mate-session" > $HOME/.xinitrc
        elif [ $DM == '3' ]
        then
            echo "#!/bin/sh\nexec xfce4-session" > $HOME/.xinitrc
        else
            echo "#!/bin/sh\nexec fluxbox-session" > $HOME/.xinitrc
        fi
    fi
}

base()
{
    printf "Do you want to install base software ? "
    YES_NO
    if [ $YES_NO == '1' ]
    then
        sudo pacman --force -S ${cat base.install } 2>&1
    else
        printf "let's go to live on edge side"
    fi
}

DE_WM()
{
    printf "you need to select a Desktop environment or a windows manager"
    printf "[1]fluxbox\n[2]I3\n[3]mate\n[4]Xfce\n"
    read $DE_WM
    if [ $DE_WM == '1' ]
    then 
       fluxbox()
    elif [ $DM == '2' ]
    then
       i3()
    elif [ $DM == '3' ]
    then
        mate()
    else
        xfce()
    fi
}

AUR()
{
    printf "choose a AUR package manager \n [1]pamac\n[2]trizen\n[3]yay"
    read $AUR
    if [ $AUR == '1' ]
    then 
        git clone https://aur.archlinux.org/pamac 
        cd pamac && makepkg -si && cd ..
        printf "Pamac is now installed"
    if [ $AUR == '2' ]
    then 
        git clone https://aur.archlinux.org/trizen
        cd trizen && makepkg -si && cd ..
        cp -r /tmp/soft_config/trizen/ $HOME/.config/trizen

        printf "trizen is now installed"
    else
        git clone https://aur.archlinux.org/yay
        cd yay && makepkg -si && cd .. 
        printf "yay is now installed"
    fi
}

soft_config()
{
    printf "goig to install all software and config file"
    git clone https://github.com/kawaegle/soft_config /tmp
    #spotify
    cp -r /tmp/soft_config/spicetify/ $HOME/.config/
    sudo chmod 777 /opt/spotify -R
    spicetify config current_theme Night
    spicetify backup apply enable-devtool
    #vscodium
    cp -r /tmp/soft_config/VSCodium/ $HOME/.config/
    cp -r /tmp/soft_config/vscodium-oss $HOME/.vscodium-oss
    
    
}