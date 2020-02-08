# show or not show output
VERBOSE=""

# Color
WHITE="$(tput setaf 7)"
WHITEB="$(tput bold ; tput setaf 7)"
BLUE="$(tput setaf 4)"
BLUEB="$(tput bold ; tput setaf 4)"
CYAN="$(tput setaf 6)"
CYANB="$(tput bold ; tput setaf 6)"
GREEN="$(tput setaf 2)"
GREENB="$(tput bold ; tput setaf 2)"
RED="$(tput setaf 1)"
REDB="$(tput bold; tput setaf 1)"
YELLOW="$(tput setaf 3)"
YELLOWB="$(tput bold ; tput setaf 3)"
BLINK="$(tput blink)"
NC="$(tput sgr0)"

# true / false
TRUE=0
FALSE=1

# return codes
SUCCESS=0
FAILURE=1

# chosen locale
LOCALE=''

# set locale
SET_LOCALE='1'

# list locales
LIST_LOCALE='2'

# chosen keymap
KEYMAP=''

# set keymap
SET_KEYMAP='1'

# list keymaps
LIST_KEYMAP='2'

# hostname
HOST_NAME=''

# avalable hard drive
HD_DEVS=''

# chosen hard drive device
HD_DEV=''

# boot fs type - default: ext4
BOOT_FS_TYPE='vfat -F32'

# check boot mode
BOOT_MODE=''

# label gtp mbr
PART_LABEL='gpt'

# root fs type - default: ext4
ROOT_FS_TYPE='ext4'

# chroot directory / blackarch linux installation
CHROOT='/mnt'

# normal system user
NORMAL_USER=''

# X (display + window managers ) setup - default: false
X_SETUP=$FALSE

