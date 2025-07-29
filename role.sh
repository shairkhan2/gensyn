#!/bin/bash
set -e

echo "=== Step 1: Installing Go 1.24.0 ==="
wget -q https://go.dev/dl/go1.24.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz
rm go1.24.0.linux-amd64.tar.gz

echo "=== Step 2: Setting Go PATH ==="
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Persist to bashrc
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
fi
if ! grep -q "$HOME/go/bin" ~/.bashrc; then
  echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
fi

# Make Go accessible to system-wide commands (e.g., used in make)
sudo ln -sf /usr/local/go/bin/go /usr/bin/go

echo "=== Step 3: Verifying Go installation ==="
go version

echo "=== Step 4: Installing GSwarm via go install (Option 1) ==="
go install github.com/Deep-Commit/gswarm/cmd/gswarm@latest

if [ -f "$HOME/go/bin/gswarm" ]; then
  echo "=== Step 5: Moving gswarm binary to /usr/local/bin ==="
  sudo mv "$HOME/go/bin/gswarm" /usr/local/bin/gswarm
fi

echo "=== Step 6: Verifying gswarm installation ==="
gswarm --version || echo "❌ gswarm install failed via go install"

echo "=== Step 7: Also installing from source (Option 2) ==="
rm -rf "$HOME/gswarm"
git clone https://github.com/Deep-Commit/gswarm.git
cd gswarm
make build
sudo make install
cd ..
rm -rf gswarm

echo "=== Step 8: How to use GSwarm ==="
echo ""
echo "✅ shairu here now use :"
echo "    gswarm"
echo ""
echo "📦 To set up Telegram notifications:"
echo "    1. Get your Telegram bot token from @BotFather"
echo "    2. Get your Telegram chat ID (can be a user or group)"
echo "    3. Run gswarm with proper config or env vars"
echo ""
echo "🎉 Done!"
