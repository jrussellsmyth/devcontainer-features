# Dev Container Features

This repo provides Dev Container Features I have authored.

## Contents

### [`yarn-apt-publickey`](src/yarn-apt-publickey/README.md)

Installs the latest public key for the yarn apt repostiory. Workaround for debian devcontainers being borked by the yarn public key expiring while we wait for the maintainers to update all of the images.

### [`openspec`](src/openspec/README.md)

Installs the OpenSpec CLI in devcontainers, reuses or installs Node.js as needed, and can initialize supported OpenSpec tool integrations in the workspace when `toolSupport` is configured.
