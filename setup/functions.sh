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
    echo '🚀 Deploying assets (atomic release swap)...'

    # Release dir on the display server, sibling of the live dir. We NEVER
    # rsync into the live path, so nginx never serves a half-written dir.
    local release_dir commit_short
    commit_short=$(git -C "$DOCS_DIR" rev-parse --short HEAD 2>/dev/null || echo local)
    release_dir="$SSH_RELEASES_DIR/$(date +%Y%m%d%H%M%S)-$commit_short"

    ssh "$SSH_NAME" "mkdir -p '$SSH_RELEASES_DIR' '$SSH_DOCS_PATH'"
    rsync -avz "$DOCS_DIR"/build/ "$SSH_NAME":"$release_dir"

    # Sanity check: never point live at a broken release.
    if ! ssh "$SSH_NAME" "test -s '$release_dir/index.html'"; then
        echo "  ✗ index.html missing in '$release_dir', aborting swap"
        return 1
    fi

    # Atomic symlink swap: in-flight requests keep serving the old release,
    # new requests resolve to the new one. No missing-file window.
    ssh "$SSH_NAME" "ln -sfn '$release_dir' '$SSH_DOCS_LIVE'"
    echo "  ∟ Swapped '$SSH_DOCS_LIVE' -> '$release_dir'"

    # Warm shared edge cache for this release's hashed assets.
    prewarm_assets

    # Prune old releases, keep the newest $KEEP_RELEASES.
    # Sort lexicographically: release dirs are named <YYYYmmddHHMMSS>-<sha>, so
    # name order == chronological order (mtime ties unreliable for same-minute).
    ssh "$SSH_NAME" "find '$SSH_RELEASES_DIR' -mindepth 1 -maxdepth 1 -type d | sort -r | tail -n +\$(($KEEP_RELEASES + 1)) | xargs -r rm -rf"
    echo ''
}

prewarm_assets() {
    echo "  ∟ Pre-warming edge cache (up to $PREWARM_MAX assets)..."
    if ! command -v curl >/dev/null 2>&1; then
        echo '  ∟ curl not found, skipping prewarm'
        return 0
    fi

    local base
    base="${DOCS_PUBLIC_URL%/}"
    export base

    find "$DOCS_DIR/build/assets" -type f \( -name '*.js' -o -name '*.css' \) \
        | head -n "$PREWARM_MAX" \
        | xargs -P 8 -I{} bash -c 'curl -fsS -o /dev/null --max-time 20 "$base/${1#*build/}"' _ {}
}
