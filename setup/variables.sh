#!/bin/bash

# shellcheck disable=SC2034
CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
DOCS_DIR="$SOURCE_DIR/$DOCS_NAME"
ENV=${ENV:-prod}
GIT_SSH_URL=${GIT_SSH_URL:-git@github.com:cslant}
DOCS_REPO="$GIT_SSH_URL/$DOCS_REPO.git"
USE_SUBMODULES=${USE_SUBMODULES:-false}
SSH_NAME=${SSH_NAME:-cslant}
SSH_DOCS_PATH=${SSH_DOCS_PATH:-/home/cslant/docs.cslant.com}

# A trailing slash in .env leaks into every path built from this value, which is
# how paths like "/var/www/html/docs//current" showed up in deploy logs.
while [[ "$SSH_DOCS_PATH" == */ ]]; do
  SSH_DOCS_PATH="${SSH_DOCS_PATH%/}"
done