# banner for installer most important things
banner()
{
  columns="$(tput cols)"
  str="--=={ OPPAI_<H4K3R>-(Arch)version v$VERSION }==--"

  printf "${BLUEB}%*s${NC}\n" "${COLUMNS:-$(tput cols)}" | tr ' ' '-'

  echo "$str" |
  while IFS= read -r line
  do
    printf "%s%*s\n%s" "$CYANB" $(( (${#line} + columns) / 2)) \
      "$line" "$NC"
  done

  printf "${BLUEB}%*s${NC}\n\n\n" "${COLUMNS:-$(tput cols)}" | tr ' ' '-'

  return $SUCCESS
}

# check exit status
check()
{
  es=$1
  func="$2"
  info="$3"

  if [ $es -ne 0 ]
  then
    echo
    warn "Something went wrong with $func. $info."
    sleep 5
  fi
}

# print formatted output
wprintf()
{
  fmt="${1}"

  shift
  printf "%s$fmt%s" "$WHITE" "$@" "$NC"

  return $SUCCESS
}

# print warning
warn()
{
  printf "%s[!] WARNING: %s%s\n" "$YELLOW" "$@" "$NC"

  return $SUCCESS
}

# print error and exit
err()
{
  printf "%s[-] ERROR: %s%s\n" "$RED" "$@" "$NC"

  exit $FAILURE

  return $SUCCESS
}

# sleep and clear
sleep_clear()
{
  sleep $1
  clear

  return $SUCCESS
}

# confirm user inputted yYnN
confirm()
{
  header="$1"
  ask="$2"

  while true
  do
    title "$header"
    wprintf "$ask"
    read input
    case $input in
      y|Y|yes|YES|Yes) return $TRUE ;;
      n|N|no|NO|No) return $FALSE ;;
      *) clear ; continue ;;
    esac
  done

  return $SUCCESS
}


# print menu title
title()
{
  banner
  printf "${CYAN}>> %s${NC}\n\n\n" "${@}"

  return "${SUCCESS}"
}

# check for environment issues
check_env()
{
  if [ -f '/var/lib/pacman/db.lck' ]
  then
    err 'pacman locked - Please remove /var/lib/pacman/db.lck'
  fi
}

# ask for output mode
ask_output_mode()
{
  title 'Environment > Output Mode'
  wprintf '[+] Available output modes:'
  printf "\n
  1. Quiet (default)
  2. Verbose (output of system commands: mkfs, pacman, etc.)\n\n"
  wprintf "[?] Make a choice: "
  read output_opt
  if [ "$output_opt" = 2 ]
  then
    VERBOSE='/dev/stdout'
  fi

  return $SUCCESS
}

# ask for locale to use
ask_locale()
{
  while [ \
    "$locale_opt" != "$SET_LOCALE" -a \
    "$locale_opt" != "$LIST_LOCALE" ]
  do
    title 'Environment > Locale Setup'
    wprintf '[+] Available locale options:'
    printf "\n
  1. Set a locale
  2. List available locales\n\n"
    wprintf "[?] Make a choice: "
    read locale_opt
    if [ "$locale_opt" = "$SET_LOCALE" ]
    then
      break
    elif [ "$locale_opt" = "$LIST_LOCALE" ]
    then
      less /etc/locale.gen
      echo
    else
      clear
      continue
    fi
    clear
  done

  clear

  return $SUCCESS
}

# check boot mode
check_boot_mode()
{
  if [ "$(efivar --list 2> /dev/null)" ]
  then
     BOOT_MODE="uefi"
  fi

  return $SUCCESS
}

# set locale to use
set_locale()
{
  title 'Environment > Locale Setup'
  wprintf '[?] Set locale [en_US.UTF-8]: '
  read LOCALE

  # default locale
  if [ -z "$LOCALE" ]
  then
    echo
    warn 'Setting default locale: en_US.UTF-8'
    sleep 1
    LOCALE='en_US.UTF-8'
  fi
  localectl set-locale "LANG=$LOCALE"
  check $? 'setting locale'

  return $SUCCESS
}

# ask for keymap to use
ask_keymap()
{
  while [ \
    "$keymap_opt" != "$SET_KEYMAP" -a \
    "$keymap_opt" != "$LIST_KEYMAP" ]
  do
    title 'Environment > Keymap Setup'
    wprintf '[+] Available keymap options:'
    printf "\n
  1. Set a keymap
  2. List available keymaps\n\n"
    wprintf '[?] Make a choice: '
    read keymap_opt

    if [ "$keymap_opt" = "$SET_KEYMAP" ]
    then
      break
    elif [ "$keymap_opt" = "$LIST_KEYMAP" ]
    then
      localectl list-x11-keymap-layouts
      echo
    else
      clear
      continue
    fi
    clear
  done

  clear

  return $SUCCESS
}

# set keymap to use
set_keymap()
{
  title 'Environment > Keymap Setup'
  wprintf '[?] Set keymap [us]: '
  read KEYMAP

  # default keymap
  if [ -z "$KEYMAP" ]
  then
    echo
    warn 'Setting default keymap: us'
    sleep 1
    KEYMAP='us'
  fi
  localectl set-keymap --no-convert "$KEYMAP"
  loadkeys "$KEYMAP" > $VERBOSE 2>&1
  check $? 'setting keymap'

  return $SUCCESS
}

# enable multilib in pacman.conf if x86_64 present
enable_pacman_multilib()
{
  path="$1"

  if [ "$path" = 'chroot' ]
  then
    path="$CHROOT"
  else
    path=""
  fi

  title 'Pacman Setup > Multilib'

  if [ "$(uname -m)" = "x86_64" ]
  then
    wprintf '[+] Enabling multilib support'
    printf "\n\n"
    if grep -q "#\[multilib\]" "$path/etc/pacman.conf"
    then
      # it exists but commented
      sed -i '/\[multilib\]/{ s/^#//; n; s/^#//; }' "$path/etc/pacman.conf"
    elif ! grep -q "\[multilib\]" "$path/etc/pacman.conf"
    then
      # it does not exist at all
      printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" \
        >> "$path/etc/pacman.conf"
    fi
  fi

  return $SUCCESS
}


# enable color mode in pacman.conf
enable_pacman_color()
{
  path="$1"

  if [ "$path" = 'chroot' ]
  then
    path="$CHROOT"
  else
    path=""
  fi

  title 'Pacman Setup > Color'

  wprintf '[+] Enabling color mode'
  printf "\n\n"

  sed -i 's/^#Color/Color/' "$path/etc/pacman.conf"

  return $SUCCESS
}


# update pacman package database
update_pkg_database()
{
  title 'Pacman Setup > Package Database'

  wprintf '[+] Updating pacman database'
  printf "\n\n"

  pacman -Syy --noconfirm > $VERBOSE 2>&1

  return $SUCCESS
}


# update pacman.conf and database
update_pacman()
{
  enable_pacman_multilib
  sleep_clear 1

  enable_pacman_color
  sleep_clear 1

  update_pkg_database
  sleep_clear 1

  return $SUCCESS
}

# ask user for hostname
ask_hostname()
{
  while [ -z "$HOST_NAME" ]
  do
    title 'Network Setup > Hostname'
    wprintf '[?] Set your hostname: '
    read HOST_NAME
  done

  return $SUCCESS
}

# check for internet connection
check_inet_conn()
{
  title 'Network Setup > Connection Check'
  wprintf '[+] Checking for Internet connection...'

  if ! curl -s http://www.yahoo.com/ > $VERBOSE 2>&1
  then
    err 'No Internet connection! Check your network (settings).'
  fi

  return $SUCCESS
}

# get available hard disks
get_hd_devs()
{
  HD_DEVS="$(lsblk | grep disk | awk '{print $1}')"

  return $SUCCESS
}

# ask user for device to format and setup
ask_hd_dev()
{
  while true
  do
    title 'Hard Drive Setup'

    wprintf '[+] Available hard drives for installation:'
    printf "\n\n"

    for i in $HD_DEVS
    do
      echo "    > ${i}"
    done
    echo
    wprintf '[?] Please choose a device: '
    read HD_DEV
    if echo $HD_DEVS | grep "\<$HD_DEV\>" > /dev/null
    then
      HD_DEV="/dev/$HD_DEV"
      clear
      break
    fi
    clear
  done


  return $SUCCESS
}

# zero out partition if needed/chosen
zero_part()
{
  if confirm 'Hard Drive Setup' '[?] Start with an in-memory zeroed partition table [y/n]: '
  then
    cfdisk -z "$HD_DEV"
    sync
  else
    cfdisk "$HD_DEV"
    sync
  fi

  return $SUCCESS
}


# ask user to create partitions using cfdisk
ask_cfdisk()
{
  if confirm 'Hard Drive Setup > Partitions' '[?] Create partitions with cfdisk (root and boot, optional swap) [y/n]: '
  then
    clear
    zero_part
  else
    echo
    warn 'No partitions chosed? Make sure you have them already configured.'
  fi

  return $SUCCESS
}

# get partitions
ask_partitions()
{
  partitions=$(ls ${HD_DEV}* | grep -v "${HD_DEV}\>")

  while [ \
    "$BOOT_PART" = '' -o \
    "$ROOT_PART" = '' -o \
    "$BOOT_FS_TYPE" = '' -o \
    "$ROOT_FS_TYPE" = '' ]
  do
    title 'Hard Drive Setup > Partitions'
    wprintf '[+] Created partitions:'
    printf "\n\n"

    for i in $partitions
    do
      echo "    > $i"
    done
    echo

    if [ "$BOOT_MODE" = 'uefi' ] 
    then
      wprintf '[?] EFI System partition (/dev/sdXY): '
      read BOOT_PART
      BOOT_FS_TYPE="fat32"
    else
      wprintf '[?] Boot partition (/dev/sdXY): '
      read BOOT_PART
      wprintf '[?] Boot FS type (ext2, ext3, ext4): '
      read BOOT_FS_TYPE
    fi
    wprintf '[?] Root partition (/dev/sdXY): '
    read ROOT_PART
    wprintf '[?] Root FS type (ext2, ext3, ext4, btrfs): '
    read ROOT_FS_TYPE
    wprintf '[?] Swap parition (/dev/sdXY - empty for none): '
    read SWAP_PART

    if [ "$SWAP_PART" = '' ]
    then
      SWAP_PART='none'
    fi
    clear
  done

  return $SUCCESS
}

# print partitions and ask for confirmation
print_partitions()
{
  i=""

  while true
  do
    title 'Hard Drive Setup > Partitions'
    wprintf '[+] Current Partition table'
    printf "\n
  > /boot   : $BOOT_PART ($BOOT_FS_TYPE)
  > /       : $ROOT_PART ($ROOT_FS_TYPE)
  > swap    : $SWAP_PART (swap)
  \n"
    wprintf '[?] Partition table correct [y/n]: '
    read i
    if [ "$i" = 'y' -o "$i" = 'Y' ]
    then
      clear
      break
    elif [ "$i" = 'n' -o "$i" = 'N' ]
    then
      echo
      err 'Hard Drive Setup aborted.'
    else
      clear
      continue
    fi
    clear
  done

  return $SUCCESS
}

# ask user and get confirmation for formatting
ask_formatting()
{
  if confirm 'Hard Drive Setup > Partition Formatting' '[?] Formatting partitions. Are you sure? No crying afterwards? [y/n]: '
  then
    return $SUCCESS
  else
    echo
    err 'Seriously? No formatting no fun!'
  fi

  return $SUCCESS
}

# create swap partition
make_swap_partition()
{
  title 'Hard Drive Setup > Partition Creation (swap)'

  wprintf '[+] Creating SWAP partition'
  printf "\n\n"
  mkswap $SWAP_PART > $VERBOSE 2>&1 || err 'Could not create filesystem'

  return $SUCCESS
}

make_root_partition()
{
    title 'Hard Drive Setup > Partition Creation (root)'
    wprintf '[+] Creating ROOT partition'
    printf "\n\n"
    if [ "$ROOT_FS_TYPE" = 'ext4' ]
    then
      mkfs.$ROOT_FS_TYPE $ROOT_PART > $VERBOSE 2>&1 ||
        err 'Could not create filesystem'
    fi
    sleep_clear 1

  return $SUCCESS
}

make_boot_partition()
{
    
  title 'Hard Drive Setup > Partition Creation (boot)'

  wprintf '[+] Creating BOOT partition'
  printf "\n\n"
  if [ "$BOOT_MODE" = 'uefi' ] && [ "$PART_LABEL" = 'gpt' ]
  then
    mkfs.fat -F32 $BOOT_PART > $VERBOSE 2>&1 ||
      err 'Could not create filesystem'
  else
    mkfs.$BOOT_FS_TYPE -F $BOOT_PART > $VERBOSE 2>&1 ||
      err 'Could not create filesystem'
  fi

  return $SUCCESS
}


# make and format partitions
make_partitions()
{
  make_boot_partition
  sleep_clear 1

  make_root_partition
  sleep_clear 1

  if [ "$SWAP_PART" != "none" ]
  then
    make_swap_partition
    sleep_clear 1
  fi

  return $SUCCESS
}


# mount filesystems
mount_filesystems()
{
  title 'Hard Drive Setup > Mount'

  wprintf '[+] Mounting filesystems'
  printf "\n\n"

  # ROOT
  mount $ROOT_PART $CHROOT > $VERBOSE 2>&1
  
  # BOOT
  mkdir "$CHROOT/boot" > $VERBOSE 2>&1
  mount $BOOT_PART "$CHROOT/boot" > $VERBOSE 2>&1

  # SWAP
  if [ "$SWAP_PART" != "none" ]
  then
    swapon $SWAP_PART > $VERBOSE 2>&1
  fi

  return $SUCCESS
}


# unmount filesystems
umount_filesystems()
{
  routine="$1"

  if [ "$routine" = 'harddrive' ]
  then
    title 'Hard Drive Setup > Unmount'

    wprintf '[+] Unmounting filesystems'
    printf "\n\n"

    umount -Rf "$HD_DEV"{1..128} > /dev/null 2>&1 # gpt max - 128
  else
    title 'Game Over'

    wprintf '[+] Unmounting filesystems'
    printf "\n\n"

    umount -Rf $CHROOT > /dev/null 2>&1
    cryptsetup luksClose "$CRYPT_ROOT" > /dev/null 2>&1
    swapoff $SWAP_PART > /dev/null 2>&1
  fi

  return $SUCCESS
}

# install ArchLinux base and base-devel packages
install_base_packages()
{
  title 'Base System Setup > ArchLinux Packages'

  wprintf '[+] Installing ArchLinux base packages'
  printf "\n\n"
  warn 'This can take a while, please wait...'
  printf "\n"

  pacstrap $CHROOT base base-devel linux linux-firmware terminus-font > $VERBOSE 2>&1
  chroot $CHROOT pacman -Syy --noconfirm --overwrite='*' > $VERBOSE 2>&1

  return $SUCCESS
}

# setup /etc/resolv.conf
setup_resolvconf()
{
  title 'Base System Setup > Etc'

  wprintf '[+] Setting up /etc/resolv.conf'
  printf "\n\n"

  mkdir -p "$CHROOT/etc/" > $VERBOSE 2>&1
  cp -L /etc/resolv.conf "$CHROOT/etc/resolv.conf" > $VERBOSE 2>&1

  return $SUCCESS
}


# setup fstab
setup_fstab()
{
  title 'Base System Setup > Etc'

  wprintf '[+] Setting up /etc/fstab'
  printf "\n\n"

  if [ "$PART_LABEL" = "gpt" ]
  then
    genfstab -U $CHROOT >> "$CHROOT/etc/fstab"
  fi

  sed 's/relatime/noatime/g' -i "$CHROOT/etc/fstab"

  return $SUCCESS
}

# setup locale and keymap
setup_locale()
{
  title 'Base System Setup > Locale'

  wprintf "[+] Setting up $LOCALE locale"
  printf "\n\n"
  sed -i "s/^#en_US.UTF-8/en_US.UTF-8/" "$CHROOT/etc/locale.gen"
  sed -i "s/^#$LOCALE/$LOCALE/" "$CHROOT/etc/locale.gen"
  chroot $CHROOT locale-gen > $VERBOSE 2>&1
  echo "LANG=$LOCALE" > "$CHROOT/etc/locale.conf"
  echo "KEYMAP=$KEYMAP" > "$CHROOT/etc/vconsole.conf"

  return $SUCCESS
}

# setup timezone
setup_time()
{
  if confirm 'Base System Setup > Timezone' '[?] Default: UTC. Choose other timezone [y/n]: '
  then
    for t in $(timedatectl list-timezones)
    do
      echo "    > $(echo $t)"
    done

    wprintf "\n[?] What is your (Zone/SubZone): "
    read timezone
    chroot $CHROOT ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime \
      > $VERBOSE 2>&1

    if [ $? -eq 1 ]
    then
      warn 'Do you live on Mars? Setting default time zone...'
      sleep 1
      default_time
    else
      wprintf "\n[+] Time zone setup correctly\n"
    fi
  else
    wprintf "\n[+] Setting up default time and timezone\n"
    sleep 2
    default_time
  fi

  printf "\n"

  return $SUCCESS
}


# default time and timezone
default_time()
{
  echo
  warn 'Setting up default time and timezone: UTC'
  printf "\n\n"
  chroot $CHROOT ln -sf /usr/share/zoneinfo/UTC /etc/localtime > $VERBOSE 2>&1

  return $SUCCESS
}

# setup initramfs
setup_initramfs()
{
  title 'Base System Setup > InitramFS'

  wprintf '[+] Setting up InitramFS'
  printf "\n\n"

  # terminus font
  sed -i 's/keyboard fsck/keyboard fsck consolefont/g' \
    "$CHROOT/etc/mkinitcpio.conf"
  echo 'FONT=ter-114n' >> "$CHROOT/etc/vconsole.conf"

  warn 'This can take a while, please wait...'
  printf "\n"
  chroot $CHROOT mkinitcpio -p linux > $VERBOSE 2>&1

  return $SUCCESS
}

# setup hostname
setup_hostname()
{
  title 'Base System Setup > Hostname'

  wprintf '[+] Setting up hostname'
  printf "\n\n"

  echo $HOST_NAME > "$CHROOT/etc/hostname"

  return $SUCCESS
}

setup_bootloader()
{
  title 'Base System Setup > Boot Loader'
  if [ "$BOOT_MODE" = 'uefi' ] && [ "$PART_LABEL" = 'gpt' ]
  then
  wprintf '[+] Setting up GRUB boot loader'
    printf "\n\n"
    chroot $CHROOT pacman -S grub --noconfirm --overwrite='*' --needed > $VERBOSE 2>&1
    mkdir -p "$CHROOT/boot/grub"
    chroot $CHROOT grub-mkconfig -o /boot/grub/grub.cfg > $VERBOSE 2>&1
    chroot $CHROOT grub-install --target=x86_64-efi --efi-directory=$BOOT_PART --recheck > $VERBOSE 2>&1
  fi

  return $SUCCESS
}

# ask for normal user account to setup
ask_user_account()
{
  if confirm 'Base System Setup > User' '[?] Setup a normal user account [y/n]: '
  then
    wprintf '[?] User name: '
    read NORMAL_USER
  fi

  return $SUCCESS
}

title 'Base System Setup > User'

  wprintf "[+] Setting up $user account"
  printf "\n\n"

  # normal user
  if [ ! -z $NORMAL_USER ]
  then
    chroot $CHROOT groupadd $user > $VERBOSE 2>&1
    chroot $CHROOT useradd -g $user -d "/home/$user" -s "/bin/zsh" \
      -G "$user,wheel,users,video,audio" -m $user > $VERBOSE 2>&1
    chroot $CHROOT chown -R $user:$user "/home/$user" > $VERBOSE 2>&1
    wprintf "[+] Added user: $user"
    printf "\n\n"
  fi

  # password
  res=1337
  wprintf "[?] Set password for $user: "
  printf "\n\n"
  while [ $res -ne 0 ]
  do
    if [ "$user" = "root" ]
    then
      chroot $CHROOT passwd
    else
      chroot $CHROOT passwd $user
    fi
    res=$?
  done

  return $SUCCESS
}

