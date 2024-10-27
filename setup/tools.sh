#!/bin/bash

if [ "$ENV" = "prod" ]; then
  if ! command -v pm2 &> /dev/null; then
    echo '  ∟ Installing pm2...'
    npm install -g pm2
  fi
fi
