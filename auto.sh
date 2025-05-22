#!/bin/bash

show_menu() {
  echo "==== GENSYN SETUP MENU ===="
  echo "1) Install system & Python dependencies"
  echo "2) Clone RL-Swarm repo"
  echo "3) Run RL-Swarm (inside detached screen session)"
  echo "4) Run backup script"
  echo "5) Start Cloudflare Tunnel"
  echo "6) Attach to RL-Swarm screen session"
  echo "7) Exit"
  echo "8) Page loading fixed"
  echo "==========================="
  echo -n "Enter choice [1-8]: "
}

install_dependencies() {
  echo "[*] Installing dependencies..."
  sudo apt update && sudo apt install -y \
    python3 python3-pip python3-venv curl wget screen git lsof

  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs

  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null
  sudo apt update && sudo apt install -y yarn
}

clone_repo() {
  echo "[*] Cloning RL-Swarm repo..."
  git clone https://github.com/gensyn-ai/rl-swarm.git
  cd rl-swarm || exit

  python3 -m venv venv
  source venv/bin/activate
  if [ -f "requirements.txt" ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
  fi
}

run_rl_swarm() {
  echo "[*] Starting RL-Swarm in a detached screen session..."

  # Kill existing 'gensyn' screen session if running
  screen -S gensyn -X quit 2>/dev/null || true

  # Run ./run_rl_swarm in rl-swarm directory inside detached screen
  screen -dmS gensyn bash -c '
    cd rl-swarm || exit
    chmod +x ./run_rl_swarm
    echo "[*] Running ./run_rl_swarm..."
    ./run_rl_swarm
    exec bash
  '

  echo "[*] RL-Swarm is running inside detached screen session named 'gensyn'."
  echo "    Use Option 6 or run manually: screen -r gensyn"
}

run_backup_script() {
  echo "[*] Running backup.sh from GitHub..."
  [ -f backup.sh ] && rm backup.sh
  curl -sSL -O https://raw.githubusercontent.com/shairkhan2/gensyn/main/backup.sh
  chmod +x backup.sh
  ./backup.sh
}

start_cloudflare_tunnel() {
  echo "[*] Setting up Cloudflare Tunnel..."

  if ! command -v cloudflared &> /dev/null; then
    echo "[*] cloudflared not found. Installing..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
  fi

  echo -n "Enter the local port to tunnel (default 3000): "
  read -r port
  port=${port:-3000}

  echo "[*] Launching tunnel to http://localhost:$port"
  cloudflared tunnel --url http://localhost:$port
}

attach_screen_session() {
  if screen -list | grep -q "gensyn"; then
    echo "[*] Attaching to 'gensyn' screen session..."
    screen -r gensyn
  else
    echo "[!] No active 'gensyn' screen session found."
  fi
}

fix_page_loading() {
  echo "[*] Fixing page loading issue..."
  cd rl-swarm || { echo "[!] rl-swarm directory not found."; return; }
  curl -o modal-login/app/page.tsx https://raw.githubusercontent.com/shairkhan2/gensyn/main/page.tsx
  echo "[*] page.tsx has been updated."
}

while true; do
  show_menu
  read -r choice
  case $choice in
    1) install_dependencies ;;
    2) clone_repo ;;
    3) run_rl_swarm ;;
    4) run_backup_script ;;
    5) start_cloudflare_tunnel ;;
    6) attach_screen_session ;;
    7) echo "Goodbye!" && exit 0 ;;
    8) fix_page_loading ;;
    *) echo "[!] Invalid option. Please choose between 1 and 8." ;;
  esac
done