reinitialize_keyring()
{
  title 'Base System Setup > Keyring Reinitialization'

  wprintf '[+] Reinitializing keyrings'
  printf "\n"
  sleep 2

  chroot $CHROOT pacman -S --overwrite='*' --noconfirm archlinux-keyring > $VERBOSE 2>&1

  return $SUCCESS
}

# install extra (missing) packages
setup_extra_packages()
{
  arch='arch-install-scripts pkgfile'

  bluetooth='bluez bluez-hid2hci bluez-tools bluez-utils'

  browser='chromium elinks firefox'

  editor='hexedit vim'

  filesystem='btrfs-progs cifs-utils dmraid dosfstools exfat-utils f2fs-tools
  gpart gptfdisk mtools nilfs-utils ntfs-3g partclone parted partimage'

  fonts='ttf-dejavu ttf-indic-otf ttf-liberation xorg-fonts-alias
  xorg-fonts-misc'

  hardware='amd-ucode intel-ucode'

  kernel='linux-headers'

  misc='acpi alsa-utils b43-fwcutter bash-completion bc cmake ctags expac
  feh git gpm haveged hdparm htop inotify-tools ipython irssi
  linux-atm lsof mercurial mesa mlocate moreutils mpv p7zip rsync
  rtorrent screen scrot smartmontools strace tmux udisks2 unace unrar
  unzip upower usb_modeswitch zip zsh'

  network='atftp bind-tools bridge-utils curl darkhttpd dhclient dialog
  dnscrypt-proxy dnsmasq dnsutils fwbuilder gnu-netcat ipw2100-fw ipw2200-fw iw
  lftp nfs-utils ntp openconnect openssh openvpn ppp pptpclient rfkill rp-pppoe
  socat vpnc wget wicd wicd-gtk wireless_tools wpa_supplicant wvdial xl2tpd'

  xorg='rxvt-unicode terminus-font xf86-video-amdgpu xf86-video-ati
  xf86-video-dummy xf86-video-fbdev xf86-video-intel xf86-video-nouveau
  xf86-video-openchrome xf86-video-sisusb xf86-video-vesa xf86-video-vmware
  xf86-video-voodoo xorg-server xorg-xbacklight xorg-xinit xterm'

  all="$arch $bluetooth $browser $editor $filesystem $fonts $hardware $kernel"
  all="$all $misc $network $xorg"

  title 'Base System Setup > Extra Packages'

  wprintf '[+] Installing extra packages'
  printf "\n"

  printf "
  > ArchLinux   : $(echo $arch | wc -w) packages
  > Browser     : $(echo $browser | wc -w) packages
  > Bluetooth   : $(echo $bluetooth | wc -w) packages
  > Editor      : $(echo $editor | wc -w) packages
  > Filesystem  : $(echo $filesystem | wc -w) packages
  > Fonts       : $(echo $fonts | wc -w) packages
  > Hardware    : $(echo $hardware | wc -w) packages
  > Kernel      : $(echo $kernel | wc -w) packages
  > Misc        : $(echo $misc | wc -w) packages
  > Network     : $(echo $network | wc -w) packages
  > Xorg        : $(echo $xorg | wc -w) packages
  \n"

  warn 'This can take a while, please wait...'
  printf "\n"
  sleep 2

  chroot $CHROOT pacman -S --needed --overwrite='*' --noconfirm $(echo $all) \
    > $VERBOSE 2>&1

  return $SUCCESS
}

