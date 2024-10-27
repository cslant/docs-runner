#!/bin/bash

# shellcheck disable=SC2034
CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
DOCS_DIR="$SOURCE_DIR/$DOCS_NAME"
ENV=${ENV:-prod}
GIT_SSH_URL=${GIT_SSH_URL:-git@github.com:cslant}
DOCS_REPO="$GIT_SSH_URL/$DOCS_REPO.git"
USE_SUBMODULES=${USE_SUBMODULES:-false}
