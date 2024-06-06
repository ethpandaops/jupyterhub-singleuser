#!/bin/bash

# Clone xatu examples
GITHUB_REPO_URL=https://github.com/ethpandaops/xatu-data.git
GITHUB_REPO_DIR=/tmp/xatu-data
git clone $GITHUB_REPO_URL $GITHUB_REPO_DIR

rm -rf $HOME/examples
mkdir -p $HOME/examples
cp -r $GITHUB_REPO_DIR/examples/clickhouse/* $HOME/examples/
rm -rf $GITHUB_REPO_DIR

# Start Jupyter Lab
exec jupyter lab