# perform system base setup/configurations
setup_base_system()
{
  if [ "$INSTALL_MODE" != "$INSTALL_LIVE_ISO" ]
  then
    pass_mirror_conf # copy mirror list to chroot env

    setup_resolvconf
    sleep_clear 1

    install_base_packages
    sleep_clear 1

    setup_resolvconf
    sleep_clear 1
  fi

  setup_fstab
  sleep_clear 1

  setup_proc_sys_dev
  sleep_clear 1

  setup_locale
  sleep_clear 1

  setup_initramfs
  sleep_clear 1

  setup_hostname
  sleep_clear 1

  setup_user "root"
  sleep_clear 1

  ask_user_account
  sleep_clear 1

  if [ ! -z "$NORMAL_USER" ]
  then
    setup_user "$NORMAL_USER"
    sleep_clear 1
  else
    setup_testuser
    sleep_clear 2
  fi

  if [ "$INSTALL_MODE" != "$INSTALL_LIVE_ISO" ]
  then
    reinitialize_keyring
    sleep_clear 1
    setup_extra_packages
    sleep_clear 1
  fi

  setup_bootloader
  sleep_clear 1

  return $SUCCESS
}

#  ask user for X (display + window manager) setup
ask_x_setup()
{
  if confirm 'BlackArch Linux Setup > X11' '[?] Setup X11 + window managers [y/n]: '
  then
    X_SETUP=$TRUE
    printf "\n"
    printf "${BLINK}NOOB! NOOB! NOOB! NOOB! NOOB! NOOB! NOOB!${NC}\n\n"
  fi

  return $SUCCESS
}

