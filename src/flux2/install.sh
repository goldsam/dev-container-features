#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Activating feature 'flux2'"

if [ "${VERSION}" = "none" ] || type flux > /dev/null 2>&1; then
    echo "FLux already installed. Skipping..."
else
  if [ "${VERSION}" = "latest" ] ; then
    VERSION=
  else

  echo "Installing flux...'"

  # The official install script will honor FLUX_VERSION
  curl -s https://fluxcd.io/install.sh | FLUX_VERSION=$VERSION bash
fi

set +e

echo "Done!"
