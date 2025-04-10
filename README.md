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
| `all`    | Runs all the commands        |
