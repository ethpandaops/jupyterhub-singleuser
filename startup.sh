#!/bin/bash

# Enable debug mode
set -x

# Clone xatu examples
echo "Cloning the xatu-data repository..."
git clone https://github.com/ethpandaops/xatu-data.git /tmp/xatu-data

# Check if the clone was successful
if [ $? -ne 0 ]; then
  echo "Failed to clone the repository"
  exit 1
fi

# Remove existing examples directory
echo "Removing existing examples directory..."
rm -rf /home/jovyan/examples

# Create a new examples directory
echo "Creating a new examples directory..."
mkdir -p /home/jovyan/examples

# Check if the examples directory was created successfully
if [ ! -d /home/jovyan/examples ]; then
  echo "Failed to create examples directory"
  exit 1
fi

# Copy the files
echo "Copying the examples from the repository..."
cp -r /tmp/xatu-data/examples/clickhouse/* /home/jovyan/examples/

# Check if the files were copied successfully
if [ $? -ne 0 ]; then
  echo "Failed to copy the examples"
  exit 1
fi

# Clean up the temporary directory
echo "Removing the temporary xatu-data directory..."
rm -rf /tmp/xatu-data

# Start Jupyter Lab
echo "Starting Jupyter Lab..."
exec jupyter lab
