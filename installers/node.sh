#!/usr/bin/env bash

# Sourced from: https://github.com/nvm-sh/nvm

export NVM_DIR="$HOME/.local/bin/nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"