# ask for blackarch linux mirror
ask_mirror()
{
  title 'BlackArch Linux Setup > BlackArch Mirror'

  local IFS='|'
  count=1
  mirror_url='https://raw.githubusercontent.com/BlackArch/blackarch/master/mirror/mirror.lst'
  mirror_file='/tmp/mirror.lst'

  wprintf '[+] Fetching mirror list'
  printf "\n\n"
  curl -s -o $mirror_file $mirror_url > $VERBOSE 2>&1

  while read -r country url mirror_name
  do
    wprintf " %s. %s - %s" "$count" "$country" "$mirror_name"
    printf "\n"
    wprintf "   * %s" "$url"
    printf "\n"
    count=$(expr $count + 1)
  done < "$mirror_file"

  printf "\n"
  wprintf '[?] Select a mirror number (enter for default): '
  read a
  printf "\n"

  # bugfix: detected chars added sometimes - clear chars
  _a=$(printf "%s" $a | sed 's/[a-z]//Ig' 2> /dev/null)

  if [ -z "$_a" ]
  then
    wprintf "[+] Choosing default mirror: %s " $BA_REPO_URL
  else
    BA_REPO_URL=$(sed -n "${_a}p" $mirror_file | cut -d "|" -f 2)
    wprintf "[+] Mirror from '%s' selected" \
      $(sed -n "${_a}p" $mirror_file | cut -d "|" -f 3)
    printf "\n\n"
  fi

  rm -f $mirror_file

  return $SUCCESS
}

