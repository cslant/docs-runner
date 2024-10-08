git_sync() {
  echo "📥 Syncing $DOCS_NAME repository..."
  echo ''

  if [ ! -d "$DOCS_DIR" ]; then
    cd "$SOURCE_DIR" || exit

    echo "  ∟ Cloning $DOCS_NAME repository..."
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

    all)
      telegram_git_notifier_docs_sync
      laravel_like_docs_sync
      ;;
  esac

  echo '✨ Syncing docs done!'
  echo ''
}

# ========================================
repo_sync_template() {
  REPO_NAME="$1"

  echo "» Syncing $REPO_NAME repository..."
  cd "$DOCS_DIR/repos" || exit
  if [ -z "$(ls -A "$REPO_NAME")" ]; then
    echo "  ∟ Cloning $REPO_NAME repository..."
    git clone git@github.com:cslant/"$REPO_NAME".git
  else
    echo "  ∟ Pulling $REPO_NAME repository..."
    cd "$REPO_NAME" || exit

    git checkout main -f
    git pull
  fi
  echo ''
}

# Repository: telegram-git-notifier-docs
telegram_git_notifier_docs_sync() {
  repo_sync_template "telegram-git-notifier-docs"
}

# Repository: laravel-like-docs
laravel_like_docs_sync() {
  repo_sync_template "laravel-like-docs"
}
