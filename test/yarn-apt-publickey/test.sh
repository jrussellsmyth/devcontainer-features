#!/bin/sh
set -e

KEYRING_PATH="/usr/share/keyrings/yarn-archive-keyring.gpg"

if [ ! -s "$KEYRING_PATH" ]; then
  echo "Yarn keyring not found at $KEYRING_PATH"
  exit 1
fi

installed_fpr=$(gpg --batch --with-colons --show-keys "$KEYRING_PATH" | awk -F: '/^fpr:/ {print $10; exit}')
downloaded_fpr=$(curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --batch --with-colons --show-keys | awk -F: '/^fpr:/ {print $10; exit}')

if [ -z "$installed_fpr" ] || [ -z "$downloaded_fpr" ]; then
  echo "Unable to read Yarn key fingerprint"
  exit 1
fi

if [ "$installed_fpr" != "$downloaded_fpr" ]; then
  echo "Installed Yarn key fingerprint does not match upstream"
  echo "Installed:  $installed_fpr"
  echo "Upstream:   $downloaded_fpr"
  exit 1
fi

echo "Yarn key fingerprint matches upstream: $installed_fpr"
