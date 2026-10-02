#!/bin/bash

build() {
  echo '⚙ Building docs...'

  cd "$DOCS_DIR" || exit

  BUILD_TYPE="$1"
  
  if [ ! -f "$DOCS_DIR/.env" ]; then
    echo '  ∟ .env file missing, copying from .env.example...'
    cp "$DOCS_DIR/.env.example" "$DOCS_DIR/.env"
  fi

  if ! command -v yarn &> /dev/null; then
    echo '  ∟ Installing yarn...'
    npm install -g yarn
  fi

  if [ ! -d "$DOCS_DIR/node_modules" ] || [ "$BUILD_TYPE" = "install" ]; then
    echo '  ∟ Installing dependencies...'
    if [ "$INSTALLER" = "yarn" ]; then
      yarn install --immutable
    else
      npm ci
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
  if [ "$ENV" = "prod" ]; then
    node_runner build
  else
    node_runner start
  fi
  echo ''
}

worker() {
  echo '📽 Starting worker...'

  if pm2 show "$WORKER_NAME" > /dev/null; then
    echo "  ∟ Restarting $WORKER_NAME..."
    # pm2 restart "$WORKER_NAME" --update-env
    pm2 reload ecosystem.config.cjs
  else
    echo "  ∟ Starting $WORKER_NAME..."
    cd "$DOCS_DIR" || exit

#     if [ "$INSTALLER" = "yarn" ]; then
#       pm2 start yarn --name "$WORKER_NAME" -- serve --port "$PORT"
#     else
#       pm2 start npm --name "$WORKER_NAME" -- run serve --port "$PORT"
#     fi

    pm2 start ecosystem.config.cjs
    pm2 save
  fi
  echo ''
}

node_runner() {
  echo '🏃‍♂️ Running node...'

  cd "$DOCS_DIR" || exit

  if [ "$INSTALLER" = "yarn" ]; then
    yarn "$@"
  else
    npm run "$@"
  fi
  echo ''
}

update_assets() {
  echo '🚀 Publishing assets...'

  # --delay-updates writes every file under a temporary name and renames them all
  # in one pass at the end; --delete-after holds back the removal of the previous
  # build until the new files are in place. Without both, the web root spends the
  # whole transfer missing files that live pages are already requesting, which is
  # what produced the burst of failed /assets/js/*.js requests after a deploy.
  rsync -az --delete-after --delay-updates \
    "$DOCS_DIR"/build/ "$SSH_NAME":"$SSH_DOCS_PATH"/ </dev/null

  echo "  ∟ Published $(git -C "$DOCS_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)" \
    "to $SSH_NAME:$SSH_DOCS_PATH"
  echo ''
}
