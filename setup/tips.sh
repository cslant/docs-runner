welcome() {
  echo '
  ____ ____  _        _    _   _ _____   ____   ___   ____ ____
 / ___/ ___|| |      / \  | \ | |_   _| |  _ \ / _ \ / ___/ ___|
| |   \___ \| |     / _ \ |  \| | | |   | | | | | | | |   \___ \
| |___ ___) | |___ / ___ \| |\  | | |   | |_| | |_| | |___ ___) |
 \____|____/|_____/_/   \_\_| \_| |_|   |____/ \___/ \____|____/
  '
  echo ''
  echo '⚡ Welcome to the docs runner!'
  echo ''
  echo "- Current dir        : $CURRENT_DIR"
  echo "- Source dir         : $SOURCE_DIR"
  echo "- Docs name          : $DOCS_NAME"
  echo "- Docs dir           : $DOCS_DIR"
  echo ''
}

usage() {
  welcome
  echo "Usage: bash $0 [command] [args]"
  echo ''
  echo 'Commands:'
  echo '  welcome         Show welcome message'
  echo '  help            Show this help message'
  echo '  git_sync        Sync git repository'
  echo '  docs_sync       Sync docs repository'
  echo '  build           Build docs'
  echo '  worker          Start worker'
  echo '  all             Sync git and docs repository, build docs'
  echo ''
  echo 'Args for docs_sync:'
  echo '  tgn             Sync telegram-git-notifier-docs repository'
  echo '  all             Sync all docs repository'
  echo ''
  echo 'Example:'
  echo "  bash $0 git_sync"
  echo "  bash $0 docs_sync all"
  echo "  bash $0 build"
  echo ''
}
