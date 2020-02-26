USER="kawaegle"
EMAIL="alecromski@gmail.com"
HUB="https"
VERSION="1.1.Oppai"
YES_NO="1"

config()
{
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ -d "$HOME/.vim*" ]
    then
        rm -rf $HOME/.vim* ; git clone https://github.com/kawaegle/Vim $HOME/.vim/ ; ln -sf $HOME/.vim/vimrc/ $HOME/.vimrc
    else
        git clone https://github.com/kawaegle/Vim $HOME/.vim/ ; ln -sf $HOME/.vim/vimrc/ $HOME/.vimrc
    fi

    if [ -d "$HOME/Templates" ]
    then
        rm -rf $HOME/Templates ; git clone https://github.com/kawaegle/Templates $HOME/Templates/
    else
        git clone https://github.com/kawaegle/Templates $HOME/Templates/
    fi
    GIT
}

GIT()
{
    if [ -e "$HOME/.gitconfig" ]
    then 
        mv $HOME/.gitconfig $HOME/.gitconfig.oppai ; printf ".gitconfig was present, so we move it to .gitconfig.oppai"
        printf "What is your github/Coder/Programmer username ? \n"
        read USER
        git config --global user.name
        printf "What is your github/Coder/Programmer mail address? \n"
        read EMAIL
        git config --global user.email
        git config --global hub.protocol https
    else
        printf "What is your github/Coder/Programmer username ? \n"
        read USER
        git config --global user.name $USER
        printf "What is your github/Coder/Programmer mail address? \n"
        read EMAIL
        git config --global user.email $EMAIL
        printf "What protocol you want for hub (github cli helper) ssh/https"
        read HUB
        git config --global hub.protocol HUB $HUB
    fi 
}

pacman_conf()
{

}

sleep_clear()
{
  sleep $1
  clear

  return $SUCCESS
}s

URXVT()
{
    echo "URxvt.scrolBar: false" > $HOME/.Xressources
}

########### START ############
main()
{

}

main