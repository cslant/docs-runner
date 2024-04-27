#! /bin/bash

set -a
source .env
set +a
set -ue

CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
DOCS_DIR=$(readlink -f "$DOCS_DIR")

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
echo "- Docs dir           : $DOCS_DIR"
echo ""
