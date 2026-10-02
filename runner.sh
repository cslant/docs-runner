#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo '✗ .env is missing. Copy .env.example to .env and fill in the values.' >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

# A pipeline run has no terminal. Anything that would prompt has to fail instead
# of waiting, or the job hangs until the runner kills it.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes}"
export RSYNC_RSH="${RSYNC_RSH:-ssh -o BatchMode=yes}"

# shellcheck disable=SC1091
source setup/variables.sh
source setup/tips.sh
source setup/git.sh
source setup/tools.sh
source setup/functions.sh

case "${1:-}" in
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
    docs_sync "${2:-all}"
    ;;

  build | build_docs | b)
    build "${2:-install}"
    ;;

  worker | start_worker | w)
    worker
    ;;

  update_assets)
    update_assets
    ;;

  all | a)
    git_sync
    docs_sync all
    build install
    #worker
    ;;

  *)
    usage
    exit 1
    ;;
esac
