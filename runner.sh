#!/bin/bash

set -a
source .env
set +a
set -ue

source setup/tips.sh
source setup/git.sh
source setup/functions.sh

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
