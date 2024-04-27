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
  welcome
  echo "Usage: bash $0 [command] [args]"
  echo ""
  echo "Commands:"
  echo "  welcome         Show welcome message"
  echo "  help            Show this help message"
  echo "  git_sync        Sync git repository"
  echo "  docs_sync       Sync docs repository"
  echo "  build           Build docs"
  echo "  worker          Start worker"
  echo "  all             Sync git and docs repository, build docs"
  echo ""
  echo "Args for docs_sync:"
  echo "  tgn             Sync telegram-git-notifier-docs repository"
  echo "  all             Sync all docs repository"
  echo ""
  echo "Example:"
  echo "  bash $0 git_sync"
  echo "  bash $0 docs_sync all"
  echo "  bash $0 build"
  echo ""
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

docs_sync() {
  echo '◎ Syncing docs...'

  cd "$DOCS_DIR/repo" || exit
  echo ''

  case "$1" in
    tgn)
      telegram_git_notifier_docs_sync
      ;;

    all)
      telegram_git_notifier_docs_sync
      ;;
  esac

  echo '◎ Syncing docs done!'
}

build() {
  echo '◎ Building docs...'

  cd "$DOCS_DIR" || exit

  echo '  ∟ Yarn build...'
  yarn build
}

worker() {
  echo "◎ Starting worker..."

  if pm2 show "$WORKER_NAME" > /dev/null; then
    echo "  ∟ Restarting $WORKER_NAME..."
    pm2 restart "$WORKER_NAME"
  else
    echo "  ∟ Starting $WORKER_NAME..."
    cd "$DOCS_DIR" || exit
    pm2 start yarn --name "$WORKER_NAME" -- start
  fi
}

telegram_git_notifier_docs_sync() {
  echo "» Syncing telegram-git-notifier-docs repository..."
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

case "$1" in
  welcome)
    welcome
    ;;

  help)
    usage
    ;;

  git_sync)
    git_sync
    ;;

  docs_sync)
    docs_sync "$2"
    ;;

  build)
    build
    ;;

  worker)
    worker
    ;;

  all)
    git_sync
    docs_sync all
    build
    worker
    ;;

  *)
    usage
    exit 1
    ;;
esac
