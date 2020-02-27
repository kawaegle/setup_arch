USER=""
EMAIL=""
HUB=""
DE=""
VERSION="1.1.Oppai"
YES_NO="1"

vim()
{
    git clone https://github.com/alcromski/vim $HOME/.vim && ln -sf $HOME/.vim/vimrc $HOME/.vimrc
    printf "load vim config file"
}

templates()
{
    git clone https://github.com/alecromski/Templates Templates
    printf "there is all templates file from Parrotsec, fork by me"
}

pacman_install()
{
    sudo pacman -S --noconfirm $(cat pacadd)
    printf "you have install all package need avaible in official repository"
}

trizen()
{
    git clone https://aur.archlinux.org/trizen 
    cd trizen && makepkg -si
    cd ..
    printf "you have now install trizen"
}

aurInstall()
{
    trizen -S $(cat aurInstall)
    printf "you have now install all software and package need from AUR"
}

oh-my-zsh()
{
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    printf "install oh my zsh (you can load some plugins)"
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
    sudo cp Config/pacman.conf /etc/pacman.conf
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

DE_WM()
{
    printf "What is the Desktop manager / Window manager you want to install ?"
    printf "[1]I3\n[2]Mate\n[3]Xfce\n"
    read DE
    sudo systemctl enable ly
    if [ $DE == '1' ]
    then 
        URXVT
        sudo pacman -S $(cat Config/I3/pacadd)
        trizen -S $(cat Config/I3/aurInstall)
        i3
    elif[ $DE == '2' ]
    then
        sudo pacman -S $(cat Config/mate/pacadd)
        trizen -S $(cat Config/mate/aurInstall)
        mate
    elif [ $DE == '3' ]
    then
        sudo pacman -S $(cat Config/xfce/pacadd)
        trizen -S $(cat Config/xfce/aurInstall)
        xfce
    else
        printf " /!\WHAT THE FUCK /!\ "
        DE_WM
}

wallpaper()
{
    git clone https://github.com/alecromski/wallpaper $HOME/Wallpaper
    printf "You have install wallpaper"
}

########### START ############

main()
{
pacman_conf
pacman_install
trizen
sleep_clear
GIT
sleep_clear
aurInstall
DE_WM
vim
templates
Wallpaper
}

main