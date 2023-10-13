#!/usr/bin/env bash

set -e

CUE_VERSION="${VERSION:-"latest"}"
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

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

# Get central common setting
get_common_setting() {
    if [ "${common_settings_file_loaded}" != "true" ]; then
        curl -sfL "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        common_settings_file_loaded=true
    fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        local multi_line=""
        if [ "$2" = "true" ]; then multi_line="-z"; fi
        local result="$(grep ${multi_line} -oP "$1=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"
        if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
    fi
    echo "$1=${!1}"
}

export DEBIAN_FRONTEND=noninteractive

echo "Activating feature 'cue-lang'"

architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

# Install curl, apt-transport-https, curl, gpg, or dirmngr, git if missing
check_packages curl ca-certificates apt-transport-https dirmngr gnupg2
if ! type git > /dev/null 2>&1; then
    check_packages git
fi

find_version_from_git_tags CUE_VERSION https://github.com/cue-lang/cue

# Install CUE
umask 0002

if [ "${CUE_VERSION}" = "none" ] || type cue > /dev/null 2>&1; then
    echo "CUE already installed. Skipping..."
else
    mkdir -p /tmp/cue
    
    pushd /tmp/cue

    echo "Downloading CUE ${CUE_VERSION}..."

    ARCHIVE_FILE="cue_v${CUE_VERSION}_linux_${architecture}.tar.gz"
    curl -fsSL -o "${ARCHIVE_FILE}" "https://github.com/cue-lang/cue/releases/download/v${CUE_VERSION}/${ARCHIVE_FILE}"
    curl -fsSL -o checksums.txt "https://github.com/cue-lang/cue/releases/download/v0.6.0/checksums.txt"

    calculated_checksum=$(sha256sum "${ARCHIVE_FILE}" | awk '{print $1}')
    expected_checksum=$(grep "${ARCHIVE_FILE}" "checksums.txt" | awk '{print $1}')

    if [ "$calculated_checksum" != "$expected_checksum" ]; then
        echo -e "Invalid CUE archive checksom." >&2
        exit 1
    fi

    echo "Extracting CUE ${CUE_VERSION}..."

    tar -xzf "${ARCHIVE_FILE}" -C /usr/local/bin cue

    popd

    rm -rf /tmp/cue
fi

set +e

echo "Done!"