# ask for archlinux server
ask_mirror_arch()
{
  declare mirrold='cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup'

  if confirm 'Pacman Setup > ArchLinux Mirrorlist' \
    "[+] Worldwide mirror will be used\n\n[?] Look for the best server [y/n]: "
  then
    printf "\n"
    warn 'This may take time depending on your connection'
    printf "\n"
    $mirrold
    pacman -Sy --noconfirm > $VERBOSE 2>&1
    pacman -S --needed --noconfirm reflector > $VERBOSE 2>&1
    yes | pacman -Scc > $VERBOSE 2>&1
    reflector --verbose --latest 10 --protocol https --sort rate \
      --save /etc/pacman.d/mirrorlist > $VERBOSE 2>&1
  else
    printf "\n"
    warn 'Using Worldwide mirror server'
    $mirrold
    echo -e "## Arch Linux repository Worldwide mirrorlist\n\n" \
      > /etc/pacman.d/mirrorlist

    for wore in $AR_REPO_URL
    do
      echo "Server = $wore" >> /etc/pacman.d/mirrorlist
    done
  fi

}

# pass correct config
pass_mirror_conf()
{
  mkdir -p "$CHROOT/etc/pacman.d/" > $VERBOSE 2>&1
  cp -f /etc/pacman.d/mirrorlist "$CHROOT/etc/pacman.d/mirrorlist" \
    > $VERBOSE 2>&1
}

