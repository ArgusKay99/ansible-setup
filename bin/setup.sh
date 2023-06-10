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

function ensurePackageIsInstalled() {
    # source: https://stackoverflow.com/questions/1298066/how-can-i-check-if-a-package-is-installed-and-install-it-if-not
    local requiredPackage="${1}"
    local isPackageInstalled
    isPackageInstalled=$(dpkg-query -W --showformat='${Status}\n' "${requiredPackage}"|grep "install ok installed")
    echoinfo "Checking for ${requiredPackage}: ${isPackageInstalled}"
    if [ "" = "${isPackageInstalled}" ]; then
      echoinfo "No ${requiredPackage}. Setting up ${requiredPackage}."
      sudo apt update
      failOnError ${?} "failed to update packages"
      sudo apt --yes install "${requiredPackage}"
      failOnError ${?} "failed to install ansible"
      echok "installed ansible successfully"
    fi
}

function installPlaybook() {
    local infoMessage
    infoMessage="${1}"

    local pathToPlaybook
    pathToPlaybook="${2}"

    echoinfo "${infoMessage}"
    ansible-playbook "${pathToPlaybook}"
    failOnError ${?} "failed to install playbook: ${pathToPlaybook}"
}

localDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
repositoryRoot="${localDir}/.."

echoinfo "starting setup script"

ensurePackageIsInstalled ansible

# ansible plugins
echoinfo "installing ansible plugins"

ansible-galaxy install igor_mukhin.bash_aliases
failOnError ${?} "failed to install ansible addon: igor_mukhin.bash_aliases"

echok "all ansible plugins installed"


# running playbooks
echoinfo "running ansible playbooks"

installPlaybook "install core packages" "${repositoryRoot}/playbook.yml"
installPlaybook "create user" "${repositoryRoot}/playbooks/createUser/createUser.yml"


echok "everything installed. Happy Hacking :)"
