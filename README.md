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

| Command         | Description                                      |
|-----------------|--------------------------------------------------|
| `help`          | Shows the help message                           |
| `git_sync`      | Pulls the docs repository                        |
| `docs_sync`     | Pulls the per-package docs repositories          |
| `build`         | Builds the docs                                  |
| `worker`        | Create or restart the worker                     |
| `update_assets` | Publishes `build/` to the web server over rsync  |
| `all`           | `git_sync`, `docs_sync all` and `build install`   |

`all` does not publish. The pipeline runs `./runner.sh a` and then
`./runner.sh update_assets`, so a failed build never reaches the web server.

## Publishing (update_assets)

`update_assets` rsyncs `build/` straight into `$SSH_DOCS_PATH` on the web server,
which is the directory nginx serves. There is no release directory and no symlink
swap: the publish is already atomic enough through two rsync flags.

- `--delay-updates` writes every file under a temporary name and renames them all
  in one pass at the end.
- `--delete-after` holds back the removal of the previous build until the new
  files are in place.

Without both, the web root spends the whole transfer missing files that live
pages are requesting, and visitors see failed `/assets/js/*.js` requests for as
long as the sync takes.