# enable iptables services
enable_iptables()
{
  title 'BlackArch Linux Setup > Iptables'

  wprintf '[+] Enabling iptables and ip6tables'
  printf "\n\n"

  chroot $CHROOT systemctl enable iptables > $VERBOSE 2>&1
  chroot $CHROOT systemctl enable ip6tables > $VERBOSE 2>&1

  return $SUCCESS
}

# setup display manager
setup_display_manager()
{
  title 'BlackArch Linux Setup > Display Manager'

  wprintf '[+] Setting up LXDM'
  printf "\n"

  # install lxdm packages
  chroot $CHROOT pacman -S lxdm --needed --overwrite='*' --noconfirm \
    > $VERBOSE 2>&1
  # enable in systemd
  chroot $CHROOT systemctl enable lxdm > $VERBOSE 2>&1

  return $SUCCESS
}



# setup window managers
setup_window_managers()
{
  title 'BlackArch Linux Setup > Window Managers'

  wprintf '[+] Setting up window managers'
  printf "\n"

  while true
  do
    printf "
  1. Awesome
  2. Fluxbox
  3. I3-wm
  4. Openbox
  5. Spectrwm
  6. All of the above
  \n"
    wprintf '[?] Choose an option [6]: '
    read choice
    echo
    case $choice in
      1)
        chroot $CHROOT pacman -S awesome --needed --overwrite='*' --noconfirm \
          > $VERBOSE 2>&1
        cp -r "$BI_PATH/data/etc/xdg/awesome/." "$CHROOT/etc/xdg/awesome/."
        cp -r "$BI_PATH/data/usr/share/awesome/." "$CHROOT/usr/share/awesome/."
        # fix bullshit exit() issue
        sed -i 's|local visible, action = cmd(item, self)|local visible, action = cmd(0, 0)|' \
          "$CHROOT/usr/share/awesome/lib/awful/menu.lua"
        cp -r "$BI_PATH/data/usr/share/xsessions/awesome.desktop" "$CHROOT/usr/share/xsessions"
        break
        ;;
      2)
        chroot $CHROOT pacman -S fluxbox --needed --overwrite='*' --noconfirm \
          > $VERBOSE 2>&1
        cp -r "$BI_PATH/data/usr/share/fluxbox/." "$CHROOT/usr/share/fluxbox/."
        cp -r "$BI_PATH/data/usr/share/xsessions/fluxbox.desktop" "$CHROOT/usr/share/xsessions"
        break
        ;;
      3)
        chroot $CHROOT pacman -S i3 dmenu --needed --overwrite='*' --noconfirm \
          > $VERBOSE 2>&1
        cp -r "$BI_PATH/data/root/"{.config,.i3status.conf} "$CHROOT/root/."
        cp -r "$BI_PATH/data/usr/share/xsessions/i3.desktop" "$CHROOT/usr/share/xsessions"
        break
        ;;
      4)
        chroot $CHROOT pacman -S openbox --needed --overwrite='*' --noconfirm \
          > $VERBOSE 2>&1
        cp -r "$BI_PATH/data/etc/xdg/openbox/." "$CHROOT/etc/xdg/openbox/."
        cp -r "$BI_PATH/data/usr/share/themes/blackarch" \
          "$CHROOT/usr/share/themes/i3lock/."
        cp -r "$BI_PATH/data/usr/share/xsessions/openbox.desktop" "$CHROOT/usr/share/xsessions"
        break
        ;;
      5)
        chroot $CHROOT pacman -S spectrwm --needed --overwrite='*' --noconfirm \
          > $VERBOSE 2>&1
        cp -r "$BI_PATH/data/etc/spectrwm.conf" "$CHROOT/etc/spectrwm.conf"
        cp -r "$BI_PATH/data/usr/share/xsessions/spectrwm.desktop" "$CHROOT/usr/share/xsessions"
        break
        ;;
      *)
        chroot $CHROOT pacman -S fluxbox openbox awesome i3 spectrwm --needed \
          --overwrite='*' --noconfirm > $VERBOSE 2>&1

        # awesome
        cp -r "$BI_PATH/data/etc/xdg/awesome/." "$CHROOT/etc/xdg/awesome/."
        cp -r "$BI_PATH/data/usr/share/awesome/." "$CHROOT/usr/share/awesome/."
        sed -i 's|local visible, action = cmd(item, self)|local visible, action = cmd(0, 0)|' \
          "$CHROOT/usr/share/awesome/lib/awful/menu.lua"

        # fluxbox
        cp -r "$BI_PATH/data/usr/share/fluxbox/." "$CHROOT/usr/share/fluxbox/."

        # i3
        cp -r "$BI_PATH/data/root/"{.config,.i3status.conf} "$CHROOT/root/."

        # openbox
        cp -r "$BI_PATH/data/etc/xdg/openbox/." "$CHROOT/etc/xdg/openbox/."
        cp -r "$BI_PATH/data/usr/share/themes/blackarch" \
          "$CHROOT/usr/share/themes/."

        # spectrwm
        cp -r "$BI_PATH/data/etc/spectrwm.conf" "$CHROOT/etc/spectrwm.conf"

        # xsessions
        cp -r "$BI_PATH/data/usr/share/xsessions" "$CHROOT/usr/share/xsessions"

        break
        ;;
    esac
  done

  # wallpaper
  cp -r "$BI_PATH/data/usr/share/blackarch" "$CHROOT/usr/share/blackarch"

  # remove wrong xsession entries
  chroot $CHROOT rm /usr/share/xsessions/openbox-kde.desktop > $VERBOSE 2>&1
  chroot $CHROOT rm /usr/share/xsessions/i3-with-shmlog.desktop > $VERBOSE 2>&1

  return $SUCCESS
}

