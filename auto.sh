#!/bin/bash

# GENSYN SETUP MENU by shairkhan

install_dependencies() {
    echo "==== Installing system & Python dependencies ===="
    sudo apt update
    sudo apt install -y dos2unix git curl screen python3 python3-pip python3-venv
    pip3 install -U pip setuptools
    echo "Dependencies installed!"
}

clone_rlswarm_repo() {
    echo "==== Cloning RL-Swarm repo ===="
    git clone https://github.com/Gensyn-AI/rl-swarm.git || echo "Repo already exists."
    echo "RL-Swarm repo ready!"
}

run_rlswarm() {
    echo "==== Starting RL-Swarm inside screen session 'gensyn' ===="
    cd rl-swarm || { echo "RL-Swarm repo not found!"; return; }

    # Create virtual environment if not exists
    if [ ! -d ".venv" ]; then
        echo "Creating Python virtual environment (.venv)..."
        python3 -m venv .venv
    fi

    # Start screen session with venv activated
    screen -S gensyn -dm bash -c "source .venv/bin/activate && chmod +x run_rl_swarm.sh && ./run_rl_swarm.sh"
    echo "RL-Swarm is running in a detached screen session named 'gensyn'"
    cd ..
}

run_backup() {
    echo "==== Running backup script ===="
    bash backup.sh || echo "backup.sh not found!"
}

start_cloudflare() {
    echo "==== Starting Cloudflare tunnel in screen session 'cloudflare_gensyn' ===="
    screen -S cloudflare_gensyn -dm bash -c "cloudflared tunnel --url http://localhost:3000"
    echo "Cloudflare tunnel running in screen session 'cloudflare_gensyn'"
}

open_screen_sessions() {
    echo "==== Open Screen Sessions ===="
    screen -ls || echo "No screen sessions found."
}

attach_rlswarm_screen() {
    echo "==== Attaching to RL-Swarm screen session ===="
    screen -ls | grep gensyn || echo "No RL-Swarm screen session found."
    read -p "Enter the screen session ID or name (e.g. 12345.gensyn): " gensyn_session
    screen -r "$gensyn_session"
}

attach_cloudflare_screen() {
    echo "==== Attaching to Cloudflare Tunnel screen session ===="
    screen -r cloudflare_gensyn || echo "No Cloudflare tunnel screen found or already running."
}

fix_psx_loading_issue() {
    echo "==== Applying PSX loading page fix (placeholder) ===="
    # Add your real fix logic here
    echo "PSX loading fix applied (mockup)"
}

apply_cloudflare_rules() {
    echo "==== Applying Cloudflare rules (placeholder) ===="
    # Insert real logic here to configure WAF/routing if needed
    echo "Cloudflare rules set (mockup)"
}

while true; do
    echo ""
    echo "==== GENSYN SETUP MENU (by shairkhan) ===="
    echo "1) Install system & Python dependencies"
    echo "2) Clone RL-Swarm repo"
    echo "3) Run RL-Swarm (inside detached screen session)"
    echo "4) Run backup script"
    echo "5) Start Cloudflare Tunnel (inside screen session)"
    echo "6) Exit"
    echo "7) Open available screen sessions"
    echo "8) Attach to RL-Swarm screen"
    echo "9) Attach to Cloudflare Tunnel screen"
    echo "10) Fix PSX Loading Issue"
    echo "11) Apply Cloudflare Rules"
    echo "=========================================="
    read -p "Enter choice [1-11]: " choice

    case $choice in
        1) install_dependencies ;;
        2) clone_rlswarm_repo ;;
        3) run_rlswarm ;;
        4) run_backup ;;
        5) start_cloudflare ;;
        6) echo "Exiting..."; break ;;
        7) open_screen_sessions ;;
        8) attach_rlswarm_screen ;;
        9) attach_cloudflare_screen ;;
        10) fix_psx_loading_issue ;;
        11) apply_cloudflare_rules ;;
        *) echo "Invalid option!" ;;
    esac
done
