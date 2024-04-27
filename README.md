# CSlant Docs Runner

This repo is to set up the runner for updating docs at https://docs.cslant.com/

We can use this runner to update the docs automatically with CI/CD pipelines.

## Installation

First, copy the `.env.example` file to `.env` and update the values.

```bash
envsubst < .env.example > .env
```

In the `.env` file, update the values to match your environment.

```bash
# .env

SOURCE_DIR=/home/user/repo_dir

DOCS_REPO=git@github.com:cslant/main-docs.git

# The name of the docs repo
DOCS_NAME=main-docs

# The name of the runner
WORKER_NAME=cslant-docs
```

Then, run the following command to start the runner.

```bash
bash runnner.sh all
```

## Usage

The runner has the following commands:

| Command  | Description                  |
|----------|------------------------------|
| `help`   | Shows the help message       |
| `build`  | Builds the docs              |
| `worker` | Create or restart the worker |
| `all`    | Runs all the commands        |

