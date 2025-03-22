#!/bin/bash

fstab(){
    cat "/etc/fstab" | grep "/tmp"
    if [[ $? -eq 0 ]]; then
        return
    fi
    printf "# /TMP\ntmpfs\t/tmp\t\ttmpfs\t\trw,nodev,nosuid,size=10G\t\t0\t0\ntmpfs\t/home/$USER/Documents/tmp\t\ttmpfs\t\trw,nodev,nosuid,size=10G\t\t0\t0" | sudo tee -a /etc/fstab
}
