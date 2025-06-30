#!/bin/bash

# Step 1: Backup important file if it exists
if [ -f "$HOME/rl-swarm/swarm.pem" ]; then
    echo "Backing up swarm.pem file to home directory"
    mv "$HOME/rl-swarm/swarm.pem" "$HOME/"
fi

# Step 2: Remove existing rl-swarm directory
if [ -d "$HOME/rl-swarm" ]; then
    echo "Removing old rl-swarm installation"
    rm -rf "$HOME/rl-swarm"
fi

# Step 3: Clone new version from your repository
echo "Downloading latest rl-swarm version"
git clone https://github.com/gensyn-ai/rl-swarm.git "$HOME/rl-swarm"

# Step 4: Restore backed up file
if [ -f "$HOME/swarm.pem" ]; then
    echo "Moving swarm.pem back into new installation"
    mv "$HOME/swarm.pem" "$HOME/rl-swarm/"
fi

echo "Update completed successfully"
