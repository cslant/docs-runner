#!/bin/bash

CURRENT_DIR=$(pwd)
SOURCE_DIR=$(readlink -f "$SOURCE_DIR")
DOCS_DIR="$SOURCE_DIR/$DOCS_NAME"
