#!/bin/bash

function echoinfo() {
    echo "[ INFO ] " "$@"
}

function echok() {
    echo "[ OK ] " "$@"
}

function errxit() {
    errcho "$@"
    exit 1
}

function errcho() {
     echo "[ FAIL ] " "$@"
}

function failOnError() {
    local statusCode=${1}
    local errMessage=${2}
    if [ "${statusCode}" -ne 0 ];then
      errxit "${errMessage}"
    fi
}

echoinfo "starting setup script"


echoinfo "installing ansible"
sudo apt update
failOnError ${?} "failed to update apt"
sudo apt install -y ansible
failOnError ${?} "failed to install ansible"

echok "done"

echoinfo "running ansible playbook.yml"
ansible-playbook playbook.yml

echok "script finished"
