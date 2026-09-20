# CSlant Docs Runner

```text
 ██████╗███████╗██╗      █████╗ ███╗   ██╗████████╗    ██████╗  ██████╗  ██████╗███████╗
██╔════╝██╔════╝██║     ██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██╔═══██╗██╔════╝██╔════╝
██║     ███████╗██║     ███████║██╔██╗ ██║   ██║       ██║  ██║██║   ██║██║     ███████╗
██║     ╚════██║██║     ██╔══██║██║╚██╗██║   ██║       ██║  ██║██║   ██║██║     ╚════██║
╚██████╗███████║███████╗██║  ██║██║ ╚████║   ██║       ██████╔╝╚██████╔╝╚██████╗███████║
 ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═════╝  ╚═════╝  ╚═════╝╚══════╝
```

This repo is to set up the runner for updating docs at https://docs.cslant.com

We can use this runner to update the docs automatically with CI/CD pipelines.

<img src="https://github.com/cslant/docs/blob/main/static/img/cslant-docs-runner.webp" alt="CSlant docs runner">

## Installation

First, copy the `.env.example` file to `.env` and update the values.

```bash
envsubst < .env.example > .env
```

In the `.env` file, update the values to match your environment.

```bash
# .env

SOURCE_DIR=/home/user/repo_dir

GIT_SSH_URL=git@github.com:cslant

# cslant/docs.git
DOCS_REPO=docs

#DOCS_NAME=docusaurus-docs
DOCS_NAME=main-docs

# The name of the runner
WORKER_NAME=cslant-docs

# add the env to choose "npm" or "yarn" as the installer
INSTALLER=yarn
PORT=3000
```

> [!IMPORTANT]
> ## Command can't be used if wrong values are set in the `.env` file.
> * If the `SOURCE_DIR` is wrong, the runner will not be able to find the source code. So, please make sure the `SOURCE_DIR` is correct.

Then, run the following command to start the runner.

```bash
bash runner.sh all
```

## Usage

The runner has the following commands:

| Command  | Description                  |
|----------|------------------------------|
| `help`   | Shows the help message       |
| `build`  | Builds the docs              |
| `worker` | Create or restart the worker |
| `update_assets` | Deploy `build/` atomically (release + symlink swap + edge prewarm) |
| `all`    | Runs all the commands        |

## Atomic deploy (update_assets)

`update_assets` no longer rsyncs in place (which made nginx serve a half-written
directory during deploys → transient 4xx/5xx for hashed chunks requested just
after a deploy). It now:

1. rsyncs `build/` into a **fresh release dir** on the display server:
   `$SSH_DOCS_PATH-releases/<timestamp>-<git-sha>/`
2. sanity-checks that `index.html` exists in the release
3. atomically re-points the **live symlink** `$SSH_DOCS_PATH/current` to the new release
4. pre-warms the shared edge cache for this release's hashed `js`/`css` assets
5. prunes old releases, keeping the newest `$KEEP_RELEASES`

nginx must root at `$SSH_DOCS_PATH/current` (a symlink) — see `server-configs`
`docs.cslant.com.main.conf`.

### One-time migration on the display server (only required once)

```bash
DOCS=/var/www/html/docs.cslant.com           # your actual SSH_DOCS_PATH
RELEASES="$DOCS-releases"
mkdir -p "$RELEASES"
INIT="$RELEASES/$(date +%Y%m%d%H%M%S)-initial"
rsync -a "$DOCS/" "$INIT/"
ln -sfn "$INIT" "$DOCS/current"
# apply the new nginx conf (root $docs_com_path/current), then:
nginx -t && systemctl reload nginx
# only after a deploy verifies fine, remove the old loose files under "$DOCS"/
```

### New `.env` keys (all optional)

| Key | Default | Purpose |
|-----|---------|---------|
| `SSH_RELEASES_DIR` | `$SSH_DOCS_PATH-releases` | where release dirs are stored |
| `SSH_LIVE_NAME` | `current` | live symlink name inside `$SSH_DOCS_PATH` |
| `KEEP_RELEASES` | `5` | releases kept after prune |
| `DOCS_PUBLIC_URL` | `https://docs.cslant.com` | base URL used for edge prewarm |
| `PREWARM_MAX` | `80` | max hashed assets to pre-warm per deploy |
