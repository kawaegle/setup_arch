#!/bin/bash

user_manager(){
    sudo groupadd dialout
    sudo usermod -aG dialout $USER
    sudo usermod -aG input $USER
    sudo usermod -aG uucp $USER
    sudo usermod -aG wheel $USER
    sudo usermod -aG tty $USER
    user usermod -aG libvirt $USER
}