# add user to newly created groups
update_user_groups()
{
  title 'BlackArch Linux Setup > User'

  wprintf "[+] Adding user $user to groups and sudoers"
  printf "\n\n"

  # TODO: more to add here
  if [ $VBOX_SETUP -eq $TRUE ]
  then
    chroot $CHROOT usermod -aG 'vboxsf,audio,video' "$user" > $VERBOSE 2>&1
  fi

  # sudoers
  echo "$user ALL=(ALL) ALL" >> $CHROOT/etc/sudoers > $VERBOSE 2>&1

  return $SUCCESS
}


# setup blackarch related stuff
setup_blackarch()
{
  update_etc
  sleep_clear 1

  enable_wicd
  sleep_clear 1

  enable_iptables
  sleep_clear 1

  ask_mirror
  sleep_clear 1

  run_strap_sh
  sleep_clear 1

  ask_x_setup
  sleep_clear 3

  if [ $X_SETUP -eq $TRUE ]
  then
    setup_display_manager
    sleep_clear 1
    setup_window_managers
    sleep_clear 1
  fi

  ask_vbox_setup
  sleep_clear 1

  if [ $VBOX_SETUP -eq $TRUE ]
  then
    setup_vbox_utils
    sleep_clear 1
  fi

  ask_vmware_setup
  sleep_clear 1

  if [ $VMWARE_SETUP -eq $TRUE ]
  then
    setup_vmware_utils
    sleep_clear 1
  fi

  sleep_clear 1

  enable_pacman_multilib 'chroot'
  sleep_clear 1

  enable_pacman_color 'chroot'
  sleep_clear 1

  ask_ba_tools_setup
  sleep_clear 1

  if [ $BA_TOOLS_SETUP -eq $TRUE ]
  then
    setup_blackarch_tools
    sleep_clear 1
  fi

  if [ -n "$NORMAL_USER" ]
  then
    update_user_groups
    sleep_clear 1
  fi

  return $SUCCESS
}


# for fun and lulz
easter_backdoor()
{
  foo=0

  title 'Game Over'

  wprintf '[+] BlackArch Linux installation successfull!'
  printf "\n\n"

  wprintf 'Yo n00b, b4ckd00r1ng y0ur sy5t3m n0w '
  while [ $foo -ne 5 ]
  do
    wprintf "."
    sleep 1
    foo=$(expr $foo + 1)
  done
  printf " >> ${BLINK}${WHITE}HACK THE PLANET! D00R THE PLANET!${NC} <<"
  printf "\n\n"

  return $SUCCESS
}


# perform sync
sync_disk()
{
  title 'Game Over'

  wprintf '[+] Syncing disk'
  printf "\n\n"

  sync

  return $SUCCESS
}


# controller and program flow
main()
{
  # do some ENV checks
  sleep_clear 0
  check_uid
  check_env
  check_inet_conn
  sleep_clear 1
  check_boot_mode
  check_iso_type

  # install mode
  ask_install_mode

  # output mode
  ask_output_mode
  sleep_clear 0

  # locale
  ask_locale
  set_locale
  sleep_clear 0

  # keymap
  ask_keymap
  set_keymap
  sleep_clear 0

  # network
  ask_hostname
  sleep_clear 0

  # pacman
  ask_mirror_arch
  sleep_clear 1
  update_pacman

  # hard drive
  get_hd_devs
  ask_hd_dev
  sleep_clear 1
  umount_filesystems 'harddrive'
  sleep_clear 1
  ask_cfdisk
  sleep_clear 3
  ask_partitions
  print_partitions
  ask_formatting
  clear
  make_partitions
  clear
  mount_filesystems
  sleep_clear 1

  # arch linux
  setup_base_system
  sleep_clear 1
  setup_time
  sleep_clear 1

  # epilog
  umount_filesystems
  sleep_clear 1
  sync_disk
  sleep_clear 1
  easter_backdoor

  return $SUCCESS
}


# we start here
main "$@"
