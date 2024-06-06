#!/bin/bash

# Clone xatu examples
git clone https://github.com/ethpandaops/xatu-data.git /tmp/xatu-data
rm -rf /home/jovyan/examples
mkdir -p /home/jovyan/examples
cp -r /tmp/xatu-data/examples/clickhouse/* /home/jovyan/examples/
rm -rf /tmp/xatu-data

# Start Jupyter Lab
exec jupyter lab
