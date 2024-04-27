#!/bin/bash

set -a
source .env
set +a
set -ue

CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
DOCS_DIR="$SOURCE_DIR/$DOCS_NAME"

welcome() {
  # figlet
  echo "
    ____ ____  _        _    _   _ _____
   / ___/ ___|| |      / \  | \ | |_   _|
  | |   \___ \| |     / _ \ |  \| | | |
  | |___ ___) | |___ / ___ \| |\  | | |
   \____|____/|_____/_/   \_\_| \_| |_|
  "
  echo ""
  echo "» Welcome to the docs runner!"
  echo ""
  echo "- Current dir        : $CURRENT_DIR"
  echo "- Source dir         : $SOURCE_DIR"
  echo "- Docs name          : $DOCS_NAME"
  echo "- Docs dir           : $DOCS_DIR"
  echo ""
}

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

  echo ""
}

telegram_git_notifier_docs_sync() {
  echo "» Syncing docs..."

  cd "$DOCS_DIR" || exit

  cd repo || exit

  if [ -z "$(ls -A "telegram-git-notifier-docs")" ]; then
    echo "  ∟ Cloning telegram-git-notifier-docs repository..."
    git clone git@github.com:cslant/telegram-git-notifier-docs.git
  else
    echo "  ∟ Pulling telegram-git-notifier-docs repository..."
    cd telegram-git-notifier-docs || exit
    git pull
  fi
  echo ""
}

build() {
  echo "◎ Building docs..."

  cd "$DOCS_DIR" || exit

  echo "  ∟ Yarn build..."
  yarn build
}

case "$1" in

welcome)
  welcome
  ;;

help)
  welcome
  usage
  ;;

git_sync)
  git_sync
  ;;

docs_sync)
  telegram_git_notifier_docs_sync
  ;;

all)
  git_sync

  telegram_git_notifier_docs_sync

  build
  ;;

*)
  usage
  exit 1
  ;;
esac
