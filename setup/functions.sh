build() {
  echo '⚙ Building docs...'

  cd "$DOCS_DIR" || exit

  BUILD_TYPE="$1"

  if ! command -v yarn &> /dev/null; then
    echo '  ∟ Installing yarn...'
    npm install -g yarn
  fi

  if [ ! -d "$DOCS_DIR/node_modules" ] || [ "$BUILD_TYPE" = "install" ]; then
    echo '  ∟ Installing dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn install
    else
      npm install
    fi
  else
    echo '  ∟ Updating dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn upgrade
    else
      npm update
    fi
  fi

  echo '  ∟ INSTALLER build...'
  if [ "$INSTALLER" = "yarn" ]; then
    yarn build
  else
    npm run build
  fi
  echo ''
}

worker() {
  echo '📽 Starting worker...'

  if pm2 show "$WORKER_NAME" > /dev/null; then
    echo "  ∟ Restarting $WORKER_NAME..."
    pm2 restart "$WORKER_NAME" --update-env
  else
    echo "  ∟ Starting $WORKER_NAME..."
    cd "$DOCS_DIR" || exit

    if [ "$INSTALLER" = "yarn" ]; then
      pm2 start yarn --name "$WORKER_NAME" -- serve --port "$PORT"
    else
      pm2 start npm --name "$WORKER_NAME" -- run serve --port "$PORT"
    fi
    pm2 save
  fi
  echo ''
}
