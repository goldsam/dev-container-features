#!/usr/bin/env bash

set -e

FLUX_VERSION=${VERSION:-"latest"}

export DEBIAN_FRONTEND=noninteractive

echo "Activating feature 'flux2'"

if [ "${FLUX_VERSION}" = "none" ] || type flux > /dev/null 2>&1; then
    echo "FLux already installed. Skipping..."
else

  echo "Installing flux...'"

  if [ "${FLUX_VERSION}" = "latest" ] ; then
    curl -s https://fluxcd.io/install.sh | bash
  else
    curl -s https://fluxcd.io/install.sh | FLUX_VERSION=$FLUX_VERSION bash
  fi
  
fi

set +e

echo "Done!"
