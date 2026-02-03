#!/bin/sh
set -e

echo "Installing Yarn GPG keyring..."

# Ensure the directory exists
mkdir -p /usr/share/keyrings

# Run your command
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg \
  | gpg --batch --yes --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg

echo "Done!"