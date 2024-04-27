#!/bin/bash

set -a
source .env
set +a
set -ue

CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
DOCS_DIR="$SOURCE_DIR/$DOCS_NAME"

# figlet
echo "
  ____ ____  _        _    _   _ _____
 / ___/ ___|| |      / \  | \ | |_   _|
| |   \___ \| |     / _ \ |  \| | | |
| |___ ___) | |___ / ___ \| |\  | | |
 \____|____/|_____/_/   \_\_| \_| |_|
"

echo "- Current dir        : $CURRENT_DIR"
echo "- Source dir         : $SOURCE_DIR"
echo "- Docs name          : $DOCS_NAME"
echo "- Docs dir           : $DOCS_DIR"
echo ""

usage() {
  echo "Usage: $0 {git_clone}"
}

git_sync() {
  echo "» Syncing git repository..."

  if [ ! -d "$DOCS_DIR" ]; then
    cd "$SOURCE_DIR" || exit

    echo "  ∟ Cloning main-docs repository..."
    git clone "$DOCS_REPO" "$DOCS_NAME"
  else
    cd "$DOCS_DIR" || exit

    echo "  ∟ Pulling main-docs repository..."
    git pull
  fi
}

docs_sync() {
  echo "» Syncing docs..."
}

case "$1" in

git_sync)
    git_sync
    ;;

docs_sync)
    docs_sync
    ;;

all)
    git_sync
    docs_sync
    ;;

*)
    usage
    exit 1
    ;;
esac
