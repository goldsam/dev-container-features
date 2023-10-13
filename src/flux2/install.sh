#!/usr/bin/env bash

set -e

FLUX_VERSION=${VERSION:-"latest"}

export DEBIAN_FRONTEND=noninteractive

echo "Activating feature 'flux2'"

if [ "${FLUX_VERSION}" = "none" ] || type flux > /dev/null 2>&1; then
    echo "FLux already installed. Skipping..."
else

  echo "Installing flux...'"

  # The official install script will honor FLUX_VERSION
  curl -s https://fluxcd.io/install.sh | bash
fi

set +e

echo "Done!"
