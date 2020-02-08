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

APT()
{
    sudo mv /etc/apt/sources.*  /etc/apt/sources.oppai/
    sudo cp -r /Deb/apt.sources.list/ /etc/apt/sources.list.d/
    printf "move /etc/apt/sources.list in /etc/apt/sources.oppai"
}

Update()
{
    sudo apt update
    sudo apt full-upgrade
    sudo apt install $(cat Deb/apt.install)
    sudo apt remove --purge $(cat Deb/apt.linux)
    sudo apt remove --purge $(cat Deb/apt.remove)
    printf "install and clean all package from official debian server"
}

sleep_clear()
{
  sleep $1
  clear

  return $SUCCESS
}s

# update script test
# cp start.sh /tmp
# git clone https://github.com/kawaegle/config /tmp
# cat /tmp/start.sh | grep VERSION = configv
# cat /tmp/Config/start.sh | grep  VERSION == $configv
# if != printf "there is another script. please Download me and re run me !!"


Deb_start()
{
    config
    APT
    Update
}


########### START ############
printf "Chose your distro:\n   [1]Arch linux (or based)\n   [2]debian (or based)\n"

read Distro

if [ $Distro='1' ]
then
    ./Arch_start.sh
else
    Deb_start
fi
