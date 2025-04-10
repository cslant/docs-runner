#!/bin/bash

git_sync() {
  echo "📥 Syncing $DOCS_NAME repository..."
  echo ''

  if [ ! -d "$DOCS_DIR" ]; then
    cd "$SOURCE_DIR" || exit

    echo "  ∟ Cloning $DOCS_NAME repository... $DOCS_REPO"
    git clone "$DOCS_REPO" "$DOCS_NAME"
  else
    cd "$DOCS_DIR" || exit

    echo "  ∟ Pulling $DOCS_NAME repository..."

    git checkout main -f
    git pull
  fi

  echo ''
}

docs_sync() {
  echo '📥 Syncing docs...'
  echo ''

  case "$1" in
    tgn)
      telegram_git_notifier_docs_sync
      ;;

    laravel-like)
      laravel_like_docs_sync
      ;;

    github-project-php)
      github_project_php_sync
      ;;

    all)
      if [ "$USE_SUBMODULES" = true ]; then
        clone_submodules
      else
        telegram_git_notifier_docs_sync
        laravel_like_docs_sync
        github_project_php_sync
      fi
      ;;
  esac

  echo '✨ Syncing docs done!'
  echo ''
}

clone_submodules() {
  echo "📥 Cloning submodules..."
  cd "$DOCS_DIR" || exit

  git submodule update --init --recursive
  git submodule foreach git pull origin main -f || true
  echo ''
}

# ========================================
repo_sync_template() {
  REPO_NAME="$1"
  REPO_DIR="${2:-}"

  if [ -z "$REPO_DIR" ]; then
    REPO_DIR="$REPO_NAME"
  fi

  echo "» Syncing $REPO_NAME repository..."
  cd "$DOCS_DIR/repos" || exit
  if [ -z "$(ls -A "$REPO_DIR")" ]; then
    echo "  ∟ Cloning $REPO_NAME repository..."
    git clone "$GIT_SSH_URL"/"$REPO_NAME".git "$REPO_DIR"
  else
    echo "  ∟ Pulling $REPO_NAME repository..."
    cd "$DOCS_DIR/repos/$REPO_DIR" || exit

    git checkout main -f
    git pull
  fi
  echo ''
}

# Repository: telegram-git-notifier-docs
telegram_git_notifier_docs_sync() {
  repo_sync_template "telegram-git-notifier-docs"
  repo_sync_template "laravel-telegram-git-notifier" "telegram-git-notifier"
}

# Repository: laravel-like-docs
laravel_like_docs_sync() {
  repo_sync_template "laravel-like-docs"
}

github_project_php_sync() {
  repo_sync_template "github-project-php-docs"
}
