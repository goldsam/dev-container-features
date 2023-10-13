#!/usr/bin/env bash

set -e

SAM_CLI_VERSION="${VERSION:-"latest"}"

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

export DEBIAN_FRONTEND=noninteractive

echo "Activating feature 'aws-sam-cli'"

architecture="$(uname -m)"
if [ $architecture != "x86_64" ]; then
    echo "(!) Architecture $architecture unsupported"; 
    exit 1;
fi

# Install curl, apt-transport-https, curl, gpg, or dirmngr, git if missing
check_packages curl ca-certificates apt-transport-https dirmngr gnupg2
if ! type git > /dev/null 2>&1; then
    check_packages git
fi

find_version_from_git_tags SAM_CLI_VERSION https://github.com/aws/aws-sam-cli

# Install AWS SAM CLI
umask 0002

if [ "${SAM_CLI_VERSION}" = "none" ] || type sam > /dev/null 2>&1; then
    echo "AWS SAM CLI already installed. Skipping..."
else
    mkdir -p /tmp/sam
    
    pushd /tmp/sam

    echo "Downloading AWS SAM CLI ${SAM_CLI_VERSION}..."
    ARCHIVE_FILE="aws-sam-cli-linux-${architecture}.zip"
    curl -fsSL -o "${ARCHIVE_FILE}" "https://github.com/aws/aws-sam-cli/releases/download/v${SAM_CLI_VERSION}/{$ARCHIVE_FILE}"
    
    echo "Extracting AWS SAM CLI ${CUE_VERSION}..."
    unzip "${ARCHIVE_FILE}" 
    
    echo "Installing AWS SAM CLI...'"
    ./install
    
    popd

    rm -rf /tmp/sam
fi

set +e

echo "Done!"
