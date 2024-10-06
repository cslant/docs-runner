#!/bin/bash

set -a
source .env
set +a
set -ue

source setup/tips.sh
source setup/git.sh
source setup/tools.sh
source setup/functions.sh

case "$1" in
  welcome)
    welcome
    ;;

  help | tips)
    usage
    ;;

  git_sync)
    git_sync
    ;;

  docs_sync)
    docs_sync "$2"
    ;;

  build | build_docs | b)
    build
    ;;

  worker | start_worker | w)
    worker
    ;;

  all | a)
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
